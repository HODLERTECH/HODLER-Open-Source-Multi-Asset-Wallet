unit AccountData;

interface

uses tokenData, WalletStructureData, cryptoCurrencyData, System.IOUtils,
  Sysutils, Classes , FMX.Dialogs;

type
  Account = class
    name: AnsiString;
    myCoins: array of TWalletInfo;
    myTokens: array of Token;
    TCAIterations : Integer;
    EncryptedMasterSeed : AnsiString;
    userSaveSeed : boolean;

    DirPath : AnsiString;
    CoinFilePath: AnsiString;
    TokenFilePath: AnsiString;
    SeedFilePath : AnsiString;
    Paths : Array of AnsiString;

    constructor Create(_name: AnsiString);
    destructor Destroy(); override ;

    procedure LoadFiles();
    procedure SaveFiles();

    procedure AddCoin( wd : TWalletInfo);
    procedure AddToken( T : Token );
    function countWalletBy(id: integer): integer;

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

  SetLength(Paths , 3);
  paths[0] := CoinFilePath;
  Paths[1] := TokenFilePath;
  paths[2] := SeedFilePath;

  SetLength(myCoins , 0);
  SetLength(myTokens, 0);


end;

destructor Account.Destroy();
begin
   clearArrays();
end;


procedure Account.SaveSeedFile();
var
  ts : TStringLIst;
begin
  ts := TStringList.Create();

  ts.Add( inttoStr(TCAIterations) );
  ts.Add( EncryptedMasterSeed );
  ts.Add( booltoStr( userSaveSeed ) );

  ts.SaveToFile( SeedFilePath );
  ts.Free;

end;

procedure Account.LoadSeedFile();
var
  ts : TStringLIst;
begin
  ts := TStringList.Create();

  ts.LoadFromFile( seedFilePath );

  TCAIterations := strtoInt( ts[0] );
  EncryptedMasterSeed := ts[1];
  userSaveSeed := strToBool( ts[2] );

  ts.Free;

end;

function Account.countWalletBy(id: integer): integer;
var
  ts: TStringList;
  i, j: integer;
  wd: TWalletInfo;
begin

  result := 0;

  for wd in myCoins do
    if wd.coin = id then
      result := result + 1;

end;


procedure Account.clearArrays();
var
  T : Token;
  wd : TWalletInfo;
begin

  for T in myTokens do
    if t <> nil then
      t.Free;

  SetLength( myTokens , 0 );

  for Wd in MyCoins do
    if wd <> nil then
      wd.Free;

  SetLength( myCoins , 0 );

end;

procedure Account.AddCoin( wd : TWalletInfo);
begin
  SetLength(myCoins , length(myCoins) +1);
  myCoins[ length(mycoins) -1 ] := wd;
  SaveCoinFile();
end;

procedure Account.AddToken( T : Token );
begin
  SetLength( myTokens , Length(myTokens) +1);
  myTokens [ length(myTokens) -1 ] := T;
  SaveTokenFile();
end;

procedure Account.LoadFiles();
var
  ts: TStringList;
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
  ts: TStringList;
  i: Integer;
  wd: TWalletInfo;
begin

  if not fileExists( CoinFilePath ) then
    exit;

  ts := TStringList.Create();

  ts.LoadFromFile( CoinFilePath );
  i := 0;

  while i < ts.Count-1 do
  begin
    wd := TWalletInfo.Create(strtoInt(ts.Strings[i]),
      strtoInt(ts.Strings[i + 1]), strtoInt(ts.Strings[i + 2]),
      ts.Strings[i + 3], ts.Strings[i + 4], strtoInt(ts[i + 5]));

    wd.orderInWallet := strtoInt(ts[i + 6]);
    wd.pub := ts[i + 7];
    wd.EncryptedPrivKey := ts[i+8];
    wd.isCompressed := strToBool( ts[i+9] );

    wd.wid := length(myCoins);

    AddCoin( wd );

    i := i + 10;
  end;

  ts.Free;

end;

procedure Account.LoadTokenFile();
var
  ts: TStringList;
  i: Integer;
  T: Token;
begin
  if FileExists(TokenFilePath) then
  begin

    ts := TStringList.Create();

    ts.LoadFromFile(TokenFilePath);
    // clear myTokens

    i := 0;
    while i < ts.Count do
    begin

      // create token from single line
      T := Token.fromString(ts[i]);
      inc(i);

      T.idInWallet := Length(myTokens) + 10000;

      // histSize := strtoInt(ts[i]);
      inc(i);

      AddToken( T );
      // add new token to array myTokens

    end;

    ts.Free;

  end;
end;

procedure Account.SaveFiles();
var
  ts: TStringList;
  i: Integer;
  fileData: AnsiString;
begin

  SaveSeedFile();

  SaveCoinFile();
  SaveTokenFile();

end;

procedure Account.SaveTokenFile();
var
  ts: TStringList;
  i: Integer;
  fileData: AnsiString;
begin
  ts := TStringList.Create();

  // convert all tokens to string and save in TStringList
  for i := 0 to Length(myTokens) - 1 do
  begin
    if myTokens[i].deleted = false then
    begin
      myTokens[i].lastBlock := getHighestBlockNumber(myTokens[i]);
      fileData := myTokens[i].ToString() + ' ';

      ts.Add(fileData);
      ts.Add(inttostr(0));
    end;

  end;

  ts.SaveToFile(TokenFilePath);

  ts.Free;
end;

procedure Account.SaveCoinFile();
var
  ts: TStringList;
  data: TWalletInfo;
begin

  ts := TStringList.Create();

  for data in myCoins do
  begin

    ts.Add(inttostr(data.coin)); // Coin ID
    ts.Add(inttostr(data.x)); // X
    ts.Add(inttostr(data.y)); // Y
    ts.Add(data.addr);
    ts.Add(data.description);
    ts.Add(inttostr(data.creationTime));
    ts.Add(inttostr(data.orderInWallet));
    ts.Add(data.pub);
    ts.Add(data.EncryptedPrivKey);
    ts.Add(boolToStr(data.isCompressed));

  end;

  ts.SaveToFile(CoinFilePath);

  ts.Free;

end;

end.
