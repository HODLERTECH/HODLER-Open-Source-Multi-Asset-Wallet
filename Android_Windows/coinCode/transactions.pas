// Transactions unit, Copyleft 2018 FL4RE - Daniel Mazur

unit transactions;

interface

uses SysUtils, Bitcoin, Ethereum, secp256k1, base58, coinData,
  Velthuis.BigIntegers, WalletStructureData;

type
  TxBuilder = class

    constructor Create;
    procedure addToPreImage(data: AnsiString);
    procedure addOutput(address: AnsiString; amount: uint64); overload;
    procedure addOutput(address: AnsiString; amount: BigInteger); overload;
    procedure sign(i: integer); dynamic;
    procedure signAll;
    function getAllToSpent: uint64;
    function getHashType: system.UInt8;
    function getAsHex(segwit: boolean = false): AnsiString;
    function isP2PKH(netbyte: AnsiString): boolean;
    procedure setHeader;
    procedure signSegwit;
    procedure signLegacy(i: integer);
  public
    outputBuffer: AnsiString;
    preImage: AnsiString;
    Image: AnsiString;
    inputs: TUTXOS;
    sender: TWalletInfo;
    Fee: uint64;
    masterSeed: AnsiString;
    inputsBalance: uint64;
    outputsCount: integer;
    der: array of AnsiString;
  end;

type
  TXBuilderBIP_143 = class(TxBuilder)
    constructor Create;
    procedure sign(i: integer); override;

    procedure setHeader;
  end;

type
  TXBuilder_ETH = class
    constructor Create;
    procedure createPreImage;
    procedure sign(var masterSeed: AnsiString);
  public
    sender: TWalletInfo;
    nonce: system.UInt32;
    gasPrice: BigInteger;
    /// / system.uint64;
    gasLimit: system.UInt32;
    receiver: AnsiString;
    value: BigInteger;
    /// / system.uint64;
    data: AnsiString;
    v, r, s: AnsiString;
    preImage: AnsiString;
    Image: AnsiString;
  end;

implementation

uses misc, uhome;

constructor TXBuilder_ETH.Create;
begin
  nonce := 0;
  gasPrice := 0;
  gasLimit := 66666;
  receiver := '';
  value := 0;
  data := '';
  v := '';
  r := '';
  s := '';
  preImage := '';
  Image := '';
end;

procedure TXBuilder_ETH.createPreImage;
var
  tmp: AnsiString;
begin
  if nonce = 0 then
    preImage := preImage + '80'
  else
    preImage := preImage + inttoeth(nonce);
  tmp := inttoeth(gasPrice.AsInt64);
  preImage := preImage + inttohex($80 + (length(tmp) div 2), 2);
  preImage := preImage + tmp;
  tmp := inttoeth(gasLimit);
  preImage := preImage + inttohex($80 + (length(tmp) div 2), 2);
  preImage := preImage + tmp;
  tmp := (receiver);
  preImage := preImage + inttohex($80 + (length(tmp) div 2), 2);
  preImage := preImage + tmp;
  tmp := inttoeth(value);
  if value = 0 then
    preImage := preImage + '80'
  else
  begin
    preImage := preImage + inttohex($80 + (length(tmp) div 2), 2);
    preImage := preImage + tmp;
  end;
  if data = '' then
    preImage := preImage + '80'
  else
    preImage := preImage + 'b844';

  tmp := (data);
  // preImage := preImage + inttohex($80 + (length(tmp) div 2),2);
  preImage := preImage + tmp; // 1c8080
end;

procedure TXBuilder_ETH.sign(var masterSeed: AnsiString);
var
  hash, priv, pub, sig: AnsiString;
var
  l: integer;
