unit AccountData;

interface

uses tokenData, WalletStructureData, cryptoCurrencyData, System.IOUtils,
  Sysutils, Classes, FMX.Dialogs, Json, Velthuis.BigIntegers , math;

procedure loadCryptoCurrencyJSONData(data: TJSONValue; cc: cryptoCurrency);
function getCryptoCurrencyJsonData(cc: cryptoCurrency): TJSONObject;

type
  TBalances = record
    confirmed: BigInteger;
    unconfirmed: BigInteger;
  end;

type
  Account = class
    name: AnsiString;
    myCoins: array of TWalletInfo;
    myTokens: array of Token;
    TCAIterations: Integer;
    EncryptedMasterSeed: AnsiString;
    userSaveSeed: boolean;
    hideEmpties:Boolean;
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
    function getWalletWithX(X, id: Integer): TCryptoCurrencyArray;
    function getSibling(wi: TWalletInfo; Y: Integer): TWalletInfo;
    function aggregateBalances(wi: TWalletInfo): TBalances;
    function aggregateUTXO(wi: TWalletInfo): TUTXOS;
    function aggregateFiats(wi: TWalletInfo): double;
    function aggregateConfirmedFiats(wi: TWalletInfo): double;
    function aggregateUnconfirmedFiats(wi: TWalletInfo): double;
  private
    procedure SaveTokenFile();
    procedure SaveCoinFile();
    procedure SaveSeedFile();

    procedure LoadCoinFile();
    procedure LoadTokenFile();
    procedure LoadSeedFile();

    procedure clearArrays();
    procedure AddCoinWithoutSave(wd: TWalletInfo);
    procedure AddTokenWithoutSave(T: Token);

  end;

implementation

uses
  misc,uHome;


function Account.aggregateConfirmedFiats(wi: TWalletInfo): double;
var
  twi: cryptoCurrency;
begin

  if wi.X = -1 then
    exit(wi.getConfirmedFiat());

  result := 0.0;
  for twi in getWalletWithX(wi.X, TWalletInfo(wi).coin) do
    result := result + TWalletInfo(twi).getConfirmedFiat;

end;

function Account.aggregateUnconfirmedFiats(wi: TWalletInfo): double;
var
  twi: cryptoCurrency;
begin

  if wi.X = -1 then
    exit(wi.getUnconfirmedFiat());

  result := 0.0;
  for twi in getWalletWithX(wi.X, TWalletInfo(wi).coin) do
  begin
    if TWalletInfo(twi).unconfirmed > 0 then
      result := result + TWalletInfo(twi).getUnconfirmedFiat;
  end;

end;

function Account.aggregateFiats(wi: TWalletInfo): double;
var
  twi: cryptoCurrency;
begin

  if wi.X = -1 then
    exit(wi.getfiat());

  result := 0.0;
  for twi in getWalletWithX(wi.X, TWalletInfo(wi).coin) do
    result := result + max( 0 , TWalletInfo(twi).getfiat);

end;

function Account.aggregateUTXO(wi: TWalletInfo): TUTXOS;
var
  twi: cryptoCurrency;
  utxo: TBitcoinOutput;
  i: Integer;
begin
  SetLength(result, 0);

  if wi.X = -1 then
  begin

    for i := 0 to Length(TWalletInfo(wi).utxo) - 1 do
    begin
      SetLength(result, Length(result) + 1);
      result[high(result)] := TWalletInfo(wi).utxo[i];
    end;
    exit();

  end;

  for twi in getWalletWithX(wi.X, TWalletInfo(wi).coin) do
  begin
    for i := 0 to Length(TWalletInfo(twi).utxo) - 1 do
    begin
      SetLength(result, Length(result) + 1);
      result[high(result)] := TWalletInfo(twi).utxo[i];
    end;
  end;

end;

function Account.aggregateBalances(wi: TWalletInfo): TBalances;
var
  twi: cryptoCurrency;
  twis: TCryptoCurrencyArray;
  i: Integer;
