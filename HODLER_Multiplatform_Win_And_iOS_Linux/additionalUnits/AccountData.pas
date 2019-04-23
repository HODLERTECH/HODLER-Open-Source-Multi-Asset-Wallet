unit AccountData;

interface

uses tokenData, WalletStructureData, cryptoCurrencyData, System.IOUtils,
  FMX.Graphics, System.types, FMX.Types,  FMX.Controls, FMX.StdCtrls,
  Sysutils, Classes, FMX.Dialogs, Json, Velthuis.BigIntegers, math,
  System.Generics.Collections, System.SyncObjs, THreadKindergartenData ;

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
    hideEmpties: boolean;
    privTCA: boolean;

    DirPath: AnsiString;
    CoinFilePath: AnsiString;
    TokenFilePath: AnsiString;
    SeedFilePath: AnsiString;
    DescriptionFilePath: AnsiString;

    BigQRImagePath: AnsiString;
    SmallQRImagePath: AnsiString;

    Paths: Array of AnsiString;
    firstSync : boolean;

    SynchronizeThreadGuardian: ThreadKindergarten;

    DescriptionDict: TObjectDictionary<TPair<Integer, Integer>, AnsiString>;

    constructor Create(_name: AnsiString);
    destructor Destroy(); override;

    procedure GenerateEQRFiles();

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
    function getSpendable(wi: TWalletInfo): BigInteger;

    function getDescription(id, X: Integer): AnsiString;
    procedure changeDescription(id, X: Integer; newDesc: AnsiString);

    function getDecryptedMasterSeed(Password: String): AnsiString;

    function TokenExistInETH(TokenID: Integer; ETHAddress: AnsiString): boolean;

    procedure wipeAccount();

    procedure AsyncSynchronize();
    function keepSync(): boolean;

    procedure lockSynchronize();
    procedure unlockSynchronize();
    function isOurAddress(adr: string; coinid: Integer): boolean;
    procedure verifyKeypool();
    procedure asyncVerifyKeyPool();
    procedure refreshGUI();



  private

  var

    semaphore , VerifyKeypoolSemaphore:TLightweightSemaphore;
    mutex : TSemaphore;
    synchronizeThread: TThread;
    mutexTokenFile, mutexCoinFile, mutexSeedFile, mutexDescriptionFile
      : TSemaphore;

    procedure Synchronize();
    procedure SaveTokenFile();
    procedure SaveCoinFile();
    procedure SaveSeedFile();

    procedure SaveDescriptionFile();
    procedure LoadDescriptionFile();

    procedure LoadCoinFile();
    procedure LoadTokenFile();
    procedure LoadSeedFile();

    procedure clearArrays();
    procedure AddCoinWithoutSave(wd: TWalletInfo);
    procedure AddTokenWithoutSave(T: Token);

    procedure changeDescriptionwithoutSave(id, X: Integer; newDesc: AnsiString);
  end;

implementation

uses
  misc, uHome, coinData, nano, languages,SyncThr, Bitcoin , walletViewRelated , CurrencyConverter;

procedure Account.refreshGUI();
begin
  if self = currentAccount then
  begin
  frmhome.refreshGlobalImage.Start;
  refreshGlobalFiat();
    TThread.Synchronize(TThread.CurrentThread,
      procedure
      begin
        repaintWalletList;
      end);

    TThread.Synchronize(TThread.CurrentThread,
      procedure
      begin
        if frmhome.PageControl.ActiveTab = frmhome.walletView then
        begin
          try
            reloadWalletView;
          except
            on E: Exception do
          end;

        end;
      end);

    TThread.Synchronize(TThread.CurrentThread,
      procedure
      begin

        TLabel(frmHome.FindComponent('globalBalance')).text :=
          floatToStrF(frmhome.currencyConverter.calculate(globalFiat), ffFixed, 9, 2);
        TLabel(frmHome.FindComponent('globalCurrency')).text := '         ' +
          frmhome.currencyConverter.symbol;



        hideEmptyWallets(nil);

      end);
    frmhome.refreshGlobalImage.Stop;
  end;
