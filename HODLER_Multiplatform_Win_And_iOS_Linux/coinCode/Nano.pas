// Nanocurrency unit, Copyleft 2019 FL4RE - Daniel Mazur
unit Nano;

interface

uses
  {$IFDEF ANDROID} Androidapi.JNI,AESObj,{$ENDIF} SPECKObj, FMX.Objects, IdHash, IdHashSHA, IdSSLOpenSSL, languages,
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
  ClpISecureRandom, ClpCryptoApiRandomGenerator, ClpICryptoApiRandomGenerator,
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

type
  TNanoBlock = record
    blockType: AnsiString;
    state: Boolean;
    send: Boolean;
    Hash: AnsiString;
    signed: Boolean;
    worked: Boolean;
    signature: AnsiString;
    work: AnsiString;
    blockAmount: BigInteger;
    blockAccount: AnsiString;
    blockMessage: AnsiString;
    origin: AnsiString;
    immutable: Boolean;
    timestamp: System.UInt32;
    previous: AnsiString;
    destination: AnsiString;
    balance: AnsiString;
    source: AnsiString;
    representative: AnsiString;
    account: AnsiString;
  end;

type
  TpendingNanoBlock = record


    Block: TNanoBlock;
    Hash: AnsiString;

  end;

type
  NanoCoin = class(TwalletInfo)
    chain: array of TNanoBlock;
    pendingSendBlocks: array of TNanoBlock;
    PendingBlocks: TQueue<TpendingNanoBlock>;
    PendingThread: TThread;
    mutexMining: TSemaphore;
    lastBlockAmount: BigInteger;
    UnlockPriv: AnsiString;
    isUnlocked: Boolean;
    sessionKey: AnsiString;
  private

    function getPreviousHash: AnsiString;
    procedure removePendingBlock(prev: AnsiString);
    procedure addToChain(block: TNanoBlock);
    function inChain(hash: AnsiString): Boolean;
    function isFork(prev: AnsiString): Boolean;
    function findUnusedPrevious: AnsiString;
    function BlockByPrev(prev: ansistring): TNanoBlock;
    function BlockByHash(hash: ansistring): TNanoBlock;
    function nextBlock(block:TNanoBlock):TNanoBlock;
    function prevBlock(block: TNanoBlock): TNanoBlock;
  public
    procedure mineAllPendings(MasterSeed: AnsiString = '');
    procedure loadSendBlocks;
    procedure saveSendBlocks;
    procedure unlock(MasterSeed: AnsiString);
    function getPrivFromSession(): AnsiString;

    procedure mineBlock(Block: TpendingNanoBlock;
      MasterSeed: AnsiString); overload;
    procedure mineBlock(Block: TpendingNanoBlock); overload;

    procedure tryAddPendingBlock(Block: TpendingNanoBlock);

    constructor Create(id: integer; _x: integer; _y: integer; _addr: AnsiString;
      _description: AnsiString; crTime: integer = -1); overload;


    destructor destroy();
    // ConfirmThread : TAutoReceive;

    // procedure runAutoConfirm();

  end;

function nano_pow(Hash: AnsiString): AnsiString;

procedure removePow(Hash: AnsiString);

procedure setPrecalculated(Hash, work: AnsiString);

function findPrecalculated(Hash: AnsiString): AnsiString;

procedure nano_test(cc: cryptoCurrency; data: AnsiString);

procedure nano_precalculate(Hash: AnsiString);

function nano_accountFromHexKey(adr: AnsiString): AnsiString;

function nano_getPriv(x, y: System.UInt32; MasterSeed: AnsiString): AnsiString; overload;
function nano_getPriv(wd : NanoCoin; MasterSeed: AnsiString): AnsiString; overload;

function nano_keyFromAccount(adr: AnsiString): AnsiString;

function nano_createHD(x, y: System.UInt32; MasterSeed: AnsiString)
  : TwalletInfo;

function nano_obtainBlock(Hash: AnsiString): AnsiString;


function nano_addPendingReceiveBlock(sourceBlockHash: AnsiString;
  cc: cryptoCurrency; from: AnsiString; ms: AnsiString; amount: BigInteger)
  : TNanoBlock; overload;
function nano_addPendingReceiveBlock(sourceBlockHash: AnsiString; cc: NanoCoin;
  from: AnsiString; amount: BigInteger): TNanoBlock; overload;

function nano_buildFromJSON(JSON, prev: AnsiString; hexBalance: Boolean = false)
  : TNanoBlock;

function nano_getJSONBlock(Block: TNanoBlock): AnsiString;

function nano_checkWork(Block: TNanoBlock; work: AnsiString;
  blockHash: AnsiString = ''): Boolean;

function nano_getBlockHash(var Block: TNanoBlock): AnsiString;

procedure nano_DoMine(cc: cryptoCurrency; pw: AnsiString);

function nano_send(var from: TwalletInfo; sendto: AnsiString;
  amount: BigInteger; MasterSeed: AnsiString): AnsiString;

function nano_pushBlock(b: AnsiString): AnsiString;

procedure nano_signBlock(var Block: TNanoBlock; cc: NanoCoin); overload;
procedure nano_signBlock(var Block: TNanoBlock; cc: cryptoCurrency;
  ms: AnsiString); overload;

{$IFDEF ANDROID}
function AcquireWakeLock: Boolean;
procedure ReleaseWakeLock;
{$ENDIF}

{$IFDEF ANDROID}



{$ENDIF}


implementation