begin

  if wi.X = -1 then
  begin

    result.confirmed := wi.confirmed;
    result.unconfirmed := wi.unconfirmed;

    exit();
  end;

  result.confirmed := BigInteger.Zero;
  result.unconfirmed := BigInteger.Zero;
  twis := getWalletWithX(wi.X, TWalletInfo(wi).coin);
  for i := 0 to Length(twis) - 1 do
  begin
    twi := twis[i];
    if not assigned(twi) then
      continue;

    try

      result.confirmed := result.confirmed + twi.confirmed;
      if twi.unconfirmed > 0 then
        result.unconfirmed := result.unconfirmed + twi.unconfirmed;
    except

    end;
  end;

end;

function Account.getSibling(wi: TWalletInfo; Y: Integer): TWalletInfo;
var
  i: Integer;
  pub: AnsiString;
  p: AnsiString;

begin
  result := nil;
  if (wi.X = -1) and (wi.Y = -1) then
  begin
    result := wi;
    exit;

  end;
  for i := 0 to Length(myCoins) - 1 do
  begin

    if (myCoins[i].coin = wi.coin) and (myCoins[i].X = wi.X) and
      (myCoins[i].Y = Y) then
    begin
      result := myCoins[i];
      break;
    end;

  end;

end;

function Account.getWalletWithX(X, id: Integer): TCryptoCurrencyArray;
var
  i: Integer;
begin
  SetLength(result, 0);

  for i := 0 to Length(myCoins) - 1 do
  begin

    if (myCoins[i].coin = id) and (myCoins[i].X = X) then
    begin
      SetLength(result, Length(result) + 1);
      result[Length(result) - 1] := myCoins[i];
    end;

  end;

end;

constructor Account.Create(_name: AnsiString);
begin
  name := _name;

  DirPath := TPath.Combine(HOME_PATH, name);

  if not DirectoryExists(DirPath) then
    CreateDir(DirPath);

  // CoinFilePath := TPath.Combine(HOME_PATH, name);
  CoinFilePath := TPath.Combine(DirPath, 'hodler.coin.dat');

  // TokenFilePath := TPath.Combine(HOME_PATH, name);
  TokenFilePath := TPath.Combine(DirPath, 'hodler.erc20.dat');

  // SeedFilePath := TPath.Combine(HOME_PATH, name);
  SeedFilePath := TPath.Combine(DirPath, 'hodler.masterseed.dat');

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
  ts.Add(booltoStr(frmHome.HideZeroWalletsCheckBox.isChecked));
  ts.SaveToFile(SeedFilePath);
  ts.Free;

end;

procedure Account.LoadSeedFile();
var
  ts: TStringLIst;
begin
  ts := TStringLIst.Create();

  ts.LoadFromFile(SeedFilePath);

  TCAIterations := strtoInt(ts.Strings[0]);
  EncryptedMasterSeed := ts.Strings[1];
  userSaveSeed := strToBool(ts.Strings[2]);
  if ts.Count > 4 then  begin
    privTCA := strToBoolDef(ts.Strings[3], false) ;
    hideEmpties := strToBoolDef(ts.Strings[4], false)
  end
  else  begin
    privTCA := false;
    hideEmpties := false;
  end;
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
  SetLength(myCoins, Length(myCoins) + 1);
  myCoins[Length(myCoins) - 1] := wd;
  SaveCoinFile();
end;

procedure Account.AddToken(T: Token);
begin
  SetLength(myTokens, Length(myTokens) + 1);
  myTokens[Length(myTokens) - 1] := T;
  SaveTokenFile();
end;

procedure Account.AddCoinWithoutSave(wd: TWalletInfo);
begin
  SetLength(myCoins, Length(myCoins) + 1);
  myCoins[Length(myCoins) - 1] := wd;
end;

procedure Account.AddTokenWithoutSave(T: Token);
begin
  SetLength(myTokens, Length(myTokens) + 1);
  myTokens[Length(myTokens) - 1] := T;
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
  JsonArray: TJsonArray;
  coinJson: TJSONValue;
  dataJson: TJSONObject;
  ccData: TJSONObject;

  innerID, X, Y, address, description, creationTime, panelYPosition, publicKey,
    EncryptedPrivateKey, isCompressed: AnsiString;
  s: string;
