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
  TKeypoolQuene = array [0 .. maxKeypoolFillThreads] of TFillKeypoolThread;

procedure sanitizePool;

function findUnusedReceiving(wi: TWalletInfo): TWalletInfo;

function findUnusedChange(wi: TWalletInfo; ms: AnsiString;
  forceCreate: boolean = false): TWalletInfo;

procedure startFullfillingKeypool(ms: AnsiString);
procedure kLog(s: string);

var
  threadPool: TKeypoolQuene;
  GhostMasterSeed
    : AnsiString =
    '00000000000000000000000000000000000000000000000000000000000000';

implementation

uses
  Bitcoin, uHome, base58, Ethereum, coinData, secp256k1, AccountRelated, misc,
  SyncThr;

procedure kLog(s: string);
var
  flock: TObject;
  ts: TStringList;
begin
  (* {$IFDEF  DEBUG}
    flock := TObject.Create;
    TMonitor.Enter(flock);
    ts := TStringList.Create;
    try
    if FileExists('klog.txt') then
    ts.LoadFromFile('klog.txt');
    ts.Add(s);
    ts.SaveToFile('klog.txt');
    except
    on E: Exception do
    begin

    end;
    end;
    ts.Free;
    TMonitor.Exit(flock);
    flock.Free;
    {$ENDIF} *)
end;

procedure TFillKeypoolThread.setCC(cc: cryptoCurrency);
begin
  self.crypto := cc;
end;

function keypoolrequirementsmet(wi: TWalletInfo): boolean;
begin
  result := not((wi.coin = 4) or (wi.coin >= 10000) or (wi.x = -1) or
    (CurrentAccount = nil));
  kLog('keypoolrequirementsmet wi.X: ' + IntToStr(TWalletInfo(wi).x) + ' bool: '
    + booltostr(result));
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
    result := -1;
    i := 0;
    SetLength(Ys, 0);
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
    for i := 1 to Length(Ys) - 1 do
    begin
      j := Ys[i - 1];
      if Abs(j - Ys[i]) > 1 then
        Exit(j + 1);
      result := Ys[i] + 1;
    end;
  end;

  function missingAmount: Integer;
  var
    arr: array of Integer;
    wd: TWalletInfo;
    flagElse, sorted: boolean;
    i, j: Integer;
    debugString: AnsiString;
  begin
    i := 0;
    result := requiredKeyPool;
    try
      SetLength(arr, CurrentAccount.countWalletBy
        (TWalletInfo(self.crypto).coin));
      for wd in CurrentAccount.myCoins do
      begin
        if result = 0 then
          Break;

        if wd.x = -1 then
          continue;
        if (wd.coin = TWalletInfo(self.crypto).coin) and
          (wd.x = TWalletInfo(self.crypto).x) then
        begin
          if Length(wd.History) = 0 then
            Dec(result);

        end;

      end;
    except
      on E: Exception do
      begin
      end;
    end;
  end;
  function missingChangeAmount: Integer;
  var
    arr: array of Integer;
    wd: TWalletInfo;
    flagElse, sorted: boolean;
    i, j: Integer;
    debugString: AnsiString;
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
      if (wd.coin = TWalletInfo(self.crypto).coin) and
        (wd.x = TWalletInfo(self.crypto).x) and (wd.Y >= changeDelimiter) then
      begin
        if Length(wd.History) = 0 then
          Dec(result);

      end;

    end;
  end;

begin
  try
    if self = nil then
    begin
      kLog('Self = nil');
      Exit;
    end;
    if keypoolrequirementsmet(TWalletInfo(self.crypto)) = false then
    begin
      kLog('keypoolrequirementsmet=false, exiting');
      cleanupRoutine;
      Exit;
    end;
    kLog('189: enter keypooler for Self.Crypto: ' +
      IntToStr(TWalletInfo(self.crypto).coin) + ' AccName: ' +
      CurrentAccount.Name);
    newOne := nil;
    missing := missingAmount;
    kLog('192: enter keypooler for Self.Crypto: ' +
      IntToStr(TWalletInfo(self.crypto).coin) + ' Missing: ' +
      IntToStr(missing));
    while (missing > 0) do
    begin

      for i := 0 to missing - 1 do
      begin

        if self.Terminated then
          Exit();
        newY := findUnusedReceiveY(TWalletInfo(self.crypto));
        if newY = -1 then
          continue;
        kLog('192: receive loop for Self.Crypto: ' +
          IntToStr(TWalletInfo(self.crypto).coin) + ' NewY: ' + IntToStr(newY));
        newOne := coinData.createCoin(TWalletInfo(self.crypto).coin,
          TWalletInfo(self.crypto).x, newY, GhostMasterSeed,
          self.crypto.description);
        newOne.inPool := false; // Pooled
        if self.Terminated then
          Exit();
        CurrentAccount.AddCoin(newOne);
        CurrentAccount.SaveFiles;

      end;
      verifyKeypoolNoThread(CurrentAccount, TWalletInfo(self.crypto));
      missing := missingAmount;
      kLog('217: verifyKeypool for Self.Crypto: ' +
        IntToStr(TWalletInfo(self.crypto).coin) + ' Missing: ' +
        IntToStr(missing));
    end;
    missing := missingChangeAmount();
    kLog('220: enter change keypooler for Self.Crypto: ' +
      IntToStr(TWalletInfo(self.crypto).coin) + ' Missing: ' +
      IntToStr(missing));
    while (missing > 0) do
    begin

      if self.Terminated then
        Exit();
      findUnusedChange(TWalletInfo(self.crypto), GhostMasterSeed, True);
      missing := missingChangeAmount();
      kLog('228: change loop for Self.Crypto: ' +
        IntToStr(TWalletInfo(self.crypto).coin) + ' Missing: ' +
        IntToStr(missing));
      if missing = 0 then
        Break;
      verifyKeypoolNoThread(CurrentAccount, TWalletInfo(self.crypto));
    end;

    cleanupRoutine;
  except
    on E: Exception do
    begin
      kLog(E.Message)
    end;
  end;
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
  begin
    kLog('ms =""');
    Exit;
  end;
  for i := 0 to maxKeypoolFillThreads do
    if threadPool[i] = nil then
    begin
      threadPool[i] := TFillKeypoolThread.Create(True);
      threadPool[i].SetFreeOnTerminate(True);
      threadPool[i].queneID := i;
      threadPool[i].setCC(xcc);
      threadPool[i].Start;
      Break;
    end;