uses
  ED25519_Blake2b, uHome, PopupWindowData, keypoolrelated, walletviewrelated
{$IFDEF ANDROID},
  FMX.Helpers.Android
{$ENDIF};

/// ///////////////////////////////////////////////////////////////////
{$IFDEF ANDROID}
function GetPowerManager: JPowerManager;
var
  PowerServiceNative: JObject;
begin
  PowerServiceNative := TAndroidHelper.Context.getSystemService(TJContext.JavaClass.POWER_SERVICE);
  if not Assigned(PowerServiceNative) then
    raise Exception.Create('Could not locate Power Service');
  Result := TJPowerManager.Wrap((PowerServiceNative as ILocalObject).GetObjectID);
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
    WakeLock := PowerManager.newWakeLock(TJPowerManager.JavaClass.SCREEN_BRIGHT_WAKE_LOCK,
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


constructor NanoCoin.Create(id: integer; _x: integer; _y: integer;
  _addr: AnsiString; _description: AnsiString; crTime: integer = -1);
begin

  inherited Create(id, _x, _y, _addr, _description, crTime);

  PendingBlocks := TQueue<TpendingNanoBlock>.Create();
  mutexMining := TSemaphore.Create();
  isUnlocked := false;
  loadSendBlocks;

end;

destructor NanoCoin.destroy;
begin

  inherited;
  wipeAnsiString(UnlockPriv);

  PendingBlocks.Free;
  mutexMining.Free;

end;
function NanoCoin.inChain(hash:AnsiString):Boolean;
var i:integer;
begin
result:=False;
for i := 0 to Length(chain)-1 do
if Self.chain[i].Hash=hash then Exit(True);

end;
function NanoCoin.isFork(prev:AnsiString):Boolean;
var i:integer;
begin
result:=False;
for i := 0 to Length(chain)-1 do
if chain[i].previous=prev then Exit(True);

end;
procedure NanoCoin.addToChain(block:TNanoBlock);
begin
if (not inChain(block.hash)) and (not isFork(block.previous)) then begin
SetLength(chain,Length(chain)+1);
chain[high(chain)]:=block;
end;
end;
function NanoCoin.findUnusedPrevious:AnsiString;
var i:integer;
begin
result:='0000000000000000000000000000000000000000000000000000000000000000';
for i := 0 to Length(chain)-1 do
if not isFork(chain[i].hash) then Exit(chain[i].hash);
end;
function NanoCoin.BlockByPrev(prev:ansistring):TNanoBlock;
var i:integer;
begin
for i := 0 to Length(chain)-1 do
if chain[i].previous=prev then Exit(chain[i]);
end;
function NanoCoin.BlockByHash(hash:ansistring):TNanoBlock;
var i:integer;
begin
for i := 0 to Length(chain)-1 do
if chain[i].hash=hash then Exit(chain[i]);
end;
function NanoCoin.nextBlock(block:TNanoBlock):TNanoBlock;
begin
result:=BlockByPrev(block.Hash);
end;
function NanoCoin.prevBlock(block:TNanoBlock):TNanoBlock;
begin
 result:=blockByHash(block.previous);
end;

function nano_sendFromJSON(JSON: TJSONValue): TNanoBlock;
begin
  result.blockType := JSON.GetValue<string>('type');
  result.previous := JSON.GetValue<string>('previous');
  result.account := JSON.GetValue<string>('account');
  result.representative := JSON.GetValue<string>('representative');
  result.balance := JSON.GetValue<string>('balance');
  result.destination := JSON.GetValue<string>('link');
  result.work := '';
  result.signature := JSON.GetValue<string>('signature');
end;

function nano_sendToJSON(Block: TNanoBlock): string;
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
  result := obj.tojson;
  obj.Free;
end;

procedure NanoCoin.saveSendBlocks;
var
  js: TJSONArray;
  Block: TNanoBlock;
  ts: TStringList;
begin
Exit;
  js := TJSONArray.Create;
  for Block in self.pendingSendBlocks do
    if Block.work = '' then
    begin
      try
        js.AddElement(TJSONObject.ParseJSONValue(nano_sendToJSON(Block))
          as TJSONValue);
      except
      end;
    end;

  ts := TStringList.Create;
  ts.Add(js.tojson);
  ts.SaveToFile(TPath.Combine(CurrentAccount.DirPath,
    self.addr + '.send.json'));
  ts.Free;
  js.Free;
end;

procedure NanoCoin.removePendingBlock(prev: AnsiString);
var
  i: integer;
begin
  for i := 0 to Length(self.pendingSendBlocks) - 1 do
    if self.pendingSendBlocks[i].previous = prev then
    begin
      self.pendingSendBlocks[i] := self.pendingSendBlocks
        [High(self.pendingSendBlocks)];
      SetLength(self.pendingSendBlocks, Length(self.pendingSendBlocks) - 1);
      break;
    end;

end;

function NanoCoin.getPrivFromSession;
var
  i: integer;
begin
  if isUnlocked = false then
    raise Exception.Create('nano must be unlocked first');

  SetLength(result, Length(UnlockPriv));
  for i := low(UnlockPriv) to High(UnlockPriv) do
  begin
    result[i] := AnsiChar(ord(sessionKey[i]) xor ord(UnlockPriv[i]));
  end;

end;

procedure NanoCoin.unlock(MasterSeed: AnsiString);
var
  i: integer;
begin

  UnlockPriv := nano_getPriv(x, y, MasterSeed);
  SetLength(sessionKey, Length(UnlockPriv));
  for i := low(UnlockPriv) to High(UnlockPriv) do
  begin
    sessionKey[i] := AnsiChar(random(255));
  end;

  for i := low(UnlockPriv) to High(UnlockPriv) do
  begin
    UnlockPriv[i] := AnsiChar(ord(sessionKey[i]) xor ord(UnlockPriv[i]));
  end;

  isUnlocked := true;

  mineAllPendings();

end;

procedure NanoCoin.mineAllPendings(MasterSeed: AnsiString = '');
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

  wipeAnsiString(MasterSeed);
end;

function NanoCoin.getPreviousHash(): AnsiString;
var
  i, l: integer;
begin
  result := self.lastPendingBlock;
  if self.lastBlock <> '' then
  begin
    result := self.lastBlock;
    self.lastBlock := '';
    exit;
  end;
  l := Length(self.PendingBlocks.ToArray);
  if l > 0 then
  begin
    for i := 0 to l - 1 do
    begin
      result := self.PendingBlocks.ToArray[i].Hash;

    end;

  end;

end;

procedure NanoCoin.tryAddPendingBlock(Block: TpendingNanoBlock);
var
  it: TQueue<TpendingNanoBlock>.TEnumerator;
begin

  it := PendingBlocks.GetEnumerator;

  while it.MoveNext do
  begin
    if it.Current.Hash = Block.Hash then
    begin
      exit;
    end;

  end;

  PendingBlocks.Enqueue(Block);

  if isUnlocked then
    mineAllPendings();

end;





/// ///////////////////////////////////////////////////////////////////


type
  precalculatedPow = record
    Hash: AnsiString;
    work: AnsiString;
  end;

type
  precalculatedPows = array of precalculatedPow;

  TPowWorker = class(TThread)
  public
    foundWork: AnsiString;
    Hash: AnsiString;
    Blake2b: IHash;
  protected
    procedure execute; override;
  end;

const
  nano_charset = '13456789abcdefghijkmnopqrstuwxyz';

var
  pows: precalculatedPows;

function nano_getWalletRepresentative: AnsiString;
begin
  result := 'xrb_1nanode8ngaakzbck8smq6ru9bethqwyehomf79sae1k7xd47dkidjqzffeg';
end;

function nano_keyFromAccount(adr: AnsiString): AnsiString;
var
  chk: AnsiString;
  rAdr, rChk: TIntegerArray;
  i: integer;
begin
  result := adr;
  adr := stringreplace(adr, 'xrb_', '', [rfReplaceAll]);
  adr := stringreplace(adr, 'nano_', '', [rfReplaceAll]);
  chk := Copy(adr, 52 + 1, 100);
  adr := '1111' + Copy(adr, 1, 52);
  SetLength(rAdr, Length(adr));
  SetLength(rChk, Length(chk));
  for i := 0 to Length(adr) - 1 do
    rAdr[i] := Pos(adr[i{$IFDEF MSWINDOWS} + 1{$ENDIF}], nano_charset) - 1;

  for i := 0 to Length(chk) - 1 do
    rChk[i] := Pos(chk[i{$IFDEF MSWINDOWS} + 1{$ENDIF}], nano_charset) - 1;
  result := '';
  rAdr := ChangeBits(rAdr, 5, 8, true);
  for i := 3 to Length(rAdr) - 1 do
    result := result + inttohex(rAdr[i], 2)
end;

function nano_encodeBase32(values: TIntegerArray): string;
var
  i: integer;
begin
  result := '';
  for i := 0 to Length(values) - 1 do
  begin
    result := result + nano_charset[values[i] + low(nano_charset)];
  end;
end;

function nano_addressChecksum(m: AnsiString): AnsiString;
var
  Blake2b: IHash;
begin
  Blake2b := THashFactory.TCrypto.CreateBlake2B(TBlake2BConfig.Create(5));
  Blake2b.Initialize();
  Blake2b.TransformBytes(hexatotbytes(m), 0, Length(m) div 2);
  result := Blake2b.TransformFinal.ToString();
  result := reversehexorder(result);
end;

function nano_accountFromHexKey(adr: AnsiString): AnsiString;
var
  data, chk: TIntegerArray;
begin
  result := 'FAILED';
  chk := hexatotintegerarray(nano_addressChecksum(adr));
  adr := '303030' + adr;
  data := hexatotintegerarray(adr);
  // Copy(adr,4{$IFDEF MSWINDOWS}+1{$ENDIF},100)

  data := ChangeBits(data, 8, 5, true);
  chk := ChangeBits(chk, 8, 5, true);
  Delete(data, 0, 4);
  result := 'xrb_' + nano_encodeBase32(data) + nano_encodeBase32(chk);
end;

function nano_newBlock(state: Boolean = false): TNanoBlock;
begin
  result.state := state;
  result.signed := false;
  result.worked := false;
  result.signature := '';
  result.work := '';
  result.blockAmount := 0;
  result.immutable := false;
end;

function nano_getPrevious(Block: TNanoBlock): AnsiString;
begin
  if Block.blockType = 'open' then
    exit(Block.account);
  result := Block.previous;
end;

function nano_getBlockHash(var Block: TNanoBlock): AnsiString;
var
  Blake2b: IHash;
  toHash: AnsiString;
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
  result := Blake2b.TransformFinal.ToString();
  Block.Hash := result;
end;

procedure nano_setSendParameters(var Block: TNanoBlock;
previousBlockHash, destinationAccount, balanceRemaining: AnsiString);
var
  accKey: AnsiString;
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
previousBlockHash, sourceBlockHash: AnsiString);
begin
  if (not IsHex(previousBlockHash)) then
    raise Exception.Create('Invalid previous block hash');
  if (not IsHex(sourceBlockHash)) then
    raise Exception.Create('Invalid source block hash');

  Block.previous := previousBlockHash;
  Block.source := sourceBlockHash;
  Block.blockType := 'receive';

