unit CurrencyConverter;

interface

uses
  system.Generics.Collections;
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

  except
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
  availableCurrency.AddOrSetValue(symbol, ratio);
end;

constructor TCurrencyConverter.Create();
begin
  availableCurrency := TObjectDictionary<AnsiString, double>.Create();
  availableCurrency.Add('PLN', 3.73);
  availableCurrency.Add('EUR', 0.86);
  availableCurrency.Add('USD', 1.0);
  availableCurrency.Add('GBP', 0.77);
  availableCurrency.Add('CAD', 1.32);
  availableCurrency.Add('INR', 69.07);
  ratio := 1.0;
  symbol := 'USD';

end;

destructor TCurrencyConverter.destroy;
begin

  availableCurrency.Free;

end;

end.
