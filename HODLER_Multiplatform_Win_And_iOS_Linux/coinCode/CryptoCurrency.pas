unit CryptoCurrency;

interface

uses    System.IOUtils , sysutils, StrUtils, Velthuis.BigIntegers, System.Classes,
  FMX.Graphics,
   base58 ,
   FMX.Dialogs;

type
  transactionHistory = record
    typ : AnsiString;
    TransactionID : AnsiString;
    data : AnsiString;
    addresses : Array of AnsiString;
    values : Array of BigInteger;
    CountValues : BigInteger;

    end;

  type
    cryptoCurrency = class
    history: Array of transactionHistory;
  end;


implementation

end.
