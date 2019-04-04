unit Spendable;

interface

uses tokenData, WalletStructureData, cryptoCurrencyData, System.IOUtils, FMX.Graphics, System.types,
  Sysutils, Classes, FMX.Dialogs, Json, Velthuis.BigIntegers, math ,System.Generics.Collections ,
   System.SyncObjs , THreadKindergartenData ;

type
  TAdvancedOption = ( Fee , unstantSend , unlockWalletToReceiveFunds );

type
  TAdvancedOptionArray = array of TAdvancedOption;

type
  TAddressInfo = record

  private
    function getAddress() : AnsiString;
  public
    description : AnsiString;
    prefix : AnsiString;

    rawAddress : AnsiString;

    suffix : AnsiString;

    property address: AnsiString read getAddress;

  end;

type
  TAddressInfoArray = array of TAddressInfo;

type
  ISpendable = interface



    //isERC20Token():boolean;
    //isToken():boolean

    //function getCryptocurrencyType() : TCryptocurrencyType;   // mo¿e przez dziedziczenie ustaliæ typ ?

    function advancedOptions(): TAdvancedOptionArray;
    function getImageResource() : TStream;
    function isValidAddress( addr : AnsiString ): boolean;

    procedure resync();

    function getConfirmed():BigInteger;
    function getUnconfirmed():BigInteger;
    function getDescription():AnsiString;
    procedure setDescription( desc : AnsiString );

    //validateTransaction(...):boolean;  ???
    function getHistoryType( tx: transactionHistory ): integer; // ???
    function getHistory(): TxHistory;
    function getMinimalFee():BigInteger;
    function getFee( confirms: Integer ) : BigInteger;
    //static getPrice() : double;
    //static setPrice( price : double ) ;
    function getTransactionRequiredData({from:Spendable}): TObject;
    function signOffline({from:Spendable}receiver:ansistring; amount,fee:BigInteger ):string;
    function send({from:Spendable} receiver:ansistring ; amount,fee:BigInteger ):string;
    //loadFromFile();
    //saveToFile();
    function Addresses : TaddressInfoArray;
    function isOnline:boolean;
    //Create(...)
    // AddressType: array of AddressType   // Address type in description in TaddressInfo
    // createFromPriv( priv : AnsiString; compressed:boolean=true );

    function getPrivateKey( MasterSeed :ansiString  ): AnsiString;
    // getRawAddress()  // in TaddressInfo
    //getAddressPrefix()

    //class function transactionHistoryExist( priv : AnsiString ): boolean;

  end;

implementation

function TAddressInfo.GetAddress : AnsiString;
begin
  result := prefix + rawAddress + suffix;
end;

end.
