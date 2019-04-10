unit Bitcoin;

interface

uses
  SysUtils, secp256k1, HashObj, base58, coinData, Velthuis.BigIntegers,
  WalletStructureData, System.classes;

function reedemFromPub(pub: AnsiString): AnsiString;

function Bitcoin_PublicAddrToWallet(pub: AnsiString; netbyte: AnsiString = '00';
  scriptType: AnsiString = 'p2pkh'): AnsiString;

function Bitcoin_createHD(coinid, x, y: integer; MasterSeed: AnsiString)
  : TWalletInfo;

function createTransaction(from: TWalletInfo; sendto: AnsiString;
  Amount, Fee: BigInteger; inputs: TUTXOS; MasterSeed: AnsiString): AnsiString;

function sendCoinsTO(from: TWalletInfo; sendto: AnsiString;
  Amount, Fee: BigInteger; MasterSeed: AnsiString; coin: AnsiString = 'bitcoin')
  : AnsiString;
// function netbyteFromCoinID(coinid: integer): AnsiString;

function generatep2sh(pub, netbyte: AnsiString): AnsiString;

function generatep2pkh(pub, netbyte: AnsiString): AnsiString;

function generatep2wpkh(pub: AnsiString; hrp: AnsiString = 'bc'): AnsiString;

implementation

uses
  uHome, transactions, tokenData, bech32, misc, SyncThr, WalletViewRelated,
  KeypoolRelated,Nano , debugAnalysis ;

function Bitcoin_createHD(coinid, x, y: integer; MasterSeed: AnsiString)
  : TWalletInfo;
var
  pub: AnsiString;
  p: AnsiString;
begin

  p := priv256forhd(coinid, x, y, MasterSeed);
  pub := secp256k1_get_public(p);
  result := TWalletInfo.Create(coinid, x, y, Bitcoin_PublicAddrToWallet(pub,
    availablecoin[coinid].p2pk), '');
  result.pub := pub;
  result.isCompressed := true;
  wipeAnsiString(p);
  wipeAnsiString(MasterSeed);

end;

function generatep2pkh(pub, netbyte: AnsiString): AnsiString;
var
  s, r: AnsiString;
begin
  s := GetSHA256FromHex(pub);
  s := hash160FromHex(s);
  s := netbyte + s;
  r := GetSHA256FromHex(s);
  r := GetSHA256FromHex(r);
{$IF DEFINED(ANDROID) OR DEFINED(IOS)}
  s := s + copy(r, 0, 8);
{$ELSE}
  s := s + copy(r, 1, 8);
{$ENDIF}
  result := Encode58(s);

end;

function reedemFromPub(pub: AnsiString): AnsiString;
var
  s: AnsiString;
begin
  s := GetSHA256FromHex(pub);
  s := hash160FromHex(s);
  s := '0014' + s;
  result := s;
end;

function generatep2sh(pub, netbyte: AnsiString): AnsiString;
var
  s, r ,t: AnsiString;
begin
  s := GetSHA256FromHex(pub);
  s := hash160FromHex(s);
  s := '0014' + s;
  s := GetSHA256FromHex(s);
  s := hash160FromHex(s);
  s := netbyte + s;
  r := GetSHA256FromHex(s);
  t := GetSHA256FromHex(r);
{$IF DEFINED(ANDROID) OR DEFINED(IOS)}
  s := s + copy(t, 0, 8);
{$ELSE}
  s := s + copy(t, 1, 8);
{$ENDIF}
  result := Encode58(s) ;


end;

function generatep2wpkh(pub: AnsiString; hrp: AnsiString = 'bc'): AnsiString;
var
  s: AnsiString;
begin
  if hrp = '' then
    hrp := 'bc';
  s := GetSHA256FromHex(pub);
  s := hash160FromHex(s);
  result := segwit_addr_encode(hrp, 0, s);
end;

function Bitcoin_PublicAddrToWallet(pub: AnsiString; netbyte: AnsiString = '00';
  scriptType: AnsiString = 'p2pkh'): AnsiString;
begin
  result := 'UNKNOWN_SCRIPT_TYPE';
  if scriptType = 'p2pkh' then
    result := generatep2pkh(pub, netbyte);
  if scriptType = 'p2sh' then
    result := generatep2sh(pub, netbyte);
  if scriptType = 'p2wpkh' then
    result := generatep2wpkh(pub);

end;

function createSegwitTransaction(from: TWalletInfo; sendto: AnsiString;
  Amount, Fee: BigInteger; inputs: TUTXOS; MasterSeed: AnsiString): AnsiString;
var
  TXBIP143: TXBuilderBIP_143;
  diff: int64;
begin
  result := '';
  TXBIP143 := TXBuilderBIP_143.Create;
  TXBIP143.sender := from;
  TXBIP143.inputs := inputs;
  TXBIP143.MasterSeed := MasterSeed;
  TXBIP143.addOutput(sendto, Amount);
  diff := TXBIP143.getAllToSPent - (Amount.AsInt64 + Fee.AsInt64);
  if diff > 0 then
    TXBIP143.addOutput(KeypoolRelated.findUnusedChange(TXBIP143.sender,
      MasterSeed).addr, diff);
  if Length(TXBIP143.getAsHex(true)) mod 2 <> 0 then
  begin
    result := createSegwitTransaction(from, sendto, Amount, Fee, inputs,
      MasterSeed);
    wipeAnsiString(MasterSeed);
    exit;
  end;
  wipeAnsiString(MasterSeed);
  result := TXBIP143.getAsHex(true);
end;

