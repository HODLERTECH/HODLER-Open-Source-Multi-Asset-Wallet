// Nanocurrency unit, Copyleft 2019 FL4RE - Daniel Mazur
unit Nano;

interface

uses
  AESObj, SPECKObj, FMX.Objects, IdHash, IdHashSHA, IdSSLOpenSSL, languages,
  System.Hash, MiscOBJ, SysUtils, System.IOUtils, HashObj, System.Types, System.UITypes,
  System.DateUtils, System.Generics.Collections, System.Classes, System.Variants,
  Math, FMX.Types, FMX.Graphics, FMX.Controls, FMX.Forms, FMX.Dialogs, FMX.StdCtrls,
  FMX.Controls.Presentation, FMX.Styles, System.ImageList, FMX.ImgList, FMX.Ani,
  FMX.Layouts, FMX.ExtCtrls, Velthuis.BigIntegers, FMX.ScrollBox, FMX.Memo, FMX.platform,
  FMX.TabControl, {$IF NOT DEFINED(LINUX)}System.Sensors, System.Sensors.Components, {$ENDIF}
  FMX.Edit, JSON, JSON.Builders, JSON.Readers, DelphiZXingQRCode, System.Net.HttpClientComponent,
  System.Net.HttpClient, keccak_n, tokenData, bech32, cryptoCurrencyData,
  WalletStructureData, AccountData, ClpCryptoLibTypes, ClpSecureRandom,
  ClpISecureRandom, ClpCryptoApiRandomGenerator, ClpICryptoApiRandomGenerator,
  AssetsMenagerData, HlpBlake2BConfig, HlpBlake2B, HlpHashFactory,
  ClpDigestUtilities, HlpIHash, misc, ClpIX9ECParameters, ClpIECDomainParameters,
  ClpECDomainParameters, ClpIECKeyPairGenerator, ClpECKeyPairGenerator,
  ClpIECKeyGenerationParameters, ClpIAsymmetricCipherKeyPair,
  ClpIECPrivateKeyParameters, ClpIECPublicKeyParameters,
  ClpECPrivateKeyParameters, ClpIECInterface, ClpHex, ClpCustomNamedCurves,
  ClpHMacDsaKCalculator, ECCObj , System.SyncObjs

{$IFDEF ANDROID}, Androidapi.JNI.GraphicsContentViewText, Androidapi.JNI.JavaTypes,
  Androidapi.Helpers, Androidapi.JNI.Net, Androidapi.JNI.Os, Androidapi.JNI.Webkit,
  Androidapi.JNIBridge
{$ENDIF}
{$IFDEF MSWINDOWS}
  , Winapi.ShellApi

{$ENDIF};

const
  RAI_TO_RAW = '000000000000000000000000';
  MAIN_NET_WORK_THRESHOLD = 'ffffffc000000000';
  STATE_BLOCK_PREAMBLE = '0000000000000000000000000000000000000000000000000000000000000006';
  STATE_BLOCK_ZERO = '0000000000000000000000000000000000000000000000000000000000000000';

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

    Block : TnanoBlock;
    Hash : AnsiString;

  end;


type
  NanoCoin = class ( TwalletInfo )

    PendingBlocks : TQueue<TpendingNanoBlock>;
    PendingThread : TThread;
    mutexMining : TSemaphore;

    UnlockPriv : AnsiString;
    isUnlocked : boolean;
    sessionKey : AnsiString;

    public
    procedure mineAllPendings( MasterSeed : AnsiString = '' );

    procedure unlock( masterSeed : ansiString );
    function getPrivFromSession() : AnsiString;

    procedure mineBlock( block : TpendingNanoBlock  ; MasterSeed : AnsiString ); overload;
    procedure mineBlock( block : TpendingNanoBlock ); overload;

    procedure tryAddPendingBlock( block : TpendingNanoBlock );

    constructor Create(id: integer; _x: integer; _y: integer; _addr: AnsiString;
      _description: AnsiString; crTime: integer = -1); overload;


    destructor destroy();
    //ConfirmThread : TAutoReceive;

    //procedure runAutoConfirm();

  end;

function nano_pow(Hash: AnsiString): AnsiString;

procedure removePow(Hash: AnsiString);

procedure setPrecalculated(Hash, work: AnsiString);

function findPrecalculated(Hash: AnsiString): AnsiString;

procedure nano_test(cc: cryptoCurrency; data: AnsiString);

