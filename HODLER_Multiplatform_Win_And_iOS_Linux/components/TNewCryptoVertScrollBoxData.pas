unit TNewCryptoVertScrollBoxData;

interface

uses
  System.SysUtils, System.Classes, FMX.Types, FMX.Controls, FMX.Layouts,
  FMX.Edit, FMX.StdCtrls, FMX.Clipboard, FMX.Platform, FMX.Objects, AccountData,
  System.Types, StrUtils, popupwindowData, coinData, TokenData,
  walletStructureData;

type
  TNewCryptoVertScrollBox = class(TVertScrollBox)

  type
    TAddNewCryptoPanel = class(TPanel)

    private
      coinName: TLabel;
      coinIMG: TImage;

      procedure PanelClick(Sender: TObject; const Point: TPointF); overload;
      procedure PanelClick(Sender: TObject); overload;

    published
      Edit: TEdit;
      checkBox: TCheckBox;

      constructor Create(AOwner: TComponent); override;

    end;

  type
    TAddNewTokenPanel = class(TAddNewCryptoPanel)
      public
        treeImage : Timage;

      published
        constructor Create(AOwner: TComponent); override;
    end;

  type
    TNewTokenList = class(Tlayout)

    private
      coinAddress: AnsiString;

    published

      constructor Create(AOwner: TComponent; wd: TwalletInfo = nil;
        ac: Account = nil);
      // procedure setCoinAddress( address : AnsiString );

    end;

  type
    TETHPanel = class(TPanel)

      coinName: TLabel;
      coinIMG: TImage;

      constructor Create(AOwner: TComponent); override;

    end;

  type
    TETHListPanel = class(Tlayout)

    private
      ethpanel: TETHPanel;
      tokenList: TNewTokenList;

    published

      constructor Create(AOwner: TComponent; wd: TwalletInfo; ac: Account);

    public

    end;

  published

    constructor Create(AOwner: TComponent; acc: Account);

  public

    ETHAddressForNewToken: AnsiString;
    CoinLayout: Tlayout;
    ETHAddTokenLayout: Tlayout;
    ETHTokenLayout: Tlayout;

    ethpanel: TAddNewCryptoPanel;

    tokenCount: Integer;
    ac: Account;
    procedure setETHWalletForNewTokens(newETH: TwalletInfo);
    procedure clear();
    procedure prepareForAccount(acc: Account);

  end;

procedure Register;

implementation

uses misc, languages, uhome;

procedure Register;
begin
  RegisterComponents('Samples', [TNewCryptoVertScrollBox]);
end;

constructor TNewCryptoVertScrollBox.TAddNewTokenPanel.Create(AOwner: TComponent);
begin
  inherited;

  treeImage := TImage.create(self);
  TreeImage.parent := self;
  treeImage.Align := tAlignLayout.mostLeft;
  treeImage.Width := 24;

end;

constructor TNewCryptoVertScrollBox.TETHPanel.Create(AOwner: TComponent);
begin

  inherited;

  coinName := TLabel.Create(self);
  coinName.parent := self;
  // coinName.Text := 'test';
  coinName.Visible := true;
  coinName.Align := TAlignLayout.Client;
  coinName.HitTest := false;

  coinIMG := TImage.Create(self);
  coinIMG.parent := self;
  // coinIMG.Bitmap.LoadFromStream
  // (ResourceMenager.getAssets(availableCoin[0].resourceName));
  coinIMG.Align := TAlignLayout.Left;
  coinIMG.Margins.Top := 8;
  coinIMG.Margins.Bottom := 8;
  coinIMG.Width := 50;
  coinIMG.HitTest := false;
end;

constructor TNewCryptoVertScrollBox.TETHListPanel.Create(AOwner: TComponent;
  wd: TwalletInfo; ac: Account);
