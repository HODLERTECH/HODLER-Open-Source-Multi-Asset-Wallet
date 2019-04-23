// Nanocurrency unit, Copyleft 2019 FL4RE - Daniel Mazur
unit Nano;

interface

uses

{$IFDEF  ANDROID}Androidapi.JNI, {$ENDIF} AESObj, SPECKObj, FMX.Objects,
  IdHash, IdHashSHA,
  IdSSLOpenSSL, languages,

  System.Hash, MiscOBJ, SysUtils, System.IOUtils, HashObj, System.Types,
  System.UITypes,
  System.DateUtils, System.Generics.Collections, System.Classes,
  System.Variants,
  Math, FMX.Types, FMX.Graphics, FMX.Controls, FMX.Forms, FMX.Dialogs,
  FMX.StdCtrls,
  FMX.Controls.Presentation, FMX.Styles, System.ImageList, FMX.ImgList, FMX.Ani,
  FMX.Layouts, FMX.ExtCtrls, Velthuis.BigIntegers, FMX.ScrollBox, FMX.Memo,
  FMX.platform,
  FMX.TabControl, {$IF NOT DEFINED(LINUX)}System.Sensors,
  System.Sensors.Components, {$ENDIF}
  FMX.Edit, JSON, JSON.Builders, JSON.Readers, DelphiZXingQRCode,
  System.Net.HttpClientComponent,
  System.Net.HttpClient, keccak_n, tokenData, bech32, cryptoCurrencyData,
  WalletStructureData, AccountData, ClpCryptoLibTypes, ClpSecureRandom,
  ClpISecureRandom, ClpCryptoApiRandomGenerator,
  ClpICryptoApiRandomGenerator,
  AssetsMenagerData, HlpBlake2BConfig, HlpBlake2B, HlpHashFactory,
  ClpDigestUtilities, HlpIHash, misc, ClpIX9ECParameters,
  ClpIECDomainParameters,
  ClpECDomainParameters, ClpIECKeyPairGenerator, ClpECKeyPairGenerator,
  ClpIECKeyGenerationParameters, ClpIAsymmetricCipherKeyPair,
  ClpIECPrivateKeyParameters, ClpIECPublicKeyParameters,
  ClpECPrivateKeyParameters, ClpIECInterface, ClpHex, ClpCustomNamedCurves,
  ClpHMacDsaKCalculator, ECCObj, System.SyncObjs

{$IFDEF ANDROID}, Androidapi.JNI.GraphicsContentViewText,
  Androidapi.JNI.JavaTypes,
  Androidapi.Helpers, Androidapi.JNI.Net, Androidapi.JNI.Os,
  Androidapi.JNI.Webkit,
  Androidapi.JNIBridge
{$ENDIF}
{$IFDEF MSWINDOWS}
    , Winapi.ShellApi

{$ENDIF};

const
  RAI_TO_RAW = '000000000000000000000000';
  MAIN_NET_WORK_THRESHOLD = 'ffffffc000000000';
  STATE_BLOCK_PREAMBLE =
    '0000000000000000000000000000000000000000000000000000000000000006';
  STATE_BLOCK_ZERO =
    '0000000000000000000000000000000000000000000000000000000000000000';

var
  hashcounter: cardinal; // 100k tries

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
    blockAmount: BigInteger;
    blockAccount: string;
    blockMessage: string;
    origin: string;
    immutable: Boolean;
    timestamp: System.UInt32;
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
    Hash: String;

  end;

type
  TNanoBlockChain = array of TNanoBlock;

type
  NanoCoin = class(TwalletInfo)
    pendingChain: TNanoBlockChain;

    PendingBlocks: TQueue<TpendingNanoBlock>;
    PendingThread: TThread;
    mutexMining: TSemaphore;
    lastBlockAmount: BigInteger;
    UnlockPriv: String;
    isUnlocked: Boolean;
    sessionKey: String;
    chaindir: string;
  private

  public
    procedure removeBlock(Hash: string);
    function getPreviousHash: String;
    procedure addToChain(Block: TNanoBlock);
    function inChain(Hash: String): Boolean;
    function isFork(prev: String): Boolean;
    function findUnusedPrevious: String;
    function BlockByPrev(prev: String): TNanoBlock;
    function BlockByHash(Hash: String): TNanoBlock;
    function BlockByLink(Hash: String): TNanoBlock;
    function nextBlock(Block: TNanoBlock): TNanoBlock;
    function prevBlock(Block: TNanoBlock): TNanoBlock;
    procedure loadChain;
    function firstBlock: TNanoBlock;
    function curBlock: TNanoBlock;
    procedure mineAllPendings(MasterSeed: String = '');
    procedure unlock(MasterSeed: String);
    function getPrivFromSession(): String;

    procedure mineBlock(Block: TpendingNanoBlock; MasterSeed: String); overload;
    procedure mineBlock(Block: TpendingNanoBlock); overload;

    procedure tryAddPendingBlock(Block: TpendingNanoBlock);

    constructor Create(id: integer; _x: integer; _y: integer; _addr: String;
      _description: String; crTime: integer = -1); overload;

    constructor Create(); overload;

    destructor destroy();
    // ConfirmThread : TAutoReceive;

    // procedure runAutoConfirm();

  end;

procedure nano_checkMineState(acc: account);
procedure saveBlockToJSON(Block: TNanoBlock);
function nano_pow(Hash: String): String;
function nano_getWork(var Block: TNanoBlock): String;
procedure removePow(Hash: String);
function nano_builtToJSON(Block: TNanoBlock): string;
procedure setPrecalculated(Hash, work: String);

function findPrecalculated(Hash: String): String;

procedure nano_test();
procedure savePows;
procedure nano_precalculate(Hash: String);

function nano_accountFromHexKey(adr: String): String;
function isInPows(Hash: String): Boolean;
function nano_getPriv(x, y: System.UInt32; MasterSeed: String): String;
  overload;
function nano_getPriv(wd: NanoCoin; MasterSeed: String): String; overload;

function nano_keyFromAccount(adr: String): String;

function nano_createHD(x, y: System.UInt32; MasterSeed: String): TwalletInfo;

function nano_obtainBlock(Hash: String): String;

function nano_addPendingReceiveBlock(sourceBlockHash: String;
  cc: cryptoCurrency; from: String; ms: String; amount: BigInteger;
  doWork: Boolean = false): TNanoBlock; overload;
function nano_addPendingReceiveBlock(sourceBlockHash: String; cc: NanoCoin;
  from: String; amount: BigInteger; doWork: Boolean = false)
  : TNanoBlock; overload;

function nano_buildFromJSON(JSON, prev: String; hexBalance: Boolean = false)
  : TNanoBlock;

function nano_getJSONBlock(Block: TNanoBlock): String;

function nano_checkWork(Block: TNanoBlock; work: String;
  blockHash: String = ''): Boolean;

function nano_getBlockHash(var Block: TNanoBlock): String;

procedure nano_DoMine(cc: cryptoCurrency; pw: String);
procedure loadPows;
function nano_send(var from: TwalletInfo; sendto: String; amount: BigInteger;
  MasterSeed: String): String;

function nano_pushBlock(b: String): String;