end;

procedure Account.asyncVerifyKeyPool();
begin

  SynchronizeThreadGuardian.CreateAnonymousThread(procedure
  begin

    verifyKeypool();

  end).start();

end;

procedure Account.verifyKeypool();
var
  i: Integer;
  licz: Integer;
  batched: string;

begin

  for i in [0, 1, 2, 3, 4, 5, 6, 7] do
  begin
    if TThread.CurrentThread.CheckTerminated then
      exit();
    mutex.Acquire();

    SynchronizeThreadGuardian.CreateAnonymousThread(
      procedure
      var
        id: Integer;
        wi: TWalletInfo;
        wd: TObject;
        url, s: string;

      begin

        id := i;
        mutex.Release();

        VerifyKeypoolSemaphore.WaitFor();
        try
          s := keypoolIsUsed(self,id);
          url := HODLER_URL + '/batchSync0.3.2.php?keypool=true&coin=' +
            availablecoin[id].name;
          if TThread.CurrentThread.CheckTerminated then
            exit();
          parseSync(self , postDataOverHTTP(url, s, false, True), True);

        except
          on E: Exception do
          begin

          end;
        end;
        VerifyKeypoolSemaphore.Release();

      end).Start();
    mutex.Acquire();
    mutex.Release();

  end;

  while VerifyKeypoolSemaphore.CurrentCount <> 8 do
  begin
    if TThread.CurrentThread.CheckTerminated then
      exit();
    sleep(50);
  end;

  SaveFiles();

end;

function Account.isOurAddress(adr: string; coinid: Integer): boolean;
var
  twi: TWalletInfo;
var
  segwit, cash, compatible, legacy: AnsiString;
  pub: AnsiString;
begin

  result := false;

  adr := lowercase(StringReplace(adr, 'bitcoincash:', '', [rfReplaceAll]));

  for twi in myCoins do
  begin

    if twi.coin <> coinid then
      continue;

    if TThread.CurrentThread.CheckTerminated then
    begin
      exit();
    end;
    pub := twi.pub;

    segwit := lowercase(generatep2wpkh(pub, availablecoin[coinid].hrp));
    compatible := lowercase(generatep2sh(pub, availablecoin[coinid].p2sh));
    legacy := generatep2pkh(pub, availablecoin[coinid].p2pk);

    cash := lowercase(bitcoinCashAddressToCashAddress(legacy, false));
    legacy := lowercase(legacy);
    cash := StringReplace(cash, 'bitcoincash:', '', [rfReplaceAll]);
    if ((adr) = segwit) or (adr = compatible) or (adr = legacy) or (adr = cash)
    then
      exit(True);

  end;
end;

procedure  Account.lockSynchronize();
begin

end;

procedure  Account.unlockSynchronize();
begin

end;

function Account.keepSync(): boolean;
begin

  result := (synchronizeThread = nil) or (not synchronizeThread.finished);

end;

procedure Account.AsyncSynchronize();
begin

  if (synchronizeThread <> nil) and (synchronizeThread.finished) then
  begin

    synchronizeThread.Free;
    synchronizeThread := nil;

  end;

  if synchronizeThread = nil then
  begin

    synchronizeThread := tthread.CreateAnonymousThread( self.synchronize );
    synchronizeThread.FreeOnTerminate := false;
    synchronizeThread.start();
    //synchronizeThread.
  end;



end;

procedure Account.Synchronize();
var
  i: Integer;
  licz: Integer;
  batched: string;