begin

  inherited Create(AOwner);

  ethpanel := TETHPanel.Create(self);
  ethpanel.parent := self;
  ethpanel.Align := TAlignLayout.MostTop;
  ethpanel.Height := 48;
  ethpanel.coinName.Text := ac.getDescription(wd.coin, wd.X);
  ethpanel.coinIMG.Bitmap.LoadFromStream
    (ResourceMenager.getAssets(availableCoin[4].resourceName));

  tokenList := TNewTokenList.Create(self, wd, ac);
  tokenList.parent := self;
  tokenList.Align := TAlignLayout.Top;
  tokenList.Visible := true;
  // tokenlist.Height := 480;

  Height := tokenList.Height + ethpanel.Height;

end;

constructor TNewCryptoVertScrollBox.TNewTokenList.Create(AOwner: TComponent;
  wd: TwalletInfo = nil; ac: Account = nil);
var
  i: Integer;
  ancp: TAddNewTokenPanel;
  countToken: Integer;
begin

  inherited Create(AOwner);
  countToken := 0;
  for i := 0 to length(Token.availableToken) - 1 do
  begin
    if Token.availableToken[i].address = '' then
      Continue;

    countToken := countToken + 1;

    ancp := TAddNewTokenPanel.Create(self);
    ancp.Margins.Left := 10;
    ancp.parent := self;
    ancp.Align := TAlignLayout.Top;
    ancp.Height := 48;
    ancp.Position.Y := 48 + i * 48;
    ancp.Visible := true;
    ancp.tag := i;
    ancp.TagString := 'token';
    ancp.coinName.Text := Token.availableToken[i].name;
    ancp.coinIMG.Bitmap.LoadFromStream
      (ResourceMenager.getAssets(Token.availableToken[i].resourceName));
    ancp.treeImage.Bitmap.LoadFromStream( ResourceMenager.getAssets( 'ETH_TREE' ) );

    if (wd <> nil) and (ac <> nil) then
    begin
      if ac.TokenExistinETh(Token.availableToken[i].id, wd.ADDR) then
      begin

        ancp.checkBox.isChecked := true;
        ancp.Edit.Visible := true;

      end;

    end
    else
    begin
      ancp.checkBox.isChecked := false;
      ancp.Edit.Visible := false;
    end;

  end;

  ancp.treeImage.Bitmap.LoadFromStream( ResourceMenager.getAssets( 'ETH_TREE_SHORT' ) );

  self.Height := countToken * 48;

end;

procedure TNewCryptoVertScrollBox.prepareForAccount(acc: Account);
begin

end;

procedure TNewCryptoVertScrollBox.clear();
var
  i: Integer;
begin

  for i := 0 to CoinLayout.ChildrenCount - 1 do
  begin

    if CoinLayout.Children[i] is TEdit then
      TEdit(CoinLayout.Children[i]).Text := '';

  end;

  { for I := 0 to TokenLayout.ChildrenCount -1  do
    begin

    if TokenLayout.Children[i] is TEdit then
    Tedit(TokenLayout.Children[i]).Text := '';

    end; }

end;

procedure TNewCryptoVertScrollBox.setETHWalletForNewTokens(newETH: TwalletInfo);
begin

  ETHAddressForNewToken := newETH.ADDR;

end;

constructor TNewCryptoVertScrollBox.Create(AOwner: TComponent; acc: Account);
var
  i: Integer;
  ancp: TAddNewCryptoPanel;
  countToken, countETH: Integer;
  ethp: TNewCryptoVertScrollBox.TETHListPanel;
  tokenList: TNewTokenList;
  coinLabel: TLabel;
  AddTokenToETH: TLabel;
