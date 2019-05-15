unit bech32;

interface

uses
  System.SysUtils, FMX.Dialogs, System.strUtils, WalletStructureData;

{$IF DEFINED(ANDROID) OR DEFINED(IOS)}

const
  StrStartIteration = {$IFNDEF LINUX} 0 {$ELSE}1{$ENDIF};

type
  AnsiString = string;

type
  AnsiChar = Char;
{$ELSE}

const
  StrStartIteration = 1;
{$ENDIF}

type
  TIntegerArray = array of System.uint32;

type
  Bech32Data = record
    hrp: String;
    values: TIntegerArray;
  end;

  // function encode(hrp : String ; values : TIntegerArray) : String;
  // function decode(str : String): Bech32Data;
function segwit_addr_encode(hrp: AnsiString; witver: byte; witprog: AnsiString)
  : AnsiString;

function segwit_addr_decode(segwit: AnsiString): TaddressInfo;

function decode(str: String): Bech32Data;

function encode(hrp: String; values: TIntegerArray): String;

function CreateChecksum(hrp: String; values: TIntegerArray): TIntegerArray;

function Concat(x, y: TIntegerArray): TIntegerArray;

function ChangeBits(var data: array of System.uint32;
  frombits, tobits: System.uint32; pad: boolean = true): TIntegerArray;

function CreateChecksum8(hrp: String; values: TIntegerArray): TIntegerArray;

function decodeBCH(str: String): Bech32Data;

function rawEncode(values: TIntegerArray): String;
function hexatotintegerarray(H: AnsiString): TIntegerArray;
function isValidBCHCashAddress(address: String): boolean;
function isCashAddress(address: String): boolean;

var
  charset: String = 'qpzry9x8gf2tvdw0s3jn54khce6mua7l';
  charset_rev: array [0 .. 127] of Integer = (
    -1,
    -1,
    -1,
    -1,
    -1,
    -1,
    -1,
    -1,
    -1,
    -1,
    -1,
    -1,
    -1,
    -1,
    -1,
    -1,
    -1,
    -1,
    -1,
    -1,
    -1,
    -1,
    -1,
    -1,
    -1,
    -1,
    -1,
    -1,
    -1,
    -1,
    -1,
    -1,
    -1,
    -1,
    -1,
    -1,
    -1,
    -1,
    -1,
    -1,
    -1,
    -1,
    -1,
    -1,
    -1,
    -1,
    -1,
    -1,
    15,
    -1,
    10,
    17,
    21,
    20,
    26,
    30,
    7,
    5,
    -1,
    -1,
    -1,
    -1,
    -1,
    -1,
    -1,
    29,
    -1,
    24,
    13,
    25,
    9,
    8,
    23,
    -1,
    18,
    22,
    31,
    27,
    19,
    -1,
    1,
    0,
    3,
    16,
    11,
    28,
    12,
    14,
    6,
    4,
    2,
    -1,
    -1,
    -1,
    -1,
    -1,
    -1,
    29,
    -1,
    24,
    13,
    25,
    9,
    8,
    23,
    -1,
    18,
    22,
    31,
    27,
    19,
    -1,
    1,
    0,
    3,
    16,
    11,
    28,
    12,
    14,
    6,
    4,
    2,
    -1,
    -1,
    -1,
    -1,
    -1
  );

implementation

function ChangeBits(var data: array of System.uint32;
  frombits, tobits: System.uint32; pad: boolean = true): TIntegerArray;
var
  acc: Integer;
  bits: Integer;
  ret: array of Integer;
  maxv: Integer;
  maxacc: Integer;
  i: Integer;
  value: Integer;
  j: Integer;