begin

  {TThread.Synchronize(nil , procedure
    begin
        showmessage('start');
          end);}


  { TThread.Synchronize(TThread.CurrentThread,
    procedure
    begin
    frmHome.DashBrdProgressBar.Max := Length(CurrentAccount.myCoins) +
    Length(CurrentAccount.myTokens);
    frmHome.DashBrdProgressBar.value := 0;
    end); }



  for i in [0, 1, 2, 3, 4, 5, 6, 7] do
  begin
    //if TThread.CurrentThread.CheckTerminated then
    //  exit();
    mutex.Acquire();

    SynchronizeThreadGuardian.CreateAnonymousThread(
      procedure
      var
        id: Integer;
        wi: TWalletInfo;
        wd: TObject;
        url, s: string;
        temp: String;

      begin

        id := i;
        mutex.Release();

        semaphore.WaitFor();
        try
          if id in [4, 8] then
          begin

            for wi in myCoins do
            begin

              //if TThread.CurrentThread.CheckTerminated then
              //  exit();

              if wi.coin in [4, 8] then
                SynchronizeCryptoCurrency(self ,wi);
            end;

          end
          else
          begin
            s := batchSync(self ,id);

            url := HODLER_URL + '/batchSync0.3.2.php?coin=' +
              availablecoin[id].name;

            temp := postDataOverHTTP(url, s, Self.firstSync, True);
            //if TThread.CurrentThread.CheckTerminated then
            //  exit();
            parseSync(self , temp);
          end;
         // if TThread.CurrentThread.CheckTerminated then
          //  exit();

         { TThread.CurrentThread.Synchronize(nil,
            procedure
            begin

              updateBalanceLabels(id);
            end);  }
        except
          on E: Exception do
          begin

          end;
        end;
        semaphore.Release();

        { TThread.CurrentThread.Synchronize(nil,
          procedure
          begin
          frmHome.DashBrdProgressBar.value :=
          frmHome.RefreshProgressBar.value + 1;
          end); }

      end).Start();

    mutex.Acquire();
    mutex.Release();

  end;
  for i := 0 to Length(myTokens) - 1 do
  begin
    //if TThread.CurrentThread.CheckTerminated then
    //  exit();
    mutex.Acquire();

    SynchronizeThreadGuardian.CreateAnonymousThread(
      procedure
      var
        id: Integer;
      begin

        id := i;
        mutex.Release();

        semaphore.WaitFor();
        try
          //if TThread.CurrentThread.CheckTerminated then
          //  exit();
          SynchronizeCryptoCurrency(self ,myTokens[id]);
        except
          on E: Exception do
          begin
          end;
        end;
        semaphore.Release();

        { TThread.CurrentThread.Synchronize(nil,
          procedure
          begin
          frmHome.DashBrdProgressBar.value :=
          frmHome.RefreshProgressBar.value + 1;
          end); }

      end).Start();
    //if TThread.CurrentThread.CheckTerminated then
    // exit();
    mutex.Acquire();
    mutex.Release();

  end;

  while (semaphore <> nil) and (semaphore.CurrentCount <> 8) do
  begin
    //if TThread.CurrentThread.CheckTerminated then
    //  exit();
    sleep(50);
  end;
  { tthread.Synchronize(nil , procedure
    begin
    showmessage( floatToStr( globalLoadCacheTime ) );
    end); }
  Self.firstSync := false;
  SaveFiles();

  refreshGUI();
  {TThread.Synchronize(nil , procedure
    begin
        showmessage('stop');
          end);}

end;

function Account.TokenExistInETH(TokenID: Integer;
ETHAddress: AnsiString): boolean;
var
  i: Integer;
begin
  result := false;
  for i := 0 to Length(myTokens) - 1 do
  begin

    if myTokens[i].addr = ETHAddress then
    begin

      if myTokens[i].id = TokenID then
        exit(True);

    end;

  end;

end;

function Account.getDecryptedMasterSeed(Password: String): AnsiString;
var
  MasterSeed, tced: AnsiString;
begin

  tced := TCA(Password);
  MasterSeed := SpeckDecrypt(tced, EncryptedMasterSeed);
  if not isHex(MasterSeed) then
  begin

    raise Exception.Create(dictionary('FailedToDecrypt'));

    { TThread.Synchronize(nil,
      procedure
      begin
      popupWindow.Create(dictionary('FailedToDecrypt'));
      end);

      exit; }
  end;

  exit(MasterSeed);

