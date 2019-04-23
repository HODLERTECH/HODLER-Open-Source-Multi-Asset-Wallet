unit SyncThr;

interface

uses
  System.classes, System.sysutils, FMX.Controls, FMX.StdCtrls, FMX.dialogs, AccountData,
  StrUtils, WalletStructureData, CryptoCurrencyData, tokenData, System.SyncObjs,

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

procedure parseDataForETH(s: AnsiString; { var } wd: TWalletInfo);

procedure parseCoinHistory(text: AnsiString; wallet: TWalletInfo);

procedure parseTokenHistory(text: AnsiString; T: Token);

function segwitParameters(wi: TWalletInfo): AnsiString;

procedure SynchronizeCryptoCurrency(ac : Account ; cc: cryptoCurrency);

procedure parseBalances(s: AnsiString; var wd: TWalletInfo);

procedure parseETHHistory(text: AnsiString; wallet: TWalletInfo);

procedure SynchronizeAll();

procedure parseDataForERC20(s: string; var wd: Token);

function batchSync(ac : Account ;var coinid: Integer; X: Integer = -1): string;

//procedure verifyKeypool();

procedure verifyKeypoolNoThread(ac : account ; wi: TWalletInfo);

procedure parseSync(ac : Account ; s: string; verifyKeypool: boolean = false);

function keypoolIsUsed(ac : account ; var coinid: Integer; X: Integer = -1): string;

//var
  //semaphore: TLightweightSemaphore;
  //VerifyKeypoolSemaphore: TLightweightSemaphore;
  //mutex: TSemaphore;

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

function batchSync(ac : Account ; var coinid: Integer; X: Integer = -1): string;
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
        Copy(GetStrHashSHA256(ac.name + IntToStr(coinid) +
        IntToStr(wi.X) + IntToStr(wi.y)), 0, 6), 0) + i); // moreUniq
      if (wi.inPool = false) or (wi.y >= changeDelimiter) then
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

function keypoolIsUsed(ac : account ; var coinid: Integer; X: Integer = -1): string;
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
    if (wi.coin = coinid) and ((wi.inPool = True) or (wi.y >= changeDelimiter))
    then
    begin
      wi.uniq := abs((coinid * 1000) + StrToInt64Def('$' +
        Copy(GetStrHashSHA256(ac.name + IntToStr(coinid) +
        IntToStr(wi.X) + IntToStr(wi.y)), 0, 7), 0) + i); // moreUniq

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
  procedure calcNanoBalances(var nn: NanoCoin);
  var
    nblock: TNanoBlock;   i:integer;
    prevAmount: BigInteger;
  begin
    if Length(nn.pendingChain) = 0 then
      exit;
    prevAmount := nn.confirmed;
    nblock := nn.firstBlock;
    if not (nblock.balance='') then
    if BigInteger.Parse(nblock.balance) < prevAmount then
      nn.confirmed := prevAmount -
        (prevAmount - BigInteger.Parse(nblock.balance));

    repeat
    if BigInteger.Parse(nblock.balance) < prevAmount then begin
      SetLength(nn.history, Length(nn.history) + 1);
      i:=length(nn.history)-1;
      SetLength(nn.history[i].values, 2);
      SetLength(nn.history[i].addresses, 2);
      nn.history[i].values[0] :=
        (prevAmount - BigInteger.Parse(nblock.balance));
      nn.history[i].values[1] := 0;
      nn.history[i].TransactionID := nblock.Hash;
      nn.history[i].addresses[0] := (nblock.account);
      nn.history[i].addresses[1] := (nblock.source);
      nn.history[i].data := IntToStr(Length(nn.history) + 1);
      nn.history[i].typ := 'OUT';
      nn.history[i].CountValues := nn.history[i].values[0];
      nn.history[i].confirmation := 0;
    end;
      prevAmount := BigInteger.Parse(nblock.balance);

      nblock := nn.BlockByPrev(nblock.hash);
      if not (nblock.balance='') then
      if BigInteger.Parse(nblock.balance) < prevAmount then
      begin
        nn.confirmed := prevAmount -
          (prevAmount - BigInteger.Parse(nblock.balance));
      end;

    until nblock.account = '';
  end;

