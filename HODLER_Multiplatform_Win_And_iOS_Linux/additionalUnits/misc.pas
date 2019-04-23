{$A8,B-,C+,D+,E-,F-,G+,H+,I+,J-,K-,L+,M-,N-,O+,P+,Q-,R-,S-,T-,U-,V+,W-,X+,Y+,Z1}
{$MINSTACKSIZE $00004000}
{$MAXSTACKSIZE $00100000}
{$IMAGEBASE $00400000}
{$APPTYPE GUI}
{$WARN SYMBOL_DEPRECATED ON}
{$WARN SYMBOL_LIBRARY ON}
{$WARN SYMBOL_PLATFORM ON}
{$WARN SYMBOL_EXPERIMENTAL ON}
{$WARN UNIT_LIBRARY ON}
{$WARN UNIT_PLATFORM ON}
{$WARN UNIT_DEPRECATED ON}
{$WARN UNIT_EXPERIMENTAL ON}
{$WARN HRESULT_COMPAT ON}
{$WARN HIDING_MEMBER ON}
{$WARN HIDDEN_VIRTUAL ON}
{$WARN GARBAGE ON}
{$WARN BOUNDS_ERROR ON}
{$WARN ZERO_NIL_COMPAT ON}
{$WARN STRING_CONST_TRUNCED ON}
{$WARN FOR_LOOP_VAR_VARPAR ON}
{$WARN TYPED_CONST_VARPAR ON}
{$WARN ASG_TO_TYPED_CONST ON}
{$WARN CASE_LABEL_RANGE ON}
{$WARN FOR_VARIABLE ON}
{$WARN CONSTRUCTING_ABSTRACT ON}
{$WARN COMPARISON_FALSE ON}
{$WARN COMPARISON_TRUE ON}
{$WARN COMPARING_SIGNED_UNSIGNED ON}
{$WARN COMBINING_SIGNED_UNSIGNED ON}
{$WARN UNSUPPORTED_CONSTRUCT ON}
{$WARN FILE_OPEN ON}
{$WARN FILE_OPEN_UNITSRC ON}
{$WARN BAD_GLOBAL_SYMBOL ON}
{$WARN DUPLICATE_CTOR_DTOR ON}
{$WARN INVALID_DIRECTIVE ON}
{$WARN PACKAGE_NO_LINK ON}
{$WARN PACKAGED_THREADVAR ON}
{$WARN IMPLICIT_IMPORT ON}
{$WARN HPPEMIT_IGNORED ON}
{$WARN NO_RETVAL ON}
{$WARN USE_BEFORE_DEF ON}
{$WARN FOR_LOOP_VAR_UNDEF ON}
{$WARN UNIT_NAME_MISMATCH ON}
{$WARN NO_CFG_FILE_FOUND ON}
{$WARN IMPLICIT_VARIANTS ON}
{$WARN UNICODE_TO_LOCALE ON}
{$WARN LOCALE_TO_UNICODE ON}
{$WARN IMAGEBASE_MULTIPLE ON}
{$WARN SUSPICIOUS_TYPECAST ON}
{$WARN PRIVATE_PROPACCESSOR ON}
{$WARN UNSAFE_TYPE OFF}
{$WARN UNSAFE_CODE OFF}
{$WARN UNSAFE_CAST OFF}
{$WARN OPTION_TRUNCATED ON}
{$WARN WIDECHAR_REDUCED ON}
{$WARN DUPLICATES_IGNORED ON}
{$WARN UNIT_INIT_SEQ ON}
{$WARN LOCAL_PINVOKE ON}
{$WARN MESSAGE_DIRECTIVE ON}
{$WARN TYPEINFO_IMPLICITLY_ADDED ON}
{$WARN RLINK_WARNING ON}
{$WARN IMPLICIT_STRING_CAST ON}
{$WARN IMPLICIT_STRING_CAST_LOSS ON}
{$WARN EXPLICIT_STRING_CAST OFF}
{$WARN EXPLICIT_STRING_CAST_LOSS OFF}
{$WARN CVT_WCHAR_TO_ACHAR ON}
{$WARN CVT_NARROWING_STRING_LOST ON}
{$WARN CVT_ACHAR_TO_WCHAR ON}
{$WARN CVT_WIDENING_STRING_LOST ON}
{$WARN NON_PORTABLE_TYPECAST ON}
{$WARN XML_WHITESPACE_NOT_ALLOWED ON}
{$WARN XML_UNKNOWN_ENTITY ON}
{$WARN XML_INVALID_NAME_START ON}
{$WARN XML_INVALID_NAME ON}
{$WARN XML_EXPECTED_CHARACTER ON}
{$WARN XML_CREF_NO_RESOLVE ON}
{$WARN XML_NO_PARM ON}
{$WARN XML_NO_MATCHING_PARM ON}
{$WARN IMMUTABLE_STRINGS OFF}
unit misc;

interface

uses AESObj, SPECKObj, FMX.Objects, IdHash, IdHashSHA, IdSSLOpenSSL, languages,
  System.Hash, MiscOBJ,
  SysUtils, System.IOUtils, HashObj, System.Types, System.UITypes,
  System.DateUtils, System.Generics.Collections, System.Diagnostics,
  System.TimeSpan,
  System.Classes,
  System.Variants, Math,
  FMX.Types, FMX.Graphics, FMX.Controls, FMX.Forms, FMX.Dialogs, FMX.StdCtrls,
  FMX.Controls.Presentation, FMX.Styles, System.ImageList, FMX.ImgList, FMX.Ani,
  FMX.Layouts, FMX.ExtCtrls, Velthuis.BigIntegers, FMX.ScrollBox, FMX.Memo,
  FMX.Platform,
  FMX.TabControl, {$IF NOT DEFINED(LINUX)}System.Sensors,
  System.Sensors.Components, {$ENDIF} FMX.Edit, JSON,
  JSON.Builders, JSON.Readers, DelphiZXingQRCode, historyPanelData,

  System.Net.HttpClientComponent, System.Net.HttpClient, keccak_n, tokenData,
  bech32,
  cryptoCurrencyData, WalletStructureData, AccountData,
  ClpCryptoLibTypes,
  ClpSecureRandom,
  ClpISecureRandom,
  ClpCryptoApiRandomGenerator,
  ClpICryptoApiRandomGenerator, PopupWindowData, TaddressLabelData,
  AssetsMenagerData, ComponentPoolData

{$IFDEF ANDROID},

  Androidapi.JNI.GraphicsContentViewText,
  Androidapi.JNI.JavaTypes,
  Androidapi.Helpers,
  Androidapi.JNI.Net,
  Androidapi.JNI.Os,
  Androidapi.JNI.Webkit,
  Androidapi.JNIBridge
{$ENDIF}
{$IFDEF MSWINDOWS}
    , WinApi.ShellApi

{$ENDIF};

{$IF DEFINED(ANDROID) OR DEFINED(IOS) OR DEFINED(LINUX)}

const
  StrStartIteration = {$IFNDEF LINUX} 0 {$ELSE}1{$ENDIF};

type
  AnsiString = string;

type
  WideString = string;

type
  AnsiChar = Char;
{$ELSE}

const
  StrStartIteration = 1;
{$ENDIF}

type

  TSecureRandoms = class
  private

    function CheckSecureRandom(const random: ISecureRandom): boolean;
    function RunChiSquaredTests(const random: ISecureRandom): boolean;
    function MeasureChiSquared(const random: ISecureRandom;
      rounds: Int32): Double;

  published
    function GetSha256Prng(): string;

  end;

type
  AccountItem = record
    name: string;
    order: integer;
  end;

type
  THistoryHolder = class(TObject)
  public
    history: transactionHistory;
  end;

type
  TKeccakMaxDigest = packed array [0 .. 63] of System.UInt8;
  { Keccak-512 digest }
{$IFDEF ANDROID}

type
  JFileProvider = interface;

  JFileProviderClass = interface(JContentProviderClass)
    ['{33A87969-5731-4791-90F6-3AD22F2BB822}']
    { class } function getUriForFile(context: JContext; authority: JString;
      _file: JFile): Jnet_Uri; cdecl;
    { class } function init: JFileProvider; cdecl;
  end;

  [JavaSignature('android/support/v4/content/FileProvider')]
  JFileProvider = interface(JContentProvider)
    ['{12F5DD38-A3CE-4D2E-9F68-24933C9D221B}']
    procedure attachInfo(context: JContext; info: JProviderInfo); cdecl;
    function delete(uri: Jnet_Uri; selection: JString;
      selectionArgs: TJavaObjectArray<JString>): integer; cdecl;
    function getType(uri: Jnet_Uri): JString; cdecl;
    function insert(uri: Jnet_Uri; values: JContentValues): Jnet_Uri; cdecl;
    function onCreate: boolean; cdecl;
    function openFile(uri: Jnet_Uri; mode: JString)
      : JParcelFileDescriptor; cdecl;
    function query(uri: Jnet_Uri; projection: TJavaObjectArray<JString>;
      selection: JString; selectionArgs: TJavaObjectArray<JString>;
      sortOrder: JString): JCursor; cdecl;
    function update(uri: Jnet_Uri; values: JContentValues; selection: JString;
      selectionArgs: TJavaObjectArray<JString>): integer; cdecl;
  end;

  TJFileProvider = class(TJavaGenericImport<JFileProviderClass, JFileProvider>)
  end;
{$ENDIF}

function ISecureRandomBuffer: AnsiString;
function speckStrPadding(data: AnsiString): AnsiString;
procedure setBlackBackground(Owner: TComponent);
function isP2PKH(netbyte: AnsiString; coinid: integer): boolean;
function isSegwitAddress(address: AnsiString): boolean;
function decodeAddressInfo(address: AnsiString; coinid: integer): TAddressInfo;
function getHighestBlockNumber(T: Token): System.uint64;
function toMnemonic(hex: AnsiString): AnsiString;
function BIntTo256Hex(data: BigInteger; Padding: integer): AnsiString;
function isEthereum(): boolean;
procedure refreshWalletDat();
function inttoeth(data: System.uint64): AnsiString; overload;
function inttoeth(data: BigInteger): AnsiString; overload;
function speckEncrypt(tcaKey, data: AnsiString): AnsiString;
function speckDecrypt(tcaKey, data: AnsiString): AnsiString;
function hexatotbytes(H: AnsiString): Tbytes;
procedure updateNameLabels();
function getUTXO(wallet: TWalletInfo): TUTXOS;
function getDataOverHTTP(aURL: String; useCache: boolean = true;
  noTimeout: boolean = false): AnsiString;
function parseUTXO(utxos: AnsiString; Y: integer): TUTXOS;
function IntToTX(data: System.uint64; Padding: integer): AnsiString; overload;
function IntToTX(data: BigInteger; Padding: integer): AnsiString; overload;
function randomHexStream(size: integer): AnsiString;
procedure wipeWalletDat;
function AES256CBCDecrypt(tcaKey, data: AnsiString): AnsiString;
function GetSHA256FromHex(H: AnsiString): AnsiString;
function HexToStream(H: AnsiString): TStream;
procedure parseWalletFile;
procedure createWalletDat();
procedure GenetareCoinsData(seed, password: AnsiString; ac: Account);
function seedToHumanReadable(seed: AnsiString): AnsiString;
function GetStrHashSHA256(Str: AnsiString): AnsiString;
function hash160FromHex(H: AnsiString): AnsiString;
function TCA(dane: AnsiString): AnsiString;
function AES256CBCEncrypt(tcaKey, data: AnsiString): AnsiString;
function isWalletDatExists: boolean;
procedure wipeAnsiString(var toWipe: AnsiString);
function reverseHexOrder(s: AnsiString): AnsiString;
function priv256forHD(coin, x, Y: integer; MasterSeed: AnsiString): AnsiString;
procedure wipeString(var toWipe: String);
procedure repaintWalletList;
function satToBtc(sat: AnsiString; decimals: integer): AnsiString; overload;
function satToBtc(num: BigInteger; decimals: integer): AnsiString; overload;
function getStringFromImage(img: TBitmap): AnsiString;
function findAddress(Str: AnsiString): AnsiString;
function SplitString(Str: AnsiString; separator: AnsiChar = ' '): TStringList;
function IsHex(s: string): boolean;
function keccak256String(s: AnsiString): AnsiString;
function keccak256Hex(s: AnsiString): AnsiString;
procedure createAddWalletView();
function cutEveryNChar(n: integer; Str: AnsiString; sep: AnsiChar = ' ')
  : AnsiString; overload;
function cutEveryNChar(n: integer; Str: AnsiString; sep: AnsiString)
  : AnsiString; overload;
function removeSpace(Str: AnsiString): AnsiString;
function generateIcon(hex: AnsiString): TBitmap;
procedure wipeTokenDat();
procedure clearVertScrollBox(VSB: TVertScrollBox);
procedure showMsg(backView: TTabItem; message: AnsiString;
  warningImage: TBitmap = nil);
function BigIntegerToFloatStr(const num: BigInteger; decimals: integer;
  precision: integer = -1): AnsiString;
function StrFloatToBigInteger(Str: AnsiString; decimals: integer): BigInteger;
function BigIntegerBeautifulStr(num: BigInteger; decimals: integer): AnsiString;
function getConfirmedAsString(wi: TWalletInfo): AnsiString;
function fromMnemonic(input: AnsiString): integer; overload;
function fromMnemonic(input: TStringList): AnsiString; overload;
function BitmapDataToScaledBitmap(data: TBitmapData; scale: integer): TBitmap;
function parseQRCode(Str: AnsiString): TStringList;
function isBech32Address(Str: AnsiString): boolean;
procedure createHistoryList(wallet: cryptoCurrency; start: integer = 0;
  stop: integer = 10);
procedure RefreshGlobalFiat();
procedure Vibrate(ms: int64);
procedure refreshOrderInDashBrd();
procedure loadDictionary(langData: WideString);
procedure refreshComponentText();
procedure refreshCurrencyValue();
procedure updateBalanceLabels(coinid: integer = -1);

Function StrToQRBitmap(Str: AnsiString; pixelSize: integer = 6): TBitmap;
procedure shareFile(path: AnsiString; deleteSourceFile: boolean = true);
procedure synchronizeCurrencyValue(data: AnsiString);
procedure LoadCurrencyFiatFromFile();
function bitcoinCashAddressToCashAddress(address: AnsiString;
  showName: boolean = true): AnsiString;
function BCHCashAddrToLegacyAddr(address: AnsiString): AnsiString;
function CreateNewAccount(name, pass, seed: AnsiString): Account;
procedure AddAccountToFile(ac: Account);

Procedure CreateNewAccountAndSave(name, pass, seed: AnsiString;
  userSaveSeed: boolean);

procedure CreatePanel(crypto: cryptoCurrency; FromAccount: Account;
  inBox: TVertScrollBox);

// procedure creatImportPrivKeyCoinList();
function getETHValidAddress(address: AnsiString): AnsiString;
function isValidETHAddress(address: AnsiString): boolean;
function searchTokens(InAddress: AnsiString; ac: Account = nil): integer;
function inputType(input: TBitcoinOutput): integer;

procedure DeleteAccount(name: AnsiString);

procedure prepareConfirmSendTabItem();

procedure LoadStyle(name: AnsiString);
procedure EnlargeQRCode(img: TBitmap);
function elevateCheckPermission(name: string): integer;
procedure AskForBackup(delay: integer = 0; afterChange: boolean = false);
procedure createSelectGenerateCoinView();
function getCoinsIDFromAddress(address: AnsiString): TIntegerArray;
procedure createTransactionWalletList(arr: TIntegerArray);
function getFirstUnusedXForCoin(id: integer): integer;
function getUnusedAccountName(): AnsiString;
function getComponentsWithTagString(tag: AnsiString; From: TfmxObject)
  : TArray<TfmxObject>;
function compareVersion(a, b: AnsiString): integer;
function postDataOverHTTP(var aURL: String; postdata: string;
  useCache: boolean = true; noTimeout: boolean = false): AnsiString;

// function floatToBigInteger(f : Single) : BigInteger;
procedure saveSendCacheToFile();
procedure loadSendCacheFromFile();
procedure clearSendCache();
function LowOrderBitSet(Value: integer): boolean;



// procedure refresh
{$WRITEABLECONST ON}

const
  HODLER_URL: string = 'https://hodler1.nq.pl/';
  HODLER_URL2: string = 'https://hodlerstream.net/';
  HODLER_ETH: string = 'https://hodler2.nq.pl/';
  HODLER_ETH2: string = 'https://hodlernode.net/';
  API_PUB = {$I 'public_key.key' };
  API_PRIV = {$I 'private_key.key' };

resourcestring
  CURRENT_VERSION = '0.4.1';

var
  AccountsNames: array of AccountItem;
  //LoadedAccount : TObjectDictionary< AnsiString , Account>;
  LoadedAccounts : TObjectDictionary<String,Account>;
  dashBoardFontSize: integer =
{$IF (DEFINED(MSWINDOWS) OR DEFINED(LINUX))}14{$ELSE}14{$ENDIF};
  TCAIterations: integer;
  userSavedSeed: boolean;
  saveSeedInfoShowed: boolean = false;
  test: AnsiString;
  globalFiat: single;
  lastChose: integer;
  lastView: TTabItem;
  isTokenDataInUse: boolean = false;
  i: integer;
  lastHistCC: integer;
  HOME_PATH: AnsiString;
  HOME_TABITEM: TTabItem;
  SYSTEM_NAME: AnsiString;
  USER_ALLOW_TO_SEND_DATA: boolean;
  cutAddressEveryNChar: integer = -1;
  addressFromQR: AnsiString;
  amountFromQR: AnsiString;
  newCoinListNextTabItem: TTabItem;
  backTabItem: TTabItem;
  WDToExportPrivKey: TWalletInfo;
  AddCoinBackTabItem: TTabItem;
  createPasswordBackTabItem: TTabItem;
  RestoreFromFileBackTabItem: TTabItem;
  SelectGenerateCoinViewBackTabItem: TTabItem;
  chooseETHWalletBackTabItem: TTabItem;
  QRMask: TBitmap;

  newcoinID: nativeint;
  ImportCoinID: integer;
  newTokenID: integer;
  AccountForSearchToken: Account;
  ResourceMenager: AssetsMenager;

  globalLoadCacheTime: Double = 0;
  globalVerifyKeypoolTime: Double = 0;
  HistoryPanelPool: TComponentPool<ThistoryPanel>;