procedure nano_precalculate(Hash: AnsiString);

function nano_accountFromHexKey(adr: AnsiString): AnsiString;

function nano_getPriv(x, y: System.UInt32; MasterSeed: AnsiString): AnsiString;

function nano_keyFromAccount(adr: AnsiString): AnsiString;

function nano_createHD(x, y: System.UInt32; MasterSeed: AnsiString): TWalletInfo;

function nano_obtainBlock(Hash: AnsiString): AnsiString;

function nano_addPendingReceiveBlock(sourceBlockHash: AnsiString; cc: cryptoCurrency; from: AnsiString; ms: AnsiString; amount: BigInteger): TNanoBlock; overload;
function nano_addPendingReceiveBlock(sourceBlockHash: AnsiString; cc: NanoCoin ; from: AnsiString; amount: BigInteger): TNanoBlock; overload;

function nano_buildFromJSON(JSON, prev: AnsiString; hexBalance: Boolean = false): TNanoBlock;

function nano_getJSONBlock(block: TNanoBlock): AnsiString;

function nano_checkWork(block: TNanoBlock; work: AnsiString; blockHash: AnsiString = ''): Boolean;

function nano_getBlockHash(var block: TNanoBlock): AnsiString;

procedure nano_DoMine(cc: cryptoCurrency; pw: AnsiString);

function nano_send(var from: TWalletInfo; sendto: AnsiString; amount: BigInteger; MasterSeed: AnsiString): AnsiString;

function nano_pushBlock(b: AnsiString): AnsiString;

procedure nano_signBlock(var block: TNanoBlock; cc: NanoCoin); overload;
procedure nano_signBlock(var block: TNanoBlock; cc: cryptoCurrency; ms: AnsiString); overload;



implementation

uses
  ED25519_Blake2b, uHome, PopupWindowData, keypoolrelated, walletviewrelated;

 //////////////////////////////////////////////////////////////////////

constructor NanoCoin.create(id: integer; _x: integer; _y: integer; _addr: AnsiString;
      _description: AnsiString; crTime: integer = -1);
begin

  inherited create(id , _x , _y , _addr , _description , crtime );

  PendingBlocks := TQueue<TpendingNanoBlock>.Create();
  mutexMining := TSemaphore.Create();
  isUnlocked := false;


end;

destructor NanoCoin.destroy;
begin

  inherited;
  wipeAnsiString( UnlockPriv );

  PendingBlocks.Free;
  mutexMining.Free;

end;

function nanocoin.getPrivFromSession;
var
  i : integer;
begin
  if isUnlocked = false then
    raise Exception.Create('nano must be unlocked first');

  SetLength( result , length( UnlockPriv ) );
  for i := low(UnlockPriv) to High(UnlockPriv) do
  begin
    result[i] := AnsiChar( ord(sessionkey[i]) xor ord(unlockPriv[i])) ;
  end;

end;
procedure NanoCoin.unlock(masterSeed: AnsiString);
var
  i : Integer;
begin

  unlockpriv := nano_getPriv( x,  y, masterSeed );
  SetLength( sessionKey , length( UnlockPriv ) );
  for i := low(UnlockPriv) to High(UnlockPriv) do
  begin
    sessionKey[i] := Ansichar( random(255) );
  end;

  for i := low(UnlockPriv) to High(UnlockPriv) do
  begin
    UnlockPriv[i] := AnsiChar( ord(sessionkey[i]) xor ord(unlockPriv[i])) ;
  end;

  isUnlocked := true;

  mineAllPendings();

end;

procedure NanoCoin.mineAllPendings( MasterSeed : AnsiString = '' );
begin
  if (isUnlocked = false) and ( masterSeed = '' ) then
    raise Exception.Create('nano must be unlocked first');



  if (PendingThread = nil) or (PendingThread.Finished) then
  begin

    if (PendingThread <> nil) and (PendingThread.Finished) then
      PendingThread.Free;

    PendingThread := TThread.CreateAnonymousThread(procedure
    begin

      while( PendingBlocks.Count <> 0 ) do
      begin

        if MasterSeed = '' then
          mineBlock( PendingBlocks.Dequeue )
        else
          mineBlock( PendingBlocks.Dequeue , masterSeed );

      end;


    end);

    PendingThread.FreeOnTerminate := false;
    PendingThread.Start;
  end;


end;

