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
  System.DateUtils, System.Generics.Collections,
  System.Classes,
  System.Variants, Math,
  FMX.Types, FMX.Graphics, FMX.Controls, FMX.Forms, FMX.Dialogs, FMX.StdCtrls,
  FMX.Controls.Presentation, FMX.Styles, System.ImageList, FMX.ImgList, FMX.Ani,
  FMX.Layouts, FMX.ExtCtrls, Velthuis.BigIntegers, FMX.ScrollBox, FMX.Memo,
  FMX.Platform,
  FMX.TabControl, {$IF NOT DEFINED(LINUX)}System.Sensors,
  System.Sensors.Components, {$ENDIF} FMX.Edit, JSON,
  JSON.Builders, JSON.Readers, DelphiZXingQRCode,

  System.Net.HttpClientComponent, System.Net.HttpClient, keccak_n, tokenData,
  bech32,
  cryptoCurrencyData, WalletStructureData, AccountData,
  ClpCryptoLibTypes,
  ClpSecureRandom,
  ClpISecureRandom,
  ClpCryptoApiRandomGenerator,
  ClpICryptoApiRandomGenerator

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
    name: AnsiString;
    order: integer;
  end;

type
  THistoryHolder = class(TObject)
  public
    history: transactionHistory;
  end;

type
  popupWindow = class(TPopup)
  public

    messageLabel: TLabel;

    procedure _onEnd(sender: TObject);

    constructor Create(mess: AnsiString);

  end;

type
  popupWindowOK = class(TPopup)
  private

    _ImageLayout: TLayout;
    _Image: TImage;

    _OKbutton: TButton;
    _lblMessage: TLabel;

    _onOKButtonPress: TProc;

    procedure _OKButtonpress(sender: TObject);
    procedure _onEnd(sender: TObject);

  public
    constructor Create(OK: TProc; mess: AnsiString;
      ButtonText: AnsiString = 'OK'; icon: integer = 1);

  end;

type
  popupWindowYesNo = class(TPopup)
  private
    _lblMessage: TLabel;

    _ImageLayout: TLayout;
    _Image: TImage;

    _ButtonLayout: TLayout;
    _YesButton: TButton;
    _NoButton: TButton;

    _onYesPress: TProc;
    _onNoPress: TProc;

    procedure _onYesClick(sender: TObject);
    procedure _onNoClick(sender: TObject);
    procedure _OnExit(sender: TObject);

  public
    constructor Create(Yes, No: TProc; mess: AnsiString;
      YesText: AnsiString = 'Yes'; NoText: AnsiString = 'No';
      icon: integer = 2);
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
  : AnsiString;
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
procedure updateBalanceLabels();

Function StrToQRBitmap(Str: AnsiString; pixelSize: integer = 6): TBitmap;
procedure shareFile(path: AnsiString; deleteSourceFile: boolean = true);
procedure synchronizeCurrencyValue();
procedure LoadCurrencyFiatFromFile();
function bitcoinCashAddressToCashAddress(address: AnsiString;
  showName: boolean = true): AnsiString;
function BCHCashAddrToLegacyAddr(address: AnsiString): AnsiString;
function CreateNewAccount(name, pass, seed: AnsiString): Account;
procedure AddAccountToFile(ac: Account);

Procedure CreateNewAccountAndSave(name, pass, seed: AnsiString;
  userSaveSeed: boolean);

procedure CreatePanel(crypto: cryptoCurrency);

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
  CURRENT_VERSION = '0.3.1';

var
  AccountsNames: array of AccountItem;
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
  firstSync: boolean = true;
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

  newcoinID: nativeint;
  ImportCoinID: integer;

implementation

uses Bitcoin, uHome, base58, Ethereum, coinData, strutils, secp256k1,
  AccountRelated, TImageTextButtonData
{$IFDEF ANDROID}
{$ELSE}
{$ENDIF};

var
  bitmapData: TBitmapData;

function TSecureRandoms.CheckSecureRandom(const random: ISecureRandom): boolean;
begin
  result := true = RunChiSquaredTests(random);

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

  result := chi2;
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

  result := passes > 75;
end;

function TSecureRandoms.GetSha256Prng: string;
var
  &random: ISecureRandom;
begin
  random := TSecureRandom.GetInstance('SHA256PRNG');
  result := ToHex(random.GenerateSeed(256), 256)
end;

function ISecureRandomBuffer: AnsiString;
var
  SecureRandoms: TSecureRandoms;
begin
  SecureRandoms := TSecureRandoms.Create();
  result := misc.GetStrHashSHA256(SecureRandoms.GetSha256Prng);
  SecureRandoms.Free;
end;
/// ////////////////////////////////////////////////////////////////

function compareVersion(a, b: AnsiString): integer;
var
  a_arr, b_arr: TStringList;

begin
  result := 0;
  a_arr := SplitString(a, '.');
  b_arr := SplitString(b, '.');

  for i := 0 to min(a_arr.Count, b_arr.Count) - 1 do
  begin
    if StrToInt(a_arr[i]) > StrToInt(b_arr[i]) then
    begin
      result := 1;
      break;
    end;
    if StrToInt(a_arr[i]) < StrToInt(b_arr[i]) then
    begin
      result := -1;
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

  result := [];
  if From.ChildrenCount <> 0 then

    for fmxObj in From.Children do
    begin
      if fmxObj.TagString = tag then
        result := result + [fmxObj];

      tmp := getComponentsWithTagString(tag, fmxObj);
      if Length(tmp) <> 0 then

        result := result + tmp;

    end;

end;

function getUnusedAccountName(): AnsiString;
var
  i, nr: integer;
  found: boolean;
