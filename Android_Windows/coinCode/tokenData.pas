unit tokenData;

interface

uses System.IOUtils, sysutils, StrUtils, Velthuis.BigIntegers, System.Classes,
  FMX.Graphics, System.DateUtils,
  base58, JSon,
  FMX.Dialogs, cryptoCurrencydata;

type
  tokenInfo = record
    id: integer;
    name: AnsiString;
    shortcut: AnsiString;
    address: AnsiString;
    decimals: integer;

  end;

type
  Token = class(cryptoCurrency)
    // private

    id: integer;
    // _name: AnsiString;
    // _shortcut: AnsiString;
    _contractAddress: AnsiString;
    // decimals : Integer;
    _WalletID: integer;
    // addr : AnsiString;

  public
    idInWallet: integer;
    lastBlock: integer;

    constructor CreateCustom(ContractAddress: AnsiString; _name: AnsiString;
      _shortcut: AnsiString; decimalsint: integer;
      WalletAddress: AnsiString); overload;
    constructor Create(index: integer; WalletAddress: AnsiString); overload;
    constructor fromString(str: AnsiString);
    constructor fromStringList(list: TStringList);
    constructor fromJson( data : TJsonValue );

    function toJson(): TJSONObject;
    function send(address: AnsiString): boolean; virtual;
    function toString(): AnsiString; virtual;
    function getIcon(): TBitmap; override;

    // property name: AnsiString read _name;
    // property id : Integer read _id;
    property image: TBitmap read getIcon;
    // property shortcut: AnsiString read _shortcut;
    property ContractAddress: AnsiString read _contractAddress;
    // property decimals : Integer read _decimals;
    property walletID: integer read _WalletID;
    // property WalletAddress : AnsiString read _WalletAddress;

    // list all supported tokens
  const
    availableToken: array [0 .. 11] of tokenInfo = ((id: 10000;
      name: 'HODLER.TECH'; shortcut: 'HDL';
      address: '0x95c4be8534d69c248c0623c4c9a7a2a001c17337'; decimals: 18;

      ), (id: 10001; name: 'Maker'; shortcut: 'MKR';
      address: '0x9f8f72aa9304c8b593d555f12ef6589cc3a579a2'; decimals: 18;
      ), (id: 10002; name: 'Tronix'; shortcut: 'TRX';
      address: '0xf230b790e05390fc8295f4d3f60332c93bed42e2'; decimals: 6;
      ), (id: 10003; name: 'VeChain'; shortcut: 'VEN';
      address: '0xd850942ef8811f2a866692a623011bde52a462c1'; decimals: 18;
      ), (id: 10004; name: 'Binance Coin'; shortcut: 'BNB';
      address: '0xB8c77482e45F1F44dE1745F52C74426C631bDD52'; decimals: 18;
      ), (id: 10005; name: 'OmiseGO'; shortcut: 'OMG';
      address: '0xd26114cd6EE289AccF82350c8d8487fedB8A0C07'; decimals: 18;
      ), (id: 10006; name: 'ICON'; shortcut: 'ICX';
      address: '0xb5a5f22694352c15b00323844ad545abb2b11028'; decimals: 18;
      ), (id: 10007; name: 'Zilliqa'; shortcut: 'ZIL';
      address: '0x05f4a42e251f2d52b8ed15e9fedaacfcef1fad27'; decimals: 12;
      ), (id: 10008; name: 'Aeternity'; shortcut: 'AE';
      address: '0x5ca9a71b1d01849c0a95490cc00559717fcf0d1d'; decimals: 18;
      ), (id: 10009; name: 'Bytom'; shortcut: 'BTM';
      address: '0xcb97e65f07da24d46bcdd078ebebd7c6e6e3d750'; decimals: 8;
      ), (id: 10010; name: '0x'; shortcut: 'ZRX';
      address: '0xe41d2489571d322189246dafa5ebde1f4699f498'; decimals: 18;
      ),

      (id: 10011; name: 'LAtoken'; shortcut: 'LA';
      address: '0xe50365f5d679cb98a1dd62d6f6e58e59321bcddf'; decimals: 18;));
  end;

type
  tokenERC20 = class(Token)

  end;

implementation

uses misc, uHome;


constructor Token.fromJson( data : TJsonValue );
var
  temp : AnsiString;
