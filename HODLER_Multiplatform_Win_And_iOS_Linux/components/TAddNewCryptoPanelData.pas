unit TAddNewCryptoPanelData;

interface

uses
  System.SysUtils, System.Classes, FMX.Types, FMX.Controls, FMX.Layouts,
  FMX.Edit, FMX.StdCtrls, FMX.Clipboard, FMX.Platform, FMX.Objects,
  System.Types, StrUtils, popupwindowData , coinData;

type
  TAddNewCryptoPanel = class(TPanel)

  private
    coinName : TLabel;
    coinIMG : TImage;

    edit : TEdit;

    procedure PanelClick(Sender: TObject; const Point: TPointF); overload;
    procedure PanelClick(Sender: TObject); overload;

  published

    checkBox : TCheckBox;

    constructor Create(AOwner: TComponent); override;

  end;

procedure Register;

implementation

uses misc, languages, uhome;

procedure Register;
begin
  RegisterComponents('Samples', [TAddNewCryptoPanel]);
end;

constructor TAddNewCryptoPanel.Create(AOwner: TComponent);
begin

  inherited create(Aowner);

{$IFDEF ANDROID}
  self.OnTap := PanelClick;
{$ELSE}
   self.OnClick := PanelClick;
{$ENDIF}

  coinName := TLabel.Create(Self);
  coinName.parent := Self;
  coinName.Text := 'test' ;
  coinName.Visible := true;
  coinName.Align := TAlignLayout.Client;
  coinName.HitTest := false;

  coinIMG := TImage.Create(Self);
  coinIMG.parent := Self;
  coinIMG.Bitmap.LoadFromStream
    (ResourceMenager.getAssets(availableCoin[0].resourceName));
  coinIMG.Align := TAlignLayout.Left;
  coinIMG.Margins.Top := 8;
  coinIMG.Margins.Bottom := 8;
  coinIMG.Width := 50;
  coinIMG.HitTest := false;

  edit := TEdit.Create(self);
  edit.parent := Self;
  edit.Align := TAlignLayout.MostRight;
  edit.visible := false;

  checkBox := TCheckBox.create(self);
  checkBox.parent := self;
  checkBox.align := TAlignlayout.mostLeft;
  checkBox.width := 24;
  checkBox.HitTest := false;
  checkBox.Margins.Left := 12;


end;

procedure TAddNewCryptoPanel.PanelClick(Sender: TObject; const Point: TPointF);
begin

  PanelClick(Sender);

end;
procedure TAddNewCryptoPanel.PanelClick(Sender: TObject);
begin

  checkBox.IsChecked := not checkBox.IsChecked;
  edit.Visible := checkbox.IsChecked;
  edit.Width := round (self.Width / 2);

end;

end.