begin
  found := false;
  nr := 1;
  while not found do
  begin
    found := true;
    for i := 0 to Length(AccountsNames) - 1 do
    begin

      if AccountsNames[i].name = 'Wallet' + intToStr(nr) then
      begin
        nr := nr + 1;
        found := false;
      end;

    end;

  end;
  result := 'Wallet' + intToStr(nr);
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
  { DebugString := '';
    for i := 0 to length(Arr) - 1 do
    DebugString := DebugString + intTostr(arr[i]) + ' ';
    tthread.Synchronize(nil , procedure
    begin
    showmessage(debugString);
    end); }

  result := Length(arr);
  for i := 0 to Length(arr) - 1 do
  begin
    if arr[i] <> i then
    begin
      result := i;
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

  result := [];
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
        result := result + [i];
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
    image.Bitmap := getCoinIcon(i);
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
    image.Bitmap := getTokenIcon(Token.availableToken[i].id);
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
            popupWindowYesNo.Create(
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
    result := 0;
    exit;
  end;

  result := TAndroidHelper.context.checkCallingOrSelfPermission
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
  stylo.TrySetStyleFromResource(name);
  currentStyle := name;

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
      ((currentcoin.coin = 3) or (currentcoin.coin = 7));

    if not isEthereum then
    begin
      fee := StrFloatToBigInteger(wvFee.Text, availableCoin[currentcoin.coin]
        .decimals);
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
        availableCoin[currentcoin.coin].decimals);
      if FeeFromAmountSwitch.IsChecked then
      begin
        amount := amount - tempFee;
      end;

    end;

    if (isEthereum) and (isTokenTransfer) then
      amount := StrFloatToBigInteger(wvAmount.Text,
        CurrentCryptoCurrency.decimals);
    if (not isTokenTransfer) then
      if amount + tempFee > (CurrentAccount.aggregateBalances(currentcoin)
        .confirmed) then
      begin
        raise Exception.Create(dictionary('AmountExceed'));
        exit;
      end;
    if ((amount) = 0) or ((fee) = 0) then
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
    SendFromLabel.Text := currentcoin.addr;
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

    if (currentcoin.coin = 4) and (CurrentCryptoCurrency is Token) then
    begin
      WaitTimeLabel.Text :=
        'The transaction may get stuck because of the low bandwidth of the ethereum network';

      sendFeeLabel.Text := AnsiReverseString
        (cutEveryNChar(3, AnsiReverseString(fee.ToString))) + ' WEI';
    end
    else if (currentcoin.coin = 4) then
    begin
      WaitTimeLabel.Text :=
        'The transaction may get stuck because of the low bandwidth of the ethereum network';

      sendFeeLabel.Text := AnsiReverseString
        (cutEveryNChar(3, AnsiReverseString(fee.ToString))) + ' WEI';
    end
    else
    begin

      if AutomaticFeeRadio.IsChecked then
      begin
        WaitTimeLabel.Text := 'The transaction should be confirmed in the ' +
          intToStr(Round(FeeSpin.Value)) + ' nearest blocks, in about ' +
          intToStr(Round(FeeSpin.Value)) + '0 minutes';
      end
      else
      begin
        WaitTimeLabel.Text := 'Fee set by the user';
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
    result := LResponse.ContentAsString();
  except
    on E: Exception do
      result := '';
  end;
  req.Free;
end;

function searchTokens(InAddress: AnsiString; ac: Account = nil): integer;
var
  data: AnsiString;
  JsonValue: TJsonvalue;
  JsonTokens: TJsonArray;
  JsonIt: TJsonvalue;
  T: Token;
  address, name, decimals, symbol: AnsiString;
  i: integer;
  createToken: boolean;
  createFromList: boolean;
  CreateFromListIndex: integer;
  added: integer;
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

  data := getDataOverHTTP('https://api.ethplorer.io/getAddressInfo/' + InAddress
    + '?apiKey=freekey');
  JsonValue := TJSONObject.ParseJSONValue(data);

  if JsonValue is TJSONObject then
  begin
    if JsonValue.tryGetValue<TJsonArray>('tokens', JsonTokens) then
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
            T := Token.CreateCustom(address, name, symbol, StrToInt(decimals),
              InAddress);
          end;

          T.idInWallet := Length(ac.myTokens) + 10000;

          ac.addToken(T);
          ac.SaveFiles();
          if ac = CurrentAccount then
            CreatePanel(T);

        end;

      end;

  end;
  result := added;
end;

function isValidETHAddress(address: AnsiString): boolean;
begin
  result := address = getETHValidAddress(address);
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

    if StrToInt('$' + hex[i]) > 7 then
      ans := ans + UpperCase(addr[i])
    else
      ans := ans + lowercase(addr[i]);

  end;
  result := ans;
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
      AddAccountToFile(ac);

      ac.Free;

      Tthread.Synchronize(nil,
        procedure
        begin
          frmhome.FormShow(nil);
          AccountRelated.LoadCurrentAccount(name);

        end);

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
  result := ac;
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

procedure CreatePanel(crypto: cryptoCurrency);
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
      tempBalances := CurrentAccount.aggregateBalances(TWalletInfo(crypto));
      ccEmpty := (tempBalances.confirmed > 0);

    end;

  end
  else
  begin

    ccEmpty := (crypto.confirmed > 0);
  end;

  with frmhome.walletList do
  begin

    panel := TPanel.Create(frmhome.walletList);
    panel.Align := panel.Align.alTop;
    panel.Height := 48;
    panel.parent := frmhome.walletList;
    panel.TagObject := crypto;
    setBlackBackground(panel);
    panel.Position.Y := crypto.orderInWallet;
    panel.Opacity := 0;
    panel.AnimateFloat('Opacity', 1, 3);
    panel.Touch.InteractiveGestures := [TInteractiveGesture.LongTap];
    panel.OnGesture := frmhome.SwitchViewToOrganize;
{$IF DEFINED(ANDROID) OR DEFINED(IOS)}
    panel.OnTap := frmhome.OpenWalletView;
{$ELSE}
    panel.OnClick := frmhome.OpenWalletView;
{$ENDIF}
    adrLabel := TLabel.Create(frmhome.walletList);
    adrLabel.StyledSettings := adrLabel.StyledSettings - [TStyledSetting.size];
    adrLabel.TextSettings.Font.size := dashBoardFontSize;
    adrLabel.parent := panel;

    if crypto.description = '' then
    begin
      adrLabel.Text := crypto.name + ' (' + crypto.shortcut + ')';
    end
    else
      adrLabel.Text := crypto.description;
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
    balLabel := TLabel.Create(frmhome.walletList);
    balLabel.StyledSettings := balLabel.StyledSettings - [TStyledSetting.size];

    balLabel.parent := panel;
    if crypto.rate >= 0 then   // rate >= 0 after first sync
    begin
      if crypto is TWalletInfo then
      begin
        balLabel.Text := BigIntegerBeautifulStr
          (CurrentAccount.aggregateBalances(TWalletInfo(crypto)).confirmed,
          crypto.decimals) + '    ' + floatToStrF(crypto.getFiat, ffFixed, 15, 2)
          + ' ' + frmhome.CurrencyConverter.symbol;
      end
      else
      begin
        balLabel.Text := BigIntegerBeautifulStr(crypto.confirmed, crypto.decimals)
          + '    ' + floatToStrF(crypto.getFiat, ffFixed, 15, 2) + ' ' +
          frmhome.CurrencyConverter.symbol;
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
    coinIMG := TImage.Create(frmhome.walletList);
    coinIMG.parent := panel;
    if crypto is TWalletInfo then
      coinIMG.Bitmap := getCoinIcon(TWalletInfo(crypto).coin)
    else
      coinIMG.Bitmap := Token(crypto).image;

    coinIMG.Height := 32.0;
    coinIMG.Width := 50;
    coinIMG.Position.x := 4;
    coinIMG.Position.Y := 8;
    //
    price := TLabel.Create(panel);
    price.parent := panel;
    price.Visible := true;
    if crypto.rate >= 0 then
      price.Text := floatToStrF(frmhome.CurrencyConverter.calculate(crypto.rate),
        ffFixed, 18, 2)
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
  end;
end;

