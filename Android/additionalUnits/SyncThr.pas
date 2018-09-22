unit SyncThr;

interface

uses System.classes, System.sysutils, FMX.Controls, FMX.StdCtrls, FMX.dialogs,
  StrUtils, WalletStructureData, CryptoCurrencyData, tokenData;

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

procedure synchronizeAddresses;
procedure parseDataForETH(s: AnsiString; { var } wd: TWalletInfo);
procedure parseCoinHistory(text: AnsiString; wallet: TWalletInfo);
procedure parseTokenHistory(text: AnsiString; T: Token);
procedure synchronizeHistory;
function segwitParameters(wi: TWalletInfo): AnsiString;
procedure SynchronizeCryptoCurrency(var cc: cryptoCurrency);
procedure parseBalances(s: AnsiString; var wd: TWalletInfo);
procedure parseETHHistory(text: AnsiString; wallet: TWalletInfo);

procedure parseDataForERC20(s: string; var wd: Token);

implementation

uses uhome, misc, coinData, Velthuis.BigIntegers, Bitcoin;

procedure SynchronizeCryptoCurrency(var cc: cryptoCurrency);
var
  data: AnsiString;
begin
frmHome.RefreshProgressBar.Visible:=true;
  if cc is TWalletInfo then
  begin
    frmHome.RefreshProgressBar.Value:=10;
    case TWalletInfo(cc).coin of

      0:
        begin
          data := getDataOverHTTP(HODLER_URL + 'getSegwitBalance.php?coin=' +
            availablecoin[TWalletInfo(cc).coin].name + '&' +
            segwitParameters(TWalletInfo(cc)));

          data := getDataOverHTTP(HODLER_URL + 'getSegwitUTXO.php?coin=' +
            availablecoin[TWalletInfo(cc).coin].name + '&' +
            segwitParameters(TWalletInfo(cc)));

          parseBalances(data, TWalletInfo(cc));
          TWalletInfo(cc).UTXO := parseUTXO(data);

        end;

      4:
        begin
          data := getDataOverHTTP(HODLER_ETH + '/?cmd=accInfo&addr=' +
            TWalletInfo(cc).addr);
          parseDataForETH(data, TWalletInfo(cc));
        end
    else
      begin
        data := getDataOverHTTP(HODLER_URL + 'getBalance.php?coin=' +
          availablecoin[TWalletInfo(cc).coin].name + '&address=' +
          TWalletInfo(cc).addr);

        data := getDataOverHTTP(HODLER_URL + 'getUTXO.php?coin=' + availablecoin
          [TWalletInfo(cc).coin].name + '&address=' + TWalletInfo(cc).addr);

        parseBalances(data, TWalletInfo(cc));
        TWalletInfo(cc).UTXO := parseUTXO(data);

      end;
    end;
      frmHome.RefreshProgressBar.value:=30;
  end
  else
  begin
    data := getDataOverHTTP(HODLER_ETH + '/?cmd=tokenInfo&addr=' + cc.addr +
      '&contract=' + Token(cc).ContractAddress);

    if Token(cc).lastBlock = 0 then
      Token(cc).lastBlock := getHighestBlockNumber(Token(cc));
        frmHome.RefreshProgressBar.value:=30;
    parseDataForERC20(data, Token(cc));
  end;

  /// ////////////////HISTORY//////////////////////////
  if cc is TWalletInfo then
  begin
      frmHome.RefreshProgressBar.value:=70;
    case TWalletInfo(cc).coin of
      0:
        begin
          data := getDataOverHTTP(HODLER_URL + 'getSegwitHistory.php?coin=' +
            availablecoin[TWalletInfo(cc).coin].name + '&' +
            segwitParameters(TWalletInfo(cc)));

          parseCoinHistory(data, TWalletInfo(cc));
        end;
      4:
        begin
          data := getDataOverHTTP(HODLER_URL + 'getHistory.php?coin=' +
            availablecoin[TWalletInfo(cc).coin].name + '&address=' +
            TWalletInfo(cc).addr);
          parseETHHistory(data, TWalletInfo(cc));
        end;
    else
      begin
        data := getDataOverHTTP(HODLER_URL + 'getHistory.php?coin=' +
          availablecoin[TWalletInfo(cc).coin].name + '&address=' +
          TWalletInfo(cc).addr);

        parseCoinHistory(data, TWalletInfo(cc));
      end;
    end;

  end
  else
  begin

    if Token(cc).lastBlock = 0 then
      Token(cc).lastBlock := getHighestBlockNumber(Token(cc));

    data := getDataOverHTTP(HODLER_ETH + '/?cmd=tokenHistory&addr=' + Token(cc)
      .addr + '&contract=' + Token(cc).ContractAddress + '&bno=' +
      inttostr(Token(cc).lastBlock));

    parseTokenHistory(data, Token(cc));

  end;
     frmHome.RefreshProgressBar.value:=0;
    frmHome.RefreshProgressBar.Visible:=false;
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

    synchronizeHistory();

    TThread.Synchronize(nil,
      procedure
      begin

        if PageControl.ActiveTab = walletView then
          createHistoryList(CurrentCryptoCurrency);

      end);

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

    TThread.Synchronize(nil,
      procedure
      begin

        synchronizeCurrencyValue();

        RefreshWalletView.Enabled := false;
        RefreshProgressBar.Visible := true;
        btnSync.Enabled := false;
        DashBrdProgressBar.Visible := true;

        btnSync.Repaint();

      end);

    synchronizeAddresses;
    refreshGlobalFiat();

    TThread.Synchronize(nil,
      procedure
      begin
        repaintWalletList;

        if PageControl.ActiveTab = walletView then
        begin

          TopInfoConfirmedValue.text :=
            BigIntegerToFloatStr(CurrentCryptoCurrency.confirmed,
            CurrentCryptoCurrency.decimals);
          TopInfoUnconfirmedValue.text :=
            BigIntegerToFloatStr(CurrentCryptoCurrency.unconfirmed,
            CurrentCryptoCurrency.decimals);
          lbBalance.text := BigIntegerBeautifulStr
            (CurrentCryptoCurrency.confirmed, CurrentCryptoCurrency.decimals);
          lbBalanceLong.text := TopInfoConfirmedValue.text;
          lblFiat.text := floatToStrF(CurrentCryptoCurrency.getFiat(),
            ffFixed, 15, 2);


          // createHistoryList( CurrentCryptoCurrency );

        end;

        TLabel(frmHome.FindComponent('globalBalance')).text :=
          floatToStrF(currencyConverter.calculate(globalFiat), ffFixed, 9, 2);
        TLabel(frmHome.FindComponent('globalCurrency')).text := '         ' +
          currencyConverter.symbol;

        RefreshWalletView.Enabled := true;
        RefreshProgressBar.Visible := false;
        btnSync.Enabled := true;
        DashBrdProgressBar.Visible := false;

        btnSync.Repaint();

        DebugRefreshTime.text := 'last refresh: ' +
          Formatdatetime('dd mmm yyyy hh:mm:ss', now);

        duringSync := false;
        txHistory.Enabled := true;
        txHistory.EndUpdate;

      end);

  end;

  endTime := now;
