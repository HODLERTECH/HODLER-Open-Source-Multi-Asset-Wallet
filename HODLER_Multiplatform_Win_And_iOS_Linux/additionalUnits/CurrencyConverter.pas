unit CurrencyConverter;

interface

uses
  system.Generics.Collections,SysUtils;
{$IF DEFINED(ANDROID) OR DEFINED(IOS) OR DEFINED(LINUX)}

const
  StrStartIteration = {$IFNDEF LINUX} 0 {$ELSE}1{$ENDIF};

type
  AnsiString = string;

type
  AnsiChar = Char;
{$ELSE}

const
  StrStartIteration = 1;
{$ENDIF}

type
  TCurrencyConverter = class

    ratio: double;
    symbol: AnsiString;

    availableCurrency: TObjectDictionary<AnsiString, double>;

    function calculate(value: double): double;

    constructor Create();
    destructor destroy(); override;

    procedure updateCurrencyRatio(symbol: AnsiString; ratio: double);
    procedure setCurrency(_symbol: AnsiString);

  end;

implementation

procedure TCurrencyConverter.setCurrency(_symbol: AnsiString);
begin
  try
    ratio := availableCurrency[_symbol];
    symbol := _symbol;

  except   on E : Exception do
    begin
      ratio := 1.0;
      symbol := 'USD';
    end;
  end;

end;

function TCurrencyConverter.calculate(value: double): double;
begin
  Result := value * ratio;
end;

procedure TCurrencyConverter.updateCurrencyRatio(symbol: AnsiString;
  ratio: double);
begin
try
  availableCurrency.TryAdd(symbol, ratio);
except
on E:Exception do begin
  writeln(E.Message);

end;
end;
end;

constructor TCurrencyConverter.Create();
begin
  availableCurrency := TObjectDictionary<AnsiString, double>.Create();
  if availableCurrency.Count=0 then begin
  availableCurrency.TryAdd('EUR', 0.89);
  availableCurrency.TryAdd('USD', 1.0);
  availableCurrency.TryAdd('GBP', 0.78);
  availableCurrency.TryAdd('CAD', 1.35);
  availableCurrency.TryAdd('PLN', 3.85);
  availableCurrency.TryAdd('INR', 69.07);
  availableCurrency.TryAdd('JPY', 109.31);
  availableCurrency.TryAdd('BGN', 1.75);
  availableCurrency.TryAdd('CZK', 23.03);
  availableCurrency.TryAdd('DKK', 6.68);
  availableCurrency.TryAdd('HUF', 290.75);
  availableCurrency.TryAdd('RON', 4.26);
  availableCurrency.TryAdd('SEK', 9.63);
  availableCurrency.TryAdd('CHF', 1.01);
  availableCurrency.TryAdd('ISK', 122.87);
  availableCurrency.TryAdd('NOK', 8.76);
  availableCurrency.TryAdd('HRK', 6.63);
  availableCurrency.TryAdd('RUB', 64.81);
  availableCurrency.TryAdd('TRY', 6.06);
  availableCurrency.TryAdd('AUD', 1.45);
  availableCurrency.TryAdd('BRL', 3.99);
  availableCurrency.TryAdd('CNY', 6.88);
  availableCurrency.TryAdd('HKD', 7.85);
  availableCurrency.TryAdd('IDR', 14460.00);
  availableCurrency.TryAdd('ILS', 3.57);
  availableCurrency.TryAdd('INR', 70.36);
  availableCurrency.TryAdd('KRW', 1190.48);
  availableCurrency.TryAdd('MXN', 19.20);
  availableCurrency.TryAdd('MYR', 4.18);
  availableCurrency.TryAdd('NZD', 1.53);
  availableCurrency.TryAdd('PHP', 52.39);
  availableCurrency.TryAdd('SGD', 1.37);
  availableCurrency.TryAdd('THB', 31.59);
  availableCurrency.TryAdd('ZAR', 14.27);
  end;
  ratio := 1.0;
  symbol := 'USD';

end;

destructor TCurrencyConverter.destroy;
begin

  availableCurrency.Free;

end;

end.