procedure nano_signBlock(var Block: TNanoBlock; cc: NanoCoin); overload;
procedure nano_signBlock(var Block: TNanoBlock; cc: cryptoCurrency;
  ms: String); overload;

procedure nano_mineBuilt(cc: NanoCoin);
function nano_loadChain(dir: string; limitTo: string = ''): TNanoBlockChain;
{$IFDEF  ANDROID}
function AcquireWakeLock: Boolean;
procedure ReleaseWakeLock;
{$ENDIF}

type
  precalculatedPow = record
    Hash: String;
    work: String;
  end;

type
  precalculatedPows = array of precalculatedPow;

  TPowWorker = class(TThread)
  public
    foundWork: String;
    Hash: String;
    Blake2b: IHash;
  protected
    procedure execute; override;
  end;

var
  pows: precalculatedPows;

implementation

uses
  ED25519_Blake2b, uHome, PopupWindowData, keypoolrelated, walletviewrelated

{$IFDEF  ANDROID}, FMX.Helpers.Android{$ENDIF};

/// ///////////////////////////////////////////////////////////////////
{$IFDEF  ANDROID}

function GetPowerManager: JPowerManager;
var
  PowerServiceNative: JObject;
begin
  PowerServiceNative := TAndroidHelper.Context.getSystemService
    (TJContext.JavaClass.POWER_SERVICE);
  if not Assigned(PowerServiceNative) then
    raise Exception.Create('Could not locate Power Service');
  Result := TJPowerManager.Wrap((PowerServiceNative as ILocalObject)
    .GetObjectID);
  if not Assigned(Result) then
    raise Exception.Create('Could not access Power Manager');
end;

var
  // *** this is in Androidapi.JNI.Os
  // WakeLock: JWakeLock = nil;
  WakeLock: JPowerManager_WakeLock = nil;

function AcquireWakeLock: Boolean;
var
  PowerManager: JPowerManager;
begin
  Result := Assigned(WakeLock);
  if not Result then
  begin
    PowerManager := GetPowerManager;
    WakeLock := PowerManager.newWakeLock
      (TJPowerManager.JavaClass.SCREEN_BRIGHT_WAKE_LOCK,
      StringToJString('NANOMinerHodler'));
    Result := Assigned(WakeLock);
  end;
  if Result then
  begin
    if not WakeLock.isHeld then
    begin
      WakeLock.acquire;
      Result := WakeLock.isHeld
    end;
  end;
end;

procedure ReleaseWakeLock;
begin
  if Assigned(WakeLock) then
  begin
    WakeLock.release;
    WakeLock := nil
  end;
end;
{$ENDIF}

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

procedure nano_checkMineState(acc: account);
var
  path: string;
  ts: TStringList;
  addr: string;
  i: integer;
  bi, delta: BigInteger;
begin
  ts := TStringList.Create;
  try
    for path in TDirectory.GetFiles(HOME_PATH) do
    begin
      bi := 0;
      if Pos('.state', path) > 0 then
      begin
        addr := StringReplace(ExtractFileName(path), '.state', '',
          [rfReplaceAll]);
        for i := 0 to High(acc.mycoins) do
          if acc.mycoins[i].coin = 8 then
            if acc.mycoins[i].addr = addr then
            begin
              ts.LoadFromFile(path);
              BigInteger.TryParse(ts.Strings[0], 10, bi);
              if bi <> NanoCoin(acc.mycoins[i]).confirmed then
              begin
                delta := bi - NanoCoin(acc.mycoins[i]).confirmed;
                NanoCoin(acc.mycoins[i]).confirmed := bi;
                NanoCoin(acc.mycoins[i]).unconfirmed := NanoCoin(acc.mycoins[i])
                  .unconfirmed - BigInteger.abs(delta);
                // abs(...) doesnt work with bigInteger
                {
                  refreshGlobalFiat();
                  TThread.Synchronize(TThread.CurrentThread,
                  procedure
                  begin
                  repaintWalletList;
                  end);
                }
                ReloadWalletView();
                ts.Free;
                DeleteFile(path);
                ts := TStringList.Create;
              end;
            end;
      end;
    end;

  finally
    ts.Free;
  end;

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
          Continue;
      Block.Hash := StringReplace(ExtractFileName(path), '.block.json', '',
        [rfReplaceAll]);
      SetLength(Result, Length(Result) + 1);
      Result[High(Result)] := Block;
    end;

  finally
    ts.Free;
  end;

end;

procedure NanoCoin.loadChain;
begin
  if CurrentAccount <> nil then
  begin
      SetLength(Self.pendingChain, 0);
    Self.chaindir := TPath.Combine(CurrentAccount.DirPath, 'Pendings');
    if directoryexists(Self.chaindir) then
      Self.pendingChain := nano_loadChain(chaindir, Self.addr)
    else
      SetLength(Self.pendingChain, 0);
  end
  else
    SetLength(Self.pendingChain, 0);
end;

constructor NanoCoin.Create(id: integer; _x: integer; _y: integer;
  _addr: String; _description: String; crTime: integer = -1);
begin

  inherited Create(id, _x, _y, _addr, _description, crTime);

  PendingBlocks := TQueue<TpendingNanoBlock>.Create();
  mutexMining := TSemaphore.Create();
  isUnlocked := false;
  loadChain;

end;

constructor NanoCoin.Create();
begin

  // inherited Create(id, _x, _y, _addr, _description, crTime);

  PendingBlocks := TQueue<TpendingNanoBlock>.Create();
  mutexMining := TSemaphore.Create();
  isUnlocked := false;
  // loadChain;

end;

destructor NanoCoin.destroy;
begin

  inherited;
  wipeString(UnlockPriv);

  PendingBlocks.Free;
  mutexMining.Free;

end;

function NanoCoin.inChain(Hash: String): Boolean;
var
  i: integer;
begin
  Result := false;
  for i := 0 to Length(pendingChain) - 1 do
    if Self.pendingChain[i].Hash = Hash then
      Exit(True);

end;

function NanoCoin.isFork(prev: String): Boolean;
var
  i: integer;
begin
  Result := false;
  for i := 0 to Length(pendingChain) - 1 do
    if pendingChain[i].previous = prev then
      Exit(True);

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
  i: integer;
begin
  for i := 0 to Length(pendingChain) - 1 do
    if pendingChain[i].Hash = Hash then
    begin
      pendingChain[i] := pendingChain[High(pendingChain)];
      SetLength(pendingChain, Length(pendingChain) - 1);
      DeleteFile(TPath.Combine(chaindir, Hash + '.block.json'));
    end;

end;

function NanoCoin.findUnusedPrevious: String;
var
  i: integer;
begin
  Result := '0000000000000000000000000000000000000000000000000000000000000000';
  for i := 0 to Length(pendingChain) - 1 do
    if not isFork(pendingChain[i].Hash) then
      Exit(pendingChain[i].Hash);
end;

function NanoCoin.BlockByPrev(prev: String): TNanoBlock;
var
  i: integer;
begin
  Result.account := '';
  for i := 0 to Length(pendingChain) - 1 do
    if pendingChain[i].previous = prev then
      Exit(pendingChain[i]);
end;

function NanoCoin.BlockByHash(Hash: String): TNanoBlock;
var
  i: integer;
