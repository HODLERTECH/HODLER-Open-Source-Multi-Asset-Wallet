unit uNanoPowAS;

// unit of Nano currency Proof of Work Android Service
// Copyleft 2019 - Daniel Mazur
interface

uses
  DW.Androidapi.JNI.Support, Androidapi.JNIBridge,
  Androidapi.JNI.JavaTypes,
  System.Android.Service, Androidapi.JNI.Util, Androidapi.JNI.App,
  Androidapi.JNI.Widget, Androidapi.JNI.Media,
  Androidapi.JNI.Support,
  Androidapi.JNI.GraphicsContentViewText,
  Androidapi.JNI.Os, System.Android.Notification, System.SysUtils,
  System.IOUtils, StrUtils,
  System.Classes, System.JSON,
  System.Generics.Collections, Androidapi.Helpers,
  System.Variants, System.net.httpclient,
  Math;

const
  RAI_TO_RAW = '000000000000000000000000';
  MAIN_NET_WORK_THRESHOLD = 'ffffffc000000000';
  STATE_BLOCK_PREAMBLE =
    '0000000000000000000000000000000000000000000000000000000000000006';
  STATE_BLOCK_ZERO =
    '0000000000000000000000000000000000000000000000000000000000000000';

const
  nano_charset = '13456789abcdefghijkmnopqrstuwxyz';

type
  TIntegerArray = array of System.uint32;

type
  dwSIZE_T = System.uint32;

  crypto_generichash_blake2b_state = packed record
    h: Array [0 .. 7] of UINT64;
    t: Array [0 .. 1] of UINT64;
    f: Array [0 .. 1] of UINT64;
    buf: Array [0 .. 255] of UINT8;
    buflen: dwSIZE_T;
    last_node: UINT8;
    padding64: array [0 .. 26] of byte;
  end;

  TDM = class(TAndroidService)
    function AndroidServiceStartCommand(const Sender: TObject;
      const Intent: JIntent; Flags, StartId: Integer): Integer;
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  DM: TDM;

var
  blake2b_init: function(var state: crypto_generichash_blake2b_state;
    const key: Pointer; const keylen: dwSIZE_T; const outlen: dwSIZE_T)
    : Integer;
  blake2b_update: function(var state: crypto_generichash_blake2b_state;
    const inBuf: Pointer; inlen: UINT64): Integer;
  blake2b_final: function(var state: crypto_generichash_blake2b_state;
    const outBuf: Pointer; const outlen: dwSIZE_T): Integer;

type
  TBytes = Array of System.UINT8;

type
  TNanoBlock = record
    blockType: string;
    state: Boolean;
    send: Boolean;
    Hash: string;
    signed: Boolean;
    worked: Boolean;
    signature: string;
    work: string;
    blockAmount: string;
    blockAccount: string;
    blockMessage: string;
    origin: string;
    immutable: Boolean;
    timestamp: System.uint32;
    previous: string;
    destination: string;
    balance: string;
    source: string;
    representative: string;
    account: string;
  end;

type
  TpendingNanoBlock = record

    Block: TNanoBlock;
    Hash: string;

  end;

type
  TNanoBlockChain = array of TNanoBlock;

type
  NanoCoin = class(TObject)
    pendingChain: TNanoBlockChain;
    lastBlock: string;
    lastPendingBlock: string;
    PendingBlocks: TQueue<TpendingNanoBlock>;
    PendingThread: TThread;

    lastBlockAmount: string;
    UnlockPriv: string;
    isUnlocked: Boolean;
    sessionKey: string;
    chaindir: string;
  private

  public
    procedure removeBlock(Hash: string);
    function getPreviousHash: string;
    procedure addToChain(Block: TNanoBlock);
    function inChain(Hash: string): Boolean;
    function isFork(prev: string): Boolean;
    function findUnusedPrevious: string;
    function BlockByPrev(prev: string): TNanoBlock;
    function BlockByHash(Hash: string): TNanoBlock;
    function BlockByLink(Hash: string): TNanoBlock;
    function nextBlock(Block: TNanoBlock): TNanoBlock;
    function prevBlock(Block: TNanoBlock): TNanoBlock;
    // procedure loadChain;
    function firstBlock: TNanoBlock;
    function curBlock: TNanoBlock;
    // procedure mineAllPendings(MasterSeed: string = '');
    // procedure unlock(MasterSeed: string);
    // function getPrivFromSession(): string;

    // procedure mineBlock(Block: TpendingNanoBlock;
    // MasterSeed: string); overload;
    // procedure mineBlock(Block: TpendingNanoBlock); overload;

    // procedure tryAddPendingBlock(Block: TpendingNanoBlock);

    constructor Create(); overload;

    destructor destroy();

  end;