function createTransaction(from: TWalletInfo; sendto: AnsiString;
  Amount, Fee: BigInteger; inputs: TUTXOS; MasterSeed: AnsiString): AnsiString;
var
  TX: TXBuilder;
  TXCash: TXBuilderBIP_143;
  diff: int64;
begin

  if not(from.coin in [3, 7]) then
  begin
    result := '';
    TX := TXBuilder.Create;
    TX.sender := from;
    TX.inputs := inputs;
    TX.MasterSeed := MasterSeed;
    TX.addOutput(sendto, Amount);
    diff := TX.getAllToSPent - (Amount.AsInt64 + Fee.AsInt64);
    if diff > 0 then
      TX.addOutput(KeypoolRelated.findUnusedChange(TX.sender, MasterSeed)
        .addr, diff);
    if Length(TX.getAsHex) mod 2 <> 0 then
    begin
      result := createTransaction(from, sendto, Amount, Fee, inputs,
        MasterSeed);
      wipeAnsiString(MasterSeed);
      exit;
    end;
    wipeAnsiString(MasterSeed);
    result := TX.getAsHex;
  end
  else
  begin
    result := '';
    TXCash := TXBuilderBIP_143.Create;
    TXCash.sender := from;
    TXCash.inputs := inputs;
    TXCash.MasterSeed := MasterSeed;
    TXCash.addOutput(sendto, Amount);
    diff := TXCash.getAllToSPent - (Amount.AsInt64 + Fee.AsInt64);
    if diff > 0 then
      TXCash.addOutput(KeypoolRelated.findUnusedChange(TXCash.sender,
        MasterSeed).addr, diff);
    if Length(TXCash.getAsHex) mod 2 <> 0 then
    begin
      result := createTransaction(from, sendto, Amount, Fee, inputs,
        MasterSeed);
      wipeAnsiString(MasterSeed);
      exit;
    end;
    wipeAnsiString(MasterSeed);
    result := TXCash.getAsHex;
  end;

end;

function canSegwit(inputs: TUTXOS): Boolean;
var
  i: integer;
begin
  result := false;
  for i := 0 to Length(inputs) - 1 do
  begin
    if inputType(inputs[i]) > 0 then
    begin
      result := true;
      exit;
    end;

  end;
end;

function sendCoinsTO(from: TWalletInfo; sendto: AnsiString;
  Amount, Fee: BigInteger; MasterSeed: AnsiString; coin: AnsiString = 'bitcoin')
  : AnsiString;
var
  TX: AnsiString;
  TXBuilder: TXBuilder_ETH;
  procedure cleanupSend;
  begin
     TThread.CreateAnonymousThread(
      procedure
      begin
        if CurrentCoin.description <> '__dashbrd__' then
        begin
          SyncThr.SynchronizeCryptoCurrency(CurrentAccount ,CurrentCoin);
          reloadWalletView;
        end;
      end).Start();
  end;
begin

  startFullfillingKeypool(MasterSeed);
  if CurrentCoin.coin=8 then begin
  TThread.CreateAnonymousThread(procedure begin
  nano_send(from,sendto,Amount,MasterSeed); wipeAnsiString(masterseed);end).Start;
  Sleep(3000);
  if NanoCoin(from).lastBlock<>'' then
    TX:='Transaction sent '+#13#10+NanoCoin(from).lastBlock else
    TX:='Transaction failed, please try again';

    cleanupSend;
    Exit(tx);


  end
  else
  begin


    if CurrentCoin.coin <> 4 then
    begin
      if ((CurrentCoin.coin in [0, 1, 5, 6])) and
        canSegwit(currentaccount.aggregateUTXO(from)) then
      begin
        TX := createSegwitTransaction(from, sendto, Amount, Fee,
          currentaccount.aggregateUTXO(from), MasterSeed);
      end
      else
      begin
        TX := createTransaction(from, sendto, Amount, Fee,
          currentaccount.aggregateUTXO(from), MasterSeed);
      end;
    end
    else
    begin
      TXBuilder := TXBuilder_ETH.Create;
      TXBuilder.sender := CurrentCoin;
      TXBuilder.nonce := TXBuilder.sender.nonce;
      TXBuilder.gasPrice := Fee;
      TXBuilder.value := Amount;
      TXBuilder.gasLimit := 21000;
      TXBuilder.receiver := StringReplace(sendto, '0x', '', [rfReplaceAll]);
      TXBuilder.data := '';
      if frmHome.isTokenTransfer then
      begin

        TXBuilder.value := BigInteger.Zero;
        TXBuilder.receiver := StringReplace(Token(CurrentCryptoCurrency)
          .ContractAddress, '0x', '', [rfReplaceAll]);
        TXBuilder.gasLimit := 66666;
        TXBuilder.data := 'a9059cbb000000000000000000000000' +
          StringReplace(sendto, '0x', '', [rfReplaceAll]) +
          BIntTo256Hex(Amount, 64);
      end;

      TXBuilder.createPreImage;
      TXBuilder.sign(MasterSeed);
      TX := TXBuilder.Image;
    end;
  end;
  result := TX;
  if TX <> '' then
  begin
    if frmHome.InstantSendSwitch.isChecked then
      coin := coin + '&mode=instant';


    result := getDataOverHTTP(HODLER_URL + 'sendTX.php?coin=' + coin + '&tx=' +
      TX + '&os=' + SYSTEM_NAME + '&appver=' + StringReplace(CURRENT_VERSION,
      '.', 'x', [rfReplaceAll]), false, true);
   cleanupSend;
  end;
end;

end.
