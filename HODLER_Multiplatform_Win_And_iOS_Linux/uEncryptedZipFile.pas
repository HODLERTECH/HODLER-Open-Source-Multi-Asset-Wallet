unit uEncryptedZipFile;

interface

uses
  System.Classes, System.Zip;

type
  EZipInvalidOperation = class(EZipException);
  EZipPasswordException = class(EZipException);
  EZipNoPassword = class(EZipPasswordException);
  EZipInvalidPassword = class(EZipPasswordException);

type
  TEncryptedZipFile = class(TZipFile)
  strict private
    class constructor Create;
  private
    FPassword: string;
  public
    constructor Create(const APassword: string);
    class function HasPassword(const ZipFile: TZipFile): Boolean;
    property Password: string read FPassword write FPassword;
  end;

implementation

uses
  System.SysUtils, System.ZLib;

resourcestring
  SInvalidPassword = 'invalid password';
  SNoPassword = 'no password';
  SInvalidOp = 'Invalid Stream operation!';

type
  TCryptor = class
  private const
    { Source: http://www.swissdelphicenter.com/de/showcode.php?id=268 }
    CRC32_TABLE: array [0 .. 255] of longword = ( // dont format
      $00000000, $77073096, $EE0E612C, $990951BA, $076DC419, $706AF48F, $E963A535, $9E6495A3, // dont format
      $0EDB8832, $79DCB8A4, $E0D5E91E, $97D2D988, $09B64C2B, $7EB17CBD, $E7B82D07, $90BF1D91, // dont format
      $1DB71064, $6AB020F2, $F3B97148, $84BE41DE, $1ADAD47D, $6DDDE4EB, $F4D4B551, $83D385C7, // dont format
      $136C9856, $646BA8C0, $FD62F97A, $8A65C9EC, $14015C4F, $63066CD9, $FA0F3D63, $8D080DF5, // dont format
      $3B6E20C8, $4C69105E, $D56041E4, $A2677172, $3C03E4D1, $4B04D447, $D20D85FD, $A50AB56B, // dont format
      $35B5A8FA, $42B2986C, $DBBBC9D6, $ACBCF940, $32D86CE3, $45DF5C75, $DCD60DCF, $ABD13D59, // dont format
      $26D930AC, $51DE003A, $C8D75180, $BFD06116, $21B4F4B5, $56B3C423, $CFBA9599, $B8BDA50F, // dont format
      $2802B89E, $5F058808, $C60CD9B2, $B10BE924, $2F6F7C87, $58684C11, $C1611DAB, $B6662D3D, // dont format
      $76DC4190, $01DB7106, $98D220BC, $EFD5102A, $71B18589, $06B6B51F, $9FBFE4A5, $E8B8D433, // dont format
      $7807C9A2, $0F00F934, $9609A88E, $E10E9818, $7F6A0DBB, $086D3D2D, $91646C97, $E6635C01, // dont format
      $6B6B51F4, $1C6C6162, $856530D8, $F262004E, $6C0695ED, $1B01A57B, $8208F4C1, $F50FC457, // dont format
      $65B0D9C6, $12B7E950, $8BBEB8EA, $FCB9887C, $62DD1DDF, $15DA2D49, $8CD37CF3, $FBD44C65, // dont format
      $4DB26158, $3AB551CE, $A3BC0074, $D4BB30E2, $4ADFA541, $3DD895D7, $A4D1C46D, $D3D6F4FB, // dont format
      $4369E96A, $346ED9FC, $AD678846, $DA60B8D0, $44042D73, $33031DE5, $AA0A4C5F, $DD0D7CC9, // dont format
      $5005713C, $270241AA, $BE0B1010, $C90C2086, $5768B525, $206F85B3, $B966D409, $CE61E49F, // dont format
      $5EDEF90E, $29D9C998, $B0D09822, $C7D7A8B4, $59B33D17, $2EB40D81, $B7BD5C3B, $C0BA6CAD, // dont format
      $EDB88320, $9ABFB3B6, $03B6E20C, $74B1D29A, $EAD54739, $9DD277AF, $04DB2615, $73DC1683, // dont format
      $E3630B12, $94643B84, $0D6D6A3E, $7A6A5AA8, $E40ECF0B, $9309FF9D, $0A00AE27, $7D079EB1, // dont format
      $F00F9344, $8708A3D2, $1E01F268, $6906C2FE, $F762575D, $806567CB, $196C3671, $6E6B06E7, // dont format
      $FED41B76, $89D32BE0, $10DA7A5A, $67DD4ACC, $F9B9DF6F, $8EBEEFF9, $17B7BE43, $60B08ED5, // dont format
      $D6D6A3E8, $A1D1937E, $38D8C2C4, $4FDFF252, $D1BB67F1, $A6BC5767, $3FB506DD, $48B2364B, // dont format
      $D80D2BDA, $AF0A1B4C, $36034AF6, $41047A60, $DF60EFC3, $A867DF55, $316E8EEF, $4669BE79, // dont format
      $CB61B38C, $BC66831A, $256FD2A0, $5268E236, $CC0C7795, $BB0B4703, $220216B9, $5505262F, // dont format
      $C5BA3BBE, $B2BD0B28, $2BB45A92, $5CB36A04, $C2D7FFA7, $B5D0CF31, $2CD99E8B, $5BDEAE1D, // dont format
      $9B64C2B0, $EC63F226, $756AA39C, $026D930A, $9C0906A9, $EB0E363F, $72076785, $05005713, // dont format
      $95BF4A82, $E2B87A14, $7BB12BAE, $0CB61B38, $92D28E9B, $E5D5BE0D, $7CDCEFB7, $0BDBDF21, // dont format
      $86D3D2D4, $F1D4E242, $68DDB3F8, $1FDA836E, $81BE16CD, $F6B9265B, $6FB077E1, $18B74777, // dont format
      $88085AE6, $FF0F6A70, $66063BCA, $11010B5C, $8F659EFF, $F862AE69, $616BFFD3, $166CCF45, // dont format
      $A00AE278, $D70DD2EE, $4E048354, $3903B3C2, $A7672661, $D06016F7, $4969474D, $3E6E77DB, // dont format
      $AED16A4A, $D9D65ADC, $40DF0B66, $37D83BF0, $A9BCAE53, $DEBB9EC5, $47B2CF7F, $30B5FFE9, // dont format
      $BDBDF21C, $CABAC28A, $53B39330, $24B4A3A6, $BAD03605, $CDD70693, $54DE5729, $23D967BF, // dont format
      $B3667A2E, $C4614AB8, $5D681B02, $2A6F2B94, $B40BBE37, $C30C8EA1, $5A05DF1B, $2D02EF8D);

  private
    FKey: array [0 .. 2] of Int64;
  protected
    function CalcDecryptByte: Byte;
    function UpdateCRC32(Key: longword; Value: Byte): longword;
    procedure UpdateKeys(Value: Byte);
  public
    procedure InitKeys(const APassword: string);
    procedure DecryptByte(var Value: Byte);
    procedure EncryptByte(var Value: Byte);
  end;

type
  TCryptStream = class(TStream)
  private
    FCryptor: TCryptor;
    FPassword: string;
    FStream: TStream;
    FStreamStartPos: Int64;
    FStreamSize: Int64;
    FZipHeader: TZipHeader;
  protected
    procedure InitHeader; virtual; abstract;
    procedure InitKeys;
    procedure ResetStream;
    property Stream: TStream read FStream;
    property ZipHeader: TZipHeader read FZipHeader;
  public
    constructor Create(AStream: TStream; const APassword: string; const AZipHeader: TZipHeader);
    destructor Destroy; override;
    function Read(var Buffer; Count: Integer): Integer; {$IF NOT  (DEFINED(IOS) OR DEFINED(LINUX))} override; {$ENDIF}
    function Seek(const Offset: Int64; Origin: TSeekOrigin): Int64; override;
    function Write(const Buffer; Count: Integer): Integer;{$IF NOT  (DEFINED(IOS) OR DEFINED(LINUX))} override; {$ENDIF}
  end;

  TDecryptStream = class(TCryptStream)
  protected
    procedure InitHeader; override;
    function Skip(Value: Int64): Int64;
  public
    function Read(var Buffer; Count: Integer): Integer; {$IF NOT  (DEFINED(IOS) OR DEFINED(LINUX))}override; {$ENDIF}
    function Seek(const Offset: Int64; Origin: TSeekOrigin): Int64;{$IF NOT  (DEFINED(IOS) OR DEFINED(LINUX))} override; {$ENDIF}
  end;

  TEncryptStream = class(TCryptStream)
  protected
    procedure InitHeader; override;
  public
    function Write(const Buffer; Count: Integer): Integer; {$IF NOT  (DEFINED(IOS) OR DEFINED(LINUX))} override; {$ENDIF}
  end;

  TEncryptedZCompressionStream = class(TMemoryStream)
  private
    FPassword: string;
    FTarget: TStream;
    FZipHeader: PZipHeader;
    procedure EncryptToTarget;
  protected
    property ZipHeader: PZipHeader read FZipHeader;
  public
    constructor Create(ATarget: TStream; const APassword: string; const AZipHeader: TZipHeader);
    destructor Destroy; override;
    property Password: string read FPassword;
    property Target: TStream read FTarget;
  end;

class constructor TEncryptedZipFile.Create;
begin
  RegisterCompressionHandler(zcDeflate,
    function(InStream: TStream; const ZipFile: TZipFile; const Item: TZipHeader): TStream
    begin
      if HasPassword(ZipFile) then begin
        Result := TEncryptedZCompressionStream.Create(InStream, TEncryptedZipFile(ZipFile).Password, Item);
      end
      else begin
        Result := TZCompressionStream.Create(InStream, zcDefault, -15);
      end;
    end,
    function(InStream: TStream; const ZipFile: TZipFile; const Item: TZipHeader): TStream
    var
      LStream : TStream;
      LIsEncrypted: Boolean;
    begin
      // From https://pkware.cachefly.net/webdocs/casestudies/APPNOTE.TXT
      // Section 4.4.4 general purpose bit flag: (2 bytes)
      // Bit 0: If set, indicates that the file is encrypted.
      LIsEncrypted := (Item.Flag and 1) = 1;

      if Assigned(TZipFile.OnCreateDecompressStream) then
        LStream := TZipFile.OnCreateDecompressStream(InStream, ZipFile, Item, LIsEncrypted)
      else if Assigned(TZipFile.CreateDecompressStreamCallBack) then
        LStream := TZipFile.CreateDecompressStreamCallBack(InStream, ZipFile, Item, LIsEncrypted)
      else if LIsEncrypted and (ZipFile is TEncryptedZipFile) then
        LStream := TDecryptStream.Create(InStream, TEncryptedZipFile(ZipFile).Password, Item)
      else
        LStream := InStream;
      Result := TZDecompressionStream.Create(LStream, -15, LStream <> InStream);
    end);
end;

constructor TEncryptedZipFile.Create(const APassword: string);
begin
  inherited Create;
  FPassword := APassword;
end;

class function TEncryptedZipFile.HasPassword(const ZipFile: TZipFile): Boolean;
begin
  Result := (ZipFile is TEncryptedZipFile) and (TEncryptedZipFile(ZipFile).Password > '');
end;

constructor TCryptStream.Create(AStream: TStream; const APassword: string; const AZipHeader: TZipHeader);
begin
  inherited Create;
  FCryptor := TCryptor.Create();
  FStream := AStream;
  FPassword := APassword;
  FZipHeader := AZipHeader;
  if (FPassword = '') then
    raise EZipNoPassword.Create(SNoPassword);
  FStreamStartPos := FStream.Position;
  InitKeys;
  InitHeader;
end;

destructor TCryptStream.Destroy;
begin
  FCryptor.Free;
  inherited Destroy;
end;

procedure TCryptStream.InitKeys;
begin
  FCryptor.InitKeys(FPassword);
end;

function TCryptStream.Read(var Buffer; Count: Integer): Integer;
begin
  raise EZipInvalidOperation.Create(SInvalidOp);
end;

procedure TCryptStream.ResetStream;
begin
  if FStream.Position <> FStreamStartPos then begin
    FStream.Position := FStreamStartPos;
  end;
  InitKeys;
  InitHeader;
end;

function TCryptStream.Write(const Buffer; Count: Integer): Integer;
begin
  raise EZipInvalidOperation.Create(SInvalidOp);
end;

function TCryptStream.Seek(const Offset: Int64; Origin: TSeekOrigin): Int64;
begin
  if (offset = 0) and (origin = soCurrent) then
  begin
    result := FStream.Position;
  end
  else begin
    raise EZipInvalidOperation.Create(SInvalidOp);
  end;
end;

procedure TDecryptStream.InitHeader;
var
  header: array [0..11] of Byte;
begin
  FStreamSize := ZipHeader.CompressedSize - Sizeof(header);
  ReadBuffer(header, Sizeof(header));
  if header[High(header)] <> (ZipHeader.CRC32 shr 24) then
    raise EZipInvalidPassword.Create(SInvalidPassword);
end;

function TDecryptStream.Read(var Buffer; Count: Integer): Integer;
var
  P: PByte;
  I: Integer;
begin
  result := FStream.Read(Buffer, Count);
  P := @Buffer;
  for I := 1 to result do begin
    FCryptor.DecryptByte(P^);
    Inc(P);
  end;
end;

function TDecryptStream.Seek(const Offset: Int64; Origin: TSeekOrigin): Int64;
var
  curPos: Int64;
  newPos: Int64;
begin
  curPos := FStream.Position;
  newPos := CurPos;
  case Origin of
    soBeginning: newPos := Offset;
    soCurrent: newPos := curPos + Offset;
    soEnd: newPos := FStreamSize + Offset;
  end;
  if newPos < curPos then begin
    ResetStream;
    result := Skip(newPos);
  end
  else begin
    result := Skip(newPos - curPos);
  end;
end;

function TDecryptStream.Skip(Value: Int64): Int64;
const
  MaxBufSize = $F000;
var
  buffer: TBytes;
  cnt: Integer;
begin
  if Value < MaxBufSize then
    SetLength(buffer, Value)
  else
    SetLength(buffer, MaxBufSize);
  while Value > 0 do begin
    cnt := Length(buffer);
    if Value < cnt then
      cnt := Value;
    ReadBuffer(buffer, cnt);
    Value := Value - cnt;
  end;
  Result := FStream.Position;
end;

procedure TEncryptStream.InitHeader;
var
  header: array[0..11] of Byte;
  I: Integer;
begin
  for I := 0 to 10 do begin
    header[I] := Random(256);
  end;
  header[11] := (ZipHeader.CRC32 shr 24);
  WriteBuffer(header, Sizeof(header));
end;

function TEncryptStream.Write(const Buffer; Count: Integer): Integer;
const
  MaxBufSize = $10000;
var
  bytes: TBytes;
  cnt: Integer;
  I: Integer;
  P: PByte;
begin
  result := 0;
  if Count < MaxBufSize then
    SetLength(bytes, Count)
  else
    SetLength(bytes, MaxBufSize);
  P := @Buffer;
  while Count > 0 do begin
    cnt := Length(bytes);
    if Count < cnt then
      cnt := Count;
    Move(P^, bytes[0], cnt);
    Inc(P, cnt);
    for I := 0 to cnt - 1 do begin
      FCryptor.EncryptByte(bytes[I]);
    end;
    result := result + FStream.Write(bytes, cnt);
    Count := Count - cnt;
  end;
end;

function TCryptor.CalcDecryptByte: Byte;
var
  temp: int64;
begin
  temp   := FKey[2] or 2;
  Result := word(temp * (temp xor 1)) shr 8;
end;

procedure TCryptor.InitKeys(const APassword: string);
var
  B: Byte;
begin
  FKey[0] := 305419896;
  FKey[1] := 591751049;
  FKey[2] := 878082192;
  for B in TEncoding.ANSI.GetBytes(APassword) do begin
    UpdateKeys(B);
  end;
end;

procedure TCryptor.DecryptByte(var Value: Byte);
begin
  Value := Value xor CalcDecryptByte;
  UpdateKeys(Value);
end;

procedure TCryptor.EncryptByte(var Value: Byte);
var
  temp: Byte;
begin
  temp := CalcDecryptByte;
  UpdateKeys(Value);
  Value := Value xor temp;
end;

function TCryptor.UpdateCRC32(Key: LongWord; Value: Byte): LongWord;
begin
  { Source: http://www.swissdelphicenter.com/de/showcode.php?id=268 }
  Result := (Key shr 8) xor CRC32_TABLE[Value xor (Key and $000000FF)];
end;

procedure TCryptor.UpdateKeys(Value: Byte);
begin
  FKey[0] := UpdateCRC32(FKey[0], Value);
  FKey[1] := FKey[1] + (FKey[0] and $000000FF);
  FKey[1] := longword(FKey[1] * 134775813 + 1);
  FKey[2] := UpdateCRC32(FKey[2], Byte(FKey[1] shr 24));
end;

constructor TEncryptedZCompressionStream.Create(ATarget: TStream; const APassword: string; const AZipHeader: TZipHeader);
begin
  inherited Create;
  FTarget := ATarget;
  FZipHeader := @AZipHeader;
  FPassword := APassword;
end;

destructor TEncryptedZCompressionStream.Destroy;
begin
  EncryptToTarget;
  inherited;
end;

procedure TEncryptedZCompressionStream.EncryptToTarget;
var
  compressionStream: TStream;
  encryptStream: TStream;
begin
  ZipHeader.Flag := ZipHeader.Flag or 1;
  ZipHeader.CRC32 := crc32(0, Memory, Size);
  encryptStream := TEncryptStream.Create(Target, Password, ZipHeader^);
  try
    compressionStream := TZCompressionStream.Create(encryptStream, zcDefault, -15);
    try
      compressionStream.CopyFrom(Self, 0);
    finally
      compressionStream.Free;
    end;
  finally
    encryptStream.Free;
    ZipHeader.CRC32 := 0;
  end;
end;

end.
