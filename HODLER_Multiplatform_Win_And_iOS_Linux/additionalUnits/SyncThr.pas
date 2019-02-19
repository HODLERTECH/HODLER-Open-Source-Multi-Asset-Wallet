unit SyncThr;

interface

uses
  System.classes, System.sysutils, FMX.Controls, FMX.StdCtrls, FMX.dialogs,
  StrUtils, WalletStructureData, CryptoCurrencyData, tokenData, System.SyncObjs,


  JSON, System.TimeSpan, System.Diagnostics, Nano{$IFDEF MSWINDOWS},Winapi.ShellAPI,Winapi.Windows{$ENDIF};

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

procedure parseDataForETH(s: AnsiString; { var } wd: TWalletInfo);

procedure parseCoinHistory(text: AnsiString; wallet: TWalletInfo);

procedure parseTokenHistory(text: AnsiString; T: Token);

function segwitParameters(wi: TWalletInfo): AnsiString;

procedure SynchronizeCryptoCurrency(cc: cryptoCurrency);

procedure parseBalances(s: AnsiString; var wd: TWalletInfo);

procedure parseETHHistory(text: AnsiString; wallet: TWalletInfo);

procedure SynchronizeAll();

procedure parseDataForERC20(s: string; var wd: Token);

function batchSync(var coinid: Integer; X: Integer = -1): string;

procedure verifyKeypool();

procedure verifyKeypoolNoThread(wi: TWalletInfo);

var
  semaphore: TLightweightSemaphore;
  VerifyKeypoolSemaphore : TLightweightSemaphore;
  mutex: TSemaphore;

implementation

uses
  uhome, misc, coinData, Velthuis.BigIntegers, Bitcoin, WalletViewRelated,
  keyPoolRelated;

function prepareBatch(wi: TWalletInfo; i: string): string;
var
  segwit, compatible, legacy: AnsiString;
begin
  segwit := generatep2wpkh(wi.pub, availablecoin[wi.coin].hrp);
  compatible := generatep2sh(wi.pub, availablecoin[wi.coin].p2sh);
  legacy := generatep2pkh(wi.pub, availablecoin[wi.coin].p2pk);
  if wi.coin in [0, 1] then
  begin
    result := '&wallet[][compatible]=' + compatible + '&wallet[][compatiblehash]=' + decodeAddressInfo(compatible, wi.coin).scriptHash + '&wallet[][segwit]=' + segwit + '&wallet[][segwithash]=' + decodeAddressInfo(segwit, wi.coin).scriptHash;
  end
  else
    result := '&wallet[][compatible]=' + compatible + '&wallet[][compatiblehash]=' + decodeAddressInfo(compatible, wi.coin).scriptHash + '&wallet[][segwit]=0&wallet[][segwithash]=0';
  result := result + '&wallet[][legacy]=' + legacy;

  result := StringReplace(result, '[]', '[' + IntToStr(abs(wi.uniq)) + ']', [rfReplaceAll]);
end;

function batchSync(var coinid: Integer; X: Integer = -1): string;
var
  wi: TWalletInfo;
  i: Integer;
begin
  i := 0;

  result := 'coin=' + availablecoin[coinid].name;
  for wi in CurrentAccount.myCoins do
  begin
    if (wi.coin = coinid) then
    begin
      wi.uniq := abs((coinid * 1000) + StrToInt64Def('$' + Copy(GetStrHashSHA256(CurrentAccount.name), 0, 5), 0) + i); // moreUniq
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
    Inc(i);
  end;
end;

function keypoolIsUsed(var coinid: Integer; X: Integer = -1): string;
var
  wi: TWalletInfo;
  i: Integer;
begin
  i := 0;

  result := 'coin=' + availablecoin[coinid].name;
  for wi in CurrentAccount.myCoins do
  begin
    if (wi.coin = coinid) and ((wi.inPool = True) or (wi.Y >= changeDelimiter)) then
    begin
      wi.uniq := abs((coinid * 1000) + StrToInt64Def('$' + Copy(GetStrHashSHA256(CurrentAccount.name), 0, 5), 0) + i); // moreUniq

      if (X <> -1) then
      begin
        if wi.X = X then
          result := result + prepareBatch(wi, wi.addr)
      end
      else
        result := result + prepareBatch(wi, wi.addr);
    end;
    Inc(i);
  end;
