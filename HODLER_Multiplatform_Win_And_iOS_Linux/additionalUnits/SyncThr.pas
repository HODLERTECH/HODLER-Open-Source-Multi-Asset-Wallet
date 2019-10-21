unit SyncThr;

interface

uses
  System.classes, System.sysutils, FMX.Controls, FMX.StdCtrls, FMX.dialogs,
  System.IOUtils,
  AccountData, electrumHandler, DateUtils,idTCPClient, idSSLOpenSSL, IdSSLOpenSSLHeaders,
  StrUtils, WalletStructureData, CryptoCurrencyData, tokenData, System.SyncObjs,
{$IFDEF ANDROID}uNanoPowAs, {$ENDIF}
  JSON, System.TimeSpan, System.Diagnostics, Nano{$IFDEF MSWINDOWS},
  Winapi.ShellAPI, Winapi.Windows{$ENDIF}{$IFDEF LINUX}, Posix.Stdlib{$ENDIF};

type
  SynchronizeBalanceThread = class(TThread)
  private
    startTime: Double;
    endTime: Double;
  public
    constructor Create();
    procedure Execute(); override;
    function TimeFromStart(): Double;
  end;

type
  TTxOutput = record
    address: AnsiString;
    value: AnsiString;
  end;

type
  TxHistoryResult = record
    inputsCount: AnsiString;
    txId: AnsiString;
    outputsCount: AnsiString;
    inputAddresses: array of AnsiString;
    timestamp: AnsiString;
    outputs: array of TTxOutput;
  end;

  { type
    SynchronizeHistoryThread = class(TThread)
    private
    startTime: Double;
    endTime: Double;
    public
    constructor Create();
    procedure Execute(); override;
    function TimeFromStart(): Double;
    end; }
procedure syncWithENetwork(ac: Account; coinid: Integer; X: Integer = -1);

procedure parseDataForETH(s: AnsiString; { var } wd: TWalletInfo);

procedure parseCoinHistory(text: AnsiString; wallet: TWalletInfo);

procedure parseTokenHistory(text: AnsiString; T: Token);

function segwitParameters(wi: TWalletInfo): AnsiString;

procedure SynchronizeCryptoCurrency(ac: Account; cc: cryptoCurrency);

procedure parseBalances(s: AnsiString; var wd: TWalletInfo);

procedure parseETHHistory(text: AnsiString; wallet: TWalletInfo);

procedure SynchronizeAll();

procedure parseDataForERC20(s: string; var wd: Token);

function batchSync(ac: Account; var coinid: Integer; X: Integer = -1): string;

// procedure verifyKeypool();

procedure verifyKeypoolNoThread(ac: Account; wi: TWalletInfo);

procedure parseSync(ac: Account; s: string; verifyKeypool: boolean = false);

function keypoolIsUsed(ac: Account; var coinid: Integer;
  X: Integer = -1): string;

// var
// semaphore: TLightweightSemaphore;
// VerifyKeypoolSemaphore: TLightweightSemaphore;
// mutex: TSemaphore;
var
  serviceStarted: boolean = false;

implementation

uses
  uhome, misc, coinData, Velthuis.BigIntegers, Bitcoin, WalletViewRelated,

  keyPoolRelated{$IFDEF ANDROID}, System.Android.Service{$ENDIF};

function prepareBatch(wi: TWalletInfo; i: string): string;
var
  segwit, compatible, legacy: AnsiString;
begin
  segwit := generatep2wpkh(wi.pub, availablecoin[wi.coin].hrp);
  compatible := generatep2sh(wi.pub, availablecoin[wi.coin].p2sh);
  legacy := generatep2pkh(wi.pub, availablecoin[wi.coin].p2pk);
  if wi.coin in [0, 1] then
  begin
    result := '&wallet[][compatible]=' + compatible +
      '&wallet[][compatiblehash]=' + decodeAddressInfo(compatible, wi.coin)
      .scriptHash + '&wallet[][segwit]=' + segwit + '&wallet[][segwithash]=' +
      decodeAddressInfo(segwit, wi.coin).scriptHash;
  end
  else
    result := '&wallet[][compatible]=' + compatible +
      '&wallet[][compatiblehash]=' + decodeAddressInfo(compatible, wi.coin)
      .scriptHash + '&wallet[][segwit]=0&wallet[][segwithash]=0';
  result := result + '&wallet[][legacy]=' + legacy;

  result := StringReplace(result, '[]', '[' + IntToStr(abs(wi.uniq)) + ']',
    [rfReplaceAll]);
end;

procedure en_getBalance(wi: TWalletInfo; shash: string;socket:TidTCPClient);
var
  JSON: TJSONObject;
  jarr: TJSONObject;
  s: string;
  cc, uc: biginteger;
begin
  try
    s := electrumRPC(wi.coin, 'blockchain.scripthash.get_balance', [shash],0,socket);
    JSON := TJSONObject.ParseJSONValue(s) as TJSONObject;
    jarr := JSON.GetValue('result').AsType<TJSONObject>;
    cc := biginteger.Parse(jarr.GetValue<string>('confirmed'));
    uc := biginteger.Parse(jarr.GetValue<string>('unconfirmed'));
    // if uc<0 then cc:=cc+uc;

    wi.confirmed := wi.confirmed + cc;
    wi.unconfirmed := wi.unconfirmed + uc;
    JSON.DisposeOf;
  except
    on E: Exception do
    begin

    end;

  end;
  // Jarr.DisposeOf;
end;

function en_getTX(coinid: Integer; txhash: string;socket:TidTCPClient): string;
var
  fdir: string;
var
  JSON: TJSONObject;
  jarr: TJSONObject;
  s: string;
  ts: TStringList;
begin
  try
    fdir := HOME_PATH + '/txCache';

    if not DirectoryExists(fdir) then
      System.IOUtils.TDirectory.CreateDirectory(fdir);
    if fileexists(fdir + '/' + txhash) then
    begin
      ts := TStringList.Create();
      ts.LoadFromFile(fdir + '/' + txhash);
      result := ts.text;
      ts.Free;
      exit;
    end;
    s := electrumRPC(coinid, 'blockchain.transaction.get', [txhash, 'true'],0,socket);
    JSON := TJSONObject.ParseJSONValue(s) as TJSONObject;
    s := JSON.GetValue('result').ToJSON;
    result := s;
    ts := TStringList.Create;
    ts.text := s;
    ts.SaveToFile(fdir + '/' + txhash);
    ts.Free;
  except
    on E: Exception do
    begin

    end;

  end;