end;

procedure parseTokenHistory(text: AnsiString; T: Token);
var
  ts: TStringList;
  i: integer;
  number: integer;
  transHist: TransactionHistory;
  j: integer;
  sum: BigInteger;
  tempts: TStringList;
begin
  sum := 0;

  ts := TStringList.Create();
  try
    ts.text := text;

    if ts.Count = 1 then
    begin
      T.lastBlock := strToIntdef(ts.Strings[0], 0);
      exit();
    end;
    i := 0;

    setLength(T.history, 0);

    while (i < ts.Count - 1) do
    begin
      number := strToInt(ts.Strings[i]);
      inc(i);
      // showmessage(inttostr(number));

      transHist.typ := ts.Strings[i];
      inc(i);

      transHist.TransactionID := ts.Strings[i];
      inc(i);

      transHist.lastBlock := strtoint64def(ts.Strings[i], 0);
      inc(i);

      tempts := SplitString(ts[i]);
      transHist.data := tempts.Strings[0];
      transHist.confirmation := strToInt(tempts[1]);
      tempts.Free;
      inc(i);

      setLength(transHist.addresses, number);
      setLength(transHist.values, number);

      for j := 0 to number - 1 do
      begin
        transHist.addresses[j] := '0x' + rightStr(ts.Strings[i], 40);
        inc(i);

        BigInteger.TryParse(ts.Strings[i], transHist.values[j]);
        inc(i);

        sum := sum + transHist.values[j];
      end;

      // showmessage( inttostr(number) );

      transHist.CountValues := sum;

      setLength(T.history, length(T.history) + 1);
      T.history[length(T.history) - 1] := transHist;

    end;
    // ts.Free;
  Except
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
  i, j, number: integer;
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
      inc(i);
      // showmessage(inttostr(number));

      transHist.typ := ts.Strings[i];
      inc(i);

      transHist.TransactionID := ts.Strings[i];
      inc(i);

      transHist.lastBlock := strtoint64def(ts.Strings[i], 0);
      inc(i);

      tempts := SplitString(ts[i]);
      transHist.data := tempts.Strings[0];
      transHist.confirmation := strToInt(tempts[1]);
      tempts.Free;
      inc(i);

      setLength(transHist.addresses, number);
      setLength(transHist.values, number);
      sum := 0;
      for j := 0 to number - 1 do
      begin
        transHist.addresses[j] := '0x' + rightStr(ts.Strings[i], 40);
        inc(i);

        BigInteger.TryParse(ts.Strings[i], transHist.values[j]);
        inc(i);

        sum := sum + transHist.values[j];
      end;

      // showmessage( inttostr(number) );

      transHist.CountValues := sum;

      setLength(wallet.history, length(wallet.history) + 1);
      wallet.history[length(wallet.history) - 1] := transHist;

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
  segwit := generatep2wpkh(wi.pub);
  compatible := generatep2sh(wi.pub, availablecoin[wi.coin].p2sh);
  legacy := generatep2pkh(wi.pub, availablecoin[wi.coin].p2pk);
  result := 'segwit=' + segwit + '&segwithash=' + decodeAddressInfo(segwit,
    wi.coin).scriptHash + '&compatible=' + compatible + '&compatiblehash=' +
    decodeAddressInfo(compatible, wi.coin).scriptHash + '&legacy=' + legacy;

