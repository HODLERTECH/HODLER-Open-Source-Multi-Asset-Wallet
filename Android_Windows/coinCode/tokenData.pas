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
    stableCoin : boolean;
    stableValue : Single;

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
  const    // if address = ''  token no longer exists
    availableToken: array [0 .. 26] of tokenInfo = ((id: 10000;
      name: 'HODLER.TECH'; shortcut: 'HDL';
      address: '0x95c4be8534d69c248c0623c4c9a7a2a001c17337'; decimals: 18;

      ), (id: 10001; name: 'Maker'; shortcut: 'MKR';
      address: '0x9f8f72aa9304c8b593d555f12ef6589cc3a579a2'; decimals: 18;
      ), (id: 10002; name: 'Tronix'; shortcut: 'TRX';
      address: ''{'0xf230b790e05390fc8295f4d3f60332c93bed42e2'}; decimals: 6;
      ), (id: 10003; name: 'VeChain'; shortcut: 'VEN';
      address: ''{.....}; decimals: 18;
      ), (id: 10004; name: 'Binance Coin'; shortcut: 'BNB';
      address: '0xB8c77482e45F1F44dE1745F52C74426C631bDD52'; decimals: 18;
      ), (id: 10005; name: 'OmiseGO'; shortcut: 'OMG';
      address: '0xd26114cd6EE289AccF82350c8d8487fedB8A0C07'; decimals: 18;
      ), (id: 10006; name: 'ICON'; shortcut: 'ICX';
      address: ''{'0xb5a5f22694352c15b00323844ad545abb2b11028'}; decimals: 18;
      ), (id: 10007; name: 'Zilliqa'; shortcut: 'ZIL';
      address: ''{'0x05f4a42e251f2d52b8ed15e9fedaacfcef1fad27'}; decimals: 12;
      ), (id: 10008; name: 'Aeternity'; shortcut: 'AE';
      address: '0x5ca9a71b1d01849c0a95490cc00559717fcf0d1d'; decimals: 18;
      ), (id: 10009; name: 'Bytom'; shortcut: 'BTM';
      address: '0xcb97e65f07da24d46bcdd078ebebd7c6e6e3d750'; decimals: 8;
      ), (id: 10010; name: '0x'; shortcut: 'ZRX';
      address: '0xe41d2489571d322189246dafa5ebde1f4699f498'; decimals: 18;      ),

      (id: 10011; name: 'LAtoken'; shortcut: 'LA';
      address: '0xe50365f5d679cb98a1dd62d6f6e58e59321bcddf'; decimals: 18;)
      ,
      (id: 10012; name: 'Algory'; shortcut: 'ALG';
      address: '0x16b0a1a87ae8af5c792fabc429c4fe248834842b'; decimals: 18;),
      (id: 10013; name: 'Gemini dollar'; shortcut: 'GUSD';
      address: '0x056fd409e1d7a124bd7017459dfea2f387b6d5cd'; decimals: 2; stableCoin:true ; StableValue: 1 )
      ,
      (id: 10014; name: 'USD Coin'; shortcut: 'USDC';
      address: '0xa0b86991c6218b36c1d19d4a2e9eb0ce3606eb48'; decimals: 6; stableCoin:true ; StableValue: 1 )
      ,
      (id: 10015; name: 'Paxos Standard'; shortcut: 'PAX';
      address: '0x8e870d67f660d95d5be530380d0ec0bd388289e1'; decimals: 18; stableCoin:true ; StableValue: 1 )
      ,
      (id: 10016; name: 'TrueUSD'; shortcut: 'TUSD';
        address: '0x8dd5fbce2f6a956c3022ba3663759011dd51e73e'; decimals: 18; stableCoin:true ; StableValue: 1 ),
      (id: 10017; name: 'Bit-Z Token'; shortcut: 'BZ';
        address: '0x4375e7ad8a01b8ec3ed041399f62d9cd120e0063'; decimals: 18 ),
      (id: 10018; name: 'Moeda Loyalty Points MDA'; shortcut: 'MDA';
        address: '0x51db5ad35c671a87207d88fc11d593ac0c8415bd'; decimals: 18 ),
      (id: 10019; name: 'MobileGo'; shortcut: 'MGO';
        address: '0x40395044Ac3c0C57051906dA938B54BD6557F212'; decimals: 8 ),
      (id: 10020; name: 'Huobi Token'; shortcut: 'HT';
        address: '0x6f259637dcd74c767781e37bc6133cd6a68aa161'; decimals: 18 ),
      (id: 10021; name: 'TrueChain'; shortcut: 'TRUE';
        address: '0xA4d17AB1eE0efDD23edc2869E7BA96B89eEcf9AB'; decimals: 18 ),
      (id: 10022; name: 'Request Network'; shortcut: 'REQ';
        address: '0x8f8221afbb33998d8584a2b05749ba73c37a938a'; decimals: 18 ),
      (id: 10023; name: 'Dai'; shortcut: 'DAI';
        address: '0x89d24a6b4ccb1b6faa2625fe562bdd9a23260359'; decimals: 18; stableCoin:true ; StableValue: 1 ),
      (id: 10024; name: 'Crypto.com'; shortcut: 'MCO';
        address: '0xb63b606ac810a52cca15e44bb630fd42d8d1d83d'; decimals: 8 ),
      (id: 10025; name: 'Kyber Network'; shortcut: 'KNC';
        address: '0xdd974d5c2e2928dea5f71b9825b8b646686bd200'; decimals: 18 ),
      (id: 10026; name: 'Nebulas'; shortcut: 'NAS';
        address: '0x5d65D971895Edc438f465c17DB6992698a52318D'; decimals: 18 )
      );
  end;

type
  tokenERC20 = class(Token)

  end;

function getTokenIcon(id: Integer): TBitmap;

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

function getTokenIcon(id: Integer): TBitmap;
begin

  result := frmhome.TokenIcons.Source[id - 10000].MultiResBitmap[0].Bitmap;

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