end;

function getCoinRate(wi: TWalletInfo): Double;
var
  s, apiname: string;
  jarr: TJSONArray;
  jobj: TJSONObject;
begin
  if MinutesBetween(coinRates[wi.coin].syncTime, now) > 10 then
  begin
    apiname := availablecoin[wi.coin].name;
    if apiname = 'bitcoinsv' then
      apiname := 'bitcoin-sv';
    if apiname = 'bitcoinabc' then
      apiname := 'bitcoin-cash';
    s := getDataOverHTTP('https://api.coinmarketcap.com/v1/ticker/' + apiname +
      '/?convert=USD', false, true);
    jarr := TJSONObject.ParseJSONValue(s) as TJSONArray;
    jobj := jarr.Items[0].AsType<TJSONObject>;
    coinRates[wi.coin].rate := StrToFloatDef(jobj.GetValue('price_usd')
      .AsType<string>, 0);
    coinRates[wi.coin].syncTime := now;
    jarr.Free;
  end;
  result := coinRates[wi.coin].rate;
end;

procedure en_getUTXO(wi: TWalletInfo; shash: string;socket:TidTCPClient);
var
  JSON, jutxo, jtx: TJSONObject;
  jarr: TJSONArray;
  s, tx_hash, tx_pos, value, scriptPubKey, txdata: string;
  i: Integer;
  tmp: TBitcoinOutput;
begin
  try
    s := electrumRPC(wi.coin, 'blockchain.scripthash.listunspent', [shash],0,socket);
    JSON := TJSONObject.ParseJSONValue(s) as TJSONObject;
    jarr := JSON.GetValue('result').AsType<TJSONArray>;
    for i := 0 to jarr.Count - 1 do
    begin
      jutxo := jarr.Items[i].AsType<TJSONObject>;
      tx_hash := jutxo.GetValue('tx_hash').AsType<string>;
      tx_pos := jutxo.GetValue('tx_pos').AsType<string>;
      value := jutxo.GetValue('value').AsType<string>;
      txdata := en_getTX(wi.coin, tx_hash,socket);
      jtx := TJSONObject.ParseJSONValue(txdata) as TJSONObject;
      scriptPubKey := jtx.GetValue('vout').AsType<TJSONArray>.Items
        [StrToInt(tx_pos)].AsType<TJSONObject>.GetValue('scriptPubKey')
        .AsType<TJSONObject>.GetValue('hex').AsType<string>;
      SetLength(wi.UTXO, Length(wi.UTXO) + 1);
      tmp.txId := tx_hash;
      tmp.n := StrToInt(tx_pos);
      tmp.Amount := StrToInt64(value);
      tmp.scriptPubKey := scriptPubKey;
      tmp.Y := wi.Y;
      wi.UTXO[high(wi.UTXO)] := tmp;
      jtx.DisposeOf;
    end;
    JSON.DisposeOf;
  except
    on E: Exception do
    begin

    end;

  end;
end;

function en_getHistoryByHash(shash: string; wi: TWalletInfo;socket:TidTCPClient): string;
var
  s: string;
  JSON: TJSONObject;

begin
  try
    s := electrumRPC(wi.coin, 'blockchain.scripthash.get_history', [shash],0,socket);
    JSON := TJSONObject.ParseJSONValue(s) as TJSONObject;
    result := JSON.GetValue('result').ToJSON;
  except
    on E: Exception do
    begin

    end;

  end;
end;

function en_getHistory(legacy, compatible, segwit: string;
  wi: TWalletInfo;socket:TidTCPClient): string;
var
  JSON, jutxo, jtx, vtx: TJSONObject;
  jarr, vins, vouts, vaddrs: TJSONArray;
  s, shash, tx_hash, txdata: string;
  i, j, k, l, addrC: Integer;
  vindata: string;
  svins, history: array of string;
  res, txId, time, vaddr: string;
begin
  try
    SetLength(history, 0);
    for j := 0 to 2 do
    begin
      case j of
        0:
          shash := legacy;
        1:
          shash := compatible;
        2:
          shash := segwit;
      end;
      s := en_getHistoryByHash(shash, wi,socket);
      jarr := TJSONObject.ParseJSONValue(s) as TJSONArray;
      for i := jarr.Count - 1 downto 0 do
      begin
        txId := jarr.Items[i].AsType<TJSONObject>.GetValue<string>('tx_hash');
        txdata := en_getTX(wi.coin, txId,socket);
        jtx := TJSONObject.ParseJSONValue(txdata) as TJSONObject;
        vins := jtx.GetValue('vin').AsType<TJSONArray>;
        vouts := jtx.GetValue('vout').AsType<TJSONArray>;
        SetLength(svins, 0);
        for k := 0 to vins.Count - 1 do
        begin

          vindata := en_getTX(wi.coin,
            vins.Items[k].AsType<TJSONObject>.GetValue<string>('txid'),socket);
          vtx := TJSONObject.ParseJSONValue(vindata) as TJSONObject;
          vaddrs := vtx.GetValue('vout').AsType<TJSONArray>.Items
            [vins.Items[k].GetValue<Integer>('vout')].GetValue<TJSONObject>
            ('scriptPubKey').GetValue('addresses').AsType<TJSONArray>;
          for l := 0 to vaddrs.Count - 1 do
          begin
            SetLength(svins, Length(svins) + 1);
            svins[High(svins)] := vaddrs.Items[l].AsType<string>;
          end;

        end;
        res := txId + #13#10 + IntToStr(Length(svins)) + #13#10;
        for l := 0 to Length(svins) - 1 do
          res := res + svins[l] + #13#10;
        if not jtx.TryGetValue('time', time) then
          time := IntToStr(DateTimeToUnix(now));
        res := res + time;
        if jtx.FindValue(('confirmations')) <> nil then
          res := res + ' ' + jtx.GetValue('confirmations')
            .AsType<string> + #13#10
        else
          res := res + '  0' + #13#10;
        addrC := 0;
        for l := 0 to vouts.Count - 1 do
        begin
          vaddr := vouts.Items[l].GetValue<TJSONObject>('scriptPubKey')
            .GetValue('addresses').AsType<TJSONArray>.Items[0].AsType<string>;
          res := res + vaddr + #13#10;
          inc(addrC);
          res := res + vouts.Items[l].GetValue<string>('value') + #13#10;
          if addrC > 50 then
            break;

        end;
        SetLength(history, Length(history) + 1);
        history[High(history)] := IntToStr(addrC) + #13#10 + res;
        jtx.DisposeOf;
      end;
      result := '';
      for l := 0 to Length(history) - 1 do
        result := result + history[l];
      if trim(result) <> '' then
        wi.inPool := false;
      jarr.DisposeOf;
    end;
  except
    on E: Exception do
    begin

    end;

  end;
