unit SyncThr;

interface

uses
  System.classes, System.sysutils, FMX.Controls, FMX.StdCtrls, FMX.dialogs,
  StrUtils, WalletStructureData, CryptoCurrencyData, tokenData, System.SyncObjs,
  JSON;

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
  SynchronizeHistoryThread = class(TThread)
  private
    startTime: Double;
    endTime: Double;
  public
    constructor Create();
    procedure Execute(); override;
    function TimeFromStart(): Double;
  end;

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

var
  semaphore: TLightweightSemaphore;
  mutex: TSemaphore;

implementation

uses
  uhome, misc, coinData, Velthuis.BigIntegers, Bitcoin, WalletViewRelated;

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

function batchSync(var coinid: Integer; X: Integer = -1): string;
var
  wi: TWalletInfo;
  i: Integer;
begin
  i := 0;

  result := 'coin=' + availablecoin[coinid].name;
  for wi in CurrentAccount.myCoins do
  begin
    if wi.coin = coinid then
    begin
      wi.uniq := i;

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

procedure parseSync(s: string);

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
{$IFDEF  ANDROID} s := StringReplace(s, '\\', '\', [rfReplaceAll]); {$ENDIF}
  try
    coinJson := TJSONObject.ParseJSONValue(s) as TJSONObject;

    if coinJson.Count = 0 then
      Exit;
    for i := 0 to coinJson.Count - 1 do
    begin
    if SyncBalanceThr<>nil then
    if SyncBalanceThr.Terminated then
      Exit();

      wd := nil;
      JsonPair := coinJson.Pairs[i];
      wd := findWDByAddr(JsonPair.JsonValue.GetValue<Integer>('wid'));
      if wd = nil then
        continue;

      parseBalances(JsonPair.JsonValue.GetValue<string>('balance'), wd);
      parseCoinHistory(JsonPair.JsonValue.GetValue<string>('history'), wd);
      wd.UTXO := parseUTXO(JsonPair.JsonValue.GetValue<string>('utxo'), wd.Y);
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
      frmHome.DashBrdProgressBar.Max := length(CurrentAccount.myCoins) +
        length(CurrentAccount.myTokens);
      frmHome.DashBrdProgressBar.Value := 0;
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
          if id = 4 then
          begin
            for wi in CurrentAccount.myCoins do
              if wi.coin = 4 then
                SynchronizeCryptoCurrency(wi);

          end
          else
          begin
            s := batchSync(id);
            url := HODLER_URL + '/batchSync.php?coin=' + availablecoin[id].name;
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
            frmHome.DashBrdProgressBar.Value :=
              frmHome.RefreshProgressBar.Value + 1;
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
            frmHome.DashBrdProgressBar.Value :=
              frmHome.RefreshProgressBar.Value + 1;
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

  CurrentAccount.SaveFiles();
  firstSync := false;

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
          url := HODLER_URL + '/batchSync.php?coin=' + availablecoin
            [TWalletInfo(cc).coin].name;
          parseSync(postDataOverHTTP(url, batchSync(TWalletInfo(cc).coin,
            TWalletInfo(cc).X), false, True));
        end;
      4:
        begin
          data := getDataOverHTTP(HODLER_URL + 'getHistory.php?coin=' +
            availablecoin[TWalletInfo(cc).coin].name + '&address=' +
            TWalletInfo(cc).addr);

          if TThread.CurrentThread.CheckTerminated then
            Exit();

          parseETHHistory(data, TWalletInfo(cc));
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
            data := getDataOverHTTP(HODLER_ETH + '/?cmd=accInfo&addr=' +
              TWalletInfo(cc).addr);

            if TThread.CurrentThread.CheckTerminated then
              Exit();

            parseDataForETH(data, TWalletInfo(cc));
          end
      end;

    end
    else if cc is Token then
    begin
      data := getDataOverHTTP(HODLER_ETH + '/?cmd=tokenInfo&addr=' + cc.addr +
        '&contract=' + Token(cc).ContractAddress);

      if TThread.CurrentThread.CheckTerminated then
        Exit();

      if Token(cc).lastBlock = 0 then
        Token(cc).lastBlock := getHighestBlockNumber(Token(cc));

      TThread.Synchronize(nil,
        procedure
        begin
          frmHome.RefreshProgressBar.Value := 30;
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
          data := getDataOverHTTP(HODLER_ETH + '/?cmd=accInfo&addr=' +
            TWalletInfo(cc).addr);

          if TThread.CurrentThread.CheckTerminated then
            Exit();

          parseDataForETH(data, TWalletInfo(cc));
        end
    end;

  end
  else if cc is Token then
  begin
    data := getDataOverHTTP(HODLER_ETH + '/?cmd=tokenInfo&addr=' + cc.addr +
      '&contract=' + Token(cc).ContractAddress);

    if TThread.CurrentThread.CheckTerminated then
      Exit();

    if Token(cc).lastBlock = 0 then
      Token(cc).lastBlock := getHighestBlockNumber(Token(cc));

    TThread.Synchronize(nil,
      procedure
      begin
        frmHome.RefreshProgressBar.Value := 30;
      end);

    parseDataForERC20(data, Token(cc));
  end
  else
  begin
    raise Exception.Create('CryptoCurrency Type Error');
  end;

  { TThread.Synchronize(nil,
    procedure
    begin
    frmHome.RefreshProgressBar.Value := 0;
    frmHome.RefreshProgressBar.Visible := false;
    end); }

end;

function SynchronizeHistoryThread.TimeFromStart;
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

    { if synchronizeHistory() then
      begin


      if assigned(Self) and (not Terminated) then
      TThread.Synchronize(nil,
      procedure
      begin

      if PageControl.ActiveTab = walletView then
      createHistoryList(CurrentCryptoCurrency, 0, lastHistCC);

      end);

      end; }

  end;

  endTime := now;
end;

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

  frmHome.DashBrdProgressBar.Value := 0;
  frmHome.RefreshProgressBar.Value := 0;

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

        TLabel(frmHome.FindComponent('globalBalance')).text :=
          floatToStrF(currencyConverter.calculate(globalFiat), ffFixed, 9, 2);
        TLabel(frmHome.FindComponent('globalCurrency')).text := '         ' +
          currencyConverter.symbol;

        RefreshWalletView.Enabled := True;
        RefreshProgressBar.Visible := false;
        btnSync.Enabled := True;
        DashBrdProgressBar.Visible := false;

        btnSync.Repaint();

        DebugRefreshTime.text := 'last refresh: ' +
          Formatdatetime('dd mmm yyyy hh:mm:ss', now);

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

      transHist.lastBlock := strtoint64def(ts.Strings[i], 0);
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

      transHist.lastBlock := strtoint64def(ts.Strings[i], 0);
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
    if (wd.id < 10000) or (not Token.AvailableToken[wd.id - 10000].stableCoin)
    then
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

procedure parseCoinHistory(text: AnsiString; wallet: TWalletInfo);
var
  ts: TStringList;
  i: Integer;
  number: Integer;
  transHist: TransactionHistory;
  j: Integer;
  sum: BigInteger;
  tempts: TStringList;
begin

  ts := TStringList.Create();

  ts.text := text;

  { Tthread.Synchronize(nil,procedure
    begin

    showmessage(wallet.pub);
    showmessage(text);
    end); }

  i := 0;

  setLength(wallet.history, 0);

  while (i < ts.Count - 1) do
  begin

    number := strToInt(ts.Strings[i]);
    Inc(i);

    transHist.typ := ts.Strings[i];
    Inc(i);

    transHist.TransactionID := ts.Strings[i];
    Inc(i);

    if ts.Strings[i] = '' then
    begin
      Inc(i);
      continue;
    end;
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
      transHist.addresses[j] := ts.Strings[i];
      Inc(i);
      transHist.values[j] := StrFloatToBigInteger(ts.Strings[i],
        availablecoin[wallet.coin].decimals);
      Inc(i);

      sum := sum + transHist.values[j];
    end;

    transHist.CountValues := sum;

    setLength(wallet.history, length(wallet.history) + 1);
    wallet.history[length(wallet.history) - 1] := transHist;

  end;

  ts.Free;
end;

end.