var
  js: TJSONObject;
  newblock: string;
  block, firstBlock: TNanoBlock;
  history: TJsonArray;
  ts: TStringList;
  i: Integer;
  masterseed, tced: AnsiString;
  err: string;
  pendings: TJsonArray;
  temp: TpendingNanoBlock;
  psxString: {$IFDEF LINUX64}System.{$ENDIF}AnsiString;   // System.AnsiString nie kompiluje siê na Androidzie
begin
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
  try

    js := TJSONObject.ParseJSONValue(data) as TJSONObject;
    cc.rate := StrToFloatDef(js.GetValue('price').value, 0.0);
    cc.confirmed := BigInteger.Parse(js.GetValue('balance')
      .GetValue<string>('balance'));
    cc.unconfirmed := BigInteger.Parse(js.GetValue('balance')
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
        BigInteger.Parse(NanoCoin(cc).curBlock.balance)
    else
      NanoCoin(cc).lastBlockAmount := cc.confirmed;

    // cc.unconfirmed := cc.unconfirmed +
    // (cc.confirmed - NanoCoin(cc).lastBlockAmount);
    try
      if js.TryGetValue<TJsonArray>('history', history) then
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
            cc.history[i].values[0] := BigInteger.abs(block.blockAmount);
            cc.history[i].values[1] := 0;
            // length(hitory.Values) must be the same as length(history.addresses)
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
          end
        end
        else
          nano_precalculate(nano_keyFromAccount(cc.addr));
    except
      on E: Exception do
      begin
       err:=E.message;
      end;
    end;
    calcNanoBalances(NanoCoin(cc));
    if js.TryGetValue<TJsonArray>('pending', pendings) then
      if pendings.Count > 0 then
      begin
        for i := 0 to (pendings.Count div 2) - 1 do
        begin
          try
            temp.block := nano_buildFromJSON(pendings.Items[(i * 2)
              ].GetValue<TJSONObject>('data').GetValue('contents').value, '');
            temp.Hash := pendings.Items[(i * 2) + 1].GetValue<string>('hash');

            if NanoCoin(cc).BlockByLink(temp.Hash).account <> '' then
            begin

              SetLength(cc.history, Length(cc.history) + 1);
              block := temp.block;
              // cc.unconfirmed := cc.unconfirmed + block.blockAmount;
              SetLength(cc.history[i].values, 2);
              SetLength(cc.history[i].addresses, 2);
              cc.history[i].values[0] := BigInteger.abs(block.blockAmount);
              cc.history[i].values[1] := 0;
              // length(hitory.Values) must be the same as length(history.addresses)
              cc.history[i].TransactionID := block.Hash;
              cc.history[i].addresses[0] :=
                nano_accountFromHexKey(block.account);
              cc.history[i].addresses[1] :=
                nano_accountFromHexKey(block.source);
              cc.history[i].data := IntToStr(history.Count - 1 - i);
              if block.blocktype = 'send' then
                cc.history[i].typ := 'OUT'
              else
                cc.history[i].typ := 'IN';
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

{$IFDEF  ANDROID} s := StringReplace(s, '\\', '\', [rfReplaceAll]); {$ENDIF}
  try

    coinJson := TJSONObject.ParseJSONValue(s) as TJSONObject;
    if coinJson.Count = 0 then
    begin
      coinJson.Free;
      exit;
    end;

    for i := 0 to coinJson.Count - 1 do
    begin

      {if SyncBalanceThr <> nil then
              if SyncBalanceThr.Terminated then
                      begin
                                coinJson.Free;
                                          exit;
                                                  end;}

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
          end;

        end;

      end;

    end;

    coinJson.Free;

  except
    on E: Exception do
      err := (E.message);
  end;

end;

procedure SynchronizeAll();
var
  i: Integer;
  licz: Integer;
  batched: string;
begin
 try
  currentAccount.AsyncSynchronize;
 except on E:Exception do begin end; end;

  currentaccount.firstSync := false;

end;

procedure verifyKeypoolNoThread(ac : Account ; wi: TWalletInfo);
var
  wd: TObject;
  url, s: string;
begin
  try
    s := keypoolIsUsed(ac , wi.coin);
    klog('386: s=' + s);
    url := HODLER_URL + '/batchSync0.3.2.php?keypool=true&coin=' + availablecoin
      [wi.coin].name;
    if TThread.CurrentThread.CheckTerminated then
      exit();
    s := postDataOverHTTP(url, s, false, True);
    klog('392: s=' + s);
    parseSync(ac , s, True);

  except
    on E: Exception do
    begin

    end;
  end;

end;



procedure SynchronizeCryptoCurrency(ac : Account ; cc: cryptoCurrency);
var
  data, url, s: string;
begin

  /// ////////////////HISTORY//////////////////////////
  if cc is TWalletInfo then
  begin

    case TWalletInfo(cc).coin of
      0, 1, 2, 3, 5, 6, 7:
        begin
          url := HODLER_URL + '/batchSync0.3.2.php?coin=' + availablecoin
            [TWalletInfo(cc).coin].name;
          s := postDataOverHTTP(url, batchSync(ac , TWalletInfo(cc).coin,
            TWalletInfo(cc).X), false, True);
          if TThread.CurrentThread.CheckTerminated then
            exit();
          parseSync(ac , s);
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
            TWalletInfo(cc).addr, false, True);
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

      {TThread.Synchronize(nil,
        procedure
        begin
          frmHome.RefreshProgressBar.value := 30;
        end);     }

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

    dataTemp := getDataOverHTTP(HODLER_URL + 'fiat.php');
    if TThread.CurrentThread.CheckTerminated then
      exit();

    TThread.Synchronize(nil,
      procedure
      begin

        synchronizeCurrencyValue(dataTemp);

        //RefreshWalletView.Enabled := false;
        //RefreshProgressBar.Visible := True;
        //btnSync.Enabled := false;
        //DashBrdProgressBar.Visible := True;

        //btnSync.Repaint();

      end);

    //refreshGlobalImage.Start;

    CurrentAccount.AsyncSynchronize();

    try
      //SynchronizeAll();
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
          floatToStrF(currencyConverter.calculate(globalFiat), ffFixed, 9, 2);
        TLabel(frmHome.FindComponent('globalCurrency')).text := '         ' +
          currencyConverter.symbol;

        {RefreshWalletView.Enabled := True;
        RefreshProgressBar.Visible := false;
        btnSync.Enabled := True;
        DashBrdProgressBar.Visible := false;}

        //btnSync.Repaint();

        //DebugRefreshTime.text := 'last refresh: ' +
        //  Formatdatetime('dd mmm yyyy hh:mm:ss', now);


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
      transHist.confirmation := strToIntdef(tempts[1], 0);
      tempts.Free;
      Inc(i);

      SetLength(transHist.addresses, number);
      SetLength(transHist.values, number);

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
  sum: BigInteger;
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
      transHist.confirmation := strToIntdef(tempts[1], 0);
      tempts.Free;
      Inc(i);

      SetLength(transHist.addresses, number);
      SetLength(transHist.values, number);
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
    wd.confirmed := BigInteger.Parse(ts.Strings[1]);
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
    wd.confirmed := BigInteger.Parse(ts.Strings[1]);
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

{function isOurAddress(adr: string; coinid: Integer): boolean;
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
end;  }

function checkTxType(tx: TxHistoryResult; coinid: Integer): Integer;
var
  ourInputs, ourOutputs: Integer;
  i: Integer;
begin

  result := 0;
  ourInputs := 0;
  ourOutputs := 0;

  for i := 0 to strToIntdef(tx.inputsCount, 0) - 1 do

    if currentAccount.isOurAddress(tx.inputAddresses[i], coinid) then
      Inc(ourInputs);

  for i := 0 to strToIntdef(tx.outputsCount, 0) - 1 do
    if currentAccount.isOurAddress(tx.outputs[i].address, coinid) then
      Inc(ourOutputs);

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
  sum: BigInteger;
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
    Inc(txIndex);
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

        if (CurrentAccount.isOurAddress(parsedTx[i].outputs[j].address, wallet.coin) = True)
        then
          transHist.values[j] := StrFloatToBigInteger('0.000000',
            availablecoin[wallet.coin].decimals)
        else
          transHist.values[j] := StrFloatToBigInteger
            (parsedTx[i].outputs[j].value, availablecoin[wallet.coin].decimals);

        sum := sum + transHist.values[j];

      end;

      if (transHist.typ = 'IN') or (transHist.typ = 'INTERNAL') then
      begin

        if not(CurrentAccount.isOurAddress(parsedTx[i].outputs[j].address, wallet.coin) = True)
        then
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