begin
  Result.account := '';
  for i := 0 to Length(pendingChain) - 1 do
    if pendingChain[i].Hash = Hash then
      Exit(pendingChain[i]);
end;

function NanoCoin.BlockByLink(Hash: String): TNanoBlock;
var
  i: integer;
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

function NanoCoin.getPrivFromSession;
var
  i: integer;
begin
  if isUnlocked = false then
    raise Exception.Create('nano must be unlocked first');

  SetLength(Result, Length(UnlockPriv));
  for i := low(UnlockPriv) to High(UnlockPriv) do
  begin
    Result[i] := char(ord(sessionKey[i]) xor ord(UnlockPriv[i]));
  end;

end;

procedure NanoCoin.unlock(MasterSeed: String);
var
  i: integer;
begin

  UnlockPriv := nano_getPriv(self, MasterSeed);
  SetLength(sessionKey, Length(UnlockPriv));
  for i := low(UnlockPriv) to High(UnlockPriv) do
  begin
    sessionKey[i] := char(random(255));
  end;

  for i := low(UnlockPriv) to High(UnlockPriv) do
  begin
    UnlockPriv[i] := char(ord(sessionKey[i]) xor ord(UnlockPriv[i]));
  end;

  isUnlocked := True;

  mineAllPendings();

end;

procedure NanoCoin.mineAllPendings(MasterSeed: String = '');
begin
  if (isUnlocked = false) and (MasterSeed = '') then
    raise Exception.Create('nano must be unlocked first');

  if (PendingThread = nil) or (PendingThread.Finished) then
  begin

    if (PendingThread <> nil) and (PendingThread.Finished) then
      PendingThread.Free;

    PendingThread := TThread.CreateAnonymousThread(
      procedure
      begin

        while (PendingBlocks.Count <> 0) do
        begin

          if MasterSeed = '' then
            mineBlock(PendingBlocks.Dequeue)
          else
            mineBlock(PendingBlocks.Dequeue, MasterSeed);

        end;

      end);

    PendingThread.FreeOnTerminate := false;
    PendingThread.Start;
  end;

  wipeString(MasterSeed);
end;

function NanoCoin.getPreviousHash(): String;
var
  i, l: integer;
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

procedure NanoCoin.tryAddPendingBlock(Block: TpendingNanoBlock);
var
  it: TQueue<TpendingNanoBlock>.TEnumerator;
  arr: Tarray<TpendingNanoBlock>;
  i: integer;
begin
  if PendingBlocks = nil then
    PendingBlocks := TQueue<TpendingNanoBlock>.Create();
  arr := PendingBlocks.ToArray;
  if Length(arr) > 0 then
    for i := 0 to Length(arr) - 1 do
      if arr[i].Hash = Block.Hash then
        Exit;

  PendingBlocks.Enqueue(Block);

  if isUnlocked then
    mineAllPendings();

end;

/// ///////////////////////////////////////////////////////////////////

const
  nano_charset = '13456789abcdefghijkmnopqrstuwxyz';

function nano_getWalletRepresentative: String;
begin
  Result := 'xrb_1nanode8ngaakzbck8smq6ru9bethqwyehomf79sae1k7xd47dkidjqzffeg';
end;

function nano_keyFromAccount(adr: String): String;
var
  chk: String;
  rAdr, rChk: TIntegerArray;
  i: integer;
begin
  Result := adr;
  adr := StringReplace(adr, 'xrb_', '', [rfReplaceAll]);
  adr := StringReplace(adr, 'nano_', '', [rfReplaceAll]);
  chk := Copy(adr, 52 + 1, 100);
  adr := '1111' + Copy(adr, 1, 52);
  SetLength(rAdr, Length(adr));
  SetLength(rChk, Length(chk));
  for i := 0 to Length(adr) - 1 do
    rAdr[i] := Pos(adr[i{$IF DEFINED(MSWINDOWS) OR DEFINED(LINUX)} + 1{$ENDIF}],
      nano_charset) - 1;

  for i := 0 to Length(chk) - 1 do
    rChk[i] := Pos(chk[i{$IF DEFINED(MSWINDOWS) OR DEFINED(LINUX)} + 1{$ENDIF}],
      nano_charset) - 1;
  Result := '';
  rAdr := ChangeBits(rAdr, 5, 8, True);
  for i := 3 to Length(rAdr) - 1 do
    Result := Result + inttohex(rAdr[i], 2)
end;

function nano_encodeBase32(values: TIntegerArray): string;
var
  i: integer;
begin
  Result := '';
  for i := 0 to Length(values) - 1 do
  begin
    Result := Result + nano_charset[values[i] + low(nano_charset)];
  end;
end;

function nano_addressChecksum(m: String): String;
var
  Blake2b: IHash;
begin
  Blake2b := THashFactory.TCrypto.CreateBlake2B(TBlake2BConfig.Create(5));
  Blake2b.Initialize();
  Blake2b.TransformBytes(hexatotbytes(m), 0, Length(m) div 2);
  Result := Blake2b.TransformFinal.ToString();
  Result := reversehexorder(Result);
end;

function nano_accountFromHexKey(adr: String): String;
var
  data, chk: TIntegerArray;
begin
  Result := 'FAILED';
  chk := hexatotintegerarray(nano_addressChecksum(adr));
  adr := '303030' + adr;
  data := hexatotintegerarray(adr);
  // Copy(adr,4{$IFDEF MSWINDOWS}+1{$ENDIF},100)

  data := ChangeBits(data, 8, 5, True);
  chk := ChangeBits(chk, 8, 5, True);
  Delete(data, 0, 4);
  Result := 'xrb_' + nano_encodeBase32(data) + nano_encodeBase32(chk);
end;

function nano_newBlock(state: Boolean = false): TNanoBlock;
begin
  Result.state := state;
  Result.signed := false;
  Result.worked := false;
  Result.signature := '';
  Result.work := '';
  Result.blockAmount := 0;
  Result.immutable := false;
end;

function nano_getPrevious(Block: TNanoBlock): String;
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

function nano_getBlockHash(var Block: TNanoBlock): String;
var
  Blake2b: IHash;
  toHash: String;