end;

procedure parseBalances(s: AnsiString; var wd: TWalletInfo);
var
  ts: TStringList;
  i: integer;
  bc: integer;
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
  end;

  ts.Free;
end;

procedure parseDataForETH(s: AnsiString; { var } wd: TWalletInfo);
var
  ts: TStringList;
  i: integer;
  bc: integer;
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
  i: integer;
  bc: integer;
begin

  ts := TStringList.Create;
  ts.text := s;
  try

    // wd.efee[0]:=ts.Strings[0];//floattostrF(strtointdef(ts.Strings[0],11000000000) /1000000000000000000,ffFixed,18,18);
    wd.confirmed := BigInteger.Parse(ts.Strings[1]);
    wd.rate := strToFloat(ts[2]);
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

procedure parseCoinHistory(text: AnsiString; wallet: TWalletInfo);
var
  ts: TStringList;
  i: integer;
  number: integer;
  transHist: TransactionHistory;
  j: integer;
  sum: BigInteger;
  tempts: TStringList;
begin

  ts := TStringList.Create();

  ts.text := text;
  i := 0;

  setLength(wallet.history, 0);

  while (i < ts.Count - 1) do
  begin

    number := strToInt(ts.Strings[i]);
    inc(i);

    transHist.typ := ts.Strings[i];
    inc(i);

    transHist.TransactionID := ts.Strings[i];
    inc(i);

    if ts.Strings[i] = '' then
    begin
      inc(i);
      continue;
    end;
    tempts := SplitString(ts[i]);
    transHist.data := tempts.Strings[0];
    transHist.confirmation := strToInt(tempts[1]);
    tempts.Free;
    inc(i);

    setLength(transHist.addresses, number);
    setLength(transHist.values, number);

    sum := 0;

    for j := 0 to number - 1 do
    begin
      transHist.addresses[j] := ts.Strings[i];
      inc(i);
      transHist.values[j] := StrFloatToBigInteger(ts.Strings[i],
        availablecoin[wallet.coin].decimals);
      inc(i);

      sum := sum + transHist.values[j];
    end;

    transHist.CountValues := sum;

    setLength(wallet.history, length(wallet.history) + 1);
    wallet.history[length(wallet.history) - 1] := transHist;

  end;

  ts.Free;