function inputType(input: TBitcoinOutput): integer;
begin
  if lowercase(Copy(input.ScriptPubKey, 0, 6)) = '76a914' then
    result := 0;
  if lowercase(Copy(input.ScriptPubKey, 0, 4)) = 'a914' then
    result := 1;
  if lowercase(Copy(input.ScriptPubKey, 0, 4)) = '0014' then
    result := 2;
  if lowercase(Copy(input.ScriptPubKey, 0, 4)) = '0020' then
    result := 3;
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

  intarr := Change(bech.values, 5, 8);

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
  result := Encode58(s);

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

    intarr[i] := StrToInt('$' + c);
    Inc(i);

  end;

  intarr := Change(intarr, 4, 5);
  checksum := CreateChecksum8('bitcoincash', intarr);

  temparr := concat(intarr, checksum);
  if showName then
    result := 'bitcoincash:' + bech32.rawencode(temparr)
  else
    result := bech32.rawencode(temparr)

end;

procedure synchronizeCurrencyValue();
var
  data: AnsiString;
  ts: TStringList;
  line: AnsiString;
  pair: TStringList;
  symbol: AnsiString;
begin
  data := getDataOverHTTP(HODLER_URL + 'fiat.php');

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

  ts.SaveToFile(TPath.Combine(HOME_PATH, 'hodler.fiat.dat'));

  ts.Free;

end;

procedure LoadCurrencyFiatFromFile();
var
  pair, ts: TStringList;
  line: AnsiString;
begin
  ts := TStringList.Create();
  try

    ts.LoadFromFile(TPath.Combine(HOME_PATH, 'hodler.fiat.dat'));

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
  result := availableCoin[coinid].p2pk = netbyte;

end;

function isSegwitAddress(address: AnsiString): boolean;
begin
  result := ((AnsiLeftStr(address, 3) = 'bc1') or
    (AnsiLeftStr(address, 4) = 'ltc1')) and (Length(address) > 39);
end;

function decodeAddressInfo(address: AnsiString; coinid: integer): TAddressInfo;
var
  addrHash: AnsiString;
  netbyte: AnsiString;
begin
  result.scriptType := -1;
  if coinid = 4 then
    exit; // Ethereum doesnt need this
  if isSegwitAddress(address) = false then
  begin
    addrHash := Copy(decode58(address), 0, 42);
    netbyte := Copy(addrHash, 0, 2);
    delete(addrHash, 1, 2);
    result.Hash := addrHash;
    if (netbyte <> coinData.availableCoin[coinid].p2sh) and
      (netbyte <> coinData.availableCoin[coinid].p2pk) then
      exit;
    if isP2PKH(netbyte, coinid) then
      result.scriptType := 0
    else
      result.scriptType := 1;
  end
  else
  begin
    result := segwit_addr_decode(address);
    if Length(result.Hash) = 40 then
      result.scriptType := 2;
    if Length(result.Hash) = 64 then
      result.scriptType := 3;

  end;

  case result.scriptType of
    0:
      result.outputScript := '76a914' + addrHash + '88ac';
    1:
      result.outputScript := 'a914' + addrHash + '87';
    2:
      result.outputScript := IntToHex(result.witver, 2) + '14' + result.Hash;
    3:
      result.outputScript := IntToHex(result.witver, 2) + '20' + result.Hash;
  end;
  result.scriptHash := reverseHexOrder(GetSHA256FromHex((result.outputScript)));
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
{$ENDIF}
begin
{$IFDEF ANDROID}
  mimetypeStr := TJMimeTypeMap.JavaClass.getSingleton.getMimeTypeFromExtension
    (StringToJString(StringReplace(TPath.GetExtension(path), '.', '', [])));
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
  saveDialog := TSaveDialog.Create(frmhome);
  saveDialog.Title := 'Save your text or word file';
  saveDialog.FileName := ExtractFileName(path);

  saveDialog.InitialDir :=
{$IFDEF IOS}TPath.GetSharedDocumentsPath{$ELSE}GetCurrentDir{$ENDIF};

  saveDialog.Filter := 'Zip File|*.zip';

  saveDialog.DefaultExt := 'zip';

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
    end;

  except
    on E: Exception do
    begin
      showmessage(E.ToString);
    end
  end;

end;

procedure loadDictionary(langData: WideString);
var
  data: AnsiString;
  StringReader: TStringReader;
  JSONTextReader: TJSONTextReader;
  JsonValue: TJsonvalue;
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
    globalFiat := globalFiat +
      Max((((ccrc.confirmed.AsDouble + Max(ccrc.unconfirmed.AsDouble, 0)) *
      ccrc.rate) / Math.Power(10, ccrc.decimals)), 0);
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
        if strToFloatDef(Tab[j].data, 0) >= strToFloatDef(Tab[j - 1].data, 0)
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
  SetLength(result, 0);
  SetLength(tmp, 0);
  for cc in CCArray do
  begin
    SetLength(result, Length(tmp) + Length(cc.history));
    insert(cc.history, tmp, Length(tmp) - Length(cc.history));
  end;
  Sort(tmp);
  result := tmp;
  SetLength(tmp, 0);
end;