begin

  if not fileExists(CoinFilePath) then
    exit;

  ts := TStringLIst.Create();

  ts.LoadFromFile(CoinFilePath);

  if ts.Text[low(ts.Text)] = '[' then
  begin
    s := ts.Text;
    JsonArray := TJsonArray(TJSONObject.ParseJSONValue(s));

    for coinJson in JsonArray do
    begin

      dataJson := coinJson.GetValue<TJSONObject>('data');
      // showmessage(dataJson.ToString);

      innerID := dataJson.GetValue<string>('innerID');
      X := dataJson.GetValue<string>('X');
      Y := dataJson.GetValue<string>('Y');
      address := dataJson.GetValue<string>('address');
      description := dataJson.GetValue<string>('description');
      creationTime := dataJson.GetValue<string>('creationTime');
      panelYPosition := dataJson.GetValue<string>('panelYPosition');

      publicKey := dataJson.GetValue<string>('publicKey');
      EncryptedPrivateKey := dataJson.GetValue<string>('EncryptedPrivateKey');

      isCompressed := dataJson.GetValue<string>('isCompressed');
      // confirmed := dataJson.GetValue<string>('confirmed');

      wd := TWalletInfo.Create(strtoInt(innerID), strtoInt(X), strtoInt(Y),
        address, description, strtoInt(creationTime));

      wd.pub := publicKey;
      wd.orderInWallet := strtoInt(panelYPosition);
      wd.EncryptedPrivKey := EncryptedPrivateKey;
      wd.isCompressed := strToBool(isCompressed);

      wd.wid := Length(myCoins);

      // coinJson.TryGetValue<TJsonObject>('CryptoCurrencyData', ccData);

      if coinJson.TryGetValue<TJSONObject>('CryptoCurrencyData', ccData) then
        loadCryptoCurrencyJSONData(ccData, wd);

      AddCoinWithoutSave(wd);

    end;

  end
  else
  begin
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

      wd.wid := Length(myCoins);

      AddCoinWithoutSave(wd);

      i := i + 10;
    end;

  end;






  // ts := TStringLIst.Create();

  // ts.LoadFromFile(CoinFilePath);

  ts.Free;

end;

procedure Account.LoadTokenFile();
var
  ts: TStringLIst;
  i: Integer;
  T: Token;
  JsonArray: TJsonArray;
  tokenJson: TJSONValue;
  tempJson: TJSONValue;
begin
  if fileExists(TokenFilePath) then
  begin

    ts := TStringLIst.Create();

    ts.LoadFromFile(TokenFilePath);

    if ts.Text[low(ts.Text)] = '[' then
    begin

      JsonArray := TJsonArray(TJSONObject.ParseJSONValue(ts.Text));

      for tokenJson in JsonArray do
      begin

        tokenJson.TryGetValue<TJSONValue>('TokenData', tempJson);

        T := Token.fromJson(tempJson);

        if tokenJson.TryGetValue<TJSONValue>('CryptoCurrencyData', tempJson)
        then
        begin

          loadCryptoCurrencyJSONData(tempJson, T);

        end;

        if (T.id < 10000) or (Token.availableToken[T.id - 10000].address <> '')
        then // if token.address = ''   token is no longer exist
          AddToken(T);

        {
          tokenJson.AddPair('name' , myTokens[i].name );
          tokenJson.AddPair('TokenData' , myTokens[i].toJson );
          TokenJson.AddPair('CryptoCurrencyData' , getCryptoCurrencyJsonData( myTokens[i] ) ); }

      end;

    end
    else
    begin

      i := 0;
      while i < ts.Count do
      begin

        // create token from single line
        T := Token.fromString(ts[i]);
        inc(i);

        T.idInWallet := Length(myTokens) + 10000;

        // histSize := strtoInt(ts[i]);
        inc(i);

        AddToken(T);
        // add new token to array myTokens

      end;

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
  TokenArray: TJsonArray;
  tokenJson: TJSONObject;

begin
  ts := TStringLIst.Create();

  TokenArray := TJsonArray.Create();

  for i := 0 to Length(myTokens) - 1 do
  begin
    if myTokens[i].deleted = false then
    begin

      tokenJson := TJSONObject.Create();
      tokenJson.AddPair('name', myTokens[i].name);
      tokenJson.AddPair('TokenData', myTokens[i].toJson);
      tokenJson.AddPair('CryptoCurrencyData',
        getCryptoCurrencyJsonData(myTokens[i]));

      TokenArray.Add(tokenJson);

    end;

  end;

  ts.Text := TokenArray.ToString;

  {
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

    end; }

  ts.SaveToFile(TokenFilePath);

  ts.Free;