end;

procedure en_getFees(wi: TWalletInfo;socket:TidTCPClient);
var
  JSON: TJSONObject;
  jarr: Double;
  s: string;
  i: Integer;
begin
  try
    for i := 0 to 4 do
    begin
      s := electrumRPC(wi.coin, 'blockchain.estimatefee', [IntToStr(i + 1)],0,socket);
      JSON := TJSONObject.ParseJSONValue(s) as TJSONObject;
      jarr := JSON.GetValue('result').AsType<Double>;
      wi.efee[i] := FloatToStrF(jarr, ffFixed, 10, 10);
      JSON.Free;
    end;
  except
    on E: Exception do
    begin

    end;

  end;
end;

procedure doEsync(wi: TWalletInfo);
var
  hist: string;
  tmpWi: TWalletInfo;
  segwit, compatible, legacy: AnsiString;
  socket:TidTCPClient;
begin
if wi=nil then exit;

  socket:=getTCPForCoin(wi.coin,-1);
  if socket=nil then Exit;

  socket:=CreateTCPConnection(socket.host,socket.port);
  segwit := decodeAddressInfo(generatep2wpkh(wi.pub,
    availablecoin[wi.coin].hrp), wi.coin).scriptHash;
  compatible := decodeAddressInfo(generatep2sh(wi.pub,
    availablecoin[wi.coin].p2sh), wi.coin).scriptHash;
  legacy := decodeAddressInfo(generatep2pkh(wi.pub,
    availablecoin[wi.coin].p2pk), wi.coin).scriptHash;
  // if (wi.inPool = false) or (wi.Y >= changeDelimiter) then
  begin
    tmpWi := TWalletInfo.Create(wi.coin, 0, 0, '', '');
   // wi.confirmed := 0;
    //wi.unconfirmed := 0;
    tmpWi.confirmed := 0;
    tmpWi.unconfirmed := 0;
    wi.UTXO := [];
    en_getBalance(tmpWi, segwit,socket);
    en_getBalance(tmpWi, compatible,socket);
    en_getBalance(tmpWi, legacy,socket);
    wi.confirmed := tmpWi.confirmed;
    wi.unconfirmed := tmpWi.unconfirmed;
    tmpWi.DisposeOf;
    en_getUTXO(wi, segwit,socket);
    en_getUTXO(wi, compatible,socket);
    en_getUTXO(wi, legacy,socket);
    en_getFees(wi,socket);
  end;
  wi.rate := getCoinRate(wi);

 hist := en_getHistory(legacy, compatible, segwit, wi,socket);
 parseCoinHistory(hist, wi);
  socket.disconnect;
  socket.DisposeOf;
end;

procedure syncWithENetwork(ac: Account; coinid: Integer; X: Integer = -1);
var
  wi: TWalletInfo;
begin
  for wi in ac.myCoins do
  begin
    if (wi.coin = coinid) then
    begin
   {   TThread.CreateAnonymousThread(
        procedure
        var
          xx: TWalletInfo;
        begin
          // xx:=wi;
          sleep(25);
          doEsync(wi);

        end).Start;
      sleep(150);}
      doEsync(wi);
    end;

    //sleep(50);
  end;

end;

function batchSync(ac: Account; var coinid: Integer; X: Integer = -1): string;
var
  wi: TWalletInfo;
  i: Integer;
begin
  i := 0;

  result := 'coin=' + availablecoin[coinid].name;
  for wi in ac.myCoins do
  begin
    if (wi.coin = coinid) then
    begin
      wi.uniq := abs((coinid * 1000) + StrToInt64Def('$5' +
        Copy(GetStrHashSHA256(ac.name + IntToStr(coinid) + IntToStr(wi.X) +
        IntToStr(wi.Y)), 0, 6), 0) + i); // moreUniq
      if (wi.inPool = false) or (wi.Y >= changeDelimiter) then
      begin

        if (X <> -1) then
        begin
          if wi.X = X then
            result := result + prepareBatch(wi, wi.addr)
        end
        else
          result := result + prepareBatch(wi, wi.addr);
      end;
    end;
    inc(i);
  end;
end;

function keypoolIsUsed(ac: Account; var coinid: Integer;
X: Integer = -1): string;
var
  wi: TWalletInfo;
  i: Integer;
begin
  i := 0;
  if not(coinid in [0 .. 8]) then
    exit;

  result := 'coin=' + availablecoin[coinid].name;
  for wi in ac.myCoins do
  begin
    if (wi.coin = coinid) and ((wi.inPool = true) or (wi.Y >= changeDelimiter))
    then
    begin
      wi.uniq := abs((coinid * 1000) + StrToInt64Def('$' +
        Copy(GetStrHashSHA256(ac.name + IntToStr(coinid) + IntToStr(wi.X) +
        IntToStr(wi.Y)), 0, 7), 0) + i); // moreUniq

      if (X <> -1) then
      begin
        if wi.X = X then
          result := result + prepareBatch(wi, wi.addr)
      end
      else
        result := result + prepareBatch(wi, wi.addr);
    end;
    inc(i);
  end;
end;