type
  precalculatedPow = record
    Hash: string;
    work: string;
  end;

type
  precalculatedPows = array of precalculatedPow;

var
  pows: precalculatedPows;

implementation

{%CLASSGROUP 'System.Classes.TPersistent'}

uses
  System.DateUtils;
{$R *.dfm}

function findPrecalculated(Hash: string): string;
var
  pow: precalculatedPow;
begin
  Result := '';
  Hash := LowerCase(Hash);
  for pow in pows do
    if pow.Hash = Hash then
      Exit(pow.work);
end;

procedure setPrecalculated(Hash, work: string);
var
  i: Integer;
begin
  if Length(Hash) <> 64 then
    Exit;
  Hash := LowerCase(Hash);
  for i := 0 to Length(pows) - 1 do
    if pows[i].Hash = Hash then
    begin
      pows[i].work := work;
      Exit;
    end;
  SetLength(pows, Length(pows) + 1);

  pows[high(pows)].Hash := Hash;
  pows[High(pows)].work := work;
end;

procedure removePow(Hash: string);
var
  i: Integer;
begin
  for i := 0 to Length(pows) - 1 do
  begin
    if pows[i].Hash = Hash then
    begin
      pows[i] := pows[High(pows)];
      SetLength(pows, Length(pows) - 1);
      Exit;
    end;
  end;
end;

procedure savePows;
var
  ts: TStringList;
  i: Integer;
begin
  ts := TStringList.Create;
  try
    for i := 0 to Length(pows) - 1 do
    begin
      if Length(pows[i].Hash) <> 64 then
        continue;

      ts.Add(pows[i].Hash + ' ' + pows[i].work);
    end;
    ts.SaveToFile(TPath.GetDocumentsPath + '/nanopows.dat');
  finally
    ts.Free;
  end;
end;

function SplitString(Str: string; separator: char = ' '): TStringList;
var
  ts: TStringList;
  i: Integer;