end;

procedure synchronizeHistory;
var
  i: integer;
  counter: integer;
  highestBlock: System.uint64;
  CoinDataArray: array of String;
  TokenDataArray: array of String;
  getDataThread: TThread;
begin

  // showmessage('synchronizeHistory not implemented yet');
  setLength(CoinDataArray, length(CurrentAccount.myCoins));
  setLength(TokenDataArray, length(CurrentAccount.myTokens));

  getDataThread := TThread.CreateAnonymousThread(
    procedure
    var
      i: integer;
    begin
      counter := 0;

      for i := 0 to length(CurrentAccount.myCoins) - 1 do
      begin

        if TThread.CurrentThread.CheckTerminated then
          exit();

        case CurrentAccount.myCoins[i].coin of
          0:
            begin
              CoinDataArray[counter] := getDataOverHTTP(HODLER_URL +
                'getSegwitHistory.php?coin=' + availablecoin
                [CurrentAccount.myCoins[i].coin].name + '&' +
                segwitParameters(CurrentAccount.myCoins[i]));
              inc(counter);
            end
        else
          begin
            CoinDataArray[counter] := getDataOverHTTP(HODLER_URL +
              'getHistory.php?coin=' + availablecoin[CurrentAccount.myCoins[i]
              .coin].name + '&address=' + CurrentAccount.myCoins[i].addr);
            inc(counter);
          end;
        end;
      end;

      if TThread.CurrentThread.CheckTerminated then
        exit();

      for i := 0 to length(CurrentAccount.myTokens) - 1 do
      begin

        if TThread.CurrentThread.CheckTerminated then
          exit();

        if CurrentAccount.myTokens[i].lastBlock = 0 then
          CurrentAccount.myTokens[i].lastBlock :=
            getHighestBlockNumber(CurrentAccount.myTokens[i]);

        highestBlock := CurrentAccount.myTokens[i].lastBlock;

        TokenDataArray[i] := getDataOverHTTP(HODLER_ETH +
          '/?cmd=tokenHistory&addr=' + CurrentAccount.myTokens[i].addr +
          '&contract=' + CurrentAccount.myTokens[i].ContractAddress + '&bno=' +
          inttostr(highestBlock));

      end;

    end);
  getDataThread.FreeOnTerminate := true;

  getDataThread.Start;

  while (not getDataThread.Finished) do
  begin
    if TThread.CurrentThread.CheckTerminated then
    begin
      getDataThread.Terminate;
      exit();

    end;
    sleep(50);
  end;

  counter := 0;

  for i := 0 to length(CurrentAccount.myCoins) - 1 do
  begin

    if TThread.CurrentThread.CheckTerminated then
      exit();

    case CurrentAccount.myCoins[i].coin of
      4:
        begin
          parseETHHistory(CoinDataArray[counter], CurrentAccount.myCoins[i]);
          inc(counter);
        end
    else
      begin
        parseCoinHistory(CoinDataArray[counter], CurrentAccount.myCoins[i]);
        inc(counter);
      end;
    end;

  end;

  for i := 0 to length(CurrentAccount.myTokens) - 1 do
  begin

    if TThread.CurrentThread.CheckTerminated then
      exit();

    parseTokenHistory(TokenDataArray[i], CurrentAccount.myTokens[i]);
  end;

  setLength(TokenDataArray, 0);
  setLength(CoinDataArray, 0);

end;

procedure synchronizeAddresses;
var
  i: integer;
  counter: integer;
  highestBlock: System.uint64;
  CoinDataArray: array of String;
  TokenDataArray: array of String;
