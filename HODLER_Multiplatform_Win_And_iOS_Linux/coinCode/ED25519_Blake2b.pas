// Nanocurrency EdDSA unit, Copyleft 2019 FL4RE - Daniel Mazur

unit ED25519_Blake2b;

interface

uses
  System.SysUtils, Velthuis.BigIntegers, ClpBigInteger, HlpBlake2BConfig,
  HlpBlake2B, HlpHashFactory, ClpDigestUtilities, HlpIHash, misc, secp256k1;

function nano_privToPub(sk: AnsiString): AnsiString;

function nano_signature(m, sk, pk: AnsiString): AnsiString;

implementation

type
  EDPoint = array[0..3] of BigInteger;

var
  Bpow: array[0..252] of EdPoint;

function pymodulus(left, right: BigInteger): BigInteger;
begin
  left := left mod right;
  while (left < 0) do
    left := left + right;
  result := left;
  //thx Piter
end;

function getB: BigInteger;
begin
  Exit(256)
end;

function getQ: BigInteger;
begin
  Exit((BigInteger.Pow(2, 255) - 19))
end;

function getL: BigInteger;
begin
  Exit(BIgInteger.Pow(2, 252) + BigInteger.Parse('27742317777372353535851937790883648493'));
end;

function H(m: AnsiString): AnsiString;
var
  Blake2b: IHash;
begin
  Blake2b := THashFactory.TCrypto.CreateBlake2B_512();
  Blake2b.Initialize();
  Blake2b.TransformBytes(hexatotbytes(m), 0, Length(m) div 2);
  Result := Blake2b.TransformFinal.ToString();
end;

function pow2(x, p: BigInteger): BigInteger;
begin
  while p > 0 do
  begin

    x := pymodulus(BigInteger.Multiply(x, x), getQ);
    p := p - 1;
  end;
  Exit(x);
end;

function inv(z: BigInteger): BigInteger;
var
  z2, z9, z11, z2_5_0, z2_10_0, z2_20_0, z2_40_0, z2_50_0, z2_100_0, z2_200_0, z2_250_0: BigInteger;
begin
  z2 := pymodulus(z * z, getQ);
  z9 := pymodulus(Pow2(z2, 2) * z, getQ);
  z11 := pymodulus(z9 * z2, getQ);
  z2_5_0 := pymodulus((z11 * z11), getQ) * pymodulus(z9, getQ);
  z2_10_0 := pymodulus(pow2(z2_5_0, 5) * z2_5_0, getQ);
  z2_20_0 := pymodulus(pow2(z2_10_0, 10) * z2_10_0, getQ);
  z2_40_0 := pymodulus(pow2(z2_20_0, 20) * z2_20_0, getQ);
  z2_50_0 := pymodulus(pow2(z2_40_0, 10) * z2_10_0, getQ);
  z2_100_0 := pymodulus(pow2(z2_50_0, 50) * z2_50_0, getQ);
  z2_200_0 := pymodulus(pow2(z2_100_0, 100) * z2_100_0, getQ);
  z2_250_0 := pymodulus(Pow2(z2_200_0, 50) * z2_50_0, getQ);
  Exit(pymodulus(pow2(z2_250_0, 5) * z11, getQ));
end;

function getD: BigInteger;
begin
  Exit(-121665 * inv(121666) mod getQ);
end;

function getI: BigInteger;
begin
  Exit(BigInteger.ModPow(2, (getQ - 1) div 4, getQ));
end;

function xrecover(y: BigInteger): BigInteger;
var
  xx, x: BigInteger;
begin
  xx := (y * y - 1) * inv(getD * y * y + 1);
  x := BigInteger.ModPow(xx, (getQ + 3) div 8, getQ);
  if (x * x - xx) mod getQ <> 0 then
    x := pymodulus((x * getI), getQ);
  if x mod 2 <> 0 then
    x := getQ - x;
  Exit(x);
end;

function By: BigInteger;
begin
  Exit(4 * inv(5));
end;

