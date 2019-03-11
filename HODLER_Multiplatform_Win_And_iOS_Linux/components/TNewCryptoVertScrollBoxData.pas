unit TNewCryptoVertScrollBoxData;

interface

uses
  System.SysUtils, System.Classes, FMX.Types, FMX.Controls, FMX.Layouts,
  FMX.Edit, FMX.StdCtrls, FMX.Clipboard, FMX.Platform, FMX.Objects,
  System.Types, StrUtils, popupwindowData, coinData , TokenData , walletStructureData;

type
  TNewCryptoVertScrollBox = class(TVertScrollBox)

  type
    TAddNewCryptoPanel = class(TPanel)

    private
      coinName: TLabel;
      coinIMG: TImage;

      Edit: TEdit;


      procedure PanelClick(Sender: TObject; const Point: TPointF); overload;
      procedure PanelClick(Sender: TObject); overload;

    published

      checkBox: TCheckBox;

      constructor Create(AOwner: TComponent); override;

    end;

  published

    constructor Create(AOwner: TComponent); override;

  public

    CoinLayout : TLayout;
    TokenLayout : TLayout;

    ETHPanel: TAddNewCryptoPanel;

    tokenCount: Integer;

    procedure setETHWalletForNewTokens(newETH : TWalletInfo);
    procedure clear();


  end;

procedure Register;

implementation

uses misc, languages, uhome;

procedure Register;
begin
  RegisterComponents('Samples', [TNewCryptoVertScrollBox]);
end;

procedure TNewCryptoVertScrollBox.clear();
var
  I :Integer;
begin

  for I := 0 to CoinLayout.ChildrenCount -1  do
  begin

    if coinLayout.Children[i] is TEdit then
      Tedit(coinLayout.Children[i]).Text := '';

  end;

  for I := 0 to TokenLayout.ChildrenCount -1  do
  begin

    if TokenLayout.Children[i] is TEdit then
      Tedit(TokenLayout.Children[i]).Text := '';

  end;

end;

procedure TNewCryptoVertScrollBox.setETHWalletForNewTokens(newETH : TWalletInfo);
begin


end;

constructor TNewCryptoVertScrollBox.Create(AOwner: TComponent);
var
  i: Integer;
  ancp : TAddNewCryptoPanel;
  countToken : Integer;
begin

  inherited Create(AOwner);

  countToken := 0;

  coinLayout := TLayout.Create(self);
  coinLayout.Parent := self;
  CoinLayout.Align := TAlignLayout.Top;


  TokenLayout := TLayout.Create(self);
  tokenLayout.Parent := self;
  TokenLayout.Align := TAlignLayout.Top;

  for i := 0 to length(availableCoin) - 1 do
  begin
    ancp := TAddNewCryptoPanel.Create( CoinLayout );
    ancp.Parent := CoinLayout;
    ancp.Align := Talignlayout.Top;
    ancp.Height := 48;
    ancp.Position.Y := 48 + i * 48;
    ancp.Visible := true;
    ancp.tag := i;
    ancp.TagString := 'coin';
    ancp.coinName.Text := availableCoin[i].name;
    ancp.coinIMG.Bitmap.LoadFromStream( ResourceMenager.getAssets(availableCoin[i].resourceName) );

    if availableCoin[i].shortcut = 'ETH' then
      ETHPanel := ancp;

  end;

  for i := 0 to length(Token.availableToken) - 1 do
  begin
    if token.availableToken[i].address = '' then
        Continue;

    countToken := countToken + 1;

    ancp := TAddNewCryptoPanel.Create( TokenLayout );
    ancp.Parent := TokenLayout;
    ancp.Align := Talignlayout.Top;
    ancp.Height := 48;
    ancp.Position.Y := 48 + i * 48;
    ancp.Visible := true;
    ancp.tag := i;
    ancp.TagString := 'token';
    ancp.coinName.Text := Token.availableToken[i].name;
    ancp.coinIMG.Bitmap.LoadFromStream( ResourceMenager.getAssets( Token.availableToken[i].ResourceName ) );
  end;

  TokenLayout.Height := ( countToken + 3 ) * 48 ; // +1 label '--TOKENS--'  +1 'Add manually' +1 'Find ERC20'
  CoinLayout.Height := ( length(availablecoin) + 1 ) * 48 ; // +1 label '--COINS--'

end;

procedure setETHWalletForNewTokens(newETH : TWalletInfo);
begin

end;

constructor TNewCryptoVertScrollBox.TAddNewCryptoPanel.Create
  (AOwner: TComponent);
begin

  inherited Create(AOwner);

{$IFDEF ANDROID}
  self.OnTap := PanelClick;
{$ELSE}
  self.OnClick := PanelClick;
{$ENDIF}
  coinName := TLabel.Create(self);
  coinName.parent := self;
  //coinName.Text := 'test';
  coinName.Visible := true;
  coinName.Align := TAlignLayout.Client;
  coinName.HitTest := false;

  coinIMG := TImage.Create(self);
  coinIMG.parent := self;
  //coinIMG.Bitmap.LoadFromStream
  //  (ResourceMenager.getAssets(availableCoin[0].resourceName));
  coinIMG.Align := TAlignLayout.Left;
  coinIMG.Margins.Top := 8;
  coinIMG.Margins.Bottom := 8;
  coinIMG.Width := 50;
  coinIMG.HitTest := false;

  Edit := TEdit.Create(self);
  Edit.parent := self;
  Edit.Align := TAlignLayout.MostRight;
  Edit.Visible := false;

  checkBox := TCheckBox.Create(self);
  checkBox.parent := self;
  checkBox.Align := TAlignLayout.mostLeft;
  checkBox.Width := 24;
  checkBox.HitTest := false;
  checkBox.Margins.Left := 12;

end;

procedure TNewCryptoVertScrollBox.TAddNewCryptoPanel.PanelClick(Sender: TObject;
  const Point: TPointF);
begin

  PanelClick(Sender);

end;

procedure TNewCryptoVertScrollBox.TAddNewCryptoPanel.PanelClick
  (Sender: TObject);
begin

  checkBox.IsChecked := not checkBox.IsChecked;
  Edit.Visible := checkBox.IsChecked;
  Edit.Width := round(self.Width / 2);

  if tagstring = 'coin' then
    Edit.Text := AvailableCoin[tag].displayName
    + ' (' + AvailableCoin[tag].shortcut + ') '  + inttoStr( getFirstUnusedXforCoin( Tag ) )
  else
    Edit.Text := Token.availableToken[tag].name;



end;

end.