begin
  acc := 0;
  bits := 0;
  ret := [];
  maxv := 0;
  maxacc := 0;
  maxv := (1 shl tobits) - 1;
  maxacc := (1 shl (frombits + tobits - 1)) - 1;

  for i := 0 to Length(data) - 1 do
  begin
    value := data[i];

    if (value < 0) or ((value shr frombits) <> 0) then
    begin
      // error
    end;

    acc := ((acc shl frombits) or value) and maxacc;
    bits := bits + frombits;

    j := 0;
    while bits >= tobits do
    begin
      bits := bits - tobits;
      setlength(ret, Length(ret) + 1);
      ret[Length(ret) - 1] := ((acc shr bits) and maxv);
      inc(j);
    end;
  end;

  if pad then
  begin
    j := 0;
    if bits <> 0 then
    begin
      setlength(ret, Length(ret) + 1);
      ret[Length(ret) - 1] := (acc shl (tobits - bits)) and maxv;
      inc(j);
    end;
  end;

  Result := TIntegerArray(ret);
end;

function writeTIA(arr: TIntegerArray): boolean;
var
  i: Integer;
  str: String;
begin
  writeln('');
  for i := 0 to Length(arr) - 1 do
  begin
    write(arr[i]);
    write(' ');
  end;
  writeln('');
end;

function Concat(x, y: TIntegerArray): TIntegerArray;
var
  i: Integer;
begin
  setlength(Result, Length(x) + Length(y));
  for i := 0 to Length(x) - 1 do
  begin
    Result[i] := x[i];
  end;
  for i := Length(x) to Length(x) + Length(y) - 1 do
  begin
    Result[i] := y[i - Length(x)];
  end;
end;

function PolyMod(v: array of System.uint32): Integer;
var
  c: Integer;
  v_i: Integer;
  c0: Integer;
begin
  c := 1;
  for v_i in v do
  begin
    c0 := c shr 25;
    c := ((c and $1FFFFFF) shl 5) xor v_i;

    if (c0 and 1 <> 0) then
      c := c xor $3B6A57B2;
    if (c0 and 2 <> 0) then
      c := c xor $26508E6D;
    if (c0 and 4 <> 0) then
      c := c xor $1EA119FA;
    if (c0 and 8 <> 0) then
      c := c xor $3D4233DD;
    if (c0 and 16 <> 0) then
      c := c xor $2A1462B3;

  end;
  Result := c;

end;

function PolyModBCH(v: array of System.uint32): int64;
var
  c: Uint64;
  v_i: Uint64;
  c0: Uint64;
begin
  c := 1;
  for v_i in v do
  begin
    c0 := c shr 35;
    c := ((c and $07FFFFFFFF) shl 5) xor v_i;

    if (c0 and 1 <> 0) then
      c := c xor $98F2BC8E61;
    if (c0 and 2 <> 0) then
      c := c xor $79B76D99E2;
    if (c0 and 4 <> 0) then
      c := c xor $F33E5FB3C4;
    if (c0 and 8 <> 0) then
      c := c xor $AE2EABE2A8;
    if (c0 and 16 <> 0) then
      c := c xor $1E4F43E470;

  end;
  Result := c;

end;

function prefix_expand(hrp: String): TIntegerArray;
var
  i: Integer;
  c: byte;
  debug: String;
begin
  setlength(Result, Length(hrp) + 1);
  for i := 0 to Length(hrp) - 1 do
  begin

    c := byte(hrp[i + low(hrp)]);
    Result[i] := (c and $1F);
  end;
  Result[Length(hrp)] := 0;

end;

function ExpandHRP(hrp: String): TIntegerArray;
var
  i: Integer;
  c: byte;
begin
  setlength(Result, Length(hrp) * 2 + 1);
  for i := 0 to Length(hrp) - 1 do
  begin
    c := byte(hrp[i + low(hrp)]);
    Result[i] := (c shr 5);
    Result[i + Length(hrp) + 1] := (c and $1F);
  end;
  Result[Length(hrp)] := 0;
end;

function CreateChecksum(hrp: String; values: TIntegerArray): TIntegerArray;
var
  enc: TIntegerArray;
  pmod: LongWord;
  i: Integer;
  temp: Integer;
begin
  enc := Concat(ExpandHRP(hrp), values);
  setlength(enc, Length(enc) + 6);

  pmod := PolyMod(enc) xor 1;
  setlength(Result, 6);
  for i := 0 to 5 do
  begin
    Result[i] := (pmod shr (5 * (5 - i))) and 31;
  end;
end;