end;

procedure Account.wipeAccount();
begin

end;

procedure Account.GenerateEQRFiles();
begin
//

end;

function Account.getDescription(id, X: Integer): AnsiString;
var
  middleNum: AnsiString;
begin
  if (not DescriptionDict.tryGetValue(TPair<Integer, Integer>.Create(id, X),
    result)) or (result = '') then
  begin
    if (X = 0) or (X = -1) then
      middleNum := ''
    else
      middleNum := ''; // ' ' + intToStr(x+1);
    result := availablecoin[id].displayname + middleNum + ' (' + availablecoin
      [id].shortcut + ')';
  end;
end;

procedure Account.changeDescription(id, X: Integer; newDesc: AnsiString);
begin
  DescriptionDict.AddOrSetValue(TPair<Integer, Integer>.Create(id, X), newDesc);
  SaveDescriptionFile();
end;

procedure Account.changeDescriptionwithoutSave(id, X: Integer;
newDesc: AnsiString);
begin
  DescriptionDict.AddOrSetValue(TPair<Integer, Integer>.Create(id, X), newDesc);

end;

procedure Account.SaveDescriptionFile();
var
  obj: TJSONObject;
  it: TObjectDictionary<TPair<Integer, Integer>, AnsiString>.TPairEnumerator;
  pair: TJSONString;
  str: TJSONString;
  ts: TstringList;
begin

  mutexDescriptionFile.Acquire;
  obj := TJSONObject.Create();

  it := DescriptionDict.GetEnumerator;

  while (it.MoveNext) do
  begin
    // it.Current.Key ;
    pair := TJSONString.Create(intToStr(it.Current.Key.Key) + '_' +
      intToStr(it.Current.Key.Value));
    str := TJSONString.Create(it.Current.Value);

    obj.AddPair(TJsonPair.Create(pair, str));

  end;

  it.Free;

  ts := TstringList.Create();

  ts.Text := obj.ToString;
  ts.SaveToFile(DescriptionFilePath);

  ts.Free();
  obj.Free;

  mutexDescriptionFile.Release;
end;

procedure Account.LoadDescriptionFile();
var
  obj : TJsonObject;
  //it : TJSONPairEnumerator; //TObjectDictionary< TPair<Integer , Integer > , AnsiString>.TPairEnumerator;
      // PairEnumerator works on 10.2
      // TEnumerator works on 10.3
  it : TJSONObject.TEnumerator; //TObjectDictionary< TPair<Integer , Integer > , AnsiString>.TPairEnumerator;
  ts , temp : TstringList;
begin

  mutexDescriptionFile.Acquire;

  if not FileExists(DescriptionFilePath) then
  begin
    mutexDescriptionFile.Release;
    exit();
  end;

  ts := TstringList.Create();
  ts.loadFromFile(DescriptionFilePath);
  if ts.Text = '' then
  begin
    ts.Free();
    mutexDescriptionFile.Release;
    exit();
  end;

  obj := TJSONObject(TJSONObject.ParseJSONValue(ts.Text));

  it := obj.GetEnumerator;

  while (it.MoveNext) do
  begin

    temp := SplitString(it.Current.JsonString.Value, '_');

    changeDescriptionwithoutSave(strToIntdef(temp[0], 0),
      strToIntdef(temp[1], 0), it.Current.JsonValue.Value);

    temp.Free();
  end;

  it.Free;
  ts.Free();

  obj.Free();
  mutexDescriptionFile.Release;
end;

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
    result := result + max(0, TWalletInfo(twi).getfiat);

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
      begin
        SetLength(result, Length(result) + 1);
        result[high(result)] := TWalletInfo(twi).utxo[i];
      end;
    end;
  end;

end;

function Account.getSpendable(wi: TWalletInfo): BigInteger;
var
  twi: cryptoCurrency;
  twis: TCryptoCurrencyArray;
  i: Integer;