begin
  l := (length(preImage) + 6);
  if l < 110 then
    hash := keccak256Hex(inttohex(($C0 + (l) div 2), 2) + preImage + '018080')
  else
    hash := keccak256Hex('f8' + inttohex(l div 2, 2) + preImage + '018080');
  if (sender.x = -1) and (sender.y = -1) then
  begin
    priv := speckDecrypt(TCA(masterSeed), sender.EncryptedPrivKey);
    pub := secp256k1_get_public(priv, not sender.isCompressed);
  end
  else
  begin
    priv := priv256forhd(sender.coin, sender.x, sender.y, masterSeed);
    pub := secp256k1_get_public(priv);
  end;
  sig := secp256k1_signDER(hash, priv, true);
  wipeAnsiString(priv);
  wipeAnsiString(masterSeed);

  preImage := preImage + sig;
  Image := 'f8' + inttohex($00 + (length(preImage) div 2), 2) + preImage;
end;

constructor TXBuilderBIP_143.Create;
begin
  inherited
end;

procedure TXBuilderBIP_143.setHeader;
begin
  addToPreImage(inttotx(1, 8)); // Version
end;

procedure TxBuilder.signLegacy(i: integer);
var
  k: integer;
  txhash, priv, pub, scriptSig: AnsiString;
  scriptCode: AnsiString;
  reedem: AnsiString;
  Y:integer;
begin
  preImage := '';
  setHeader;
  inputsBalance := 0;
  for k := 0 to length(inputs) - 1 do
  begin
    addToPreImage(ReverseHexOrder(inputs[k].txid));
    addToPreImage(inttotx(inputs[k].n, 8));
    if i = k then
    begin
      Y:=inputs[k].Y;
      scriptCode := inputs[k].ScriptPubKey;
      addToPreImage(inttotx(length(scriptCode) div 2, 2));
      addToPreImage(scriptCode);
    end
    else
    begin
      addToPreImage('00');
    end;
    addToPreImage('ffffffff');

    inputsBalance := inputsBalance + inputs[k].amount;
  end;
  addToPreImage(inttotx(outputsCount, 2));
  addToPreImage(outputBuffer);
  addToPreImage(inttotx(0, 8) + inttotx(getHashType, 8));
  txhash := (GetSha256FromHex(GetSha256FromHex(preImage)));
  if (sender.x = -1) and (sender.y = -1) then
  begin
    priv := speckDecrypt(TCA(masterSeed), sender.EncryptedPrivKey);
    pub := secp256k1_get_public(priv, not sender.isCompressed);
  end
  else
  begin
    priv := priv256forhd(sender.coin, sender.x, Y, masterSeed);
    pub := secp256k1_get_public(priv);
  end;
  scriptSig := secp256k1_signDER(txhash, priv);
  der[i] := inttotx((length(scriptSig) + 2) div 2, 2) + scriptSig +
    inttotx(getHashType and 255, 2);
  der[i] := der[i] + inttotx((length(pub)) div 2, 2) + pub;

  wipeAnsiString(priv);
end;

procedure TXBuilderBIP_143.sign(i: integer);
var
  k: integer;
  hash1, hash2: AnsiString;
  txhash, priv, pub, scriptSig, scriptCode, reedem: AnsiString;
  Y:integer;
begin
  preImage := '';
  setHeader;
  Y:= inputs[i].Y;