function CreateChecksum8(hrp: String; values: TIntegerArray): TIntegerArray;
var
  enc: TIntegerArray;
  pmod: int64;
  i: Integer;
  temp: Integer;
begin
  enc := Concat(prefix_expand(hrp), values);
  setlength(enc, Length(enc) + 8);

  // for i in enc do
  // showmessage( inttostr(i) );
  pmod := PolyModBCH(enc) xor 1;
  // showmessage( inttoStr( pmod ) );
  setlength(Result, 8);
  for i := 0 to 7 do
  begin
    Result[i] := (pmod shr (5 * (7 - i))) and 31;
  end;
end;

function VerifyChecksum(hrp: String; values: TIntegerArray): boolean;
begin
  Result := PolyMod(Concat(ExpandHRP(hrp), values)) = 1;
end;

function rawEncode(values: TIntegerArray): String;
var
  i: Integer;
begin
  Result := '';
  for i := 0 to Length(values) - 1 do
  begin
    Result := Result + charset[values[i] + low(charset)];
  end;
end;

function encode(hrp: String; values: TIntegerArray): String;
var
  checksum: TIntegerArray;
  combined: TIntegerArray;
  i: Integer;
begin
  checksum := CreateChecksum(hrp, values);
  combined := Concat(values, checksum);
  Result := hrp + '1';
  { setlength(Result, Length(hrp) + 1 + Length(combined));
    for i := Length(hrp) + 1 + 1 to Length(Result) do
    begin
    Result[i] := charset[combined[i - Length(hrp) - 2] + 1];
    end; }
  for i := 0 to Length(combined) - 1 do
  begin
    Result := Result + charset[combined[i] + low(charset)];
  end;
end;

function VerifyChecksumBCH(hrp: String; values: TIntegerArray): boolean;
begin
  Result := PolyModBCH(Concat(prefix_expand(hrp), values)) = 1;
end;

function decodeBCH(str: String): Bech32Data;
var
  lower, upper: boolean;
  i: Integer;
  c: Char;
  pos: Integer;
  values: TIntegerArray;
  rev: Integer;
  hrp: String;
begin
  Result.hrp := 'FAIL';
  Result.values := [];

  lower := False;
  upper := False;
  for i := low(str) to High(str) do
  begin

    c := str[i];
    if ((c >= 'a') and (c <= 'z')) then
    begin
      lower := true;
    end
    else if ((c >= 'A') and (c <= 'Z')) then
    begin
      upper := true;
    end
    else if ((Integer(c) < 33) or (Integer(c) > 126)) then
    begin

      exit;
    end;
  end;

  if (upper and lower) then
    exit;

  pos := str.LastIndexOf(':');

  if ((Length(str) > 90) or (pos < 1) or (pos + 7 > Length(str))) then
    exit;

  setlength(values, Length(str) - 1 - pos);
  for i := 0 to Length(values) - 1 do
  begin
    c := str[i + pos + 1 + low(str)];
    rev := charset_rev[Integer(c)];
    if (rev = -1) then
      exit;
    values[i] := rev;
  end;
  hrp := '';
  for i := Low(str) to pos + low(str) - 1 do
  begin
    hrp := hrp + LowerCase(str[i]);
  end;

  if VerifyChecksumBCH(hrp, values) = False then
    exit;

  Result.hrp := hrp;
  Result.values := values;

end;

function decode(str: String): Bech32Data;
var
  lower, upper: boolean;
  i: Integer;
  c: Char;
  pos: Integer;
  values: TIntegerArray;
  rev: Integer;
  hrp: String;