end;

procedure Account.SaveCoinFile();
var
  i: Integer;
  ts: TStringLIst;
  data: TWalletInfo;
  JsonArray: TJsonArray;
  coinJson: TJSONObject;
  dataJson: TJSONObject;
begin

  JsonArray := TJsonArray.Create();

  for data in myCoins do
  begin
    if data.deleted then
      continue;

    dataJson := TJSONObject.Create();
    dataJson.AddPair('innerID', inttoStr(data.coin));
    dataJson.AddPair('X', inttoStr(data.X));
    dataJson.AddPair('Y', inttoStr(data.Y));
    dataJson.AddPair('address', data.addr);
    dataJson.AddPair('description', data.description);
    dataJson.AddPair('creationTime', inttoStr(data.creationTime));
    dataJson.AddPair('panelYPosition', inttoStr(data.orderInWallet));
    dataJson.AddPair('publicKey', data.pub);
    dataJson.AddPair('EncryptedPrivateKey', data.EncryptedPrivKey);
    dataJson.AddPair('isCompressed', booltoStr(data.isCompressed));

    coinJson := TJSONObject.Create();
    coinJson.AddPair('name', data.name);
    coinJson.AddPair('data', dataJson);
    coinJson.AddPair('CryptoCurrencyData', getCryptoCurrencyJsonData(data));

    JsonArray.AddElement(coinJson);

  end;

  ts := TStringLIst.Create();
  ts.Text := JsonArray.ToString;
  ts.SaveToFile(CoinFilePath);

  ts.Free;
  JsonArray.Free;
  { In JSON, the parent object owns any of the values it contains, unless the Owned property is set to False.
    In this case, the destruction of a JSON object skips each member that has the flag set to False.
    This feature allows the combination of various objects into bigger objects while retaining ownership.
    By default, the property is True, meaning all contained instances are owned by their parent. }
end;

procedure loadCryptoCurrencyJSONData(data: TJSONValue; cc: cryptoCurrency);
var
  JsonObject: TJSONObject;
  dataJson: TJSONObject;
  JsonHistArray: TJsonArray;

  HistArrayIt: TJSONValue;

  confirmed, unconfirmed, rate: AnsiString;
  i: Integer;
begin

  if data.TryGetValue<AnsiString>('confirmed', confirmed) then
  begin
    BigInteger.TryParse(confirmed, 10, cc.confirmed);
  end;
  if data.TryGetValue<AnsiString>('unconfirmed', unconfirmed) then
  begin
    BigInteger.TryParse(unconfirmed, 10, cc.unconfirmed);
  end;
  if data.TryGetValue<AnsiString>('USDPrice', rate) then
  begin
    cc.rate := StrToFloatDef(rate, 0);
  end;
  if data.TryGetValue<TJsonArray>('history', JsonHistArray) then
  begin

    SetLength(cc.history, JsonHistArray.Count);
    i := 0;
    for HistArrayIt in JsonHistArray do
    begin
      cc.history[i].fromJsonValue(HistArrayIt);

      inc(i);
    end;

  end;

end;

function getCryptoCurrencyJsonData(cc: cryptoCurrency): TJSONObject;
var
  JsonObject: TJSONObject;
  dataJson: TJSONObject;
  JsonHistArray: TJsonArray;
  i: Integer;
begin

  dataJson := TJSONObject.Create();

  dataJson.AddPair('confirmed', cc.confirmed.ToString);
  dataJson.AddPair('unconfirmed', cc.unconfirmed.ToString);
  dataJson.AddPair('USDPrice', floattoStr(cc.rate));

  JsonHistArray := TJsonArray.Create();

  for i := 0 to Length(cc.history) - 1 do
  begin
    JsonHistArray.Add(TJSONObject(cc.history[i].toJsonValue()));
  end;

  dataJson.AddPair('history', JsonHistArray);

  result := dataJson;

end;

end.