procedure NanoCoin.tryAddPendingBlock(block : TpendingNanoBlock);
var
  it : TQueue<TpendingNanoBlock>.TEnumerator;
begin

  it := PendingBlocks.GetEnumerator;

  while it.MoveNext do
  begin
    if it.Current.hash = block.Hash then
    begin
      exit;
    end;

  end;

  PendingBlocks.Enqueue(block);

  if isUnlocked then
    mineAllPendings();

end;

procedure nanocoin.mineBlock(block: TpendingNanoBlock ; MasterSeed : AnsiString);
var
  temp : TNanoBLock;
begin
  mutexMining.Acquire;

  temp := nano_addPendingReceiveBlock( block.Hash , self , block.Block.source, MasterSeed, block.block.blockAmount);
  nano_pushBlock(nano_getJSONBlock(temp));

  wipeAnsiString(Masterseed);

  mutexMining.Release;
end;

procedure nanocoin.mineBlock(block: TpendingNanoBlock);
var
  temp : TNanoBLock;
begin
  if isUnlocked = false then
    raise Exception.Create('nano must be unlocked first');

  mutexMining.Acquire;

  temp := nano_addPendingReceiveBlock( block.Hash , self , block.Block.source, block.block.blockAmount);
  nano_pushBlock(nano_getJSONBlock(temp));

  mutexMining.Release;
end;







  //////////////////////////////////////////////////////////////////////

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
    hash: AnsiString;
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
  result := 'xrb_3rropjiqfxpmrrkooej4qtmm1pueu36f9ghinpho4esfdor8785a455d16nf';
end;

function nano_keyFromAccount(adr: AnsiString): AnsiString;
var
  chk: AnsiString;
  rAdr, rChk: TIntegerArray;
  i: Integer;
begin
  result := adr;
  adr := stringreplace(adr, 'xrb_', '', [rfReplaceAll]);
  chk := Copy(adr, 52 + 1, 100);
  adr := '1111' + Copy(adr, 1, 52);
  SetLength(rAdr, Length(adr));
  SetLength(rChk, Length(chk));
  for i := 0 to Length(adr) - 1 do
    rAdr[i] := Pos(adr[i{$IFDEF MSWINDOWS}     + 1{$ENDIF}], nano_charset) - 1;

  for i := 0 to Length(chk) - 1 do
    rChk[i] := Pos(chk[i{$IFDEF MSWINDOWS}     + 1{$ENDIF}], nano_charset) - 1;
  result := '';
  rAdr := ChangeBits(rAdr, 5, 8, true);
  for i := 3 to Length(rAdr) - 1 do
    result := result + inttohex(rAdr[i], 2)
end;

function nano_encodeBase32(values: TIntegerArray): string;
var
  i: Integer;
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

function nano_getPrevious(block: TNanoBlock): AnsiString;
begin
  if block.blockType = 'open' then
    Exit(block.account);
  result := block.previous;
end;

function nano_getBlockHash(var block: TNanoBlock): AnsiString;
var
  Blake2b: IHash;
  toHash: AnsiString;
begin
  Blake2b := THashFactory.TCrypto.CreateBlake2B_256();
  Blake2b.Initialize();
  toHash := '';
  if block.state then
  begin
    Blake2b.TransformBytes(hexatotbytes(STATE_BLOCK_PREAMBLE));
    Blake2b.TransformBytes(hexatotbytes(block.account));
    Blake2b.TransformBytes(hexatotbytes(block.previous));
    Blake2b.TransformBytes(hexatotbytes(block.representative));
    Blake2b.TransformBytes(hexatotbytes(reversehexorder(inttotx(BigInteger.Parse('+0x00' + block.balance), 32))));

    if block.blockType = 'send' then
      Blake2b.TransformBytes(hexatotbytes(block.destination));
    // toHash := toHash + block.destination;
    if block.blockType = 'receive' then
      Blake2b.TransformBytes(hexatotbytes(block.source));
    // toHash := toHash + block.source;
    if block.blockType = 'open' then
      Blake2b.TransformBytes(hexatotbytes(block.source));
    // toHash := toHash + block.source;
    if block.blockType = 'change' then
      Blake2b.TransformBytes(hexatotbytes(STATE_BLOCK_ZERO));
    // STATE_BLOCK_ZERO;
  end
  else
  begin
    if block.blockType = 'send' then
    begin
      Blake2b.TransformBytes(hexatotbytes(block.previous));
      Blake2b.TransformBytes(hexatotbytes(block.destination));
      Blake2b.TransformBytes(hexatotbytes(reversehexorder(inttotx(BigInteger.Parse('0x00' + block.balance), 32))));

    end;
    if block.blockType = 'receive' then
    begin
      Blake2b.TransformBytes(hexatotbytes(block.previous));
      Blake2b.TransformBytes(hexatotbytes(block.source));
    end;
    if block.blockType = 'open' then
    begin
      Blake2b.TransformBytes(hexatotbytes(block.source));
      Blake2b.TransformBytes(hexatotbytes(block.representative));
      Blake2b.TransformBytes(hexatotbytes(block.account));
    end;
    if block.blockType = 'change' then
    begin
      Blake2b.TransformBytes(hexatotbytes(block.previous));
      Blake2b.TransformBytes(hexatotbytes(block.representative));
    end;
  end;
  result := Blake2b.TransformFinal.ToString();
  block.Hash := result;
