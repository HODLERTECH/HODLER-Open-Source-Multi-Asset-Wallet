unit WalletStructureData;

interface

uses cryptoCurrencyData, SysUtils, DateUtils, FMX.Graphics;

{$IFDEF ANDROID}

const
  StrStartIteration = 0;

type
  AnsiString = string;

type
  AnsiChar = Char;
{$ELSE}

const
  StrStartIteration = 1;
{$ENDIF}

type
  TAddressInfo = record
    witver: System.UInt8;
    Hash: AnsiString;
    scriptType: integer;
    outputScript: AnsiString;
    // witver : byte;
    scriptHash: AnsiString;
  end;

type
  TBitcoinOutput = record
    txid: AnsiString;
    n: integer;
    ScriptPubKey: AnsiString;
    Amount: System.uint64;
  end;

type
  TUTXOS = array of TBitcoinOutput;

type
  TWalletInfo = class(cryptoCurrency)
    pub: AnsiString;
    coin: integer;
    x: integer;
    y: integer;
    // addr: AnsiString;
    wid: integer;
    // confirmed: BigInteger;     //// AnsiString;
    // unconfirmed: BigInteger;   //// AnsiString;
    fiat: AnsiString;
    efee: array [0 .. 6] of AnsiString;
    UTXO: TUTXOS;
    nonce: System.UInt32;
    isCompressed: Boolean;
    // description: AnsiString;
    // rate : Double;    // coin cost in USD

    constructor Create(id: integer; _x: integer; _y: integer; _addr: AnsiString;
      _description: AnsiString; crTime: integer = -1);

    function getIcon(): TBitmap; override;

  end;

implementation

uses coinData;

constructor TWalletInfo.Create(id: integer; _x: integer; _y: integer;
  _addr: AnsiString; _description: AnsiString; crTime: integer = -1);
begin
  inherited Create();
  coin := id;
  x := _x;
  y := _y;
  addr := _addr;
  decimals := availablecoin[id].decimals;
  description := _description;
  ShortCut := availablecoin[id].ShortCut;
  name := availablecoin[id].displayName;
  isCompressed := true;

  if crTime = -1 then
    crTime := DateTimeToUnix(now);

  creationTime := crTime;
end;

function TWalletInfo.getIcon(): TBitmap;
begin
  result := getCoinIcon(coin);
end;

end.
