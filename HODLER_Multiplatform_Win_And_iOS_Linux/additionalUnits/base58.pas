unit base58;

{$ifdef FPC}{$mode OBJFPC}{$endif}

interface

uses System.SysUtils, FMX.Dialogs, System.strUtils;
{$IF DEFINED(ANDROID) OR DEFINED(IOS) OR DEFINED(LINUX)}

type
  AnsiString = string;

type
  AnsiChar = Char;

{$ENDIF}
function Encode58(V: AnsiString): AnsiString;
function Decode58(S: AnsiString): AnsiString;
function ValidateBitcoinAddress(Address: AnsiString): boolean;
function ToHex(Buffer: array of Byte; Length: Word): AnsiString;

implementation

uses misc, bech32;

const
  Codes58: AnsiString =
    '123456789ABCDEFGHJKLMNPQRSTUVWXYZabcdefghijkmnopqrstuvwxyz';

function memmove(var dest: AnsiString; n, size: integer): AnsiString;
var
  tmp: AnsiString;
  i: integer;
begin
  tmp := Copy(dest, n, Length(dest) - size);
  Delete(dest, n, Length(dest) - size);
  for i := 1 to Length(tmp) do
    dest[i] := tmp[i];

end;
{$IF DEFINED(ANDROID) OR DEFINED(IOS)}

function Encode58(V: AnsiString): AnsiString;
var
  i: integer;
  a: integer;
  x: integer;
  b: integer;
  n, c: integer;
  output: AnsiString;
  sb: System.UInt8;
  S: array of System.UInt8;
begin
  SetLength(S, (Length(V) div 2));

  for i := 0 to (Length(V) div 2) - 1 do
  begin
    sb := System.UInt8(StrToIntDef('$' + Copy(V, ((i) * 2) + 1, 2),0));
    S[i] := sb;
  end;
  n := 34;
  SetLength(output, n);
  while n > 0 do
  begin
    dec(n);
    c := 0;
    for i := 0 to 24 do
    begin
      c := c * 256 + ord(S[i]);
      S[i] := System.UInt8(c div 58);
      c := c mod 58;
    end;
    output[n] := Codes58[c];

  end;
  for n := 1 to Length(output) - 1 do
  begin
    if output[n] = '1' then
    begin
      Delete(output, n, 1);
      continue;
    end;
    break;

  end;
  result := output;

end;
{$ELSE}

function Encode58(V: AnsiString): AnsiString;
var
  i: integer;
  a: integer;
  x: integer;
  b: integer;
  n, c: integer;
  output: AnsiString;
  sb: System.UInt8;
  S: TBytes;
begin
  SetLength(S, (Length(V) div 2) + 1);
  for i := 1 to (Length(V) div 2) do
  begin
    sb := System.UInt8(StrToIntDef('$' + Copy(V, ((i - 1) * 2) + 1, 2),0));
    S[i] := sb;
  end;
  n := 34;

  SetLength(output, 34);
  while n > 0 do
  begin
    c := 0;
    for i := 1 to 25 do
    begin
      c := c * 256 + ord(S[i]);
      S[i] := System.UInt8(c div 58);
      c := c mod 58;
    end;
    output[n] := Codes58[c + 1];
    dec(n);
  end;
  for n := 2 to Length(output) do
  begin
    if output[n] = '1' then
    begin
      Delete(output, n, 1);
      continue;
    end;
    break;

  end;
  result := output;
  SetLength(output,0);
  SetLength(S,0);
  SetLength(V,0);
  Delete(output , low(output) , length(output) );

end;
{$ENDIF}

function ToHex(Buffer: array of Byte; Length: Word): AnsiString;
var
  HexBuffer: AnsiString;
  i: integer;
begin
  HexBuffer := '';
  for i := 0 to (Length - 1) do
  begin
    HexBuffer := HexBuffer + IntToHex(Buffer[i], 2);
    if (i < (Length - 1)) then
      HexBuffer := HexBuffer + '';
  end;
  result := HexBuffer;
end;

function Decode58(S: AnsiString): AnsiString;
const
  size = 25;
  Alphabet = '123456789ABCDEFGHJKLMNPQRSTUVWXYZabcdefghijkmnopqrstuvwxyz';
var
  c: AnsiChar;
  i, J: integer;
  Temp: array of Byte;
begin
  SetLength(Temp, size);

  for c in S do
  begin
    i := Pos(c, Alphabet) - 1;

    if i = -1 then
      raise Exception.CreateFmt('Invalid character found: %s', [c]);

    for J := High(Temp) downto 0 do
    begin
      i := i + (58 * Temp[J]);
      Temp[J] := i mod 256;
      i := i div 256;
    end;
    result := Lowercase(ToHex(Temp, 25));
    if i <> 0 then
      raise Exception.Create('Address too long');
  end;
end;

function ValidateBitcoinAddress(Address: AnsiString): boolean;
var
  Decoded: AnsiString;
  Hashed: AnsiString;
  i: integer;
begin

  Address := StringReplace(Address, '0x', '', [rfReplaceAll]);
  if Pos(':', Address) <> 0 then
  begin
    Address := rightStr(Address, Length(Address) - Pos(':', Address));
  end
  else
    Address := Address;
  // Address := StringReplace(Address, 'bitcoincash:', '', [rfReplaceAll]);
  // ETH Adr
  if isHex(Address) and (Length(Address) = 40) then
  begin
    result := true;
    exit;
  end;
  result := false;

  if not isSegwitAddress(Address) then
  begin

    if (Length(Address) < 26) or (Length(Address) > 35) then
      exit;

    Decoded := Decode58(Address);
    Hashed := GetSHA256FromHex(GetSHA256FromHex(Copy(Decoded, 0, 42)));
    i := 1;
{$IF DEFINED(ANDROID) OR DEFINED(IOS)}
    i := 0;
{$ENDIF}
    Decoded := Copy(Decoded, 43, 8);
    Hashed := Copy(Hashed, 0 + i, 8);
    if not(Decoded = Hashed) then
      exit;
  end
  else
  begin
    try
      segwit_addr_decode(Address);
    except
      on E: Exception do
        exit;

    end;
  end;
  result := true;
end;

end.