begin
  Result.hrp := '';
  Result.values := [];

  lower := False;
  upper := False;
  for i := low(str) to High(str) do
  begin

    c := str[i];
    if ((c >= 'a') and (c <= 'z')) then
    begin
      lower := true;
    end
    else if ((c >= 'A') and (c <= 'Z')) then
    begin
      upper := true;
    end
    else if ((Integer(c) < 33) or (Integer(c) > 126)) then
    begin

      exit;
    end;
  end;

  if (upper and lower) then
    exit;

  pos := str.LastIndexOf('1');

  if ((Length(str) > 90) or (pos < 1) or (pos + 7 > Length(str))) then
    exit;

  setlength(values, Length(str) - 1 - pos);
  for i := 0 to Length(values) - 1 do
  begin
    c := str[i + pos + 1 + low(str)];
    rev := charset_rev[Integer(c)];
    if (rev = -1) then
      exit;
    values[i] := rev;
  end;
  hrp := '';
  for i := Low(str) to pos + low(str) - 1 do
  begin
    hrp := hrp + LowerCase(str[i]);
  end;

  Result.hrp := hrp; // usun
  Result.values := values; // usun

  if VerifyChecksum(hrp, values) = False then
    exit;

  Result.hrp := hrp;
  Result.values := values;

end;

function hexatotintegerarray(H: AnsiString): TIntegerArray;
var
  i: Integer;
  b: System.Uint8;
  bb: TIntegerArray;
begin
  setlength(bb, (Length(H) div 2));
{$IF DEFINED(ANDROID) OR DEFINED(IOS)}
  for i := 0 to (Length(H) div 2) - 1 do
  begin
    b := System.Uint8(strtoIntDef('$' + Copy(H, ((i) * 2) + 1, 2),0));
    bb[i] := b;
  end;
{$ELSE}
  for i := 1 to (Length(H) div 2) do
  begin
    b := System.Uint8(strtoIntDef('$' + Copy(H, ((i - 1) * 2) + 1, 2),0));
    bb[i - 1] := b;
  end;

{$ENDIF}
  Result := bb;
end;

function segwit_addr_encode(hrp: AnsiString; witver: byte; witprog: AnsiString)
  : AnsiString;
var
  data: TIntegerArray;
begin
  Result := 'FAILED';
  if witver > 0 then
    exit;
  if (witver = 0) and (Length(witprog) <> 40) and (Length(witprog) <> 64) then
    exit;
  data := hexatotintegerarray(witprog);
  data := ChangeBits(data, 8, 5, true);
  Result := encode(hrp, Concat([witver], data));

end;

function segwit_addr_decode(segwit: AnsiString): TaddressInfo;
var
  decoded: Bech32Data;
  intarr: TIntegerArray;
  witver: byte;
  hex: AnsiString;
  tempInt: Integer;
  i: Integer;
begin
  decoded := decode(segwit);
  witver := decoded.values[0];
  intarr := Copy(decoded.values, 1, Length(decoded.values) - 1);

  intarr := ChangeBits(intarr, 5, 8);

  hex := '';
  for i := 0 to Length(intarr) - 5 do
  begin
    tempInt := intarr[i];
    hex := hex + IntToHex(byte(tempInt));
  end;

  Result.Hash := hex;
  Result.witver := witver;

end;

function isValidBCHCashAddress(address: String): boolean;
var
  values: String;
  hrp: String;
  intValues: TIntegerArray;
  intarr, checkArr: TIntegerArray;
  i: Integer;
  // debugStr : String;
begin

  if LowerCase(leftstr(address, 12)) = 'bitcoincash:' then
  begin
    values := rightstr(address, Length(address) - 12);
  end
  else
  begin
    values := address;
  end;
  hrp := 'bitcoincash';

  setlength(intValues, Length(values));

  for i := 0 to Length(intValues) - 1 do
  begin

    intValues[i] := charset_rev[byte(values[i + low(values)])];

  end;
  intarr := Copy(intValues, 0, Length(intValues) - 8);

  checkArr := CreateChecksum8(hrp, intarr);

  for i := 0 to 7 do
  begin

    if checkArr[i] <> intValues[Length(intValues) - 8 + i] then
    begin
      Result := False;
      exit;
    end;

  end;
  Result := true;

end;

function isCashAddress(address: String): boolean;
var
  values: String;
begin

  if LowerCase(leftstr(address, 12)) = 'bitcoincash:' then
  begin
    values := rightstr(address, Length(address) - 12);
  end
  else
  begin
    values := address;
  end;
  if (LowerCase(values[low(values)]) = 'p') or
    (LowerCase(values[low(values)]) = 'q') then
    Result := true
  else
    Result := False;

end;

end.