implementation

uses Bitcoin, uHome, base58, Ethereum, coinData, strutils, secp256k1,
  AccountRelated, TImageTextButtonData, KeyPoolRelated, Nano
{$IFDEF ANDROID}
{$ELSE}
{$ENDIF};

var
  bitmapData: TBitmapData;

function LowOrderBitSet(Value: integer): boolean;
begin
  Result := ((Value and 1) > 0);
end;

procedure clearSendCache();
var
  FilePath: AnsiString;
  ts: TStringList;
  arr: TJsonArray;
  obj: TJsonObject;
  val: TJsonValue;
  exist: boolean;
  coinid, x: integer;
  i: integer;
begin
  // {$IFDEF ANDROID}

  FilePath := tpath.Combine(CurrentAccount.DirPath, 'SendCache.dat');

  ts := TStringList.Create();
  if FileExists(FilePath) then
    ts.LoadFromFile(FilePath);

  arr := TJsonArray(TJsonObject.ParseJSONValue(ts.Text));

  exist := false;
  i := 0;
  for val in arr do
  begin

    val.TryGetValue<integer>('coinID', coinid);

    val.TryGetValue<integer>('X', x);

    if (coinid = CurrentCoin.coin) and (x = CurrentCoin.x) then
    begin
      arr.Remove(i);
      break;
    end;

    i := i + 1;
  end;

  ts.Text := arr.ToString;

  ts.SaveToFile(FilePath);

  ts.Free;
  arr.Free();
  // {$ENDIF}
end;

procedure saveSendCacheToFile();
var
  FilePath: AnsiString;
  ts: TStringList;
  arr: TJsonArray;
  obj: TJsonObject;
  val: TJsonValue;
  exist: boolean;
  coinid, x: integer;
  i: integer;
begin
  // {$IFDEF ANDROID}
  FilePath := tpath.Combine(CurrentAccount.DirPath, 'SendCache.dat');

  ts := TStringList.Create();
  if FileExists(FilePath) then
  begin
    ts.LoadFromFile(FilePath);
    arr := TJsonArray(TJsonObject.ParseJSONValue(ts.Text));
  end
  else
  begin
    arr := TJsonArray.Create();
  end;

  exist := false;
  i := 0;

  if arr.Count > 0 then
    for val in arr do
    begin

      val.TryGetValue<integer>('coinID', coinid);

      val.TryGetValue<integer>('X', x);

      if (coinid = CurrentCoin.coin) and (x = CurrentCoin.x) then
      begin
        arr.Remove(i);
        break;
      end;

      i := i + 1;
    end;

  obj := TJsonObject.Create();

  obj.AddPair('coinID', intToStr(CurrentCoin.coin));
  obj.AddPair('X', intToStr(CurrentCoin.x));
  obj.AddPair('WVsendTO', frmhome.WVsendTO.Text);
  obj.AddPair('wvAmount', frmhome.wvAmount.Text);
  obj.AddPair('wvFee', frmhome.wvFee.Text);

  arr.AddElement(obj);

  ts.Text := arr.ToString;

  ts.SaveToFile(FilePath);

  ts.Free;
  arr.Free();
  // {$ENDIF}
end;

procedure loadSendCacheFromFile();
var
  FilePath: AnsiString;
  ts: TStringList;
  arr: TJsonArray;
  obj: TJsonObject;
  val: TJsonValue;
  exist: boolean;
  coinid, x: integer;
  i: integer;
  temp: string;
begin
  // {$IFDEF ANDROID}
  try
    FilePath := tpath.Combine(CurrentAccount.DirPath, 'SendCache.dat');
    if not FileExists(FilePath) then
      exit();
    ts := TStringList.Create();

    ts.LoadFromFile(FilePath);

    arr := TJsonArray(TJsonObject.ParseJSONValue(ts.Text));

    for val in arr do
    begin

      val.TryGetValue<integer>('coinID', coinid);

      val.TryGetValue<integer>('X', x);

      if (coinid = CurrentCoin.coin) and (x = CurrentCoin.x) then
      begin

        val.TryGetValue<string>('WVsendTO', temp);
        frmhome.WVsendTO.Text := temp;
        val.TryGetValue<string>('wvAmount', temp);
        frmhome.wvAmount.Text := temp;
        val.TryGetValue<string>('wvFee', temp);
        frmhome.wvFee.Text := temp;

        break;
      end;

    end;

    ts.Free;
    ts := nil;
    arr.Free();
    arr := nil;
  except
    on E: Exception do
    begin
      if ts <> nil then
        ts.Free;
      if arr <> nil then
        arr.Free();
    end;
  end;

  // {$ENDIF}

end;

function TSecureRandoms.CheckSecureRandom(const random: ISecureRandom): boolean;
begin
  Result := true = RunChiSquaredTests(random);

end;

function TSecureRandoms.MeasureChiSquared(const random: ISecureRandom;
  rounds: Int32): Double;
var
  opts, bs: TCryptoLibByteArray;
  counts: TCryptoLibInt32Array;
  i, b, total, k, mask, shift: Int32;
  chi2, diff, diff2, temp: Double;
begin
  opts := random.GenerateSeed(2);
  System.SetLength(counts, 256);
  System.SetLength(bs, 256);

  i := 0;
  while i < rounds do
  begin
    random.NextBytes(bs);

    for b := 0 to System.Pred(256) do
    begin

      counts[bs[b]] := counts[bs[b]] + 1;

    end;

    System.Inc(i);
  end;

  mask := opts[0];

  i := 0;
  while i < rounds do
  begin
    random.NextBytes(bs);

    for b := 0 to System.Pred(256) do
    begin

      counts[bs[b] xor Byte(mask)] := counts[bs[b] xor Byte(mask)] + 1;

    end;
    System.Inc(mask);
    System.Inc(i);
  end;

  shift := opts[1];

  i := 0;
  while i < rounds do
  begin
    random.NextBytes(bs);

    for b := 0 to System.Pred(256) do
    begin

      counts[Byte(bs[b] + Byte(shift))] :=
        counts[Byte(bs[b] + Byte(shift))] + 1;

    end;
    System.Inc(shift);
    System.Inc(i);
  end;

  total := 3 * rounds;

  chi2 := 0;

  for k := 0 to System.Pred(System.Length(counts)) do
  begin
    temp := counts[k];
    diff := temp - total;
    diff2 := diff * diff;

    chi2 := chi2 + diff2;
  end;

  chi2 := chi2 / total;

  Result := chi2;
end;

function TSecureRandoms.RunChiSquaredTests(const random: ISecureRandom)
  : boolean;
var
  passes, tries: Int32;
  chi2: Double;
begin
  passes := 0;

  tries := 0;
  while tries < 100 do
  begin
    chi2 := MeasureChiSquared(random, 1000);

    // 255 degrees of freedom in test => Q ~ 10.0% for 285
    if (chi2 < 285.0) then
    begin
      System.Inc(passes);
    end;

    System.Inc(tries);
  end;

  Result := passes > 75;
end;

function TSecureRandoms.GetSha256Prng: string;
var
  &random: ISecureRandom;
begin
  random := TSecureRandom.GetInstance('SHA256PRNG');
  Result := ToHex(random.GenerateSeed(256), 256);

end;

function ISecureRandomBuffer: AnsiString;
var
  SecureRandoms: TSecureRandoms;
begin
  SecureRandoms := TSecureRandoms.Create();
  Result := misc.GetStrHashSHA256(SecureRandoms.GetSha256Prng);
  SecureRandoms.Free;
end;
/// ////////////////////////////////////////////////////////////////

function compareVersion(a, b: AnsiString): integer;
var
  a_arr, b_arr: TStringList;

begin
  Result := 0;
  a_arr := SplitString(a, '.');
  b_arr := SplitString(b, '.');

  for i := 0 to min(a_arr.Count, b_arr.Count) - 1 do
  begin
    if StrToInt(a_arr[i]) > StrToInt(b_arr[i]) then
    begin
      Result := 1;
      break;
    end;
    if StrToInt(a_arr[i]) < StrToInt(b_arr[i]) then
    begin
      Result := -1;
      break;
    end;

  end;

  a_arr.DisposeOf;
  a_arr := nil;

  b_arr.DisposeOf;
  b_arr := nil;

end;

function getComponentsWithTagString(tag: AnsiString; From: TfmxObject)
  : TArray<TfmxObject>;
var
  fmxObj: TfmxObject;
  tmp: TArray<TfmxObject>;
begin

  Result := [];
  if From.ChildrenCount <> 0 then

    for fmxObj in From.Children do
    begin
      if fmxObj.TagString = tag then
        Result := Result + [fmxObj];

      tmp := getComponentsWithTagString(tag, fmxObj);
      if Length(tmp) <> 0 then

        Result := Result + tmp;

    end;

end;

function getUnusedAccountName(): AnsiString;
var
  i, nr: integer;
  found: boolean;
  r: string;
begin
  found := false;
  nr := 1;
  while not found do
  begin
    found := true;
    for i := 0 to Length(AccountsNames) - 1 do
    begin
      r := 'Wallet' + intToStr(nr);
      if string(AccountsNames[i].name) = (r) then
      begin
        nr := nr + 1;
        found := false;
      end;

    end;

  end;
  Result := 'Wallet' + intToStr(nr);
end;

function getFirstUnusedXForCoin(id: integer): integer;
var
  arr: Array of integer;
  wd: TWalletInfo;
  flagElse, sorted: boolean;
  i, j: integer;
  debugString: AnsiString;
begin
  i := 0;
  SetLength(arr, CurrentAccount.countWalletBy(id));
  for wd in CurrentAccount.myCoins do
  begin
    if wd.x = -1 then
      continue;
    { if wd.coin = newcoinID then
      begin
      arr[i] := wd.X;
      inc(i);
      end; }
    if wd.coin = id then
    begin
      flagElse := true;

      for j := 0 to i - 1 do
      begin

        if arr[j] = wd.x then
          flagElse := false;

      end;
      if flagElse then
      begin
        arr[i] := wd.x;
        Inc(i);
      end;

    end;
  end;
  SetLength(arr, i);
  sorted := false;
  while not sorted do
  begin
    sorted := true;
    for i := 0 to Length(arr) - 2 do
    begin

      if arr[i] > arr[i + 1] then
      begin

        j := arr[i];
        arr[i] := arr[i + 1];
        arr[i + 1] := j;
        sorted := false;
      end;

    end;

  end;

  Result := Length(arr);
  for i := 0 to Length(arr) - 1 do
  begin
    if arr[i] <> i then
    begin
      Result := i;
      break;
    end;
  end;
end;

procedure createTransactionWalletList(arr: TIntegerArray);
var
  i, j: integer;
  panel: TPanel;
  child: TfmxObject;
  temp: TfmxObject;
  existIN: boolean;

begin

  clearVertScrollBox(frmhome.WalletTransactionVertScrollBox);

  for i := 0 to frmhome.walletList.Content.ChildrenCount - 1 do
  begin
    if not(TfmxObject(frmhome.walletList.Content.Children[i])
      .TagObject is TWalletInfo) then
      continue;

    existIN := false;
    for j := 0 to Length(arr) - 1 do
    begin
      if arr[j] = TWalletInfo(TfmxObject(frmhome.walletList.Content.Children[i])
        .TagObject).coin then
      begin
        existIN := true;
        break;
      end;

    end;

    if existIN then
    begin

      panel := TPanel.Create(frmhome.WalletTransactionVertScrollBox);
      panel.parent := frmhome.WalletTransactionVertScrollBox;
      panel.Visible := true;
      panel.EnableD := true;
      panel.Align := TAlignLayout.top;
      panel.Height := 48;
      panel.TagObject := frmhome.walletList.Content.Children[i].TagObject;
      panel.OnClick := frmhome.TransactionWalletListClick;

      for child in frmhome.walletList.Content.Children[i].Children do
      begin

        temp := child.Clone(panel);
        temp.parent := panel;

      end;

    end;
  end;

  if frmhome.WalletTransactionVertScrollBox.Content.ChildrenCount = 1 then
  begin
    frmhome.TransactionWalletListClick
      (frmhome.WalletTransactionVertScrollBox.Content.Children[0]);
  end
  else
    switchTab(frmhome.pageControl, frmhome.WalletTransactionListTabItem);

end;

function getCoinsIDFromAddress(address: AnsiString): TIntegerArray;
var
  i, j: integer;
  existIN: boolean;
begin
  address := removeSpace(address);
  if ContainsStr(address, ':') then
  begin
    address := RightStr(address, Length(address) - Pos(':', address));
  end;

  Result := [];
  for i := 0 to Length(availableCoin) - 1 do
  begin
    existIN := false;
    for j := low(address) to high(availableCoin[i].availableFirstLetter) do
    begin
      if lowercase(address[low(address)])
        = lowercase(availableCoin[i].availableFirstLetter[j]) then
      begin
        existIN := true;
      end

    end;

    try
      if existIN and isValidForCoin(i, address) then
      begin
        Result := Result + [i];
      end;
    except
      on E: Exception do
    end;

  end;
end;

procedure createSelectGenerateCoinView();
var
  i: integer;
  panel: TPanel;
  checkBox: TCheckBox;
  image: TImage;
  lbl: TLabel;
begin

  SelectGenerateCoinViewBackTabItem := frmhome.pageControl.ActiveTab;

  if frmhome.GenerateCoinVertScrollBox.Content.ChildrenCount <> 0 then
  begin

    for i := 0 to frmhome.GenerateCoinVertScrollBox.Content.ChildrenCount - 1 do
    begin

      TCheckBox(TPanel(frmhome.GenerateCoinVertScrollBox.Content.Children[i])
        .TagObject).IsChecked :=
        not TCheckBox(TPanel(frmhome.GenerateCoinVertScrollBox.Content.Children
        [i]).TagObject).EnableD;
    end;

    exit;

  end;

  for i := 0 to Length(availableCoin) - 1 do
  begin

    panel := TPanel.Create(frmhome.GenerateCoinVertScrollBox);
    panel.parent := frmhome.GenerateCoinVertScrollBox;
    panel.Align := TAlignLayout.top;
    panel.Height := 48;
    panel.Visible := true;
    panel.OnClick := frmhome.PanelSelectGenerateCoinOnClick;
    panel.tag := i;

    lbl := TLabel.Create(panel);
    lbl.parent := panel;
    lbl.Visible := true;
    lbl.Align := TAlignLayout.Client;
    lbl.Text := availableCoin[i].Displayname;

    checkBox := TCheckBox.Create(panel);
    checkBox.parent := panel;
    checkBox.Visible := true;
    checkBox.Align := TAlignLayout.MostLeft;
    checkBox.Width := 15;
    checkBox.Margins.Left := 15;
    if availableCoin[i].shortcut = 'BTC' then
    begin
      checkBox.EnableD := false;
      checkBox.IsChecked := true;
      checkBox.Lock;
    end;

    panel.TagObject := checkBox;

    image := TImage.Create(panel);
    image.parent := panel;
    image.Visible := true;
    image.Bitmap.LoadFromStream(getCoinIconResource(i));
    image.Align := TAlignLayout.Left;
    image.Margins.Left := 0;
    image.Margins.Right := 0;
    image.Margins.top := 8;
    image.Margins.Bottom := 8;
    image.Width := 15 + (48 - 8 * 2) + 15;

  end;

  for i := 0 to Length(Token.availableToken) - 1 do
  begin

    if Token.availableToken[i].address = '' then
      continue;

    panel := TPanel.Create(frmhome.GenerateCoinVertScrollBox);
    panel.parent := frmhome.GenerateCoinVertScrollBox;
    panel.Align := TAlignLayout.top;
    panel.Height := 48;
    panel.Visible := true;
    panel.OnClick := frmhome.PanelSelectGenerateCoinOnClick;
    panel.tag := i + 10000;

    lbl := TLabel.Create(panel);
    lbl.parent := panel;
    lbl.Visible := true;
    lbl.Align := TAlignLayout.Client;
    lbl.Text := Token.availableToken[i].name;

    checkBox := TCheckBox.Create(panel);
    checkBox.parent := panel;
    checkBox.Visible := true;
    checkBox.Align := TAlignLayout.MostLeft;
    checkBox.Margins.Left := 15;
    checkBox.Width := 15;
    panel.TagObject := checkBox;

    image := TImage.Create(panel);
    image.parent := panel;
    image.Visible := true;

    image.Bitmap.LoadFromStream
      (ResourceMenager.getAssets(Token.availableToken[i].resourcename));
    image.Align := TAlignLayout.Left;
    image.Margins.Left := 0;
    image.Margins.Right := 0;
    image.Margins.top := 8;
    image.Margins.Bottom := 8;
    image.Width := 15 + (48 - 8 * 2) + 15;

  end;

end;

procedure AskForBackup(delay: integer = 0; afterChange: boolean = false);
begin
  Tthread.CreateAnonymousThread(

    procedure
    var
      msg: AnsiString;
    begin

      if afterChange then
        msg := dictionary('CreateBackupAfterChange')
      else
        msg := dictionary('CreateBackupWallet');
      sleep(delay);

      Tthread.Synchronize(nil,
        procedure
        begin

          with frmhome do
            frmhome.NotificationLayout.popupConfirm(
              procedure()
              begin

                btnDecryptSeed.OnClick := SendWalletFile;

                decryptSeedBackTabItem := pageControl.ActiveTab;
                pageControl.ActiveTab := descryptSeed;
                btnDSBack.OnClick := backBtnDecryptSeed;
              end,
              procedure()
              begin

              end, msg, dictionary('Yes'), dictionary('NotNow'), 1);
        end);
    end).start;
end;

function elevateCheckPermission(name: string): integer;
var
  Os: TOSVersion;

begin
{$IFDEF ANDROID}
  if Os.major < 6 then
  begin
    Result := 0;
    exit;
  end;

  Result := TAndroidHelper.context.checkCallingOrSelfPermission
    (StringToJString(name));
{$ENDIF}
end;