end;

procedure syncNano(var cc: cryptoCurrency; data: AnsiString);
var
  js: TJSONObject;
  newblock: string;
  block, firstblock: TNanoBlock;
  history: TJsonArray;
  ts: TStringList;
  i: integer;
  masterseed, tced: ansistring;

  pendings: TJsonArray;
  temp : TpendingNanoBlock;
begin
 {$IFDEF MSWINDOWS}
  if TOSVersion.Architecture=arIntelX64 then
  ShellExecute(0,'open','NanoPoW64.exe','',PWideChar(ExtractFileDir(ParamStr(0))),SW_HIDE) else
  ShellExecute(0,'open','NanoPoW32.exe','',PWideChar(ExtractFileDir(ParamStr(0))),SW_HIDE);
 {$ENDIF}
  try

    js := TJSONObject.ParseJSONValue(data) as TJSONObject;
    cc.rate := StrToFloatDef(js.GetValue('price').Value, 0.0);
    cc.confirmed := BigInteger.Parse(js.GetValue('balance').GetValue < string > ('balance'));
    cc.unconfirmed := BigInteger.Parse(js.GetValue('balance').GetValue < string > ('pending'));
    //{history := }js.TryGetValue<TJSONArray>('history' , history) {as TJSONArray};
    //{pendings :=} js.tryGetValue<TJsonArray>('pending' , pendings) {as TJsonArray};

    if (Length(NanoCoin(cc).pendingChain)>0) then
    NanoCoin(cc).lastBlockAmount:=BigInteger.Parse(NanoCoin(cc).curBlock.balance) else
    NanoCoin(cc).lastBlockAmount:=cc.confirmed;
    cc.confirmed:=NanoCoin(cc).lastBlockAmount;

	
    if js.TryGetValue<TJSONArray>('history' , history)  then
      if history.Count > 0 then
      begin

        firstblock := nano_buildFromJSON(history.Items[0].ToJSON, '', false);
        cc.lastPendingBlock := firstblock.hash;
        //nano_precalculate(cc.lastPendingBlock);
        SetLength(cc.history, history.count);
        for i := 0 to history.Count - 1 do
        begin

          block := nano_buildFromJSON(history.Items[i].ToJSON, '', false);





          SetLength(cc.history[i].values, 2);
          SetLength(cc.history[i].addresses, 2);
          cc.history[i].values[0] := BigInteger.Abs(block.blockAmount);
          cc.history[i].values[1] := 0; // length(hitory.Values) must be the same as length(history.addresses)
          cc.history[i].TransactionID := block.Hash;
          cc.history[i].addresses[0] := nano_accountFromHexKey(block.account);
          cc.history[i].addresses[1] := nano_accountFromHexKey(block.source);
          cc.history[i].data := IntToStr(history.Count - 1 - i);
          if block.blocktype = 'send' then
            cc.history[i].typ := 'OUT'
          else
            cc.history[i].typ := 'IN';
          cc.history[i].CountValues := cc.history[i].values[0];
          cc.history[i].confirmation := 1;
        end;
      end;

      if js.tryGetValue<TJsonArray>('pending' , pendings ) then
      if pendings.Count > 0 then
      begin
        for i := 0 to (pendings.Count div 2) - 1 do
        begin

          temp.Block := nano_buildFromJSON(pendings.Items[(i * 2)].GetValue < TjsonObject > ('data').GetValue('contents').Value, '');
          temp.Hash := pendings.Items[(i * 2) + 1].GetValue < Ansistring > ('hash');
          if NanoCoin(cc).BlockByLink(temp.Hash).account<>'' then
          begin
           cc.unconfirmed:=cc.unconfirmed-temp.Block.blockAmount;
          end else begin

          if not firstSync then
          NanoCoin(cc).tryAddPendingBlock(temp);
          end;
        end;
      end;
  except
    on e: exception do
    begin
    end;

  end;
  js.Free;
end;

procedure parseSync(s: string; verifyKeypool: boolean = false);

  function findWDByAddr(addr: Integer): TWalletInfo;
  var
    wd: TWalletInfo;
  begin
    result := nil;
    for wd in CurrentAccount.myCoins do
      if wd.uniq = addr then
        Exit(wd);

  end;