function Bx: BigInteger;
begin
  Exit(xrecover(By));
end;

function B: EdPoint;
begin
  Result[0] := pymodulus(Bx, getQ);
  Result[1] := pymodulus(By, getQ);
  Result[2] := 1;
  Result[3] := pymodulus((Bx * By), getQ);
end;

function ident: EDPoint;
begin
  result[0] := 0;
  Result[1] := 1;
  Result[2] := 1;
  Result[3] := 0;
end;

function edwards_add(P, Q: EDPoint): EDPoint;
var
  x1, y1, z1, t1, x2, y2, z2, t2, a, b, c, dd, e, f, g, h, x3, y3, t3, z3: BigInteger;
begin
  x1 := P[0];
  y1 := P[1];
  z1 := P[2];
  t1 := P[3];
  x2 := Q[0];
  y2 := Q[1];
  z2 := Q[2];
  t2 := Q[3];
  a := pymodulus((y1 - x1) * (y2 - x2), getQ);
  b := pymodulus((y1 + x1) * (y2 + x2), getQ);
  c := pymodulus(t1 * 2 * getD * t2, getQ);
  dd := pymodulus(z1 * 2 * z2, getQ);
  e := b - a;
  f := dd - c;
  g := dd + c;
  h := b + a;
  x3 := e * f;
  y3 := g * h;
  t3 := e * h;
  z3 := f * g;

  Result[0] := pymodulus(x3, getq);
  Result[1] := pymodulus(y3, getq);
  Result[2] := pymodulus(z3, getQ);
  Result[3] := pymodulus(t3, GetQ);
end;

function edwards_double(P: EDPoint): EDPoint;
var
  x1, y1, z1, t1, a, b, c, e, g, f, h, x3, y3, t3, z3: BigInteger;
begin
  x1 := P[0];
  y1 := P[1];
  z1 := P[2];
  t1 := P[3];
  a := pymodulus((x1 * x1), getq);
  b := pymodulus((y1 * y1), getq);
  c := pymodulus((2 * z1 * z1), getQ);
  e := pymodulus((((x1 + y1) * (x1 + y1)) - a - b), getQ);
  g := (0 - a + b);
  f := (g - c);
  h := (0 - a - b);
  x3 := (e * f);   //
  y3 := (g * h);
  t3 := (e * h);
  z3 := (f * g); //
  Result[0] := pymodulus(x3, getQ);
  Result[1] := pymodulus(y3, getQ);
  Result[2] := pymodulus(z3, getQ);
  Result[3] := pymodulus(t3, getQ);
end;

function scalarmult(P: EDPoint; e: Integer): EDPoint;
var
  Q: EDPoint;
begin
  if e = 0 then
    Exit(ident);
  Q := scalarmult(P, e div 2);
  Q := edwards_double(Q);
  if e and 1 = 1 then
    Q := edwards_add(Q, P);

  result := Q;
end;

procedure make_Bpow;
var
  P: EDPoint;
  i: integer;
begin
  P := b;
  for i := 0 to 252 do
  begin
    Bpow[i] := P;
    P := edwards_double(P);
  end;

end;

function scalarmult_B(e: BigInteger): EdPoint;
var
  P: EDPoint;
  i: Integer;
begin
  e := e mod getL;
  P := ident;
  for i := 0 to 252 do
  begin
    if e and 1 = 1 then
      P := edwards_add(P, Bpow[i]);
    e := e div 2;
  end;
  result := P;
end;

function encodeint(y: BigInteger): AnsiString;
var
  i: integer;
  bitString: string;
  sum, j: integer;
  bb: system.UInt8;
begin
  result := '';
  bitString := '';
  for i := 0 to 255 do
    if (y shr i) and 1 = 1 then
      bitString := bitString + '1'
    else
      bitString := bitString + '0';
  for i := 0 to 31 do
  begin
    sum := 0;
    for j := 0 to 7 do
    begin
      bb := StrToIntdef(bitString[{$IF DEFINED(MSWINDOWS) OR DEFINED(LINUX)}1 + {$ENDIF}(i * 8 + j)],0);
      sum := sum + system.uint8(bb shl j)
    end;
    result := result + inttohex(sum, 2);
  end;
  bitString := '';

