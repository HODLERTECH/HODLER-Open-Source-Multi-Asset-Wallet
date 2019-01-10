/// /////
/// Keypool Manager
/// 2018 Copyleft
/// /////
unit KeypoolRelated;

interface

uses
  System.classes, System.sysutils, FMX.Controls, FMX.StdCtrls, FMX.dialogs,
  StrUtils, WalletStructureData, CryptoCurrencyData, tokenData, System.SyncObjs,
  Velthuis.BigIntegers, Generics.Collections;

const
  maxKeypoolFillThreads = 19;
  requiredKeyPool: Integer = 100;
  changeDelimiter = 1073741823;

type
  TFillKeypoolThread = class(TThread)
  private
    crypto: cryptoCurrency;
  public
    queneID: Integer;
    procedure setCC(cc: cryptoCurrency);
    procedure Execute(); override;
    procedure cleanupRoutine;
  end;

type
  TKeypoolQuene = array[0..maxKeypoolFillThreads] of TFillKeypoolThread;

procedure sanitizePool;

function findUnusedReceiving(wi: TWalletInfo): twalletinfo;

function findUnusedChange(wi: TWalletInfo; ms: AnsiString): TWalletInfo;

procedure startFullfillingKeypool(ms: ansistring);

var
  threadPool: TKeypoolQuene;
  GhostMasterSeed: ansistring = '00000000000000000000000000000000000000000000000000000000000000';

implementation

uses
  Bitcoin, uHome, base58, Ethereum, coinData, secp256k1, AccountRelated, misc;

procedure TFillKeypoolThread.setCC(cc: cryptoCurrency);
begin
  self.crypto := cc;
end;

function keypoolrequirementsmet(wi: TWalletInfo): Boolean;
begin
  result := not ((wi.coin = 4) or (wi.coin >= 10000) or (wi.x = -1) or (CurrentAccount = nil))
end;

procedure TFillKeypoolThread.Execute();
var
  newY, missing, i: Integer;
  newOne: TWalletInfo;

  function findUnusedReceiveY(wi: TWalletInfo): Integer;
  var
    wd: TWalletInfo;
    Ys: tArray<Integer>;
    i, j: Integer;
  begin
    i := 0;
    for wd in CurrentAccount.myCoins do
      if (wd.x = wi.x) and (wd.coin = wi.coin) then
      begin
        SetLength(Ys, i + 1);
        Ys[i] := wd.Y;
        Inc(i);
      end;
    tArray.Sort<Integer>(Ys);
    if Length(Ys) = 1 then
    begin
      Exit(Ys[0] + 1);
    end;
    for i := 1 to Length(Ys) - 2 do
    begin
      j := Ys[i - 1];
      if Abs(j - Ys[i]) > 1 then
        Exit(j + 1);
    end;
  end;

  function missingAmount: Integer;
  var
    arr: array of Integer;
    wd: TWalletInfo;
    flagElse, sorted: Boolean;
    i, j: Integer;
    debugString: ansistring;
  begin
    i := 0;
    result := 100;
    SetLength(arr, CurrentAccount.countWalletBy(TWalletInfo(self.crypto).coin));
    for wd in CurrentAccount.myCoins do
    begin
      if result = 0 then
        Break;

      if wd.x = -1 then
        continue;
      if (wd.coin = TWalletInfo(self.crypto).coin) and (wd.X = TWalletInfo(self.crypto).X) then
      begin
        if Length(wd.History) = 0 then
          Dec(result);

      end;

    end;
  end;

begin
try
if Self=nil then Exit;

  if keypoolRequirementsMet(TWalletInfo(self.crypto)) = false then
  begin
    cleanupRoutine;
    Exit;
  end;
  newOne := nil;
  missing := missingAmount;
  for i := 0 to missing - 1 do
  begin

    if Self.Terminated then
      Exit();
    newY := findUnusedReceiveY(TWalletInfo(self.crypto));
    newOne := coinData.createCoin(TWalletInfo(Self.crypto).coin, TWalletInfo(self.crypto).X, newY, GhostMasterSeed, self.crypto.description);
    newOne.inPool := True; // Pooled
    if Self.Terminated then
      Exit();
    CurrentAccount.AddCoin(newOne);
    CurrentAccount.SaveFiles;
  end;
  cleanupRoutine;
  except on E:Exception do begin SHowMessage(E.Message) end;  end;
end;

procedure TFillKeypoolThread.cleanupRoutine;
begin
  threadPool[queneID] := nil;
  self.crypto := nil;
  self.Terminate;

end;

procedure keypoolCoin(xcc: cryptoCurrency);
var
  th: TFillKeypoolThread;
  i: Integer;
