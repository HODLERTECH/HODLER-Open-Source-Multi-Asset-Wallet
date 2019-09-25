unit JSONRPCApi;

interface

uses Classes, SysUtils, misc, JSON, AccountData, AccountRelated, uHome,
  WalletStructureData, coinData, cryptoCurrencyData, Bitcoin,
  Velthuis.BigIntegers, Languages, StrUtils, WIF, secp256k1, SyncThr,KeypoolRelated,Ethereum;
function commandHandler(data: string): string;

implementation
procedure wipeAnsiString(var toWipe: String);
var
  i: integer;
begin
  for i := 1 to Length(toWipe) do
    toWipe[i] := #0;
  toWipe := '';
end;
function buildErrorMsg(error: string): string;
begin
  result := '{"error": "' + error + '", "result": null}';

end;

function simpleReturn(value: string): string;
begin
  result := '{"error": null, "result": "' + value + '"}';

end;

function returnArray(value: TJSonArray): string;
begin
  result := '{"error": null, "result": ' + value.ToJSON + '}';

end;

function listWallets(): string;
var
  jarr: TJSonArray;
  accName: AccountItem;
begin
  jarr := TJSonArray.Create;
  for accName in AccountsNames do
    jarr.Add(accName.name);
  result := returnArray(jarr);
end;

function rpcLoadAccount(name: string): string;
begin
  loadCurrentAccount(name);
  if currentAccount = nil then
    exit(buildErrorMsg('Failed to load wallet ' + name));

  exit(simpleReturn('Wallet ' + name + ' loaded'));

end;

function rpcGetCurrentWallet(): string;
begin
  if currentAccount <> nil then
    exit(simpleReturn(currentAccount.name))
  else
    exit(buildErrorMsg('None account is loaded'));

end;

function idToCoin(id: integer): cryptoCurrency;
var
  i: integer;
  data: TWalletInfo;
begin
  if currentAccount = nil then
    exit;
  with currentAccount do
  begin
    i := 0;
    for data in myCoins do
    begin
      if i = id then
        exit(data);
      inc(i);
    end
  end;
end;

function rpcListCoins(): string;
var
  i: integer;
  data: TWalletInfo;
  JsonArray: TJSonArray;
  coinJson: TJSONObject;
  dataJson: TJSONObject;
begin

  if currentAccount = nil then
    exit(buildErrorMsg('Please load wallet first'));
  i := 0;
  with currentAccount do
  begin
    JsonArray := TJSonArray.Create();
    for data in myCoins do
    begin
      if data.deleted then
        continue;
      dataJson := TJSONObject.Create();
      dataJson.AddPair('id', inttostr(i));
      inc(i);
      dataJson.AddPair('innerID', inttostr(data.coin));
      dataJson.AddPair('X', inttostr(data.X));
      dataJson.AddPair('Y', inttostr(data.Y));
      dataJson.AddPair('address', data.addr);
      dataJson.AddPair('description', data.description);
      dataJson.AddPair('creationTime', inttostr(data.creationTime));
      dataJson.AddPair('panelYPosition', inttostr(data.orderInWallet));
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
    exit(returnArray(JsonArray));
  end;
end;

function rpcListTokens(): string;
var
  i: integer;
  fileData: AnsiString;
  TokenArray: TJSonArray;
  tokenJson: TJSONObject;

begin
  if currentAccount = nil then
    exit(buildErrorMsg('Please load wallet first'));
  with currentAccount do
  begin
    TokenArray := TJSonArray.Create();

    for i := 0 to Length(myTokens) - 1 do
    begin
      if myTokens[i].deleted = false then
      begin
        tokenJson := TJSONObject.Create();
        tokenJson.AddPair('name', myTokens[i].name);
        tokenJson.AddPair('TokenData', myTokens[i].ToJSON);
        tokenJson.AddPair('CryptoCurrencyData',
          getCryptoCurrencyJsonData(myTokens[i]));
        TokenArray.Add(tokenJson);

      end;

    end;
    exit(returnArray(TokenArray));
  end;

end;

