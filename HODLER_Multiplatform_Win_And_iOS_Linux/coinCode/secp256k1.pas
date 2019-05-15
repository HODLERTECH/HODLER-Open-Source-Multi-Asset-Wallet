unit secp256k1;

{ ******************
  Big thanks to Velthuis for his BigInteger
  You saved my ass :)


  Multiplatform ECDSA Pair creation in pure Pascal
  ****************** {$DEFINE PUREPASCAL }

interface

uses
  Velthuis.BigIntegers, misc, System.SysUtils, ClpBigInteger,
  ClpIX9ECParameters,
  ClpIECDomainParameters, ClpECDomainParameters, ClpIECKeyPairGenerator,
  ClpECKeyPairGenerator, ClpIECKeyGenerationParameters,
  ClpIAsymmetricCipherKeyPair, ClpIECPrivateKeyParameters,
  ClpIECPublicKeyParameters, ClpECPrivateKeyParameters, ClpIECInterface, ClpHex,
  ClpCustomNamedCurves, ClpHMacDsaKCalculator, ClpDigestUtilities;

type
  TBIPoint = record
    XCoordinate: BigInteger;
    YCoordinate: BigInteger;
  end;

function make256bit(var bi: BigInteger): BigInteger;

function secp256k1_get_public(privkey: AnsiString; forEth: boolean = false)
  : AnsiString;

function secp256k1_signDER(e, d: AnsiString; forEth: boolean = false)
  : AnsiString;

function getG: TBIPoint;

function getN: BigInteger;

function BIToHEX(bi: BigInteger): AnsiString;

implementation

uses
  uHome;

function getG: TBIPoint;
var
  tmp: BigInteger;
begin
  result.XCoordinate := BigInteger.Parse
    ('0x079BE667EF9DCBBAC55A06295CE870B07029BFCDB2DCE28D959F2815B16F81798');
  result.YCoordinate := BigInteger.Parse
    ('0x0483ADA7726A3C4655DA4FBFC0E1108A8FD17B448A68554199C47D08FFB10D4B8');
end;

function make256bit(var bi: BigInteger): BigInteger;
begin
  if bi.IsNegative then
    bi := bi + BigInteger.Parse
      ('+0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFEFFFFFC2F')
  else
    bi := bi mod BigInteger.Parse
      ('+0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF');
  result := bi;
end;

function getP: BigInteger;
begin
  result := BigInteger.Parse
    ('+0x0FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFEFFFFFC2F');
end;

function getN: BigInteger;
begin
  result := BigInteger.Parse
    ('+0x00FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFEBAAEDCE6AF48A03BBFD25E8CD0364141');
end;

function cmpecp(p, q: TBIPoint): boolean;
begin

  result := (p.XCoordinate = q.XCoordinate) and (p.YCoordinate = q.YCoordinate)

end;

function BIToHEX(bi: BigInteger): AnsiString;
var
  i: integer;
  b: TArray<Byte>;
begin
  bi := bi mod BigInteger.Parse
    ('0x10000000000000000000000000000000000000000000000000000000000000000');
  b := bi.ToByteArray;
  result := '';

  for i := 31 downto Low(b) do
  begin
    result := result + inttohex(System.UInt8(b[i]), 2);
  end;

end;

function point_add(p, q: TBIPoint): TBIPoint;
var
  xp, yp, xq, yq, L, rx, ry: BigInteger;
  bitwo, biP: BigInteger;
begin
  // Android optimalisations
  bitwo := BigInteger.Parse('2');
  biP := getP;
  /// ///////////////////
  xp := p.XCoordinate;
  yp := p.YCoordinate;
  xq := q.XCoordinate;
  yq := q.YCoordinate;
  if cmpecp(p, q) then
    L := (BigInteger.ModPow((yp * bitwo) mod biP, biP - bitwo, biP) *
      (3 * xp * xp)) mod biP
  else
    L := (BigInteger.ModPow(xq - xp, biP - bitwo, biP) * (yq - yp)) mod biP;

  rx := (BigInteger.Pow(L, 2) - xp) - xq;
  ry := (L * xp) - (L * rx) - yp;
  result.XCoordinate := rx mod biP;
  result.YCoordinate := ry mod biP;
end;

function point_mul(p: TBIPoint; d: BigInteger): TBIPoint;
var
  G, n, q: TBIPoint;
var
  i: integer;
  tmp: BigInteger;
  bi0, bi1: BigInteger;
begin
  bi0 := BigInteger.Zero;
  bi1 := BigInteger.One;
  n.XCoordinate := p.XCoordinate;
  n.YCoordinate := p.YCoordinate;
  q.XCoordinate := bi0;
  q.YCoordinate := bi0;
  for i := 0 to 255 do
  begin
    tmp := (bi1 shl i);
    if (d and tmp <> bi0) then
    begin
      if (q.XCoordinate = bi0) and (q.YCoordinate = bi0) then
        q := n
      else
        q := point_add(q, n);

    end;
    n := point_add(n, n);

  end;
  result := q;
end;

function secp256k1_get_public(privkey: AnsiString; forEth: boolean = false)
  : AnsiString;
var
  q: TBIPoint;
  ss: AnsiString;
  sign: AnsiString;