procedure EnlargeQRCode(img: TBitmap);
begin
{$IF DEFINED(ANDROID) OR DEFINED(IOS)}
  with frmhome do
  begin
    BigQRCodeBackTab := pageControl.ActiveTab;
    pageControl.ActiveTab := BigQRCode;
    BigQRCodeImage.Bitmap.Assign(img);

  end;

{$ENDIF}
end;

procedure LoadStyle(name: AnsiString);
var
  i: integer;
  fmxObj: TfmxObject;
  tmp: TArray<TfmxObject>;
var
  Stream: TResourceStream;
begin

{$IFDEF IOS}
  exit;
{$ENDIF}
  if name = 'RT_DARK' then
    frmhome.StatusBarFixer.Fill.Color := TAlphaColorRec.Black
  else
    frmhome.StatusBarFixer.Fill.Color := TAlphaColorRec.Whitesmoke;
{$IFDEF IOS}
  name := name + '_IOS';
{$ENDIF}
  currentStyle := name;
  {$IFDEF LINUX}
   stylo.TrySetStyleFromResource('RT_DARK_LINUX');
  {$ELSE}
  stylo.TrySetStyleFromResource('RT_DARK');
{$ENDIF}
  tmp := getComponentsWithTagString('copy_image', frmhome);
  if Length(tmp) <> 0 then
    for fmxObj in tmp do
    begin

      Stream := TResourceStream.Create(HInstance,
        'COPY_IMG_' + RightStr(currentStyle, Length(currentStyle) - 3),
        RT_RCDATA);
      try
        // showmessage( RightStr( CurrentStyle , length(CurrentStyle)-3 ) );
        TImage(fmxObj).Bitmap.LoadFromStream(Stream);

      finally
        Stream.Free;
      end;

    end;

  for fmxObj in frmhome.EncrypredQRBackupLayout.Children do
  begin
    if fmxObj.TagString = 'encrypted_qr_image' then
    begin

      Stream := TResourceStream.Create(HInstance,
        'ENCRYPTED_SEED_' + RightStr(currentStyle, Length(currentStyle) - 3),
        RT_RCDATA);
      try
        // showmessage( RightStr( CurrentStyle , length(CurrentStyle)-3 ) );
        TimagetextButton(fmxObj).img.Bitmap.LoadFromStream(Stream);

      finally
        Stream.Free;
      end;

    end;

  end;
  for fmxObj in frmhome.HSBbackupLayout.Children do
  begin
    if fmxObj.TagString = 'hodler_secure_backup_image' then
    begin

      Stream := TResourceStream.Create(HInstance,
        'HSB_' + RightStr(currentStyle, Length(currentStyle) - 3), RT_RCDATA);
      try
        // showmessage( RightStr( CurrentStyle , length(CurrentStyle)-3 ) );
        TimagetextButton(fmxObj).img.Bitmap.LoadFromStream(Stream);

      finally
        Stream.Free;
      end;

    end;

  end;

  if RightStr(currentStyle, Length(currentStyle) - 3) = 'DARK' then
  begin

    frmhome.SearchInDashBrdImage.Visible := true;

{$IF DEFINED(ANDROID) OR DEFINED(OIS)}
    frmhome.MoreImage.Visible := true;
{$ENDIF}
    frmhome.SearchInDashBrdImage.Bitmap.LoadFromStream
      (ResourceMenager.getAssets('SEARCH_' + RightStr(currentStyle,
      Length(currentStyle) - 3)));
{$IF DEFINED(ANDROID) OR DEFINED(OIS)}
    frmhome.MoreImage.Bitmap.LoadFromStream
      (ResourceMenager.getAssets('MORE_' + RightStr(currentStyle,
      Length(currentStyle) - 3)));
{$ENDIF}
  end
  else
  begin
    frmhome.SearchInDashBrdImage.Visible := false;
{$IF DEFINED(ANDROID) OR DEFINED(OIS)}
    frmhome.MoreImage.Visible := false;
{$ENDIF}
  end;

end;

procedure DeleteAccount(name: AnsiString);
var
  ac: Account;
  path: AnsiString;
  ts: TStringList;
  tempStr: AnsiString;
  i, j: integer;
begin
  refreshWalletDat;
  ac := Account.Create(name);
  // ts := TStringList.Create();

  for path in ac.Paths do
  begin
    ts := TStringList.Create;
    try
      ts.LoadFromFile(path);
      ts.Text := StringofChar('@', Length(ts.Text));
      ts.SaveToFile(path);
    finally
      DeleteFile(path);
      ts.Free;
    end;
  end;

  RemoveDir(ac.DirPath);

  for i := 0 to Length(AccountsNames) - 1 do
  begin

    if AccountsNames[i].name = name then
    begin
      delete(AccountsNames, i, 1);
      break;
    end;
  end;
  ac.Free;
  refreshWalletDat;
end;

procedure prepareConfirmSendTabItem();
var
  MasterSeed, tced, address: AnsiString;
var
  amount, fee, tempFee: BigInteger;
var
  CashAddr: AnsiString;
begin
  with frmhome do
  begin

    ConfirmSendPasswordPanel.Visible := true;
    SendTransactionButton.Visible := true;
    ConfirmSendClaimCoinButton.Visible := false;

    BCHSVBCHABCReplayProtectionLabel.Visible :=
      ((CurrentCoin.coin = 3) or (CurrentCoin.coin = 7));

    if not isEthereum then
    begin
      fee := StrFloatToBigInteger(wvFee.Text, availableCoin[CurrentCoin.coin]
        .decimals);
      if CurrentCoin.coin = 8 then
        fee := 0;
      tempFee := fee;
    end
    else
    begin

      fee := BigInteger.Parse(wvFee.Text);

      if isTokenTransfer then
        tempFee := BigInteger.Parse(wvFee.Text) * 66666
      else
        tempFee := BigInteger.Parse(wvFee.Text) * 21000;
    end;

    if (not isTokenTransfer) then
    begin
      amount := StrFloatToBigInteger(wvAmount.Text,
        availableCoin[CurrentCoin.coin].decimals);
      if FeeFromAmountSwitch.IsChecked then
      begin
        amount := amount - tempFee;
      end;

    end;

    if (isEthereum) and (isTokenTransfer) then
      amount := StrFloatToBigInteger(wvAmount.Text,
        CurrentCryptoCurrency.decimals);
    if (not isTokenTransfer) then
      if amount + tempFee > (CurrentAccount.aggregateBalances(CurrentCoin)
        .confirmed) then
      begin
        raise Exception.Create(dictionary('AmountExceed'));
        exit;
      end;
    if ((amount) = 0) or (((fee) = 0) and (CurrentCoin.coin <> 8)) then
    begin

      raise Exception.Create(dictionary('InvalidValues'));

      exit;
    end;

    address := removeSpace(WVsendTO.Text);

    if (CurrentCryptoCurrency is TWalletInfo) and
      (TWalletInfo(CurrentCryptoCurrency).coin in [3, 7]) then
    begin
      CashAddr := StringReplace(lowercase(address), 'bitcoincash:', '',
        [rfReplaceAll]);
      if (LeftStr(CashAddr, 1) = 'q') or (LeftStr(CashAddr, 1) = 'p') then
      begin
        try
          address := BCHCashAddrToLegacyAddr(address);
        except
          on E: Exception do
          begin
            showmessage('Wrong bech32 address');
            exit;
          end;
        end;
      end;
    end;
    // sendCoinsTO(CurrentCoin, Address, amount, fee, MasterSeed,
    // AvailableCoin[CurrentCoin.coin].name)
    SendFromLabel.Text := CurrentCoin.addr;
    SendToLabel.Text := address;
    if ((CurrentCryptoCurrency is TWalletInfo) and
      (TWalletInfo(CurrentCryptoCurrency).coin in [3, 7])) then
    begin
      CashAddr := StringReplace(lowercase(removeSpace(WVsendTO.Text)),
        'bitcoincash:', '', [rfReplaceAll]);
      if (LeftStr(CashAddr, 1) = 'q') or (LeftStr(CashAddr, 1) = 'p') then
      begin
        SendToLabel.Text := bitcoinCashAddressToCashAddress(address);
      end;
    end;

    SendValueLabel.Text :=
      floatToStrF(CurrencyConverter.calculate
      (strToFloat(BigIntegerToFloatStr(amount, CurrentCryptoCurrency.decimals))
      * CurrentCryptoCurrency.rate), ffFixed, 15, 2) + ' ' +
      frmhome.CurrencyConverter.symbol + ' ' + '(' + BigIntegerToFloatStr
      (amount, CurrentCryptoCurrency.decimals) + ')';

    if (CurrentCoin.coin = 4) and (CurrentCryptoCurrency is Token) then
    begin
      WaitTimeLabel.Text :=
        'The transaction may get stuck because of the low bandwidth of the ethereum network';

      sendFeeLabel.Text := AnsiReverseString
        (cutEveryNChar(3, AnsiReverseString(fee.ToString))) + ' WEI';
    end
    else if (CurrentCoin.coin = 4) then
    begin
      WaitTimeLabel.Text :=
        'The transaction may get stuck because of the low bandwidth of the ethereum network';

      sendFeeLabel.Text := AnsiReverseString
        (cutEveryNChar(3, AnsiReverseString(fee.ToString))) + ' WEI';
    end
    else
    begin
      if CurrentCoin.coin = 8 then
      begin
        sendFeeLabel.Visible := false;
        WaitTimeLabel.Text :=
          'This transaction must be mined, please be patient and do not close the application';
      end
      else
      begin
        if AutomaticFeeRadio.IsChecked then
        begin
          sendFeeLabel.Visible := true;
          WaitTimeLabel.Text := 'The transaction should be confirmed in the ' +
            intToStr(Round(FeeSpin.Value)) + ' nearest blocks, in about ' +
            intToStr(Round(FeeSpin.Value)) + '0 minutes';
        end
        else
        begin
          WaitTimeLabel.Text := 'Fee set by the user';
        end;
      end;
      sendFeeLabel.Text := BigIntegerToFloatStr(fee,
        CurrentCryptoCurrency.decimals);

    end;

  end;
end;

function getDataFromForeginAPI(aURL: String): AnsiString;
var
  req: THTTPClient;
  LResponse: IHTTPResponse;
begin

  try
    req := THTTPClient.Create();
    LResponse := req.get(aURL);
    Result := LResponse.ContentAsString();
  except
    on E: Exception do
      Result := '';
  end;
  req.Free;
end;

function searchTokens(InAddress: AnsiString; ac: Account = nil): integer;
var
  data: AnsiString;
  JsonValue: TJsonValue;
  JsonTokens: TJsonArray;
  JsonIt: TJsonValue;
  T: Token;
  address, name, decimals, symbol, balance: AnsiString;
  i: integer;
  createToken: boolean;
  createFromList: boolean;
  CreateFromListIndex: integer;
  added: integer;

  panel: TPanel;
  img: TImage;
  NameLbl, valuelbl: TLabel;
  checkBox: TCheckBox;
begin
  added := 0;
  if ac = nil then
  begin
    if CurrentAccount = nil then
    begin
      raise Exception.Create('account nilptr error');
    end
    else
    begin
      ac := CurrentAccount;
    end;
  end;
  clearVertScrollBox(frmhome.FoundTokenVertScrollBox);
  AccountForSearchToken := ac;

  data := getDataOverHTTP('https://api.ethplorer.io/getAddressInfo/' + InAddress
    + '?apiKey=freekey');
  JsonValue := TJsonObject.ParseJSONValue(data);

  if JsonValue is TJsonObject then
  begin
    if JsonValue.TryGetValue<TJsonArray>('tokens', JsonTokens) then
      for JsonIt in JsonTokens do
      begin

        address := JsonIt.GetValue<string>('tokenInfo.address');
        decimals := JsonIt.GetValue<string>('tokenInfo.decimals');

        try
          name := JsonIt.GetValue<string>('tokenInfo.name');
        except
          on E: Exception do
          begin
            name := '';
            showmessage('Load Token Name Error ' + E.message);
          end;
        end;

        try
          symbol := JsonIt.GetValue<string>('tokenInfo.symbol');
        except
          on E: Exception do
          begin
            symbol := '';
            showmessage('Load Token Symbol Error ' + E.message);
          end;
        end;
        // balance
        try
          balance := JsonIt.GetValue<string>('balance');
        except
          on E: Exception do
          begin
            balance := '0';
            showmessage('Load Token Balance Error ' + E.message);
          end;
        end;

        createToken := true;
        for i := 0 to Length(ac.myTokens) - 1 do
        begin
          if (AnsiLowerCase(ac.myTokens[i].addr) = AnsiLowerCase(InAddress)) and
            (AnsiLowerCase(ac.myTokens[i]._contractAddress)
            = AnsiLowerCase(address)) then
          begin
            createToken := false;
            break;
          end;
        end;

        if createToken then
        begin
          Inc(added);
          createFromList := false;
          for i := 0 to Length(Token.availableToken) - 1 do
          begin
            if AnsiLowerCase(Token.availableToken[i].address)
              = AnsiLowerCase(address) then
            begin
              createFromList := true;
              CreateFromListIndex := i;
              break;

            end;

          end;

          if createFromList then
          begin
            T := Token.Create(CreateFromListIndex, InAddress);
          end
          else
          begin
            T := Token.CreateCustom(address, name, symbol,
              StrToIntDef(decimals, 0), InAddress);
          end;

          panel := TPanel.Create(frmhome.FoundTokenVertScrollBox);
          panel.parent := frmhome.FoundTokenVertScrollBox;
          panel.Visible := true;
          panel.Height := 48;
          panel.Align := TAlignLayout.top;
          panel.OnClick := frmhome.FoundTokenPanelOnClick;

          img := TImage.Create(panel);
          img.parent := panel;
          img.Visible := true;
          img.Align := TAlignLayout.Left;
          img.Width := 64;
          img.Bitmap.LoadFromStream(T.getIconResource);
          img.Margins.top := 8;
          img.Margins.Bottom := 8;
          img.HitTest := false;

          NameLbl := TLabel.Create(panel);
          NameLbl.Align := TAlignLayout.Client;
          NameLbl.Visible := true;
          NameLbl.parent := panel;
          NameLbl.Text := name;

          valuelbl := TLabel.Create(panel);
          valuelbl.parent := panel;
          valuelbl.Align := TAlignLayout.Client;
          valuelbl.Visible := true;
          // floatToStrF(crypto.getFiat, ffFixed, 15, 2)
          valuelbl.Text := BigIntegerBeautifulStr
            (BigInteger.Create(strToFloat(balance)), T.decimals);
          valuelbl.TextSettings.HorzAlign := TTextAlign.Trailing;
          valuelbl.Margins.Right := 15;

          checkBox := TCheckBox.Create(panel);
          checkBox.parent := panel;
          checkBox.Align := TAlignLayout.MostLeft;
          // checkBox.Margins.Right := 10;
          checkBox.Margins.Left := 15;
          checkBox.Visible := true;
          checkBox.IsChecked := true;
          checkBox.Width := 15;

          panel.TagObject := checkBox;
          checkBox.TagObject := T;
{$IFDEF ANDROID}
          checkBox.TagObject.__ObjAddRef();
{$ENDIF}
          {
            T.idInWallet := Length(ac.myTokens) + 10000;

            ac.addToken(T);
            ac.SaveFiles();
            if ac = CurrentAccount then
            CreatePanel(T); }

        end;

      end;

  end;
  Result := added;
end;

function isValidETHAddress(address: AnsiString): boolean;
begin
  Result := address = getETHValidAddress(address);
end;

function getETHValidAddress(address: AnsiString): AnsiString;
var
  hex: AnsiString;
  ans: AnsiString;
  addr: AnsiString;
begin

  addr := RightStr(address, Length(address) - 2); // '0x'
  hex := keccak256String(lowercase(addr));
  ans := '0x';

  for i := low(addr) to high(addr) do
  begin

    if StrToIntDef('$' + hex[i], 0) > 7 then
      ans := ans + UpperCase(addr[i])
    else
      ans := ans + lowercase(addr[i]);

  end;
  Result := ans;
end;

procedure AddAccountToFile(ac: Account);
begin

  ac.SaveFiles();

  SetLength(AccountsNames, Length(AccountsNames) + 1);
  AccountsNames[Length(AccountsNames) - 1].name := ac.name;
  AccountsNames[Length(AccountsNames) - 1].order := Length(AccountsNames) - 1;
  refreshWalletDat;

end;

Procedure CreateNewAccountAndSave(name, pass, seed: AnsiString;
userSaveSeed: boolean);
var
  thr: Tthread;
begin

  thr := Tthread.CreateAnonymousThread(
    procedure
    var
      ac: Account;
    begin
      ac := CreateNewAccount(name, pass, seed);
      ac.userSaveSeed := userSaveSeed;

      Tthread.Synchronize(nil,
        procedure
        begin
          frmhome.HideZeroWalletsCheckBox.IsChecked := false;
        end);
      AddAccountToFile(ac);

      ac.Free;

      Tthread.Synchronize(nil,
        procedure
        begin

          AccountRelated.LoadCurrentAccount(name);
          AccountRelated.afterInitialize;
        end);
      startFullfillingKeypool(seed);
      wipeAnsiString(seed);
    end);

  thr.start;

end;

function CreateNewAccount(name, pass, seed: AnsiString): Account;
var
  ac: Account;
begin
  ac := Account.Create(name);

  ac.TCAIterations := TCAIterations;
  ac.EncryptedMasterSeed := speckEncrypt((TCA(pass)), seed);
  ac.userSaveSeed := false;
  ac.privTCA := false; // not frmHome.notPrivTCA1.isChecked;
  GenetareCoinsData(seed, pass, ac);
  Result := ac;
end;

procedure setBlackBackground(Owner: TComponent);
var
  bg: TRectangle;
begin
  exit;
  bg := TRectangle.Create(Owner);
  bg.parent := TfmxObject(Owner);
  bg.Align := TAlignLayout.Client;
  bg.Fill.Color := TAlphaColors.Black;
  bg.Stroke.Color := TAlphaColors.Black;
  bg.Fill.Kind := TBrushKind.Solid;
  bg.SendToBack;
  bg.Visible := true;
  TControl(Owner).Children.Items[bg.Index].SendToBack;
  // bg.Index
