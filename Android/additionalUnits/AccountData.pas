unit AccountData;

interface

uses tokenData, WalletStructureData, cryptoCurrencyData, System.IOUtils,
  Sysutils, Classes, FMX.Dialogs;

type
  Account = class
    name: AnsiString;
    myCoins: array of TWalletInfo;
    myTokens: array of Token;
    TCAIterations: Integer;
    EncryptedMasterSeed: AnsiString;
    userSaveSeed: boolean;
    privTCA: boolean;
    DirPath: AnsiString;
    CoinFilePath: AnsiString;
    TokenFilePath: AnsiString;
    SeedFilePath: AnsiString;
    Paths: Array of AnsiString;

    constructor Create(_name: AnsiString);
    destructor Destroy(); override;

    procedure LoadFiles();
    procedure SaveFiles();

    procedure AddCoin(wd: TWalletInfo);
    procedure AddToken(T: Token);
    function countWalletBy(id: Integer): Integer;

  private
    procedure SaveTokenFile();
    procedure SaveCoinFile();
    procedure SaveSeedFile();

    procedure LoadCoinFile();
    procedure LoadTokenFile();
    procedure LoadSeedFile();

    procedure clearArrays();

  end;

implementation

uses
  misc;

constructor Account.Create(_name: AnsiString);
begin
  name := _name;

  if not DirectoryExists(TPath.Combine(TPath.GetDocumentsPath, name)) then
    CreateDir(TPath.Combine(TPath.GetDocumentsPath, name));

  DirPath := TPath.Combine(TPath.GetDocumentsPath, name);

  CoinFilePath := TPath.Combine(TPath.GetDocumentsPath, name);
  CoinFilePath := TPath.Combine(CoinFilePath, 'hodler.coin.dat');

  TokenFilePath := TPath.Combine(TPath.GetDocumentsPath, name);
  TokenFilePath := TPath.Combine(TokenFilePath, 'hodler.erc20.dat');

  SeedFilePath := TPath.Combine(TPath.GetDocumentsPath, name);
  SeedFilePath := TPath.Combine(SeedFilePath, 'hodler.masterseed.dat');

  SetLength(Paths, 3);
  Paths[0] := CoinFilePath;
  Paths[1] := TokenFilePath;
  Paths[2] := SeedFilePath;

  SetLength(myCoins, 0);
  SetLength(myTokens, 0);

end;

destructor Account.Destroy();
begin
  clearArrays();
end;

procedure Account.SaveSeedFile();
var
  ts: TStringLIst;
begin
  ts := TStringLIst.Create();

  ts.Add(inttoStr(TCAIterations));
  ts.Add(EncryptedMasterSeed);
  ts.Add(booltoStr(userSaveSeed));
  ts.Add(booltoStr(privTCA));
  ts.SaveToFile(SeedFilePath);
  ts.Free;

end;

procedure Account.LoadSeedFile();
var
  ts: TStringLIst;
begin
  ts := TStringLIst.Create();

  ts.LoadFromFile(SeedFilePath);

  TCAIterations := strtoInt(ts[0]);
  EncryptedMasterSeed := ts[1];
  userSaveSeed := strToBool(ts[2]);
  if ts.Count>3 then
  privTCA := strToBoolDef(ts[3],false) else
  privTCA := false;
  ts.Free;

end;

function Account.countWalletBy(id: Integer): Integer;
var
  ts: TStringLIst;
  i, j: Integer;
  wd: TWalletInfo;
begin

  result := 0;

  for wd in myCoins do
    if wd.coin = id then
      result := result + 1;

end;

procedure Account.clearArrays();
var
  T: Token;
  wd: TWalletInfo;
begin

  for T in myTokens do
    if T <> nil then
      T.Free;

  SetLength(myTokens, 0);

  for wd in myCoins do
    if wd <> nil then
      wd.Free;

  SetLength(myCoins, 0);

end;

