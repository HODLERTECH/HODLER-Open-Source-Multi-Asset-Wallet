unit TNewCryptoVertScrollBoxData;

interface

uses
  System.SysUtils, System.Classes, FMX.Types, FMX.Controls, FMX.Layouts, System.uitypes,
  FMX.Edit, FMX.StdCtrls, FMX.Clipboard, FMX.Platform, FMX.Objects, AccountData,
  System.Types, StrUtils, popupwindowData, coinData, TokenData, FMX.Dialogs,
  walletStructureData, System.Generics.Collections, KeypoolRelated , System.Math;

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
    TTokenList = class(Tlayout)

      // private
      // coinAddress: AnsiString;
      list: Tlist<TAddNewTokenPanel>;

    public
      function countChecked(): Integer;
      constructor Create(AOwner: TComponent; wd: TwalletInfo;
        ac: Account); overload;
      constructor Create(AOwner: TComponent;
        coinPanel: TAddNewCryptoPanel); overload;
      // procedure setCoinAddress( address : AnsiString );
      destructor destroy(); Override;

    end;

  type
    TETHPanel = class(TPanel)
    public
      ETHAddress: AnsiString;
      coinName: TLabel;
      //openImage, closeImage,
      coinIMG: TImage;

      changeETHlabel : TLabel;

      constructor Create(AOwner: TComponent); override;
      procedure Resize; override;
    end;

  type
    TExistingETHTokenList = class(Tlayout)

    private
      ethPanel: TETHPanel;
      tokenList: TTokenList;

      procedure hideShowTokenList(Sender: TObject;
        const Point: TPointF); overload;
      procedure hideShowTokenList(Sender: TObject); overload;

    published

      constructor Create(AOwner: TComponent; wd: TwalletInfo; ac: Account);

    public

    end;

  type
    TNewTokenManagementLayout = class(Tlayout)

      private
      { chooseETHPanel: Tlayout;
        newETHPanel: TLayout;
        existingETHTokenList: Tlist<TExistingETHTokenList>;
        currentLoaded : TLayout; }

      newETHPanel: TAddNewCryptoPanel;
      existingETHPanel: TETHPanel;
      tokenList: TTokenList;
      ac: Account;

      ListETHPanel: Tlayout;
      backGround: TRectangle;
      CountETH : Integer;

      constructor Create(AOwner: TComponent; acc: Account);
      destructor destroy(); Override;

      procedure prepareForNew();
      procedure prepareFor(wd: TwalletInfo; ac: Account);
    public
      procedure showETHList(); overload;

      procedure showETHList(Sender: TObject; const Point: TPointF); overload;
      procedure showETHList(Sender: TObject); overload;

      procedure loadNew(Sender: TObject; const Point: TPointF); overload;
      procedure loadNew(Sender: TObject); overload;

      procedure loadExist(Sender: TObject; const Point: TPointF); overload;
      procedure loadExist(Sender: TObject); overload;

      procedure createCryptoAndAddPanelTo(box: TVertScrollBox; MasterSeed : AnsiString ; ac: Account);

      // procedure addETHList( exist : TExistingETHTokenList );
      // procedure loadETHList( panel : TETHPanel );
    end;
  private

  published

    constructor Create(AOwner: TComponent; acc: Account);
    destructor destroy(); Override;

  public

    ETHAddressForNewToken: AnsiString;
    CoinLayout: Tlayout;
    ETHTokenMenager: TNewTokenManagementLayout;
    ETHAddTokenLayout: Tlayout;
    ETHTokenLayout: Tlayout;
    tokenList: TTokenList;

    coinlist: Tlist<TAddNewCryptoPanel>;

    ethPanel: TAddNewCryptoPanel;

    tokenCount: Integer;
    ac: Account;
    procedure setETHWalletForNewTokens(newETH: TwalletInfo);
    procedure clear();
    procedure prepareForAccount(acc: Account);
    procedure createCryptoAndAddPanelTo(box: TVertScrollBox);
    procedure RecalcETHAddTokenLayoutSize();

    procedure changeETH(Sender: TObject; const Point: TPointF); overload;
    procedure changeETH(Sender: TObject); overload;

  end;

procedure Register;

implementation

uses misc, languages, uhome;

procedure Register;
begin
  RegisterComponents('Samples', [TNewCryptoVertScrollBox]);
end;

