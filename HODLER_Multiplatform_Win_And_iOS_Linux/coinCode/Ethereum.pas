unit Ethereum;

interface

uses  secp256k1, HashObj, base58, SysUtils, FMX.Dialogs,
  Velthuis.BigIntegers , WalletStructureData;

function Ethereum_PublicAddrToWallet(pub: AnsiString;
  netbyte: AnsiString = '00'): AnsiString;
function Ethereum_createHD(coinid, x, y: integer; MasterSeed: AnsiString)
  : TWalletInfo;

implementation
uses misc;

function Ethereum_createHD(coinid, x, y: integer; MasterSeed: AnsiString)
  : TWalletInfo;
var
  pub: AnsiString;
  p: AnsiString;
begin

  p := priv256forhd(coinid, x, y, MasterSeed);
  result := TWalletInfo.Create(coinid, x, y,
    Ethereum_PublicAddrToWallet(secp256k1_get_public(p, true)), '');

  wipeAnsiString(MasterSeed);

end;

function Ethereum_PublicAddrToWallet(pub: AnsiString;
  netbyte: AnsiString = '00'): AnsiString;
var
  s: AnsiString;
begin
  delete(pub, 1, 2);
  s := Keccak256Hex(pub);
  delete(s, 1, 24);
  result := getETHValidAddress( Lowercase('0x' + s) );
end;

end.
