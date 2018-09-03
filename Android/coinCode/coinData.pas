unit coinData;

interface

uses System.IOUtils, sysutils, StrUtils,
  FMX.Graphics, base58, FMX.Dialogs , WalletStructureData;

function CreateCoin(id, x, y: Integer; MasterSeed: AnsiString;
  description: AnsiString = ''): TWalletInfo;
function getCoinIcon(id: Integer): TBitmap;
function isValidForCoin(id: Integer; address: AnsiString): Boolean;

type
  coinInfo = record
    id: Integer;
    displayName: AnsiString;
    name: AnsiString;
    shortcut: AnsiString;
    WifByte:AnsiString;
    p2sh: AnsiString;
    p2pk: AnsiString;
    flag: System.UInt32;
    decimals: smallint;

  end;

const
  // all supported coin
  availableCoin: array [0 .. 4] of coinInfo = ((id: 0; displayName: 'Bitcoin';
    name: 'bitcoin'; shortcut: 'BTC';wifByte: '80'; p2sh: '05'; p2pk: '00';

    flag: 0; decimals: 8;

    ), (id: 1; displayName: 'Litecoin'; name: 'litecoin'; shortcut: 'LTC'; wifByte: 'B0';
    p2sh: '05'; p2pk: '30';

    flag: 0; decimals: 8;

    ), (id: 1; displayName: 'DASH'; name: 'dash'; shortcut: 'DASH';wifByte: 'CC'; p2sh: '10';
    p2pk: '4c'; flag: 0; decimals: 8;

    ), (id: 1; displayName: 'Bitcoin Cash'; name: 'bitcoincash';
    shortcut: 'BCH';wifByte: '80'; p2sh: '05'; p2pk: '00';

    flag: 0; decimals: 8;

    ), (id: 1; displayName: 'Ethereum'; name: 'ethereum'; shortcut: 'ETH'; wifByte: '';
    p2pk: '00'; flag: 1; decimals: 18;

    )

    );

implementation

uses Bitcoin, Ethereum , misc , UHome;

function getCoinIcon(id: Integer): TBitmap;
begin
  result := frmhome.ImageList1.Source[id].MultiResBitmap[0].Bitmap;
end;

function CreateCoin(id, x, y: Integer; MasterSeed: AnsiString;
  description: AnsiString = ''): TWalletInfo;
begin
  case availableCoin[id].flag of
    0:
      result := Bitcoin_createHD(id, x, y, MasterSeed);
    1:
      result := Ethereum_createHD(id, x, y, MasterSeed);
  end;

  // if description <> '' then
  // begin
  result.description := description;
  /// end
  // else
  // result.description := result.addr;

  wipeAnsiString(MasterSeed);
end;

// check if given address is of given coin
function isValidForCoin(id: Integer; address: AnsiString): Boolean;
var
  str: AnsiString;
  x: Integer;
  info: TAddressInfo;
begin
  result := false;
  if availableCoin[id].flag = 0 then
  begin

    if (id = 3) and (leftstr(address, 12) = 'bitcoincash:') then
    begin
      result := true;

    end
    else
    begin

      info := decodeAddressInfo(address, id);
      if info.scriptType>=0 then result:=true;

    end;

    // showmessage(str + '  sh  ' + availablecoin[id].p2sh + '  pk  ' + availablecoin[id].p2pk);
  end
  else if availableCoin[id].flag = 1 then
  begin
    // showmessage(inttostr(length(address)));
    result := ((isHex(rightStr(address, 40))) and (length(address) = 42));
  end;

end;

end.