var
  JsonArray, ColJsonArray, RowJsonArray: TJSONArray;
  JsonPair: TJSONPair;
  coinJson: TJSONObject;
  i: Integer;
  err: string;
  wd: TWalletInfo;
begin
  err := '';
  if (s = '[]') or (s = '') then
    Exit;
  if (s[Low(s)] = '[') and (s[High(s)] = ']') then
  begin
    Delete(s, Low(s), 1);
    Delete(s, High(s), 1);
  end;
{$IFDEF  ANDROID}     s := StringReplace(s, '\\', '\', [rfReplaceAll]); {$ENDIF}
  try

    coinJson := TJSONObject.ParseJSONValue(s) as TJSONObject;

    if coinJson.Count = 0 then
      Exit;
    for i := 0 to coinJson.Count - 1 do
    begin
      if SyncBalanceThr <> nil then
        if SyncBalanceThr.Terminated then
          Exit();

      wd := nil;
      JsonPair := coinJson.Pairs[i];
      wd := findWDByAddr(JsonPair.JsonValue.GetValue<Int64>('wid'));
      if wd = nil then
        continue;
      if not verifyKeypool then
      begin

        parseBalances(JsonPair.JsonValue.GetValue<string>('balance'), wd);
        try
          parseCoinHistory(JsonPair.JsonValue.GetValue<string>('history'), wd);
        except
          on e: Exception do
          begin
          end;

        end;
        wd.UTXO := parseUTXO(JsonPair.JsonValue.GetValue<string>('utxo'), wd.Y);
        if (wd.inPool = True) {or (wd.Y >= changeDelimiter)} then
          wd.inPool := trim(JsonPair.JsonValue.GetValue<string>('history')) = '';
      end
      else
      begin
        if (wd.inPool = True) {or (wd.Y >= changeDelimiter)} then
          wd.inPool := trim(JsonPair.JsonValue.GetValue<string>('history')) = '';
        try
          parseCoinHistory(JsonPair.JsonValue.GetValue<string>('history'), wd);
        except
          on e: Exception do
          begin
          end;

        end;
      end;
    end;

  except
    on e: Exception do
      err := (e.Message);
  end;

end;

procedure SynchronizeAll();
var
  i: Integer;
  licz: Integer;
  batched: string;
begin

  globalLoadCacheTime := 0;
  if semaphore = nil then
  begin
    semaphore := TLightweightSemaphore.Create(8);
  end;
  if mutex = nil then
  begin
    mutex := TSemaphore.Create();
  end;

  TThread.Synchronize(TThread.CurrentThread,
    procedure
    begin
      frmHome.DashBrdProgressBar.Max := length(CurrentAccount.myCoins) + length(CurrentAccount.myTokens);
      frmHome.DashBrdProgressBar.value := 0;
    end);

  for i in [0, 1, 2, 3, 4, 5, 6, 7] do
  begin
    if TThread.CurrentThread.CheckTerminated then
      Exit();
    mutex.Acquire();

    TThread.CurrentThread.CreateAnonymousThread(
      procedure
      var
        id: Integer;
        wi: TWalletInfo;
        wd: TObject;
        url, s: string;

      begin

        id := i;
        mutex.Release();

        semaphore.WaitFor();
        try
          if id in [4, 8] then
          begin
            for wi in CurrentAccount.myCoins do
              if wi.coin in [4, 8] then
                SynchronizeCryptoCurrency(wi);

          end
          else
          begin
            s := batchSync(id);
            url := HODLER_URL + '/batchSync0.3.2.php?coin=' + availablecoin[id].name;
            if TThread.CurrentThread.CheckTerminated then
              Exit();
            parseSync(postDataOverHTTP(url, s, firstSync, True));
          end;
          TThread.CurrentThread.Synchronize(nil,
            procedure
            begin

              updateBalanceLabels;
            end);
        except
          on e: Exception do
          begin

          end;
        end;
        semaphore.Release();

        TThread.CurrentThread.Synchronize(nil,
          procedure
          begin
            frmHome.DashBrdProgressBar.value := frmHome.RefreshProgressBar.value + 1;
          end);

      end).Start();

    mutex.Acquire();
    mutex.Release();

  end;
  for i := 0 to length(CurrentAccount.myTokens) - 1 do
  begin

    mutex.Acquire();

    TThread.CurrentThread.CreateAnonymousThread(
      procedure
      var
        id: Integer;
      begin

        id := i;
        mutex.Release();

        semaphore.WaitFor();
        try
          if TThread.CurrentThread.CheckTerminated then
            Exit();
          SynchronizeCryptoCurrency(CurrentAccount.myTokens[id]);
        except
          on e: Exception do
          begin
          end;
        end;
        semaphore.Release();

        TThread.CurrentThread.Synchronize(nil,
          procedure
          begin
            frmHome.DashBrdProgressBar.value := frmHome.RefreshProgressBar.value + 1;
          end);

      end).Start();

    mutex.Acquire();
    mutex.Release();

  end;

  while semaphore.CurrentCount <> 8 do
  begin
    if TThread.CurrentThread.CheckTerminated then
      Exit();
    sleep(50);
  end;
  {tthread.Synchronize(nil , procedure
  begin
    showmessage( floatToStr( globalLoadCacheTime ) );
  end); }

  CurrentAccount.SaveFiles();
  firstSync := false;

end;

procedure verifyKeypoolNoThread(wi: TWalletInfo);
var
  wd: TObject;
  url, s: string;
begin
  try
    s := keypoolIsUsed(wi.coin);
    klog('386: s=' + s);
    url := HODLER_URL + '/batchSync0.3.2.php?keypool=true&coin=' + availablecoin[wi.coin].name;
    if TThread.CurrentThread.CheckTerminated then
      Exit();
    s := postDataOverHTTP(url, s, false, True);
    klog('392: s=' + s);
    parseSync(s, True);

  except
    on e: Exception do
    begin

    end;
  end;

end;

procedure verifyKeypool();
var
  i: Integer;
  licz: Integer;
  batched: string;
var
  Stopwatch: TStopwatch;
  Elapsed: TTimeSpan;
begin
  if VerifyKeypoolSemaphore = nil then
  begin
    VerifyKeypoolSemaphore := TLightweightSemaphore.Create(8);
  end;
  if mutex = nil then
  begin
    mutex := TSemaphore.Create();
  end;

  for i in [0, 1, 2, 3, 4, 5, 6, 7] do
  begin
    if TThread.CurrentThread.CheckTerminated then
      Exit();
    mutex.Acquire();

    TThread.CurrentThread.CreateAnonymousThread(
      procedure
      var
        id: Integer;
        wi: TWalletInfo;
        wd: TObject;
        url, s: string;

      begin
        Stopwatch := TStopwatch.StartNew;
        id := i;
        mutex.Release();

        VerifyKeypoolSemaphore.WaitFor();
        try
          s := keypoolIsUsed(id);
          url := HODLER_URL + '/batchSync0.3.2.php?keypool=true&coin=' + availablecoin[id].name;
          if TThread.CurrentThread.CheckTerminated then
            Exit();
          parseSync(postDataOverHTTP(url, s, false, True), True);

        except
          on e: Exception do
          begin

          end;
        end;
        VerifyKeypoolSemaphore.Release();

        Elapsed := Stopwatch.Elapsed;
        globalVerifyKeypoolTime := globalLoadCacheTime + Elapsed.TotalSeconds;

      end).Start();
    mutex.Acquire();
    mutex.Release();

  end;

  while VerifyKeypoolSemaphore.CurrentCount <> 8 do
  begin
    if TThread.CurrentThread.CheckTerminated then
      Exit();
    sleep(50);
  end;

  CurrentAccount.SaveFiles();

  {tthread.Synchronize(nil , procedure
  begin
    showmessage( floatToStr(globalVerifyKeypoolTime ) );
  end); }

end;

procedure SynchronizeCryptoCurrency(cc: cryptoCurrency);
var
  data, url: string;
begin

  /// ////////////////HISTORY//////////////////////////
  if cc is TWalletInfo then
  begin

    case TWalletInfo(cc).coin of
      0, 1, 2, 3, 5, 6, 7:
        begin
          url := HODLER_URL + '/batchSync0.3.2.php?coin=' + availablecoin[TWalletInfo(cc).coin].name;
          parseSync(postDataOverHTTP(url, batchSync(TWalletInfo(cc).coin, TWalletInfo(cc).X), false, True));
        end;
      4:
        begin
          data := getDataOverHTTP(HODLER_URL + 'getHistory.php?coin=' + availablecoin[TWalletInfo(cc).coin].name + '&address=' + TWalletInfo(cc).addr);

          if TThread.CurrentThread.CheckTerminated then
            Exit();

          parseETHHistory(data, TWalletInfo(cc));
        end;
      8:
        begin
		
          data := getDataOverHTTP('https://hodlernode.net/nano.php?addr=' + TWalletInfo(cc).addr, false , true);
          if data <> '' then
            syncNano(cc, data);
			

        end;
    end;

  end
  else
  begin

    if Token(cc).lastBlock = 0 then
      Token(cc).lastBlock := getHighestBlockNumber(Token(cc));

    data := getDataOverHTTP(HODLER_ETH + '/?cmd=tokenHistory&addr=' + Token(cc).addr + '&contract=' + Token(cc).ContractAddress + '&bno=' + IntToStr(Token(cc).lastBlock));

    if TThread.CurrentThread.CheckTerminated then
      Exit();

    parseTokenHistory(data, Token(cc));

  end;

  /// ///////////// BALANCE //////////////////
  if length(cc.history) = 0 then
  begin
    if cc is TWalletInfo then
    begin

      case TWalletInfo(cc).coin of

        4:
          begin
            data := getDataOverHTTP(HODLER_ETH + '/?cmd=accInfo&addr=' + TWalletInfo(cc).addr);

            if TThread.CurrentThread.CheckTerminated then
              Exit();

            parseDataForETH(data, TWalletInfo(cc));
          end
      end;

    end
    else if cc is Token then
    begin
      data := getDataOverHTTP(HODLER_ETH + '/?cmd=tokenInfo&addr=' + cc.addr + '&contract=' + Token(cc).ContractAddress);

      if TThread.CurrentThread.CheckTerminated then
        Exit();

      if Token(cc).lastBlock = 0 then
        Token(cc).lastBlock := getHighestBlockNumber(Token(cc));

      TThread.Synchronize(nil,
        procedure
        begin
          frmHome.RefreshProgressBar.value := 30;
        end);

      parseDataForERC20(data, Token(cc));
    end
    else
    begin
      raise Exception.Create('CryptoCurrency Type Error');
    end;

    Exit();

  end;

  if cc is TWalletInfo then
  begin

    case TWalletInfo(cc).coin of

      4:
        begin
          data := getDataOverHTTP(HODLER_ETH + '/?cmd=accInfo&addr=' + TWalletInfo(cc).addr);

          if TThread.CurrentThread.CheckTerminated then
            Exit();

          parseDataForETH(data, TWalletInfo(cc));
        end
    end;

  end
  else if cc is Token then
  begin
    data := getDataOverHTTP(HODLER_ETH + '/?cmd=tokenInfo&addr=' + cc.addr + '&contract=' + Token(cc).ContractAddress);

    if TThread.CurrentThread.CheckTerminated then
      Exit();

    if Token(cc).lastBlock = 0 then
      Token(cc).lastBlock := getHighestBlockNumber(Token(cc));

    TThread.Synchronize(nil,
      procedure
      begin
        frmHome.RefreshProgressBar.value := 30;
      end);

    parseDataForERC20(data, Token(cc));
  end
  else
  begin
    raise Exception.Create('CryptoCurrency Type Error');
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
begin

  inherited;

  frmHome.DashBrdProgressBar.value := 0;
  frmHome.RefreshProgressBar.value := 0;

  startTime := now;

  with frmHome do
  begin

    TThread.Synchronize(TThread.CurrentThread,
      procedure
      begin

        synchronizeCurrencyValue();

        RefreshWalletView.Enabled := false;
        RefreshProgressBar.Visible := True;
        btnSync.Enabled := false;
        DashBrdProgressBar.Visible := True;

        btnSync.Repaint();

      end);

    refreshGlobalImage.Start;

    try
      SynchronizeAll();
    except
      on e: Exception do
      begin
      end;
    end;
    // synchronizeAddresses;

    refreshGlobalFiat();

    refreshGlobalImage.Stop();

    if TThread.CurrentThread.CheckTerminated then
      Exit();

    TThread.Synchronize(TThread.CurrentThread,
      procedure
      begin
        repaintWalletList;

        if PageControl.ActiveTab = walletView then
        begin

          reloadWalletView;


          // createHistoryList( CurrentCryptoCurrency );

        end;

        TLabel(frmHome.FindComponent('globalBalance')).text := floatToStrF(currencyConverter.calculate(globalFiat), ffFixed, 9, 2);
        TLabel(frmHome.FindComponent('globalCurrency')).text := '         ' + currencyConverter.symbol;

        RefreshWalletView.Enabled := True;
        RefreshProgressBar.Visible := false;
        btnSync.Enabled := True;
        DashBrdProgressBar.Visible := false;

        btnSync.Repaint();

        DebugRefreshTime.text := 'last refresh: ' + Formatdatetime('dd mmm yyyy hh:mm:ss', now);

        duringSync := false;
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
  sum: BigInteger;
  tempts: TStringList;
begin
  sum := 0;
  if text = '' then
    Exit;

  ts := TStringList.Create();
  try
    ts.text := text;

    if ts.Count = 1 then
    begin
      T.lastBlock := strToIntdef(ts.Strings[0], 0);
      Exit();
    end;
    i := 0;

    setLength(T.history, 0);

    while (i < ts.Count - 1) do
    begin
      number := strToInt(ts.Strings[i]);
      Inc(i);
      // showmessage(inttostr(number));

      transHist.typ := ts.Strings[i];
      Inc(i);

      transHist.TransactionID := ts.Strings[i];
      Inc(i);

      transHist.lastBlock := StrToInt64Def(ts.Strings[i], 0);
      Inc(i);

      tempts := SplitString(ts[i]);
      transHist.data := tempts.Strings[0];
      transHist.confirmation := strToInt(tempts[1]);
      tempts.Free;
      Inc(i);

      setLength(transHist.addresses, number);
      setLength(transHist.values, number);

      sum := 0;

      for j := 0 to number - 1 do
      begin
        transHist.addresses[j] := '0x' + rightStr(ts.Strings[i], 40);
        Inc(i);

        BigInteger.TryParse(ts.Strings[i], transHist.values[j]);
        Inc(i);

        sum := sum + transHist.values[j];
      end;

      // showmessage( inttostr(number) );

      transHist.CountValues := sum;

      setLength(T.history, length(T.history) + 1);
      T.history[length(T.history) - 1] := transHist;

    end;
    // ts.Free;
  except
    on e: Exception do
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
  sum: BigInteger;
  tempts: TStringList;
begin

  sum := 0;

  ts := TStringList.Create();
  try
    ts.text := text;

    setLength(wallet.history, 0);

    /// ////////

    i := 0;

    while (i < ts.Count - 1) do
    begin
      number := strToInt(ts.Strings[i]);
      Inc(i);
      // showmessage(inttostr(number));

      transHist.typ := ts.Strings[i];
      Inc(i);

      transHist.TransactionID := ts.Strings[i];
      Inc(i);

      transHist.lastBlock := StrToInt64Def(ts.Strings[i], 0);
      Inc(i);

      tempts := SplitString(ts[i]);
      transHist.data := tempts.Strings[0];
      transHist.confirmation := strToInt(tempts[1]);
      tempts.Free;
      Inc(i);

      setLength(transHist.addresses, number);
      setLength(transHist.values, number);
      sum := 0;
      for j := 0 to number - 1 do
      begin
        transHist.addresses[j] := '0x' + rightStr(ts.Strings[i], 40);
        Inc(i);

        BigInteger.TryParse(ts.Strings[i], transHist.values[j]);
        Inc(i);

        sum := sum + transHist.values[j];
      end;

      // showmessage( inttostr(number) );

      transHist.CountValues := sum;

      setLength(wallet.history, length(wallet.history) + 1);
      wallet.history[length(wallet.history) - 1] := transHist;

    end;

    /// ////////

  except
    on e: Exception do
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
    result := '&segwit=' + segwit + '&segwithash=' + decodeAddressInfo(segwit, wi.coin).scriptHash;
  end
  else
    result := '&segwit=' + '0' + '&segwithash=' + '0';
  result := result + '&compatible=' + compatible + '&compatiblehash=' + decodeAddressInfo(compatible, wi.coin).scriptHash + '&legacy=' + legacy;

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
    on e: Exception do
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
    wd.confirmed := BigInteger.Parse(ts.Strings[1]);
    // floattostrF(strtoint64def(ts.Strings[1],-1) /1000000000000000000,ffFixed,18,18);
    wd.unconfirmed := '0';
    wd.nonce := strToIntdef(ts.Strings[2], 0);
    wd.fiat := ts.Strings[3];
    // globalFiat := globalFiat + StrToFloatDef(wd.fiat, 0);
    wd.rate := StrToFloatDef(ts.Strings[4], 0);

  except
    on e: Exception do


  end;

  ts.Free;
end;

procedure parseDataForERC20(s: string; var wd: Token);
var
  ts: TStringList;
  i: Integer;
  bc: Integer;
begin

  ts := TStringList.Create;
  ts.text := s;
  try

    // wd.efee[0]:=ts.Strings[0];//floattostrF(strtointdef(ts.Strings[0],11000000000) /1000000000000000000,ffFixed,18,18);
    wd.confirmed := BigInteger.Parse(ts.Strings[1]);
    if (wd.id < 10000) or (not Token.AvailableToken[wd.id - 10000].stableCoin) then
      wd.rate := strToFloat(ts[2])
    else
      wd.rate := Token.AvailableToken[wd.id - 10000].stableValue;
    // floattostrF(strtoint64def(ts.Strings[1],-1) /1000000000000000000,ffFixed,18,18);
    wd.unconfirmed := '0';
    // wd.nonce:=strtointdef(ts.Strings[2],0);
    // wd.fiat := ts.Strings[3];
    // globalFiat := globalFiat + StrToFloatDef(wd.fiat, 0);

  except
    on e: Exception do


  end;

  ts.Free;
end;

function isOurAddress(adr: string; coinid: Integer): boolean;
var
  twi: TWalletInfo;
var
  segwit, cash, compatible, legacy: AnsiString;
begin

  result := false;

  adr := lowercase(StringReplace(adr, 'bitcoincash:', '', [rfReplaceAll]));

  for twi in CurrentAccount.myCoins do
  begin

    if twi.coin <> coinid then
      continue;

    segwit := lowercase(generatep2wpkh(twi.pub, availablecoin[twi.coin].hrp));
    compatible := lowercase(generatep2sh(twi.pub, availablecoin[twi.coin].p2sh));
    legacy := generatep2pkh(twi.pub, availablecoin[twi.coin].p2pk);
    cash := lowercase(bitcoinCashAddressToCashAddress(legacy, false));
    legacy := LowerCase(legacy);
    cash := StringReplace(cash, 'bitcoincash:', '', [rfReplaceAll]);
    if ((adr) = segwit) or (adr = compatible) or (adr = legacy) or (adr = cash) then
      Exit(True);

  end;
end;

function checkTxType(tx: TxHistoryResult; coinid: Integer): Integer;
var
  ourInputs, ourOutputs: Integer;
  i: Integer;
begin

  result := 0;
  ourInputs := 0;
  ourOutputs := 0;

  for i := 0 to strToIntdef(tx.inputsCount, 0) - 1 do

    if isOurAddress(tx.inputAddresses[i], coinid) then
      Inc(ourInputs);

  for i := 0 to strToIntdef(tx.outputsCount, 0) - 1 do
    if isOurAddress(tx.outputs[i].address, coinid) then
      Inc(ourOutputs);

  if (ourInputs >= 1) and (ourOutputs = 0) then
    Exit(0); // outgoing
  if (ourInputs >= 1) and (ourOutputs = 1) and (strToIntdef(tx.outputsCount, 0) > 1) then
    Exit(0); // outgoing
  if (ourInputs >= 1) and (strToIntdef(tx.outputsCount, 0) = ourOutputs) then
    Exit(2); // internal\
  if (ourInputs = 0) and (ourOutputs >= 1) then
    Exit(1); // incoming

end;

procedure parseCoinHistory(text: AnsiString; wallet: TWalletInfo);
var
  ts: TStringList;
  i: Integer;
  number: Integer;
  transHist: TransactionHistory;
  j: Integer;
  sum: BigInteger;
  tempts: TStringList;
  parsedTx: array of TxHistoryResult;
  // ====
  idx: Integer;
  entry, txIndex: Integer;
begin
  setLength(parsedTx, 0);
  ts := TStringList.Create();

  ts.text := text;
  if ts.Count < 6 then
  begin
    ts.Free;
    Exit;
  end;
  entry := 0;
  txIndex := 0;
  setLength(parsedTx, txIndex + 1);
  repeat
    if TThread.CurrentThread.CheckTerminated then
      Exit();

    parsedTx[txIndex].inputsCount := ts.Strings[entry + 2];
    parsedTx[txIndex].txId := ts.Strings[entry + 1];
    parsedTx[txIndex].outputsCount := ts.Strings[entry + 0];
    idx := 4 + strToIntdef(parsedTx[txIndex].inputsCount, 0);
    parsedTx[txIndex].timestamp := ts.Strings[entry + idx - 1];
    setLength(parsedTx[txIndex].outputs, strToIntdef(parsedTx[txIndex].outputsCount, 0));
    setLength(parsedTx[txIndex].inputAddresses, strToIntdef(parsedTx[txIndex].inputsCount, 0));

    for i := 0 to strToIntdef(parsedTx[txIndex].inputsCount, 0) - 1 do
    begin

      parsedTx[txIndex].inputAddresses[i] := ts.Strings[entry + 3 + i];

    end;

    for i := 0 to strToIntdef(parsedTx[txIndex].outputsCount, 0) - 1 do
    begin
      parsedTx[txIndex].outputs[i].address := ts.Strings[entry + idx + (i * 2)];
      parsedTx[txIndex].outputs[i].value := ts.Strings[entry + idx + 1 + (i * 2)];

    end;

    entry := entry + (strToIntdef(parsedTx[txIndex].outputsCount, 0) * 2) + strToIntdef(parsedTx[txIndex].inputsCount, 0) + 4;
    Inc(txIndex);
    setLength(parsedTx, txIndex + 1);
  until (entry >= (ts.Count - 1));
  setLength(parsedTx, txIndex);
  i := 0;
  setLength(wallet.history, 0);

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
    setLength(transHist.addresses, strToIntdef(parsedTx[i].outputsCount, 0));
    setLength(transHist.values, strToIntdef(parsedTx[i].outputsCount, 0));
    for j := 0 to strToIntdef(parsedTx[i].outputsCount, 0) - 1 do
    begin
      transHist.addresses[j] := parsedTx[i].outputs[j].address;
      if wallet.coin = 7 then
      begin

        if ContainsStr(transHist.addresses[j], ':') then
        begin
          transHist.addresses[j] := rightstr(transHist.addresses[j], length(transHist.addresses[j]) - pos(':', transHist.addresses[j]));
        end;

      end;

      if (transHist.typ = 'OUT') then
      begin

        if (isOurAddress(parsedTx[i].outputs[j].address, wallet.coin) = True) then
          transHist.values[j] := StrFloatToBigInteger('0.000000', availablecoin[wallet.coin].decimals)
        else
          transHist.values[j] := StrFloatToBigInteger(parsedTx[i].outputs[j].value, availablecoin[wallet.coin].decimals);

        sum := sum + transHist.values[j];

      end;

      if (transHist.typ = 'IN') or (transHist.typ = 'INTERNAL') then
      begin

        if not (isOurAddress(parsedTx[i].outputs[j].address, wallet.coin) = True) then
          transHist.values[j] := StrFloatToBigInteger('0.000000', availablecoin[wallet.coin].decimals)
        else
          transHist.values[j] := StrFloatToBigInteger(parsedTx[i].outputs[j].value, availablecoin[wallet.coin].decimals);

        sum := sum + transHist.values[j];

      end;
    end;
    transHist.CountValues := sum;
    setLength(wallet.history, length(wallet.history) + 1);
    wallet.history[length(wallet.history) - 1] := transHist;

  end;

  ts.Free;
end;

end.