{ procedure TNewCryptoVertScrollBox.TNewTokenManagementLayout.addETHList( exist : TExistingETHTokenList );
  begin

  if existingETHTokenList.Count = 0 then
  begin
  exist.parent := self;
  newETHPanel.parent := chooseETHPanel;

  end
  else
  begin
  exist.Parent := chooseETHPanel;
  end;
  existingETHTokenList.Add( exist );
  end; }
procedure TNewCryptoVertScrollBox.TETHPanel.Resize;
begin

  inherited;
  changeETHlabel.width := width / 2;

end;
procedure TNewCryptoVertScrollBox.TNewTokenManagementLayout.loadNew
  (Sender: TObject; const Point: TPointF);
begin
  prepareForNew();
  ListETHPanel.visiBle := false;
end;

procedure TNewCryptoVertScrollBox.TNewTokenManagementLayout.loadNew
  (Sender: TObject);
begin
  prepareForNew();
  ListETHPanel.visiBle := false;
end;

procedure TNewCryptoVertScrollBox.TNewTokenManagementLayout.loadExist
  (Sender: TObject; const Point: TPointF);
begin
  prepareFor( TwalletInfo( TfmxObject(Sender).TagObject)  , ac );
  ListETHPanel.visiBle := false;
end;

procedure TNewCryptoVertScrollBox.TNewTokenManagementLayout.loadExist
  (Sender: TObject);
begin
  prepareFor( TwalletInfo( TfmxObject(Sender).TagObject)  , ac );
  ListETHPanel.visiBle := false;
end;

procedure TNewCryptoVertScrollBox.TNewTokenManagementLayout.showETHList
  (Sender: TObject; const Point: TPointF);
begin
  showETHList();
end;

procedure TNewCryptoVertScrollBox.TNewTokenManagementLayout.showETHList
  (Sender: TObject);
begin
  showETHList();
end;

procedure TNewCryptoVertScrollBox.TNewTokenManagementLayout.showETHList();
var
  I: Integer;


begin

  ListETHPanel.Visible := true;
  ListETHPanel.BringToFront;

  Height := max( Height , (ListETHPanel.ChildrenCount -1) * 48 );



end;

procedure TNewCryptoVertScrollBox.TNewTokenManagementLayout.createCryptoAndAddPanelTo(box: TVertScrollBox ; MasterSeed : AnsiString ; ac: Account);
var
  i : Integer;
  T : Token;
  ETHAddressForNewToken : AnsiString;
  WalletInfo : TWalletInfo;
begin

  if CountETH =0 then
  begin
    if newETHPanel.checkBox.IsChecked = false then
      exit();

    WalletInfo := coinData.createCoin(4, getFirstUnusedXforCoin(4), 0,
          MasterSeed, newETHPanel.Edit.Text);

        ac.AddCoin(WalletInfo);
        // TThread.Synchronize(nil,
        // procedure
        // begin
        CreatePanel(WalletInfo, ac, box);
        // end);

        ETHAddressForNewToken := WalletInfo.addr;
  end
  else
  begin
    ETHAddressForNewToken :=  existingETHPanel.ETHAddress;
  end;

  for i := 0 to tokenList.list.Count -1 do
  begin
    if tokenList.list[i].Enabled and tokenList.list[i].checkBox.IsChecked then
    begin
      T := Token.Create( tokenList.list[i].Tag, ETHAddressForNewToken);

          T.idInWallet := length(ac.myTokens) + 10000;

          ac.addToken(T);
          // TThread.Synchronize(nil,
          // procedure
          // begin
          CreatePanel(T, ac, box);
          // end);
    end;
  end;

end;

constructor TNewCryptoVertScrollBox.TNewTokenManagementLayout.Create
  (AOwner: TComponent; acc: Account);
var
  I: Integer;
  ETHWallet: TwalletInfo;
  tempPanel: TETHPanel;