begin

  if CurrentAccount = nil then
    exit;

  // globalFiat := 0;
  setLength(CoinDataArray, length(CurrentAccount.myCoins) * 3);
  counter := 0;

  for i := 0 to length(CurrentAccount.myCoins) - 1 do
  begin

    if TThread.CurrentThread.CheckTerminated then
      exit();

    case CurrentAccount.myCoins[i].coin of

      0:
        begin
          CoinDataArray[counter] :=
            getDataOverHTTP(HODLER_URL + 'getSegwitBalance.php?coin=' +
            availablecoin[CurrentAccount.myCoins[i].coin].name + '&' +
            segwitParameters(CurrentAccount.myCoins[i]));
          inc(counter);
          CoinDataArray[counter] :=
            getDataOverHTTP(HODLER_URL + 'getSegwitUTXO.php?coin=' +
            availablecoin[CurrentAccount.myCoins[i].coin].name + '&' +
            segwitParameters(CurrentAccount.myCoins[i]));
          inc(counter);
        end;

      4:
        begin
          CoinDataArray[counter] :=
            getDataOverHTTP(HODLER_ETH + '/?cmd=accInfo&addr=' +
            CurrentAccount.myCoins[i].addr);
          inc(counter);
        end
    else
      begin
        CoinDataArray[counter] :=
          getDataOverHTTP(HODLER_URL + 'getBalance.php?coin=' + availablecoin
          [CurrentAccount.myCoins[i].coin].name + '&address=' +
          CurrentAccount.myCoins[i].addr);
        inc(counter);

        CoinDataArray[counter] :=
          getDataOverHTTP(HODLER_URL + 'getUTXO.php?coin=' + availablecoin
          [CurrentAccount.myCoins[i].coin].name + '&address=' +
          CurrentAccount.myCoins[i].addr);
        inc(counter);

      end;
    end;

    frmHome.DashBrdProgressBar.Value :=
      (95.0 / (length(CurrentAccount.myCoins) + length(CurrentAccount.myTokens))
      ) * (i + 1);
    frmHome.RefreshProgressBar.Value := frmHome.DashBrdProgressBar.Value;

  end;

  setLength(TokenDataArray, length(CurrentAccount.myTokens) * 2);

  for i := 0 to length(CurrentAccount.myTokens) - 1 do
  begin

    if TThread.CurrentThread.CheckTerminated then
      exit();

    TokenDataArray[2 * i] :=
      getDataOverHTTP(HODLER_ETH + '/?cmd=tokenInfo&addr=' +
      CurrentAccount.myTokens[i].addr + '&contract=' + CurrentAccount.myTokens
      [i].ContractAddress);

    if CurrentAccount.myTokens[i].lastBlock = 0 then
      CurrentAccount.myTokens[i].lastBlock :=
        getHighestBlockNumber(CurrentAccount.myTokens[i]);

    frmHome.DashBrdProgressBar.Value :=
      (95.0 / (length(CurrentAccount.myCoins) + length(CurrentAccount.myTokens))
      ) * (i + 1 + length(CurrentAccount.myCoins));

    frmHome.RefreshProgressBar.Value := frmHome.DashBrdProgressBar.Value;

    // highestBlock := myTokens[i].lastBlock;

    // TokenDataArray[2*i+1] := getDataOverHTTP(HODLER_ETH + '/?cmd=tokenHistory&addr=' +
    // myTokens[i].addr + '&contract=' + myTokens[i].ContractAddress + '&bno=' +
    // inttostr(highestBlock));

  end;

  if CurrentAccount = nil then
    exit;

  counter := 0;

  for i := 0 to length(CurrentAccount.myCoins) - 1 do
  begin

    if TThread.CurrentThread.CheckTerminated then
      exit();

    case CurrentAccount.myCoins[i].coin of
      4:
        begin
          parseDataForETH(CoinDataArray[counter], CurrentAccount.myCoins[i]);
          inc(counter);
        end
    else
      begin
        parseBalances(CoinDataArray[counter], CurrentAccount.myCoins[i]);
        inc(counter);

        CurrentAccount.myCoins[i].UTXO := parseUTXO(CoinDataArray[counter]);
        inc(counter);

        // parseCoinHistory( CoinDataArray[counter], myWallets[i]);
        // inc(counter);
      end;
    end;

  end;

  for i := 0 to length(CurrentAccount.myTokens) - 1 do
  begin

    if TThread.CurrentThread.CheckTerminated then
      exit();

    parseDataForERC20(TokenDataArray[2 * i], CurrentAccount.myTokens[i]);


    // parseTokenHistory( TokenDataArray[2*i+1], myTokens[i]);

  end;

  setLength(TokenDataArray, 0);
  setLength(CoinDataArray, 0);

  CurrentAccount.SaveFiles();
  firstSync := false;
end;

end.
