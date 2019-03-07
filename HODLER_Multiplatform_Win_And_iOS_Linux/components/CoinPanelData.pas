unit CoinPanelData;

interface

uses
  System.SysUtils, System.UITypes, System.Classes, FMX.Types, FMX.Controls,
  FMX.Layouts,
  FMX.Edit, FMX.StdCtrls, FMX.Clipboard, FMX.Platform, FMX.Objects,
  FMX.Graphics,
  System.Types, StrUtils, FMX.Dialogs, CrossPlatformHeaders, TAddressLabelData,
  cryptoCurrencyData, WalletStructureData, System.DateUtils;

type
  TCoinPanel = class(TPanel)

  private
    coinName: TLabel;
    balLabel: TLabel;
    adrLabel: TLabel;
    coinIMG: TImage;
    price: TLabel;
    serverStatus: TImage;

  public

    crypto: cryptoCurrency;

    constructor Create(AOwner: TComponent; cc: cryptoCurrency);
    destructor Destroy; override;

    procedure refreshBalanceLabel();
    procedure refreshAddressLabel();
    procedure refreshPriceLabel();
    procedure refreshServerStatus();

    procedure refresh();

  end;

procedure Register;

implementation

uses
  uhome, misc;

procedure Register;
begin
  RegisterComponents('Samples', [TCoinPanel]);
end;

constructor TCoinPanel.Create(AOwner: TComponent; cc: cryptoCurrency);
begin

end;

destructor TCoinPanel.Destroy;
begin

end;

procedure TCoinPanel.refreshBalanceLabel();
begin

end;

procedure TCoinPanel.refreshAddressLabel();
begin

end;

procedure TCoinPanel.refreshPriceLabel();
begin

end;

procedure TCoinPanel.refresh();
begin

end;

procedure TCoinPanel.refreshServerStatus();
begin

end;

end.
