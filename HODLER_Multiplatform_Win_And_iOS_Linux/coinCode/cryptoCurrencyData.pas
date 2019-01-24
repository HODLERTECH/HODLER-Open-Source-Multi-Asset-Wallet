unit cryptoCurrencyData;

interface

uses System.IOUtils, sysutils, StrUtils, Velthuis.BigIntegers, System.Classes,
  Math, // uHome ,
  FMX.Graphics, // misc,
  base58, Json,
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
    confirmation: System.uint64;
    function toString(): AnsiString;
    procedure FromString(str: AnsiString);
    function toJsonValue(): TJsonValue;
    procedure fromJsonValue(JsonValue: TJsonValue);

  end;

function compareHistory(a, b: transactionHistory): integer;

type
  TxHistory = array of transactionHistory;

type
  cryptoCurrency = class

    creationTime: integer;
    history: TxHistory;
    confirmed: BigInteger;
    unconfirmed: BigInteger;
    decimals: integer;
    addr: AnsiString;
    rate: Double;
    description: AnsiString;
    orderInWallet: integer;
    deleted: boolean;
    EncryptedPrivKey: AnsiString;
    name, ShortCut: AnsiString;

    constructor Create();
    destructor Destroy(); override;

    function getIconResource(): TStream; virtual;

    function getFiat: Double;
    function getUnconfirmedFiat(): Double;
    function getConfirmedFiat(): Double;
  end;

type
  TCryptoCurrencyArray = array of cryptoCurrency;

implementation

uses misc, uHome;

function compareHistory(a, b: transactionHistory): integer;
begin

  if strToFloatDef(a.data, 0) > strToFloatDef(b.data, 0) then
    exit(1);
  if strToFloatDef(a.data, 0) < strToFloatDef(b.data, 0) then
    exit(-1);

  result := CompareStr(a.TransactionID, b.TransactionID);
end;

function cryptoCurrency.getIconResource(): TStream;
begin
  raise Exception.Create('getIcon not implemented');
end;

destructor cryptoCurrency.Destroy();
begin
  SetLength(history, 0);
end;

constructor cryptoCurrency.Create();
begin
  rate := -1;
  deleted := false;
  orderInWallet := maxint;
end;

function cryptoCurrency.getUnconfirmedFiat(): Double;
var
  d: Double;
begin
  d := unconfirmed.asDouble;

  result := frmHome.currencyConverter.calculate(d) * rate /
    Math.power(10, decimals);
end;

function cryptoCurrency.getConfirmedFiat(): Double;
var
  d: Double;
begin
  d := confirmed.asDouble;
  { if d < 0 then
    d := 0.0; }
  result := frmHome.currencyConverter.calculate(d) * rate /
    Math.power(10, decimals);
end;

function cryptoCurrency.getFiat: Double;
var
  d: Double;
begin
  d := confirmed.asDouble + unconfirmed.asDouble;
  if d < 0 then
    d := 0.0;
  result := frmHome.currencyConverter.calculate(d) * rate /
    Math.power(10, decimals);

end;

function transactionHistory.toJsonValue(): TJsonValue;
var
  HistJson: TJsonObject;
  addrArray: TjsonArray;
  addrValJson: TJsonObject;
  i: integer;
begin
  HistJson := TJsonObject.Create();

  HistJson.AddPair('type', typ);
  HistJson.AddPair('transactionID', TransactionID);
  HistJson.AddPair('timeStamp', data);
  HistJson.AddPair('countValues', CountValues.toString());
  HistJson.AddPair('lastBlock', inttostr(lastBlock));
  HistJson.AddPair('confirmation', inttostr(confirmation));

  addrArray := TjsonArray.Create();

  for i := 0 to Length(addresses) - 1 do
  begin

    addrValJson := TJsonObject.Create;
    addrValJson.AddPair('address', addresses[i]);
    addrValJson.AddPair('value', values[i].toString());

    addrArray.Add(addrValJson);

  end;

  HistJson.AddPair('addressList', addrArray);
  result := HistJson;

end;

procedure transactionHistory.fromJsonValue(JsonValue: TJsonValue);
var
  i: integer;
  conf, lastB, temp, countVal: AnsiString;
  addrlist: TjsonArray;
  JsonIt: TJsonValue;

begin

  JsonValue.TryGetValue<AnsiString>('type', typ);
  JsonValue.TryGetValue<AnsiString>('transactionID', TransactionID);
  JsonValue.TryGetValue<AnsiString>('timeStamp', data);
  if JsonValue.TryGetValue<AnsiString>('confirmation', conf) then
  begin
    confirmation := strToIntDef(conf, 0);
  end;
  if JsonValue.TryGetValue<AnsiString>('countValues', countVal) then
  begin
    BigInteger.TryParse(countVal, 10, CountValues);
  end;
  if JsonValue.TryGetValue<AnsiString>('lastBlock', lastB) then
  begin
    lastBlock := strToIntDef(lastB, 0);
  end;

  if JsonValue.TryGetValue<TjsonArray>('addressList', addrlist) then
  begin
    SetLength(addresses, addrlist.Count);
    SetLength(values, addrlist.Count);

    i := 0;
    for JsonIt in addrlist do
    begin

      JsonIt.TryGetValue<AnsiString>('address', addresses[i]);

      if JsonIt.TryGetValue<AnsiString>('value', temp) then
      begin

        BigInteger.TryParse(temp, 10, values[i]);

      end;

      inc(i);
    end;

  end;

end;

function transactionHistory.toString(): AnsiString;
var
  list: TstringList;
  i: integer;
begin
  list := TstringList.Create();

  list.Add(typ);
  list.Add(TransactionID);
  list.Add(data);
  list.Add(inttostr(Length(addresses)));
  for i := 0 to Length(addresses) - 1 do
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
  size: integer;
  i: integer;
  temp: BigInteger;
  list: TstringList;
begin

  list := SplitString(str, ',');

  typ := list.Strings[0];
  TransactionID := list.Strings[1];
  data := list.Strings[2];
  size := strToIntDef(list.Strings[3], 0);

  SetLength(addresses, size);
  SetLength(values, size);

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