end;

procedure CreatePanel(crypto: cryptoCurrency; FromAccount: Account;
inBox: TVertScrollBox);
var
  panel: TPanel;
  coinName: TLabel;
  balLabel: TLabel;
  adrLabel: TLabel;
  coinIMG: TImage;
  price: TLabel;
  ccEmpty: boolean;
  tempBalances: TBalances;

begin

  if crypto is TWalletInfo then
  begin

    if TWalletInfo(crypto).coin = 4 then
    begin

      ccEmpty := (crypto.confirmed > 0);

    end
    else
    begin
      tempBalances := FromAccount.aggregateBalances(TWalletInfo(crypto));
      ccEmpty := (tempBalances.confirmed > 0);

    end;

  end
  else
  begin

    ccEmpty := (crypto.confirmed > 0);
  end;

  with frmhome.walletList do
  begin

    panel := TPanel.Create(inBox);
    panel.Align := panel.Align.alTop;
    panel.Height := 48;
    panel.parent := inBox;
    panel.TagObject := crypto;
    setBlackBackground(panel);
    panel.Position.Y := crypto.orderInWallet;
    panel.Opacity := 0;

    panel.Touch.InteractiveGestures := [TInteractiveGesture.LongTap];
    panel.OnGesture := frmhome.SwitchViewToOrganize;
{$IF DEFINED(ANDROID) OR DEFINED(IOS)}
    panel.OnTap := frmhome.OpenWalletView;
{$ELSE}
    panel.OnClick := frmhome.OpenWalletView;
{$ENDIF}
    adrLabel := TLabel.Create(panel);
    adrLabel.StyledSettings := adrLabel.StyledSettings - [TStyledSetting.size];
    adrLabel.TextSettings.Font.size := dashBoardFontSize;
    adrLabel.parent := panel;
    if crypto is TWalletInfo then
    begin
      adrLabel.Text := FromAccount.getDescription(TWalletInfo(crypto).coin,
        TWalletInfo(crypto).x);
    end
    else
    begin
      if crypto.description = '' then
      begin
        adrLabel.Text := crypto.name + ' (' + crypto.shortcut + ')';
      end
      else
        adrLabel.Text := crypto.description;
    end;

    adrLabel.AutoSize := false;
    adrLabel.Visible := true;
    adrLabel.TextSettings.WordWrap := false;
    adrLabel.Width :=
{$IF (DEFINED(MSWINDOWS) OR DEFINED(LINUX))}250{$ELSE}150{$ENDIF};
    adrLabel.Height := 48;
    adrLabel.Position.x := 52;
    adrLabel.Position.Y := 0;
    adrLabel.AutoSize := false;
    adrLabel.Visible := true;
    adrLabel.TextSettings.WordWrap := false;
    adrLabel.TagString := 'name';
    //
    balLabel := TLabel.Create(panel);
    balLabel.StyledSettings := balLabel.StyledSettings - [TStyledSetting.size];

    balLabel.parent := panel;
    if crypto.rate >= 0 then // rate >= 0 after first sync
    begin
      if crypto is TWalletInfo then
      begin
        balLabel.Text := BigIntegerBeautifulStr
          (FromAccount.aggregateBalances(TWalletInfo(crypto)).confirmed,
          crypto.decimals) + '    ' +
          floatToStrF(FromAccount.aggregateConfirmedFiats(TWalletInfo(crypto)),
          ffFixed, 15, 2) + ' ' + frmhome.CurrencyConverter.symbol;
      end
      else
      begin
        balLabel.Text := BigIntegerBeautifulStr(crypto.confirmed,
          crypto.decimals) + '    ' + floatToStrF(crypto.getFiat, ffFixed, 15,
          2) + ' ' + frmhome.CurrencyConverter.symbol;
      end;
    end
    else
    begin
      balLabel.Text := 'Syncing with network...';
    end;

    balLabel.TextSettings.HorzAlign := TTextAlign.Trailing;
    balLabel.Visible := true;
    balLabel.Width := 200;
    balLabel.Height := 48;
    balLabel.Align := TAlignLayout.FitRight;
    balLabel.TextSettings.Font.size := dashBoardFontSize;
    balLabel.Margins.Right := 15;
    balLabel.TagString := 'balance';
    //
    coinIMG := TImage.Create(panel);
    coinIMG.parent := panel;
    try
      if crypto is TWalletInfo then
        coinIMG.Bitmap.LoadFromStream
          (ResourceMenager.getAssets(availableCoin[TWalletInfo(crypto).coin]
          .resourcename)) // getCoinIcon(TWalletInfo(crypto).coin)
      else
        coinIMG.Bitmap.LoadFromStream(Token(crypto).getIconResource);
    except
      on E: Exception do
      begin
      end;
    end;
    // getCoinIcon(TWalletInfo(crypto).coin)
    if coinIMG.Bitmap <> nil then
    begin

      coinIMG.Height := 32.0;
      coinIMG.Width := 50;
    end;
    coinIMG.Position.x := 4;
    coinIMG.Position.Y := 8;
    //
    price := TLabel.Create(panel);
    price.parent := panel;
    price.Visible := true;
    if crypto.rate >= 0 then
      price.Text := floatToStrF(frmhome.CurrencyConverter.calculate
        (crypto.rate), ffFixed, 18, 2)
    else
      price.Text := 'Syncing with network...';
    price.Align := TAlignLayout.Bottom;
    price.Height := 16;
    price.TextSettings.HorzAlign := TTextAlign.Leading;
    price.Margins.Left := coinIMG.Width + 2;
    price.TagString := 'price';
    price.StyledSettings := balLabel.StyledSettings - [TStyledSetting.size];
    price.TextSettings.Font.size := 9;
    price.Margins.Bottom := 2;
    panel.Visible :=
      (ccEmpty or (not frmhome.HideZeroWalletsCheckBox.IsChecked));
    // panel.AnimateFloat('Opacity', 1, 2);
    panel.Opacity := 1;

  end;
end;

function inputType(input: TBitcoinOutput): integer;
begin
  if lowercase(Copy(input.ScriptPubKey, 0, 6)) = '76a914' then
    Result := 0;
  if lowercase(Copy(input.ScriptPubKey, 0, 4)) = 'a914' then
    Result := 1;
  if lowercase(Copy(input.ScriptPubKey, 0, 4)) = '0014' then
    Result := 2;
  if lowercase(Copy(input.ScriptPubKey, 0, 4)) = '0020' then
    Result := 3;
end;

function BCHCashAddrToLegacyAddr(address: AnsiString): AnsiString;
var
  bech: Bech32Data;
  intarr: TIntegerArray;
  hex, netbyte, r, s: AnsiString;
  tempInt: integer;
begin

  if lowercase(LeftStr(address, 12)) <> 'bitcoincash:' then
  begin
    address := 'bitcoincash:' + address;
  end;

  bech := decodeBCH(address);

  if bech.hrp = 'FAIL' then
    raise Exception.Create('BECH FAILRE');
  intarr := Copy(bech.values, 1, Length(bech.values) - 1);

  intarr := ChangeBits(bech.values, 5, 8);

  hex := '';
  for i := 0 to Length(intarr) - 7 do
  begin
    tempInt := intarr[i];
    hex := hex + IntToHex(Byte(tempInt));
  end;

  if Copy(hex, 0, 2) = '08' then
    netbyte := '05'
  else
    netbyte := '00';
{$IF DEFINED(ANDROID) OR DEFINED(IOS)}
  delete(hex, 1, 2);
{$ELSE}
  delete(hex, 1, 2);
{$ENDIF}
  s := netbyte + hex;
  r := GetSHA256FromHex(s);
  r := GetSHA256FromHex(r);
{$IF DEFINED(ANDROID) OR DEFINED(IOS)}
  s := s + Copy(r, 0, 8);
{$ELSE}
  s := s + Copy(r, 1, 8);
{$ENDIF}
  Result := Encode58(s);

end;

function bitcoinCashAddressToCashAddress(address: AnsiString;
showName: boolean = true): AnsiString;
var
  intarr: TIntegerArray;
  checksum: TIntegerArray;
  temparr: TIntegerArray;
  payload: TCharArray;
  c: AnsiChar;
  i: integer;
  adrInfo: TAddressInfo;
  tempStr: AnsiString;
begin

  adrInfo := decodeAddressInfo(address, 3);
  case adrInfo.scriptType of
    0:
      tempStr := '00' + adrInfo.Hash;
    1:
      tempStr := '08' + adrInfo.Hash;
  end;

  SetLength(intarr, Length(tempStr));
  i := 0;

  for c in tempStr do
  begin

    intarr[i] := StrToIntDef('$' + c, 0);
    Inc(i);

  end;

  intarr := ChangeBits(intarr, 4, 5);
  checksum := CreateChecksum8('bitcoincash', intarr);

  temparr := concat(intarr, checksum);
  if showName then
    Result := 'bitcoincash:' + bech32.rawencode(temparr)
  else
    Result := bech32.rawencode(temparr)

end;

procedure synchronizeCurrencyValue(data: AnsiString);
var

  ts: TStringList;
  line: AnsiString;
  pair: TStringList;
  symbol: AnsiString;
begin

  ts := TStringList.Create();
  try
    ts.Text := data;

    for line in ts do
    begin
      pair := SplitString(line);
      frmhome.CurrencyConverter.updateCurrencyRatio(pair[1],
        strToFloat(pair[0]));
      pair.Free;
    end;

  Except
    on E: Exception do
      showmessage('Currency converter Error');

  end;
  ts.Free;

  frmhome.CurrencyBox.Items.Clear;
  frmhome.WelcometabFiatPopupBox.Items.Clear;
  for symbol in frmhome.CurrencyConverter.availableCurrency.Keys do
  begin
    frmhome.CurrencyBox.Items.Add(symbol);
    frmhome.WelcometabFiatPopupBox.Items.Add(symbol);
  end;
  frmhome.CurrencyBox.ItemIndex := frmhome.CurrencyBox.Items.IndexOf
    (frmhome.CurrencyConverter.symbol);
  frmhome.WelcometabFiatPopupBox.ItemIndex := frmhome.CurrencyBox.Items.IndexOf
    (frmhome.CurrencyConverter.symbol);

  ts := TStringList.Create();

  for symbol in frmhome.CurrencyConverter.availableCurrency.Keys do
  begin
    data := floattoStr(frmhome.CurrencyConverter.availableCurrency[symbol]);
    data := data + ' ' + symbol;
    ts.Add(data);
  end;

  ts.SaveToFile(tpath.Combine(HOME_PATH, 'hodler.fiat.dat'));

  ts.Free;

end;

procedure LoadCurrencyFiatFromFile();
var
  pair, ts: TStringList;
  line: AnsiString;
begin
  ts := TStringList.Create();
  try

    ts.LoadFromFile(tpath.Combine(HOME_PATH, 'hodler.fiat.dat'));

    for line in ts do
    begin
      pair := SplitString(line);
      frmhome.CurrencyConverter.updateCurrencyRatio(pair[1],
        strToFloat(pair[0]));
      pair.Free;
    end;

  Except
    on E: Exception do
      showmessage('Currency converter Error');

  end;
  ts.Free;
end;

function isP2PKH(netbyte: AnsiString; coinid: integer): boolean;
begin
  Result := availableCoin[coinid].p2pk = netbyte;

end;

function isSegwitAddress(address: AnsiString): boolean;
begin
  Result := ((AnsiLeftStr(address, 3) = 'bc1') or
    (AnsiLeftStr(address, 4) = 'ltc1')) and (Length(address) > 39);
end;

function decodeAddressInfo(address: AnsiString; coinid: integer): TAddressInfo;
var
  addrHash: AnsiString;
  netbyte: AnsiString;
begin
  Result.scriptType := -1;
  if coinid = 4 then
    exit; // Ethereum doesnt need this
  if isSegwitAddress(address) = false then
  begin
    addrHash := Copy(decode58(address), 0, 42);
    netbyte := Copy(addrHash, 0, 2);
    delete(addrHash, 1, 2);
    Result.Hash := addrHash;
    if (netbyte <> coinData.availableCoin[coinid].p2sh) and
      (netbyte <> coinData.availableCoin[coinid].p2pk) then
      exit;
    if isP2PKH(netbyte, coinid) then
      Result.scriptType := 0
    else
      Result.scriptType := 1;
  end
  else
  begin
    Result := segwit_addr_decode(address);
    if Length(Result.Hash) = 40 then
      Result.scriptType := 2;
    if Length(Result.Hash) = 64 then
      Result.scriptType := 3;

  end;

  case Result.scriptType of
    0:
      Result.outputScript := '76a914' + addrHash + '88ac';
    1:
      Result.outputScript := 'a914' + addrHash + '87';
    2:
      Result.outputScript := IntToHex(Result.witver, 2) + '14' + Result.Hash;
    3:
      Result.outputScript := IntToHex(Result.witver, 2) + '20' + Result.Hash;
  end;
  Result.scriptHash := reverseHexOrder(GetSHA256FromHex((Result.outputScript)));
end;

procedure shareFile(path: AnsiString; deleteSourceFile: boolean = true);
var
  i: integer;
{$IFDEF ANDROID}
  intent: JIntent;
  mimetypeStr: JString;
  fileUri: JParcelable;
  javafile: JFile;
  Os: TOSVersion;
{$ELSE}
  saveDialog: TSaveDialog;
  thisExt:string;
{$ENDIF}
begin
{$IFDEF ANDROID}
  mimetypeStr := TJMimeTypeMap.JavaClass.getSingleton.getMimeTypeFromExtension
    (StringToJString(StringReplace(tpath.GetExtension(path), '.', '', [])));
  intent := TJIntent.Create();
  intent.setFlags(TJIntent.JavaClass.FLAG_GRANT_READ_URI_PERMISSION);
  intent.SetAction(TJIntent.JavaClass.ACTION_SEND);
  intent.setType(mimetypeStr);

  if (Os.major >= 5) then
  begin
    // FileProvider for Android 5.1+
    javafile := TJFile.JavaClass.init(StringToJString(path));
    fileUri := JParcelable(TJFileProvider.JavaClass.getUriForFile
      (TAndroidHelper.context, StringToJString('tech.hodler.core.fileProvider'),
      javafile));
  end
  else
  Begin
    // Oldschool URL
    fileUri := JParcelable(TJnet_Uri.JavaClass.fromFile
      (TJFile.JavaClass.init(StringToJString(path))));
  end;
  intent.putExtra(TJIntent.JavaClass.EXTRA_STREAM, fileUri);

  SharedActivity.startActivity(TJIntent.JavaClass.createChooser(intent,
    StrToJcharSequence('Share with')));
{$ELSE}
thisExt:=LowerCase(ExtractFileExt(path));
  saveDialog := TSaveDialog.Create(frmhome);
  saveDialog.Title := 'Save your text or word file';
  saveDialog.FileName := ExtractFileName(path);

  saveDialog.InitialDir :=
{$IFDEF IOS}tpath.GetSharedDocumentsPath{$ELSE}tpath.GetDocumentsPath{$ENDIF};

  saveDialog.Filter := 'File|*'+thisExt;
  if thisExt='.png' then
  saveDialog.FileName:=CurrentAccount.name+'.paperwallet.png';
  saveDialog.DefaultExt := thisExt;

  saveDialog.FilterIndex := 1;

  if saveDialog.Execute then
  begin
    TFile.Copy(path, saveDialog.FileName);
    if deleteSourceFile then
      DeleteFile(path);

  end;
  saveDialog.Free;

{$ENDIF}
end;

Function StrToQRBitmap(Str: AnsiString; pixelSize: integer = 6): TBitmap;
var
  Local_Row: integer;
  Local_Column: integer;
  vPixelB: integer;
  vPixelW: integer;
  QRCode: TDelphiZXingQRCode;
  QRCodeBitmap: TBitmapData;
  Row: integer;
  bmp: FMX.Graphics.TBitmap;
  Column: integer;
  ms: TMemoryStream;
  bmp2: FMX.Graphics.TBitmap;
  DestW: int64;
  DestH: int64;
  pixW: int64;
  pixH: int64;
  j: integer;
  currentRow: int64;
  k: int64;
  currentCol: int64;
  x, Y: integer;
  // rsrc, rDest: TRectF;
  s: AnsiString;

begin
  // result := TBitmap.Create();

  vPixelB := TAlphaColorRec.Black;
  // determine colour to use
  vPixelW := TAlphaColorRec.white;
  // determine colour to use
  QRCode := TDelphiZXingQRCode.Create();

  try

    QRCode.Encoding := TQRCodeEncoding(qrAuto);
    QRCode.QuietZone := 6;
    QRCode.data := {$IFDEF ANDROID}'  ' + {$ENDIF}Str;
    bmp := FMX.Graphics.TBitmap.Create();
    bmp.SetSize(QRCode.Rows, QRCode.Columns);
    if bmp.Map(TMapAccess.maReadWrite, QRCodeBitmap) then
    begin

      for Y := 0 to QRCode.Rows - 1 do
      begin
        for x := 0 to QRCode.Columns - 1 do
        begin

          if (QRCode.IsBlack[Y, x]) then
          begin
            QRCodeBitmap.SetPixel(Y, x, vPixelB);
          end
          else
          begin
            QRCodeBitmap.SetPixel(Y, x, vPixelW);
          end;

        end;
      end;

      if QRCodeBitmap.data <> nil then
      begin
        bmp.Free;
        bmp := BitmapDataToScaledBitmap(QRCodeBitmap, pixelSize);
        bmp.Unmap(QRCodeBitmap);
        end;
    end;
  finally
    QRCode.Free;
  end;

  result := TBitmap.Create();
  result.Assign(bmp);

  try
    if bmp <> nil then
      bmp.Free;
  except

  end;

end;

procedure refreshCurrencyValue();
var
  T: Token;
  w: TWalletInfo;
begin
  frmhome.lblReceiveRealCurrency.Text := frmhome.CurrencyConverter.symbol;
  frmhome.lblCoinFiat.Text := frmhome.CurrencyConverter.symbol;

  TLabel(frmhome.FindComponent('globalBalance')).Text :=
    floatToStrF(frmhome.CurrencyConverter.calculate(globalFiat), ffFixed, 9, 2);
  TLabel(frmhome.FindComponent('globalCurrency')).Text := '         ' +
    frmhome.CurrencyConverter.symbol;

  updateBalanceLabels();