begin
  result := BigInteger.Zero;
  if wi.X = -1 then
  begin
    result := wi.confirmed;
    result := result + wi.unconfirmed;

  end;
  twis := getWalletWithX(wi.X, TWalletInfo(wi).coin);
  for i := 0 to Length(twis) - 1 do
  begin
    twi := twis[i];
    if not assigned(twi) then
      continue;
    // if not TWalletInfo(twi).inPool then Continue;
    try

      result := result + twi.confirmed;
      result := result + twi.unconfirmed;
    except

    end;
  end
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
    // if not TWalletInfo(twi).inPool then Continue;
    try

      result.confirmed := result.confirmed + twi.confirmed;
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
  inherited Create;
  name := _name;

  self.firstsync := true;

  DirPath := TPath.Combine(HOME_PATH, name);

  DescriptionDict := TObjectDictionary<TPair<Integer, Integer>,
    AnsiString>.Create();

  if not DirectoryExists(DirPath) then
    CreateDir(DirPath);

  // CoinFilePath := TPath.Combine(HOME_PATH, name);
  CoinFilePath := TPath.Combine(DirPath, 'hodler.coin.dat');

  // TokenFilePath := TPath.Combine(HOME_PATH, name);
  TokenFilePath := TPath.Combine(DirPath, 'hodler.erc20.dat');

  // SeedFilePath := TPath.Combine(HOME_PATH, name);
  SeedFilePath := TPath.Combine(DirPath, 'hodler.masterseed.dat');

  DescriptionFilePath := TPath.Combine(DirPath, 'hodler.description.dat');

  // System.IOUtils.TPath.GetDownloadsPath()

  SetLength(Paths, 4);
  Paths[0] := CoinFilePath;
  Paths[1] := TokenFilePath;
  Paths[2] := SeedFilePath;
  Paths[3] := DescriptionFilePath;

  SetLength(myCoins, 0);
  SetLength(myTokens, 0);

  mutexTokenFile := TSemaphore.Create();
  mutexCoinFile := TSemaphore.Create();
  mutexSeedFile := TSemaphore.Create();
  mutexDescriptionFile := TSemaphore.Create();

  semaphore := TLightweightSemaphore.Create(8);
  VerifyKeypoolSemaphore := TLightweightSemaphore.Create(8);
  mutex := TSemaphore.Create();

  SynchronizeThreadGuardian := ThreadKindergarten.Create();

end;

destructor Account.Destroy();
begin

  {if SyncBalanceThr <> nil then

      SyncBalanceThr.Terminate;

        TThread.CreateAnonymousThread(
            procedure
                begin

                      SyncBalanceThr.DisposeOf;

                            SyncBalanceThr := nil;

                                end).Start();}

if (synchronizeThread <> nil) and (synchronizeThread.finished) then
  begin
    synchronizeThread.Free;
    synchronizeThread := nil;
  end
  else if synchronizeThread <> nil then
  begin
    synchronizeThread.Terminate;
    synchronizeThread.WaitFor;
  end;

  SynchronizeThreadGuardian.DisposeOf;
  SynchronizeThreadGuardian := nil;

  mutexTokenFile.Free;
  mutexCoinFile.Free;
  mutexSeedFile.Free;
  mutexDescriptionFile.Free;
  DescriptionDict.Free();
  clearArrays();
  semaphore.free;
  VerifyKeypoolSemaphore.free;
  mutex.free;

  inherited;
end;

procedure Account.SaveSeedFile();
var
  ts: TstringList;
  flock: TObject;
begin
  mutexSeedFile.Acquire;
  { flock := TObject.Create;
    TMonitor.Enter(flock); }
  ts := TstringList.Create();
  try
    ts.Add(intToStr(TCAIterations));
    ts.Add(EncryptedMasterSeed);
    ts.Add(booltoStr(userSaveSeed));
    ts.Add(booltoStr(privTCA));
    ts.Add(booltoStr(frmHome.HideZeroWalletsCheckBox.isChecked));
    ts.SaveToFile(SeedFilePath);
  except
    on E: Exception do
    begin
    end;

  end;
  ts.Free;
  { TMonitor.exit(flock);
    flock.Free; }
  mutexSeedFile.Release;