procedure syncNano(var cc: cryptoCurrency; data: AnsiString);
  procedure calcNanoBalances(var nn: NanoCoin);
  var
    nblock: TNanoBlock;
    i: Integer;
    prevAmount, prevUAmount, delta: biginteger;

  begin
    if Length(nn.pendingChain) = 0 then
      exit;
    prevAmount := nn.confirmed;
    nblock := nn.firstBlock;
    if not(nblock.balance = '') then
      if biginteger.Parse(nblock.balance) < prevAmount then
      begin
        delta := (prevAmount - biginteger.Parse(nblock.balance));
        nn.confirmed := prevAmount - delta;
        nn.unconfirmed := nn.unconfirmed - delta;
      end;

    repeat

      if biginteger.Parse(nblock.balance) < prevAmount then
      begin
        SetLength(nn.history, Length(nn.history) + 1);
        i := Length(nn.history) - 1;
        SetLength(nn.history[i].values, 2);
        SetLength(nn.history[i].addresses, 2);
        nn.history[i].values[0] :=
          (prevAmount - biginteger.Parse(nblock.balance));
        nn.history[i].values[1] := 0;
        nn.history[i].TransactionID := nblock.Hash;
        nn.history[i].addresses[0] := (nblock.Account);
        nn.history[i].addresses[1] := (nblock.source);
        nn.history[i].data := IntToStr(Length(nn.history) + 1);
        nn.history[i].typ := 'OUT';
        nn.history[i].CountValues := nn.history[i].values[0];
        nn.history[i].confirmation := 0;

      end;
      prevAmount := biginteger.Parse(nblock.balance);

      nblock := nn.BlockByPrev(nblock.Hash);
      if not(nblock.balance = '') then
        if biginteger.Parse(nblock.balance) < prevAmount then
        begin
          delta := (prevAmount - biginteger.Parse(nblock.balance));
          nn.confirmed := prevAmount - delta;
          nn.unconfirmed := nn.unconfirmed - delta;
        end;

    until nblock.Account = '';
  end;

var
  js: TJSONObject;
  newblock: string;
  block, firstBlock: TNanoBlock;
  history: TJSONArray;
  ts: TStringList;
  i: Integer;
  masterseed, tced: AnsiString;
  err: string;
  pendings: TJSONArray;
  temp: TpendingNanoBlock;
  psxString: {$IFDEF LINUX64}System.{$ENDIF}AnsiString;
  // System.AnsiString nie kompiluje siê na Androidzie
begin
  data := StringReplace(data, 'xrb_', 'nano_', [rfReplaceAll]);
{$IFDEF MSWINDOWS}
  if TOSVersion.Architecture = arIntelX64 then
    ShellExecute(0, 'open', 'NanoPoW64.exe', '',
      PWideChar(ExtractFileDir(ParamStr(0))), 6)
  else
    ShellExecute(0, 'open', 'NanoPoW32.exe', '',
      PWideChar(ExtractFileDir(ParamStr(0))), 6);
{$ENDIF}
{$IFDEF LINUX64}
  psxString := '"' + ExtractFileDir(ParamStr(0)) + '/nanopow64" ';
  _system(@psxString[1]);
{$ENDIF}
{$IFDEF ANDROID}
  if not serviceStarted then
  begin
    if not SYSTEM_APP then
      frmHome.FServiceConnection.StartService('NanoPowAS')
    else
      uNanoPowAs.nanoPowAndroidStart();
    serviceStarted := true;
  end;
{$ENDIF}
  try

    js := TJSONObject.ParseJSONValue(data) as TJSONObject;
    cc.rate := StrToFloatDef(js.GetValue('price').value, 0.0);
    cc.confirmed := biginteger.Parse(js.GetValue('balance')
      .GetValue<string>('balance'));
    cc.unconfirmed := biginteger.Parse(js.GetValue('balance')
      .GetValue<string>('pending'));
    // {history := }js.TryGetValue<TJSONArray>('history' , history) {as TJSONArray};
    // {pendings :=} js.tryGetValue<TJsonArray>('pending' , pendings) {as TJsonArray};
    try
      NanoCoin(cc).loadChain;
    except
      on E: Exception do
      begin
      end;
    end;
    if (Length(NanoCoin(cc).pendingChain) > 0) then
      NanoCoin(cc).lastBlockAmount :=
        biginteger.Parse(NanoCoin(cc).curBlock.balance)
    else
      NanoCoin(cc).lastBlockAmount := cc.confirmed;

    // cc.unconfirmed := cc.unconfirmed +
    // (cc.confirmed - NanoCoin(cc).lastBlockAmount);
    try
      if js.TryGetValue<TJSONArray>('history', history) then
        if history.Count > 0 then
        begin

          firstBlock := nano_buildFromJSON(history.Items[0].ToJSON, '', false);
          cc.lastPendingBlock := firstBlock.Hash;
          // if (Length(NanoCoin(cc).pendingChain) = 0) then
          nano_precalculate(cc.lastPendingBlock);
          SetLength(cc.history, history.Count);
          for i := 0 to history.Count - 1 do
          begin

            block := nano_buildFromJSON(history.Items[i].ToJSON, '', false);

            SetLength(cc.history[i].values, 2);
            SetLength(cc.history[i].addresses, 2);
            cc.history[i].values[0] := biginteger.abs(block.blockAmount);
            cc.history[i].values[1] := 0;
            // length(hitory.Values) must be the same as length(history.addresses)
            cc.history[i].TransactionID := block.Hash;
            if block.blocktype = 'send' then
            begin
              cc.history[i].typ := 'OUT';
              cc.history[i].addresses[0] :=
                nano_accountFromHexKey(block.destination);
              cc.history[i].addresses[1] :=
                nano_accountFromHexKey(block.Account);
            end
            else
            begin
              cc.history[i].typ := 'IN';
              cc.history[i].addresses[0] :=
                nano_accountFromHexKey(block.Account);
              cc.history[i].addresses[1] := { nano_accountFromHexKey }
                (block.source);
            end;

            cc.history[i].data := IntToStr(history.Count - 1 - i);

            cc.history[i].CountValues := cc.history[i].values[0];
            cc.history[i].confirmation := 1;
          end
        end
        else
          nano_precalculate(nano_keyFromAccount(cc.addr));
    except
      on E: Exception do
      begin
        err := E.message;
      end;
    end;
    calcNanoBalances(NanoCoin(cc));
    if js.TryGetValue<TJSONArray>('pending', pendings) then
      if pendings.Count > 0 then
      begin
        for i := 0 to (pendings.Count div 2) - 1 do
        begin
          try
            temp.block := nano_buildFromJSON(pendings.Items[(i * 2)
              ].GetValue<TJSONObject>('data').GetValue('contents').value, '',
              false, true);
            temp.Hash := pendings.Items[(i * 2) + 1].GetValue<string>('hash');

            if NanoCoin(cc).BlockByLink(temp.Hash).Account <> '' then
            begin

              SetLength(cc.history, Length(cc.history) + 1);
              block := temp.block;
              // cc.unconfirmed := cc.unconfirmed + block.blockAmount;
              SetLength(cc.history[i].values, 2);
              SetLength(cc.history[i].addresses, 2);
              cc.history[i].values[0] := biginteger.abs(block.blockAmount);

              cc.history[i].values[1] := 0;
              // length(hitory.Values) must be the same as length(history.addresses)
              cc.history[i].TransactionID := block.Hash;
              cc.history[i].addresses[0] :=
                nano_accountFromHexKey(block.Account);
              cc.history[i].addresses[1] :=
                nano_accountFromHexKey(block.source);
              cc.history[i].data := IntToStr(history.Count - 1 - i);
              if block.blocktype = 'send' then
              begin
                cc.history[i].typ := 'OUT';
              end
              else
              begin
                cc.history[i].typ := 'IN';
              end;
              cc.history[i].CountValues := cc.history[i].values[0];
              cc.history[i].confirmation := 0;
            end
            else
            begin

              if not currentaccount.firstSync then
                NanoCoin(cc).tryAddPendingBlock(temp);
            end;
          except
            on E: Exception do
            begin
            end;
          end;
        end;
      end;
  except
    on E: Exception do
    begin
      err := E.message;
    end;

  end;
  js.Free;