end;

procedure nano_setStateParameters(var Block: TNanoBlock;
newAccount, representativeAccount, curBalance: AnsiString);
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
sourceBlockHash, newAccount, representativeAccount: AnsiString);
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
previousBlockHash, representativeAccount: AnsiString);
begin
  if not IsHex(previousBlockHash) then
    raise Exception.Create('Invalid previous block hash');
  Block.representative := nano_keyFromAccount(representativeAccount);
  Block.previous := previousBlockHash;
  Block.blockType := 'change';

end;

procedure nano_setSignature(var Block: TNanoBlock; hex: AnsiString);
begin
  Block.signature := hex;
  Block.signed := true;
end;

procedure TPowWorker.execute;
var
  i, j: System.Uint8;
  workBytes, t: TArray<Byte>;
var
  work: AnsiString;
  ran, thres: System.UInt64;
  counter: Int64;
var
  &random: ISecureRandom;
begin

  try
    self.foundWork := '';
    counter := 0;
    Blake2b := THashFactory.TCrypto.CreateBlake2B(TBlake2BConfig.Create(8));
    Blake2b.Initialize();

    thres := $FFFFFFC000000000;
    workBytes := hexatotbytes('0000000000000000' + Hash);
    random := TSecureRandom.GetInstance('SHA256PRNG');
    ran := random.NextInt64;
    Move(ran, workBytes[0], 8);

	
    while true do
    begin

      // if counter mod 1000000 = 0 then
      // Sleep(50); //no luck, let's cool down CPU :)

      for i := 0 to 255 do
      begin
        workBytes[7] := i;


        if Terminated then
          exit();
   

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

                self.foundWork := work;
                exit;
              end;
      end;
      // Move(t[0],ran,8);
      ran := ran * $08088405 + 1;

      Move(ran, workBytes[0], 7);

    end;
  except
    on E: Exception do
      TThread.Synchronize(nil,
        procedure
        begin
          showmessage(E.Message);
        end);
  end;
  
