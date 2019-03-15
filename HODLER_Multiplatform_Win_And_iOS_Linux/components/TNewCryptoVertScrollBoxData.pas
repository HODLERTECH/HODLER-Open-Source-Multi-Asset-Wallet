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

      procedure PanelClick(Sender: TObject; const Point: TPointF);
        overload; virtual;
      procedure PanelClick(Sender: TObject); overload; virtual;

      procedure onCheck(Sender: TObject);
      procedure Resize; override;

    published
      Edit: TEdit;
      checkBox: TCheckBox;

      constructor Create(AOwner: TComponent); override;

    end;

  type
    TAddNewTokenPanel = class(TAddNewCryptoPanel)
    private

    public
      treeImage: TImage;

    published
      constructor Create(AOwner: TComponent); override;
    end;

  type
    TAddNewTokenPanelForNewETH = class(TAddNewTokenPanel)
    private
      ethPanel: TAddNewCryptoPanel;
      procedure PanelClick(Sender: TObject; const Point: TPointF);
        overload; override;
      procedure PanelClick(Sender: TObject); overload; override;

    published
      constructor Create(AOwner: TComponent); override;
    end;

  type
    TNewTokenList = class(Tlayout)

    //private
    //  coinAddress: AnsiString;

    public
      function countChecked(): Integer;
      constructor Create(AOwner: TComponent; wd: TwalletInfo;
        ac: Account); overload;
      constructor Create(AOwner: TComponent;
        coinPanel: TAddNewCryptoPanel); overload;
      // procedure setCoinAddress( address : AnsiString );

    end;

  type
    TETHPanel = class(TPanel)
      public
        ETHAddress : AnsiString;
        coinName: TLabel;
        coinIMG: TImage;

      constructor Create(AOwner: TComponent); override;

    end;

  type
    TETHListPanel = class(Tlayout)

    private
      ethPanel: TETHPanel;
      tokenList: TNewTokenList;

      procedure PanelClick(Sender: TObject; const Point: TPointF); overload;
      procedure PanelClick(Sender: TObject); overload;

    published

      constructor Create(AOwner: TComponent; wd: TwalletInfo; ac: Account);

    public

    end;
  private

  published

    constructor Create(AOwner: TComponent; acc: Account);

  public

    ETHAddressForNewToken: AnsiString;
    CoinLayout: Tlayout;
    ETHAddTokenLayout: Tlayout;
    ETHTokenLayout: Tlayout;
    tokenList: TNewTokenList;

    ethPanel: TAddNewCryptoPanel;

    tokenCount: Integer;
    ac: Account;
    procedure setETHWalletForNewTokens(newETH: TwalletInfo);
    procedure clear();
    procedure prepareForAccount(acc: Account);
    procedure createCryptoAndAddPanelTo(box: TVertScrollBox);

  end;

procedure Register;

implementation

uses misc, languages, uhome;

procedure Register;
begin
  RegisterComponents('Samples', [TNewCryptoVertScrollBox]);
end;

procedure TNewCryptoVertScrollBox.createCryptoAndAddPanelTo
  (box: TVertScrollBox);