begin
  inherited Create(AOwner);
  ETHWallet := nil;
  ac := acc;
  CountETH := 0;

  ListETHPanel := Tlayout.Create(self);
  ListETHPanel.Parent := self;
  ListETHPanel.Align := TAlignLayout.Contents;
  ListETHPanel.Visible := false;


  backGround := TRectangle.create(ListETHPanel);
  backGround.Visible := true;
  backGround.Opacity := 0.5;
  backGround.Parent := ListETHPanel;
  backGround.Align := TAlignLayout.Contents;
  backGround.Fill.Color := TAlphaColorF.create(0, 0, 0, 0.5).ToAlphaColor;


  //backGround.OnClick := backGroundClick;
  {tempPanel := TETHPanel.Create(ListETHPanel);
  tempPanel.Parent := ListETHPanel;
  tempPanel.Align := TAlignLayout.MostTop;
  tempPanel.height := 48;
  tempPanel.coinName.Text := ' + Add New Ethereum';
  tempPanel.coinIMG.Bitmap.loadFromStream
    (ResourceMenager.getAssets(availableCoin[4].resourceName));
  tempPanel.ETHAddress := '';

  tempPanel.OnClick := loadNew;  }

  for I := 0 to length(ac.myCoins) - 1 do
  begin
    if ac.myCoins[I].coin = 4 then
    begin
      countETH := countETH + 1;

      tempPanel := TETHPanel.Create(ListETHPanel);
      tempPanel.Parent := ListETHPanel;
      tempPanel.Align := TAlignLayout.Top;
      tempPanel.height := 48;
      tempPanel.coinName.Text := ac.getDescription(4, ac.myCoins[I].X);
      tempPanel.coinIMG.Bitmap.loadFromStream
        (ResourceMenager.getAssets(availableCoin[4].resourceName));
      tempPanel.ETHAddress := ac.myCoins[I].addr;
      tempPanel.TagObject := ac.myCoins[i];

      tempPanel.OnClick := loadExist;

    end;
  end;




  for I := 0 to length(ac.myCoins) - 1 do
  begin

    if ac.myCoins[I].coin = 4 then
    begin

      if ETHWallet = nil then
      begin
        ETHWallet := ac.myCoins[I];
        break;
      end;

    end;

  end;

  if ETHWallet = nil then
  begin
    prepareForNew();
  end
  else
  begin
    prepareFor(ETHWallet, ac);
  end;

  { existingETHTokenList := Tlist<TExistingETHTokenList>.Create();

    chooseETHPanel := Tlayout.create(self);
    chooseEthPanel.Parent := self;
    chooseETHPanel.align := TalignLayout.Contents;
    chooseETHPanel.visible := false;
    chooseETHPanel.BringToFront(); }
  // chooseEthPanel.Opacity := 0.5;
end;

procedure TNewCryptoVertScrollBox.TNewTokenManagementLayout.prepareForNew();
begin
  //existingETHPanel.Visible := false;
  existingETHPanel.DisposeOf;
  tokenlist.DisposeOf;
  newETHPanel.DisposeOf;
  existingETHPanel := nil;
  tokenList := nil;
  newETHPanel := nil;

  newETHPanel := TAddNewCryptoPanel.Create(self);
  newETHPanel.Parent := self;
  newETHPanel.Align := TAlignLayout.Top;
  newETHPanel.height := 48;
  //newETHPanel.Position.Y := 4800;
  newETHPanel.Visible := true;
  newETHPanel.Tag := I;
  newETHPanel.TagString := 'coin';
  newETHPanel.coinName.Text := availableCoin[4].name;
  newETHPanel.coinIMG.Bitmap.loadFromStream
    (ResourceMenager.getAssets(availableCoin[4].resourceName));

  //newETHPanel.OnClick := /showETHList;

  tokenList := TTokenList.Create(self, newETHPanel);
  tokenList.Parent := self;
  tokenList.Align := TAlignLayout.Top;
  tokenList.Visible := true;

  self.height := newETHPanel.height + tokenList.height;
end;

procedure TNewCryptoVertScrollBox.TNewTokenManagementLayout.prepareFor
  (wd: TwalletInfo; ac: Account);
begin
  existingETHPanel.DisposeOf;
  tokenlist.DisposeOf;
  newETHPanel.DisposeOf;
  existingETHPanel := nil;
  tokenList := nil;
  newETHPanel := nil;

  existingETHPanel := TETHPanel.Create(self);
  existingETHPanel.Parent := self;
  existingETHPanel.Align := TAlignLayout.MostTop;
  existingETHPanel.height := 48;
  existingETHPanel.coinName.Text := ac.getDescription(wd.coin, wd.X);
  existingETHPanel.coinIMG.Bitmap.loadFromStream
    (ResourceMenager.getAssets(availableCoin[4].resourceName));
  existingETHPanel.ETHAddress := wd.addr;
  (*
    {$IFDEF ANDROID}
    ethPanel.OnTap := TNewCryptoVertScrollBox.changeETH;
    {$ELSE}
    ethPanel.OnClick := changeETH;
    {$ENDIF} *)
  existingETHPanel.OnClick := showETHList;

  tokenList := TTokenList.Create(self, wd, ac);
  tokenList.Parent := self;
  tokenList.Align := TAlignLayout.Top;
  tokenList.Visible := true;
  self.height := existingETHPanel.height + tokenList.height;