end;

function nano_pow(Hash: AnsiString): AnsiString;
const
  powworkers = 0;
var
  work: AnsiString;
  workers: array [0 .. powworkers] of TPowWorker;
  i: integer;
begin
  // Randomize; moved to AccountRelated.InitializeHodler
  if Length(Hash) <> 64 then
    exit;

  work := findPrecalculated(Hash);
  if (work <> '') and (work <> 'MINING') then
  begin
    exit(work);
  end;
  if work = 'MINING' then
  begin // We are mining this one already, so let's wait

    while (work = 'MINING') do
    begin

      Sleep(100);
      work := findPrecalculated(Hash);
    end;

	
    exit(work);
    // Exit(nano_pow(Hash));
	
  end;

  {$IFDEF ANDROID}

    AcquireWakeLock;

{$ENDIF}

  setPrecalculated(Hash, 'MINING');

  for i := 0 to powworkers do
  begin
    workers[i] := TPowWorker.Create(true);
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

        {$IFDEF ANDROID}

            ReleaseWakeLock;

{$ENDIF}



        setPrecalculated(Hash, work);
        result := work;
        break;
      end;

  end;
  for i := 0 to powworkers do
    workers[i].Terminate;
end;

function nano_getWork(var Block: TNanoBlock): AnsiString;
begin
  Block.work := nano_pow(nano_getPrevious(Block));
  Block.worked := true;

end;

procedure nano_precalculate(Hash: AnsiString);
begin
  TThread.CreateAnonymousThread(
    procedure
    begin
      nano_pow(Hash);
    end).Start();
end;

function nano_checkWork(Block: TNanoBlock; work: AnsiString;
blockHash: AnsiString = ''): Boolean;
var
  t, t2: TBytes;
var
  Blake2b: IHash;
  toHash: AnsiString;
begin
  result := false;
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
          result := true;
end;

procedure nano_setWork(var Block: TNanoBlock; hex: AnsiString);
begin
  if not nano_checkWork(Block, hex) then
    raise Exception.Create('Work not valid for block');
  Block.work := hex;
  Block.worked := true;
end;

procedure nano_setAccount(var Block: TNanoBlock; acc: AnsiString);
begin
  Block.blockAccount := acc;
  if Block.blockType = 'send' then
    Block.origin := acc;
end;

procedure nano_setOrigin(var Block: TNanoBlock; acc: AnsiString);
begin
  if (Block.blockType = 'receive') or (Block.blockType = 'open') then
    Block.origin := acc;
end;

procedure nano_setTimestamp(var Block: TNanoBlock; millis: System.UInt64);
begin
  Block.timestamp := millis;
end;

function nano_getOrigin(Block: TNanoBlock): AnsiString;
begin
  if (Block.blockType = 'receive') or (Block.blockType = 'open') then
    exit(Block.origin);
  if (Block.blockType = 'send') then
    exit(Block.blockAccount);
  result := '';
end;

function nano_getDestination(Block: TNanoBlock): AnsiString;
begin
  if (Block.blockType = 'send') then
    exit(nano_accountFromHexKey(Block.destination));
  if (Block.blockType = 'receive') or (Block.blockType = 'open') then
    exit(Block.blockAccount);

end;