function rpcSynchronize(): string;
begin
  if currentAccount = nil then
    exit(buildErrorMsg('Please load wallet first'));
  TThread.CreateAnonymousThread(
    procedure
    begin
      currentAccount.AsyncSynchronize();
    end).start;
  exit(simpleReturn('Synchronization called'));
end;

function rpcCreateWallet(name, seed, password: string): string;
begin
  try
    CreateNewAccountAndSave(name, password, seed, true);
  except
    on E: Exception do
    begin
      exit(buildErrorMsg('Failed to create wallet'));
    end;
  end;
  exit(simpleReturn('Wallet ' + name + ' created'));
end;

function rpcCreateWalletMnemonic(name, seed, password: string): string;
begin
  try
    CreateNewAccountAndSave(name, password,
      fromMnemonic(misc.SplitString(seed)), true);
  except
    on E: Exception do
    begin
      exit(buildErrorMsg('Failed to create wallet'));
    end;
  end;
  exit(simpleReturn('Wallet ' + name + ' created'));
end;

function rpcCreateCoin(coinid, X, Y, desc, pass: string): string;
var
  wi: TWalletInfo;
  seed: string;
begin
  if currentAccount = nil then
    exit(buildErrorMsg('Please load wallet first'));
  try
    seed := SpeckDecrypt(TCA(pass), currentAccount.EncryptedMasterSeed);
    if (not isHex(seed)) and (Length(seed) <> 64) then
      exit(buildErrorMsg('Wrong password'));

    wi := CreateCoin(strtoint(coinid), strtoint(X), strtoint(Y), seed, desc);
    if      CurrentAccount.getSibling(wi,strtoint(Y))<>nil then begin 
        wipeAnsiString(seed);
    exit(buildErrorMsg('This coin already exists'));
    end;
    currentAccount.AddCoin(wi);
    currentAccount.SaveFiles;
    wipeAnsiString(seed);
  except
    on E: Exception do
    begin
      wipeAnsiString(seed);
      exit(buildErrorMsg('Failed to create coin'));
    end;
  end;
  exit(simpleReturn('Coin created'));
end;

function rpcAddressFromPub(pub, coinid, mode: string): string;
var
  cid: integer;
  imode: integer;
  s: string;
begin
  try
    cid := strtoint(coinid);
    imode := strtoint(mode);
    if isHex(pub) = false then
      exit(buildErrorMsg('Invalid pub format'));
    case imode of
      0:
        s := generatep2pkh(pub, availablecoin[cid].p2pk);
      1:
        s := generatep2sh(pub, availablecoin[cid].p2sh);
      2:
        s := generatep2wpkh(pub, availablecoin[cid].hrp);
      3:
        s := bitcoinCashAddressToCashAddress
          (generatep2pkh(pub, availablecoin[cid].p2pk), false)
    end;
    exit(simpleReturn(s));
  except
    on E: Exception do
    begin
      exit(buildErrorMsg('An exception occured: ' + E.Message));
    end;

  end;
end;

function rpcSendHelper(wd: TWalletInfo; Address, samount, sfee, coinname,
  pass: string): string;
var
  cc: cryptoCurrency;
  seed, CashAddr, s: string;
  Amount, Fee: BigInteger;