procedure createHistoryList(wallet: cryptoCurrency; start: integer = 0;
stop: integer = 10);
var
  panel: TPanel;
  image: TImage;
  lbl: TLabel;
  addrLbl: TLabel;
  datalbl: TLabel;
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
    clearVertScrollBox(frmhome.TxHistory);

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
  if Length(hist) > 10 then
    frmhome.LoadMore.Visible := true;
  // {$ENDIF}
  if start > stop then
    start := 0;

  for i := start to stop do
  begin
    if i >= Length(hist) then
      exit;

    panel := TPanel.Create(frmhome.TxHistory);

    panel.Height := 40;
    panel.Visible := true;
    panel.tag := i;
    panel.TagFloat := strToFloatDef(hist[i].data, 0);
    panel.parent := frmhome.TxHistory;
    panel.Position.Y := (i * 40) + 0.1;
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

    addrLbl := TLabel.Create(panel);
    addrLbl.Visible := true;
    addrLbl.parent := panel;
    addrLbl.Width := 400;
    addrLbl.Height := 18;
    addrLbl.Position.x := 36;
    addrLbl.Position.Y := 0;
    if Length(hist[i].addresses) = 0 then
      addrLbl.Text := 'history damaged'
    else
      addrLbl.Text := hist[i].addresses[0];
    addrLbl.TextSettings.HorzAlign := TTextAlign.Leading;

    datalbl := TLabel.Create(panel);
    datalbl.Visible := true;
    datalbl.parent := panel;
    datalbl.Width := 400;
    datalbl.Height := 18;
    datalbl.Position.x := 36;

    datalbl.Position.Y := 18;
    datalbl.Text := FormatDateTime('dd mmm yyyy hh:mm',
      UnixToDateTime(strToIntdef(hist[i].data, 0)));
    datalbl.TextSettings.HorzAlign := TTextAlign.Leading;

    image := TImage.Create(panel);
    image.Width := 18;
    image.Height := 18;
    image.Position.x := 9;
    image.Position.Y := 9;
    image.Visible := true;
    image.parent := panel;

    if hist[i].typ = 'OUT' then
      image.Bitmap := frmhome.sendImage.Bitmap;
    if hist[i].typ = 'IN' then
      image.Bitmap := frmhome.receiveImage.Bitmap;

    lbl := TLabel.Create(panel);
    lbl.Align := TAlignLayout.Bottom;
    lbl.Height := 18;
    lbl.TextSettings.HorzAlign := TTextAlign.taTrailing;
    lbl.Visible := true;
    lbl.parent := panel;
    if (wallet is tWalletInfo) and (TwalletInfo(wallet).coin = 4) and (hist[i].CountValues = 0) then
    begin
      lbl.Text := 'Token transfer';
    end
    else
      lbl.Text := BigIntegerBeautifulStr(hist[i].CountValues, wallet.decimals);
    lbl.Margins.Right := 5;

    if hist[i].confirmation = 0 then
    begin
      panel.Opacity := 0.5;
      lbl.Opacity := 0.5;
      image.Opacity := 0.5;
      addrLbl.Opacity := 0.5;
      datalbl.Opacity := 0.5;
    end;

  end;

  { frmhome.TxHistory.Sort( function (a , b : TfmxObject) : integer
    begin
    if a.TagFloat > b.TagFloat then
    exit(1);
    if a.TagFloat < b.TagFloat then
    exit(-1);
    if a.TagFloat = b.TagFloat then
    exit(0);
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
  result := true;

  for i := Low(prefix) to High(prefix) do
  begin
    if prefix[i] <> Str[i] then
      result := false;
  end;

end;

function parseQRCode(Str: AnsiString): TStringList;
begin

  Str := StringReplace(Str, '?', #13#10, [rfReplaceAll]);
  Str := StringReplace(Str, ':', #13#10, []);
  Str := StringReplace(Str, '&', #13#10, [rfReplaceAll]);
  Str := StringReplace(Str, '=', #13#10, [rfReplaceAll]);
  result := TStringList.Create;
  result.Text := Str;

end;

function BitmapDataToScaledBitmap(data: TBitmapData; scale: integer): TBitmap;
var
  x, Y, i, j: integer;
  temp: TBitmapData;

begin
  result := TBitmap.Create(data.Width * scale, data.Height * scale);

  if result.Map(TMapAccess.maReadWrite, temp) then
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

    result.Unmap(temp);
  end;

end;

constructor popupWindowYesNo.Create(Yes: TProc; No: TProc; mess: AnsiString;
YesText: AnsiString = 'Yes'; NoText: AnsiString = 'No'; icon: integer = 2);
var
  panel, Panel2: TPanel;
  rect: TRectangle;
  i: integer;
begin
  inherited Create(frmhome.pageControl);

  _onYesPress := Yes;
  _onNoPress := No;

  parent := frmhome.pageControl;
  Height := 300;
  Width := 350;
  Placement := TPlacement.Center;

  Visible := true;
  PlacementRectangle := TBounds.Create(RectF(0, 0, 0, 0));

  panel := TPanel.Create(self);
  panel.Align := TAlignLayout.Client;
  panel.Height := 48;
  panel.Visible := true;
  panel.tag := i;
  panel.parent := self;

  rect := TRectangle.Create(panel);
  rect.parent := panel;
  rect.Align := TAlignLayout.Contents;
  rect.Fill.Color := frmhome.StatusBarFixer.Fill.Color;

  _ImageLayout := TLayout.Create(panel);
  _ImageLayout.Visible := true;
  _ImageLayout.Align := TAlignLayout.MostTop;
  _ImageLayout.parent := panel;
  _ImageLayout.Height := 96;

  _Image := TImage.Create(_ImageLayout);
  _Image.Align := TAlignLayout.Center;
  _Image.Width := 64;
  _Image.Height := 64;
  _Image.Visible := true;
  _Image.parent := _ImageLayout;
  case icon of
    0:
      _Image.Bitmap := frmhome.OKImage.Bitmap;
    1:
      _Image.Bitmap := frmhome.InfoImage.Bitmap;
    2:
      _Image.Bitmap := frmhome.warningImage.Bitmap;
    3:
      _Image.Bitmap := frmhome.ErrorImage.Bitmap;
  end;

  _lblMessage := TLabel.Create(panel);
  _lblMessage.Align := TAlignLayout.Client;
  _lblMessage.Visible := true;
  _lblMessage.parent := panel;
  _lblMessage.Text := mess;
  _lblMessage.TextSettings.HorzAlign := TTextAlign.Center;

  _ButtonLayout := TLayout.Create(panel);
  _ButtonLayout.Visible := true;
  _ButtonLayout.Align := TAlignLayout.MostBottom;
  _ButtonLayout.parent := panel;
  _ButtonLayout.Height := 48;

  _YesButton := TButton.Create(_ButtonLayout);
  _YesButton.Align := TAlignLayout.Right;
  _YesButton.Width := _ButtonLayout.Width / 2;
  _YesButton.Visible := true;
  _YesButton.parent := _ButtonLayout;
  _YesButton.Text := YesText;
  _YesButton.OnClick := _onYesClick;

  _NoButton := TButton.Create(_ButtonLayout);
  _NoButton.Align := TAlignLayout.Left;
  _NoButton.Width := _ButtonLayout.Width / 2;
  _NoButton.Visible := true;
  _NoButton.parent := _ButtonLayout;
  _NoButton.Text := NoText;
  _NoButton.OnClick := _onNoClick;

  Popup();

  OnClosePopup := _OnExit;

end;

procedure popupWindowYesNo._OnExit(sender: TObject);
begin

  parent := nil;
  Tthread.CreateAnonymousThread(
    procedure
    begin
      Tthread.Synchronize(nil,
        procedure
        begin
          DisposeOf();
        end);
    end).start;

end;

procedure popupWindowYesNo._onYesClick;
begin
  IsOpen := false;
  _onYesPress();

  ClosePopup();
  // Release;

end;

procedure popupWindowYesNo._onNoClick;
begin
  IsOpen := false;

  _onNoPress();

  ClosePopup();
  // Release;

end;

constructor popupWindowOK.Create(OK: TProc; mess: AnsiString;
ButtonText: AnsiString = 'OK'; icon: integer = 1);
var
  panel, Panel2: TPanel;
  i: integer;
  rect: TRectangle;
begin
  inherited Create(frmhome.pageControl);
  parent := frmhome.pageControl;
  Height := 200;
  Width := 300;
  Placement := TPlacement.Center;

  Visible := true;
  PlacementRectangle := TBounds.Create(RectF(0, 0, 0, 0));

  panel := TPanel.Create(self);
  panel.Align := TAlignLayout.Client;
  panel.Height := 48;
  panel.Visible := true;
  panel.tag := i;
  panel.parent := self;

  rect := TRectangle.Create(panel);
  rect.parent := panel;
  rect.Align := TAlignLayout.Contents;
  rect.Fill.Color := frmhome.StatusBarFixer.Fill.Color;

  _ImageLayout := TLayout.Create(panel);
  _ImageLayout.Visible := true;
  _ImageLayout.Align := TAlignLayout.MostTop;
  _ImageLayout.parent := panel;
  _ImageLayout.Height := 96;

  _Image := TImage.Create(_ImageLayout);
  _Image.Align := TAlignLayout.Center;
  _Image.Width := 64;
  _Image.Height := 64;
  _Image.Visible := true;
  _Image.parent := _ImageLayout;
  case icon of
    0:
      _Image.Bitmap := frmhome.OKImage.Bitmap;
    1:
      _Image.Bitmap := frmhome.InfoImage.Bitmap;
    2:
      _Image.Bitmap := frmhome.warningImage.Bitmap;
    3:
      _Image.Bitmap := frmhome.ErrorImage.Bitmap;
  end;

  _lblMessage := TLabel.Create(panel);
  _lblMessage.Align := TAlignLayout.Client;
  _lblMessage.Visible := true;
  _lblMessage.parent := panel;
  _lblMessage.Text := mess;
  _lblMessage.TextSettings.HorzAlign := TTextAlign.Center;

  _OKbutton := TButton.Create(panel);
  _OKbutton.Align := TAlignLayout.Bottom;
  _OKbutton.Height := 48;
  _OKbutton.Visible := true;
  _OKbutton.parent := panel;
  _OKbutton.OnClick := _OKButtonpress;
  _OKbutton.Text := ButtonText;

  _onOKButtonPress := OK;

  self.OnClosePopup := _onEnd;

  Popup();
end;

procedure popupWindowOK._OKButtonpress(sender: TObject);
begin
  IsOpen := false;
  _onOKButtonPress();

  ClosePopup();

end;

procedure popupWindowOK._onEnd(sender: TObject);
begin

  parent := nil;
  Tthread.CreateAnonymousThread(
    procedure
    begin
      Tthread.Synchronize(nil,
        procedure
        begin
          DisposeOf();
        end);
    end).start;
end;

constructor popupWindow.Create(mess: AnsiString);
var
  panel, Panel2: TPanel;
  i: integer;
  rect: TRectangle;
begin
  inherited Create(frmhome.pageControl);

  parent := frmhome.pageControl;
  Height := 100;
  Width := 300;
  Placement := TPlacement.Center;

  Visible := true;
  PlacementRectangle := TBounds.Create(RectF(0, 0, 0, 0));

  panel := TPanel.Create(self);
  panel.Align := TAlignLayout.Client;
  panel.Visible := true;
  panel.tag := i;
  panel.parent := self;

  rect := TRectangle.Create(panel);
  rect.parent := panel;
  rect.Align := TAlignLayout.Contents;
  rect.Fill.Color := frmhome.StatusBarFixer.Fill.Color;

  messageLabel := TLabel.Create(panel);
  messageLabel.Align := TAlignLayout.Client;
  messageLabel.Visible := true;
  messageLabel.parent := panel;
  messageLabel.Text := mess;
  messageLabel.TextSettings.HorzAlign := TTextAlign.Center;

  self.OnClosePopup := _onEnd;

  Popup();
end;

procedure popupWindow._onEnd(sender: TObject);
begin

  IsOpen := false;

  parent := nil;
  Tthread.CreateAnonymousThread(
    procedure
    begin
      Tthread.Synchronize(nil,
        procedure
        begin
          DisposeOf();
        end);
    end).start;

end;

function fromMnemonic(input: AnsiString): integer;
var
  i: integer;
  temp: AnsiString;
begin
  result := -1;
  for i := 0 to frmhome.wordList.Lines.Count - 1 do
  begin
    if input = frmhome.wordList.Lines.Strings[i] then
    begin
      result := i;
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
      result := '';
      popupWindow.Create(input[i] + ' ' + dictionary('NotExistInWorldlist'));
      exit;
    end;
    bi := bi + fromMnemonic(input[i]);
  end;

  result := bi.tohexString();

  result := bi.tohexString();
  while Length(result) < 64 do
    result := '0' + result;

end;

function toMnemonic(hex: AnsiString): AnsiString;
var
  tmp: AnsiString;
  part: integer;
  IntSeed: BigInteger;
begin
  part := 0;
  if (not IsHex(hex)) then
    result := ''
  else
  begin

    BigInteger.TryParse(hex, 16, IntSeed);

    while IntSeed > 0 do
    begin
      result := result + (frmhome.wordList.Lines.Strings[(IntSeed mod 2048)
        .asInteger]) + ' ';
      IntSeed := IntSeed div 2048;
    end;

  end;

end;

function getConfirmedAsString(wi: TWalletInfo): AnsiString;
begin
  result := BigIntegerToFloatStr(wi.confirmed, availableCoin[wi.coin].decimals);
end;

function isEthereum: boolean;
begin

  result := currentcoin.coin = 4;

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
    result := '0.00';
    exit;
  end;

  zeroCounter := 0;

  Str := num.ToDecimalString;
  temp := (Length(Str) - decimals);
  if temp > 8 then
  begin
    SetLength(Str, Length(Str) - decimals);
    result := Str;
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

    result := Str;
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

  result := BigInteger.Create(0);
  for i := Low(Str) to High(Str) do
  begin

    if flag then
      Inc(counter);

    if Char(Str[i]) <> separator then
    begin

      result := result * 10;
      result := result + integer(Str[i]) - integer('0');

    end
    else
    begin
      flag := true;
    end;

  end;

  while (counter < decimals) do
  begin
    result := result * 10;
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

  result := '';

  for i := 0 to decimals do
  begin
    result := result + '0';
  end;

  if Length(Str) >= Length(result) then
  begin
    result := Str;
  end
  else
  begin
    for i := High(Str) downto Low(Str) do
    begin
      result[High(result) - (high(Str) - i)] := Str[i];
    end;

  end;

  insert(FormatSettings.DecimalSeparator, result, High(result) - decimals +
    1{$IF DEFINED(ANDROID) OR DEFINED(IOS)} + 1{$ENDIF});

  SetLength(result, Length(result) - (decimals - precision));
  minus := Pos('-', result) > 1;
  if minus then
  begin
    result := StringReplace(result, '-', '0', [rfReplaceAll]);
    result := '-' + result;

  end;
  if AnsiContainsText(result, '-.') then
    result := StringReplace(result, '-.', '-0.', [rfReplaceAll]);
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
  DeleteFile(TPath.Combine(HOME_PATH, 'hodler.erc20.dat'));
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

  result := TBitmap.Create();
  result.SetSize(32, 32);

  if result.Map(TMapAccess.maReadWrite, bitmapData) then
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

  result.Unmap(bitmapData);

end;

// add SEP every N char in STR
function cutEveryNChar(n: integer; Str: AnsiString; sep: AnsiChar = ' ')
  : AnsiString;
var
  i, j: integer;
begin
  result := Str;
  //exit;
  if n < 0 then
    exit(Str);
  Inc(n);
  result := Str;

  for i := n to Length(Str) + (Length(Str) - 1) div (n - 1) do

  begin
    if i mod n = 0 then

      insert(sep, result, i);

  end;

end;

function removeSpace(Str: AnsiString): AnsiString;
begin
  result := Str;
  result := StringReplace(result, ' ', '', [rfReplaceAll]);
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
      coinIMG.Bitmap := frmhome.coinIconsList.Source[i].MultiResBitmap
        [0].Bitmap;
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
  result := '';
  for i := 0 to 31 do // keccack-256 digest
    result := result + IntToHex(bb[i], 2);
end;

function IsHex(s: string): boolean;
var
  i: integer;
begin
  s := UpperCase(s);
  result := true;
  for i := StrStartIteration to Length(s){$IF DEFINED(ANDROID) OR DEFINED(IOS)} - 1{$ENDIF} do
    if not(Char(s[i]) in ['0' .. '9']) and not(Char(s[i]) in ['A' .. 'F']) then
    begin
      result := false;
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
  result := TStateToHEX(K256Dig);

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
  result := TStateToHEX(K256Dig);

end;

function SplitString(Str: AnsiString; separator: AnsiChar = ' '): TStringList;
var
  ts: TStringList;
  i: integer;
begin
  Str := StringReplace(Str, separator, #13#10, [rfReplaceAll]);
  ts := TStringList.Create;
  ts.Text := Str;
  result := ts;

end;

function getStringFromImage(img: TBitmap): AnsiString;
begin

end;

function OCRFix(Str: AnsiString): AnsiString;
begin
  result := Str;
  result := StringReplace(result, 'O', 'o', [rfReplaceAll]);
  result := StringReplace(result, '0', 'o', [rfReplaceAll]);
  result := StringReplace(result, 'I', 'J', [rfReplaceAll]);
  result := StringReplace(result, 'l', 'J', [rfReplaceAll]);
end;

// try find wallet address in text and return it
function findAddress(Str: AnsiString): AnsiString;
var
  strArray: TStringList;
begin
  strArray := SplitString(Str);
  result := 'Not found';
  for i := 0 to strArray.Count - 1 do
  begin

    if base58.ValidateBitcoinAddress(trim(OCRFix(strArray[i]))) = true then
    begin
      result := strArray[i];
      strArray.Free;
      exit;
    end;

  end;

  for i := 0 to strArray.Count - 1 do
  begin

    if ((Length(strArray[i]) >= 25) and (Length(strArray[i]) <= 43)) then
    begin
      result := strArray[i];
      strArray.Free;
      exit;
    end;

  end;

  strArray.Free;
end;

function satToBtc(sat: AnsiString; decimals: integer): AnsiString;
begin
  result := floatToStrF((strToIntdef(sat, 0) / Power(10, decimals)), ffFixed,
    15, decimals);
end;

function satToBtc(num: BigInteger; decimals: integer): AnsiString;
begin
  result := BigIntegerToFloatStr(num, decimals);

end;

function inttoeth(data: System.uint64): AnsiString;
var
  ll: integer;
begin
  ll := ceil(Length(IntToHex(data, 0)) / 2);
  result := IntToHex(data, ll * 2);
end;

function inttoeth(data: BigInteger): AnsiString;
var
  ll: integer;
begin
  result := data.tohexString;
  if Length(result) mod 2 = 1 then
    result := '0' + result;

end;

function IntToTX(data: System.uint64; Padding: integer): AnsiString;
Begin
  // Keep padding!
  result := Copy(reverseHexOrder(IntToHex(data, Padding)), 0, Padding);
End;

function BIntTo256Hex(data: BigInteger; Padding: integer): AnsiString;
Begin
  result := data.tohexString;
  while Length(result) < Padding do
  begin
    result := '0' + result;
  end;
  // Keep padding!
  result := Copy((result), 0, Padding);
End;

function IntToTX(data: BigInteger; Padding: integer): AnsiString;
Begin
  result := data.tohexString;
  while Length(result) < Padding do
  begin
    result := '0' + result;
  end;
  // Keep padding!
  result := Copy(reverseHexOrder(result), 0, Padding);
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
    result := lowercase('&pub=' + API_PUB + '&nonce=' + nonce +
      '&hash=' + Hash);
    if Pos('?', aURL) = 0 then
      result := '?' + result;
  end
  else
    result := '';
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
  result := '';
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
      result := result + Codes64[x + 1];
    end;
  end;
  if a > 0 then
  begin
    x := b shl (6 - a);
    result := result + Codes64[x + 1];
  end;
end;

function Decode64(s: string): string;
var
  i: integer;
  a: integer;
  x: integer;
  b: integer;
begin
  result := '';
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
        result := result + chr(x);
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
begin
  result := 'NOCACHE';

  if (CurrentAccount = nil) or
    (fileExists(CurrentAccount.DirPath + '/cache.dat') = false) then
    exit;

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

      result := conv.FormattOstring(list.values[Hash]);
      conv.Free;
    end;
  finally
    list.Free;
  end;
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
            if fileExists(CurrentAccount.DirPath + '/cache.dat') then
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
    result := '';
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
    result := aResult;
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
  result := aURL;
end;

function getDataOverHTTP(aURL: String; useCache: boolean = true;
noTimeout: boolean = false): AnsiString;
var
  req: THTTPClient;
  LResponse: IHTTPResponse;
  urlHash: AnsiString;
begin
  aURL := ensureURL(aURL);
  urlHash := GetStrHashSHA256(aURL);
  if (firstSync and useCache) then
  begin
    result := loadCache(urlHash);
  end;
  try
    if ((result = 'NOCACHE') or (not firstSync) or (not useCache)) then
    begin

      req := THTTPClient.Create();
      if not noTimeout then
      begin

        req.ConnectionTimeout := 5000;
        req.ResponseTimeout := 5000;
      end;
      aURL := aURL + buildAuth(aURL);

      LResponse := req.get(aURL);
      result := apiStatus(aURL, LResponse.ContentAsString());
      try
        saveCache(urlHash, result);
      except
        on E: Exception do
        begin
        end

      end;
      if LResponse.StatusCode <> 200 then
        result := apiStatus(aURL, '', true);
    end;
  except
    on E: Exception do
    begin
      result := apiStatus(aURL, '', true);

    end;
  end;
  req.Free;
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
  if (firstSync and useCache) then
  begin
    result := loadCache(urlHash);
  end;
  try
    if ((result = 'NOCACHE') or (not firstSync) or (not useCache)) then
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
{$IFDEF  DEBUG} ts.SaveToFile('params' + urlHash + '.json'); {$ENDIF}
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
      result := apiStatus(aURL, asyncResponse);
      ts.Text := asyncResponse;
{$IFDEF  DEBUG} ts.SaveToFile(urlHash + '.json'); {$ENDIF}
      ts.Free;
      try
        saveCache(urlHash, result);
      except
        on E: Exception do
        begin
        end

      end;
      if LResponse.StatusCode <> 200 then
        result := apiStatus(aURL, '', true);
    end;
  except
    on E: Exception do
    begin
      result := apiStatus(aURL, '', true);

    end;
  end;
  req.Free;
end;

function hash160FromHex(H: AnsiString): AnsiString;
var
  ripemd160: TRIPEMD160Hash;
  i: integer;
  b: Byte;
  memstr: TMemoryStream;
begin
  memstr := TMemoryStream.Create;
  memstr.SetSize(int64(Length(H) div 2));
  memstr.Seek(int64(0), soFromBeginning);
{$IF DEFINED(ANDROID) OR DEFINED(IOS)}
  for i := 0 to (Length(H) div 2) - 1 do
  begin
    b := Byte(StrToInt('$' + Copy(H, ((i) * 2) + 1, 2)));
    memstr.Write(b, 1);
  end;
{$ELSE}
  for i := 1 to (Length(H) div 2) do
  begin
    b := Byte(StrToInt('$' + Copy(H, ((i - 1) * 2) + 1, 2)));
    memstr.Write(b, 1);
  end;

{$ENDIF}
  ripemd160 := TRIPEMD160Hash.Create;
  try
    ripemd160.OutputFormat := hexa;
    ripemd160.Unicode := noUni;
    result := ripemd160.HashStream(memstr);
  finally
    ripemd160.Free;
    memstr.Free;
  end;
end;

function isWalletDatExists: boolean;
var
  WDPath: AnsiString;
begin
  WDPath := TPath.Combine(HOME_PATH, 'hodler.wallet.dat');
  result := fileExists(WDPath);
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
    b := System.UInt8(StrToInt('$' + Copy(H, (i) * 2, 2)));
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
    b := Byte(StrToInt('$' + Copy(H, (i - 1) * 2 + 1, 2)));
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
  SetLength(bb, (Length(H) div 2));
{$IF (DEFINED(ANDROID) OR DEFINED(IOS))}
  for i := 0 to (Length(H) div 2) - 1 do
  begin
    b := System.UInt8(StrToInt('$' + Copy(H, ((i) * 2) + 1, 2)));
    bb[i] := b;
  end;
{$ELSE}
  for i := 1 to (Length(H) div 2) do
  begin
    b := System.UInt8(StrToInt('$' + Copy(H, ((i - 1) * 2) + 1, 2)));
    bb[i - 1] := b;
  end;

{$ENDIF}
  result := bb;
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
  result := HashSHA.HashAsString;

end;

function GetStrHashSHA256(Str: AnsiString): AnsiString;
var
  sha2: TSHA2Hash;

begin
  sha2 := TSHA2Hash.Create;
  sha2.HashSizeBits := 256;
  sha2.OutputFormat := hexa;
  sha2.Unicode := noUni;
  result := sha2.Hash(Str);
  sha2.Free;

end;

function GetStrHashSHA512(Str: AnsiString): AnsiString;
var
  HashSHA: THashSHA2;
begin
  HashSHA := THashSHA2.Create;
  HashSHA.GetHashString(Str);
  result := HashSHA.GetHashString(Str, SHA512);
end;

function GetStrHashBobJenkins(Str: AnsiString): AnsiString;
var
  Hash: THashBobJenkins;
begin
  Hash := THashBobJenkins.Create;
  Hash.GetHashString(Str);
  result := Hash.GetHashString(Str);
end;

function GetStrHashSHA512_256(Str: AnsiString): AnsiString;
var
  HashSHA: THashSHA2;
begin
  HashSHA := THashSHA2.Create;
  HashSHA.GetHashString(Str);
  result := HashSHA.GetHashString(Str, SHA512_256);
end;

function GetStrHashSHA512_224(Str: AnsiString): AnsiString;
var
  HashSHA: THashSHA2;
begin
  HashSHA := THashSHA2.Create;
  HashSHA.GetHashString(Str);
  result := HashSHA.GetHashString(Str, SHA512_224);
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
  result := s;
  if allowAnim then
  begin

    frmhome.TCAInfoPanel.Visible := false;
    Application.ProcessMessages;
  end;
end;

function TBytesToString(bb: Tbytes): WideString;
begin
  result := TEncoding.ANSI.GetString(bb);
end;

function speckStrPadding(data: AnsiString): AnsiString;
var
  lacking: integer;
begin

  lacking := 16 - (Length(data) mod 16);
  result := data + StringofChar(#0, lacking);
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
  result := cipher;
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
  result := trim(speck.Decrypt(data));
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
  result := cipher;
end;

function randomHexStream(size: integer): AnsiString;
var
  i: integer;
begin

  for i := 0 to size - 1 do
    result := result + IntToHex(random($FF), 2);

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
    b := System.UInt8(StrToInt('$' + Copy(tcaKey, ((i) * 2) + 1, 2)));
    bb[i] := b;
  end;
{$ELSE}
  for i := 1 to (Length(tcaKey) div 2) do
  begin
    b := System.UInt8(StrToInt('$' + Copy(tcaKey, ((i - 1) * 2) + 1, 2)));
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
  result := cipher;
end;

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
  result := '';
  repeat
    if Length(s) >= 2 then
    begin
      v := Copy(s, 0, 2);
      delete(s, 1, 2);
      result := v + result;
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
  result := GetSHA256FromHex(IntToHex(x, 32) + GetSHA256FromHex(IntToHex(coin,
    8) + GetSHA256FromHex(IntToHex(coin, 8) + IntToHex(x, 32) + MasterSeed +
    IntToHex(Y, 32))) + IntToHex(Y, 32));
  BigInteger.TryParse(result, 16, bi);
  if bi > secp256k1.getN then
    result := priv256forHD(coin, x, Y, GetStrHashSHA256(result));

  wipeAnsiString(MasterSeed);
end;

function seedToHumanReadable(seed: AnsiString): AnsiString;
var
  i: integer;
begin
  result := '* ::: ';
  for i := StrStartIteration to Length(seed) do
  begin
    result := result + seed[i];
{$IF DEFINED(ANDROID) OR DEFINED(IOS)}
    if i mod 1 = 0 then
      result := result + ' ';
    if i mod 7 = 0 then
{$ELSE}
    if i mod 2 = 0 then
      result := result + ' ';
    if i mod 8 = 0 then
{$ENDIF}
      result := result + ' :::  ';

  end;
  result := result + '*';
  wipeAnsiString(seed);
end;

procedure refreshWalletDat();
var
  wd: TWalletInfo;
  ts { , oldFile } : TStringList;
  i: integer;
  Flock: TObject;
  accObject, JsonObject: TJSONObject;
  JSONArray: TJsonArray;
begin
  Flock := TObject.Create;
  TMonitor.Enter(Flock);
  try
    if not fileExists(TPath.Combine(HOME_PATH, 'hodler.wallet.dat')) then
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

      accObject := TJSONObject.Create();
      accObject.AddPair('name', AccountsNames[i].name);
      accObject.AddPair('order', intToStr(i));

      JSONArray.AddElement(accObject);
    end;

    JsonObject := TJSONObject.Create();

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
    ts.SaveToFile(TPath.Combine(HOME_PATH, 'hodler.wallet.dat'));
    ts.Free;

  finally
    TMonitor.exit(Flock);
  end;

end;

procedure createWalletDat();
var
  ts: TStringList;
  genThr: Tthread;
  accObject, JsonObject: TJSONObject;
  JSONArray: TJsonArray;
begin

  JSONArray := TJsonArray.Create();

  for i := 0 to Length(AccountsNames) - 1 do
  begin
    if AccountsNames[i].name = '' then
      continue;

    accObject := TJSONObject.Create();
    accObject.AddPair('name', AccountsNames[i].name);
    accObject.AddPair('order', intToStr(i));

    JSONArray.AddElement(accObject);
  end;

  JsonObject := TJSONObject.Create();

  JsonObject.AddPair('languageIndex', intToStr(frmhome.LanguageBox.ItemIndex));
  JsonObject.AddPair('currency', frmhome.CurrencyConverter.symbol);
  JsonObject.AddPair('lastOpen', '');
  JsonObject.AddPair('accounts', JSONArray);
  JsonObject.AddPair('styleName', 'RT_WHITE');
  JsonObject.AddPair('AllowToSendData', boolToStr(true));

  ts := TStringList.Create;
  ts.Text := JsonObject.ToString;

  ts.SaveToFile(TPath.Combine(HOME_PATH, 'hodler.wallet.dat'));

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

  frmhome.pageControl.ActiveTab := frmhome.WaitWalletGenerate;

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
  filePath: AnsiString;
begin
  try
    for acname in AccountsNames do
    begin
      tempAccount := Account.Create(acname.name);
      try
        for filePath in tempAccount.Paths do
        begin
          ts := TStringList.Create;
          ts.LoadFromFile(filePath);
          ts.Text := StringofChar('@', Length(ts.Text));
          ts.SaveToFile(filePath);
          ts.Free;
          DeleteFile(filePath);
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
    DeleteFile(TPath.Combine(HOME_PATH, 'hodler.wallet.dat'));
    DeleteFile(TPath.Combine(HOME_PATH, 'hodler.fiat.dat'));
  end;
end;

procedure parseWalletFile;
var
  ts: TStringList;
  i, j: integer;
  wd: TWalletInfo;
  JsonObject: TJSONObject;
  JSONArray: TJsonArray;
  JsonValue: TJsonvalue;
  temp, name, order: AnsiString;
begin
  ts := TStringList.Create;
  ts.LoadFromFile(TPath.Combine(HOME_PATH, 'hodler.wallet.dat'));

  if ts.Text[low(ts.Text)] = '{' then
  begin
    JsonObject := TJSONObject(TJSONObject.ParseJSONValue(ts.Text));

    JSONArray := TJsonArray(JsonObject.GetValue('accounts'));

    frmhome.LanguageBox.ItemIndex :=
      StrToInt(JsonObject.GetValue<string>('languageIndex'));
    frmhome.CurrencyConverter.setCurrency
      (JsonObject.GetValue<string>('currency'));

    lastClosedAccount := JsonObject.GetValue<string>('lastOpen');

    currentStyle := JsonObject.GetValue<string>('styleName');

    if JsonObject.tryGetValue<AnsiString>('AllowToSendData', temp) then
      USER_ALLOW_TO_SEND_DATA := strToBool(temp)
    else
      USER_ALLOW_TO_SEND_DATA := true;
    frmhome.SendErrorMsgSwitch.IsChecked := USER_ALLOW_TO_SEND_DATA;
    // JsonObject.AddPair('AllowToSendData' , boolToStr(USER_ALLOW_TO_SEND_DATA) );

    SetLength(AccountsNames, JSONArray.Count);
    i := 0;
    for JsonValue in JSONArray do
    begin
      if JsonValue.tryGetValue<AnsiString>('name', name) then
      begin
        AccountsNames[i].name := name;
        try
          AccountsNames[i].order :=
            StrToInt(JsonValue.GetValue<string>('order'));
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

    frmhome.LanguageBox.ItemIndex := StrToInt(ts[0]);
    frmhome.CurrencyConverter.setCurrency(ts[1]);

    lastClosedAccount := ts[2];

    SetLength(AccountsNames, StrToInt(ts[3]));
    for i := 0 to StrToInt(ts[3]) - 1 do
    begin
      AccountsNames[i].name := ts[4 + i];
    end;

  end;

  ts.Free;

end;

procedure updateBalanceLabels();
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
    for fmxObj in panel.Children do
    begin

      if fmxObj.TagString = 'balance' then
      begin
        try


          if cc.rate >= 0 then
          begin
            if cc is TWalletInfo then
            begin

              if TWalletInfo(cc).coin = 4 then
              begin

                TLabel(fmxObj).Text := BigIntegerBeautifulStr
                  (cc.confirmed + Max(bal.unconfirmed.AsInt64, 0), cc.decimals) +
                  '    ' + floatToStrF(cc.getFiat(), ffFixed, 15, 2) + ' ' +
                  frmhome.CurrencyConverter.symbol;
              end
              else
              begin
                bal := CurrentAccount.aggregateBalances(TWalletInfo(cc));

                TLabel(fmxObj).Text := BigIntegerBeautifulStr
                  (bal.confirmed + Max(bal.unconfirmed.AsInt64, 0), cc.decimals) +
                  '    ' + floatToStrF
                  (CurrentAccount.aggregateFiats(TWalletInfo(cc)), ffFixed, 15, 2)
                  + ' ' + frmhome.CurrencyConverter.symbol;
              end;

            end
            else
            begin

              TLabel(fmxObj).Text := BigIntegerBeautifulStr
                (cc.confirmed + Max(bal.unconfirmed.AsInt64, 0), cc.decimals) +
                '    ' + floatToStrF(cc.getFiat(), ffFixed, 15, 2) + ' ' +
                frmhome.CurrencyConverter.symbol;

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
          if cc.rate >= 0 then
            TLabel(fmxObj).Text :=
              floatToStrF(frmhome.CurrencyConverter.calculate(cc.rate), ffFixed,
              15, 2) + ' ' + frmhome.CurrencyConverter.symbol + '/' + cc.shortcut
          else
            TLabel(fmxObj).Text :='Syncing with network...';
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
          if cc.description = '' then
          begin
            TLabel(fmxObj).Text := cc.name + ' (' + cc.shortcut + ')';
          end
          else
            TLabel(fmxObj).Text := cc.description;
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
  result := 0;
  l := Length(T.history);
  if l = 0 then
    exit;

  for i := 0 to l - 1 do
    if T.history[i].lastBlock > result then
      result := T.history[i].lastBlock;

end;

function getUTXO(wallet: TWalletInfo): TUTXOS;
begin
  result := wallet.UTXO;
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
  SetLength(result, utxoCount);
  for i := 0 to utxoCount - 1 do
  begin
    result[i].txid := ts.Strings[(i * 4) + 0];
    result[i].n := StrToInt(ts.Strings[(i * 4) + 1]);
    result[i].ScriptPubKey := ts.Strings[(i * 4) + 2];
    result[i].amount := StrToInt64(ts.Strings[(i * 4) + 3]);
    result[i].Y := Y;
  end;

  ts.Free;
end;

end.