begin
  if BigInteger.Parse('+0x00' + GhostMasterSeed).isZero then
    Exit;

  for i := 0 to maxKeypoolFillThreads do
    if threadPool[i] = nil then
    begin
      threadPool[i] := TFillKeypoolThread.Create(true);
      threadPool[i].SetFreeOnTerminate(true);
      threadPool[i].queneID := i;
      threadPool[i].setCC(xcc);
      threadPool[i].Start;
      Break;
    end;
end;

procedure startFullfillingKeypool(ms: ansistring);
var
  wd: TWalletInfo;
begin
  GhostMasterSeed := ms;
  for wd in CurrentAccount.myCoins do
  begin
    if (wd.Y = 0) and (wd.deleted = False) and (not wd.inPool) then
      keypoolCoin(wd);
  end;
  wipeAnsiString(ms);
end;

procedure sanitizePool;
var
  i, standing: Integer;
begin
  standing := 0;
  for i := 0 to maxKeypoolFillThreads do
    if threadPool[i] <> nil then
      Inc(standing);

  if standing = 0 then
    wipeAnsiString(GhostMasterSeed);

end;

function pickFromPool(wi: TWalletInfo): TWalletInfo;
var
  arr: array of Integer;
  wd: TWalletInfo;
  flagElse, sorted: Boolean;
  i, j: Integer;
  debugString: ansistring;
begin
  result := wi;
  try
    SetLength(arr, CurrentAccount.countWalletBy(wi.coin));
    for wd in CurrentAccount.myCoins do
    begin

      if wd.x = -1 then
        continue;
      if (wd.coin = wi.coin) and (wd.X = wi.X) and (wd.inPool) then
      begin

        if Length(wd.History) = 0 then
        begin
          wd.inPool := false;
          CurrentAccount.SaveFiles;
          Exit(wd);
        end;
      end;

    end;

  except
    on E: Exception do
    begin
    end;

  end;
end;

function findUnusedReceiving(wi: TWalletInfo): twalletinfo;
var
  arr: array of Integer;
  wd: TWalletInfo;
  flagElse, sorted: Boolean;
  i, j: Integer;
  debugString: ansistring;
  used, all: integer;
begin
  used := 0;
  all := 0;
  result := wi;
  if keypoolRequirementsMet(wi) = false then
    Exit;

  try
    SetLength(arr, CurrentAccount.countWalletBy(wi.coin));
    for wd in CurrentAccount.myCoins do
    begin

      if wd.x = -1 then
        continue;
      if (wd.coin = wi.coin) and (wd.X = wi.X) and (not wd.inPool) then
      begin
        Inc(all);
        if Length(wd.History) <> 0 then
          Inc(used)
        else
          Exit(wd);

      end;

    end;
    if all > 0 then
      if all - used = 0 then
        Exit(pickFromPool(wi));
  except
    on E: Exception do
    begin
    end;

  end;
end;

function findUnusedChangeY(wi: TWalletInfo): Integer;
var
  wd: TWalletInfo;
  Ys: tArray<Integer>;
  i, j: Integer;
begin
  i := 0;
  for wd in CurrentAccount.myCoins do
    if (wd.x = wi.x) and (wd.coin = wi.coin) and (wd.Y > changeDelimiter) then
    begin
      SetLength(Ys, i + 1);
      Ys[i] := wd.Y;
      Inc(i);
    end;
  tArray.Sort<Integer>(Ys);
  if Length(Ys) = 1 then
  begin
    Exit(Ys[0] + 1);
  end;
  if Length(Ys) = 0 then
    Exit(changeDelimiter + 1);
  for i := 1 to Length(Ys) - 2 do
  begin
    j := Ys[i - 1];
    if Abs(j - Ys[i]) > 1 then
      Exit(j + 1);
  end;
end;

function findUnusedChange(wi: TWalletInfo; ms: AnsiString): TWalletInfo;
var
  arr: array of Integer;
  wd: TWalletInfo;
  flagElse, sorted: Boolean;
  i, j: Integer;
  debugString: ansistring;
  used, all, newY: integer;
  newOne: TWalletInfo;
begin
  used := 0;
  all := 0;
  result := wi;
  if keypoolRequirementsMet(wi) = false then
    Exit;

  try
    SetLength(arr, CurrentAccount.countWalletBy(wi.coin));
    for wd in CurrentAccount.myCoins do
    begin

      if wd.x = -1 then
        continue;
      if (wd.coin = wi.coin) and (wd.X = wi.X) and (wd.Y > changeDelimiter) then
      begin
        Inc(all);
        if Length(wd.History) <> 0 then
          Inc(used)
        else
          Exit(wd);

      end;

    end;
    newY := findUnusedChangeY(wi);
    newOne := coinData.createCoin(wi.coin, wi.X, newY, ms, wi.description);
    CurrentAccount.AddCoin(newOne);
    CurrentAccount.SaveFiles;
    wipeAnsiString(ms);
    Exit(newOne);
  except
    on E: Exception do
    begin
    end;

  end;

end;

end.