begin
  Blake2b := THashFactory.TCrypto.CreateBlake2B_256();
  Blake2b.Initialize();
  toHash := '';
  if Block.state then
  begin
    Blake2b.TransformBytes(hexatotbytes(STATE_BLOCK_PREAMBLE));
    Blake2b.TransformBytes(hexatotbytes(Block.account));
    Blake2b.TransformBytes(hexatotbytes(Block.previous));
    Blake2b.TransformBytes(hexatotbytes(Block.representative));
    Blake2b.TransformBytes
      (hexatotbytes(reversehexorder(inttotx(BigInteger.Parse('+0x00' +
      Block.balance), 32))));

    if Block.blockType = 'send' then
      Blake2b.TransformBytes(hexatotbytes(Block.destination));
    // toHash := toHash + block.destination;
    if Block.blockType = 'receive' then
      Blake2b.TransformBytes(hexatotbytes(Block.source));
    // toHash := toHash + block.source;
    if Block.blockType = 'open' then
      Blake2b.TransformBytes(hexatotbytes(Block.source));
    // toHash := toHash + block.source;
    if Block.blockType = 'change' then
      Blake2b.TransformBytes(hexatotbytes(STATE_BLOCK_ZERO));
    // STATE_BLOCK_ZERO;
  end
  else
  begin
    if Block.blockType = 'send' then
    begin
      Blake2b.TransformBytes(hexatotbytes(Block.previous));
      Blake2b.TransformBytes(hexatotbytes(Block.destination));
      Blake2b.TransformBytes
        (hexatotbytes(reversehexorder(inttotx(BigInteger.Parse('0x00' +
        Block.balance), 32))));

    end;
    if Block.blockType = 'receive' then
    begin
      Blake2b.TransformBytes(hexatotbytes(Block.previous));
      Blake2b.TransformBytes(hexatotbytes(Block.source));
    end;
    if Block.blockType = 'open' then
    begin
      Blake2b.TransformBytes(hexatotbytes(Block.source));
      Blake2b.TransformBytes(hexatotbytes(Block.representative));
      Blake2b.TransformBytes(hexatotbytes(Block.account));
    end;
    if Block.blockType = 'change' then
    begin
      Blake2b.TransformBytes(hexatotbytes(Block.previous));
      Blake2b.TransformBytes(hexatotbytes(Block.representative));
    end;
  end;
  Result := Blake2b.TransformFinal.ToString();
  Block.Hash := Result;
end;

procedure nano_setSendParameters(var Block: TNanoBlock;
previousBlockHash, destinationAccount, balanceRemaining: String);
var
  accKey: String;
begin

  if (not IsHex(previousBlockHash)) then
    raise Exception.Create('Invalid previous block hash');
  try
    accKey := nano_keyFromAccount(destinationAccount);
  except
    on E: Exception do
      raise Exception.Create('Invalid dest address');
  end;
  Block.previous := previousBlockHash;
  Block.destination := accKey;
  Block.balance := balanceRemaining;
  Block.blockType := 'send';
end;

procedure nano_setReceiveParameters(var Block: TNanoBlock;
previousBlockHash, sourceBlockHash: String);
begin
  if (not IsHex(previousBlockHash)) then
    raise Exception.Create('Invalid previous block hash');
  if (not IsHex(sourceBlockHash)) then
    raise Exception.Create('Invalid source block hash ' + sourceBlockHash);

  Block.previous := previousBlockHash;
  Block.source := sourceBlockHash;
  Block.blockType := 'receive';

end;

procedure nano_setStateParameters(var Block: TNanoBlock;
newAccount, representativeAccount, curBalance: String);
begin

  try
    Block.account := nano_keyFromAccount(newAccount);

  except
    on E: Exception do
      raise Exception.Create('Invalid address');
  end;
  try
    Block.representative := nano_keyFromAccount(representativeAccount);

  except
    on E: Exception do
      raise Exception.Create('Invalid representative address');
  end;
  Block.balance := curBalance;
end;

procedure nano_setOpenParameters(var Block: TNanoBlock;
sourceBlockHash, newAccount, representativeAccount: String);
begin
  if (not IsHex(sourceBlockHash)) then
    raise Exception.Create('Invalid source block hash');

  if representativeAccount <> '' then
    Block.representative := nano_keyFromAccount(representativeAccount)
  else
    Block.representative := Block.account;
  Block.source := sourceBlockHash;
  if Block.state then
    Block.previous := STATE_BLOCK_ZERO;
  Block.blockType := 'open';

end;

procedure nano_setChangeParameters(var Block: TNanoBlock;
previousBlockHash, representativeAccount: String);
begin
  if not IsHex(previousBlockHash) then
    raise Exception.Create('Invalid previous block hash');
  Block.representative := nano_keyFromAccount(representativeAccount);
  Block.previous := previousBlockHash;
  Block.blockType := 'change';

end;

procedure nano_setSignature(var Block: TNanoBlock; hex: String);
begin
  Block.signature := hex;
  Block.signed := True;
end;

procedure TPowWorker.execute;
var
  i, j: System.Uint8;
  workBytes, t: Tarray<Byte>;
var
  work: String;
  ran, thres: System.UInt64;
  counter: Int64;
var
  &random: ISecureRandom;
begin

  try
    Self.foundWork := '';
    counter := 1;
    Blake2b := THashFactory.TCrypto.CreateBlake2B(TBlake2BConfig.Create(8));
    Blake2b.Initialize();

    thres := $FFFFFFC000000000;
    workBytes := hexatotbytes('0000000000000000' + Hash);
    random := TSecureRandom.GetInstance('SHA256PRNG');
    ran := random.NextInt64;
    Move(ran, workBytes[0], 8);

    while True do

    begin
      Inc(hashcounter, 256);
      for i := 0 to 255 do
      begin
        workBytes[7] := i;

        if Terminated then
          Exit();

        Blake2b.TransformBytes(workBytes);
        t := Blake2b.TransformFinal.GetBytes;
        if t[7] = 255 then
          if t[6] = 255 then
            if t[5] = 255 then
              if t[4] >= 192 then
              begin
                work := '';
                for j := 7 downto 0 do
                  work := work + inttohex(workBytes[j], 2);
                loadPows;
                setPrecalculated(Hash, work);
                Self.foundWork := work;
                savePows;

                Exit;

              end;
      end;
      // Move(t[0],ran,8);
      ran := ran * $08088405 + 1;

      Move(ran, workBytes[0], 7);

    end;
  except
    on E: Exception do
    begin
    end;
  end;

end;

function nano_pow(Hash: String): String;
const
  powworkers = 0;
var
  work: String;
  workers: array [0 .. powworkers] of TPowWorker;
  i: integer;
begin
  // Randomize; moved to AccountRelated.InitializeHodler
  if Length(Hash) <> 64 then
    Exit;

  work := findPrecalculated(Hash);
  if (work <> '') and (work <> 'MINING') then
  begin
    Exit(work);
  end;
  if work = 'MINING' then
  begin // We are mining this one already, so let's wait

    while (work = 'MINING') do
    begin

      Sleep(100);
      work := findPrecalculated(Hash);
    end;

    Exit(work);

    // Exit(nano_pow(Hash));

  end;

{$IFDEF  ANDROID}AcquireWakeLock; {$ENDIF}
  setPrecalculated(Hash, 'MINING');

  for i := 0 to powworkers do
  begin
    workers[i] := TPowWorker.Create(True);
{$IFDEF MSWINDOWS} workers[i].Priority := tpHighest; {$ENDIF}
    workers[i].Hash := Hash;
    workers[i].Start;
  end;

  while work = '' do
  begin
    Sleep(100);
    for i := 0 to powworkers do
      if workers[i].foundWork <> '' then
      begin
        work := workers[i].foundWork;

{$IFDEF  ANDROID} ReleaseWakeLock; {$ENDIF}
        setPrecalculated(Hash, work);
        Result := work;
        break;
      end;

  end;
  for i := 0 to powworkers do
    workers[i].Terminate;
end;

function nano_getWork(var Block: TNanoBlock): String;
begin
  Block.work := nano_pow(nano_getPrevious(Block));
  Block.worked := True;

end;

{ TThread.CreateAnonymousThread(
  procedure
  begin
  nano_pow(Hash);
  end).Start(); }

function nano_checkWork(Block: TNanoBlock; work: String;
blockHash: String = ''): Boolean;
var
  t, t2: TBytes;