var
  domain: IECDomainParameters;
  generator: IECKeyPairGenerator;
  keygenParams: IECKeyGenerationParameters;
  KeyPair: IAsymmetricCipherKeyPair;
  privParams: IECPrivateKeyParameters;
  pubParams: IECPublicKeyParameters;
  FCurve: IX9ECParameters;
  PrivateKeyBytes, PayloadToDecodeBytes, DecryptedCipherText: TBytes;
  RegeneratedPublicKey: IECPublicKeyParameters;
  RegeneratedPrivateKey: IECPrivateKeyParameters;
  PrivD: TBigInteger;
  ax, ay: BigInteger;
begin
  BigInteger.Decimal;
  BigInteger.AvoidPartialFlagsStall(True);

  ss := '$' + (privkey);
  /// / Hyperspeed
  FCurve := TCustomNamedCurves.GetByName('secp256k1');
  domain := TECDomainParameters.Create(FCurve.Curve, FCurve.G, FCurve.n,
    FCurve.H, FCurve.GetSeed);
  PrivateKeyBytes := THex.Decode(privkey);
  PrivD := TBigInteger.Create(1, PrivateKeyBytes);
  RegeneratedPrivateKey := TECPrivateKeyParameters.Create('ECDSA',
    PrivD, domain);

  RegeneratedPublicKey := TECKeyPairGenerator.GetCorrespondingPublicKey
    (RegeneratedPrivateKey);
  ax := BigInteger.Parse('+0x00' + RegeneratedPublicKey.q.Normalize.
    AffineXCoord.ToBigInteger.ToString(16));
  ay := BigInteger.Parse('+0x00' + RegeneratedPublicKey.q.Normalize.
    AffineYCoord.ToBigInteger.ToString(16));
  /// / Hyperspeed
  // q := point_mul(getG, ss);
  q.YCoordinate := make256bit(ay);
  q.XCoordinate := make256bit(ax);
  if q.YCoordinate.isEven then
    sign := '02'
  else
    sign := '03';
  if not forEth then
    result := sign + BIToHEX(q.XCoordinate)
  else
    result := '04' + BIToHEX(q.XCoordinate) + BIToHEX(q.YCoordinate);
  wipeAnsiString(ss);
  wipeAnsiString(privkey);


end;

function GetDetermisticRandomForSign(e, d: AnsiString): BigInteger;
var
  hmac: THMacDsaKCalculator;
var
  xn, xd: TBigInteger;
  xe: TBytes;
begin
  /// RFC 6979 - "Deterministic Usage of the Digital
  /// Signature Algorithm (DSA) and Elliptic Curve Digital Signature
  /// Algorithm (ECDSA)".
  hmac := THMacDsaKCalculator.Create(TDigestUtilities.GetDigest('SHA-256'));
  xn := TBigInteger.Create
    ('FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFEBAAEDCE6AF48A03BBFD25E8CD0364141', 16);
  xd := TBigInteger.Create(d, 16);
  xe := THex.Decode(e);
  hmac.Init(xn, xd, xe);
  result := BigInteger.Parse('+0x00' + THex.Encode(hmac.NextK.ToByteArray));
  hmac.Free;
  wipeAnsiString(d);
end;

function secp256k1_signDER(e, d: AnsiString; forEth: boolean = false)
  : AnsiString;
var
  C: TBIPoint;
  r, s: BigInteger;
  k: BigInteger;
  sr, ss: AnsiString;
  b, recid: System.UInt8;
  overflow: System.UInt8;
begin
  overflow := 0;
  BigInteger.Decimal;
  BigInteger.AvoidPartialFlagsStall(True);
  k := GetDetermisticRandomForSign(e, d); // mod getN;
  C := point_mul(getG, k);

  if C.YCoordinate.IsNegative then
    C.YCoordinate := C.YCoordinate + BigInteger.Parse
      ('+0x0FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFEFFFFFC2F');;
  if C.XCoordinate.IsNegative then
    C.XCoordinate := C.XCoordinate + BigInteger.Parse
      ('+0x0FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFEFFFFFC2F');

  r := C.XCoordinate mod getN;
  // s=(e+rd)/k
  s := BigInteger.ModInverse(k, getN) *
    (BigInteger.Parse('+0x0' + (e)) +
    (BigInteger(r * BigInteger.Parse('+0x0' + d)) mod getN)) mod getN;
  if C.YCoordinate.isEven then
    recid := 0
  else
    recid := 1;

  if (s > (getN div BigInteger.Parse('2'))) then
  begin
    s := getN - s;
    recid := recid xor 1;
  end;
  recid := 37 + (recid);
  sr := BIToHEX(r);
  ss := BIToHEX(s);
  if Length(sr + ss) mod 2 <> 0 then
  begin
    result := secp256k1_signDER(e, d);
    exit;
  end;

  if forEth then
  begin
    result := inttohex(recid, 2);
    result := result + 'a0' + sr + 'a0' + ss;
  end
  else
  begin
    b := System.UInt8(strtointdef('$' + copy(sr, 0, 2),0));
    if b >= System.UInt8($80) then
      sr := '00' + sr;
    result := ss;
    result := '02' + IntToTx(Length(ss) div 2, 2) + result;
    result := sr + result;
    result := '02' + IntToTx(Length(sr) div 2, 2) + result;
    result := '30' + IntToTx(Length(result) div 2, 2) + result;
  end;
end;

end.
