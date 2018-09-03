unit secp256k1;

{ ******************
  Big thanks to Velthuis for his BigInteger
  You saved my ass :)


  Multiplatform ECDSA Pair creation in pure Pascal
  ****************** }
{$DEFINE PUREPASCAL}

interface

uses Velthuis.BigIntegers, misc, System.SysUtils;

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

uses uHome;

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
begin
  xp := p.XCoordinate;
  yp := p.YCoordinate;
  xq := q.XCoordinate;
  yq := q.YCoordinate;
  if cmpecp(p, q) then
  begin

    // L:= (3*xp*xp) * BigInteger.ModPow((yp * BigInteger.Parse('2')), getP - BigInteger.Parse('2'), getP);
    L := (BigInteger.ModPow((yp * BigInteger.Parse('2')) mod getP,
      getP - BigInteger.Parse('2'), getP) * (3 * xp * xp)) mod getP
  end
  else
  begin
    // L:= (yq-yp) * BigInteger.ModPow(xq-xp,getP-BigInteger.Parse('2'),getP);
    L := (BigInteger.ModPow(xq - xp, getP - BigInteger.Parse('2'), getP) *
      (yq - yp)) mod getP;
  end;

  rx := (BigInteger.Pow(L, 2) - xp) - xq;
  ry := (L * xp) - (L * rx) - yp;
  result.XCoordinate := rx mod getP;
  result.YCoordinate := ry mod getP;
end;

function point_mul(p: TBIPoint; d: BigInteger): TBIPoint;
var
  G, n, q: TBIPoint;
var
  i: integer;
  tmp: BigInteger;
begin
  n.XCoordinate := p.XCoordinate;
  n.YCoordinate := p.YCoordinate;
  q.XCoordinate := BigInteger.Zero;
  q.YCoordinate := BigInteger.Zero;
  for i := 0 to 255 do
  begin
    tmp := (BigInteger.One shl i);
    if (d and tmp <> BigInteger.Zero) then
    begin
      if (q.XCoordinate = BigInteger.Zero) and (q.YCoordinate = BigInteger.Zero)
      then
      begin
        q := n
      end
      else
      begin

        q := point_add(q, n);

      end;
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
begin
  BigInteger.Decimal;
  BigInteger.AvoidPartialFlagsStall(True);
  ss := '$' + (privkey);
  q := point_mul(getG, ss);
  q.YCoordinate := make256bit(q.YCoordinate);
  q.XCoordinate := make256bit(q.XCoordinate);
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

function GetDetermisticRandomForSign(d: AnsiString): BigInteger;
begin

  result := BigInteger.Parse
    ('+0x00' + BigInteger(BigInteger.Parse('+0x00' +
    GetSHA256FromHex(inttohex(random($FFFFFFFF), 8) + d + randomHexStream(64) +
    inttohex(random($FFFFFF), 32))) mod (getN div 4)).ToHexString);

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
  k := GetDetermisticRandomForSign(d); // mod getN;
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
  // recid:=BigInteger(( mod BigInteger.Parse('2'))).AsInteger;

  if (s > (getN div BigInteger.Parse('2'))) then
  begin
    s := getN - s;
    recid := recid xor 1;
  end;
  recid := 37 + (recid);
  // DER Format
  sr := BIToHEX(r); // r.TOHexString;
  ss := BIToHEX(s); // s.ToHexString;
  // frmHome.Memo1.Lines.Clear;
  if Length(sr + ss) mod 2 <> 0 then
  begin
    result := secp256k1_signDER(e, d);
    exit;
  end;

  // FrmHome.memo1.lines.Add(sr+ss);
  if forEth then
  begin
    result := inttohex(recid, 2);
    result := result + 'a0' + sr + 'a0' + ss;
  end
  else
  begin
    b := System.UInt8(strtoint('$' + copy(sr, 0, 2)));
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