var
  Blake2b: IHash;
  toHash: String;
begin
  Result := false;
  Blake2b := THashFactory.TCrypto.CreateBlake2B(TBlake2BConfig.Create(8));
  Blake2b.Initialize();
  toHash := '';
  if blockHash = '' then
    blockHash := nano_getPrevious(Block);
  t := hexatotbytes(MAIN_NET_WORK_THRESHOLD);
  toHash := reversehexorder(work); // reserve?
  toHash := toHash + blockHash;
  Blake2b.TransformBytes(hexatotbytes(toHash), 0, Length(toHash) div 2);
  t2 := hexatotbytes(reversehexorder(Blake2b.TransformFinal.ToString()));
  // reserve?
  if t2[0] = t[0] then
    if t2[1] = t[1] then
      if t2[2] = t[2] then
        if t2[3] >= t[3] then
          Result := True;
end;

procedure nano_setWork(var Block: TNanoBlock; hex: String);
begin
  if not nano_checkWork(Block, hex) then
    raise Exception.Create('Work not valid for block');
  Block.work := hex;
  Block.worked := True;
end;

procedure nano_setAccount(var Block: TNanoBlock; acc: String);
begin
  Block.blockAccount := acc;
  if Block.blockType = 'send' then
    Block.origin := acc;
end;

procedure nano_setOrigin(var Block: TNanoBlock; acc: String);
begin
  if (Block.blockType = 'receive') or (Block.blockType = 'open') then
    Block.origin := acc;
end;

procedure nano_setTimestamp(var Block: TNanoBlock; millis: System.UInt64);
begin
  Block.timestamp := millis;
end;

function nano_getOrigin(Block: TNanoBlock): String;
begin
  if (Block.blockType = 'receive') or (Block.blockType = 'open') then
    Exit(Block.origin);
  if (Block.blockType = 'send') then
    Exit(Block.blockAccount);
  Result := '';
end;

function nano_getDestination(Block: TNanoBlock): String;
begin
  if (Block.blockType = 'send') then
    Exit(nano_accountFromHexKey(Block.destination));
  if (Block.blockType = 'receive') or (Block.blockType = 'open') then
    Exit(Block.blockAccount);

end;

function nano_getRepresentative(Block: TNanoBlock): String;
begin
  if (Block.state) or (Block.blockType = 'change') or (Block.blockType = 'open')
  then
    Exit(nano_accountFromHexKey(Block.representative))
  else
    Result := '';

end;

function nano_isReady(Block: TNanoBlock): Boolean;
begin
  Result := Block.signed and Block.worked;
end;

procedure nano_changePrevious(var Block: TNanoBlock; newPrevious: String);
begin
  if Block.blockType = 'open' then
    raise Exception.Create('Open has no previous block');
  if Block.blockType = 'receive' then
  begin
    nano_setReceiveParameters(Block, newPrevious, Block.source);
    nano_getBlockHash(Block);
    Exit;
  end;
  if Block.blockType = 'send' then
  begin
    nano_setSendParameters(Block, newPrevious, Block.destination,
      Block.balance);
    // api.setSendParameters(newPrevious, destination, stringFromHex(balance).replace(RAI_TO_RAW, ''))
    nano_getBlockHash(Block);
    Exit;
  end;
  if Block.blockType = 'change' then
  begin
    nano_setChangeParameters(Block, newPrevious, Block.representative);
    nano_getBlockHash(Block);
    Exit;
  end;
  raise Exception.Create('Invalid block type');
end;

function nano_getJSONBlock(Block: TNanoBlock): String;
var
  obj: TJSONObject;
begin
  if not Block.signed then
    raise Exception.Create('Block not signed');

  obj := TJSONObject.Create();
  if Block.state then
  begin
    obj.AddPair(TJSONPair.Create('type', 'state'));
    if Block.blockType = 'open' then
      obj.AddPair(TJSONPair.Create('previous', STATE_BLOCK_ZERO))
    else
      obj.AddPair(TJSONPair.Create('previous', Block.previous));

    obj.AddPair(TJSONPair.Create('account',
      nano_accountFromHexKey(Block.account)));
    obj.AddPair(TJSONPair.Create('representative',
      nano_accountFromHexKey(Block.representative { + block.account } )));
    obj.AddPair(TJSONPair.Create('balance',
      BigInteger.Parse('+0x0' + Block.balance).ToString(10)));
    if Block.blockType = 'send' then
      obj.AddPair(TJSONPair.Create('link', Block.destination));
    if Block.blockType = 'receive' then
      obj.AddPair(TJSONPair.Create('link', Block.source));
    if Block.blockType = 'open' then
      obj.AddPair(TJSONPair.Create('link', Block.source));
    if Block.blockType = 'change' then
      obj.AddPair(TJSONPair.Create('link', STATE_BLOCK_ZERO));
  end
  else
  begin
    obj.AddPair(TJSONPair.Create('type', Block.blockType));
    if Block.blockType = 'send' then
    begin
      obj.AddPair(TJSONPair.Create('previous', Block.previous));
      obj.AddPair(TJSONPair.Create('destination',
        nano_accountFromHexKey(Block.destination)));
      obj.AddPair(TJSONPair.Create('balance', Block.balance));
    end;
    if Block.blockType = 'receive' then
    begin
      obj.AddPair(TJSONPair.Create('source', Block.source));
      obj.AddPair(TJSONPair.Create('previous', Block.previous));
    end;
    if Block.blockType = 'open' then
    begin
      obj.AddPair(TJSONPair.Create('source', Block.source));
      obj.AddPair(TJSONPair.Create('representative',
        nano_accountFromHexKey(Block.representative { + block.account } )));
      obj.AddPair(TJSONPair.Create('account',
        nano_accountFromHexKey(Block.account)));
    end;
    if Block.blockType = 'change' then
    begin
      obj.AddPair(TJSONPair.Create('previous', Block.previous));
      obj.AddPair(TJSONPair.Create('representative',
        nano_accountFromHexKey(Block.representative)));
    end;
  end;
  obj.AddPair(TJSONPair.Create('work', Block.work));
  obj.AddPair(TJSONPair.Create('signature', Block.signature));
  Result := obj.tojson;
  obj.Free;
end;

function loadNanoBlockCache(Hash: string): string;
var
  ts: TStringList;
  fpath: string;
begin
  Result := '';
  fpath := HOME_PATH + '/NanoBlocks/' + Hash + '.json';
  if fileexists(fpath) then
  begin
    ts := TStringList.Create;
    try
      ts.LoadFromFile(fpath);
      Result := ts.Text;
    finally
      ts.Free;
    end;

  end;

end;

procedure saveNanoBlockCache(Hash, data: string);
var
  ts: TStringList;
  fpath: string;
begin

  fpath := HOME_PATH + 'NanoBlocks/' + Hash + '.json';
  TDirectory.CreateDirectory(HOME_PATH + 'NanoBlocks');

  ts := TStringList.Create;
  try
    ts.Text := data;
    ts.SaveToFile(fpath);

  finally
    ts.Free;
  end;

end;

function nano_obtainBlock(Hash: String): String;
var
  data, cache, err: String;