function nano_getRepresentative(Block: TNanoBlock): AnsiString;
begin
  if (Block.state) or (Block.blockType = 'change') or (Block.blockType = 'open')
  then
    exit(nano_accountFromHexKey(Block.representative))
  else
    result := '';

end;

function nano_isReady(Block: TNanoBlock): Boolean;
begin
  result := Block.signed and Block.worked;
end;

procedure nano_changePrevious(var Block: TNanoBlock; newPrevious: AnsiString);
begin
  if Block.blockType = 'open' then
    raise Exception.Create('Open has no previous block');
  if Block.blockType = 'receive' then
  begin
    nano_setReceiveParameters(Block, newPrevious, Block.source);
    nano_getBlockHash(Block);
    exit;
  end;
  if Block.blockType = 'send' then
  begin
    nano_setSendParameters(Block, newPrevious, Block.destination,
      Block.balance);
    // api.setSendParameters(newPrevious, destination, stringFromHex(balance).replace(RAI_TO_RAW, ''))
    nano_getBlockHash(Block);
    exit;
  end;
  if Block.blockType = 'change' then
  begin
    nano_setChangeParameters(Block, newPrevious, Block.representative);
    nano_getBlockHash(Block);
    exit;
  end;
  raise Exception.Create('Invalid block type');
end;

function nano_getJSONBlock(Block: TNanoBlock): AnsiString;
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
  result := obj.tojson;
  obj.Free;
end;

function nano_obtainBlock(Hash: AnsiString): AnsiString;
var
  data, err: AnsiString;
begin
  data := '{}';
  try
    data := getDataOverHTTP('https://hodlernode.net/nano.php?h=' + Hash);
    result := data;

  except
    on E: Exception do
    begin
      err := E.Message;
    end;
  end;
end;

function nano_buildFromJSON(JSON, prev: AnsiString; hexBalance: Boolean = false)
  : TNanoBlock;
var
  obj, prevObj: TJSONObject;
var
  state: Boolean;
begin
  result := nano_newBlock(false);
  obj := TJSONObject.ParseJSONValue(TEncoding.ASCII.GetBytes(JSON), 0)
    as TJSONObject;
  if (Length(obj.GetValue('previous').Value) = 64) and (prev = '') then
  begin
    prev := nano_obtainBlock(obj.GetValue('previous').Value);
  end;

  prevObj := TJSONObject.ParseJSONValue(TEncoding.ASCII.GetBytes(prev), 0)
    as TJSONObject;
  state := obj.GetValue('type').Value = 'state';

  result.state := state or false;
  result.blockType := obj.GetValue('type').Value;
  if result.state then
  begin

    result.send := false;
    if prevObj <> nil then
    begin
      if prevObj.GetValue('type').Value <> 'state' then
      begin
        if not hexBalance then
          result.send := BigInteger.Parse
            ( { '0x0' + } prevObj.GetValue('balance').Value) >
            BigInteger.Parse( { '0x0' + } obj.GetValue('balance').Value)
        else
          result.send := BigInteger.Parse('0x0' + prevObj.GetValue('balance')
            .Value) > BigInteger.Parse('0x0' + obj.GetValue('balance').Value)
      end
      else
      begin
        if obj.GetValue('subtype') <> nil then
          result.send := obj.GetValue('subtype').Value = 'send';
      end;
    end;
    result.previous := obj.GetValue('previous').Value;
    if not hexBalance then
      result.balance := BigInteger.Parse(obj.GetValue('balance').Value)
        .ToString(10)
    else
      result.balance := BigInteger.Parse(obj.GetValue('balance').Value)
        .ToString(16);
    result.account := nano_keyFromAccount(obj.GetValue('account').Value);
    result.representative := nano_keyFromAccount
      (obj.GetValue('representative').Value);
    if result.send then
    begin
      result.blockType := 'send';
      result.destination := obj.GetValue('link').Value;
      if not hexBalance then
        result.blockAmount := BigInteger.Parse(prevObj.GetValue('balance')
          .Value) - BigInteger.Parse(obj.GetValue('balance').Value)
      else
        result.blockAmount :=
          BigInteger.Parse('0x0' + prevObj.GetValue('balance').Value) -
          BigInteger.Parse('0x0' + obj.GetValue('balance').Value)
    end
    else
    begin
      if obj.GetValue('link').Value = STATE_BLOCK_ZERO then
        result.blockType := 'change'
      else
      begin
        if result.previous = STATE_BLOCK_ZERO then
        begin
          result.blockType := 'open';
          result.source := obj.GetValue('link').Value;
          if not hexBalance then
            result.blockAmount := BigInteger.Parse(result.balance)
          else
            result.blockAmount := BigInteger.Parse('0x0' + result.balance)
        end
        else
        begin
          result.blockType := 'receive';
          result.source := obj.GetValue('link').Value;
          if not hexBalance then
            result.blockAmount := BigInteger.Parse(prevObj.GetValue('balance')
              .Value) - BigInteger.Parse(obj.GetValue('balance').Value)
          else
            result.blockAmount :=
              BigInteger.Parse('0x0' + prevObj.GetValue('balance').Value) -
              BigInteger.Parse('0x0' + obj.GetValue('balance').Value)
        end;
      end;

    end;

  end
  else
  begin
    if result.blockType = 'send' then
    begin
      result.previous := obj.GetValue('previous').Value;
      result.destination := nano_keyFromAccount
        (obj.GetValue('destination').Value);
      result.balance := obj.GetValue('balance').Value;
      if not hexBalance then
        result.blockAmount := BigInteger.Parse(prevObj.GetValue('balance')
          .Value) - BigInteger.Parse(obj.GetValue('balance').Value)
      else
        result.blockAmount :=
          BigInteger.Parse('0x0' + prevObj.GetValue('balance').Value) -
          BigInteger.Parse('0x0' + obj.GetValue('balance').Value)
    end;
    if result.blockType = 'receive' then
    begin
      result.previous := obj.GetValue('previous').Value;
      result.source := obj.GetValue('source').Value;

    end;
    if result.blockType = 'open' then
    begin
      result.source := obj.GetValue('source').Value;
      result.representative := nano_keyFromAccount
        (obj.GetValue('representative').Value);
      result.account := nano_keyFromAccount(obj.GetValue('account').Value);
    end;
    if result.blockType = 'change' then
    begin
      result.previous := obj.GetValue('previous').Value;
      result.representative := nano_keyFromAccount
        (obj.GetValue('representative').Value)

    end;
  end;
  result.signature := obj.GetValue('signature').Value;
  result.work := obj.GetValue('work').Value;
  if result.work <> '' then
    result.worked := true;
  if result.signature <> '' then
    result.signed := true;
  if not(obj.GetValue('hash') = nil) then
    result.Hash := obj.GetValue('hash').Value
  else
    result.Hash := nano_getBlockHash(result);