end;

procedure nano_setSendParameters(var block: TNanoBlock; previousBlockHash, destinationAccount, balanceRemaining: AnsiString);
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
  block.previous := previousBlockHash;
  block.destination := accKey;
  block.balance := balanceRemaining;
  block.blockType := 'send';
end;

procedure nano_setReceiveParameters(var block: TNanoBlock; previousBlockHash, sourceBlockHash: AnsiString);
begin
  if (not IsHex(previousBlockHash)) then
    raise Exception.Create('Invalid previous block hash');
  if (not IsHex(sourceBlockHash)) then
    raise Exception.Create('Invalid source block hash');

  block.previous := previousBlockHash;
  block.source := sourceBlockHash;
  block.blockType := 'receive';

end;

procedure nano_setStateParameters(var block: TNanoBlock; newAccount, representativeAccount, curBalance: AnsiString);
begin

  try
    block.account := nano_keyFromAccount(newAccount);

  except
    on E: Exception do
      raise Exception.Create('Invalid address');
  end;
  try
    block.representative := nano_keyFromAccount(representativeAccount);

  except
    on E: Exception do
      raise Exception.Create('Invalid representative address');
  end;
  block.balance := curBalance;
end;

procedure nano_setOpenParameters(var block: TNanoBlock; sourceBlockHash, newAccount, representativeAccount: AnsiString);
begin
  if (not IsHex(sourceBlockHash)) then
    raise Exception.Create('Invalid source block hash');

  if representativeAccount <> '' then
    block.representative := nano_keyFromAccount(representativeAccount)
  else
    block.representative := block.account;
  block.source := sourceBlockHash;
  if block.state then
    block.previous := STATE_BLOCK_ZERO;
  block.blockType := 'open';

end;

procedure nano_setChangeParameters(var block: TNanoBlock; previousBlockHash, representativeAccount: AnsiString);
begin
  if not IsHex(previousBlockHash) then
    raise Exception.Create('Invalid previous block hash');
  block.representative := nano_keyFromAccount(representativeAccount);
  block.previous := previousBlockHash;
  block.blockType := 'change';

end;