begin
  data := '{}';
  cache := '';
  try
    if True then
      cache := loadNanoBlockCache(Hash);
    if cache = '' then
    begin

      data := getDataOverHTTP('https://hodlernode.net/nano.php?h=' + Hash);
      Result := data;
      saveNanoBlockCache(Hash, data);
    end
    else
      Result := cache;

  except
    on E: Exception do
    begin
      err := E.Message;
    end;
  end;
end;

function nano_buildFromJSON(JSON, prev: String; hexBalance: Boolean = false)
  : TNanoBlock;
var
  obj, prevObj: TJSONObject;
var
  state: Boolean;
begin
  Result := nano_newBlock(false);
  obj := TJSONObject.ParseJSONValue(TEncoding.ASCII.GetBytes(JSON), 0)
    as TJSONObject;
  if (Length(obj.GetValue('previous').Value) = 64) and (prev = '') then
  begin
    prev := nano_obtainBlock(obj.GetValue('previous').Value);
  end;
  if (prev = '') and (obj.GetValue('previous').Value <> STATE_BLOCK_ZERO) then
    raise Exception.Create('Failed to obtain block');

  prevObj := TJSONObject.ParseJSONValue(TEncoding.ASCII.GetBytes(prev), 0)
    as TJSONObject;
  state := obj.GetValue('type').Value = 'state';

  Result.state := state or false;
  Result.blockType := obj.GetValue('type').Value;
  if Result.state then
  begin

    Result.send := false;
    if prevObj <> nil then
    begin
      if prevObj.GetValue('type').Value <> 'state' then
      begin
        if not hexBalance then
          Result.send := BigInteger.Parse
            ( { '0x0' + } prevObj.GetValue('balance').Value) >
            BigInteger.Parse( { '0x0' + } obj.GetValue('balance').Value)
        else
          Result.send := BigInteger.Parse('0x0' + prevObj.GetValue('balance')
            .Value) > BigInteger.Parse('0x0' + obj.GetValue('balance').Value)
      end
      else
      begin
        if obj.GetValue('subtype') <> nil then
          Result.send := obj.GetValue('subtype').Value = 'send';
      end;
    end;
    Result.previous := obj.GetValue('previous').Value;
    if not hexBalance then
      Result.balance := BigInteger.Parse(obj.GetValue('balance').Value)
        .ToString(10)
    else
      Result.balance := BigInteger.Parse(obj.GetValue('balance').Value)
        .ToString(16);
    Result.account := nano_keyFromAccount(obj.GetValue('account').Value);
    Result.representative := nano_keyFromAccount
      (obj.GetValue('representative').Value);
    if Result.send then
    begin
      Result.blockType := 'send';
      Result.destination := obj.GetValue('link').Value;
      if not hexBalance then
        Result.blockAmount := BigInteger.Parse(prevObj.GetValue('balance')
          .Value) - BigInteger.Parse(obj.GetValue('balance').Value)
      else
        Result.blockAmount :=
          BigInteger.Parse('0x0' + prevObj.GetValue('balance').Value) -
          BigInteger.Parse('0x0' + obj.GetValue('balance').Value)
    end
    else
    begin
      if obj.GetValue('link').Value = STATE_BLOCK_ZERO then
        Result.blockType := 'change'
      else
      begin
        if Result.previous = STATE_BLOCK_ZERO then
        begin
          Result.blockType := 'open';
          Result.source := obj.GetValue('link').Value;
          if not hexBalance then
            Result.blockAmount := BigInteger.Parse(Result.balance)
          else
            Result.blockAmount := BigInteger.Parse('0x0' + Result.balance)
        end
        else
        begin
          Result.blockType := 'receive';
          Result.source := obj.GetValue('link').Value;
          if not hexBalance then
          begin
            if prevObj <> nil then
              Result.blockAmount := BigInteger.Parse(prevObj.GetValue('balance')
                .Value) - BigInteger.Parse(obj.GetValue('balance').Value)
            else
              Result.blockAmount :=
                -BigInteger.Parse(obj.GetValue('balance').Value);
          end
          else
            Result.blockAmount :=
              BigInteger.Parse('0x0' + prevObj.GetValue('balance').Value) -
              BigInteger.Parse('0x0' + obj.GetValue('balance').Value)
        end;
      end;

    end;

  end
  else
  begin
    if Result.blockType = 'send' then
    begin
      Result.previous := obj.GetValue('previous').Value;
      Result.destination := nano_keyFromAccount
        (obj.GetValue('destination').Value);
      Result.balance := obj.GetValue('balance').Value;
      if not hexBalance then
        Result.blockAmount := BigInteger.Parse(prevObj.GetValue('balance')
          .Value) - BigInteger.Parse(obj.GetValue('balance').Value)
      else
        Result.blockAmount :=
          BigInteger.Parse('0x0' + prevObj.GetValue('balance').Value) -
          BigInteger.Parse('0x0' + obj.GetValue('balance').Value)
    end;
    if Result.blockType = 'receive' then
    begin
      Result.previous := obj.GetValue('previous').Value;
      Result.source := obj.GetValue('source').Value;

    end;
    if Result.blockType = 'open' then
    begin
      Result.source := obj.GetValue('source').Value;
      Result.representative := nano_keyFromAccount
        (obj.GetValue('representative').Value);
      Result.account := nano_keyFromAccount(obj.GetValue('account').Value);
    end;
    if Result.blockType = 'change' then
    begin
      Result.previous := obj.GetValue('previous').Value;
      Result.representative := nano_keyFromAccount
        (obj.GetValue('representative').Value)

    end;
  end;
  Result.signature := obj.GetValue('signature').Value;
  Result.work := obj.GetValue('work').Value;
  if Result.work <> '' then
    Result.worked := True;
  if Result.signature <> '' then
    Result.signed := True;
  if not(obj.GetValue('hash') = nil) then
    Result.Hash := obj.GetValue('hash').Value
  else
    Result.Hash := nano_getBlockHash(Result);
end;

function nano_getPriv(wd: NanoCoin; MasterSeed: String): String;
begin

  if (wd.x = -1) and (wd.y = -1) then
  begin
    /// speckDecrypt(TCA(masterSeed), sender.EncryptedPrivKey);
    Result := speckDecrypt(TCA(MasterSeed), wd.EncryptedPrivKey);

  end
  else
  begin

    Result := nano_getPriv(wd.x, wd.y, MasterSeed);

  end;

end;

function nano_getPriv(x, y: System.UInt32; MasterSeed: String): String;
var
  Blake2b: IHash;
  toHash: String;
begin
  Blake2b := THashFactory.TCrypto.CreateBlake2B_256();
  Blake2b.Initialize();
  Blake2b.TransformBytes(hexatotbytes(GetStrHashSHA256(MasterSeed + inttohex(x,
    32) + inttohex(y, 32)) + MasterSeed + inttohex(x, 32) + inttohex(y,
    32)), 0);
  Result := Blake2b.TransformFinal.ToString;
end;

function nano_createHD(x, y: System.UInt32; MasterSeed: String): TwalletInfo;
var
  pub: String;
  p: String;
begin
  p := nano_getPriv(x, y, MasterSeed);
  pub := nano_privToPub(p);
  Result := NanoCoin.Create(8, x, y, nano_accountFromHexKey(pub), '');
  Result.pub := pub;
  wipeString(p);
  wipeString(MasterSeed);