begin
  if currentAccount = nil then
    exit(buildErrorMsg('Please load wallet first'));
  try
    cc := cryptoCurrency(wd);

    if cc = nil then
      exit(buildErrorMsg('crypto with given id not found'));
    Amount := BigInteger.Parse(samount);
    Fee := BigInteger.Parse(sfee);
    currentCoin := TWalletInfo(cc);
    seed := SpeckDecrypt(TCA(pass), currentAccount.EncryptedMasterSeed);
    if (not isHex(seed)) and (Length(seed) <> 64) then
      exit(buildErrorMsg('Wrong password'));

    if not((isEthereum) or (frmHome.isTokenTransfer) or (currentCoin.coin = 8))
    then
      if Length(currentAccount.aggregateUTXO(currentCoin)) = 0 then
      begin
        wipeAnsiString(seed);
        exit(buildErrorMsg
          (('There is no inputs to spend, please wait for transaction confirmation')
          ));
      end;
    if (not frmHome.isTokenTransfer) then
    begin
      if Amount + Fee > (currentAccount.aggregateBalances(currentCoin).confirmed)
      then
      begin
        wipeAnsiString(seed);
        exit(buildErrorMsg((dictionary('AmountExceed'))));
      end;
    end;
    if ((Amount) = 0) or (((Fee) = 0) and (currentCoin.coin <> 8)) then
    begin
      wipeAnsiString(seed);
      exit(buildErrorMsg((dictionary('InvalidValues'))));
    end;
    if (CurrentCryptoCurrency is TWalletInfo) and
      (TWalletInfo(CurrentCryptoCurrency).coin in [3, 7]) then
    begin
      CashAddr := StringReplace(lowercase(Address), 'bitcoincash:', '',
        [rfReplaceAll]);
      if (LeftStr(CashAddr, 1) = 'q') or (LeftStr(CashAddr, 1) = 'p') then
      begin
        try
          Address := BCHCashAddrToLegacyAddr(Address);
        except
          on E: Exception do
          begin
            wipeAnsiString(seed);
            exit(buildErrorMsg(('Wrong bech32 address')));
          end;
        end;
      end;
    end;
    s := simpleReturn(SendCoinsTo(TWalletInfo(cc), Address, Amount, Fee, seed,
      coinname));
    wipeAnsiString(seed);
    exit(s);
  except
    on E: Exception do
    begin
      wipeAnsiString(seed);
      exit(buildErrorMsg('Exception occured: ' + E.Message));
    end;

  end;

end;

function rpcSend(sId, Address, samount, sfee, coinname, pass: string): string;
var
  cc: cryptoCurrency;
  seed, CashAddr, s: string;
  Amount, Fee: BigInteger;
begin
  if currentAccount = nil then
    exit(buildErrorMsg('Please load wallet first'));
  try
    cc := idToCoin(strtoint(sId));

    if cc = nil then
      exit(buildErrorMsg('crypto with given id not found'));
    Amount := BigInteger.Parse(samount);
    Fee := BigInteger.Parse(sfee);
    currentCoin := TWalletInfo(cc);
    seed := SpeckDecrypt(TCA(pass), currentAccount.EncryptedMasterSeed);
    if (not isHex(seed)) and (Length(seed) <> 64) then
      exit(buildErrorMsg('Wrong password'));
    startFullfillingKeypool(seed);
    if not((isEthereum) or (frmHome.isTokenTransfer) or (currentCoin.coin = 8))
    then
      if Length(currentAccount.aggregateUTXO(currentCoin)) = 0 then
      begin
        wipeAnsiString(seed);
        exit(buildErrorMsg
          (('There is no inputs to spend, please wait for transaction confirmation')
          ));
      end;
    if (not frmHome.isTokenTransfer) then
    begin
      if Amount + Fee > (currentAccount.aggregateBalances(currentCoin).confirmed)
      then
      begin
        wipeAnsiString(seed);
        exit(buildErrorMsg((('AmountExceed'))));
      end;
    end;
    if ((Amount) = 0) or (((Fee) = 0) and (currentCoin.coin <> 8)) then
    begin
      wipeAnsiString(seed);
      exit(buildErrorMsg((('InvalidValues'))));
    end;
    if (CurrentCryptoCurrency is TWalletInfo) and
      (TWalletInfo(CurrentCryptoCurrency).coin in [3, 7]) then
    begin
      CashAddr := StringReplace(lowercase(Address), 'bitcoincash:', '',
        [rfReplaceAll]);
      if (LeftStr(CashAddr, 1) = 'q') or (LeftStr(CashAddr, 1) = 'p') then
      begin
        try
          Address := BCHCashAddrToLegacyAddr(Address);
        except
          on E: Exception do
          begin
            wipeAnsiString(seed);
            exit(buildErrorMsg(('Wrong bech32 address')));
          end;
        end;
      end;
    end;
    s := simpleReturn(SendCoinsTo(TWalletInfo(cc), Address, Amount, Fee, seed,
      coinname));
    wipeAnsiString(seed);
    exit(s);
  except
    on E: Exception do
    begin
      wipeAnsiString(seed);
      exit(buildErrorMsg('Exception occured: ' + E.Message));
    end;

  end;