begin

  frmhome.NotificationLayout.popupPasswordConfirm(
    procedure(password: String)
    var
      MasterSeed: AnsiString;
    var
      i , j: Integer;
      ancp: TNewCryptoVertScrollBox.TAddNewCryptoPanel;
      WalletInfo: TwalletInfo;
      T: Token;
      ETHAddressForNewToken: AnsiString;
      countETH: Integer;
      tempTokenList : TETHListPanel;
    begin

      try
        MasterSeed := CurrentAccount.getDecryptedMasterSeed(password);
      except
        on E: Exception do
          popupWindow.Create(E.Message);
      end;

      for i := 0 to CoinLayout.children.Count - 1 do
      begin

        if CoinLayout.children[i] is TNewCryptoVertScrollBox.TAddNewCryptoPanel
        then
        begin
          ancp := TNewCryptoVertScrollBox.TAddNewCryptoPanel
            (CoinLayout.children[i]);
        end
        else
          Continue;

        if ancp.checkBox.IsChecked then
        begin

          WalletInfo := coinData.createCoin(ancp.Tag,
            getFirstUnusedXforCoin(ancp.Tag), 0, MasterSeed, ancp.Edit.Text);

          ac.AddCoin(WalletInfo);
          TThread.Synchronize(nil,
            procedure
            begin
              CreatePanel(WalletInfo, ac, box);
            end);

        end;

      end;
      if ethPanel.checkBox.IsChecked then
      begin

        WalletInfo := coinData.createCoin(4, getFirstUnusedXforCoin(4), 0,
          MasterSeed, ethPanel.Edit.Text);

        ac.AddCoin(WalletInfo);
        TThread.Synchronize(nil,
          procedure
          begin
            CreatePanel(WalletInfo, ac, box);
          end);

        ETHAddressForNewToken := WalletInfo.addr;
      end;


      for i := 0 to tokenList.children.Count - 1 do
      begin
        if tokenList.children[i] is TAddNewCryptoPanel then
          ancp := TAddNewCryptoPanel(tokenList.children[i])
        else
          Continue;
        if ancp.checkBox.IsChecked then
        begin

          T := Token.Create(ancp.Tag, ETHAddressForNewToken);

          T.idInWallet := length(ac.myTokens) + 10000;

          ac.addToken(T);
          TThread.Synchronize(nil,
            procedure
            begin
              CreatePanel(T, ac, box);
            end);

        end;

      end;

      for i := 0 to ETHAddTokenLayout.children.Count - 1 do
      begin

        if ETHAddTokenLayout.children[i] is TETHListPanel then
        begin


          tempTokenList := TETHListPanel( ETHAddTokenLayout.children[i] );
          for j := 0 to temptokenlist.tokenList.Children.Count - 1 do
          begin

            if temptokenList.tokenList.children[j] is TAddNewTokenPanel then
              ancp := TAddNewTokenPanel(temptokenList.tokenList.children[j])
            else
              Continue;

            if ancp.checkBox.IsChecked then
            begin

              T := Token.Create(ancp.Tag, tempTokenlist.ethPanel.ETHAddress);

              T.idInWallet := length(ac.myTokens) + 10000;

              ac.addToken(T);
              TThread.Synchronize(nil,
                procedure
                begin
                  CreatePanel(T, ac, box);
                end);

            end;
          end;


        end;

      end;

      // startFullfillingKeypool(MasterSeed);
      TThread.Synchronize(nil,
        procedure
        begin
          frmhome.btnSyncClick(nil);
        end);

    end,
    procedure(password: String)
    begin

    end, 'test');

end;

procedure TNewCryptoVertScrollBox.TAddNewCryptoPanel.Resize;
begin

  inherited;
  Edit.width := width / 2;

end;

procedure TNewCryptoVertScrollBox.TAddNewCryptoPanel.onCheck(Sender: TObject);
begin

  // checkBox.isChecked := not checkBox.isChecked;
  Edit.Visible := checkBox.IsChecked;
  Edit.width := round(self.width / 2);

  if TagString = 'coin' then
    Edit.Text := availableCoin[Tag].displayName + ' (' + availableCoin[Tag]
      .shortcut + ') ' + inttoStr(getFirstUnusedXforCoin(Tag))
  else
    Edit.Text := Token.availableToken[Tag].name;

end;

function TNewCryptoVertScrollBox.TNewTokenList.countChecked(): Integer;
var
  i: Integer;
begin
  result := 0;
  for i := 0 to children.Count - 1 do
  begin

    if children[i] is TAddNewCryptoPanel then
    begin

      if TAddNewCryptoPanel(children[i]).checkBox.IsChecked then
        result := result + 1;

    end;

  end;

end;

constructor TNewCryptoVertScrollBox.TAddNewTokenPanelForNewETH.Create
  (AOwner: TComponent);
begin

  inherited Create(AOwner);
  // ethPanel := TNewCryptoVertScrollBox( TfmxObject(Aowner).parent.parent.parent.parent ).ethPanel;