procedure Account.AddCoin(wd: TWalletInfo);
begin
  SetLength(myCoins, length(myCoins) + 1);
  myCoins[length(myCoins) - 1] := wd;
  SaveCoinFile();
end;

procedure Account.AddToken(T: Token);
begin
  SetLength(myTokens, length(myTokens) + 1);
  myTokens[length(myTokens) - 1] := T;
  SaveTokenFile();
end;

procedure Account.LoadFiles();
var
  ts: TStringLIst;
  i: Integer;
  T: Token;
begin

  clearArrays();

  LoadSeedFile();

  LoadCoinFile();
  LoadTokenFile();

end;

procedure Account.LoadCoinFile();
var
  ts: TStringLIst;
  i: Integer;
  wd: TWalletInfo;
begin

  if not fileExists(CoinFilePath) then
    exit;

  ts := TStringLIst.Create();

  ts.LoadFromFile(CoinFilePath);
  i := 0;

  while i < ts.Count - 1 do
  begin
    wd := TWalletInfo.Create(strtoInt(ts.Strings[i]),
      strtoInt(ts.Strings[i + 1]), strtoInt(ts.Strings[i + 2]),
      ts.Strings[i + 3], ts.Strings[i + 4], strtoInt(ts[i + 5]));

    wd.orderInWallet := strtoInt(ts[i + 6]);
    wd.pub := ts[i + 7];
    wd.EncryptedPrivKey := ts[i + 8];
    wd.isCompressed := strToBool(ts[i + 9]);

    wd.wid := length(myCoins);

    AddCoin(wd);

    i := i + 10;
  end;

  ts.Free;

end;

procedure Account.LoadTokenFile();
var
  ts: TStringLIst;
  i: Integer;
  T: Token;
begin
  if fileExists(TokenFilePath) then
  begin

    ts := TStringLIst.Create();

    ts.LoadFromFile(TokenFilePath);
    // clear myTokens

    i := 0;
    while i < ts.Count do
    begin

      // create token from single line
      T := Token.fromString(ts[i]);
      inc(i);

      T.idInWallet := length(myTokens) + 10000;

      // histSize := strtoInt(ts[i]);
      inc(i);

      AddToken(T);
      // add new token to array myTokens

    end;

    ts.Free;

  end;
end;

procedure Account.SaveFiles();
var
  ts: TStringLIst;
  i: Integer;
  fileData: AnsiString;
begin

  SaveSeedFile();

  SaveCoinFile();
  SaveTokenFile();

end;

procedure Account.SaveTokenFile();
var
  ts: TStringLIst;
  i: Integer;
  fileData: AnsiString;
begin
  ts := TStringLIst.Create();

  // convert all tokens to string and save in TStringList
  for i := 0 to length(myTokens) - 1 do
  begin
    if myTokens[i].deleted = false then
    begin
      myTokens[i].lastBlock := getHighestBlockNumber(myTokens[i]);
      fileData := myTokens[i].ToString() + ' ';

      ts.Add(fileData);
      ts.Add(inttoStr(0));
    end;

  end;

  ts.SaveToFile(TokenFilePath);

  ts.Free;
end;

procedure Account.SaveCoinFile();
var
  ts: TStringLIst;
  data: TWalletInfo;
begin

  ts := TStringLIst.Create();

  for data in myCoins do
  begin
if data.deleted then
      Continue;
    ts.Add(inttoStr(data.coin)); // Coin ID
    ts.Add(inttoStr(data.x)); // X
    ts.Add(inttoStr(data.y)); // Y
    ts.Add(data.addr);
    ts.Add(data.description);
    ts.Add(inttoStr(data.creationTime));
    ts.Add(inttoStr(data.orderInWallet));
    ts.Add(data.pub);
    ts.Add(data.EncryptedPrivKey);
    ts.Add(booltoStr(data.isCompressed));

  end;

  ts.SaveToFile(CoinFilePath);

  ts.Free;

end;

end.