end;

procedure startFullfillingKeypool(ms: AnsiString);
var
  wd: TWalletInfo;
begin
  GhostMasterSeed := ms;
  for wd in CurrentAccount.myCoins do
  begin
    if wd.coin in [4, 8] then
      continue;

    kLog(Format('checking coin %d wd X: %d Y: %d', [wd.coin, wd.x, wd.Y]));
    if (wd.Y = 0) and (wd.deleted = false) and (not wd.inPool) then
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
    TThread.CreateAnonymousThread(
      procedure
      begin
        sleep(5000);
        wipeAnsiString(GhostMasterSeed);
      end)

end;

function pickFromPool(wi: TWalletInfo; receiving: boolean = True): TWalletInfo;
var
  arr: array of Integer;
  wd: TWalletInfo;
  flagElse, sorted: boolean;
  i, j: Integer;
  debugString: AnsiString;
begin
  result := wi;
  try
    SetLength(arr, CurrentAccount.countWalletBy(wi.coin));
    for wd in CurrentAccount.myCoins do
    begin

      if wd.x = -1 then
        continue;
      if (wd.coin = wi.coin) and (wd.x = wi.x) and (wd.inPool) then
      begin
        if receiving then
          if wd.Y > changeDelimiter then
            continue;

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

function findUnusedReceiving(wi: TWalletInfo): TWalletInfo;
var
  arr: array of Integer;
  wd: TWalletInfo;
  flagElse, sorted: boolean;
  i, j: Integer;
  debugString: AnsiString;
  used, all: Integer;
begin
  used := 0;
  all := 0;
  result := wi;
  if keypoolrequirementsmet(wi) = false then
    Exit;

  try
    SetLength(arr, CurrentAccount.countWalletBy(wi.coin));
    for wd in CurrentAccount.myCoins do
    begin

      if wd.x = -1 then
        continue;
      if (wd.coin = wi.coin) and (wd.x = wi.x) and (not wd.inPool) then
      begin
        Inc(all);
        if (Length(wd.History) <> 0) and (wd.Y < changeDelimiter) then
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
  result := -1;
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
  for i := 1 to Length(Ys) - 1 do
  begin
    j := Ys[i - 1];
    if Abs(j - Ys[i]) > 1 then
      Exit(j + 1);
    result := Ys[i] + 1;
  end;
end;

function findUnusedChange(wi: TWalletInfo; ms: AnsiString;
forceCreate: boolean = false): TWalletInfo;
var
  arr: array of Integer;
  wd: TWalletInfo;
  flagElse, sorted: boolean;
  i, j: Integer;
  debugString: AnsiString;
  used, all, newY: Integer;
  newOne: TWalletInfo;
begin
  used := 0;
  all := 0;
  result := wi;
  if keypoolrequirementsmet(wi) = false then
    Exit;

  try
    SetLength(arr, CurrentAccount.countWalletBy(wi.coin));
    for wd in CurrentAccount.myCoins do
    begin

      if wd.x = -1 then
        continue;
      if (wd.coin = wi.coin) and (wd.x = wi.x) and (wd.Y >= changeDelimiter)
      then
      begin
        Inc(all);
        if Length(wd.History) <> 0 then
          Inc(used)
        else if not forceCreate then
          Exit(wd);

      end;

    end;
    newY := findUnusedChangeY(wi);
    if newY = -1 then
      Exit;

    newOne := coinData.createCoin(wi.coin, wi.x, newY, ms, wi.description);
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