//  pub := currentCoin.pub;
  pub:= CurrentAccount.getSibling(CurrentCoin,Y).pub;


  inputsBalance := 0;
  hash1 := '';
  hash2 := '';
  for k := 0 to length(inputs) - 1 do
  begin
    hash1 := hash1 + ReverseHexOrder(inputs[k].txid) + inttotx(inputs[k].n, 8);
    hash2 := hash2 + 'ffffffff';
  end;
  addToPreImage(GetSha256FromHex(GetSha256FromHex(hash1)));
  addToPreImage(GetSha256FromHex(GetSha256FromHex(hash2)));
  addToPreImage(ReverseHexOrder(inputs[i].txid));
  addToPreImage(inttotx(inputs[i].n, 8));

  scriptCode := inputs[i].ScriptPubKey;

  if inputType(inputs[i]) = 2 then
  begin
    delete(scriptCode, 1, 2);
    scriptCode := '76a9' + scriptCode + '88ac';
  end;
  if inputType(inputs[i]) = 1 then
  begin
    scriptCode := reedemFromPub(pub);
    delete(scriptCode, 1, 2);
    scriptCode := '76a9' + scriptCode + '88ac';
  end;

  addToPreImage(inttotx(length(scriptCode) div 2, 2));
  addToPreImage(scriptCode);
  addToPreImage(inttotx(inputs[i].amount, 16));
  addToPreImage('ffffffff');

  addToPreImage(GetSha256FromHex(GetSha256FromHex(outputBuffer)));

  addToPreImage(inttotx(0, 8) + inttotx(getHashType, 8));
  txhash := (GetSha256FromHex(GetSha256FromHex(preImage)));
  if (sender.x = -1) and (sender.y = -1) then
  begin
    priv := speckDecrypt(TCA(masterSeed), sender.EncryptedPrivKey);
    pub := secp256k1_get_public(priv, not sender.isCompressed);
  end
  else
  begin
    priv := priv256forhd(sender.coin, sender.x, Y, masterSeed);
    pub := secp256k1_get_public(priv);
  end;
  scriptSig := secp256k1_signDER(txhash, priv);
  der[i] := inttotx((length(scriptSig) + 2) div 2, 2) + scriptSig +
    inttotx(getHashType and 255, 2);
  der[i] := der[i] + inttotx((length(pub)) div 2, 2) + pub;
  wipeAnsiString(priv);
end;

constructor TxBuilder.Create;
begin
  outputBuffer := '';
  inputsBalance := 0;
  outputsCount := 0;
  Fee := 0;
  preImage := '';
  Image := '';
end;

function TxBuilder.getHashType: system.UInt8;
begin
  if sender.coin = 3 then
    result := $01 or $40
  else
    result := $01;
end;

function TxBuilder.getAllToSpent(): uint64;
var
  i: integer;
begin
  result := 0;
  for i := 0 to length(inputs) - 1 do
    result := result + inputs[i].amount;
end;

function TxBuilder.isP2PKH(netbyte: AnsiString): boolean;
begin
  result := availablecoin[sender.coin].p2pk = netbyte;

end;

procedure TxBuilder.addToPreImage(data: AnsiString);
begin
  preImage := preImage + data;
end;

procedure TxBuilder.setHeader;
begin
  addToPreImage(inttotx(1, 8)); // Version
  addToPreImage(inttotx(length(inputs), 2)); // Count of UTXO

end;

procedure TxBuilder.addOutput(address: AnsiString; amount: uint64);
var
  outputScript: AnsiString;
  outData: TAddressInfo;
begin
  inc(outputsCount);
  outData := decodeAddressInfo(address, currentCoin.coin);
  outputScript := outData.outputScript;

  outputBuffer := outputBuffer + (inttotx(amount, 16));
  outputBuffer := outputBuffer + (inttotx(length(outputScript), 2) +
    outputScript);
end;

procedure TxBuilder.addOutput(address: AnsiString; amount: BigInteger);
var
  outputScript: AnsiString;
  outData: TAddressInfo;
begin
  inc(outputsCount);
  outData := decodeAddressInfo(address, currentCoin.coin);
  outputScript := outData.outputScript;

  outputBuffer := outputBuffer + (inttotx(amount, 16));
  outputBuffer := outputBuffer + (inttotx(length(outputScript) div 2, 2) +
    outputScript);

end;

procedure TxBuilder.sign(i: integer);
var
  k: integer;
  txhash, priv, pub, scriptSig: AnsiString;
  scriptCode: AnsiString;
  reedem: AnsiString;
  Y:integer;