end;

procedure parseSync(ac : Account ; s: string; verifyKeypool: boolean = false);

  function findWDByAddr(ac : Account ; addr: Integer): TWalletInfo;
  var
    wd: TWalletInfo;
  begin
    result := nil;
    for wd in ac.myCoins do
      if wd.uniq = addr then
        exit(wd);

  end;

var
  JsonArray, ColJsonArray, RowJsonArray: TJsonArray;
  JsonPair: TJSONPair;
  coinJson: TJSONObject;
  i: Integer;
  err: string;
  wd: TWalletInfo;
begin
s:=trim(s);
  if LeftStr(s, 7) = ('Invalid') then
    exit;

  err := '';
  if (s = '[]') or (s = '') then
    exit;
  if (s[Low(s)] = '[') and (s[High(s)] = ']') then
  begin
    Delete(s, Low(s), 1);
    Delete(s, High(s), 1);
  end;

{$IF  DEFINED(ANDROID) }
 s := StringReplace(s, '\\', '\', [rfReplaceAll]);
  {$ENDIF}
  try
   //writeln(s);
    coinJson := TJSONObject.ParseJSONValue(s) as TJSONObject;
    if coinJson<>nil then begin
    if coinJson.Count = 0 then
    begin
      coinJson.Free;
      exit;
    end;

    for i := 0 to coinJson.Count - 1 do
    begin
      wd := nil;
      JsonPair := coinJson.Pairs[i];
      wd := findWDByAddr(ac , JsonPair.JsonValue.GetValue<Int64>('wid'));

      if wd = nil then
        continue;

      if not verifyKeypool then
      begin

        parseBalances(JsonPair.JsonValue.GetValue<string>('balance'), wd);
        try
          parseCoinHistory(JsonPair.JsonValue.GetValue<string>('history'), wd);
        except
          on E: Exception do
          begin
           //writeln('parseSync '+E.Message);
          end;

        end;

        wd.UTXO := parseUTXO(JsonPair.JsonValue.GetValue<string>('utxo'), wd.y);

        if (wd.inPool = True) { or (wd.Y >= changeDelimiter) } then
          wd.inPool :=
            trim(JsonPair.JsonValue.GetValue<string>('history')) = '';

      end
      else
      begin

        if (wd.inPool = True) { or (wd.Y >= changeDelimiter) } then
          wd.inPool :=
            trim(JsonPair.JsonValue.GetValue<string>('history')) = '';

        try
          parseCoinHistory(JsonPair.JsonValue.GetValue<string>('history'), wd);
        except
          on E: Exception do
          begin
          //writeln('parseSync '+E.Message);
          end;

        end;

      end;

    end;

    if coinJson<>nil then coinJson.Free;
   end;

  except
    on E: Exception do
      //writeln('parseSync '+E.Message);
  end;

end;

procedure SynchronizeAll();
var
  i: Integer;
  licz: Integer;
  batched: string;
begin
  try
    currentaccount.AsyncSynchronize;
  except
    on E: Exception do
    begin
    end;
  end;

  currentaccount.firstSync := false;

end;

procedure verifyKeypoolNoThread(ac: Account; wi: TWalletInfo);
var
  wd: TObject;
  url, s: string;
begin
  exit;
  try
    s := keypoolIsUsed(ac, wi.coin);
    klog('386: s=' + s);
    url := HODLER_URL + '/batchSync0.3.2.php?keypool=true&coin=' + availablecoin
      [wi.coin].name;
    if TThread.CurrentThread.CheckTerminated then
      exit();
    s := postDataOverHTTP(url, s, false, true);
    klog('392: s=' + s);
    parseSync(ac, s, true);

  except
    on E: Exception do
    begin

    end;
  end;

end;

procedure SynchronizeCryptoCurrency(ac: Account; cc: cryptoCurrency);
var
  data, url, s, err: string;
begin

  /// ////////////////HISTORY//////////////////////////
  if cc is TWalletInfo then
  begin

    case TWalletInfo(cc).coin of
      { 0, 2, 3, } 5, 6:
        begin
          url := HODLER_URL + '/batchSync0.3.2.php?coin=' + availablecoin
            [TWalletInfo(cc).coin].name;
          s := postDataOverHTTP(url, batchSync(ac, TWalletInfo(cc).coin,
            TWalletInfo(cc).X), false, true);
          if TThread.CurrentThread.CheckTerminated then
            exit();
          parseSync(ac, s);
        end;
      0, 1, 2, 3, 7:
        begin
          try
            syncWithENetwork(ac, TWalletInfo(cc).coin);
          except
            on E: Exception do
            begin

              err := (E.message);
              err := lowercase(E.message);
            end;

          end;
        end;
      4:
        begin
          data := getDataOverHTTP(HODLER_URL + 'getHistory.php?coin=' +
            availablecoin[TWalletInfo(cc).coin].name + '&address=' +
            TWalletInfo(cc).addr);

          if TThread.CurrentThread.CheckTerminated then
            exit();

          parseETHHistory(data, TWalletInfo(cc));
        end;
      8:
        begin

          data := getDataOverHTTP('https://hodlernode.net/nano.php?addr=' +
            TWalletInfo(cc).addr, false, true);
          if TThread.CurrentThread.CheckTerminated then
            exit();
          if data <> '' then
            syncNano(cc, data);

        end;
    end;

  end
  else
  begin

    if Token(cc).lastBlock = 0 then
      Token(cc).lastBlock := getHighestBlockNumber(Token(cc));

    data := getDataOverHTTP(HODLER_ETH + '/?cmd=tokenHistory&addr=' + Token(cc)
      .addr + '&contract=' + Token(cc).ContractAddress + '&bno=' +
      IntToStr(Token(cc).lastBlock));

    if TThread.CurrentThread.CheckTerminated then
      exit();

    parseTokenHistory(data, Token(cc));

  end;

  /// ///////////// BALANCE //////////////////
  if Length(cc.history) = 0 then
  begin
    if cc is TWalletInfo then
    begin

      case TWalletInfo(cc).coin of

        4:
          begin
            data := getDataOverHTTP(HODLER_ETH + '/?cmd=accInfo&addr=' +
              TWalletInfo(cc).addr);

            if TThread.CurrentThread.CheckTerminated then
              exit();

            parseDataForETH(data, TWalletInfo(cc));
          end
      end;

    end
    else if cc is Token then
    begin
      data := getDataOverHTTP(HODLER_ETH + '/?cmd=tokenInfo&addr=' + cc.addr +
        '&contract=' + Token(cc).ContractAddress);

      if TThread.CurrentThread.CheckTerminated then
        exit();

      if Token(cc).lastBlock = 0 then
        Token(cc).lastBlock := getHighestBlockNumber(Token(cc));

      { TThread.Synchronize(nil,
        procedure
        begin
        frmHome.RefreshProgressBar.value := 30;
        end); }

      parseDataForERC20(data, Token(cc));
    end
    else
    begin
      // raise exception.Create('CryptoCurrency Type Error');
    end;

    exit();

  end;

  if cc is TWalletInfo then
  begin

    case TWalletInfo(cc).coin of

      4:
        begin
          data := getDataOverHTTP(HODLER_ETH + '/?cmd=accInfo&addr=' +
            TWalletInfo(cc).addr);

          if TThread.CurrentThread.CheckTerminated then
            exit();

          parseDataForETH(data, TWalletInfo(cc));
        end
    end;

  end
  else if cc is Token then
  begin
    data := getDataOverHTTP(HODLER_ETH + '/?cmd=tokenInfo&addr=' + cc.addr +
      '&contract=' + Token(cc).ContractAddress);

    if TThread.CurrentThread.CheckTerminated then
      exit();

    if Token(cc).lastBlock = 0 then
      Token(cc).lastBlock := getHighestBlockNumber(Token(cc));

    { TThread.Synchronize(nil,
      procedure
      begin
      frmHome.RefreshProgressBar.value := 30;
      end); }

    parseDataForERC20(data, Token(cc));
  end
  else
  begin
    // raise exception.Create('CryptoCurrency Type Error');
  end;

end;

{ function SynchronizeHistoryThread.TimeFromStart;
  begin
  result := 0;
  if startTime > endTime then
  result := startTime - now;
  end;

  constructor SynchronizeHistoryThread.Create;
  begin
  inherited Create(false);

  startTime := now;
  endTime := now;

  end;

  procedure SynchronizeHistoryThread.Execute();
  begin

  inherited;

  startTime := now;

  with frmHome do
  begin



  end;

  endTime := now;
  end; }

function SynchronizeBalanceThread.TimeFromStart;
begin
  result := 0;
  if startTime > endTime then
    result := startTime - now;
end;

constructor SynchronizeBalanceThread.Create;
begin
  inherited Create(false);

  startTime := now;
  endTime := now;

end;

procedure SynchronizeBalanceThread.Execute();
var
  dataTemp: AnsiString;
begin

  inherited;

  // frmHome.DashBrdProgressBar.value := 0;
  // frmHome.RefreshProgressBar.value := 0;

  startTime := now;

  with frmHome do
  begin

    if TThread.CurrentThread.CheckTerminated then
      exit();

    TThread.Synchronize(nil,
      procedure
      begin
        frmHome.Caption := 'xxx';


        // RefreshWalletView.Enabled := false;
        // RefreshProgressBar.Visible := True;
        // btnSync.Enabled := false;
        // DashBrdProgressBar.Visible := True;

        // btnSync.Repaint();

      end);

    // refreshGlobalImage.Start;

    currentaccount.AsyncSynchronize();

    try
      // SynchronizeAll();
    except
      on E: Exception do
      begin
      end;
    end;
    // synchronizeAddresses;

    refreshGlobalFiat();

    refreshGlobalImage.Stop();

    if TThread.CurrentThread.CheckTerminated then
      exit();

    TThread.Synchronize(TThread.CurrentThread,
      procedure
      begin
        repaintWalletList;
      end);

    TThread.Synchronize(TThread.CurrentThread,
      procedure
      begin
        if PageControl.ActiveTab = walletView then
        begin
          try
            reloadWalletView;
          except
            on E: Exception do
          end;



          // createHistoryList( CurrentCryptoCurrency );

        end;
      end);

    TThread.Synchronize(TThread.CurrentThread,
      procedure
      begin

        TLabel(frmHome.FindComponent('globalBalance')).text :=
          FloatToStrF(currencyConverter.calculate(globalFiat), ffFixed, 9, 2);
        TLabel(frmHome.FindComponent('globalCurrency')).text := '         ' +
          currencyConverter.symbol;

        { RefreshWalletView.Enabled := True;
          RefreshProgressBar.Visible := false;
          btnSync.Enabled := True;
          DashBrdProgressBar.Visible := false; }

        // btnSync.Repaint();

        // DebugRefreshTime.text := 'last refresh: ' +
        // Formatdatetime('dd mmm yyyy hh:mm:ss', now);

        // txHistory.Enabled := true;
        // txHistory.EndUpdate;
        hideEmptyWallets(nil);

      end);

  end;

  endTime := now;
end;

procedure parseTokenHistory(text: AnsiString; T: Token);
var
  ts: TStringList;
  i: Integer;
  number: Integer;
  transHist: TransactionHistory;
  j: Integer;
  sum: biginteger;
  tempts: TStringList;
begin
  sum := 0;
  if text = '' then
    exit;

  ts := TStringList.Create();
  try
    ts.text := text;

    if ts.Count = 1 then
    begin
      T.lastBlock := strToIntdef(ts.Strings[0], 0);
      exit();
    end;
    i := 0;

    SetLength(T.history, 0);

    while (i < ts.Count - 1) do
    begin
      number := strToIntdef(ts.Strings[i], 0);
      inc(i);
      // showmessage(inttostr(number));

      transHist.typ := ts.Strings[i];
      inc(i);

      transHist.TransactionID := ts.Strings[i];
      inc(i);

      transHist.lastBlock := StrToInt64Def(ts.Strings[i], 0);
      inc(i);

      tempts := SplitString(ts[i]);
      transHist.data := tempts.Strings[0];
      transHist.confirmation := strToIntdef(tempts[1], 0);
      tempts.Free;
      inc(i);

      SetLength(transHist.addresses, number);
      SetLength(transHist.values, number);

      sum := 0;

      for j := 0 to number - 1 do
      begin
        transHist.addresses[j] := '0x' + rightStr(ts.Strings[i], 40);
        inc(i);

        biginteger.TryParse(ts.Strings[i], transHist.values[j]);
        inc(i);

        sum := sum + transHist.values[j];
      end;

      // showmessage( inttostr(number) );

      transHist.CountValues := sum;

      SetLength(T.history, Length(T.history) + 1);
      T.history[Length(T.history) - 1] := transHist;

    end;
    // ts.Free;
  except
    on E: Exception do
    begin
    end;

  end;
  if ts <> nil then
    ts.Free

end;

procedure parseETHHistory(text: AnsiString; wallet: TWalletInfo);
var
  ts: TStringList;
  i, j, number: Integer;
  transHist: TransactionHistory;
  sum: biginteger;
  tempts: TStringList;
begin

  sum := 0;

  ts := TStringList.Create();
  try
    ts.text := text;

    SetLength(wallet.history, 0);

    /// ////////

    i := 0;

    while (i < ts.Count - 1) do
    begin
      number := strToIntdef(ts.Strings[i], 0);
      inc(i);
      // showmessage(inttostr(number));

      transHist.typ := ts.Strings[i];
      inc(i);

      transHist.TransactionID := ts.Strings[i];
      inc(i);

      transHist.lastBlock := StrToInt64Def(ts.Strings[i], 0);
      inc(i);

      tempts := SplitString(ts[i]);
      transHist.data := tempts.Strings[0];
      transHist.confirmation := strToIntdef(tempts[1], 0);
      tempts.Free;
      inc(i);

      SetLength(transHist.addresses, number);
      SetLength(transHist.values, number);
      sum := 0;
      for j := 0 to number - 1 do
      begin
        transHist.addresses[j] := '0x' + rightStr(ts.Strings[i], 40);
        inc(i);

        biginteger.TryParse(ts.Strings[i], transHist.values[j]);
        inc(i);

        sum := sum + transHist.values[j];
      end;

      // showmessage( inttostr(number) );

      transHist.CountValues := sum;

      SetLength(wallet.history, Length(wallet.history) + 1);
      wallet.history[Length(wallet.history) - 1] := transHist;

    end;

    /// ////////

  except
    on E: Exception do
    begin

    end;

  end;
  ts.Free();

end;

function segwitParameters(wi: TWalletInfo): AnsiString;
var
  segwit, compatible, legacy: AnsiString;
begin
  segwit := generatep2wpkh(wi.pub, availablecoin[wi.coin].hrp);
  compatible := generatep2sh(wi.pub, availablecoin[wi.coin].p2sh);
  legacy := generatep2pkh(wi.pub, availablecoin[wi.coin].p2pk);
  if wi.coin in [0, 1] then
  begin
    result := '&segwit=' + segwit + '&segwithash=' + decodeAddressInfo(segwit,
      wi.coin).scriptHash;
  end
  else
    result := '&segwit=' + '0' + '&segwithash=' + '0';
  result := result + '&compatible=' + compatible + '&compatiblehash=' +
    decodeAddressInfo(compatible, wi.coin).scriptHash + '&legacy=' + legacy;

end;

procedure parseBalances(s: AnsiString; var wd: TWalletInfo);
var
  ts: TStringList;
  i: Integer;
  bc: Integer;
begin

  ts := TStringList.Create;
  ts.text := s;
  try

    wd.confirmed := ts.Strings[0];
    wd.unconfirmed := (ts.Strings[1]);
    wd.fiat := ts.Strings[2];
    // globalFiat := globalFiat + StrToFloatDef(wd.fiat, 0);
    wd.efee[0] := ts.Strings[3];
    wd.efee[1] := ts.Strings[4];
    wd.efee[2] := ts.Strings[5];
    wd.efee[3] := ts.Strings[6];
    wd.efee[4] := ts.Strings[7];
    wd.efee[5] := ts.Strings[8];

    wd.rate := StrToFloatDef(ts.Strings[9], 0);

  except
    on E: Exception do
    begin
    end;
  end;

  ts.Free;
end;

procedure parseDataForETH(s: AnsiString; { var } wd: TWalletInfo);
var
  ts: TStringList;
  i: Integer;
  bc: Integer;
begin

  ts := TStringList.Create;
  ts.text := s;
  try

    wd.efee[0] := ts.Strings[0];
    // floattostrF(strtointdef(ts.Strings[0],11000000000) /1000000000000000000,ffFixed,18,18);
    wd.confirmed := biginteger.Parse(ts.Strings[1]);
    // floattostrF(strtoint64def(ts.Strings[1],-1) /1000000000000000000,ffFixed,18,18);
    wd.unconfirmed := '0';
    wd.nonce := strToIntdef(ts.Strings[2], 0);
    wd.fiat := ts.Strings[3];
    // globalFiat := globalFiat + StrToFloatDef(wd.fiat, 0);
    wd.rate := StrToFloatDef(ts.Strings[4], 0);

  except
    on E: Exception do

  end;

  ts.Free;
end;

procedure parseDataForERC20(s: string; var wd: Token);
var
  ts: TStringList;
  i: Integer;
  bc: Integer;
begin
  if LeftStr(s, 7) = 'Invalid' then
    exit;

  ts := TStringList.Create;
  ts.text := s;
  try

    // wd.efee[0]:=ts.Strings[0];//floattostrF(strtointdef(ts.Strings[0],11000000000) /1000000000000000000,ffFixed,18,18);
    wd.confirmed := biginteger.Parse(ts.Strings[1]);
    if (wd.id < 10000) or (not Token.AvailableToken[wd.id - 10000].stableCoin)
    then
      wd.rate := StrToFloatDef(ts[2], 0)
    else
      wd.rate := Token.AvailableToken[wd.id - 10000].stableValue;
    // floattostrF(strtoint64def(ts.Strings[1],-1) /1000000000000000000,ffFixed,18,18);
    wd.unconfirmed := '0';
    // wd.nonce:=strtointdef(ts.Strings[2],0);
    // wd.fiat := ts.Strings[3];
    // globalFiat := globalFiat + StrToFloatDef(wd.fiat, 0);

  except
    on E: Exception do

  end;

  ts.Free;
end;

{ function isOurAddress(adr: string; coinid: Integer): boolean;
  var
  twi: TWalletInfo;
  var
  segwit, cash, compatible, legacy: AnsiString;
  pub: AnsiString;
  begin

  result := false;

  adr := lowercase(StringReplace(adr, 'bitcoincash:', '', [rfReplaceAll]));

  for twi in CurrentAccount.myCoins do
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
  end; }

function checkTxType(tx: TxHistoryResult; coinid: Integer): Integer;
var
  ourInputs, ourOutputs: Integer;
  i: Integer;
begin

  result := 0;
  ourInputs := 0;
  ourOutputs := 0;

  for i := 0 to strToIntdef(tx.inputsCount, 0) - 1 do

    if currentaccount.isOurAddress(tx.inputAddresses[i], coinid) then
      inc(ourInputs);

  for i := 0 to strToIntdef(tx.outputsCount, 0) - 1 do
    if currentaccount.isOurAddress(tx.outputs[i].address, coinid) then
      inc(ourOutputs);

  if (ourInputs >= 1) and (ourOutputs = 0) then
    exit(0); // outgoing
  if (ourInputs >= 1) and (ourOutputs = 1) and
    (strToIntdef(tx.outputsCount, 0) > 1) then
    exit(0); // outgoing
  if (ourInputs >= 1) and (strToIntdef(tx.outputsCount, 0) = ourOutputs) then
    exit(2); // internal\
  if (ourInputs = 0) and (ourOutputs >= 1) then
    exit(1); // incoming

end;

procedure parseCoinHistory(text: AnsiString; wallet: TWalletInfo);
var
  ts: TStringList;
  i: Integer;
  number: Integer;
  transHist: TransactionHistory;
  j: Integer;
  sum: biginteger;
  tempts: TStringList;
  parsedTx: array of TxHistoryResult;
  // ====
  idx: Integer;
  entry, txIndex: Integer;
begin
  SetLength(parsedTx, 0);
  ts := TStringList.Create();

  ts.text := text;
  if ts.Count < 6 then
  begin
    ts.Free;
    exit;
  end;
  entry := 0;
  txIndex := 0;
  SetLength(parsedTx, txIndex + 1);
  repeat
    if TThread.CurrentThread.CheckTerminated then
      exit();

    parsedTx[txIndex].inputsCount := ts.Strings[entry + 2];
    parsedTx[txIndex].txId := ts.Strings[entry + 1];
    parsedTx[txIndex].outputsCount := ts.Strings[entry + 0];
    idx := 4 + strToIntdef(parsedTx[txIndex].inputsCount, 0);
    parsedTx[txIndex].timestamp := ts.Strings[entry + idx - 1];
    SetLength(parsedTx[txIndex].outputs,
      strToIntdef(parsedTx[txIndex].outputsCount, 0));
    SetLength(parsedTx[txIndex].inputAddresses,
      strToIntdef(parsedTx[txIndex].inputsCount, 0));

    for i := 0 to strToIntdef(parsedTx[txIndex].inputsCount, 0) - 1 do
    begin

      parsedTx[txIndex].inputAddresses[i] := ts.Strings[entry + 3 + i];

    end;

    for i := 0 to strToIntdef(parsedTx[txIndex].outputsCount, 0) - 1 do
    begin
      parsedTx[txIndex].outputs[i].address := ts.Strings[entry + idx + (i * 2)];
      parsedTx[txIndex].outputs[i].value :=
        ts.Strings[entry + idx + 1 + (i * 2)];

    end;

    entry := entry + (strToIntdef(parsedTx[txIndex].outputsCount, 0) * 2) +
      strToIntdef(parsedTx[txIndex].inputsCount, 0) + 4;
    inc(txIndex);
    SetLength(parsedTx, txIndex + 1);
  until (entry >= (ts.Count - 1));
  SetLength(parsedTx, txIndex);
  i := 0;
  SetLength(wallet.history, 0);

  for i := 0 to txIndex - 1 do
  begin
    case checkTxType(parsedTx[i], wallet.coin) of
      0:
        transHist.typ := 'OUT';
      1:
        transHist.typ := 'IN';
      2:
        transHist.typ := 'INTERNAL';
    end;
    sum := 0;
    transHist.TransactionID := parsedTx[i].txId;
    tempts := SplitString(parsedTx[i].timestamp);
    transHist.data := tempts.Strings[0];
    transHist.confirmation := strToIntdef(tempts[1], 0);
    tempts.Free;
    SetLength(transHist.addresses, strToIntdef(parsedTx[i].outputsCount, 0));
    SetLength(transHist.values, strToIntdef(parsedTx[i].outputsCount, 0));
    for j := 0 to strToIntdef(parsedTx[i].outputsCount, 0) - 1 do
    begin
      transHist.addresses[j] := parsedTx[i].outputs[j].address;
      if wallet.coin = 7 then
      begin

        if ContainsStr(transHist.addresses[j], ':') then
        begin
          transHist.addresses[j] := rightStr(transHist.addresses[j],
            Length(transHist.addresses[j]) - pos(':', transHist.addresses[j]));
        end;

      end;

      if (transHist.typ = 'OUT') then
      begin

        if (currentaccount.isOurAddress(parsedTx[i].outputs[j].address,
          wallet.coin) = true) then
          transHist.values[j] := StrFloatToBigInteger('0.000000',
            availablecoin[wallet.coin].decimals)
        else
          transHist.values[j] := StrFloatToBigInteger
            (parsedTx[i].outputs[j].value, availablecoin[wallet.coin].decimals);

        sum := sum + transHist.values[j];

      end;

      if (transHist.typ = 'IN') or (transHist.typ = 'INTERNAL') then
      begin

        if not(currentaccount.isOurAddress(parsedTx[i].outputs[j].address,
          wallet.coin) = true) then
          transHist.values[j] := StrFloatToBigInteger('0.000000',
            availablecoin[wallet.coin].decimals)
        else
          transHist.values[j] := StrFloatToBigInteger
            (parsedTx[i].outputs[j].value, availablecoin[wallet.coin].decimals);

        sum := sum + transHist.values[j];

      end;
    end;
    transHist.CountValues := sum;
    SetLength(wallet.history, Length(wallet.history) + 1);
    wallet.history[Length(wallet.history) - 1] := transHist;

  end;

  ts.Free;
end;

end.