procedure nano_setSignature(var block: TNanoBlock; hex: AnsiString);
begin
  block.signature := hex;
  block.signed := true;
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
    thres := $ffffffc000000000;
    workBytes := hexatotbytes('0000000000000000' + Hash);
    random := TSecureRandom.GetInstance('SHA256PRNG');
    ran := random.NextInt64;
    Move(ran, workBytes[0], 8);
    while True do
    begin

      //if counter mod 1000000 = 0 then
      //  Sleep(50); //no luck, let's cool down CPU :)

      for i := 0 to 255 do
      begin
        workBytes[7] := i;


        //inc(counter);

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
                Self.foundWork := work;
                Exit;
              end;
      end;
  //Move(t[0],ran,8);
      ran := ran * $08088405 + 1;

        Move(ran, workBytes[0], 7);


    end;
  except on E: Exception do
      TThread.Synchronize(nil , procedure
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
  workers: array[0..powworkers] of TPowWorker;
  i: Integer;
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
    Exit( work );
    //Exit(nano_pow(Hash));
  end;
  setPrecalculated(Hash, 'MINING');

  for i := 0 to powworkers do
  begin
    workers[i] := TPowWorker.Create(True);
    {$IFDEF MSWINDOWS}            workers[i].Priority := tpHighest; {$ENDIF}
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
        setPrecalculated(Hash, work);
        result := work;
        Break;
      end;

  end;
  for i := 0 to powworkers do
    workers[i].Terminate;
end;

function nano_getWork(var block: TNanoBlock): AnsiString;
begin
  block.work := nano_pow(nano_getPrevious(block));
  block.worked := true;

end;

procedure nano_precalculate(Hash: AnsiString);
begin
  TThread.CreateAnonymousThread(
    procedure
    begin
      nano_pow(Hash);
    end).Start();
end;

function nano_checkWork(block: TNanoBlock; work: AnsiString; blockHash: AnsiString = ''): Boolean;
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
    blockHash := nano_getPrevious(block);
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

procedure nano_setWork(var block: TNanoBlock; hex: AnsiString);
begin
  if not nano_checkWork(block, hex) then
    raise Exception.Create('Work not valid for block');
  block.work := hex;
  block.worked := true;
end;

procedure nano_setAccount(var block: TNanoBlock; acc: AnsiString);
begin
  block.blockAccount := acc;
  if block.blockType = 'send' then
    block.origin := acc;
end;

procedure nano_setOrigin(var block: TNanoBlock; acc: AnsiString);
begin
  if (block.blockType = 'receive') or (block.blockType = 'open') then
    block.origin := acc;
end;

procedure nano_setTimestamp(var block: TNanoBlock; millis: System.UInt64);
begin
  block.timestamp := millis;
end;

function nano_getOrigin(block: TNanoBlock): AnsiString;
begin
  if (block.blockType = 'receive') or (block.blockType = 'open') then
    Exit(block.origin);
  if (block.blockType = 'send') then
    Exit(block.blockAccount);
  result := '';
end;

function nano_getDestination(block: TNanoBlock): AnsiString;
begin
  if (block.blockType = 'send') then
    Exit(nano_accountFromHexKey(block.destination));
  if (block.blockType = 'receive') or (block.blockType = 'open') then
    Exit(block.blockAccount);

end;

function nano_getRepresentative(block: TNanoBlock): AnsiString;
begin
  if (block.state) or (block.blockType = 'change') or (block.blockType = 'open') then
    Exit(nano_accountFromHexKey(block.representative))
  else
    result := '';

end;

function nano_isReady(block: TNanoBlock): Boolean;
begin
  result := block.signed and block.worked;
end;

procedure nano_changePrevious(var block: TNanoBlock; newPrevious: AnsiString);
begin
  if block.blockType = 'open' then
    raise Exception.Create('Open has no previous block');
  if block.blockType = 'receive' then
  begin
    nano_setReceiveParameters(block, newPrevious, block.source);
    nano_getBlockHash(block);
    Exit;
  end;
  if block.blockType = 'send' then
  begin
    nano_setSendParameters(block, newPrevious, block.destination, block.balance);
    // api.setSendParameters(newPrevious, destination, stringFromHex(balance).replace(RAI_TO_RAW, ''))
    nano_getBlockHash(block);
    Exit;
  end;
  if block.blockType = 'change' then
  begin
    nano_setChangeParameters(block, newPrevious, block.representative);
    nano_getBlockHash(block);
    Exit;
  end;
  raise Exception.Create('Invalid block type');
end;

function nano_getJSONBlock(block: TNanoBlock): AnsiString;
var
  obj: TjsonObject;
begin
  if not block.signed then
    raise Exception.Create('Block not signed');

  obj := TjsonObject.Create();
  if block.state then
  begin
    obj.AddPair(TJSONPair.Create('type', 'state'));
    if block.blockType = 'open' then
      obj.AddPair(TJSONPair.Create('previous', STATE_BLOCK_ZERO))
    else
      obj.AddPair(TJSONPair.Create('previous', block.previous));

    obj.AddPair(TJSONPair.Create('account', nano_accountFromHexKey(block.account)));
    obj.AddPair(TJSONPair.Create('representative', nano_accountFromHexKey(block.representative { + block.account } )));
    obj.AddPair(TJSONPair.Create('balance', BigInteger.Parse('+0x0' + block.balance).ToString(10)));
    if block.blockType = 'send' then
      obj.AddPair(TJSONPair.Create('link', block.destination));
    if block.blockType = 'receive' then
      obj.AddPair(TJSONPair.Create('link', block.source));
    if block.blockType = 'open' then
      obj.AddPair(TJSONPair.Create('link', block.source));
    if block.blockType = 'change' then
      obj.AddPair(TJSONPair.Create('link', STATE_BLOCK_ZERO));
  end
  else
  begin
    obj.AddPair(TJSONPair.Create('type', block.blockType));
    if block.blockType = 'send' then
    begin
      obj.AddPair(TJSONPair.Create('previous', block.previous));
      obj.AddPair(TJSONPair.Create('destination', nano_accountFromHexKey(block.destination)));
      obj.AddPair(TJSONPair.Create('balance', block.balance));
    end;
    if block.blockType = 'receive' then
    begin
      obj.AddPair(TJSONPair.Create('source', block.source));
      obj.AddPair(TJSONPair.Create('previous', block.previous));
    end;
    if block.blockType = 'open' then
    begin
      obj.AddPair(TJSONPair.Create('source', block.source));
      obj.AddPair(TJSONPair.Create('representative', nano_accountFromHexKey(block.representative { + block.account } )));
      obj.AddPair(TJSONPair.Create('account', nano_accountFromHexKey(block.account)));
    end;
    if block.blockType = 'change' then
    begin
      obj.AddPair(TJSONPair.Create('previous', block.previous));
      obj.AddPair(TJSONPair.Create('representative', nano_accountFromHexKey(block.representative)));
    end;
  end;
  obj.AddPair(TJSONPair.Create('work', block.work));
  obj.AddPair(TJSONPair.Create('signature', block.signature));
  result := obj.ToJSON;
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

function nano_buildFromJSON(JSON, prev: AnsiString; hexBalance: Boolean = false): TNanoBlock;
var
  obj, prevObj: TjsonObject;
var
  state: Boolean;
begin
  result := nano_newBlock(false);
  obj := TjsonObject.ParseJSONValue(TEncoding.ASCII.GetBytes(JSON), 0) as TjsonObject;
  if (Length(obj.GetValue('previous').Value) = 64) and (prev = '') then
  begin
    prev := nano_obtainBlock(obj.GetValue('previous').Value);
  end;

  prevObj := TjsonObject.ParseJSONValue(TEncoding.ASCII.GetBytes(prev), 0) as TjsonObject;
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
          result.send := BigInteger.Parse( { '0x0' + } prevObj.GetValue('balance').Value) > BigInteger.Parse( { '0x0' + } obj.GetValue('balance').Value)
        else
          result.send := BigInteger.Parse('0x0' + prevObj.GetValue('balance').Value) > BigInteger.Parse('0x0' + obj.GetValue('balance').Value)
      end
      else
      begin
        if obj.GetValue('subtype') <> nil then
          result.send := obj.GetValue('subtype').Value = 'send';
      end;
    end;
    result.previous := obj.GetValue('previous').Value;
    if not hexBalance then
      result.balance := BigInteger.Parse(obj.GetValue('balance').Value).ToString(10)
    else
      result.balance := BigInteger.Parse(obj.GetValue('balance').Value).ToString(16);
    result.account := nano_keyFromAccount(obj.GetValue('account').Value);
    result.representative := nano_keyFromAccount(obj.GetValue('representative').Value);
    if result.send then
    begin
      result.blockType := 'send';
      result.destination := obj.GetValue('link').Value;
      if not hexBalance then
        result.blockAmount := BigInteger.Parse(prevObj.GetValue('balance').Value) - BigInteger.Parse(obj.GetValue('balance').Value)
      else
        result.blockAmount := BigInteger.Parse('0x0' + prevObj.GetValue('balance').Value) - BigInteger.Parse('0x0' + obj.GetValue('balance').Value)
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
            result.blockAmount := BigInteger.Parse(prevObj.GetValue('balance').Value) - BigInteger.Parse(obj.GetValue('balance').Value)
          else
            result.blockAmount := BigInteger.Parse('0x0' + prevObj.GetValue('balance').Value) - BigInteger.Parse('0x0' + obj.GetValue('balance').Value)
        end;
      end;

    end;

  end
  else
  begin
    if result.blockType = 'send' then
    begin
      result.previous := obj.GetValue('previous').Value;
      result.destination := nano_keyFromAccount(obj.GetValue('destination').Value);
      result.balance := obj.GetValue('balance').Value;
      if not hexBalance then
        result.blockAmount := BigInteger.Parse(prevObj.GetValue('balance').Value) - BigInteger.Parse(obj.GetValue('balance').Value)
      else
        result.blockAmount := BigInteger.Parse('0x0' + prevObj.GetValue('balance').Value) - BigInteger.Parse('0x0' + obj.GetValue('balance').Value)
    end;
    if result.blockType = 'receive' then
    begin
      result.previous := obj.GetValue('previous').Value;
      result.source := obj.GetValue('source').Value;

    end;
    if result.blockType = 'open' then
    begin
      result.source := obj.GetValue('source').Value;
      result.representative := nano_keyFromAccount(obj.GetValue('representative').Value);
      result.account := nano_keyFromAccount(obj.GetValue('account').Value);
    end;
    if result.blockType = 'change' then
    begin
      result.previous := obj.GetValue('previous').Value;
      result.representative := nano_keyFromAccount(obj.GetValue('representative').Value)

    end;
  end;
  result.signature := obj.GetValue('signature').Value;
  result.work := obj.GetValue('work').Value;
  if result.work <> '' then
    result.worked := true;
  if result.signature <> '' then
    result.signed := true;
  if not (obj.GetValue('hash') = nil) then
    result.Hash := obj.GetValue('hash').Value
  else
    result.Hash := nano_getBlockHash(result);
end;

function nano_getPriv(x, y: System.UInt32; MasterSeed: AnsiString): AnsiString;
var
  Blake2b: IHash;
  toHash: AnsiString;
begin
  Blake2b := THashFactory.TCrypto.CreateBlake2B_256();
  Blake2b.Initialize();
  Blake2b.TransformBytes(hexatotbytes(GetStrHashSHA256(MasterSeed + inttohex(x, 32) + inttohex(y, 32)) + MasterSeed + inttohex(x, 32) + inttohex(y, 32)), 0);
  result := Blake2b.TransformFinal.ToString;
end;

function nano_createHD(x, y: System.UInt32; MasterSeed: AnsiString): TWalletInfo;
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

procedure nano_signBlock(var block: TNanoBlock; cc: cryptoCurrency; ms: AnsiString);
var
  blockHash: AnsiString;
  pub: AnsiString;
  p: AnsiString;
begin
  p := nano_getPriv(TWalletInfo(cc).x, TWalletInfo(cc).y, ms);
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
  blockHash := nano_getBlockHash(block);
  nano_setSignature(block, nano_signature(blockHash, p, pub));
  nano_setAccount(block, cc.addr);
  wipeAnsiString(p);
end;

function nano_addPendingReceiveBlock(sourceBlockHash: AnsiString; cc: cryptoCurrency; from: AnsiString; ms: AnsiString; amount: BigInteger): TNanoBlock;
begin
  result := nano_newBlock(true);
  if (Length(cc.lastPendingBlock) = 64) and (Length(cc.History) > 0) then
    nano_setReceiveParameters(result, cc.lastPendingBlock, sourceBlockHash)
  else
    nano_setOpenParameters(result, sourceBlockHash, cc.addr, nano_getWalletRepresentative);
  nano_setStateParameters(result, cc.addr, nano_getWalletRepresentative, BigInteger(cc.confirmed + amount).ToString(16));
  result.Hash := nano_getBlockHash(result);
  nano_getWork(result);
  // Result.work := 'B99E3C6668B87AEF';
  result.worked := true;
  nano_signBlock(result, cc, ms);
  nano_checkWork(result, result.work, result.Hash);
  nano_setAccount(result, cc.addr);
  cc.confirmed := cc.confirmed + amount;
  cc.unconfirmed := cc.unconfirmed - amount;
  cc.lastPendingBlock := result.Hash;
  wipeAnsiString(ms);
end;

function nano_addPendingReceiveBlock(sourceBlockHash: AnsiString; cc: NanoCoin ; from: AnsiString; amount: BigInteger): TNanoBlock;
begin
  result := nano_newBlock(true);
  if (Length(cc.lastPendingBlock) = 64) and (Length(cc.History) > 0) then
    nano_setReceiveParameters(result, cc.lastPendingBlock, sourceBlockHash)
  else
    nano_setOpenParameters(result, sourceBlockHash, cc.addr, nano_getWalletRepresentative);

  nano_setStateParameters(result, cc.addr, nano_getWalletRepresentative, BigInteger(cc.confirmed + amount).ToString(16));
  result.Hash := nano_getBlockHash(result);
  nano_getWork(result);
  // Result.work := 'B99E3C6668B87AEF';
  result.worked := true;
  nano_signBlock(result, cc);
  nano_checkWork(result, result.work, result.Hash);
  nano_setAccount(result, cc.addr);
  cc.confirmed := cc.confirmed + amount;
  cc.unconfirmed := cc.unconfirmed - amount;
  cc.lastPendingBlock := result.Hash;
end;

procedure nano_test(cc: cryptoCurrency; data: AnsiString);
var
  js: TjsonObject;
  newblock: string;
  testblock: TNanoBlock;
  pendings: TJsonArray;
begin
  try

    js := TjsonObject.ParseJSONValue(data) as TjsonObject;

    cc.confirmed := BigInteger.Parse(js.GetValue('balance').GetValue < string > ('balance'));
    cc.unconfirmed := BigInteger.Parse(js.GetValue('balance').GetValue < string > ('pending'));
    pendings := js.GetValue<TJsonArray>('pending') as TJsonArray;
    testblock := nano_buildFromJSON(pendings.Items[0].GetValue < TjsonObject > ('data').GetValue('contents').Value, '');
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
  result := getDataOverHTTP('https://hodlernode.net/nano.php?b=' + b);
end;

procedure nano_minePendings(cc: cryptoCurrency; data: AnsiString; pw: AnsiString);
var
  js: TjsonObject;
  newblock: string;
  testblock: TNanoBlock;
  pendings: TJsonArray;
  ts: TStringList;
  i: Integer;
  err: string;
  MasterSeed, tced: AnsiString;
begin
  try

    js := TjsonObject.ParseJSONValue(data) as TjsonObject;

    cc.confirmed := BigInteger.Parse(js.GetValue('balance').GetValue < string > ('balance'));
    cc.unconfirmed := BigInteger.Parse(js.GetValue('balance').GetValue < string > ('pending'));
    pendings := js.GetValue<TJsonArray>('pending') as TJsonArray;
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

      Exit;
    end;
    startFullfillingKeypool(MasterSeed);
    if pendings.Count > 0 then
      for i := 0 to (pendings.Count div 2) - 1 do
      begin

        testblock := nano_buildFromJSON(pendings.Items[(i * 2)].GetValue < TjsonObject > ('data').GetValue('contents').Value, '');
        testblock := nano_addPendingReceiveBlock(pendings.Items[(i * 2) + 1].GetValue < string > ('hash'), cc, testblock.source, MasterSeed, testblock.blockAmount);
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
      tthread.Synchronize(nil , procedure
      begin
        frmhome.NanoUnlocker.Enabled := false;
        frmhome.NanoUnlocker.Text := 'Mining NANO...';
      end);

      nano_minePendings(cc, getDataOverHTTP('https://hodlernode.net/nano.php?addr=' + cc.addr, false, true), pw);

      tthread.Synchronize(nil , procedure
      begin
        frmhome.NanoUnlocker.Enabled := true;
        wipeAnsiString(pw);
      end);


    end).Start();