begin

  data.TryGetValue<AnsiString>('name' ,name );
  data.TryGetValue<AnsiString>('shortCut' ,shortcut );
  data.TryGetValue<AnsiString>('contractAddress' ,_contractAddress );
  data.TryGetValue<AnsiString>('ETHAddress' ,addr );
  data.TryGetValue<AnsiString>('description' ,description );

  if data.TryGetValue<AnsiString>('innerID' , temp ) then
  begin
    id := strToInt(temp);
  end;
  if data.TryGetValue<AnsiString>('decimals' , temp ) then
  begin
    decimals := strToInt(temp);
  end;
  if data.TryGetValue<AnsiString>('walletID' , temp ) then
  begin
    _WalletID := strToInt(temp);
  end;

  if data.TryGetValue<AnsiString>('lastBlock' , temp ) then
  begin
    lastBlock := strToInt(temp);
  end;
  if data.TryGetValue<AnsiString>('timeStamp' , temp ) then
  begin
    creationTime := strToInt(temp);
  end;
  if data.TryGetValue<AnsiString>('panelYPosition' , temp ) then
  begin
    orderInWallet := strToInt(temp);
  end;



end;

function Token.toJson(): TJSONObject;
var
  dataJson : TJsonObject;
begin

  dataJson := TJSONObject.Create();

  dataJson.AddPair('innerID' , inttoStr(id) );
  dataJson.AddPair('name' ,name );
  dataJson.AddPair('shortCut' ,shortcut );
  dataJson.AddPair('contractAddress' ,_contractAddress );
  dataJson.AddPair('decimals' , inttostr(decimals) );
  dataJson.AddPair('walletID' ,intToStr(_WalletID) );
  dataJson.AddPair('ETHAddress' ,addr );
  dataJson.AddPair('lastBlock' ,intToStr(lastBlock) );
  dataJson.AddPair('timeStamp' , intToStr(creationTime) );
  dataJson.AddPair('description' ,description );
  dataJson.AddPair('panelYPosition' ,intToStr(orderInWallet) );

  result := dataJson;

end;

// return token icon  or generate syntetic when icon doesn't exist
function Token.getIcon(): TBitmap;
begin
  // sry
  if (id >= 10000) and (id < 10000 + length(availableToken)) then
  begin
    result := frmhome.TokenIcons.Source[id - 10000].MultiResBitmap[0].Bitmap;
  end
  else
    result := generateIcon(ContractAddress);

end;

// return string      you can build a token from it
function Token.toString: AnsiString;
begin
  result := inttostr(id) + '|' + name + '|' + shortcut + '|' + ContractAddress +
    '|' + inttostr(decimals) + '|' + inttostr(walletID) + '|' + addr + '|' +
    inttostr(lastBlock) + '|' + confirmed.toString + '|' +
    inttostr(creationTime) + '|' + description + '|' +
    inttostr(orderInWallet) + '|';
end;

// custom token constructor
constructor Token.CreateCustom(ContractAddress: AnsiString; _name: AnsiString;
  _shortcut: AnsiString; decimalsint: integer; WalletAddress: AnsiString);
begin
  inherited Create();
  creationTime := DateTimetoUnix(Now);

  id := -1;
  _contractAddress := ContractAddress;
  name := _name;
  shortcut := _shortcut;
  decimals := decimalsint;
  addr := WalletAddress;

end;

constructor Token.Create(index: integer; WalletAddress: AnsiString);
begin
  inherited Create();
  creationTime := DateTimetoUnix(Now);

  id := Token.availableToken[index].id;
  _contractAddress := Token.availableToken[index].address;;
  decimals := Token.availableToken[index].decimals;
  addr := WalletAddress;
  name := Token.availableToken[index].name;
  shortcut := Token.availableToken[index].shortcut;

  lastBlock := 0;
end;

// construct token from string
constructor Token.fromString(str: AnsiString);
var
  strList: TStringList;
begin
  // inherited create();
  strList := SplitString(str, '|');
  fromStringList(strList);

end;

// construct token from list of single string
constructor Token.fromStringList(list: TStringList);
var
  bi: BigInteger;
begin
  inherited Create();
  try
    if list.Count <> 13 then
    begin
      showmessage('LOADING TOKEN ERROR ' + inttostr(list.Count));
      exit;
    end;

    id := strtoInt(list[0]);
    name := list[1];
    shortcut := list[2];
    _contractAddress := list[3];
    decimals := strtoInt(list[4]);
    _WalletID := strtoInt(list[5]);
    addr := list[6];
    lastBlock := strtointdef(trim(list[7]), 0);
    BigInteger.TryParse(list[8], 10, bi);
    confirmed := bi;
    creationTime := strtoInt(list[9]);
    description := list[10];
    orderInWallet := strtoInt(list[11]);
  except
    on E: Exception do

  end;
end;

function Token.send(address: AnsiString): boolean;
begin

end;

end.
