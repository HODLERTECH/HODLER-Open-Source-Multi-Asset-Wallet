unit cryptoCurrencyData;

interface

uses System.IOUtils, sysutils, StrUtils, Velthuis.BigIntegers, System.Classes,
  Math, // uHome ,
  FMX.Graphics, // misc,
  base58,
  FMX.Dialogs;

type
  transactionHistory = record
    typ: AnsiString;
    TransactionID: AnsiString;
    data: AnsiString;
    addresses: Array of AnsiString;
    values: Array of BigInteger;
    CountValues: BigInteger;
    lastBlock: System.uint64;

    function toString(): AnsiString;
    procedure FromString(str: AnsiString);

  end;

type
  cryptoCurrency = class

    creationTime: Integer;
    history: Array of transactionHistory;
    confirmed: BigInteger;
    unconfirmed: BigInteger;
    decimals: Integer;
    addr: AnsiString;
    rate: Double;
    description: AnsiString;
    orderInWallet: Integer;
    deleted: boolean;
    EncryptedPrivKey : AnsiString;
    name , ShortCut : AnsiString;

    constructor Create();
    destructor Destroy(); override ;

    function getIcon() : TBitmap; virtual ;

    function getFiat: Double;
  end;

implementation

uses misc, uHome;

function cryptoCurrency.getIcon() : TBitmap;
begin
  raise Exception.Create('getIcon not implemented');
end;


destructor cryptoCurrency.Destroy();
begin
  SetLength( history , 0 );
end;

constructor cryptoCurrency.Create();
begin
  deleted := false;
end;

function cryptoCurrency.getFiat: Double;
begin

  result := currencyConverter.calculate(confirmed.asDouble) * rate /
    Math.power(10, decimals);

end;

function transactionHistory.toString(): AnsiString;
var
  list: TstringList;
  i: Integer;
begin
  list := TstringList.Create();

  list.Add(typ);
  list.Add(TransactionID);
  list.Add(data);
  list.Add(inttostr(length(addresses)));
  for i := 0 to length(addresses) - 1 do
  begin

    list.Add(addresses[i]);
    list.Add(values[i].toString());

  end;
  list.Add(CountValues.toString());
  list.Add(inttostr(lastBlock));

  result := list.DelimitedText;

  list.Free;
end;

procedure transactionHistory.FromString(str: AnsiString);
var
  size: Integer;
  i: Integer;
  temp: BigInteger;
  list: TstringList;
begin

  list := SplitString(str, ',');

  typ := list.Strings[0];
  TransactionID := list.Strings[1];
  data := list.Strings[2];
  size := strtoIntDef(list.Strings[3], 0);

  setLength(addresses, size);
  setLength(values, size);

  for i := 0 to size - 1 do
  begin

    addresses[i] := list.Strings[4 + 2 * i];
    BigInteger.TryParse(list.Strings[5 + 2 * i], temp);
    values[i] := temp;

  end;
  BigInteger.TryParse(list.Strings[4 + 2 * size], temp);
  CountValues := temp;
  lastBlock := strToInt(list.Strings[5 + 2 * size]);

  list.Free;

end;

end.