end;

procedure Account.LoadSeedFile();
var
  ts: TstringList;
  flock: TObject;
begin
  { flock:=TObject.Create;
    TMonitor.Enter(flock); }

  mutexSeedFile.Acquire;

  ts := TstringList.Create();
  try

    ts.loadFromFile(SeedFilePath);

    TCAIterations := strToIntdef(ts.Strings[0], 0);
    EncryptedMasterSeed := ts.Strings[1];
    userSaveSeed := strToBool(ts.Strings[2]);
    if ts.Count > 4 then
    begin
      privTCA := strToBoolDef(ts.Strings[3], false);
      hideEmpties := strToBoolDef(ts.Strings[4], false)
    end
    else
    begin
      privTCA := false;
      hideEmpties := false;
    end;
  except
    on E: Exception do
    begin
    end;
  end;
  ts.Free;

  mutexSeedFile.Release;
  { TMonitor.exit(flock);
    flock.Free; }
end;

function Account.countWalletBy(id: Integer): Integer;
var
  ts: TstringList;
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
  changeDescription(wd.coin, wd.X, wd.description);
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
  ts: TstringList;
  i: Integer;
  T: Token;
  flock: TObject;
begin
  // flock := TObject.Create;
  // TMonitor.Enter(flock);

  clearArrays();


  LoadSeedFile();

  LoadCoinFile();
  LoadTokenFile();
  LoadDescriptionFile();

   {$IF (DEFINED(MSWINDOWS) OR DEFINED(LINUX))}
  BigQRImagePath := TPath.Combine( DirPath , hash160FromHex(EncryptedMasterSeed) + '_' + '_BIG' + '.png')  ;
  SmallQRImagePath:=TPath.Combine( DirPath , hash160FromHex(EncryptedMasterSeed) + '_' + '_SMALL' + '.png');
{$ELSE}
  if not DirectoryExists(TPath.Combine(System.IOUtils.TPath.GetDownloadsPath(),
    'hodler.tech')) then
    ForceDirectories(TPath.Combine(System.IOUtils.TPath.GetDownloadsPath(),
      'hodler.tech'));

  BigQRImagePath := TPath.Combine
    (TPath.Combine(System.IOUtils.TPath.GetDownloadsPath(), 'hodler.tech'),
    name + '_' + EncryptedMasterSeed + '_' + '_ENC_QR_BIG' + '.png');
  SmallQRImagePath := TPath.Combine
    (TPath.Combine(System.IOUtils.TPath.GetDownloadsPath(), 'hodler.tech'),
    name + '_' + EncryptedMasterSeed + '_' + '_ENC_QR_SMALL' + '.png');
{$ENDIF}

end;

procedure Account.LoadCoinFile();
var
  ts: TstringList;
  i: Integer;
  JsonArray: TJsonArray;
  coinJson: TJSONValue;
  dataJson: TJSONObject;
  ccData: TJSONObject;
  inPool: AnsiString;
  s: string;
  wd: TWalletInfo;
  procedure setupCoin(coinName: AnsiString; dataJson: TJSONObject);
  var
    wd: TWalletInfo;
    nn: NanoCoin;
    innerID, X, Y, address, description, creationTime, panelYPosition,
      publicKey, EncryptedPrivateKey, isCompressed: AnsiString;
  begin
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

    if coinName = 'Nano' then
    begin
      nn := NanoCoin.Create(strToIntdef(innerID, 0), strToIntdef(X, 0),
        strToIntdef(Y, 0), string(address), string(description),
        strToIntdef(creationTime, 0));
      wd := TWalletInfo(nn);
    end
    else
      wd := TWalletInfo.Create(strToIntdef(innerID, 0), strToIntdef(X, 0),
        strToIntdef(Y, 0), address, description, strToIntdef(creationTime, 0));
    wd.inPool := strToBoolDef(inPool, false);
    wd.pub := publicKey;
    wd.orderInWallet := strToIntdef(panelYPosition, 0);
    wd.EncryptedPrivKey := EncryptedPrivateKey;
    wd.isCompressed := strToBool(isCompressed);

    wd.wid := Length(myCoins);

    // coinJson.TryGetValue<TJsonObject>('CryptoCurrencyData', ccData);

    if coinJson.tryGetValue<TJSONObject>('CryptoCurrencyData', ccData) then
      loadCryptoCurrencyJSONData(ccData, wd);

    AddCoinWithoutSave(wd);

  end;