end;

procedure refreshComponentText();
var
  it: System.Generics.Collections.TDictionary<AnsiString, WideString>.
    TPairEnumerator;
  component: TComponent;
begin

  try

    with frmhome do
    begin

      it := sourceDictionary.GetEnumerator();

      While (it.MoveNext) do
      begin

        component := frmhome.FindComponent(it.Current.Key);
        if component <> nil then
        begin
          if component is TPresentedTextControl then
            TPresentedTextControl(component).Text := it.Current.Value
          else if component is TTextControl then
            TTextControl(component).Text := it.Current.Value
          else
            showmessage('Forgotten component ' + component.ToString);
        end;
      end;

      it.Free;

    end;

  except
    on E: Exception do
    begin

    end
  end;

end;

procedure loadDictionary(langData: WideString);
var
  data: AnsiString;
  StringReader: TStringReader;
  JSONTextReader: TJSONTextReader;
  JsonValue: TJsonValue;
  JSONArray: TJsonArray;
  it: TJSONIterator;
  ts: TStringList;

begin

  if frmhome.sourceDictionary = nil then
    frmhome.sourceDictionary :=
      TObjectDictionary<AnsiString, WideString>.Create();

  StringReader := TStringReader.Create(langData);
  JSONTextReader := TJSONTextReader.Create(StringReader);

  it := TJSONIterator.Create(JSONTextReader);

  it.Recurse;
  while (it.Next()) do
  begin
    frmhome.sourceDictionary.AddOrSetValue(trim(it.Key), it.AsString);
  end;

  it.Free;

  JSONTextReader.Free;
  StringReader.Free;
end;

procedure Vibrate(ms: int64);
{$IFDEF ANDROID}
var

  Vibrator: JVibrator;
{$ENDIF}
begin
{$IFDEF ANDROID}
  Vibrator := TJvibrator.Wrap
    ((SharedActivityContext.getSystemService
    (TJContext.JavaClass.VIBRATOR_SERVICE) as ILocalObject).GetObjectID());
  Vibrator.Vibrate(200);
{$ENDIF}
end;

procedure RefreshGlobalFiat();
var
  ccrc: cryptoCurrency;
begin
  globalFiat := 0;
  for ccrc in CurrentAccount.myCoins do
  begin
    if not TWalletInfo(ccrc).inPool then
      globalFiat := globalFiat +
        Max((((ccrc.confirmed.AsDouble + ccrc.unconfirmed.AsDouble) * ccrc.rate)
        / Math.Power(10, ccrc.decimals)), 0);
  end;

  for ccrc in CurrentAccount.myTokens do
  begin
    globalFiat := globalFiat +
      Max((((ccrc.confirmed.AsDouble) * ccrc.rate) / Math.Power(10,
      ccrc.decimals)), 0);
  end;

end;

procedure refreshOrderInDashBrd();
var
  fmxObj: TfmxObject;
begin;

  if frmhome.walletList.Content.ChildrenCount = 0 then
    exit;

  for fmxObj in frmhome.walletList.Content.Children do
  begin

    TPanel(fmxObj).Position.Y := cryptoCurrency(fmxObj.TagObject)
      .orderInWallet - 1;

  end;
  frmhome.walletList.Repaint;

end;

function aggregateAndSortTX(CCArray: TCryptoCurrencyArray): TxHistory;
  function alreadyOnList(txid: AnsiString; var Tab: TxHistory): boolean;
  var
    tx: transactionHistory;
    ref: integer;
  begin
    Result := false;
    ref := 0;
    if Length(Tab) <= 1 then
      exit(false);

    for tx in Tab do
    begin
      if tx.TransactionID = txid then
        Inc(ref);

      if ref > 1 then
        exit(true);

    end;
  end;
  function removeDuplicatedTX(var Tab: TxHistory): TxHistory;
  var
    i: integer;
  begin
    i := 0;
    if Length(Tab) <= 1 then
      exit(Tab);
    repeat
      if alreadyOnList(Tab[i].TransactionID, Tab) then
      begin
        Tab[i] := Tab[High(Tab)];
        SetLength(Tab, Length(Tab) - 1);
        continue;
      end;
      Inc(i);
    until i >= Length(Tab);

    Result := Tab;
  end;
  procedure Sort(var Tab: TxHistory);
  var
    i, j: integer;
    temp: transactionHistory;
  begin
    if Length(Tab) <= 1 then
      exit;

    for i := Low(Tab) to High(Tab) do
    begin
      for j := Low(Tab) + 1 to High(Tab) do
      begin
        { if compareHistory( tab[j] , tab[i]) < 0 then
          begin
          temp := Tab[j];
          Tab[j] := Tab[j - 1];
          Tab[j - 1] := temp;
          end; }

        if strToFloatDef(Tab[j].data, 0) > strToFloatDef(Tab[j - 1].data, 0)
        then
        begin
          temp := Tab[j];
          Tab[j] := Tab[j - 1];
          Tab[j - 1] := temp;
        end;
        if strToFloatDef(Tab[j].data, 0) = strToFloatDef(Tab[j - 1].data, 0)
        then
          if CompareStr(Tab[j].TransactionID, Tab[j - 1].TransactionID) < 0 then
          begin
            temp := Tab[j];
            Tab[j] := Tab[j - 1];
            Tab[j - 1] := temp;
          end;
      end;
    end;
  end;

var
  i: integer;
  cc: cryptoCurrency;
  tmp: TxHistory;
  tx: transactionHistory;
begin
  SetLength(Result, 0);

  try
    SetLength(tmp, 0);
    for cc in CCArray do
    begin
      SetLength(Result, Length(tmp) + Length(cc.history));
      insert(cc.history, tmp, Length(tmp) - Length(cc.history));
    end;
    tmp := removeDuplicatedTX(tmp);
    Sort(tmp);
    Result := tmp;
    SetLength(tmp, 0);
  except
    on E: Exception do
    begin
    end;
  end;
end;

function HistoryRecycling(VSB: TVertScrollBox; Pos: single): TPanel;
var
  i: integer;
begin
  Result := nil;
  if VSB.ComponentCount > 0 then
    for i := 0 to VSB.ComponentCount - 1 do
    begin
      if (TControl(VSB.Components[i]).Position.Y >= Pos) and
        (TControl(VSB.Components[i]).Position.Y + TControl(VSB.Components[i])
        .Height <= Pos) then
      begin
        if VSB.Components[i] is TPanel then
        begin
          Result := TPanel(VSB.Components[i]);
          exit;
        end;
      end;

    end;
  if Result = nil then
    Result := TPanel.Create(VSB);
end;

procedure createHistoryList(wallet: cryptoCurrency; start: integer = 0;
stop: integer = 10);
var
  panel: ThistoryPanel;
  // image: TImage;
  // lbl: TLabel;
  // addrLbl: TAddressLabel;
  // datalbl: TLabel;
  fmxObj: TfmxObject;
  i: integer;

  cc: cryptoCurrency;
  CCArray: TCryptoCurrencyArray;
  hist: TxHistory;
var
  tmp: single;
  holder: THistoryHolder;
begin
  tmp := frmhome.TxHistory.ViewportPosition.Y;

  lastHistCC := stop;
  // {$IFDEF ANDROID}
  frmhome.LoadMore.TagString := 'LOADMORE';
  frmhome.LoadMore.Visible := false;
  // {$ENDIF}
  if start = 0 then
  begin

    i := frmhome.TxHistory.Content.ChildrenCount - 1;
    while i >= 0 do
    begin
      if frmhome.TxHistory.Content.Children[i].ClassType = ThistoryPanel then
      begin
        if ThistoryPanel(frmhome.TxHistory.Content.Children[i]).TagObject is THistoryHolder
        then
          ThistoryPanel(frmhome.TxHistory.Content.Children[i]).TagObject.Free;

        HistoryPanelPool.returnComponent
          (ThistoryPanel(frmhome.TxHistory.Content.Children[i]));
        i := frmhome.TxHistory.Content.ChildrenCount - 1
      end
      else
        dec(i);
    end;

  end;
  // clearVertScrollBox(frmhome.TxHistory);

  if (wallet is TWalletInfo) and (TWalletInfo(wallet).x <> -1) then
  begin
    CCArray := CurrentAccount.getWalletWithX(TWalletInfo(wallet).x,
      TWalletInfo(wallet).coin);
  end
  else
  begin
    SetLength(CCArray, 1);
    CCArray[0] := wallet;
  end;
  hist := aggregateAndSortTX(CCArray);
  if start >= Length(hist) then
    exit;
  // {$IFDEF ANDROID}
  if Length(hist) > stop then
    frmhome.LoadMore.Visible := true;
  // {$ENDIF}
  if start > stop then
    start := 0;

  for i := start to stop do
  begin
    if i >= Length(hist) then
      exit;
    if Length(hist[i].addresses) = 0 then
      continue;

    // panel := THistoryPanel.Create(frmhome.TxHistory);//HistoryRecycling(frmhome.TxHistory,(i * 44) - 1); //
    panel := HistoryPanelPool.getComponent();

    panel.Height := 40;

    panel.Visible := true;
    panel.tag := i;
    panel.TagFloat := strToFloatDef(hist[i].data, 0);
    panel.parent := frmhome.TxHistory;
    panel.Position.Y := (i * 44) - 1;
    // 40 (panel.height) + 2 ( panel.margin.bottom ) + 2 ( panel.margin.top );
    panel.Align := TAlignLayout.top;
{$IF DEFINED(ANDROID) OR DEFINED(IOS)}
    panel.OnTap := frmhome.ShowHistoryDetails;
{$ELSE}
    panel.OnClick := frmhome.ShowHistoryDetails;
{$ENDIF}
    holder := THistoryHolder.Create;
{$IF DEFINED(ANDROID) OR DEFINED(IOS)}
    holder.__ObjAddRef;
{$ENDIF}
    panel.TagObject := holder;
    (panel.TagObject as THistoryHolder).history := hist[i];
    panel.Margins.Bottom := 2;
    panel.Margins.top := 2;
    panel.Width := frmhome.TxHistory.Width;

    // panel.addrLbl.TextSettings.HorzAlign := TTextAlign.Leading;
    if wallet is TWalletInfo then
    begin
      if TWalletInfo(wallet).coin = 8 then
        panel.addrLbl.SetText(hist[i].addresses[0], 4)
      else if TWalletInfo(wallet).coin = 4 then
        panel.addrLbl.SetText(hist[i].addresses[0], 2)
      else if TWalletInfo(wallet).coin = 3 then
        panel.addrLbl.SetText(hist[i].addresses[0], 12)
      else
        panel.addrLbl.Text := hist[i].addresses[0];
    end
    else
      panel.addrLbl.Text := hist[i].addresses[0];

    panel.datalbl.Text := FormatDateTime('dd mmm yyyy hh:mm',
      UnixToDateTime(StrToIntDef(hist[i].data, 0)));
    panel.datalbl.Visible := TWalletInfo(wallet).coin <> 8;

    panel.setType(hist[i].typ);

    { if hist[i].typ = 'OUT' then
      panel.image.Bitmap := frmhome.sendImage.Bitmap;
      if hist[i].typ = 'IN' then
      panel.image.Bitmap := frmhome.receiveImage.Bitmap;
      if hist[i].typ = 'INTERNAL' then
      panel.image.Bitmap := frmhome.internalImage.Bitmap; }

    if (wallet is TWalletInfo) and (TWalletInfo(wallet).coin = 4) and
      (hist[i].CountValues = 0) then
    begin
      panel.lbl.Text := 'Token transfer';
    end
    else
      panel.lbl.Text := BigIntegerBeautifulStr(hist[i].CountValues,
        wallet.decimals);

    panel.setConfirmed(hist[i].confirmation <> 0);
    { if hist[i].confirmation = 0 then
      begin
      panel.Opacity := 0.5;
      lbl.Opacity := 0.5;
      image.Opacity := 0.5;
      addrLbl.Opacity := 0.5;
      datalbl.Opacity := 0.5;

      end; }
    // Application.ProcessMessages;
  end;

  { frmhome.TxHistory.Sort( function (a , b : TfmxObject) : integer
    begin
    if not ((a is Tpanel) and (b is TPanel)) then
    if a is Tpanel then
    exit(1)
    else
    exit(0);


    result := compareHistory( THistoryHolder(a.TagObject).history , THistoryHolder(b.TagObject).history  )
    end); }

  // frmHome.txHistory.RecalcAbsolute;
  // frmHome.txHistory.RealignContent;
  // {$IFDEF ANDROID}
  frmhome.LoadMore.Position.Y := stop * 360;
  // {$ENDIF}
  frmhome.TxHistory.ViewportPosition := PointF(0, tmp);

end;

function isBech32Address(Str: AnsiString): boolean;
var
  prefix: AnsiString;
  i: integer;
begin
  prefix := 'bc1';
  Result := true;

  for i := Low(prefix) to High(prefix) do
  begin
    if prefix[i] <> Str[i] then
      Result := false;
  end;

end;