end;

destructor TNewCryptoVertScrollBox.TNewTokenManagementLayout.destroy();
begin

  inherited;
end;

procedure TNewCryptoVertScrollBox.changeETH(Sender: TObject;
  const Point: TPointF);
begin
  changeETH(Sender);
end;

procedure TNewCryptoVertScrollBox.changeETH(Sender: TObject);
begin
  { if ETHTokenMenager.chooseETHPanel.Visible = false then
    begin

    ETHTokenMenager.chooseETHPanel.Visible := true;
    ETHTokenMenager.chooseETHPanel.BringToFront;
    end
    else
    begin
    ETHTokenMenager.chooseETHPanel.Visible := false;
    ETHTokenMenager.loadETHList( Sender );

    end; }

end;
{
  procedure TNewCryptoVertScrollBox.TNewTokenManagementLayout.loadETHList( );
  begin

  end; }

procedure TNewCryptoVertScrollBox.RecalcETHAddTokenLayoutSize();
var
  temp: Single;
  I: Integer;
begin

  temp := 0;

  for I := 0 to ETHAddTokenLayout.children.count - 1 do
  begin
    temp := temp + TExistingETHTokenList(ETHAddTokenLayout.children[I]).height;
  end;

  ETHAddTokenLayout.height := temp;

end;

procedure TNewCryptoVertScrollBox.createCryptoAndAddPanelTo
  (box: TVertScrollBox);