var
  flock: TObject;
  coinName: AnsiString;
begin

  mutexCoinFile.Acquire;

  { flock := TObject.Create;
    TMonitor.Enter(flock); }

  if not FileExists(CoinFilePath) then
  begin

    mutexCoinFile.Release;
    exit;

  end;

  ts := TstringList.Create();

  ts.loadFromFile(CoinFilePath);

  if ts.Text[low(ts.Text)] = '[' then
  begin
    s := ts.Text;
    JsonArray := TJsonArray(TJSONObject.ParseJSONValue(s));

    for coinJson in JsonArray do
    begin
      coinName := coinJson.GetValue<String>('name');
      dataJson := coinJson.GetValue<TJSONObject>('data');
      inPool := '0';
      try
        inPool := dataJson.GetValue<string>('inPool')
      except
        on E: Exception do
        begin
        end;
        // Do nothing - preKeypool .dat
      end;
      setupCoin(coinName, dataJson);

    end;

    JsonArray.Free;

  end
  else
  begin
    i := 0;
    while i < ts.Count - 1 do
    begin
      wd := TWalletInfo.Create(strToIntdef(ts.Strings[i], 0),
        strToIntdef(ts.Strings[i + 1], 0), strToIntdef(ts.Strings[i + 2], 0),
        ts.Strings[i + 3], ts.Strings[i + 4], strToIntdef(ts[i + 5], 0));

      wd.orderInWallet := strToIntdef(ts[i + 6], 0);
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

  mutexCoinFile.Release;
  {
    TMonitor.exit(flock);
    flock.Free; }
end;

procedure Account.LoadTokenFile();
var
  ts: TstringList;
  i: Integer;
  T: Token;
  JsonArray: TJsonArray;
  tokenJson: TJSONValue;
  tempJson: TJSONValue;
  flock: TObject;
begin
  { flock := TObject.Create;
    TMonitor.Enter(flock); }
  mutexTokenFile.Acquire;
  if FileExists(TokenFilePath) then
  begin

    ts := TstringList.Create();

    ts.loadFromFile(TokenFilePath);

    if ts.Text[low(ts.Text)] = '[' then
    begin

      JsonArray := TJsonArray(TJSONObject.ParseJSONValue(ts.Text));

      for tokenJson in JsonArray do
      begin

        tokenJson.tryGetValue<TJSONValue>('TokenData', tempJson);

        T := Token.fromJson(tempJson);

        if tokenJson.tryGetValue<TJSONValue>('CryptoCurrencyData', tempJson)
        then
        begin

          loadCryptoCurrencyJSONData(tempJson, T);

        end;

        if (T.id < 10000) or (Token.availableToken[T.id - 10000].address <> '')
        then // if token.address = ''   token is no longer exist
          AddTokenWithoutSave(T);

        {
          tokenJson.AddPair('name' , myTokens[i].name );
          tokenJson.AddPair('TokenData' , myTokens[i].toJson );
          TokenJson.AddPair('CryptoCurrencyData' , getCryptoCurrencyJsonData( myTokens[i] ) ); }

      end;

      JsonArray.Free;
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

        AddTokenWithoutSave(T);
        // add new token to array myTokens

      end;

    end;

    ts.Free;

  end;

  mutexTokenFile.Release;
  { TMonitor.exit(flock);
    flock.Free; }
end;

