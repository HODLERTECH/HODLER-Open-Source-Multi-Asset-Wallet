unit WIF;

interface
uses base58 , system.strUtils ,SysUtils , Math;

type
  WIFAddressData = record
    PrivKey : AnsiString;
    isCompressed : Boolean;
    wifByte : AnsiString;
  end;

Function WIFToPrivKey( wif : String ) : WIFAddressData;
function PrivKeyToWIF( pk  : String ; IsCompressed : boolean ; WifByte : AnsiString ) : String; overload;
function PrivKeyToWIF( data : WIFAddressData ) : String; overload ;

implementation
uses misc;
// /////////////////////////////////////////////////////////////////////////////////////////////////
 const
  Codes58: AnsiString =
    '123456789ABCDEFGHJKLMNPQRSTUVWXYZabcdefghijkmnopqrstuvwxyz';
function De58(S: AnsiString): AnsiString;
const
  Alphabet = '123456789ABCDEFGHJKLMNPQRSTUVWXYZabcdefghijkmnopqrstuvwxyz';
var
  size : Integer ;
  c: AnsiChar;
  i, J: integer;
  Temp: array of Byte;
begin

  size := ((Length(S) * 73224) div 100000);

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
    result := Lowercase(ToHex(Temp, size));

    if i <> 0 then
      raise Exception.Create('Private Key too long');
  end;




end;

{$IFDEF ANDROID}

function En58(V: AnsiString): AnsiString;
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
  SetLength(S, (Length(V) div 2));
  for i := 0 to (Length(V) div 2) - 1 do
  begin
    sb := System.UInt8(StrToInt('$' + Copy(V, ((i) * 2) + 1, 2)));
    S[i] := sb;
  end;
  n := ceil(( length(v) ) * 10000 / 14645 );
  SetLength(output, n);
  while n > 0 do
  begin
    dec(n);
    c := 0;
    for i := 0 to round(length(v)/2)-1 do
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

function En58(V: AnsiString): AnsiString;
var
  i: integer;
  a: integer;
  x: integer;
  b: integer;
  n, c: integer;
  output: AnsiString;
  sb: System.UInt8;
  S: TBytes;

  size : Integer;
begin
  size := ceil(( length(v) ) * 10000 / 14645 );

  SetLength(S, (Length(V) div 2));
  for i := 1 to (Length(V) div 2) do
  begin
    sb := System.UInt8(StrToInt('$' + Copy(V, ((i - 1) * 2) + 1, 2)));
    S[i] := sb;
  end;
  n := size;
  SetLength(output, size);
  while n > 0 do
  begin
    c := 0;
    for i := 1 to round(length(v)/2) do
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
end;
{$ENDIF}



Function WIFToPrivKey( wif : String ) : WIFAddressData;
var tempStr : String;
begin

  tempStr := De58(wif);

  tempStr := LeftStr( tempStr , Length(tempStr)-8);

  if rightSTR(tempStr , 2) = '01' then
  begin
    Result.isCompressed := true;
    tempStr := leftStr(tempStr , Length( tempStr ) -2 );
  end
  else
  begin
    result.isCompressed := false;
  end;

  result.wifByte := leftStr( tempStr , 2 );
  tempStr := RightStr(tempStr , Length(tempStr)-2);

  result.PrivKey := UpperCase( tempStr );
  tempStr := '';

end;
function PrivKeyToWIF( pk  : String ; isCompressed : boolean ; WifByte : AnsiString ) : String;
var
  checkSum : String;
begin
  pk := WifByte + PK;

  if isCompressed then
  begin
    Pk := pk + '01';
  end;

  checkSum := GetSHa256Fromhex (GetSHA256FromHex(pk));
  checkSum := LeftStr(checksum , 8);
  pk := pk + checkSum;
  //result := pk;
  result:=En58(pk);

end;

function PrivKeyToWIF( data : WIFAddressData ) : String;
begin
  Result := PrivKeyToWIF( data.PrivKey , data.isCompressed , data.wifByte );
end;

end.