end;

function encodepoint(P: EDPoint): AnsiString;
var
  zi, x, y, z, t: BigInteger;
  bi: BigInteger;
  bitString: string;
  i, j: integer;
  sum: integer;
  bb: system.uint8;
begin
  result := '';
  x := P[0];
  y := P[1];
  z := P[2];
  t := P[3];
  zi := inv(z);
  x := pymodulus((x * zi), getQ);
  y := pymodulus((y * zi), getQ);
  bitString := '';
  for i := 0 to 254 do
    if (y shr i) and 1 = 1 then
      bitString := bitString + '1'
    else
      bitString := bitString + '0';
  if x and 1 = 1 then
    bitString := bitString + '1'
  else
    bitString := bitString + '0';

  for i := 0 to 31 do
  begin
    sum := 0;
    for j := 0 to 7 do
    begin
      bb := StrToIntdef(bitString[{$IF DEFINED(MSWINDOWS) OR DEFINED(LINUX)}1 + {$ENDIF}(i * 8 + j)],0);
      sum := sum + system.uint8(bb shl j)
    end;
    result := result + inttohex(sum, 2);
  end;
  bitString := '';
end;

function bit(h: TBytes; i: Integer): integer;
begin
  Result := (h[i div 8] shr (i mod 8)) and 1;
end;

function nano_privToPub(sk: AnsiString): AnsiString;
var
  a: BigInteger;
  sum: BigInteger;
  i: integer;
  tb: Integer;
  AP: EDPoint;
  bextsk: tArray<Byte>;
  s: ansistring;
begin
  bextsk := hexatotbytes(h(sk));
{bextsk[0]:=bextsk[0] and 248;
bextsk[31]:=bextsk[31] and 127;
bextsk[31]:=bextsk[31] OR 64;  }

  for i := 3 to 253 do
  begin
    if bit(bextsk, i) = 1 then
      tb := 1
    else
      tb := 0;
    sum := sum + (BigInteger.Pow(2, i) * tb);
  end;
  a := BigInteger.Pow(2, 254) + sum;
  AP := scalarmult_B(a);
  result := encodepoint(AP);
end;

function Hint(m: ansistring): ansistring;
var
  hh: tbytes;
  sum: BigInteger;
  i, tb: integer;
begin
  hh := hexatotbytes(h(m));
  for i := 0 to 511 do
  begin
    if bit((hh), i) = 1 then
      tb := 1
    else
      tb := 0;
    sum := sum + (BigInteger.Pow(2, i) * tb);
  end;
  result := sum.tostring(16);
end;

function nano_signature(m, sk, pk: AnsiString): AnsiString;
var
  hh: tbytes;
  rh, r: AnsiString;
  i: integer;
  a: BigInteger;
  sum, SS: BigInteger;
  RR: EDPoint;
  tb: integer;
begin
  hh := hexatotbytes(h(sk));
  for i := 3 to 253 do
  begin
    if bit((hh), i) = 1 then
      tb := 1
    else
      tb := 0;
    sum := sum + (BigInteger.Pow(2, i) * tb);
  end;
  a := BigInteger.Pow(2, 254) + sum;
  rh := '';
  for i := 32 to 63 do
    rh := rh + IntToHex(hh[i], 2);
  r := Hint(rh + m);
  RR := scalarmult_b(BigInteger.Parse('+0x00' + r));
  SS := pymodulus(BigInteger.Parse('+0x00' + r) + BigInteger.Parse('+0x00' + Hint(encodepoint(RR) + pk + m)) * a, getL);
  result := encodepoint(RR) + encodeint(SS);

end;

initialization
  BigInteger.Decimal;
  BigInteger.AvoidPartialFlagsStall(True);
  make_Bpow();

end.