begin
  Str := StringReplace(Str, separator, #13#10, [rfReplaceAll]);
  ts := TStringList.Create;
  ts.Text := Str;
  Result := ts;

end;

procedure loadPows;
var
  ts: TStringList;
  i: Integer;
  t: TStringList;
begin
  SetLength(pows, 0);
  ts := TStringList.Create;
  try
    if FileExists((TPath.GetDocumentsPath + '/nanopows.dat')) then
    begin
      ts.LoadFromFile(TPath.GetDocumentsPath + '/nanopows.dat');
      SetLength(pows, ts.Count);
      for i := 0 to ts.Count - 1 do
      begin
        t := SplitString(ts.Strings[i], ' ');
        if t.Count = 1 then
        begin
          pows[i].Hash := t[0];
          pows[i].work := '';
          continue;
        end;
        if t.Count <> 2 then
          continue;

        pows[i].Hash := t[0];
        pows[i].work := t[1];
        if pows[i].work = 'MINING' then
          pows[i].work := '';

        t.Free;
      end;
    end;
  finally
    ts.Free;
  end;

end;

function hexatotbytes(h: string): TBytes;
var
  i: Integer;
  b: System.UINT8;
  bb: TBytes;
begin

  // if not IsHex(h) then
  // raise Exception.Create(H + ' is not hex');

  SetLength(bb, (Length(h) div 2));
{$IF (DEFINED(ANDROID) OR DEFINED(IOS))}
  for i := 0 to (Length(h) div 2) - 1 do
  begin
    b := System.UINT8(StrToInt('$' + Copy(h, ((i) * 2) + 1, 2)));
    bb[i] := b;
  end;
{$ELSE}
  for i := 1 to (Length(h) div 2) do
  begin
    b := System.UINT8(StrToInt('$' + Copy(h, ((i - 1) * 2) + 1, 2)));
    bb[i - 1] := b;
  end;

{$ENDIF}
  Result := bb;
end;

function findwork(Hash: string): string;
var
  state: crypto_generichash_blake2b_state;
  workbytes: TBytes;
  res: array of System.UINT8;
  j, i: Integer;
  work: string;
begin
  loadPows;
  work := findPrecalculated(Hash);
  if (work <> '') and (work <> 'MINING') then
    Exit(work);
  randomize;
  SetLength(res, 8);
  workbytes := hexatotbytes('0000000000000000' + Hash);
  repeat
    workbytes[0] := random(255);
    workbytes[1] := random(255);
    workbytes[2] := random(255);
    workbytes[3] := random(255);
    workbytes[4] := random(255);
    workbytes[5] := random(255);
    workbytes[6] := random(255);
    for i := 0 to 255 do
    begin
      workbytes[7] := i;
      blake2b_init(state, nil, 0, 8);
      blake2b_update(state, workbytes, Length(workbytes));
      blake2b_final(state, res, 8);
      if res[7] = 255 then
        if res[6] = 255 then
          if res[5] = 255 then
            if res[4] >= 192 then
            begin
              Result := '';
              for j := 7 downto 0 do
                Result := Result + inttohex(workbytes[j], 2);
              setPrecalculated(Hash, Result);
              savePows;
              Exit;
            end;
    end;
  until true = false;
end;

function nano_builtFromJSON(JSON: TJSONValue): TNanoBlock;
begin
  Result.blockType := JSON.GetValue<string>('type');
  Result.previous := JSON.GetValue<string>('previous');
  Result.account := JSON.GetValue<string>('account');
  Result.representative := JSON.GetValue<string>('representative');
  Result.balance := JSON.GetValue<string>('balance');
  Result.destination := JSON.GetValue<string>('link');
  Result.work := JSON.GetValue<string>('work');
  Result.signature := JSON.GetValue<string>('signature');
end;

function nano_builtToJSON(Block: TNanoBlock): string;
var
  obj: TJSONObject;
begin

  obj := TJSONObject.Create();

  obj.AddPair(TJSONPair.Create('type', 'state'));
  obj.AddPair(TJSONPair.Create('previous', Block.previous));
  obj.AddPair(TJSONPair.Create('balance', Block.balance));
  obj.AddPair(TJSONPair.Create('account', Block.account));
  obj.AddPair(TJSONPair.Create('representative', Block.representative));
  obj.AddPair(TJSONPair.Create('link', Block.destination));
  obj.AddPair(TJSONPair.Create('work', Block.work));
  obj.AddPair(TJSONPair.Create('signature', Block.signature));
  Result := obj.tojson;
  obj.Free;
end;

function nano_loadChain(dir: string; limitTo: string = ''): TNanoBlockChain;
var
  path: string;
  ts: TStringList;
  Block: TNanoBlock;
begin
  SetLength(Result, 0);
  ts := TStringList.Create;
  try
    for path in TDirectory.GetFiles(dir) do
    begin
      ts.LoadFromFile(path);
      Block := nano_builtFromJSON(TJSONObject.ParseJSONValue(ts.Text)
        as TJSONValue);
      if limitTo <> '' then
        if Block.account <> limitTo then
          continue;
      Block.Hash := StringReplace(ExtractFileName(path), '.block.json', '',
        [rfReplaceAll]);
      SetLength(Result, Length(Result) + 1);
      Result[High(Result)] := Block;
    end;

  finally
    ts.Free;
  end;

end;

constructor NanoCoin.Create();
begin
  PendingBlocks := TQueue<TpendingNanoBlock>.Create();
  isUnlocked := false;

end;

destructor NanoCoin.destroy;
begin

  inherited;
  PendingBlocks.Free;

end;

function NanoCoin.inChain(Hash: string): Boolean;
var
  i: Integer;
begin
  Result := false;
  for i := 0 to Length(pendingChain) - 1 do
    if Self.pendingChain[i].Hash = Hash then
      Exit(true);

end;

function NanoCoin.isFork(prev: string): Boolean;
var
  i: Integer;
begin
  Result := false;
  for i := 0 to Length(pendingChain) - 1 do
    if pendingChain[i].previous = prev then
      Exit(true);

end;

procedure NanoCoin.addToChain(Block: TNanoBlock);
begin
  if (not inChain(Block.Hash)) and (not isFork(Block.previous)) then
  begin
    SetLength(pendingChain, Length(pendingChain) + 1);
    pendingChain[high(pendingChain)] := Block;
  end;
end;

procedure NanoCoin.removeBlock(Hash: string);
var
  i: Integer;
begin
  for i := 0 to Length(pendingChain) - 1 do
    if pendingChain[i].Hash = Hash then
    begin
      pendingChain[i] := pendingChain[High(pendingChain)];
      SetLength(pendingChain, Length(pendingChain) - 1);
      DeleteFile(TPath.Combine(chaindir, Hash + '.block.json'));
    end;

end;

function NanoCoin.findUnusedPrevious: string;
var
  i: Integer;
begin
  Result := '0000000000000000000000000000000000000000000000000000000000000000';
  for i := 0 to Length(pendingChain) - 1 do
    if not isFork(pendingChain[i].Hash) then
      Exit(pendingChain[i].Hash);
end;

function NanoCoin.BlockByPrev(prev: string): TNanoBlock;
var
  i: Integer;
begin
  Result.account := '';
  for i := 0 to Length(pendingChain) - 1 do
    if pendingChain[i].previous = prev then
      Exit(pendingChain[i]);
end;

function NanoCoin.BlockByHash(Hash: string): TNanoBlock;
var
  i: Integer;
begin
  Result.account := '';
  for i := 0 to Length(pendingChain) - 1 do
    if pendingChain[i].Hash = Hash then
      Exit(pendingChain[i]);
end;

function NanoCoin.BlockByLink(Hash: string): TNanoBlock;
var
  i: Integer;
begin
  Result.account := '';
  for i := 0 to Length(pendingChain) - 1 do
    if pendingChain[i].destination = Hash then
      Exit(pendingChain[i]);
end;

function NanoCoin.nextBlock(Block: TNanoBlock): TNanoBlock;
begin
  Result := BlockByPrev(Block.Hash);
end;

function NanoCoin.prevBlock(Block: TNanoBlock): TNanoBlock;
begin
  Result := BlockByHash(Block.previous);
end;

function NanoCoin.firstBlock: TNanoBlock;
var
  prev, cur: TNanoBlock;
begin
  if Length(Self.pendingChain) = 0 then
    Exit;

  cur := Self.pendingChain[0];
  repeat
    prev := prevBlock(cur);
    if prev.account <> '' then
      cur := prev;
  until prev.account = '';
  Result := cur;
end;

function NanoCoin.curBlock: TNanoBlock;
var
  next, cur: TNanoBlock;
begin
  if Length(Self.pendingChain) = 0 then
    Exit;

  cur := Self.pendingChain[0];
  repeat
    next := nextBlock(cur);
    if next.account <> '' then
      cur := next;
  until next.account = '';
  Result := cur;
end;

function NanoCoin.getPreviousHash(): string;
var
  i, l: Integer;
begin
  Result := Self.lastPendingBlock;
  if Length(Self.pendingChain) > 0 then
    Exit(curBlock.Hash);

  if Self.lastBlock <> '' then
  begin
    Result := Self.lastBlock;
    Self.lastBlock := '';
    Exit;
  end;
  l := Length(Self.PendingBlocks.ToArray);
  if l > 0 then
  begin
    for i := 0 to l - 1 do
    begin
      Result := Self.PendingBlocks.ToArray[i].Hash;

    end;

  end;

end;

function ChangeBits(var data: array of System.uint32;
  frombits, tobits: System.uint32; pad: Boolean = true): TIntegerArray;
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
      SetLength(ret, Length(ret) + 1);
      ret[Length(ret) - 1] := ((acc shr bits) and maxv);
      inc(j);
    end;
  end;

  if pad then
  begin
    j := 0;
    if bits <> 0 then
    begin
      SetLength(ret, Length(ret) + 1);
      ret[Length(ret) - 1] := (acc shl (tobits - bits)) and maxv;
      inc(j);
    end;
  end;

  Result := TIntegerArray(ret);
end;

function nano_keyFromAccount(adr: string): string;
var
  chk: string;
  rAdr, rChk: TIntegerArray;
  i: Integer;
begin
  Result := adr;
  adr := StringReplace(adr, 'xrb_', '', [rfReplaceAll]);
  adr := StringReplace(adr, 'nano_', '', [rfReplaceAll]);
  chk := Copy(adr, 52 + 1, 100);
  adr := '1111' + Copy(adr, 1, 52);
  SetLength(rAdr, Length(adr));
  SetLength(rChk, Length(chk));
  for i := 0 to Length(adr) - 1 do
    rAdr[i] := Pos(adr[i{$IFDEF MSWINDOWS} + 1{$ENDIF}], nano_charset) - 1;

  for i := 0 to Length(chk) - 1 do
    rChk[i] := Pos(chk[i{$IFDEF MSWINDOWS} + 1{$ENDIF}], nano_charset) - 1;
  Result := '';
  rAdr := ChangeBits(rAdr, 5, 8, true);
  for i := 3 to Length(rAdr) - 1 do
    Result := Result + inttohex(rAdr[i], 2)
end;

function nano_getPrevious(Block: TNanoBlock): string;
begin
  if Block.previous = STATE_BLOCK_ZERO then
  begin
    if Pos('_', Block.account) > 0 then
      Exit(nano_keyFromAccount(Block.account))
    else
      Exit(Block.account);
  end;
  Result := Block.previous;
end;

function nano_getWork(var Block: TNanoBlock): string;
begin
  Block.work := findwork(nano_getPrevious(Block));
  Block.worked := true;

end;

function getDataOverHTTP(aURL: String; useCache: Boolean = true;
  noTimeout: Boolean = false): string;
var
  req: THTTPClient;
  LResponse: IHTTPResponse;
  urlHash: string;
begin
  req := THTTPClient.Create();
  try
    LResponse := req.get(aURL);
    Result := LResponse.ContentAsString();
  except
    on E: Exception do
    begin
      Result := E.Message;

    end;

  end;
  req.Free;
end;

function nano_pushBlock(b: string): string;
begin
  Result := getDataOverHTTP('https://hodlernode.net/nano.php?b=' + b,
    false, true);
end;

function IsHex(s: string): Boolean;
var
  i: Integer;
begin
  // Odd string or empty string is not valid hexstring
  if (Length(s) = 0) or (Length(s) mod 2 <> 0) then
    Exit(false);

  s := UpperCase(s);
  Result := true;
  for i := 0 to Length(s) - 1 do
    if not(char(s[i]) in ['0' .. '9']) and not(char(s[i]) in ['A' .. 'F']) then
    begin
      Result := false;
      Exit;
    end;
end;

procedure nano_mineBuilt64(cc: NanoCoin);
var
  Block: TNanoBlock;
  lastHash, s: string;
  isCorrupted: Boolean;
begin
  isCorrupted := false;
  repeat
    Block := cc.firstBlock;

    if Block.account <> '' then
    begin

      if not isCorrupted then
      begin
        nano_getWork(Block);

        s := nano_pushBlock(nano_builtToJSON(Block));

        lastHash := StringReplace(s, 'https://www.nanode.co/block/', '',
          [rfReplaceAll]);

        if IsHex(lastHash) = false then
        begin
          if LeftStr(lastHash, Length('Transaction failed')) = 'Transaction failed'
          then
          begin
            isCorrupted := true;
          end;
          lastHash := '';
        end;
        if cc.BlockByPrev(lastHash).account = '' then
          if lastHash <> '' then
            findwork(lastHash);
      end;
    end;
    cc.removeBlock(Block.Hash);
  until Length(cc.pendingChain) = 0;
end;

procedure mineAll;
var
  cc: NanoCoin;
  path: string;
  i: Integer;
begin

  repeat
    for path in TDirectory.GetDirectories
      (IncludeTrailingPathDelimiter(System.IOUtils.TPath.GetDocumentsPath)) do
    begin
      if DirectoryExists(TPath.Combine(path, 'Pendings')) then
      begin
        cc := NanoCoin.Create();
        cc.chaindir := TPath.Combine(path, 'Pendings');
        cc.pendingChain := nano_loadChain(TPath.Combine(path, 'Pendings'));
        nano_mineBuilt64(cc);
        cc.Free;
      end;
      Sleep(100);
    end;
    loadPows;
    for i := 0 to Length(pows) - 1 do
      if pows[i].work = '' then
        findwork(pows[i].Hash);
  until true = false;
end;

function TDM.AndroidServiceStartCommand(const Sender: TObject;
  const Intent: JIntent; Flags, StartId: Integer): Integer;

var
  err, ex: string;
  LibHandle: THandle;
var
  LBuilder: DW.Androidapi.JNI.Support.JNotificationCompat_Builder;
  channel: JNotificationChannel;
  manager: JNotificationManager;
  group: JNotificationChannelGroup;
begin
  group := TJNotificationChannelGroup.Create;
  group := TJNotificationChannelGroup.JavaClass.init(StringToJString('hodler'),
    StrToJCharSequence('hodler'));

  manager := TJNotificationManager.Wrap
    ((TAndroidHelper.context.getSystemService
    (TJContext.JavaClass.NOTIFICATION_SERVICE) as ILocalObject).GetObjectID);
  manager.createNotificationChannelGroup(group);
  channel := TJNotificationChannel.Create;
  channel := TJNotificationChannel.JavaClass.init(StringToJString('hodler'),
    StrToJCharSequence('hodler'), 0);

  channel.setGroup(StringToJString('hodler'));
  channel.setName(StrToJCharSequence('hodler'));
  channel.enableLights(true);
  channel.enableVibration(true);
  channel.setLightColor(TJColor.JavaClass.GREEN);
  channel.setLockscreenVisibility(TJNotification.JavaClass.VISIBILITY_PRIVATE);

  manager.createNotificationChannel(channel);
  // EnableWakeLock(True);
  LBuilder := DW.Androidapi.JNI.Support.TJNotificationCompat_Builder.JavaClass.
    init(TAndroidHelper.context);
  LBuilder.setAutoCancel(true);
  LBuilder.setGroupSummary(true);
  LBuilder.setChannelId(channel.getId);
  LBuilder.setContentTitle(StrToJCharSequence('HODLER - Nano PoW Worker'));
  LBuilder.setContentText(StrToJCharSequence('Doing work for mine the blocks'));
  LBuilder.setSmallIcon(TAndroidHelper.context.getApplicationInfo.icon);
  LBuilder.setTicker(StrToJCharSequence('HODLER - Nano PoW Worker'));
  DM.JavaService.StartForeground(1995, LBuilder.build);
  Result := TJService.JavaClass.START_STICKY;
  err := 'la';
  try
    try
      err := TPath.GetDocumentsPath + '/nacl2/libsodium.so';
      if FileExists(err) then
        ex := 'isthere'
      else
        ex := 'uuuuu';
      LibHandle := LoadLibrary(PwideChar(err));
      if LibHandle <> 0 then
      begin
        blake2b_init := getprocaddress(LibHandle,
          PwideChar('crypto_generichash_blake2b_init'));
        blake2b_update := getprocaddress(LibHandle,
          'crypto_generichash_blake2b_update');
        blake2b_final := getprocaddress(LibHandle,
          'crypto_generichash_blake2b_final');
      end;
    except
      on E: Exception do
      begin
        // no libsodium, so kill yourself
        Exit;
      end;

    end;
  finally

  end;
  TThread.CreateAnonymousThread(
    procedure
    begin
      mineAll;
    end).Start();

end;

end.
