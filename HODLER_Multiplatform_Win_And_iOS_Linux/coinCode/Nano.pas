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
  ClpDigestUtilities, HlpIHash,misc

{$IFDEF ANDROID}, Androidapi.JNI.GraphicsContentViewText, Androidapi.JNI.JavaTypes,
  Androidapi.Helpers, Androidapi.JNI.Net, Androidapi.JNI.Os, Androidapi.JNI.Webkit,
  Androidapi.JNIBridge
{$ENDIF}
{$IFDEF MSWINDOWS}
  , WinApi.ShellApi

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
    hash: ansistring;
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

implementation

function nanoGetBlockHash(block: TNanoBlock): AnsiString;
var
  Blake2b: IHash;
  toHash: AnsiString;
begin
  Blake2b := THashFactory.TCrypto.CreateBlake2B_256();
  Blake2b.Initialize();
  toHash := '';
  if block.state then
  begin
    toHash := toHash + STATE_BLOCK_PREAMBLE;
    toHash := toHash + block.account;
    toHash := toHash + block.previous;
    toHash := toHash + block.representative;
    toHash := toHash + block.balance;
    if block.blockType = 'send' then
      toHash := toHash + block.destination;
    if block.blockType = 'receive' then
      toHash := toHash + block.source;
    if block.blockType = 'open' then
      toHash := toHash + block.source;
    if block.blockType = 'change' then
      toHash := toHash + STATE_BLOCK_ZERO;
  end
  else
  begin
       if block.blockType = 'send' then begin
        toHash := toHash + block.previous;
        toHash := toHash + block.destination;
        toHash := toHash + block.balance;
       end;
       if block.blockType = 'receive' then begin
        toHash := toHash + block.previous;
        toHash := toHash + block.source;
       end;
       if block.blockType = 'open' then begin
        toHash := toHash + block.source;
        toHash := toHash + block.representative;
        toHash := toHash + block.account;
       end;
       if block.blockType = 'change' then begin
        toHash := toHash + block.previous;
        toHash := toHash + block.representative;
       end;
  end;
  Blake2b.TransformBytes(hexatotbytes(toHash), 0, Length(toHash) div 2);
 Result:=Blake2b.TransformFinal.ToString();
end;

end.