end;

function nano_getPriv(wd : NanoCoin; MasterSeed: AnsiString): AnsiString;
begin

  if (wd.x = -1) and (wd.Y = -1) then
  begin
              ///speckDecrypt(TCA(masterSeed), sender.EncryptedPrivKey);
    result := speckDecrypt(TCA(masterSeed), wd.EncryptedPrivKey );

  end
  else
  begin

    Result := nano_getPriv(wd.x , wd.Y , MasterSeed);

  end;


end;

function nano_getPriv(x, y: System.UInt32; MasterSeed: AnsiString): AnsiString;
var
  Blake2b: IHash;
  toHash: AnsiString;
begin
  Blake2b := THashFactory.TCrypto.CreateBlake2B_256();
  Blake2b.Initialize();
  Blake2b.TransformBytes(hexatotbytes(GetStrHashSHA256(MasterSeed + inttohex(x,
    32) + inttohex(y, 32)) + MasterSeed + inttohex(x, 32) + inttohex(y,
    32)), 0);
  result := Blake2b.TransformFinal.ToString;
end;

function nano_createHD(x, y: System.UInt32; MasterSeed: AnsiString)
  : TwalletInfo;
var
  pub: AnsiString;
  p: AnsiString;
begin
  p := nano_getPriv(x, y, MasterSeed);
  pub := nano_privToPub(p);
  result := NanoCoin.Create(8, x, y, nano_accountFromHexKey(pub), '');
  result.pub := pub;
  wipeAnsiString(p);
  wipeAnsiString(MasterSeed);
end;

procedure nano_signBlock(var Block: TNanoBlock; cc: cryptoCurrency;
ms: AnsiString);
var
  blockHash: AnsiString;
  pub: AnsiString;
  p: AnsiString;
begin
  p := nano_getPriv(nanocoin(cc), ms);
  pub := nano_privToPub(p);
  blockHash := nano_getBlockHash(block);
  nano_setSignature(block, nano_signature(blockHash, p, pub));
  nano_setAccount(block, cc.addr);
  wipeAnsiString(p);
end;

procedure nano_signBlock(var block: TNanoBlock; cc: NanoCoin);
var
  blockHash: AnsiString;
  pub: AnsiString;
  p: AnsiString;
begin
  p := cc.getPrivFromSession();
  pub := nano_privToPub(p);
  blockHash := nano_getBlockHash(Block);
  nano_setSignature(Block, nano_signature(blockHash, p, pub));
  nano_setAccount(Block, cc.addr);
  wipeAnsiString(p);
end;


function nano_addPendingReceiveBlock(sourceBlockHash: AnsiString;
cc: cryptoCurrency; from: AnsiString; ms: AnsiString; amount: BigInteger)
  : TNanoBlock;
begin
  result := nano_newBlock(true);
  if (Length(cc.lastPendingBlock) = 64) and (Length(cc.History) > 0) then
    nano_setReceiveParameters(result, NanoCoin(cc).getPreviousHash,
      sourceBlockHash)
  else
    nano_setOpenParameters(result, sourceBlockHash, cc.addr,
      nano_getWalletRepresentative);
  nano_setStateParameters(result, cc.addr, nano_getWalletRepresentative,
    BigInteger(cc.confirmed + amount).ToString(16));
  result.Hash := nano_getBlockHash(result);
  cc.lastBlock := result.Hash;
  NanoCoin(cc).lastBlockAmount := NanoCoin(cc).lastBlockAmount + amount;
  nano_getWork(result);
  // Result.work := 'B99E3C6668B87AEF';
  result.worked := true;
  nano_signBlock(result, cc, ms);
  nano_checkWork(result, result.work, result.Hash);
  nano_setAccount(result, cc.addr);
  cc.confirmed := cc.confirmed + amount;
  cc.unconfirmed := cc.unconfirmed - amount;
  cc.lastBlock := result.Hash;
  wipeAnsiString(ms);
end;


function nano_addPendingReceiveBlock(sourceBlockHash: AnsiString; cc: NanoCoin;
from: AnsiString; amount: BigInteger): TNanoBlock;
var
  ph: AnsiString;