end;

function rpcWalletBalance: string;
begin
  if currentAccount = nil then
    exit(buildErrorMsg('Please load wallet first'));
  exit(simpleReturn(floatToStrF(frmHome.CurrencyConverter.calculate(globalFiat),
    ffFixed, 9, 2)));
end;

function rpcWalletFiat: string;
begin
  if currentAccount = nil then
    exit(buildErrorMsg('Please load wallet first'));
  exit(simpleReturn(frmHome.CurrencyConverter.symbol));
end;

function rpcSweep(priv, Compressed, coinid, dest: string): string;
var
  out , pub: AnsiString;
  WData: WIFAddressData;
  wd: TWalletInfo;
  tmp: integer;
  isCOmpressed:boolean;
  coin: integer;
  s: string;
begin
  try
    coin := strtoint(coinid);
    priv := removeSpace(priv);
    dest := removeSpace(dest);

    if isHex(priv) and (Length(priv) = 64) then
    begin
      out := priv;
    end
    else
    begin
      WData := wifToPrivKey(priv);
      isCompressed := WData.isCompressed;
      out := WData.PrivKey;
    end;
    pub := secp256k1_get_public(out , not isCompressed);

    wd := TWalletInfo.Create(coin, -1, -1, Bitcoin_PublicAddrToWallet(pub,
      availablecoin[coin].p2pk), 'Imported');
    wd.pub := pub;
    wd.EncryptedPrivKey := out;
    wd.isCompressed := StrToBool(Compressed);
    parseBalances(getDataOverHTTP(HODLER_URL + 'getBalance.php?coin=' +
      availablecoin[coin].name + '&address=' + wd.addr), wd);
    wd.UTXO := parseUTXO(getDataOverHTTP(HODLER_URL + 'getUTXO.php?coin=' +
      availablecoin[coin].name + '&address=' + wd.addr), -1);
    tmp := currentCoin.coin;
    currentCoin.coin := coin;

    if (dest = wd.addr) or (bitcoinCashAddressToCashAddress(wd.addr)
      = rightStr(dest, Length(bitcoinCashAddressToCashAddress(wd.addr)))) then
    begin
      raise Exception.Create('Use different destination address');
    end;

    if not isValidForCoin(coin, dest) then
    begin
      raise Exception.Create('Wrong Target Address');
    end;

    if wd.confirmed <= BigInteger(1700) then
    begin
      raise Exception.Create('Amount too small');
    end;
    s := rpcSendHelper(wd, dest, BigInteger(wd.confirmed - BigInteger(1700))
      .toString(10), '1700', availablecoin[strtoint(coinid)].name,'');
    currentCoin.coin := tmp;
    exit(s);
  except
    on E: Exception do
    begin
      exit(buildErrorMsg('Exception occured: ' + E.Message));
    end;

  end;
end;
function rpcImport(priv,Compressed,coinId,pass:string): string;
var
  ts: TStringList;
  path: AnsiString;
  out : AnsiString;
  wd: TWalletInfo;
  isCompressed: Boolean;
  WData: WIFAddressData;
  pub: AnsiString;

  tced: AnsiString;
  MasterSeed: AnsiString;