{$IFDEF ANDROID}
  OnTap := PanelClick;
{$ELSE}
  OnClick := PanelClick;
{$ENDIF}
end;

procedure TNewCryptoVertScrollBox.TAddNewTokenPanelForNewETH.PanelClick
  (Sender: TObject; const Point: TPointF);
begin
  inherited;

  if TNewTokenList(parent).countChecked <> 0 then
  begin
    ethPanel.checkBox.Enabled := false;
    ethPanel.checkBox.IsChecked := true;
  end
  else
  begin
    ethPanel.checkBox.Enabled := true;
    ethPanel.checkBox.IsChecked := false;
  end;

end;

procedure TNewCryptoVertScrollBox.TAddNewTokenPanelForNewETH.PanelClick
  (Sender: TObject);
begin
  inherited;
  if TNewTokenList(parent).countChecked <> 0 then
  begin
    ethPanel.checkBox.Enabled := false;
    ethPanel.checkBox.IsChecked := true;
  end
  else
  begin
    ethPanel.checkBox.Enabled := true;
    ethPanel.checkBox.IsChecked := false;
  end;
end;

procedure TNewCryptoVertScrollBox.TETHListPanel.PanelClick(Sender: TObject;
const Point: TPointF);
begin

  tokenList.Visible := not tokenList.Visible;
  if tokenList.Visible = true then
  begin
    height := tokenList.height + 48;
  end
  else
  begin
    height := 48;
  end;

end;

procedure TNewCryptoVertScrollBox.TETHListPanel.PanelClick(Sender: TObject);
begin

  PanelClick(Sender, TPointF.Zero);

end;

constructor TNewCryptoVertScrollBox.TAddNewTokenPanel.Create
  (AOwner: TComponent);
begin
  inherited;

  treeImage := TImage.Create(self);
  treeImage.parent := self;
  treeImage.Align := tAlignLayout.mostLeft;
  treeImage.width := 30;
  treeImage.Margins.Left := 6;
{$IFDEF ANDROID}
  OnTap := PanelClick;
{$ELSE}
  OnClick := PanelClick;
{$ENDIF}
end;

constructor TNewCryptoVertScrollBox.TETHPanel.Create(AOwner: TComponent);
begin

  inherited;

  coinName := TLabel.Create(self);
  coinName.parent := self;
  // coinName.Text := 'test';
  coinName.Visible := true;
  coinName.Align := tAlignLayout.Client;
  coinName.HitTest := false;

  coinIMG := TImage.Create(self);
  coinIMG.parent := self;
  // coinIMG.Bitmap.LoadFromStream
  // (ResourceMenager.getAssets(availableCoin[0].resourceName));
  coinIMG.Align := tAlignLayout.Left;
  coinIMG.Margins.Top := 8;
  coinIMG.Margins.Bottom := 8;
  coinIMG.width := 50;
  coinIMG.HitTest := false;
end;

constructor TNewCryptoVertScrollBox.TETHListPanel.Create(AOwner: TComponent;
wd: TwalletInfo; ac: Account);
begin

  inherited Create(AOwner);

  ethPanel := TETHPanel.Create(self);
  ethPanel.parent := self;
  ethPanel.Align := tAlignLayout.MostTop;
  ethPanel.height := 48;
  ethPanel.coinName.Text := ac.getDescription(wd.coin, wd.X);
  ethPanel.coinIMG.Bitmap.LoadFromStream
    (ResourceMenager.getAssets(availableCoin[4].resourceName));
  ethPanel.ETHAddress := wd.addr;

{$IFDEF ANDROID}
  ethPanel.OnTap := PanelClick;
{$ELSE}
  ethPanel.OnClick := PanelClick;
{$ENDIF}
  tokenList := TNewTokenList.Create(self, wd, ac);
  tokenList.parent := self;
  tokenList.Align := tAlignLayout.Top;
  tokenList.Visible := true;
  // tokenlist.Height := 480;

  height := tokenList.height + ethPanel.height;

end;

constructor TNewCryptoVertScrollBox.TNewTokenList.Create(AOwner: TComponent;
coinPanel: TAddNewCryptoPanel);
var
  i: Integer;
  ancp: TAddNewTokenPanelForNewETH;
  countToken: Integer;