end;

procedure nano_signBlock(var Block: TNanoBlock; cc: cryptoCurrency; ms: String);
var
  blockHash: String;
  pub: String;
  p: String;
begin
  p := nano_getPriv(NanoCoin(cc), ms);
  pub := nano_privToPub(p);
  blockHash := nano_getBlockHash(Block);
  nano_setSignature(Block, nano_signature(blockHash, p, pub));
  nano_setAccount(Block, cc.addr);
  wipeString(p);
end;

procedure nano_signBlock(var Block: TNanoBlock; cc: NanoCoin);
var
  blockHash: String;
  pub: String;
  p: String;
begin
  p := cc.getPrivFromSession();
  pub := nano_privToPub(p);
  blockHash := nano_getBlockHash(Block);
  nano_setSignature(Block, nano_signature(blockHash, p, pub));
  nano_setAccount(Block, cc.addr);
  wipeString(p);
end;

function nano_addPendingReceiveBlock(sourceBlockHash: String;
cc: cryptoCurrency; from: String; ms: String; amount: BigInteger;
doWork: Boolean = false): TNanoBlock;
begin
  Result := nano_newBlock(True);
  if (Length(cc.lastPendingBlock) = 64) and (Length(cc.History) > 0) then
    nano_setReceiveParameters(Result, NanoCoin(cc).getPreviousHash,
      sourceBlockHash)
  else
    nano_setOpenParameters(Result, sourceBlockHash, cc.addr,
      nano_getWalletRepresentative);
  nano_setStateParameters(Result, cc.addr, nano_getWalletRepresentative,
    BigInteger(NanoCoin(cc).lastBlockAmount + amount).ToString(16));
  Result.Hash := nano_getBlockHash(Result);
  cc.lastBlock := Result.Hash;
  NanoCoin(cc).lastBlockAmount := NanoCoin(cc).lastBlockAmount + amount;
  nano_signBlock(Result, cc, ms);
  nano_setAccount(Result, cc.addr);
  saveBlockToJSON(Result);
  NanoCoin(cc).loadChain;
  if doWork then
  begin

    nano_getWork(Result);
    Result.worked := True;
    nano_checkWork(Result, Result.work, Result.Hash);
  end;

  // cc.confirmed := cc.confirmed + amount;
  // cc.unconfirmed := cc.unconfirmed - amount;
  cc.lastBlock := Result.Hash;
  wipeString(ms);
end;

procedure saveBlockToJSON(Block: TNanoBlock);
var
  ts: TStringList;
  dir: String;
begin

  dir := TPath.Combine(CurrentAccount.DirPath, 'Pendings');
  TDirectory.CreateDirectory(dir);
  ts := TStringList.Create;
  ts.Add(nano_getJSONBlock(Block));
  ts.SaveToFile(TPath.Combine(dir, Block.Hash + '.block.json'));
  ts.Free;

end;

function nano_addPendingReceiveBlock(sourceBlockHash: String; cc: NanoCoin;
from: String; amount: BigInteger; doWork: Boolean = false): TNanoBlock;
var
  ph: String;
begin
  Result := nano_newBlock(True);
  ph := cc.getPreviousHash;
  if (Length(ph) = 64) and (Length(cc.History) > 0) then
    nano_setReceiveParameters(Result, ph, sourceBlockHash)
  else
    nano_setOpenParameters(Result, sourceBlockHash, cc.addr,
      nano_getWalletRepresentative);

  nano_setStateParameters(Result, cc.addr, nano_getWalletRepresentative,
    BigInteger(NanoCoin(cc).lastBlockAmount + amount).ToString(16));
  Result.Hash := nano_getBlockHash(Result);
  cc.lastBlock := Result.Hash;
  NanoCoin(cc).lastBlockAmount := NanoCoin(cc).lastBlockAmount + amount;
  nano_signBlock(Result, cc);
  nano_setAccount(Result, cc.addr);
  saveBlockToJSON(Result);
  NanoCoin(cc).loadChain;
  if doWork then
  begin

    nano_getWork(Result);
    Result.worked := True;
    nano_checkWork(Result, Result.work, Result.Hash);
  end;

  // cc.confirmed := cc.confirmed + amount;
  // cc.unconfirmed := cc.unconfirmed - amount;

  // cc.lastPendingBlock := result.Hash;
end;

procedure nano_test();
var
  Blake2b: IHash;
  i, j: System.Uint8;
  workBytes, t: Tarray<Byte>;
var
  work: String;
  ran, thres: System.UInt64;
  counter: Int64;
var
  &random: ISecureRandom;
begin

  try

    Blake2b := THashFactory.TCrypto.CreateBlake2B(TBlake2BConfig.Create(8));
    Blake2b.Initialize();

    thres := $FFFFFFC000000000;
    workBytes := hexatotbytes('00');

    Blake2b.TransformBytes(workBytes);
    t := Blake2b.TransformFinal.GetBytes;

  except
    on E: Exception do
    begin
    end;
  end;

end;

function nano_pushBlock(b: String): String;
begin
  Result := getDataOverHTTP('https://hodlernode.net/nano.php?b=' + b,
    false, True);
end;

procedure nano_minePendings(cc: cryptoCurrency; data: String; pw: String);
var
  js: TJSONObject;
  newblock: string;
  testblock: TNanoBlock;
  pendings: TJSONArray;
  ts: TStringList;
  i: integer;
  err: string;
  MasterSeed, tced: String;
begin
  try

    js := TJSONObject.ParseJSONValue(data) as TJSONObject;

    cc.confirmed := BigInteger.Parse(js.GetValue('balance')
      .GetValue<string>('balance'));
    cc.unconfirmed := BigInteger.Parse(js.GetValue('balance')
      .GetValue<string>('pending'));
    pendings := js.GetValue<TJSONArray>('pending') as TJSONArray;
    with frmhome do
      tced := TCA(pw);
    // CoinPrivKeyDescriptionEdit NewCoinDescriptionPassEdit.Text := '';
    MasterSeed := speckDecrypt(tced, CurrentAccount.EncryptedMasterSeed);
    if not IsHex(MasterSeed) then
    begin

      TThread.Synchronize(nil,
        procedure
        begin
          popupWindow.Create(dictionary('FailedToDecrypt'));
        end);

      Exit;
    end;
    startFullfillingKeypool(MasterSeed);
    if pendings.Count > 0 then
      for i := 0 to (pendings.Count div 2) - 1 do
      begin

        testblock := nano_buildFromJSON(pendings.Items[(i * 2)
          ].GetValue<TJSONObject>('data').GetValue('contents').Value, '');
        testblock := nano_addPendingReceiveBlock
          (pendings.Items[(i * 2) + 1].GetValue<string>('hash'), cc,
          testblock.source, MasterSeed, testblock.blockAmount, false);

        TThread.Synchronize(TThread.CurrentThread,
          procedure
          begin
            updateBalanceLabels();
            if frmhome.PageControl.activetab = frmhome.WalletView then
              ReloadWalletView();
          end);
      end;

    newblock := testblock.work;

  except
    on E: Exception do
    begin
      err := E.Message;
      err := err;
    end;

  end;

  wipeString(MasterSeed);
  wipeString(pw);
  js.Free;