begin
  if currentAccount = nil then
    exit(buildErrorMsg('Please load wallet first'));
  try
      tced := TCA(pass);
    MasterSeed := SpeckDecrypt(tced, CurrentAccount.EncryptedMasterSeed);
    if not isHex(MasterSeed) then
    begin
    misc.wipeAnsiString(MasterSeed);
      exit(buildErrorMsg(dictionary('FailedToDecrypt')));
    end;
    startFullfillingKeypool(MasterSeed);
    if isHex(priv) and (length(priv) = 64) then
    begin
      out := priv;
        isCompressed := StrToBool(compressed);
    end
    else
    begin
      WData := wifToPrivKey(priv);
      isCompressed := WData.isCompressed;
      out := WData.PrivKey;
    end;
    if ImportCoinID <> 4 then
    begin
      pub := secp256k1_get_public(out , not isCompressed);

      wd := TWalletInfo.create(ImportCoinID, -1, -1,
        Bitcoin_PublicAddrToWallet(pub, AvailableCoin[ImportCoinID].p2pk),
        'Imported');
      wd.pub := pub;
      wd.EncryptedPrivKey := speckEncrypt((TCA(MasterSeed)), out);
      wd.isCompressed := isCompressed;
    end
    else if ImportCoinID = 4 then
    begin
      pub := secp256k1_get_public(out , true);
      wd := TWalletInfo.create(ImportCoinID, -1, -1,
        Ethereum_PublicAddrToWallet(pub), 'Imported');
      wd.pub := pub;
      wd.EncryptedPrivKey := speckEncrypt((TCA(MasterSeed)), out);
      wd.isCompressed := false;
    end;
    CurrentAccount.AddCoin(wd);  
    CurrentAccount.SaveFiles;
    misc.wipeAnsiString(MasterSeed);
    exit(simpleReturn('Coin imported'));  
  except
    on E: Exception do
    begin
      exit(buildErrorMsg('Exception occured: ' + E.Message));
    end;

  end;
end;

function invokeMethod(method: string; params: TArray<string>): string;
begin
  try
    writeln('invoking ' + method);
    if method = 'version' then
      exit(simpleReturn(CURRENT_VERSION));
    if method = 'listWallets' then
      exit(listWallets());
    if method = 'loadWallet' then
      exit(rpcLoadAccount(params[0]));
    if method = 'getCurrentWallet' then
      exit(rpcGetCurrentWallet());
    if method = 'listCoins' then
      exit(rpcListCoins());
    if method = 'listTokens' then
      exit(rpcListTokens());
    if method = 'synchronize' then
      exit(rpcSynchronize());
    if method = 'createWallet' then
      exit(rpcCreateWallet(params[0], params[1], params[2]));
    if method = 'createWalletFromMnemonic' then
      exit(rpcCreateWalletMnemonic(params[0], params[1], params[2]));
    if method = 'createCoin' then
      exit(rpcCreateCoin(params[0], params[1], params[2], params[3],
        params[4]));
    if method = 'addressFromPub' then
      exit(rpcAddressFromPub(params[0], params[1], params[2]));
    if method = 'send' then
      exit(rpcSend(params[0], params[1], params[2], params[3], params[4],
        params[5]));
    if method = 'walletBalance' then
      exit(rpcWalletBalance());
    if method = 'walletFiat' then
      exit(rpcWalletFiat());
    if method = 'sweep' then
      exit(rpcSweep(params[0], params[1], params[2], params[3]));
    if method = 'importPriv' then
      exit(rpcImport(params[0], params[1], params[2], params[3]));
   // if method = 'exportPriv' then
   //   exit(rpcExport(params[0], params[1]));  
    exit(buildErrorMsg('method ' + method + ' not found'));
  except
    on E: Exception do
    begin
      exit(buildErrorMsg('An exception during invoking method ' + method + ': '
        + E.Message));
    end;

  end;
end;

function commandHandler(data: string): string;
var
  jobj: TJSONObject;
  jarr: TJSonArray;
  method: string;
  params: TArray<string>;
  i: integer;
begin
  try
    jobj := TJSONObject.ParseJSONValue(data) as TJSONObject;
    try
      method := jobj.GetValue('method').value;
      jarr := (jobj.GetValue('params').AsType<TJSonArray>);

      SetLength(params, jarr.Count);
      if jarr.Count > 0 then
      begin
        for i := 0 to jarr.Count - 1 do
        begin
          params[i] := jarr.Items[i].value;
        end;

      end;
      result := invokeMethod(method, params);
    except
      on E: Exception do
      begin
        FreeAndNil(jobj);
        FreeAndNil(jarr);
        exit(buildErrorMsg('Error in method ' + method + ': ' + E.Message));
      end;
    end;
    if jobj <> nil then
      FreeAndNil(jobj);
    // if jarr<>nil then  FreeAndNil(jarr);
  except
    on E: Exception do
    begin
      exit(buildErrorMsg('unknown exception during JSON parsing: ' +
        E.Message));
    end;

  end;

end;

end.