begin

  frmhome.NotificationLayout.popupPasswordConfirm(
    procedure(password: String)
    var
      MasterSeed: AnsiString;
    var
      I, j: Integer;
      ancp: TNewCryptoVertScrollBox.TAddNewCryptoPanel;
      WalletInfo: TwalletInfo;
      T: Token;
      ETHAddressForNewToken: AnsiString;
      countETH: Integer;
      tempTokenList: TExistingETHTokenList;
    begin

      try
        MasterSeed := CurrentAccount.getDecryptedMasterSeed(password);
      except
        on E: Exception do
        begin
          popupWindow.Create(E.Message);
          exit;
        end;
      end;

      for I := 0 to CoinLayout.children.count - 1 do
      begin

        if CoinLayout.children[I] is TNewCryptoVertScrollBox.TAddNewCryptoPanel
        then
        begin
          ancp := TNewCryptoVertScrollBox.TAddNewCryptoPanel
            (CoinLayout.children[I]);
        end
        else
          Continue;

        if ancp.checkBox.IsChecked then
        begin

          WalletInfo := coinData.createCoin(ancp.Tag,
            getFirstUnusedXforCoin(ancp.Tag), 0, MasterSeed, ancp.Edit.Text);

          ac.AddCoin(WalletInfo);
          // TThread.Synchronize(nil,
          // procedure
          // begin
          CreatePanel(WalletInfo, ac, box);
          // end);

        end;

      end;

      ETHTokenMenager.createCryptoAndAddPanelTo( box, MasterSeed, ac );
      {if ethPanel.checkBox.IsChecked then
      begin

        WalletInfo := coinData.createCoin(4, getFirstUnusedXforCoin(4), 0,
          MasterSeed, ethPanel.Edit.Text);

        ac.AddCoin(WalletInfo);
        // TThread.Synchronize(nil,
        // procedure
        // begin
        CreatePanel(WalletInfo, ac, box);
        // end);

        ETHAddressForNewToken := WalletInfo.addr;
      end; }

      {for I := 0 to tokenList.children.count - 1 do
      begin
        if tokenList.children[I] is TAddNewCryptoPanel then
          ancp := TAddNewCryptoPanel(tokenList.children[I])
        else
          Continue;
        if ancp.checkBox.IsChecked then
        begin

          T := Token.Create(ancp.Tag, ETHAddressForNewToken);

          T.idInWallet := length(ac.myTokens) + 10000;

          ac.addToken(T);
          // TThread.Synchronize(nil,
          // procedure
          // begin
          CreatePanel(T, ac, box);
          // end);

        end;

      end;

      for I := 0 to ETHAddTokenLayout.children.count - 1 do
      begin

        if ETHAddTokenLayout.children[I] is TExistingETHTokenList then
        begin

          tempTokenList := TExistingETHTokenList(ETHAddTokenLayout.children[I]);
          for j := 0 to tempTokenList.tokenList.ChildrenCount - 1 do
          begin

            if tempTokenList.tokenList.children[j] is TAddNewTokenPanel then
              ancp := TAddNewTokenPanel(tempTokenList.tokenList.children[j])
            else
              Continue;

            if ancp.checkBox.IsChecked then
            begin

              T := Token.Create(ancp.Tag, tempTokenList.ethPanel.ETHAddress);

              T.idInWallet := length(ac.myTokens) + 10000;

              ac.addToken(T);
              // TThread.Synchronize(nil,
              // procedure
              // begin
              CreatePanel(T, ac, box);
              // end);

              { end
                else
                begin
                if ac.TokenExistInETH( ancp.Tag , tempTokenlist.ethPanel.ETHAddress) then
                begin

                end;

            end;
          end;

        end;

      end;   }

      startFullfillingKeypool(MasterSeed);
      // TThread.Synchronize(nil,
      // procedure
      // begin

      frmhome.btnSyncClick(nil);

      // end);
      switchTab(frmhome.PageControl, HOME_TABITEM);

    end,
    procedure(password: String)
    begin

    end, 'Please insert password to continue.', 'Continue', 'Cancel');

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

function TNewCryptoVertScrollBox.TTokenList.countChecked(): Integer;
var
  I: Integer;
begin
  result := 0;
  for I := 0 to children.count - 1 do
  begin

    if children[I] is TAddNewCryptoPanel then
    begin

      if TAddNewCryptoPanel(children[I]).checkBox.IsChecked then
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

  if TTokenList(Parent).countChecked <> 0 then
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
  if TTokenList(Parent).countChecked <> 0 then
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

procedure TNewCryptoVertScrollBox.TExistingETHTokenList.hideShowTokenList
  (Sender: TObject; const Point: TPointF);

begin

  tokenList.Visible := not tokenList.Visible;
  //ethPanel.closeImage.Visible := tokenList.Visible;
  //ethPanel.openImage.Visible := not tokenList.Visible;

  if tokenList.Visible = true then
  begin
    height := tokenList.height + 48;
  end
  else
  begin
    height := 48;
  end;
  TNewCryptoVertScrollBox(Parent.Parent.Parent).RecalcETHAddTokenLayoutSize();

end;

procedure TNewCryptoVertScrollBox.TExistingETHTokenList.hideShowTokenList
  (Sender: TObject);
begin

  hideShowTokenList(Sender, TPointF.Zero);

end;

constructor TNewCryptoVertScrollBox.TAddNewTokenPanel.Create
  (AOwner: TComponent);
begin
  inherited;

  treeImage := TImage.Create(self);
  treeImage.Parent := self;
  treeImage.Align := TAlignLayout.mostLeft;
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
  coinName.Parent := self;
  // coinName.Text := 'test';
  coinName.Visible := true;
  coinName.Align := TAlignLayout.Client;
  coinName.HitTest := false;

  coinIMG := TImage.Create(self);
  coinIMG.Parent := self;
  // coinIMG.Bitmap.LoadFromStream
  // (ResourceMenager.getAssets(availableCoin[0].resourceName));
  coinIMG.Align := TAlignLayout.Left;
  coinIMG.Margins.Top := 8;
  coinIMG.Margins.Bottom := 8;
  coinIMG.width := 50;
  coinIMG.HitTest := false;

  changeETHlabel := TLabel.create(self);
  changeETHLabel.Parent := self;
  changeETHLabel.align := TalignLayout.Right;
  changeETHLabel.Text := 'Click here to change ETH';
  changeETHLABEL.TextAlign := TTextAlign.Center;


  {closeImage := TImage.Create(self);
  closeImage.Parent := self;
  closeImage.Align := TAlignLayout.Mostright;
  closeImage.Bitmap.loadFromStream(ResourceMenager.getAssets('UP_ARROW'));
  closeImage.Margins.Left := 14;
  closeImage.Margins.Right := 0;
  closeImage.Margins.Bottom := 20;
  closeImage.Margins.Top := 20;
  closeImage.width := 44;
  closeImage.HitTest := false;
  closeImage.WrapMode := TimageWrapMode.fit;

  openImage := TImage.Create(self);
  openImage.Parent := self;
  openImage.Align := closeImage.Align;
  openImage.Bitmap.loadFromStream(ResourceMenager.getAssets('DOWN_ARROW'));
  openImage.Margins := closeImage.Margins;
  openImage.width := closeImage.width;
  openImage.HitTest := false;
  openImage.Visible := false;
  openImage.WrapMode := closeImage.WrapMode; }

end;

constructor TNewCryptoVertScrollBox.TExistingETHTokenList.Create
  (AOwner: TComponent; wd: TwalletInfo; ac: Account);
begin

  inherited Create(AOwner);

  ethPanel := TETHPanel.Create(self);
  ethPanel.Parent := self;
  ethPanel.Align := TAlignLayout.MostTop;
  ethPanel.height := 48;

  ethPanel.coinName.Text := ac.getDescription(wd.coin, wd.X);

  ethPanel.coinIMG.Bitmap.loadFromStream
    (ResourceMenager.getAssets(availableCoin[4].resourceName));

  ethPanel.ETHAddress := wd.addr;
  (*
    {$IFDEF ANDROID}
    ethPanel.OnTap := TNewCryptoVertScrollBox.changeETH;
    {$ELSE}
    ethPanel.OnClick := changeETH;
    {$ENDIF} *)
  tokenList := TTokenList.Create(self, wd, ac);
  tokenList.Parent := self;
  tokenList.Align := TAlignLayout.Top;
  tokenList.Visible := false;


  // tokenlist.Height := 480;

  height := { tokenList.height + } ethPanel.height;

end;

destructor TNewCryptoVertScrollBox.TTokenList.destroy();
begin
  list.disposeof();
  inherited;
end;

constructor TNewCryptoVertScrollBox.TTokenList.Create(AOwner: TComponent;
coinPanel: TAddNewCryptoPanel);
var
  I: Integer;
  ancp: TAddNewTokenPanelForNewETH;
  countToken: Integer;
begin

  inherited Create(AOwner);
  list := Tlist<TAddNewTokenPanel>.Create();
  countToken := 0;
  for I := 0 to length(Token.availableToken) - 1 do
  begin
    if Token.availableToken[I].address = '' then
      Continue;

    countToken := countToken + 1;

    ancp := TAddNewTokenPanelForNewETH.Create(self);
    ancp.ethPanel := coinPanel;

    // ancp.Margins.Left := 10;
    ancp.Parent := self;
    ancp.Align := TAlignLayout.Top;
    ancp.height := 48;
    ancp.Position.Y := 48 + I * 48;
    ancp.Visible := true;
    ancp.Tag := I;
    ancp.TagString := 'token';
    ancp.coinName.Text := Token.availableToken[I].name;
    ancp.coinIMG.Bitmap.loadFromStream
      (ResourceMenager.getAssets(Token.availableToken[I].resourceName));
    ancp.treeImage.Bitmap.loadFromStream(ResourceMenager.getAssets('ETH_TREE'));

    ancp.checkBox.IsChecked := false;
    ancp.Edit.Visible := false;
    list.add(ancp);
  end;

  ancp.treeImage.Bitmap.loadFromStream
    (ResourceMenager.getAssets('ETH_TREE_SHORT'));

  self.height := countToken * 48;

end;

constructor TNewCryptoVertScrollBox.TTokenList.Create(AOwner: TComponent;
wd: TwalletInfo; ac: Account);
var
  I: Integer;
  ancp: TAddNewTokenPanel;
  countToken: Integer;
begin

  inherited Create(AOwner);
  ancp := nil;
  list := Tlist<TAddNewTokenPanel>.Create();
  countToken := 0;
  for I := 0 to length(Token.availableToken) - 1 do
  begin
    if Token.availableToken[I].address = '' then
      Continue;

    countToken := countToken + 1;

    ancp := TAddNewTokenPanel.Create(self);
    ancp.Parent := self;
    ancp.Align := TAlignLayout.Top;
    ancp.height := 48;
    ancp.Position.Y := 48 + I * 48;
    ancp.Visible := true;
    ancp.Tag := I;
    ancp.TagString := 'token';
    ancp.coinName.Text := Token.availableToken[I].name;
    ancp.coinIMG.Bitmap.loadFromStream
      (ResourceMenager.getAssets(Token.availableToken[I].resourceName));
    ancp.treeImage.Bitmap.loadFromStream(ResourceMenager.getAssets('ETH_TREE'));



    // ancp.Edit.Width := 200;

    if (wd <> nil) and (ac <> nil) then
    begin

      if ac.TokenExistinETh(Token.availableToken[I].id, wd.addr) then
      begin

        ancp.Enabled := false;
        ancp.checkBox.IsChecked := true;
        // ancp.Edit.Visible := true;

      end;

    end;

    list.add(ancp);
  end;
  if ancp <> nil then
    ancp.treeImage.Bitmap.loadFromStream
      (ResourceMenager.getAssets('ETH_TREE_SHORT'));

  self.height := countToken * 48;

end;

procedure TNewCryptoVertScrollBox.prepareForAccount(acc: Account);
var
  I, countETH: Integer;
  firstETHList, ethp: TNewCryptoVertScrollBox.TExistingETHTokenList;

  countHeight: Single;
  FirstETHAddr: AnsiString;
  ancp : TAddNewCryptoPanel;
begin

  clear();

  ETHTokenMenager.DisposeOf;

  ETHTokenMenager := TNewTokenManagementLayout.Create(self, acc);
  ETHTokenMenager.Parent := self;
  ETHTokenMenager.Align := TAlignLayout.Top;

  if EthPanel <> nil then
    coinlist.Remove( ethPanel);
  ethPanel.DisposeOf;
  ethPanel := nil;



  if ETHTokenMenager.CountETH <> 0 then
  begin
    ancp := TAddNewCryptoPanel.Create(CoinLayout);
    ancp.Parent := CoinLayout;
    ancp.Align := TAlignLayout.Top;
    ancp.height := 48;
    ancp.Position.Y := 48 * 4;
    ancp.Visible := true;
    ancp.Tag := 4;
    ancp.TagString := 'coin';
    ancp.coinName.Text := availableCoin[4].name;
    ancp.coinIMG.Bitmap.loadFromStream
      (ResourceMenager.getAssets(availableCoin[4].resourceName));

    ethPanel := ancp;
  end;

  RealignContent;


  { for i := ETHTokenMenager.existingETHTokenList.count - 1 downto 0 do
    begin
    ETHTokenMenager.existingETHTokenList[i].disposeof();
    end;
    ETHTokenMenager.existingETHTokenList.Clear; }
  {
    i := 0;
    while( i <  ETHAddTokenLayout.Children.Count ) do
    begin
    if ETHAddTOkenLayout.Children[i] is TExistingETHTokenList then
    begin
    ETHAddTOkenLayout.Children[i].DisposeOf;
    i := -1;
    end;
    inc(i);
    end; }

  { countETH := 0;
    countHeight := 0;

    for I := 0 to length(acc.myCoins) - 1 do
    begin

    if acc.myCoins[I].coin = 4 then
    begin

    countETH := countETH + 1;
    ethp := TExistingETHTokenList.Create(ETHTokenMenager,
    acc.myCoins[I], acc);
    ethp.ethPanel.OnClick := changeETH;
    ethp.parent := ETHTokenMenager;
    ethp.Align := tAlignLayout.Top;
    countHeight := countHeight + ethp.height;
    // ETHTokenMenager.addETHList(ethp);

    if countETH = 1 then
    begin
    FirstETHAddr := acc.myCoins[I].addr;
    firstETHList := ethp;
    end;
    end;

    end; }

  { if countETH = 0 then
    begin
    ETHTokenLayout.Parent := CoinLayout;
    firstETHList.Parent := ETHAddTokenLayout;
    end
    else
    begin
    ETHTokenLayout.Parent := ETHAddTokenLayout;
    firstETHList.Parent := CoinLayout;


    end; }// ETHAddTokenLayout.height := countHeight + 48 + 48;
end;

procedure TNewCryptoVertScrollBox.clear();
var
  I, j: Integer;
begin

   for I := 0 to coinlist.count - 1 do
    begin
    coinlist[I].checkBox.IsChecked := false;
    end;

   { ethPanel.checkBox.Enabled := true;

    for I := 0 to tokenList.list.count - 1 do
    begin
    tokenList.list[I].checkBox.IsChecked := false;
    end;

    for j := 0 to ETHAddTokenLayout.children.count - 1 do
    begin

    if ETHAddTokenLayout.children[j] is TExistingETHTokenList then
    begin

    for I := 0 to TExistingETHTokenList(ETHAddTokenLayout.children[j])
    .tokenList.list.count - 1 do
    begin
    TExistingETHTokenList(ETHAddTokenLayout.children[j]).tokenList.list[I]
    .checkBox.IsChecked := false;
    end;

    end;

    end; }

end;

procedure TNewCryptoVertScrollBox.setETHWalletForNewTokens(newETH: TwalletInfo);
begin

  ETHAddressForNewToken := newETH.addr;

end;

destructor TNewCryptoVertScrollBox.destroy();
begin

  coinlist.disposeof();

  inherited;

end;

constructor TNewCryptoVertScrollBox.Create(AOwner: TComponent; acc: Account);
var
  I: Integer;
  ancp: TAddNewCryptoPanel;
  countToken, countETH: Integer;
  ethp: TNewCryptoVertScrollBox.TExistingETHTokenList;

  coinLabel: TLabel;
  AddTokenToETH: TLabel;
begin

  inherited Create(AOwner);

  coinlist := Tlist<TAddNewCryptoPanel>.Create();

  ac := acc;

  countToken := 0;

  ETHTokenMenager := TNewTokenManagementLayout.Create(self, acc);
  ETHTokenMenager.Parent := self;
  ETHTokenMenager.Align := TAlignLayout.Top;

  CoinLayout := Tlayout.Create(self);
  CoinLayout.Parent := self;
  CoinLayout.Align := TAlignLayout.Top;

  coinLabel := TLabel.Create(CoinLayout);
  coinLabel.Parent := CoinLayout;
  coinLabel.Align := TAlignLayout.MostTop;
  coinLabel.Text := '----ADD NEW COIN/TOKEN----';
  coinLabel.TextSettings.HorzAlign := TTextAlign.Center;
  coinLabel.height := 48;

  {ETHAddTokenLayout := Tlayout.Create(self);
  ETHAddTokenLayout.Parent := self;
  ETHAddTokenLayout.Align := TAlignLayout.Top;
  ETHAddTokenLayout.height := 4 * 48;  }

  for I := 0 to length(availableCoin) - 1 do
  begin
    if (I = 4) and (ETHTokenMenager.CountETH = 0) then
      Continue;
    ancp := TAddNewCryptoPanel.Create(CoinLayout);
    ancp.Parent := CoinLayout;
    ancp.Align := TAlignLayout.Top;
    ancp.height := 48;
    ancp.Position.Y := 4800;
    ancp.Visible := true;
    ancp.Tag := I;
    ancp.TagString := 'coin';
    ancp.coinName.Text := availableCoin[I].name;
    ancp.coinIMG.Bitmap.loadFromStream
      (ResourceMenager.getAssets(availableCoin[I].resourceName));

   if availableCoin[I].shortcut = 'ETH' then
    begin

      ethPanel := ancp;
      ETHTokenMenager.Position.Y := ethPanel.Position.Y +1 ;

      {ethPanel.OnClick := changeETH;
      ETHTokenLayout := Tlayout.Create(ETHTokenMenager);
      ETHTokenLayout.Parent := ETHTokenMenager;
      ETHTokenLayout.Align := TAlignLayout.Top;
      ETHTokenLayout.Position.Y := 4800;

      ethPanel.Parent := ETHTokenLayout;
      tokenList := TTokenList.Create(ETHTokenLayout, ethPanel);
      tokenList.Parent := ETHTokenLayout;
      tokenList.Align := TAlignLayout.Top;
      tokenList.Visible := false;
      // ethp.Height := 960;
      ETHTokenLayout.height := ethPanel.height; // + tokenList.height;
      // ETHTokenMenager.newETHPanel := ETHTokenLayout;    }
    end;
    coinlist.add(ancp);
  end;

  CoinLayout.height := { ETHTokenLayout.height + }  (coinList.Count + 1) * 48;

  Height := CoinLayout.height + ETHTokenMenager.Height;

 { AddTokenToETH := TLabel.Create(ETHAddTokenLayout);
  AddTokenToETH.Parent := ETHAddTokenLayout;
  AddTokenToETH.Align := TAlignLayout.MostTop;
  AddTokenToETH.Text := '----Select ETH for new token----';
  AddTokenToETH.TextSettings.HorzAlign := TTextAlign.Center;
  AddTokenToETH.height := 48;  }

  // prepareForAccount(acc);

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
  coinName.Parent := self;
  // coinName.Text := 'test';
  coinName.Visible := true;
  coinName.Align := TAlignLayout.Client;
  coinName.HitTest := false;

  coinIMG := TImage.Create(self);
  coinIMG.Parent := self;
  // coinIMG.Bitmap.LoadFromStream
  // (ResourceMenager.getAssets(availableCoin[0].resourceName));
  coinIMG.Align := TAlignLayout.Left;
  coinIMG.Margins.Top := 8;
  coinIMG.Margins.Bottom := 8;
  coinIMG.width := 50;
  coinIMG.HitTest := false;

  Edit := TEdit.Create(self);
  Edit.Parent := self;
  Edit.Align := TAlignLayout.Mostright;
  Edit.Visible := false;
  Edit.width := self.width / 2;

  checkBox := TCheckBox.Create(self);
  checkBox.Parent := self;
  checkBox.Align := TAlignLayout.mostLeft;
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