begin
  result := nano_newBlock(true);
  ph := cc.getPreviousHash;
  if (Length(ph) = 64) and (Length(cc.History) > 0) then
    nano_setReceiveParameters(result, ph, sourceBlockHash)
  else
    nano_setOpenParameters(result, sourceBlockHash, cc.addr,
      nano_getWalletRepresentative);

  nano_setStateParameters(result, cc.addr, nano_getWalletRepresentative,
    BigInteger(cc.confirmed + amount).ToString(16));
  result.Hash := nano_getBlockHash(result);
  cc.lastBlock := result.Hash;
  NanoCoin(cc).lastBlockAmount := NanoCoin(cc).lastBlockAmount + amount;
  nano_getWork(result);
  // Result.work := 'B99E3C6668B87AEF';
  result.worked := true;
  nano_signBlock(result, cc);
  nano_checkWork(result, result.work, result.Hash);
  nano_setAccount(result, cc.addr);
  cc.confirmed := cc.confirmed + amount;
  cc.unconfirmed := cc.unconfirmed - amount;

  // cc.lastPendingBlock := result.Hash; 
end;

procedure nano_test(cc: cryptoCurrency; data: AnsiString);
var
  js: TJSONObject;
  newblock: string;
  testblock: TNanoBlock;
  pendings: TJSONArray;
begin
  try

    js := TJSONObject.ParseJSONValue(data) as TJSONObject;

    cc.confirmed := BigInteger.Parse(js.GetValue('balance')
      .GetValue<string>('balance'));
    cc.unconfirmed := BigInteger.Parse(js.GetValue('balance')
      .GetValue<string>('pending'));
    pendings := js.GetValue<TJSONArray>('pending') as TJSONArray;
    testblock := nano_buildFromJSON(pendings.Items[0].GetValue<TJSONObject>
      ('data').GetValue('contents').Value, '');
    // testblock:=nano_addPendingReceiveBlock(testblock.hash,cc,testblock.source,speckDecrypt(TCA('Azymut1337n'),CurrentAccount.EncryptedMasterSeed),testblock.blockAmout);
  except
    on E: Exception do
    begin
    end;

  end;
  js.Free;
end;

function nano_pushBlock(b: AnsiString): AnsiString;
begin
  result := getDataOverHTTP('https://hodlernode.net/nano.php?b=' + b,
    false, true);
end;

procedure nano_minePendings(cc: cryptoCurrency; data: AnsiString;
pw: AnsiString);
var
  js: TJSONObject;
  newblock: string;
  testblock: TNanoBlock;
  pendings: TJSONArray;
  ts: TStringList;
  i: integer;
  err: string;
  MasterSeed, tced: AnsiString;
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
    MasterSeed := SpeckDecrypt(tced, CurrentAccount.EncryptedMasterSeed);
    if not IsHex(MasterSeed) then
    begin

      TThread.Synchronize(nil,
        procedure
        begin
          popupWindow.Create(dictionary('FailedToDecrypt'));
        end);

      exit;
    end;
    startFullfillingKeypool(MasterSeed);
    if pendings.Count > 0 then
      for i := 0 to (pendings.Count div 2) - 1 do
      begin

        testblock := nano_buildFromJSON(pendings.Items[(i * 2)
          ].GetValue<TJSONObject>('data').GetValue('contents').Value, '');
        testblock := nano_addPendingReceiveBlock
          (pendings.Items[(i * 2) + 1].GetValue<string>('hash'), cc,
          testblock.source, MasterSeed, testblock.blockAmount);
        nano_pushBlock(nano_getJSONBlock(testblock));
        TThread.Synchronize(TThread.CurrentThread,
          procedure
          begin
            updateBalanceLabels();
            if frmhome.PageControl.activetab = frmhome.WalletView then
              reloadWalletView();
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

  wipeAnsiString(MasterSeed);
  wipeAnsiString(pw);
  js.Free;
end;

procedure nano_DoMine(cc: cryptoCurrency; pw: AnsiString);
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
        false, true), pw);

      TThread.Synchronize(nil,
        procedure
        begin
          frmhome.NanoUnlocker.Enabled := true;
          wipeAnsiString(pw);
        end);

		
    end).Start();

end;

function nano_send(var from: TwalletInfo; sendto: AnsiString;
amount: BigInteger; MasterSeed: AnsiString): AnsiString;
var
  Block: TNanoBlock;
  pub: AnsiString;
  p: AnsiString;
  ts: TStringList;
  pb:TPendingNanoBlock;
begin


  p := nano_getPriv(Nanocoin(from), MasterSeed);
  
  pub := nano_privToPub(p);
  Block := nano_newBlock(true);
  nano_setSendParameters(Block, NanoCoin(from).getPreviousHash, sendto,
    BigInteger(NanoCoin(from).lastBlockAmount - amount).ToString(16));
  nano_setStateParameters(Block, from.addr, nano_getWalletRepresentative,
    BigInteger(NanoCoin(from).lastBlockAmount - amount).ToString(16));
  NanoCoin(from).lastBlock := nano_getBlockHash(Block);
  nano_setSignature(Block, nano_signature(nano_getBlockHash(Block), p, pub));
  from.lastBlock := Block.Hash;
  pb.Block:=block;
  pb.Hash:=Block.Hash;
  NanoCoin(from).lastBlockAmount := NanoCoin(from).lastBlockAmount - amount;
  if NanoCoin(from).isUnlocked then
  NanoCoin(from).tryAddPendingBlock(pb) else
  NanoCoin(from).mineBlock(pb,masterseed);