begin

  inherited Create(AOwner);

  ac := acc;

  countToken := 0;

  CoinLayout := Tlayout.Create(self);
  CoinLayout.parent := self;
  CoinLayout.Align := TAlignLayout.Top;

  coinLabel := TLabel.Create(CoinLayout);
  coinLabel.parent := CoinLayout;
  coinLabel.Align := TAlignLayout.MostTop;
  coinLabel.Text := '----ADD NEW COIN/TOKEN----';
  coinLabel.TextSettings.HorzAlign := TTextAlign.Center;
  coinLabel.Height := 48;

  for i := 0 to length(availableCoin) - 1 do
  begin
    ancp := TAddNewCryptoPanel.Create(CoinLayout);
    ancp.parent := CoinLayout;
    ancp.Align := TAlignLayout.Top;
    ancp.Height := 48;
    ancp.Position.Y := 4800;
    ancp.Visible := true;
    ancp.tag := i;
    ancp.TagString := 'coin';
    ancp.coinName.Text := availableCoin[i].name;
    ancp.coinIMG.Bitmap.LoadFromStream
      (ResourceMenager.getAssets(availableCoin[i].resourceName));

    if availableCoin[i].shortcut = 'ETH' then
    begin

      ethpanel := ancp;

      ETHTokenLayout := Tlayout.Create(CoinLayout);
      ETHTokenLayout.parent := CoinLayout;
      ETHTokenLayout.Align := TAlignLayout.Top;
      ETHTokenLayout.Position.Y := 4800;

      ethpanel.parent := ETHTokenLayout;
      tokenList := TNewTokenList.Create(ETHTokenLayout);
      tokenList.parent := ETHTokenLayout;
      tokenList.Align := TAlignLayout.Top;
      // ethp.Height := 960;
      ETHTokenLayout.Height := ethpanel.Height + tokenList.Height;

    end;

  end;
  CoinLayout.Height := ETHTokenLayout.Height + (length(availableCoin)) * 48;

  ETHAddTokenLayout := Tlayout.Create(self);
  ETHAddTokenLayout.parent := self;
  ETHAddTokenLayout.Align := TAlignLayout.Top;

  AddTokenToETH := TLabel.Create(ETHAddTokenLayout);
  AddTokenToETH.parent := ETHAddTokenLayout;
  AddTokenToETH.Align := TAlignLayout.MostTop;
  AddTokenToETH.Text := '----ADD TOKEN TO EXISTING WALLET----';
  AddTokenToETH.TextSettings.HorzAlign := TTextAlign.Center;
  AddTokenToETH.Height := 48;

  countETH := 0;
  for i := 0 to length(acc.myCoins) - 1 do
  begin

    if acc.myCoins[i].coin = 4 then
    begin

      countETH := countETH + 1;
      ethp := TETHListPanel.Create(ETHAddTokenLayout, acc.myCoins[i], acc);
      ethp.parent := ETHAddTokenLayout;
      ethp.Align := TAlignLayout.Top;

    end;

  end;
  if countETH = 0 then
  begin

  end
  else
  begin

    ETHAddTokenLayout.Height := countETH * (ethp.Height) + 48;

  end;

  { for i := 0 to length(Token.availableToken) - 1 do
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

    TokenLayout.Height := ( countToken + 3 ) * 48 ; // +1 label '--TOKENS--'  +1 'Add manually' +1 'Find ERC20' }
  // +1 label '--COINS--'

end;

procedure setETHWalletForNewTokens(newETH: TwalletInfo);
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
  // coinName.Text := 'test';
  coinName.Visible := true;
  coinName.Align := TAlignLayout.Client;
  coinName.HitTest := false;

  coinIMG := TImage.Create(self);
  coinIMG.parent := self;
  // coinIMG.Bitmap.LoadFromStream
  // (ResourceMenager.getAssets(availableCoin[0].resourceName));
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

  checkBox.isChecked := not checkBox.isChecked;
  Edit.Visible := checkBox.isChecked;
  Edit.Width := round(self.Width / 2);

  if TagString = 'coin' then
    Edit.Text := availableCoin[tag].displayName + ' (' + availableCoin[tag]
      .shortcut + ') ' + inttoStr(getFirstUnusedXforCoin(tag))
  else
    Edit.Text := Token.availableToken[tag].name;

end;

end.