function parseQRCode(Str: AnsiString): TStringList;
begin

  Str := StringReplace(Str, '?', #13#10, [rfReplaceAll]);
  Str := StringReplace(Str, ':', #13#10, []);
  Str := StringReplace(Str, '&', #13#10, [rfReplaceAll]);
  Str := StringReplace(Str, '=', #13#10, [rfReplaceAll]);
  Result := TStringList.Create;
  Result.Text := Str;

end;

function BitmapDataToScaledBitmap(data: TBitmapData; scale: integer): TBitmap;
var
  x, Y, i, j: integer;
  temp: TBitmapData;

begin
  Result := TBitmap.Create(data.Width * scale, data.Height * scale);

  if Result.Map(TMapAccess.maReadWrite, temp) then
  begin
    for Y := 0 to data.Height - 1 do
    begin
      for x := 0 to data.Width - 1 do
      begin

        for i := 0 to scale - 1 do
        begin
          for j := 0 to scale - 1 do
          begin
            temp.SetPixel(Y * scale + i, x * scale + j, data.GetPixel(Y, x));
          end;
        end;

      end;
    end;

    Result.Unmap(temp);

  end;

end;

function fromMnemonic(input: AnsiString): integer;
var
  i: integer;
  temp: AnsiString;
begin
  Result := -1;
  for i := 0 to frmhome.wordList.Lines.Count - 1 do
  begin
    if input = frmhome.wordList.Lines.Strings[i] then
    begin
      Result := i;
      exit;
    end;
  end;
end;

function fromMnemonic(input: TStringList): AnsiString;
var
  i: integer;
  bi: BigInteger;
  temp: integer;
begin
  bi := BigInteger.Zero;

  for i := input.Count - 1 downto 0 do
  begin
    bi := bi * 2048;
    temp := fromMnemonic(input[i]);
    if (temp < 0) or (temp > 2047) then
    begin
      Result := '';
      popupWindow.Create(input[i] + ' ' + dictionary('NotExistInWorldlist'));
      exit;
    end;
    bi := bi + fromMnemonic(input[i]);
  end;

  Result := bi.tohexString();

  Result := bi.tohexString();
  while Length(Result) < 64 do
    Result := '0' + Result;

end;

function toMnemonic(hex: AnsiString): AnsiString;
var
  tmp: AnsiString;
  part: integer;
  IntSeed: BigInteger;
begin
  part := 0;
  if (not IsHex(hex)) then
    Result := ''
  else
  begin

    BigInteger.TryParse(hex, 16, IntSeed);

    while IntSeed > 0 do
    begin
      Result := Result + (frmhome.wordList.Lines.Strings[(IntSeed mod 2048)
        .asInteger]) + ' ';
      IntSeed := IntSeed div 2048;
    end;

  end;

end;

function getConfirmedAsString(wi: TWalletInfo): AnsiString;
begin
  Result := BigIntegerToFloatStr(wi.confirmed, availableCoin[wi.coin].decimals);
end;

function isEthereum: boolean;
begin

  Result := CurrentCoin.coin = 4;

end;

function BigIntegerBeautifulStr(num: BigInteger; decimals: integer): AnsiString;
var
  c: array [-4 .. 5] of Char;
  Str: AnsiString;
  temp, i: integer;
  zeroCounter: integer;
begin

  if decimals = 0 then
    exit(num.ToString);

  if num < 0 then
  begin
    Result := '0.00';
    exit;
  end;

  zeroCounter := 0;

  Str := num.ToDecimalString;
  temp := (Length(Str) - decimals);
  if temp > 8 then
  begin
    SetLength(Str, Length(Str) - decimals);
    Result := Str;
  end
  else
  begin

    Str := BigIntegerToFloatStr(num, decimals);
    // SetLength(Str, min(9, decimals));

    for i := high(Str) downto Low(Str) do
    begin
      if Str[i] = '0' then
      begin
        zeroCounter := zeroCounter + 1;
      end
      else
        break;
    end;
    SetLength(Str, Length(Str) - Max(0, zeroCounter - 2));

    if (Length(Str) > 11) and (Pos(FormatSettings.DecimalSeparator, Str) = 2)
    then
      SetLength(Str, 11);

    if Pos(FormatSettings.DecimalSeparator, Str) > 9 then
    begin
      SetLength(Str, Pos(FormatSettings.DecimalSeparator, Str) - 1);
    end;

    Result := Str;
  end;

end;

function StrFloatToBigInteger(Str: AnsiString; decimals: integer): BigInteger;
var
  // temp : AnsiString;
  i: integer;
  separator: Char;
  flag: boolean;
  counter: integer;
begin
  flag := false;
  counter := 0;
  /// Cut additional chars exceeding decimals
  separator := FormatSettings.DecimalSeparator;
  // str := str + StringOfChar('0' , decimals);
  if Pos(separator, Str) <> 0 then
  begin
    // str := str + StringOfChar('0' , decimals + 1) ;
    Str := LeftStr(Str, Pos(separator, Str) + decimals);
  end;

  Result := BigInteger.Create(0);
  for i := Low(Str) to High(Str) do
  begin

    if flag then
      Inc(counter);

    if Char(Str[i]) <> separator then
    begin

      Result := Result * 10;
      Result := Result + integer(Str[i]) - integer('0');

    end
    else
    begin
      flag := true;
    end;

  end;

  while (counter < decimals) do
  begin
    Result := Result * 10;
    Inc(counter);
  end;

end;

function BigIntegerToFloatStr(const num: BigInteger; decimals: integer;
precision: integer = -1): AnsiString;
var
  i: integer;
  // len : integer;
  temp: BigInteger;
  Str: AnsiString;
  minus: boolean;
begin
  if precision = -1 then
    precision := decimals;

  if decimals = 0 then
    exit(num.ToString);

  // temp := BigInteger.Create(num);
  Str := num.ToDecimalString;

  Result := '';

  for i := 0 to decimals do
  begin
    Result := Result + '0';
  end;

  if Length(Str) >= Length(Result) then
  begin
    Result := Str;
  end
  else
  begin
    for i := High(Str) downto Low(Str) do
    begin
      Result[High(Result) - (high(Str) - i)] := Str[i];
    end;

  end;

  insert(FormatSettings.DecimalSeparator, Result, High(Result) - decimals +
    1{$IF DEFINED(ANDROID) OR DEFINED(IOS)} + 1{$ENDIF});

  SetLength(Result, Length(Result) - (decimals - precision));
  minus := Pos('-', Result) > 1;
  if minus then
  begin
    Result := StringReplace(Result, '-', '0', [rfReplaceAll]);
    Result := '-' + Result;

  end;
  if AnsiContainsText(Result, '-.') then
    Result := StringReplace(Result, '-.', '-0.', [rfReplaceAll]);
end;

// return index of array where  is wallet with given address

// show message window
procedure showMsg(backView: TTabItem; message: AnsiString;
warningImage: TBitmap = nil);
begin

  frmhome.btnSMVNo.Visible := true;
  frmhome.btnSMVYes.Visible := true;
  frmhome.btnSMVYes.Text := 'Yes';
  frmhome.btnSMVNo.Text := 'No';
  frmhome.btnSMVYes.Align := frmhome.btnSMVYes.Align.alRight;
  frmhome.btnSMVNo.Align := frmhome.btnSMVNo.Align.alLeft;
  if not(warningImage = nil) then
  begin
    frmhome.imageSMV.Bitmap := warningImage;
  end;
  lastView := backView;
  frmhome.lblmessageText.Text := message;
  switchTab(frmhome.pageControl, frmhome.showMsgView);

end;

// delete all panels from given TVertScrollBox
procedure clearVertScrollBox(VSB: TVertScrollBox);
var
  i: integer;
  temp: TVertScrollBox;
begin
  // temp := TVertScrollBox.Create(frmhome);

  i := VSB.ComponentCount - 1;
  while i >= 0 do
  begin

    if VSB.Components[i].ClassType = TPanel then
    begin

      if TPanel(VSB.Components[i]).TagObject is THistoryHolder then
        TPanel(VSB.Components[i]).TagObject.Free;

      VSB.Components[i].DisposeOf;
      i := VSB.ComponentCount - 1
    end
    else
      dec(i);
  end;

  i := VSB.ComponentCount - 1;
  while i >= 0 do
  begin
    if VSB.Components[i].ClassType = TButton then
    begin
      if (TButton(VSB.Components[i]).TagString <> 'LOADMORE') then
        VSB.Components[i].DisposeOf;
      i := VSB.ComponentCount - 1
    end
    else
      dec(i);
  end;

end;

procedure wipeTokenDat();
begin
  DeleteFile(tpath.Combine(HOME_PATH, 'hodler.erc20.dat'));
end;

// generate icon based on hex
function generateIcon(hex: AnsiString): TBitmap;
var
  bitmapData: TBitmapData;
  Y: integer;
  x: integer;
  Color: TAlphaColor;
  i: integer;
  i_max: integer;
  bb: Tbytes;
  colors: array [0 .. 5] of TAlphaColor;
  j: integer;
begin
  if hex = '' then
    exit;

  if not IsHex(hex) then
  begin

    if (hex[Low(hex)] = '0') and ((hex[Low(hex) + 1] = 'x')) then
    begin
      hex := StringReplace(hex, '0x', '', [rfReplaceAll]);
    end
    else
      hex := '0123456789ABCDEF0123456789ABCDEF012345FF';
  end;

  // convert str to array of colors
  bb := hexatotbytes(hex);
  for i := 1 to 5 do
  begin

    colors[i] := TAlphaColorF.Create(bb[3 * i], bb[3 * i + 1], bb[3 * i + 2])
      .ToAlphaColor;

  end;

  Result := TBitmap.Create();
  Result.SetSize(32, 32);

  if Result.Map(TMapAccess.maReadWrite, bitmapData) then
  begin
    // bitmap "8x8" coloring
    for Y := 0 to 7 do
    begin
      for x := 0 to 7 do
      begin

        // fill small square
        for i := 0 to 3 do
          for j := 0 to 3 do
          begin
            bitmapData.SetPixel(4 * Y + i, 4 * x + j,
              TAlphaColor(colors[(x + 8 * Y) mod 6]));
          end;

      end;
    end;
  end;

  if bb[18] > $7F then // symmertic Y axis
  begin
    for x := 0 to 15 do
    begin
      for Y := 0 to 31 do
      begin
        Color := bitmapData.GetPixel(x, Y);
        bitmapData.SetPixel(31 - x, Y, Color);
      end;
    end;
  end;

  if bb[19] > $7F then // symmetric X axis
  begin
    for x := 0 to 31 do
    begin
      for Y := 0 to 15 do
      begin
        Color := bitmapData.GetPixel(x, Y);
        bitmapData.SetPixel(x, 31 - Y, Color);
      end;
    end;
  end;

  // rounding icon
  for i := 0 to 31 do
    for j := 0 to 31 do
    begin
      // if pixel is outside circle set as alpha
      if (((i) - 15.5) * ((i) - 15.5) + ((j) - 15.5) * ((j) - 15.5)) > 16 * 16
      then
      begin
        bitmapData.SetPixel(i, j, TAlphaColor(0));
      end;

    end;

  Result.Unmap(bitmapData);

end;

// add SEP every N char in STR
function cutEveryNChar(n: integer; Str: AnsiString; sep: AnsiChar = ' ')
  : AnsiString;
var
  i, j: integer;
begin
  Result := Str;
  // exit;
  if n < 0 then
    exit(Str);
  Inc(n);
  Result := Str;

  for i := n to Length(Str) + (Length(Str) - 1) div (n - 1) do

  begin
    if i mod n = 0 then

      insert(sep, Result, i);

  end;

end;

function cutEveryNChar(n: integer; Str: AnsiString; sep: AnsiString)
  : AnsiString;
var
  i, j: integer;
begin

  Result := Str;
  j := 0;
  for i := Low(sep) to High(sep) do
  begin

    Result := cutEveryNChar(n + j, Result, sep[i]);

    j := j + 1;
  end;

end;

function removeSpace(Str: AnsiString): AnsiString;
begin
  Result := Str;
  Result := StringReplace(Result, #13#10, '', [rfReplaceAll]);
  Result := StringReplace(Result, ' ', '', [rfReplaceAll]);
end;

// return number of wallets of chosen coin     for example countWalletBy(0) return number of out BTC wallet

// create view with all supported coins
procedure createAddWalletView();
var
  panel: TPanel;
  coinName: TLabel;
  balLabel: TLabel;
  coinIMG: TImage;
begin
  // if already generated then exit
  if frmhome.SelectNewCoinBox.ComponentCount > 1 then
    exit;

  for i := 0 to Length(coinData.availableCoin) - 1 do
  begin

    with frmhome.SelectNewCoinBox do
    begin
      panel := TPanel.Create(frmhome.SelectNewCoinBox);
      panel.Align := panel.Align.alTop;
      panel.Height := 48;
      panel.Visible := true;
      panel.tag := i;
      panel.parent := frmhome.SelectNewCoinBox;
      panel.OnClick := frmhome.addNewWalletPanelClick;

      coinName := TLabel.Create(frmhome.SelectNewCoinBox);
      coinName.parent := panel;
      coinName.Text := availableCoin[i].Displayname;
      coinName.Visible := true;
      coinName.Width := 500;
      coinName.Position.x := 52;
      coinName.Position.Y := 16;
      coinName.tag := i;
      coinName.OnClick := frmhome.addNewWalletPanelClick;

      coinIMG := TImage.Create(frmhome.SelectNewCoinBox);
      coinIMG.parent := panel;

      coinIMG.Bitmap.LoadFromStream
        (ResourceMenager.getAssets(availableCoin[i].resourcename));
      { := frmhome.coinIconsList.Source[i].MultiResBitmap
        [0].Bitmap; }
      coinIMG.Height := 32.0;
      coinIMG.Width := 50;
      coinIMG.Position.x := 4;
      coinIMG.Position.Y := 8;
      coinIMG.OnClick := frmhome.addNewWalletPanelClick;
      coinIMG.tag := i;

    end;
  end;
end;

function TStateToHEX(bb: TKeccakMaxDigest): AnsiString;
var
  i: integer;
begin
  Result := '';
  for i := 0 to 31 do // keccack-256 digest
    Result := Result + IntToHex(bb[i], 2);
end;

function IsHex(s: string): boolean;
var
  i: integer;
begin
  // Odd string or empty string is not valid hexstring
  if (Length(s) = 0) or (Length(s) mod 2 <> 0) then
    exit(false);

  s := UpperCase(s);
  Result := true;
  for i := StrStartIteration to Length(s){$IF DEFINED(ANDROID) OR DEFINED(IOS)} - 1{$ENDIF} do
    if not(Char(s[i]) in ['0' .. '9']) and not(Char(s[i]) in ['A' .. 'F']) then
    begin
      Result := false;
      exit;
    end;
end;

function keccak256String(s: AnsiString): AnsiString;
var
  buf: array of System.UInt8;

var
  K224State: THashState;
  K256State: THashState;
  K384State: THashState;
  K512State: THashState;
  K224Dig: TKeccakMaxDigest;
  K256Dig: TKeccakMaxDigest;
  K384Dig: TKeccakMaxDigest;
  K512Dig: TKeccakMaxDigest;
  i: integer;

begin

  SetLength(buf, Length(s));
  for i := 0 to Length(s) - 1 do
    buf[i] := System.UInt8(ord(s[i{$IF NOT( DEFINED(ANDROID) OR DEFINED(IOS) ) } + 1{$ENDIF}]));

  init(K256State, 256);

  update(K256State, buf, (Length(s)) * 8);
  Final(K256State, @K256Dig);
  Result := TStateToHEX(K256Dig);

end;

function keccak256Hex(s: AnsiString): AnsiString;
var
  buf: array of System.UInt8;

var
  K224State: THashState;
  K256State: THashState;
  K384State: THashState;
  K512State: THashState;
  K224Dig: TKeccakMaxDigest;
  K256Dig: TKeccakMaxDigest;
  K384Dig: TKeccakMaxDigest;
  K512Dig: TKeccakMaxDigest;
  i: integer;
  bb: Tbytes;
begin
  bb := hexatotbytes(s);
  SetLength(buf, Length(bb));
  for i := 0 to Length(bb) - 1 do
    buf[i] := bb[i];

  init(K256State, 256);

  update(K256State, buf, (Length(bb)) * 8);
  Final(K256State, @K256Dig);
  Result := TStateToHEX(K256Dig);

end;

function SplitString(Str: AnsiString; separator: AnsiChar = ' '): TStringList;
var
  ts: TStringList;
  i: integer;
begin
  Str := StringReplace(Str, separator, #13#10, [rfReplaceAll]);
  ts := TStringList.Create;
  ts.Text := Str;
  Result := ts;

end;

function getStringFromImage(img: TBitmap): AnsiString;
begin

end;

function OCRFix(Str: AnsiString): AnsiString;
begin
  Result := Str;
  Result := StringReplace(Result, 'O', 'o', [rfReplaceAll]);
  Result := StringReplace(Result, '0', 'o', [rfReplaceAll]);
  Result := StringReplace(Result, 'I', 'J', [rfReplaceAll]);
  Result := StringReplace(Result, 'l', 'J', [rfReplaceAll]);
end;

// try find wallet address in text and return it
function findAddress(Str: AnsiString): AnsiString;
var
  strArray: TStringList;
begin
  strArray := SplitString(Str);
  Result := 'Not found';
  for i := 0 to strArray.Count - 1 do
  begin

    if base58.ValidateBitcoinAddress(trim(OCRFix(strArray[i]))) = true then
    begin
      Result := strArray[i];
      strArray.Free;
      exit;
    end;

  end;

  for i := 0 to strArray.Count - 1 do
  begin

    if ((Length(strArray[i]) >= 25) and (Length(strArray[i]) <= 43)) then
    begin
      Result := strArray[i];
      strArray.Free;
      exit;
    end;

  end;

  strArray.Free;
end;

function satToBtc(sat: AnsiString; decimals: integer): AnsiString;
begin
  Result := floatToStrF((StrToIntDef(sat, 0) / Power(10, decimals)), ffFixed,
    15, decimals);
end;

function satToBtc(num: BigInteger; decimals: integer): AnsiString;
begin
  Result := BigIntegerToFloatStr(num, decimals);

end;

function inttoeth(data: System.uint64): AnsiString;
var
  ll: integer;
begin
  ll := ceil(Length(IntToHex(data, 0)) / 2);
  Result := IntToHex(data, ll * 2);
end;

function inttoeth(data: BigInteger): AnsiString;
var
  ll: integer;
begin
  Result := data.tohexString;
  if Length(Result) mod 2 = 1 then
    Result := '0' + Result;

end;

function IntToTX(data: System.uint64; Padding: integer): AnsiString;
Begin
  // Keep padding!
  Result := Copy(reverseHexOrder(IntToHex(data, Padding)), 0, Padding);
End;

function BIntTo256Hex(data: BigInteger; Padding: integer): AnsiString;
Begin
  Result := data.tohexString;
  while Length(Result) < Padding do
  begin
    Result := '0' + Result;
  end;
  // Keep padding!
  Result := Copy((Result), 0, Padding);
End;

function IntToTX(data: BigInteger; Padding: integer): AnsiString;
Begin
  Result := data.tohexString;
  while Length(Result) < Padding do
  begin
    Result := '0' + Result;
  end;
  // Keep padding!
  Result := Copy(reverseHexOrder(Result), 0, Padding);
End;

function buildAuth(aURL: String): AnsiString;
var
  nonce: string;
  Hash: string;
begin
  if ((Pos(HODLER_URL, aURL) > 0) or (Pos(HODLER_ETH, aURL) > 0)) then
  begin
    randomize;
    nonce := intToStr(10000000 + random(900000000)); // Get some random number
    Hash := lowercase(GetStrHashSHA256(API_PRIV));
    Hash := GetStrHashSHA256(nonce + Hash);
    Result := lowercase('&pub=' + API_PUB + '&nonce=' + nonce +
      '&hash=' + Hash);
    if Pos('?', aURL) = 0 then
      Result := '?' + Result;
  end
  else
    Result := '';
end;

const
  Codes64 = '0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz+/';

function Encode64(s: string): string;
var
  i: integer;
  a: integer;
  x: integer;
  b: integer;
begin
  Result := '';
  a := 0;
  b := 0;
  for i := Low(s) to High(s) do
  begin
    x := ord(s[i]);
    b := b * 256 + x;
    a := a + 8;
    while a >= 6 do
    begin
      a := a - 6;
      x := b div (1 shl a);
      b := b mod (1 shl a);
      Result := Result + Codes64[x + 1];
    end;
  end;
  if a > 0 then
  begin
    x := b shl (6 - a);
    Result := Result + Codes64[x + 1];
  end;
end;

function Decode64(s: string): string;
var
  i: integer;
  a: integer;
  x: integer;
  b: integer;
begin
  Result := '';
  a := 0;
  b := 0;
  for i := Low(s) to High(s) do
  begin
    x := Pos(s[i], Codes64) - 1;
    if x >= 0 then
    begin
      b := b * 64 + x;
      a := a + 6;
      if a >= 8 then
      begin
        a := a - 8;
        x := b shr a;
        b := b mod (1 shl a);
        x := x mod 256;
        Result := Result + chr(x);
      end;
    end
    else
      exit;
  end;
end;

function loadCache(Hash: AnsiString): AnsiString;
var
  list: TStringList;
  i: integer;
  conv: TConvert;

var
  Stopwatch: TStopwatch;
  Elapsed: TTimeSpan;

begin

  Result := 'NOCACHE';

  if (CurrentAccount = nil) or
    (FileExists(CurrentAccount.DirPath + '/cache.dat') = false) then
    exit;

  Stopwatch := TStopwatch.StartNew;

  list := TStringList.Create();
  try
    list.NameValueSeparator := '#';
    Tthread.Synchronize(nil,
      procedure
      begin
        list.LoadFromFile(CurrentAccount.DirPath + '/cache.dat');
      end);

    i := list.IndexOfName(Hash);
    if i >= 0 then
    begin
      conv := TConvert.Create(base64);

      Result := conv.FormattOstring(list.values[Hash]);
      conv.Free;
    end;
  finally
    list.Free;
  end;

  Elapsed := Stopwatch.Elapsed;
  globalLoadCacheTime := globalLoadCacheTime + Elapsed.TotalSeconds;

end;

procedure saveCache(Hash, data: AnsiString);
var
  ts: TStringList;
  conv: TConvert;
var
  Flock: TObject;
begin
  if (CurrentAccount = nil) then
    exit();
  // FLock := TObject.Create;
  // TMonitor.Enter(FLock);
  try
    ts := TStringList.Create;
    try
      try
        Tthread.Synchronize(nil,
          procedure
          begin
            if FileExists(CurrentAccount.DirPath + '/cache.dat') then
              ts.LoadFromFile(CurrentAccount.DirPath + '/cache.dat');
          end);

        ts.NameValueSeparator := '#';
        conv := TConvert.Create(base64);
        data := conv.StringToFormat(data);
        if ts.IndexOfName(Hash) >= 0 then
          ts.values[Hash] := data
        else
          ts.Add(Hash + '#' + data);
        conv.Free;
        Tthread.Synchronize(nil,
          procedure
          begin
            ts.SaveToFile(CurrentAccount.DirPath + '/cache.dat');

          end);

      except
        on E: Exception do

      end;

    finally
      ts.Free;
    end;
  finally
    // TMonitor.Exit(FLock);
  end;
end;

function apiStatus(aURL, aResult: string; exceptional: boolean = false): string;
var
  switch: boolean;
  tmp: string;
  Flock: TObject;
begin
  Flock := TObject.Create;
  TMonitor.Enter(Flock);
  try
    switch := exceptional;
    Result := '';
    if Pos('Transport endpoint is not connected', aResult) > 0 then
      switch := true;

    { if (Pos(HODLER_ETH, aURL) > 0) and (switch) then
      begin
      switch := true;
      aURL := StringReplace(aURL, HODLER_ETH, HODLER_ETH2, [rfReplaceAll]);
      tmp := HODLER_ETH2;
      HODLER_ETH2 := HODLER_ETH;
      HODLER_ETH := tmp;
      end; }
    Result := aResult;
  finally
    TMonitor.exit(Flock);
    Flock.Free;
  end;
end;

function ensureURL(aURL: string): string;
begin
  if AnsiContainsStr(aURL, 'ravencoin') or AnsiContainsStr(aURL, 'digibyte') or
    AnsiContainsStr(aURL, 'bitcoinabc') or AnsiContainsStr(aURL, 'bitcoin') or
    AnsiContainsStr(aURL, 'litecoin') or AnsiContainsStr(aURL, 'dash') then
  begin
    aURL := StringReplace(aURL, 'hodlerstream.net', 'hodler1.nq.pl',
      [rfReplaceAll]);
  end;
  if AnsiContainsStr(aURL, 'bitcoinsv') then
  begin
    aURL := StringReplace(aURL, 'hodler1.nq.pl', 'hodlerstream.net',
      [rfReplaceAll]);
  end;
  Result := aURL;
end;

function getDataOverHTTP(aURL: String; useCache: boolean = true;
noTimeout: boolean = false): AnsiString;
var
  req: THTTPClient;
  LResponse: IHTTPResponse;
  urlHash: AnsiString;
  ares: iasyncresult;
  debug: AnsiString;
  fs:boolean;
begin
if currentaccount<>nil  then
fs:=currentaccount.firstSync else
fs:=false;
  req := THTTPClient.Create();
  aURL := ensureURL(aURL);
  urlHash := GetStrHashSHA256(aURL);
  if (fs and useCache) then

  begin
    Result := loadCache(urlHash);
  end;
  try
    if ((Result = 'NOCACHE') or (not fs) or (not useCache)) then
    begin

      if not noTimeout then
      begin

        req.ConnectionTimeout := 5000;
        req.ResponseTimeout := 5000;
      end;
      aURL := aURL + buildAuth(aURL);

      ares := req.BeginGet(aURL);
      while not(ares.IsCompleted or ares.isCancelled) do

      begin
        sleep(50);
        if not Tthread.CurrentThread.ExternalThread then
          if Tthread.CurrentThread.CheckTerminated then
            exit();
      end;
      LResponse := req.EndAsyncHTTP(ares);

      // LResponse := req.get(aURL);
      Result := apiStatus(aURL, LResponse.ContentAsString());
      try
        saveCache(urlHash, Result);
      except
        on E: Exception do
        begin
        end

      end;
      if LResponse.StatusCode <> 200 then
        Result := apiStatus(aURL, '', true);
    end;
  except
    on E: Exception do
    begin
      Result := E.message;
      Result := apiStatus(aURL, '', true);

    end;

  end;
  req.Free;
  debug := Result;
end;

function postDataOverHTTP(var aURL: String; postdata: string;
useCache: boolean = true; noTimeout: boolean = false): AnsiString;
const
  waitForRequestEnd: string = '##$$NORES$$##';
var
  req: THTTPClient;
  LResponse: IHTTPResponse;
  urlHash: AnsiString;
  ts: TStringList;
  asyncResponse: string;
  ares: iasyncresult;
begin
  if Tthread.CurrentThread.CheckTerminated then
    exit();
  asyncResponse := waitForRequestEnd;
  aURL := ensureURL(aURL);
  urlHash := GetStrHashSHA256(aURL);
  if (currentaccount.firstSync and useCache) then
  begin
    Result := loadCache(urlHash);
  end;
  try
    if ((Result = 'NOCACHE') or (not currentaccount.firstSync) or (not useCache)) then
    begin

      req := THTTPClient.Create();
      if not noTimeout then
      begin

        req.ConnectionTimeout := 3000;
        req.ResponseTimeout := 60000;
      end;
      aURL := aURL + buildAuth(aURL);
      ts := TStringList.Create;
      ts.Text := StringReplace(postdata, '&', #13#10, [rfReplaceAll]);

//{$IFDEF  DEBUG} ts.SaveToFile('params' + urlHash + '.json'); {$ENDIF}  // shoud be in debugAnalysis

      ares := req.BeginPost(aURL, ts);
      while not(ares.IsCompleted or ares.isCancelled) do
      begin
        sleep(50);
        if Tthread.CurrentThread.CheckTerminated then
          exit();
      end;
      LResponse := req.EndAsyncHTTP(ares);
      asyncResponse := LResponse.ContentAsString();
      // asyncResponse:=req.EndAsyncHTTP(ares).ContentAsString();

      Result := apiStatus(aURL, asyncResponse);
      ts.Text := asyncResponse;
      // {$IFDEF  DEBUG} ts.SaveToFile(urlHash + '.json'); {$ENDIF}
      ts.Free;
      try
        saveCache(urlHash, Result);
      except
        on E: Exception do
        begin
        end

      end;
      if LResponse.StatusCode <> 200 then
        Result := apiStatus(aURL, '', true);
    end;
  except
    on E: Exception do
    begin
      Result := apiStatus(aURL, '', true);

    end;
  end;
  req.DisposeOf;
end;

function hash160FromHex(H: AnsiString): AnsiString;
var
  ripemd160: TRIPEMD160Hash;
  i: integer;
  b: Byte;
  memstr: TMemoryStream;
begin
if not isHex(h) then exit('');

  memstr := TMemoryStream.Create;
  memstr.SetSize(int64(Length(H) div 2));
  memstr.Seek(int64(0), soFromBeginning);
{$IF DEFINED(ANDROID) OR DEFINED(IOS)}
  for i := 0 to (Length(H) div 2) - 1 do
  begin
    b := Byte(StrToIntDef('$' + Copy(H, ((i) * 2) + 1, 2), 0));
    memstr.Write(b, 1);
  end;
{$ELSE}
  for i := 1 to (Length(H) div 2) do
  begin
    b := Byte(StrToIntDef('$' + Copy(H, ((i - 1) * 2) + 1, 2), 0));
    memstr.Write(b, 1);
  end;

{$ENDIF}
  ripemd160 := TRIPEMD160Hash.Create;
  try
    ripemd160.OutputFormat := hexa;
    ripemd160.Unicode := noUni;
    Result := ripemd160.HashStream(memstr);
  finally
    ripemd160.Free;
    memstr.Free;
  end;
end;

function isWalletDatExists: boolean;
var
  WDPath: AnsiString;
begin
  WDPath := tpath.Combine(HOME_PATH, 'hodler.wallet.dat');
  Result := FileExists(WDPath);
end;
{$IF DEFINED(ANDROID) OR DEFINED(IOS)}

function HexToStream(H: AnsiString): TStream;
var
  i: integer;
  b: System.UInt8;
  memstr: TMemoryStream;
begin
  memstr := TMemoryStream.Create;
  memstr.SetSize({$IFDEF IOS}int64{$ENDIF}((Length(H) div 2) - 1));
  memstr.Seek({$IFDEF IOS}int64{$ENDIF}(0), soFromBeginning);

  for i := 0 to (Length(H) div 2) - 1 do
  begin
    b := System.UInt8(StrToIntDef('$' + Copy(H, (i) * 2, 2), 0));
    memstr.Write(b, 1);
  end;
end;
{$ELSE}

function HexToStream(H: AnsiString): TStream;
var
  i: integer;
  b: Byte;
  memstr: TMemoryStream;
begin
  memstr := TMemoryStream.Create;
  memstr.SetSize(int64(Length(H) div 2));
  memstr.Seek(int64(0), soFromBeginning);
  for i := 1 to (Length(H) div 2) do
  begin
    b := Byte(StrToIntDef('$' + Copy(H, (i - 1) * 2 + 1, 2), 0));
    memstr.Write(b, 1);
  end;
end;
{$ENDIF}

// convert hex string to array of 8-bit number
function hexatotbytes(H: AnsiString): Tbytes;
var
  i: integer;
  b: System.UInt8;
  bb: Tbytes;
begin

  // if not IsHex(h) then
  // raise Exception.Create(H + ' is not hex');

  SetLength(bb, (Length(H) div 2));
{$IF (DEFINED(ANDROID) OR DEFINED(IOS))}
  for i := 0 to (Length(H) div 2) - 1 do
  begin
    b := System.UInt8(StrToIntDef('$' + Copy(H, ((i) * 2) + 1, 2), 0));
    bb[i] := b;
  end;
{$ELSE}
  for i := 1 to (Length(H) div 2) do
  begin
    b := System.UInt8(StrToIntDef('$' + Copy(H, ((i - 1) * 2) + 1, 2), 0));
    bb[i - 1] := b;
  end;

{$ENDIF}
  Result := bb;
end;

function GetSHA256FromHex(H: AnsiString): AnsiString;
var
  HashSHA: THashSHA2;
  sha2: TSHA2Hash;
  i: integer;
  b: System.UInt8;
  bb: Tbytes;
begin
  bb := hexatotbytes(H);
  HashSHA := THashSHA2.Create;
  HashSHA.Reset;
  HashSHA.update(bb, (Length(H) div 2));
  Result := HashSHA.HashAsString;

end;

function GetStrHashSHA256(Str: AnsiString): AnsiString;
var
  sha2: TSHA2Hash;

begin
  sha2 := TSHA2Hash.Create;
  sha2.HashSizeBits := 256;
  sha2.OutputFormat := hexa;
  sha2.Unicode := noUni;
  Result := sha2.Hash(Str);
  sha2.Free;

end;

function GetStrHashSHA512(Str: AnsiString): AnsiString;
var
  HashSHA: THashSHA2;
begin
  HashSHA := THashSHA2.Create;
  HashSHA.GetHashString(Str);
  Result := HashSHA.GetHashString(Str, SHA512);
end;

function GetStrHashBobJenkins(Str: AnsiString): AnsiString;
var
  Hash: THashBobJenkins;
begin
  Hash := THashBobJenkins.Create;
  Hash.GetHashString(Str);
  Result := Hash.GetHashString(Str);
end;

function GetStrHashSHA512_256(Str: AnsiString): AnsiString;
var
  HashSHA: THashSHA2;
begin
  HashSHA := THashSHA2.Create;
  HashSHA.GetHashString(Str);
  Result := HashSHA.GetHashString(Str, SHA512_256);
end;

function GetStrHashSHA512_224(Str: AnsiString): AnsiString;
var
  HashSHA: THashSHA2;
begin
  HashSHA := THashSHA2.Create;
  HashSHA.GetHashString(Str);
  Result := HashSHA.GetHashString(Str, SHA512_224);
end;

function TCA(dane: AnsiString): AnsiString;
var
  i: integer;
  s: AnsiString;
  allowAnim: boolean;
begin
  s := dane;
  allowAnim := frmhome.pageControl.ActiveTab = frmhome.descryptSeed;
  if allowAnim then
  begin

    frmhome.TCAInfoPanel.Visible := true;
    Application.ProcessMessages;
  end;
  for i := 0 to TCAIterations do
    s := GetStrHashSHA256
      (GetStrHashSHA256(GetStrHashSHA256(GetStrHashBobJenkins(s))));
  Result := s;
  if allowAnim then
  begin

    frmhome.TCAInfoPanel.Visible := false;
    Application.ProcessMessages;
  end;
end;

function TBytesToString(bb: Tbytes): WideString;
begin
  Result := TEncoding.ANSI.GetString(bb);
end;

function speckStrPadding(data: AnsiString): AnsiString;
var
  lacking: integer;
begin

  lacking := 16 - (Length(data) mod 16);
  Result := data + StringofChar(#0, lacking);
end;

function speckEncrypt(tcaKey, data: AnsiString): AnsiString;
var
  speck: TSPECKEncryption;
  cipher: string;
begin
  speck := TSPECKEncryption.Create;
  speck.AType := stOFB;
  speck.WordSizeBits := TSPECKWordSizeBits.wsb64;
  speck.KeySizeWords := TSPECKKeySizeWords.ksw4;
  speck.Key := TBytesToString(hexatotbytes(tcaKey));
  speck.OutputFormat := hexa;
  speck.Unicode := noUni;
  speck.PaddingMode := TSPECKPaddingMode.nopadding;
  speck.IVMode := TSPECKIVMode.userdefined;
  speck.IV := '0123456789abcdef';
  cipher := speck.Encrypt(data);
  Result := cipher;
  speck.Free;

end;

function speckDecrypt(tcaKey, data: AnsiString): AnsiString;
var
  speck: TSPECKEncryption;
  cipher: string;
begin
  speck := TSPECKEncryption.Create;
  speck.AType := stOFB;
  speck.WordSizeBits := TSPECKWordSizeBits.wsb64;
  speck.KeySizeWords := TSPECKKeySizeWords.ksw4;
  speck.Key := TBytesToString(hexatotbytes(tcaKey));;

  speck.OutputFormat := hexa;
  speck.Unicode := noUni;
  speck.PaddingMode := TSPECKPaddingMode.nopadding;
  speck.IVMode := TSPECKIVMode.userdefined;
  speck.IV := '0123456789abcdef';
  Result := trim(speck.Decrypt(data));
  speck.Free;
  // result := string(cipher);
end;

function AES256CBCEncrypt(tcaKey, data: AnsiString): AnsiString;
var
  aes: TAESEncryption;
  cipher: string;
  i: integer;
  b: System.UInt8;
  bb: Tbytes;
begin
  bb := hexatotbytes(tcaKey);
  aes := TAESEncryption.Create;
  aes.AType := atCBC;
  aes.KeyLength := kl256;
  aes.Unicode := noUni;
  aes.Key := String(bb);
  aes.OutputFormat := hexa;
  aes.PaddingMode := TpaddingMode.PKCS7;
  aes.IVMode := TIVMode.rand;
  cipher := aes.Encrypt(data);
  aes.Free;
  Result := cipher;
end;

function randomHexStream(size: integer): AnsiString;
var
  i: integer;
begin

  for i := 0 to size - 1 do
    Result := Result + IntToHex(random($FF), 2);

end;

function AES256CBCDecrypt(tcaKey, data: AnsiString): AnsiString;
var
  aes: TAESEncryption;
  cipher: string;
  i: integer;
  b: System.UInt8;
  bb, bb2: Tbytes;
  conv: TConvert;

begin
  SetLength(bb, (Length(tcaKey) div 2));
  SetLength(bb2, (Length(data) div 2));
{$IF DEFINED(ANDROID) OR DEFINED(IOS)}
  for i := 0 to (Length(tcaKey) div 2) - 1 do
  begin
    b := System.UInt8(StrToIntDef('$' + Copy(tcaKey, ((i) * 2) + 1, 2), 0));
    bb[i] := b;
  end;
{$ELSE}
  for i := 1 to (Length(tcaKey) div 2) do
  begin
    b := System.UInt8(StrToIntDef('$' + Copy(tcaKey, ((i - 1) * 2) + 1, 2), 0));
    bb[i - 1] := b;
  end;
{$ENDIF}
  aes := TAESEncryption.Create;
  aes.AType := atCBC;
  aes.KeyLength := kl256;
  aes.Unicode := noUni;
  conv := TConvert.Create;
  aes.Key := conv.TBytesToString(bb);
  aes.OutputFormat := hexa;
  aes.PaddingMode := TpaddingMode.PKCS7;
  aes.IVMode := TIVMode.rand;
  cipher := aes.Decrypt(data);
  aes.Free;
  conv.Free;
  Result := cipher;
end;
{$IF DEFINED(ANDROID) OR DEFINED(IOS)}

procedure wipeString(var toWipe: String);
var
  i: integer;
begin
  for i := 0 to Length(toWipe) - 1 do
    toWipe[i] := #0;
  toWipe := '';
end;
{$ELSE}

procedure wipeString(var toWipe: String);
var
  i: integer;
begin
  for i := 1 to Length(toWipe) do
    toWipe[i] := #0;
  toWipe := '';
end;
{$ENDIF}
{$IF DEFINED(ANDROID) OR DEFINED(IOS)}

procedure wipeAnsiString(var toWipe: AnsiString);
var
  i: integer;
begin
  for i := 0 to Length(toWipe) - 1 do
    toWipe[i] := #0;
  toWipe := '';
end;
{$ELSE}

procedure wipeAnsiString(var toWipe: AnsiString);
var
  i: integer;
begin
  for i := 1 to Length(toWipe) do
    toWipe[i] := #0;
  toWipe := '';
end;
{$ENDIF}

function reverseHexOrder(s: AnsiString): AnsiString;
var
  v: AnsiString;
begin
  s := StringReplace(s, '$', '', [rfReplaceAll]);
  Result := '';
  repeat
    if Length(s) >= 2 then
    begin
      v := Copy(s, 0, 2);
      delete(s, 1, 2);
      Result := v + Result;
    end
    else
      break;
  until 1 = 0;
end;

function priv256forHD(coin, x, Y: integer; MasterSeed: AnsiString): AnsiString;
var
  bi: BigInteger;
begin
  { if CurrentAccount.privTCA then
    result := GetSHA256FromHex(TCA(IntToHex(x, 32) + GetSHA256FromHex(IntToHex(coin,
    8) + GetSHA256FromHex(IntToHex(coin, 8) + IntToHex(x, 32) + MasterSeed +
    IntToHex(y, 32))) + IntToHex(y, 32))) else }
  Result := GetSHA256FromHex(IntToHex(x, 32) + GetSHA256FromHex(IntToHex(coin,
    8) + GetSHA256FromHex(IntToHex(coin, 8) + IntToHex(x, 32) + MasterSeed +
    IntToHex(Y, 32))) + IntToHex(Y, 32));
  BigInteger.TryParse(Result, 16, bi);
  if bi > secp256k1.getN then
    Result := priv256forHD(coin, x, Y, GetStrHashSHA256(Result));

  wipeAnsiString(MasterSeed);
end;

function seedToHumanReadable(seed: AnsiString): AnsiString;
var
  i: integer;
begin
  Result := '* ::: ';
  for i := StrStartIteration to Length(seed) do
  begin
    Result := Result + seed[i];
{$IF DEFINED(ANDROID) OR DEFINED(IOS)}
    if i mod 1 = 0 then
      Result := Result + ' ';
    if i mod 7 = 0 then
{$ELSE}
    if i mod 2 = 0 then
      Result := Result + ' ';
    if i mod 8 = 0 then
{$ENDIF}
      Result := Result + ' :::  ';

  end;
  Result := Result + '*';
  wipeAnsiString(seed);
end;

procedure refreshWalletDat();
var
  wd: TWalletInfo;
  ts { , oldFile } : TStringList;
  i: integer;
  Flock: TObject;
  accObject, JsonObject: TJsonObject;
  JSONArray: TJsonArray;
begin
  Flock := TObject.Create;
  TMonitor.Enter(Flock);
  try
    if not FileExists(tpath.Combine(HOME_PATH, 'hodler.wallet.dat')) then
    begin
      exit;
    end;

    ts := TStringList.Create;
    // oldFile := TStringList.Create;
    // oldFile.LoadFromFile(TPath.Combine(TPath.GetDocumentsPath,
    // 'hodler.wallet.dat'));
    JSONArray := TJsonArray.Create();

    for i := 0 to Length(AccountsNames) - 1 do
    begin
      if AccountsNames[i].name = '' then
        continue;

      accObject := TJsonObject.Create();
      accObject.AddPair('name', AccountsNames[i].name);
      accObject.AddPair('order', intToStr(i));

      JSONArray.AddElement(accObject);
    end;

    JsonObject := TJsonObject.Create();

    JsonObject.AddPair('languageIndex',
      intToStr(frmhome.LanguageBox.ItemIndex));
    JsonObject.AddPair('currency', frmhome.CurrencyConverter.symbol);
    if CurrentAccount <> nil then
      JsonObject.AddPair('lastOpen', CurrentAccount.name)
    else
      JsonObject.AddPair('lastOpen', lastClosedAccount);

    JsonObject.AddPair('accounts', JSONArray);
    JsonObject.AddPair('styleName', currentStyle);
    JsonObject.AddPair('AllowToSendData', boolToStr(USER_ALLOW_TO_SEND_DATA));

    ts.Text := JsonObject.ToString;
    ts.SaveToFile(tpath.Combine(HOME_PATH, 'hodler.wallet.dat'));
    ts.Free;
    JsonObject.Free;
  finally
    TMonitor.exit(Flock);
    Flock.Free;
  end;

end;

procedure createWalletDat();
var
  ts: TStringList;
  genThr: Tthread;
  accObject, JsonObject: TJsonObject;
  JSONArray: TJsonArray;
begin

  JSONArray := TJsonArray.Create();

  for i := 0 to Length(AccountsNames) - 1 do
  begin
    if AccountsNames[i].name = '' then
      continue;

    accObject := TJsonObject.Create();
    accObject.AddPair('name', AccountsNames[i].name);
    accObject.AddPair('order', intToStr(i));

    JSONArray.AddElement(accObject);
  end;

  JsonObject := TJsonObject.Create();

  JsonObject.AddPair('languageIndex', intToStr(frmhome.LanguageBox.ItemIndex));
  JsonObject.AddPair('currency', frmhome.CurrencyConverter.symbol);
  JsonObject.AddPair('lastOpen', '');
  JsonObject.AddPair('accounts', JSONArray);
  JsonObject.AddPair('styleName', 'RT_WHITE');
  JsonObject.AddPair('AllowToSendData', boolToStr(true));

  ts := TStringList.Create;
  ts.Text := JsonObject.ToString;

  ts.SaveToFile(tpath.Combine(HOME_PATH, 'hodler.wallet.dat'));

  ts.Free;

  JsonObject.Free;

end;

procedure GenetareCoinsData(seed, password: AnsiString; ac: Account);
var
  genThr: Tthread;
  wd: TWalletInfo;
var

  T: Token;
  EthAddress: AnsiString;
  tokenCount: integer;
  Position: integer;
  i, j: integer;
  panel: TPanel;
  countwallet: integer;
begin

  // raise Exception.Create('print path');
  EthAddress := '';
  tokenCount := 0;
  countwallet := 0;
  Position := 0;

  if ac = nil then
    raise Exception.Create('GenerateCoinsData() nullptr Exception');

  Tthread.Synchronize(nil,
    procedure
    begin
      frmhome.pageControl.ActiveTab := frmhome.WaitWalletGenerate;
    end);

  try

    for i := 0 to (frmhome.GenerateCoinVertScrollBox.Content.
      ChildrenCount - 1) do
    begin

      panel := TPanel(frmhome.GenerateCoinVertScrollBox.Content.Children[i]);

      if not TCheckBox(panel.TagObject).IsChecked then
      begin
        continue;
      end;
      if panel.tag < 10000 then
      begin
        if panel.tag = 4 then
          countwallet := countwallet + 1
        else
          countwallet := countwallet + 5;
      end

    end;

    Tthread.Synchronize(nil,
      procedure
      begin
        frmhome.WaitForGenerationProgressBar.Value := 0;
        frmhome.WaitForGenerationProgressBar.Max := countwallet;
        frmhome.WaitForGenerationLabel.Text := '';
      end);

    for i := 0 to (frmhome.GenerateCoinVertScrollBox.Content.
      ChildrenCount - 1) do
    begin

      panel := TPanel(frmhome.GenerateCoinVertScrollBox.Content.Children[i]);

      if not TCheckBox(panel.TagObject).IsChecked then
      begin
        continue;
      end;

      if panel.tag >= 10000 then
      begin
        tokenCount := tokenCount + 1;
      end
      else
      begin

        if panel.tag = 4 then
        begin

          wd := Ethereum_createHD(4, 0, 0, seed);
          wd.orderInWallet := Position;
          Inc(Position, 48);
          ac.AddCoin(wd);
          Tthread.Synchronize(nil,
            procedure
            begin
              frmhome.WaitForGenerationLabel.Text := 'Generating ETH Wallet';
              frmhome.WaitForGenerationProgressBar.Value :=
                frmhome.WaitForGenerationProgressBar.Value + 1;
            end);

          EthAddress := wd.addr;

          continue;
        end;
        if panel.tag = 8 then
        begin

          wd := nano_createHD(0, 0, seed);
          wd.orderInWallet := Position;
          Inc(Position, 48);
          ac.AddCoin(wd);
          Tthread.Synchronize(nil,
            procedure
            begin
              frmhome.WaitForGenerationLabel.Text := 'Generating NANO Wallet';
              frmhome.WaitForGenerationProgressBar.Value :=
                frmhome.WaitForGenerationProgressBar.Value + 1;
            end);

          continue;
        end;
        for j := 0 to 4 do
        begin
          wd := Bitcoin_createHD(panel.tag, 0, j, seed);
          wd.orderInWallet := Position;
          Inc(Position, 48);
          ac.AddCoin(wd);
          Tthread.Synchronize(nil,
            procedure
            begin
              frmhome.WaitForGenerationLabel.Text := 'Generating ' +
                availableCoin[panel.tag].shortcut + ' Wallet';
              frmhome.WaitForGenerationProgressBar.Value :=
                frmhome.WaitForGenerationProgressBar.Value + 1;
            end);
        end;

      end;

    end;

    if tokenCount > 0 then
    begin
      if EthAddress = '' then
      begin
        wd := Ethereum_createHD(4, 0, 0, seed);
        wd.orderInWallet := Position;
        Inc(Position, 48);
        ac.AddCoin(wd);
        Tthread.Synchronize(nil,
          procedure
          begin
            frmhome.WaitForGenerationLabel.Text := 'Generating ETH Wallet';
            frmhome.WaitForGenerationProgressBar.Value :=
              frmhome.WaitForGenerationProgressBar.Value + 1;
          end);

        EthAddress := wd.addr;
      end;
      for i := 0 to frmhome.GenerateCoinVertScrollBox.Content.
        ChildrenCount - 1 do
      begin

        panel := TPanel(frmhome.GenerateCoinVertScrollBox.Content.Children[i]);

        if not TCheckBox(panel.TagObject).IsChecked then
        begin
          continue;
        end;

        if panel.tag < 10000 then
        begin
          continue;
        end;

        T := Token.Create(panel.tag - 10000, EthAddress);
        T.orderInWallet := Position;
        Inc(Position, 48);

        T.idInWallet := Length(ac.myTokens) + 10000;
        ac.addToken(T);

      end;

    end;

  except
    on E: Exception do
      raise (E);
  end;
  wipeAnsiString(seed);

end;

procedure wipeWalletDat;
var
  ts: TStringList;
  acname: AccountItem;
  tempAccount: Account;
  FilePath: AnsiString;
begin
  try
    for acname in AccountsNames do
    begin
      tempAccount := Account.Create(acname.name);
      try
        for FilePath in tempAccount.Paths do
        begin
          ts := TStringList.Create;
          ts.LoadFromFile(FilePath);
          ts.Text := StringofChar('@', Length(ts.Text));
          ts.SaveToFile(FilePath);
          ts.Free;
          DeleteFile(FilePath);
        end;

        RemoveDir(tempAccount.DirPath);
      except
        on E: Exception do
        begin
        end;
      end;

      tempAccount.Free;
    end;
  finally
    DeleteFile(tpath.Combine(HOME_PATH, 'hodler.wallet.dat'));
    DeleteFile(tpath.Combine(HOME_PATH, 'hodler.fiat.dat'));
  end;
end;

procedure parseWalletFile;
var
  ts: TStringList;
  i, j: integer;
  wd: TWalletInfo;
  JsonObject: TJsonObject;
  JSONArray: TJsonArray;
  JsonValue: TJsonValue;
  temp, name, order: string;
begin
  ts := TStringList.Create;
  ts.LoadFromFile(tpath.Combine(HOME_PATH, 'hodler.wallet.dat'));

  if ts.Text[low(ts.Text)] = '{' then
  begin
    JsonObject := TJsonObject(TJsonObject.ParseJSONValue(ts.Text));

    JSONArray := TJsonArray(JsonObject.GetValue('accounts'));

    frmhome.LanguageBox.ItemIndex :=
      StrToIntDef(JsonObject.GetValue<string>('languageIndex'), 0);
    frmhome.CurrencyConverter.setCurrency
      (JsonObject.GetValue<string>('currency'));

    lastClosedAccount := JsonObject.GetValue<string>('lastOpen');

    currentStyle := JsonObject.GetValue<string>('styleName');

    if JsonObject.TryGetValue<string>('AllowToSendData', temp) then
      USER_ALLOW_TO_SEND_DATA := strToBooldef(temp, false)
    else
      USER_ALLOW_TO_SEND_DATA := true;
    frmhome.SendErrorMsgSwitch.IsChecked := USER_ALLOW_TO_SEND_DATA;
    // JsonObject.AddPair('AllowToSendData' , boolToStr(USER_ALLOW_TO_SEND_DATA) );

    SetLength(AccountsNames, JSONArray.Count);
    i := 0;
    for JsonValue in JSONArray do
    begin
      if JsonValue.TryGetValue<string>('name', name) then
      begin
        AccountsNames[i].name := name;
        try
          AccountsNames[i].order :=
            StrToIntDef(JsonValue.GetValue<string>('order'), i);
        except
          on E: Exception do
            AccountsNames[i].order := i;
        end;
        //
      end
      else
      begin
        AccountsNames[i].name := JsonValue.Value;

      end;

      Inc(i);
    end;

    JsonObject.Free;
  end
  else
  begin

    frmhome.LanguageBox.ItemIndex := StrToIntDef(ts[0], 0);
    frmhome.CurrencyConverter.setCurrency(ts[1]);

    lastClosedAccount := ts[2];

    SetLength(AccountsNames, StrToIntDef(ts[3], 0));
    for i := 0 to StrToIntDef(ts[3], 0) - 1 do
    begin
      AccountsNames[i].name := ts[4 + i];
    end;

  end;

  ts.Free;

end;

procedure updateBalanceLabels(coinid: integer = -1);
var
  i: integer;
  component: TLabel;
  fmxObj: TfmxObject;
  panel: TPanel;
  cc: cryptoCurrency;
  bal: TBalances;
begin

  for i := 0 to frmhome.walletList.Content.ChildrenCount - 1 do
  begin
    panel := TPanel(frmhome.walletList.Content.Children[i]);
    cc := cryptoCurrency(panel.TagObject);

    if cc is TWalletInfo then
    begin
      if (TWalletInfo(cc).coin <> coinid) and (coinid <> -1) then
        continue;
    end;

    for fmxObj in panel.Children do
    begin

      if fmxObj.TagString = 'balance' then
      begin
        try

          if cc.rate >= 0 then
          begin
            if cc is TWalletInfo then
            begin

              if TWalletInfo(cc).coin in [4, 8] then
              begin
                if TWalletInfo(cc).coin = 4 then
                  TLabel(fmxObj).Text :=
                    BigIntegerBeautifulStr
                    (cc.confirmed + bal.unconfirmed.AsInt64, cc.decimals) +
                    '    ' + floatToStrF(cc.getFiat(), ffFixed, 15, 2) + ' ' +
                    frmhome.CurrencyConverter.symbol;
                if TWalletInfo(cc).coin = 8 then
                begin
                  TLabel(fmxObj).Text := BigIntegerBeautifulStr(cc.confirmed,
                    cc.decimals) + '    ' + floatToStrF(cc.getConfirmedFiat(),
                    ffFixed, 15, 2) + ' ' + frmhome.CurrencyConverter.symbol;
                  if cc.unconfirmed > 0 then
                    TLabel(fmxObj).Text := TLabel(fmxObj).Text + #13#10 +
                      ' Unpocketed ' + BigIntegerBeautifulStr(cc.unconfirmed,
                      cc.decimals) + '    ' +
                      floatToStrF(cc.getunConfirmedFiat(), ffFixed, 15, 2) + ' '
                      + frmhome.CurrencyConverter.symbol
                end;
              end
              else
              begin
                bal := CurrentAccount.aggregateBalances(TWalletInfo(cc));

                TLabel(fmxObj).Text := BigIntegerBeautifulStr
                  (bal.confirmed + bal.unconfirmed.AsInt64, cc.decimals) +
                  '    ' + floatToStrF
                  (CurrentAccount.aggregateFiats(TWalletInfo(cc)), ffFixed, 15,
                  2) + ' ' + frmhome.CurrencyConverter.symbol;
              end;

            end
            else
            begin

              TLabel(fmxObj).Text := BigIntegerBeautifulStr(cc.confirmed,
                cc.decimals) + '    ' + floatToStrF(cc.getFiat(), ffFixed, 15,
                2) + ' ' + frmhome.CurrencyConverter.symbol;

            end;
          end
          else
          begin
            TLabel(fmxObj).Text := 'Syncing with network...';
          end;

        finally

        end;

      end;

      if fmxObj.TagString = 'price' then
      begin
        try
          if cc.rate >= 0.0 then
            TLabel(fmxObj).Text :=
              floatToStrF(frmhome.CurrencyConverter.calculate(cc.rate), ffFixed,
              15, 2) + ' ' + frmhome.CurrencyConverter.symbol + '/' +
              cc.shortcut
          else
            TLabel(fmxObj).Text := 'Syncing with network...';
        finally

        end;
      end;

    end;

  end;

end;

procedure updateNameLabels();
var
  i: integer;
  component: TLabel;
  fmxObj: TfmxObject;
  panel: TPanel;
  cc: cryptoCurrency;
begin

  for i := 0 to frmhome.walletList.Content.ChildrenCount - 1 do
  begin
    panel := TPanel(frmhome.walletList.Content.Children[i]);
    cc := cryptoCurrency(panel.TagObject);
    for fmxObj in panel.Children do
    begin
      try
        if fmxObj.TagString = 'name' then
        begin

          if cc is TWalletInfo then
          begin

            TLabel(fmxObj).Text := CurrentAccount.getDescription
              (TWalletInfo(cc).coin, TWalletInfo(cc).x);

          end
          else
          begin

            if cc.description = '' then
            begin
              TLabel(fmxObj).Text := cc.name + ' (' + cc.shortcut + ')';
            end
            else
              TLabel(fmxObj).Text := cc.description;

          end;

        end;

      finally

      end;
    end;

  end;

end;

procedure repaintWalletList;
var
  i: integer;
  T: Token;
begin

  updateBalanceLabels();
  updateNameLabels();

end;

function getHighestBlockNumber(T: Token): System.uint64;
var
  i, l: integer;
begin
  Result := 0;
  l := Length(T.history);
  if l = 0 then
    exit;

  for i := 0 to l - 1 do
    if T.history[i].lastBlock > Result then
      Result := T.history[i].lastBlock;

end;

function getUTXO(wallet: TWalletInfo): TUTXOS;
begin
  Result := wallet.UTXO;
end;

function parseUTXO(utxos: AnsiString; Y: integer): TUTXOS;
var
  ts: TStringList;
  i: integer;
  utxoCount: integer;
begin
  ts := TStringList.Create;
  ts.Text := utxos;
  utxoCount := ts.Count div 4;
  SetLength(Result, utxoCount);
  for i := 0 to utxoCount - 1 do
  begin
    Result[i].txid := ts.Strings[(i * 4) + 0];
    Result[i].n := StrToIntDef(ts.Strings[(i * 4) + 1], 0);
    Result[i].ScriptPubKey := ts.Strings[(i * 4) + 2];
    Result[i].amount := StrToInt64(ts.Strings[(i * 4) + 3]);
    Result[i].Y := Y;
  end;

  ts.Free;
end;

end.