end;

function nano_send(var from: TWalletInfo; sendto: AnsiString; amount: BigInteger; MasterSeed: AnsiString): AnsiString;
var
  block: TNanoBlock;
  pub: AnsiString;
  p: AnsiString;
  ts: TStringList;
begin
  p := nano_getPriv(TWalletInfo(from).x, TWalletInfo(from).y, MasterSeed);
  pub := nano_privToPub(p);
  block := nano_newBlock(true);
  nano_setSendParameters(block, from.lastPendingBlock, sendto, BigInteger(from.confirmed - amount).ToString(16));
  nano_setStateParameters(block, from.addr, nano_getWalletRepresentative, BigInteger(from.confirmed - amount).ToString(16));
  nano_getBlockHash(block);
  nano_setSignature(block, nano_signature(nano_getBlockHash(block), p, pub));
  nano_getWork(block);
  from.confirmed := from.confirmed - amount;
  result := nano_pushBlock(nano_getJSONBlock(block));
  from.lastPendingBlock := block.Hash;
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
      Exit(pow.work);
end;

procedure setPrecalculated(Hash, work: AnsiString);
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

procedure removePow(Hash: AnsiString);
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
    ts.SaveToFile('nanopows.dat');
  finally
    ts.Free;
  end;
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

procedure auxPOW;
begin

end;

initialization
  loadPows;

finalization
  savePows;

end.