procedure Account.SaveFiles();
var
  ts: TstringList;
  i: Integer;
  fileData: AnsiString;
  flock: TObject;
begin
  // flock := TObject.Create;
  // TMonitor.Enter(flock);

  SaveSeedFile();

  SaveCoinFile();
  SaveTokenFile();
  SaveDescriptionFile();

  // TMonitor.exit(flock);
  // flock.Free;
end;

procedure Account.SaveTokenFile();
var
  ts: TstringList;
  i: Integer;
  fileData: AnsiString;
  TokenArray: TJsonArray;
  tokenJson: TJSONObject;
  flock: TObject;
begin

  mutexTokenFile.Acquire;

  ts := TstringList.Create();
  try
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
    ts.SaveToFile(TokenFilePath);
    TokenArray.Free;
  except
    on E: Exception do
    begin
    end;
  end;

  ts.Free;
  mutexTokenFile.Release;

end;

procedure Account.SaveCoinFile();
var
  i: Integer;
  ts: TstringList;
  data: TWalletInfo;
  JsonArray: TJsonArray;
  coinJson: TJSONObject;
  dataJson: TJSONObject;
  flock: TObject;
begin
  { flock := TObject.Create;
    TMonitor.Enter(flock); }
  mutexCoinFile.Acquire();
  try

    JsonArray := TJsonArray.Create();

    for data in myCoins do
    begin
      if data.deleted then
        continue;

      dataJson := TJSONObject.Create();
      dataJson.AddPair('innerID', intToStr(data.coin));
      dataJson.AddPair('X', intToStr(data.X));
      dataJson.AddPair('Y', intToStr(data.Y));
      dataJson.AddPair('address', data.addr);
      dataJson.AddPair('description', data.description);
      dataJson.AddPair('creationTime', intToStr(data.creationTime));
      dataJson.AddPair('panelYPosition', intToStr(data.orderInWallet));
      dataJson.AddPair('publicKey', data.pub);
      dataJson.AddPair('EncryptedPrivateKey', data.EncryptedPrivKey);
      dataJson.AddPair('isCompressed', booltoStr(data.isCompressed));
      dataJson.AddPair('inPool', booltoStr(data.inPool));
      coinJson := TJSONObject.Create();
      coinJson.AddPair('name', data.name);
      coinJson.AddPair('data', dataJson);
      coinJson.AddPair('CryptoCurrencyData', getCryptoCurrencyJsonData(data));

      JsonArray.AddElement(coinJson);

    end;

    ts := TstringList.Create();
    try
      ts.Text := JsonArray.ToString;
      ts.SaveToFile(CoinFilePath);
    except
      on E: Exception do
      begin
        //
      end;
    end;
    ts.Free;
    JsonArray.Free;

  except
    on E: Exception do
    begin

    end;
  end;
  mutexCoinFile.Release;

  { TMonitor.exit(flock);
    flock.Free; }
end;

procedure loadCryptoCurrencyJSONData(data: TJSONValue; cc: cryptoCurrency);
var
  JsonObject: TJSONObject;
  dataJson: TJSONObject;
  JsonHistArray: TJsonArray;

  HistArrayIt: TJSONValue;

  confirmed, unconfirmed, rate: string;
  i: Integer;
begin

  if data.tryGetValue<string>('confirmed', confirmed) then
  begin
    BigInteger.TryParse(confirmed, 10, cc.confirmed);
  end;
  if data.tryGetValue<string>('unconfirmed', unconfirmed) then
  begin
    BigInteger.TryParse(unconfirmed, 10, cc.unconfirmed);
  end;
  if data.tryGetValue<string>('USDPrice', rate) then
  begin
    cc.rate := StrToFloatDef(rate, 0);
  end;
  { if data.TryGetValue<TJsonArray>('history', JsonHistArray) then
    begin

    SetLength(cc.history, JsonHistArray.Count);
    i := 0;
    for HistArrayIt in JsonHistArray do
    begin
    cc.history[i].fromJsonValue(HistArrayIt);

    inc(i);
    end;

    end; }

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