begin

  inherited Create(AOwner);
  countToken := 0;
  for i := 0 to length(Token.availableToken) - 1 do
  begin
    if Token.availableToken[i].address = '' then
      Continue;

    countToken := countToken + 1;

    ancp := TAddNewTokenPanelForNewETH.Create(self);
    ancp.ethPanel := coinPanel;

    // ancp.Margins.Left := 10;
    ancp.parent := self;
    ancp.Align := tAlignLayout.Top;
    ancp.height := 48;
    ancp.Position.Y := 48 + i * 48;
    ancp.Visible := true;
    ancp.Tag := i;
    ancp.TagString := 'token';
    ancp.coinName.Text := Token.availableToken[i].name;
    ancp.coinIMG.Bitmap.LoadFromStream
      (ResourceMenager.getAssets(Token.availableToken[i].resourceName));
    ancp.treeImage.Bitmap.LoadFromStream(ResourceMenager.getAssets('ETH_TREE'));

    ancp.checkBox.IsChecked := false;
    ancp.Edit.Visible := false;

  end;

  ancp.treeImage.Bitmap.LoadFromStream
    (ResourceMenager.getAssets('ETH_TREE_SHORT'));

  self.height := countToken * 48;

end;

constructor TNewCryptoVertScrollBox.TNewTokenList.Create(AOwner: TComponent;
wd: TwalletInfo; ac: Account);
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
    // ancp.Margins.Left := 10;
    ancp.parent := self;
    ancp.Align := tAlignLayout.Top;
    ancp.height := 48;
    ancp.Position.Y := 48 + i * 48;
    ancp.Visible := true;
    ancp.Tag := i;
    ancp.TagString := 'token';
    ancp.coinName.Text := Token.availableToken[i].name;
    ancp.coinIMG.Bitmap.LoadFromStream
      (ResourceMenager.getAssets(Token.availableToken[i].resourceName));
    ancp.treeImage.Bitmap.LoadFromStream(ResourceMenager.getAssets('ETH_TREE'));

    // ancp.Edit.Width := 200;

    if (wd <> nil) and (ac <> nil) then
    begin
      if ac.TokenExistinETh(Token.availableToken[i].id, wd.addr) then
      begin

        ancp.checkBox.IsChecked := true;
        // ancp.Edit.Visible := true;

      end;

    end
    else
    begin
      ancp.checkBox.IsChecked := false;
      // ancp.Edit.Visible := false;
    end;

  end;

  ancp.treeImage.Bitmap.LoadFromStream
    (ResourceMenager.getAssets('ETH_TREE_SHORT'));

  self.height := countToken * 48;

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

    if CoinLayout.children[i] is TEdit then
      TEdit(CoinLayout.children[i]).Text := '';

  end;

  { for I := 0 to TokenLayout.ChildrenCount -1  do
    begin

    if TokenLayout.Children[i] is TEdit then
    Tedit(TokenLayout.Children[i]).Text := '';

    end; }

end;

procedure TNewCryptoVertScrollBox.setETHWalletForNewTokens(newETH: TwalletInfo);
begin

  ETHAddressForNewToken := newETH.addr;

end;

constructor TNewCryptoVertScrollBox.Create(AOwner: TComponent; acc: Account);
var
  i: Integer;
  ancp: TAddNewCryptoPanel;
  countToken, countETH: Integer;
  ethp: TNewCryptoVertScrollBox.TETHListPanel;

  coinLabel: TLabel;
  AddTokenToETH: TLabel;