begin
  preImage := '';
  setHeader;
  inputsBalance := 0;
  for k := 0 to length(inputs) - 1 do
  begin
    addToPreImage(ReverseHexOrder(inputs[k].txid));
    addToPreImage(inttotx(inputs[k].n, 8));
    if i = k then
    begin

      scriptCode := inputs[k].ScriptPubKey;
      Y:=inputs[k].Y;
      addToPreImage(inttotx(length(scriptCode) div 2, 2));
      addToPreImage(scriptCode);
    end
    else
    begin
      addToPreImage('00');
    end;
    addToPreImage('ffffffff');

    inputsBalance := inputsBalance + inputs[k].amount;
  end;
  addToPreImage(inttotx(outputsCount, 2));
  addToPreImage(outputBuffer);
  addToPreImage(inttotx(0, 8) + inttotx(getHashType, 8));
  txhash := (GetSha256FromHex(GetSha256FromHex(preImage)));
  if (sender.x = -1) and (sender.y = -1) then
  begin
    priv := speckDecrypt(TCA(masterSeed), sender.EncryptedPrivKey);
    pub := secp256k1_get_public(priv, not sender.isCompressed);
  end
  else
  begin
    priv := priv256forhd(sender.coin, sender.x, Y, masterSeed);
    pub := CurrentAccount.getSibling(CurrentCoin,Y).pub;
  end;

  scriptSig := secp256k1_signDER(txhash, priv);
  der[i] := inttotx((length(scriptSig) + 2) div 2, 2) + scriptSig +
    inttotx(getHashType and 255, 2);
  der[i] := der[i] + inttotx((length(pub)) div 2, 2) + pub;

  wipeAnsiString(priv);
end;

procedure TxBuilder.signSegwit;
var
  i: integer;
begin
  for i := 0 to length(inputs) - 1 do
  begin
    if inputType(inputs[i]) = 0 then
      signLegacy(i)
    else

      sign(i);
  end;
end;

procedure TxBuilder.signAll;
var
  i: integer;
begin
  for i := 0 to length(inputs) - 1 do
  begin
    sign(i);
  end;
end;

function TxBuilder.getAsHex(segwit: boolean = false): AnsiString;
var
  i: integer;
  pub: AnsiString;
  witness: AnsiString;
  reedem: AnsiString;
begin
  if Image <> '' then
  begin
    result := Image;
    exit;
  end;
  if length(inputs) = 0 then
    exit;
  preImage := '';
  witness := '';
  SetLength(der, length(inputs));
  if not segwit then
    signAll
  else
    signSegwit;
  preImage := '';

  if not segwit then
    setHeader
  else
  begin
    addToPreImage('010000000001'); // marker and flag for segwit
    addToPreImage(inttotx(length(inputs), 2));
  end;
  for i := 0 to length(inputs) - 1 do
  begin
    addToPreImage(ReverseHexOrder(inputs[i].txid));
    addToPreImage(inttotx(inputs[i].n, 8));

    if not segwit then
    begin
      addToPreImage(inttotx(length(der[i]) div 2, 2));
      addToPreImage(der[i]);

    end
    else
    begin
      case inputType(inputs[i]) of
        0:
          begin
            addToPreImage(inttotx(length(der[i]) div 2, 2));
            addToPreImage(der[i]);
            witness := witness + '00';
          end;
        1:
          begin
            reedem := reedemFromPub(CurrentAccount.getSibling(CurrentCoin,inputs[i].Y).pub);
            addToPreImage('1716' + reedem);
            witness := witness + '02' + der[i];
          end;
        2, 3:
          begin
            addToPreImage('00');
            witness := witness + '02' + der[i];
          end;
      end;

    end;
    addToPreImage('ffffffff');

  end;
  addToPreImage(inttotx(outputsCount, 2));
  addToPreImage(outputBuffer);
  // witness
  if segwit then
    addToPreImage(witness);

  addToPreImage(inttotx(0, 8));
  Image := preImage;
  result := Image;
end;

end.