//  SetLength(NanoCoin(from).pendingSendBlocks,
//    Length(NanoCoin(from).pendingSendBlocks) + 1);
//  NanoCoin(from).pendingSendBlocks[High(NanoCoin(from).pendingSendBlocks)
//    ] := Block;
 // NanoCoin(from).saveSendBlocks;
//  nano_getWork(Block);
//  from.confirmed := from.confirmed - amount;
//  result := nano_pushBlock(nano_getJSONBlock(Block));
//  NanoCoin(from).removePendingBlock(block.previous);
  wipeAnsiString(MasterSeed);
  wipeAnsiString(p);
end;

function findPrecalculated(Hash: AnsiString): AnsiString;
var
  pow: precalculatedPow;
begin
  result := '';
  Hash := LowerCase(Hash);
  for pow in pows do
    if pow.Hash = Hash then
      exit(pow.work);
end;

procedure setPrecalculated(Hash, work: AnsiString);
var
  i: integer;
begin
  if Length(Hash) <> 64 then
    exit;
  Hash := LowerCase(Hash);
  for i := 0 to Length(pows) - 1 do
    if pows[i].Hash = Hash then
    begin
      pows[i].work := work;
      exit;
    end;
  SetLength(pows, Length(pows) + 1);

  pows[high(pows)].Hash := Hash;
  pows[High(pows)].work := work;
end;

procedure removePow(Hash: AnsiString);
var
  i: integer;
begin
  for i := 0 to Length(pows) - 1 do
  begin
    if pows[i].Hash = Hash then
    begin
      pows[i] := pows[High(pows)];
      SetLength(pows, Length(pows) - 1);
      exit;
    end;
  end;
end;

procedure savePows;
var
  ts: TStringList;
  i: integer;
begin
  ts := TStringList.Create;
  try
    for i := 0 to Length(pows) - 1 do
    begin
      if Length(pows[i].Hash) <> 64 then
        continue;

      ts.Add(pows[i].Hash + ' ' + pows[i].work);
    end;
    ts.SaveToFile('nanopows.dat');
  finally
    ts.Free;
  end;
end;

procedure loadPows;
var
  ts: TStringList;
  i: integer;
  t: TStringList;
begin
  SetLength(pows, 0);
  ts := TStringList.Create;
  try
    if FileExists(('nanopows.dat')) then
    begin
      ts.LoadFromFile('nanopows.dat');
      SetLength(pows, ts.Count);
      for i := 0 to ts.Count - 1 do
      begin
        t := SplitString(ts.Strings[i], ' ');
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

procedure NanoCoin.loadSendBlocks;
var
  js: TJSONArray;
  jo: TJSONObject;
  ts: TStringList;
  i: integer;
  b: TNanoBlock;
begin
exit;
  SetLength(self.pendingSendBlocks, 0);
  ts := TStringList.Create();
  jo := TJSONObject.Create;
  try
    if FileExists(TPath.Combine(CurrentAccount.DirPath,
      self.addr + '.send.json')) then
    begin

      ts.LoadFromFile(TPath.Combine(CurrentAccount.DirPath,
        self.addr + '.send.json'));
      js := jo.ParseJSONValue(ts.Text) as TJSONArray;
      for i := 0 to js.Count - 1 do
      begin
        b := nano_sendFromJSON(js.Get(i));
        SetLength(self.pendingSendBlocks, Length(self.pendingSendBlocks) + 1);
        self.pendingSendBlocks[High(self.pendingSendBlocks)] := b;
      end;

      js.Free;
    end;
    self.lastBlockAmount := BigInteger.Parse
      (self.pendingSendBlocks[High(self.pendingSendBlocks)].balance);
    self.lastBlock := nano_getBlockHash
      (self.pendingSendBlocks[High(self.pendingSendBlocks)]);

  except
  end;
  ts.Free;
  jo.Free;
  TThread.CreateAnonymousThread(
    procedure
    var
      Block, bx: TNanoBlock;
    var
      work: AnsiString;
    begin
      for bx in self.pendingSendBlocks do
      begin
        Block := bx;
        work := nano_pow(Block.previous);
        Block.work := work;
        nano_pushBlock(nano_sendToJSON(Block));
        self.removePendingBlock(Block.previous);
        self.saveSendBlocks;
      end;

    end).Start;
end;
procedure NanoCoin.mineBlock(Block: TpendingNanoBlock; MasterSeed: AnsiString);
var
  temp: TNanoBlock;
begin
  mutexMining.Acquire;
  if Block.Block.blockType<>'send' then
  begin

  temp := nano_addPendingReceiveBlock(Block.Hash, self, Block.Block.source,
    MasterSeed, Block.Block.blockAmount);
   end else
  begin
   temp:=Block.block;
   nano_getWork(temp);

  end;
  nano_pushBlock(nano_getJSONBlock(temp));

  wipeAnsiString(MasterSeed);

  mutexMining.Release;
end;
procedure NanoCoin.mineBlock(Block: TpendingNanoBlock);
var
  temp: TNanoBlock;
begin
  if isUnlocked = false then
    raise Exception.Create('nano must be unlocked first');

  mutexMining.Acquire;
  if Block.Block.blockType<>'send' then
  begin
  temp := nano_addPendingReceiveBlock(Block.Hash, self, Block.Block.source,
    Block.Block.blockAmount);
  end else
  begin
   temp:=Block.block;
   nano_getWork(temp);

  end;
  nano_pushBlock(nano_getJSONBlock(temp));

  mutexMining.Release;
end;


procedure auxPOW;
begin

end;

initialization

loadPows;

finalization

savePows;

end.