begin

  inherited Create(AOwner);

  ac := acc;

  countToken := 0;

  CoinLayout := Tlayout.Create(self);
  CoinLayout.parent := self;
  CoinLayout.Align := tAlignLayout.Top;

  coinLabel := TLabel.Create(CoinLayout);
  coinLabel.parent := CoinLayout;
  coinLabel.Align := tAlignLayout.MostTop;
  coinLabel.Text := '----ADD NEW COIN/TOKEN----';
  coinLabel.TextSettings.HorzAlign := TTextAlign.Center;
  coinLabel.height := 48;

  for i := 0 to length(availableCoin) - 1 do
  begin
    ancp := TAddNewCryptoPanel.Create(CoinLayout);
    ancp.parent := CoinLayout;
    ancp.Align := tAlignLayout.Top;
    ancp.height := 48;
    ancp.Position.Y := 4800;
    ancp.Visible := true;
    ancp.Tag := i;
    ancp.TagString := 'coin';
    ancp.coinName.Text := availableCoin[i].name;
    ancp.coinIMG.Bitmap.LoadFromStream
      (ResourceMenager.getAssets(availableCoin[i].resourceName));

    if availableCoin[i].shortcut = 'ETH' then
    begin

      ethPanel := ancp;

      ETHTokenLayout := Tlayout.Create(CoinLayout);
      ETHTokenLayout.parent := CoinLayout;
      ETHTokenLayout.Align := tAlignLayout.Top;
      ETHTokenLayout.Position.Y := 4800;

      ethPanel.parent := ETHTokenLayout;
      tokenList := TNewTokenList.Create(ETHTokenLayout, ethPanel);
      tokenList.parent := ETHTokenLayout;
      tokenList.Align := tAlignLayout.Top;
      // ethp.Height := 960;
      ETHTokenLayout.height := ethPanel.height + tokenList.height;

    end;

  end;
  CoinLayout.height := ETHTokenLayout.height + (length(availableCoin)) * 48;

  ETHAddTokenLayout := Tlayout.Create(self);
  ETHAddTokenLayout.parent := self;
  ETHAddTokenLayout.Align := tAlignLayout.Top;

  AddTokenToETH := TLabel.Create(ETHAddTokenLayout);
  AddTokenToETH.parent := ETHAddTokenLayout;
  AddTokenToETH.Align := tAlignLayout.MostTop;
  AddTokenToETH.Text := '----ADD TOKEN TO EXISTING WALLET----';
  AddTokenToETH.TextSettings.HorzAlign := TTextAlign.Center;
  AddTokenToETH.height := 48;

  countETH := 0;
  for i := 0 to length(acc.myCoins) - 1 do
  begin

    if acc.myCoins[i].coin = 4 then
    begin

      countETH := countETH + 1;
      ethp := TETHListPanel.Create(ETHAddTokenLayout, acc.myCoins[i], acc);
      ethp.parent := ETHAddTokenLayout;
      ethp.Align := tAlignLayout.Top;

    end;

  end;
  if countETH = 0 then
  begin

  end
  else
  begin

    ETHAddTokenLayout.height := countETH * (ethp.height) + 48;

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
  coinName.Align := tAlignLayout.Client;
  coinName.HitTest := false;

  coinIMG := TImage.Create(self);
  coinIMG.parent := self;
  // coinIMG.Bitmap.LoadFromStream
  // (ResourceMenager.getAssets(availableCoin[0].resourceName));
  coinIMG.Align := tAlignLayout.Left;
  coinIMG.Margins.Top := 8;
  coinIMG.Margins.Bottom := 8;
  coinIMG.width := 50;
  coinIMG.HitTest := false;

  Edit := TEdit.Create(self);
  Edit.parent := self;
  Edit.Align := tAlignLayout.MostRight;
  Edit.Visible := false;
  Edit.width := self.width / 2;

  checkBox := TCheckBox.Create(self);
  checkBox.parent := self;
  checkBox.Align := tAlignLayout.mostLeft;
  checkBox.width := 24;
  checkBox.HitTest := false;
  checkBox.Margins.Left := 12;
  checkBox.onchange := onCheck;

end;

procedure TNewCryptoVertScrollBox.TAddNewCryptoPanel.PanelClick(Sender: TObject;
const Point: TPointF);
begin

  PanelClick(Sender);

end;

procedure TNewCryptoVertScrollBox.TAddNewCryptoPanel.PanelClick
  (Sender: TObject);
begin

  if checkBox.Enabled then
    checkBox.IsChecked := not checkBox.IsChecked;

end;

end.