end;

procedure nano_DoMine(cc: cryptoCurrency; pw: String);
begin
  TThread.CreateAnonymousThread(
    procedure
    begin

      TThread.Synchronize(nil,
        procedure
        begin
          frmhome.NanoUnlocker.Enabled := false;
          frmhome.NanoUnlocker.Text := 'Mining NANO...';
        end);

      nano_minePendings(cc,
        getDataOverHTTP('https://hodlernode.net/nano.php?addr=' + cc.addr,
        false, True), pw);

      TThread.Synchronize(nil,
        procedure
        begin
          frmhome.NanoUnlocker.Enabled := True;
          wipeString(pw);
        end);

    end).Start();

end;

function nano_send(var from: TwalletInfo; sendto: String; amount: BigInteger;
MasterSeed: String): String;
var
  Block: TNanoBlock;
  pub: String;
  p: String;
  ts: TStringList;
  pb: TpendingNanoBlock;
begin

  p := nano_getPriv(NanoCoin(from), MasterSeed);

  pub := nano_privToPub(p);
  Block := nano_newBlock(True);
  nano_setSendParameters(Block, NanoCoin(from).getPreviousHash, sendto,
    BigInteger(NanoCoin(from).lastBlockAmount - amount).ToString(16));
  nano_setStateParameters(Block, from.addr, nano_getWalletRepresentative,
    BigInteger(NanoCoin(from).lastBlockAmount - amount).ToString(16));
  NanoCoin(from).lastBlock := nano_getBlockHash(Block);
  nano_setSignature(Block, nano_signature(nano_getBlockHash(Block), p, pub));
  from.lastBlock := Block.Hash;
  pb.Block := Block;
  pb.Hash := Block.Hash;
  NanoCoin(from).lastBlockAmount := NanoCoin(from).lastBlockAmount - amount;
  // NanoCoin(from).confirmed:=NanoCoin(from).lastBlockAmount;
  saveBlockToJSON(Block);
  NanoCoin(from).loadChain;
  if NanoCoin(from).isUnlocked then
    NanoCoin(from).tryAddPendingBlock(pb)
  else
    NanoCoin(from).mineBlock(pb, MasterSeed);
  // SetLength(NanoCoin(from).pendingSendBlocks,
  // Length(NanoCoin(from).pendingSendBlocks) + 1);
  // NanoCoin(from).pendingSendBlocks[High(NanoCoin(from).pendingSendBlocks)
  // ] := Block;
  // NanoCoin(from).saveSendBlocks;
  // nano_getWork(Block);
  // from.confirmed := from.confirmed - amount;
  // result := nano_pushBlock(nano_getJSONBlock(Block));
  // NanoCoin(from).removePendingBlock(block.previous);
  wipeString(MasterSeed);
  wipeString(p);
end;

function isInPows(Hash: String): Boolean;
var
  pow: precalculatedPow;
begin
  loadPows;
  Result := false;
  Hash := LowerCase(Hash);
  for pow in pows do
    if pow.Hash = Hash then
      Exit(True);
end;

function findPrecalculated(Hash: String): String;
var
  pow: precalculatedPow;
begin
  loadPows;
  Result := '';
  Hash := LowerCase(Hash);
  for pow in pows do
    if pow.Hash = Hash then
      Exit(pow.work);
end;

procedure removePow(Hash: String);
var
  i: integer;
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
  i: integer;
  path: AnsiString;
begin
  path := IncludeTrailingPathDelimiter
    ({$IF DEFINED(LINUX)}System.IOUtils.TPath.GetHomePath +
    '/.hodlertech/'{$ELSE}System.IOUtils.TPath.Combine
    (System.SysUtils.GetEnvironmentVariable('APPDATA'), 'hodlertech'){$ENDIF});
{$IFDEF ANDROID}
  path := TPath.GetDocumentsPath + '/nanopows.dat';
{$ENDIF}
  ts := TStringList.Create;
  try
    for i := 0 to Length(pows) - 1 do
    begin
      if Length(pows[i].Hash) <> 64 then
        Continue;

      ts.Add(pows[i].Hash + ' ' + pows[i].work);
    end;
    ts.SaveToFile(TPath.Combine(path, 'nanopows.dat'));
  except
    on E: Exception do
    begin

    end;

  end;
  ts.Free;
end;

procedure setPrecalculated(Hash, work: String);
var
  i: integer;
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
  savePows;
end;

procedure loadPows;
var
  ts: TStringList;
  i: integer;
  t: TStringList;
begin
  SetLength(pows, 0);
  HOME_PATH := IncludeTrailingPathDelimiter
    ({$IF DEFINED(LINUX)}System.IOUtils.TPath.GetHomePath +
    '/.hodlertech/'{$ELSE}System.IOUtils.TPath.Combine
    (System.SysUtils.GetEnvironmentVariable('APPDATA'), 'hodlertech'){$ENDIF});
{$IFDEF ANDROID}
  HOME_PATH := TPath.GetDocumentsPath + '/nanopows.dat';
{$ENDIF}
  ts := TStringList.Create;
  try
    if fileexists(TPath.Combine(HOME_PATH, 'nanopows.dat')) then
    begin
      ts.LoadFromFile(TPath.Combine(HOME_PATH, 'nanopows.dat'));
      SetLength(pows, ts.Count);
      for i := 0 to ts.Count - 1 do
      begin
        t := SplitString(ts.Strings[i], ' ');
        if t.Count = 1 then
        begin
          pows[i].Hash := t[0];
          pows[i].work := '';
          Continue;
        end;

        if t.Count <> 2 then
          Continue;

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

procedure NanoCoin.mineBlock(Block: TpendingNanoBlock; MasterSeed: String);
var
  temp: TNanoBlock;
begin
  mutexMining.acquire;
  if Block.Block.blockType <> 'send' then
  begin

    temp := nano_addPendingReceiveBlock(Block.Hash, Self, Block.Block.source,
      MasterSeed, Block.Block.blockAmount, false);
  end
  else
  begin
    temp := Block.Block;

  end;

  wipeString(MasterSeed);

  mutexMining.release;
end;

procedure NanoCoin.mineBlock(Block: TpendingNanoBlock);
var
  temp: TNanoBlock;
begin
  if isUnlocked = false then
    raise Exception.Create('nano must be unlocked first');

  mutexMining.acquire;
  if Block.Block.blockType <> 'send' then
  begin
    temp := nano_addPendingReceiveBlock(Block.Hash, Self, Block.Block.source,
      Block.Block.blockAmount, false);
  end
  else
  begin
    temp := Block.Block;

  end;
  mutexMining.release;
end;

procedure nano_mineBuilt(cc: NanoCoin);
var
  Block: TNanoBlock;
begin
  repeat
    Block := cc.firstBlock;
    nano_getWork(Block);
    nano_pushBlock(nano_builtToJSON(Block));

    cc.removeBlock(Block.Hash);
  until Length(cc.pendingChain) = 0;
end;

procedure nano_precalculate(Hash: String);
begin
  if not isInPows(Hash) then
  begin
    setPrecalculated(Hash, 'MINING');

  end;
end;

initialization

loadPows;

finalization

savePows;

end.
