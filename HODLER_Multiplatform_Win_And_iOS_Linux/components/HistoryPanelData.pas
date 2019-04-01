unit HistoryPanelData;

interface

uses
  System.SysUtils, System.UITypes, System.Classes, FMX.Types, FMX.Controls,
  FMX.Layouts,
  FMX.Edit, FMX.StdCtrls, FMX.Clipboard, FMX.Platform, FMX.Objects,
  FMX.Graphics,
  System.Types, StrUtils, FMX.Dialogs, CrossPlatformHeaders, TAddressLabelData,
  cryptoCurrencyData, WalletStructureData, System.DateUtils;

type
  THistoryPanel = class(TPanel)

  private

  public
    image: TImage;
    lbl: TLabel;
    addrLbl: TAddressLabel;
    datalbl: TLabel;
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;

    procedure setConfirmed(confirmed: boolean);
    procedure setType(inOutInternal: AnsiString);

  end;

procedure Register;

implementation

uses
  uhome, misc;

procedure Register;
begin
  RegisterComponents('Samples', [THistoryPanel]);
end;

procedure THistoryPanel.setType(inOutInternal: AnsiString);
begin
  image.Bitmap.LoadFromStream( ResourceMenager.getAssets('TRANSACTION_' + inOutInternal ));
  {if inOutInternal = 'OUT' then
    panel.image.Bitmap.LoadFromStream( ResourceMenager.getAssets(  ));
  if inOutInternal = 'IN' then
    panel.image.Bitmap := frmhome.receiveImage.Bitmap;
  if inOutInternal = 'INTERNAL' then
    panel.image.Bitmap := frmhome.internalImage.Bitmap; }
end;

constructor THistoryPanel.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);

  addrLbl := TAddressLabel.Create(self);
  addrLbl.parent := self;
  addrLbl.Align := TAlignLayout.Top;
  addrLbl.Visible := true;
  addrLbl.Height := 18;

  addrLbl.TextSettings.HorzAlign := TTextAlign.Leading;

  datalbl := TLabel.Create(self);
  datalbl.Visible := true;
  datalbl.parent := self;
  datalbl.Width := 400;
  datalbl.Height := 18;
  datalbl.Position.x := 36;

  datalbl.Position.Y := 18;

  datalbl.TextSettings.HorzAlign := TTextAlign.Leading;
  datalbl.Visible := true;

  image := TImage.Create(self);
  image.Align := TAlignLayout.MostLeft;
  image.Margins.Left := 9;
  image.Margins.Right := 9;
  image.Width := 18;
  image.Visible := true;
  image.parent := self;

  lbl := TLabel.Create(self);
  lbl.Align := TAlignLayout.Bottom;
  lbl.Height := 18;
  lbl.TextSettings.HorzAlign := TTextAlign.Trailing;
  lbl.Visible := true;
  lbl.parent := self;

end;

procedure THistoryPanel.setConfirmed(confirmed: boolean);
var
  val: single;
begin

  if not confirmed then
    val := 0.5
  else
    val := 1;

  self.Opacity := val;
  lbl.Opacity := val;
  image.Opacity := val;
  addrLbl.Opacity := val;
  datalbl.Opacity := val;

end;

destructor THistoryPanel.Destroy();
begin

  inherited;

end;

end.
