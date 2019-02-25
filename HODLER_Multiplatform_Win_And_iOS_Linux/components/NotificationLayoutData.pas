unit NotificationLayoutData;

interface

uses
  System.SysUtils, System.Classes, FMX.Types, FMX.Controls, FMX.Layouts, System.uiTypes,
  FMX.Edit, FMX.StdCtrls, FMX.Clipboard, FMX.Platform, FMX.Objects, fmx.graphics,
  System.Types, StrUtils, FMX.Dialogs , crossplatformHeaders ,System.Generics.Collections  ,FMX.VirtualKeyboard;

type
  PasswordDialog = class( TLayout )
    public
    //protectWord : AnsiString;

   _protectLayout : TLayout;
    _staticInfoLabel : TLabel;
    _edit : TEdit;
    //_ProtectWordLabel : TLAbel;

    _lblMessage: TLabel;

    _ImageLayout: TLayout;
    _Image: TImage;

    _ButtonLayout: TLayout;
    _YesButton: TButton;
    _NoButton: TButton;

    _onYesPress: TProc<AnsiString>;
    _onNoPress: TProc<AnsiString>;

    procedure _onYesClick(sender: TObject);
    procedure _onNoClick(sender: TObject);
    //procedure _OnExit(sender: TObject);
    //procedure checkProtect(Sender : TObject );


    constructor create( Owner : TComponent ; Yes, No: TProc<AnsiString>; mess: AnsiString;
      YesText: AnsiString = 'Yes'; NoText: AnsiString = 'No';
      icon: integer = 2);

    destructor destroy(); Override;

  end;

type
  ProtectedConfirmDialog = class( Tlayout )
    public
    protectWord : AnsiString;

    _protectLayout : TLayout;
    _staticInfoLabel : TLabel;
    _edit : TEdit;
    _ProtectWordLabel : TLAbel;

    _lblMessage: TLabel;

    _ImageLayout: TLayout;
    _Image: TImage;

    _ButtonLayout: TLayout;
    _YesButton: TButton;
    _NoButton: TButton;

    _onYesPress: TProc;
    _onNoPress: TProc;

    procedure _onYesClick(sender: TObject);
    procedure _onNoClick(sender: TObject);
    //procedure _OnExit(sender: TObject);
    procedure checkProtect(Sender : TObject );


    constructor create( Owner : TComponent ; Yes, No: TProc; mess: AnsiString;
      YesText: AnsiString = 'Yes'; NoText: AnsiString = 'No';
      icon: integer = 2);

    destructor destroy(); Override;

  end;

type
  YesNoDialog = class( Tlayout )
  private
    _lblMessage: TLabel;

    _ImageLayout: TLayout;
    _Image: TImage;

    _ButtonLayout: TLayout;
    _YesButton: TButton;
    _NoButton: TButton;

    _onYesPress: TProc;
    _onNoPress: TProc;

    procedure _onYesClick(sender: TObject);
    procedure _onNoClick(sender: TObject);
    //procedure _OnExit(sender: TObject);

  public
    constructor Create( Owner : TComponent ; Yes, No: TProc; mess: AnsiString;
      YesText: AnsiString = 'Yes'; NoText: AnsiString = 'No';
      icon: integer = 2);

    destructor destroy(); Override;
  end;

type
  TNotificationLayout = class( TLayout )

  popupStack : TStack<Tlayout>;
  notificationStack : TStack<Tlayout>;

  CurrentPOpup : Tlayout;
  PopupQueue : TQueue<Tlayout>;

  backGround : TRectangle;

  constructor create( Owner : TComponent); override;
  destructor destroy(); Override;

  procedure backGroundClick(Sender : TObject);

  procedure ClosePopup();

  procedure moveCurrentPopupToTop();
  procedure centerCurrentPopup();
  //procedure layoutClick(Sender : TObject);

  //procedure AddNotification( msg : AnsiString ; time : integer = 15 );

  procedure popupProtectedConfirm(Yes: TProc; No: TProc; mess: AnsiString;
    YesText: AnsiString = 'Yes'; NoText: AnsiString = 'No'; icon: integer = 2);

  procedure popupPasswordConfirm(Yes: TProc<AnsiString>; No: TProc<AnsiString>; mess: AnsiString;
    YesText: AnsiString = 'Yes'; NoText: AnsiString = 'No'; icon: integer = 2);

  procedure popupConfirm(Yes, No: TProc; mess: AnsiString;
      YesText: AnsiString = 'Yes'; NoText: AnsiString = 'No';
      icon: integer = 2);

  //procedure popup( msg : AnsiString );
  //procedure popup(

  end;

implementation
uses
  uhome;

procedure TNotificationLayout.moveCurrentPopupToTop();
begin
  try
  if currentpopup <> nil then
    Currentpopup.AnimateFloat( 'position.y' , 0 , 0.2 );
  except
  on E:Exception do begin end;

  end;
end;

procedure TNotificationLayout.centerCurrentPopup();
begin
 try
  if currentpopup <> nil then
    Currentpopup.AnimateFloat( 'position.y' , ( Self.Height / 2 ) - (currentPopup.Height / 2 )  , 0.2 );
  Except on E:Exception do begin end; end;
end;

procedure TNotificationLayout.ClosePopup;
var
  KeyboardService: IFMXVirtualKeyboardService;
begin
 try
{$IFDEF ANDROID}
  if TPlatformServices.Current.SupportsPlatformService(IFMXVirtualKeyboardService, IInterface(KeyboardService)) then
   if KeyboardService<>nil then KeyboardService.HideVirtualKeyboard;
{$ENDIF}

 {$IFNDEF ANDROID}
  Currentpopup.AnimateFloat( 'position.x' ,  self.width + currentpopup.width  , 0.2 );

  backGround.AnimateFloat( 'opacity' , 0 , 0.2 );
  backGround.AnimateInt( 'visible' , 0 , 0.2);
  {$ENDIF}
  background.HitTest :=false;



  tthread.CreateAnonymousThread(procedure
  var
    del : TLayout;
  begin
    del := CurrentPOpup;
    CurrentPOpup := nil;

    sleep(1000);

    del.DisposeOf;
    del := nil;

  end).Start;
except on E:Exception do begin end; end;

end;

procedure TNotificationLayout.backgroundClick(Sender : TObject);
begin

  ClosePopup;

end;

procedure TNotificationLayout.popupPasswordConfirm(Yes, No: TProc<AnsiString>; mess: AnsiString;
      YesText: AnsiString = 'Yes'; NoText: AnsiString = 'No';
      icon: integer = 2);
var
  popup : Tlayout;
begin

  popup := PasswordDialog.create( self , yes , no , mess , yesText , noText , icon);
  popup.Parent := self;
  popup.Align := TAlignLayout.None;
  popup.Position.Y := ( Self.Height / 2 ) - ( popup.Height / 2 );
  popup.Position.X := - popup.Width;
  popup.Visible := true;

  CurrentPOpup := popup;

  self.BringToFront;

  popup.AnimateFloat( 'position.x' , (Self.Width /2 ) - (popup.width /2 ) , 0.2 );
  backGround.HitTest := true;
  background.Visible := true;
  backGround.AnimateFloat( 'opacity' , 1 , 0.2 )


end;

procedure TNotificationLayout.popupConfirm(Yes, No: TProc; mess: AnsiString;
      YesText: AnsiString = 'Yes'; NoText: AnsiString = 'No';
      icon: integer = 2);
var
  popup : Tlayout;
begin

  popup := YesNoDialog.create( self , yes , no , mess , yesText , noText , icon);
  popup.Parent := self;
  popup.Align := TAlignLayout.None;
  popup.Position.Y := ( Self.Height / 2 ) - ( popup.Height / 2 );
  popup.Position.X := - popup.Width;
  popup.Visible := true;

  CurrentPOpup := popup;

  self.BringToFront;

  popup.AnimateFloat( 'position.x' , (Self.Width /2 ) - (popup.width /2 ) , 0.2 );
  backGround.HitTest := true;
  background.Visible := true;
  backGround.AnimateFloat( 'opacity' , 1 , 0.2 )


end;

procedure TNotificationLayout.popupProtectedConfirm(Yes: TProc; No: TProc; mess: AnsiString;
    YesText: AnsiString = 'Yes'; NoText: AnsiString = 'No'; icon: integer = 2);
var
  popup : Tlayout;
begin

  popup := ProtectedConfirmDialog.create( self , yes , no , mess , yesText , noText , icon);
  popup.Parent := self;
  popup.Align := TAlignLayout.None;
  popup.Position.Y := ( Self.Height / 2 ) - ( popup.Height / 2 );
  popup.Position.X := - popup.Width;
  popup.Visible := true;

  CurrentPOpup := popup;

  self.BringToFront;

  popup.AnimateFloat( 'position.x' , (Self.Width /2 ) - (popup.width /2 ) , 0.2 );
  backGround.HitTest := true;
  background.Visible := true;
  backGround.AnimateFloat( 'opacity' , 1 , 0.2 )

end;

constructor TNotificationLayout.Create(Owner : Tcomponent) ;
var
  locGradient: TGradient;
begin
  inherited Create(owner);
  popupStack := TStack<TLayout>.create();



  Background := TRectangle.Create( Self );
  Background.Visible := false ;
  background.Opacity := 0;
  backGround.Parent := self;
  backGround.Align := TAlignLayout.Contents;
  background.Fill.Color := TAlphaColorF.Create( 0 , 0 , 0 , 0.5 ).ToAlphaColor;
  backGround.OnClick := backGroundClick;
  //background.Fill.Gradient.Style.gsRadial;
  {backGround.Fill.Kind := TBrushKind.Gradient;
  backGround.Fill.Gradient.Style := TGradientStyle.Radial;

  backGround.Fill.Gradient.StartPosition.X := 50;
  backGround.Fill.Gradient.StartPosition.Y := 50;
  backGround.Fill.Gradient.StopPosition.X := 100;
  backGround.Fill.Gradient.StopPosition.Y := 100;

  backGround.Fill.Gradient.Color := TAlphaColorrec.Black;
  backGround.Fill.Gradient.Color1 :=  TAlphaColorF.Create( 0 , 0 , 0 , 0 ).ToAlphaColor; }

  {locGradient := TGradient.Create();
  locGradient.Color := TAlphaColorrec.Black;
  locGradient.Color1 := Talphacolorrec.Alpha;

  locGradient. StartPosition .Y  := 0.5;
  locGradient.StopPosition  .X  := 1;
  locGradient.StopPosition  .Y  := 0.5;


  with Fill do begin
      Kind      := TBrushKind.Gradient;
      Gradient  := locGradient;
    end;  }

end;
destructor TNotificationLayout.destroy;
begin
  inherited;
  popupStack.Free;
end;

procedure ProtectedConfirmDialog._onYesClick(Sender : Tobject);
begin
  if _edit.Text = protectWord then
  begin

   _onYesPress();
    TNotificationLayout( Owner ).ClosePopup;

  end;

end;
procedure ProtectedConfirmDialog._onNoClick(Sender : Tobject);
begin
  _onNoPress();
  TNotificationLayout( Owner ).ClosePopup;
end;

procedure ProtectedConfirmDialog.checkProtect(Sender : TObject );
begin

  if _edit.text = protectWord then
  begin
    _onYesClick(Sender);
  end
  else
  begin
    //popupWindow.Create('wrong word');
  end;

end;

constructor ProtectedConfirmDialog.create( Owner : TComponent ; Yes, No: TProc; mess: AnsiString;
      YesText: AnsiString = 'Yes'; NoText: AnsiString = 'No';
      icon: integer = 2);
var
  panel : TPanel;
begin

  inherited Create( owner );

  _onYesPress := Yes;
  _onNoPress := No;

  //parent := TfmxObject ( owner );
  self.Height := 350;
  self.Width := 350 ;//min( 400 , owner.Width );

  self.protectWord := frmhome.wordlist.Lines[Random(2000)] + ' ' + frmhome.wordlist.Lines[Random(2000)]  ;

  //Align := TAlignLayout.None;
  //position.Y := ( TControl( owner ).Height / 2 ) - ( height / 2);
  //position.X := - Width;

  //AnimateFloat('position.x' , ( TControl( owner ).Width / 2 ) - ( width / 2 ));

  panel := TPanel.Create(self);
  panel.Parent := self;
  panel.Align := TAlignlayout.Contents;
  panel.Visible := true;

  _protectLayout := TLayout.Create(panel);
  _protectLayout.Parent := panel;
  _protectLayout.Align := TAlignLayout.Bottom;
  _protectLayout.Height := 48 * 2 + 24;
  _protectLayout.Visible := true;

  _staticInfoLabel := TLabel.Create(_protectLayout);
  _staticInfoLabel.Parent := _protectLayout;
  _staticInfoLabel.Visible := true;
  _staticInfoLabel.Align := TAlignLayout.Top;
  _staticInfoLabel.Text := 'Rewrite text to confirm';
  _staticInfoLabel.Height := 24;
  _staticInfoLabel.TextAlign := TTextAlign.Center;


  _ProtectWordLabel := TLabel.Create( _protectLayout );
  _ProtectWordLabel.Parent := _protectLayout;
  _ProtectWordLabel.Text := protectWord;
  _ProtectWordLabel.Align := TAlignLayout.Bottom;
  _ProtectWordLabel.Height := 48;
  _ProtectWordLabel.StyledSettings := _ProtectWordLabel.StyledSettings - [TStyledSetting.size] ;
  {adrLabel.StyledSettings := adrLabel.StyledSettings - [TStyledSetting.size];
    adrLabel.TextSettings.Font.size := dashBoardFontSize;}
  _ProtectWordLabel.TextSettings.Font.Size := 24;
  _ProtectWordLabel.TextAlign := TTextAlign.Center;

  _ProtectWordLabel.Visible := true;

  _edit := Tedit.Create( _protectLayout );
  _edit.Parent := _protectLayout;
  _edit.Align := TAlignLayout.MostBottom;
  _edit.Visible := true;
  _edit.Height := 48;
  _edit.TextAlign := TTextAlign.Center;

  _ImageLayout := TLayout.Create(panel);
  _ImageLayout.Visible := true;
  _ImageLayout.Align := TAlignLayout.MostTop;
  _ImageLayout.parent := panel;
  _ImageLayout.Height := 96;

  _Image := TImage.Create(_ImageLayout);
  _Image.Align := TAlignLayout.Center;
  _Image.Width := 64;
  _Image.Height := 64;
  _Image.Visible := true;
  _Image.parent := _ImageLayout;
  case icon of
    0:
      _Image.Bitmap := frmhome.OKImage.Bitmap;
    1:
      _Image.Bitmap := frmhome.InfoImage.Bitmap;
    2:
      _Image.Bitmap := frmhome.warningImage.Bitmap;
    3:
      _Image.Bitmap := frmhome.ErrorImage.Bitmap;
  end;

  _lblMessage := TLabel.Create(panel);
  _lblMessage.Align := TAlignLayout.Client;
  _lblMessage.Visible := true;
  _lblMessage.parent := panel;
  _lblMessage.Text := mess;
  _lblMessage.TextSettings.HorzAlign := TTextAlign.Center;
  _lblMessage.Margins.Left := 10;
  _lblMessage.Margins.Right := 10;

  _ButtonLayout := TLayout.Create(panel);
  _ButtonLayout.Visible := true;
  _ButtonLayout.Align := TAlignLayout.MostBottom;
  _ButtonLayout.parent := panel;
  _ButtonLayout.Height := 48;

  _YesButton := TButton.Create(_ButtonLayout);
  _YesButton.Align := TAlignLayout.Right;
  _YesButton.Width := _ButtonLayout.Width / 2;
  _YesButton.Visible := true;
  _YesButton.parent := _ButtonLayout;
  _YesButton.Text := YesText;
  _YesButton.OnClick := checkProtect;

  _NoButton := TButton.Create(_ButtonLayout);
  _NoButton.Align := TAlignLayout.Left;
  _NoButton.Width := _ButtonLayout.Width / 2;
  _NoButton.Visible := true;
  _NoButton.parent := _ButtonLayout;
  _NoButton.Text := NoText;
  _NoButton.OnClick := _onNoClick;


end;

destructor ProtectedConfirmDialog.Destroy;
begin

  inherited;

end;

////////////////////////////////////
procedure YesNoDialog._onYesClick(Sender : Tobject);
begin

  _onYesPress();
  TNotificationLayout( Owner ).ClosePopup;

end;
procedure YesNoDialog._onNoClick(Sender : Tobject);
begin

  _onNoPress();
  TNotificationLayout( Owner ).ClosePopup;

end;

constructor YesNoDialog.create( Owner : TComponent ; Yes, No: TProc; mess: AnsiString;
      YesText: AnsiString = 'Yes'; NoText: AnsiString = 'No';
      icon: integer = 2);
var
  panel : TPanel;
begin

  inherited Create( owner );

  _onYesPress := Yes;
  _onNoPress := No;

  //parent := TfmxObject ( owner );
  self.Height := 250;
  self.Width := 350 ;//min( 400 , owner.Width );

  //Align := TAlignLayout.None;
  //position.Y := ( TControl( owner ).Height / 2 ) - ( height / 2);
  //position.X := - Width;

  //AnimateFloat('position.x' , ( TControl( owner ).Width / 2 ) - ( width / 2 ));

  panel := TPanel.Create(self);
  panel.Parent := self;
  panel.Align := TAlignlayout.Contents;
  panel.Visible := true;

    _ImageLayout := TLayout.Create(panel);
  _ImageLayout.Visible := true;
  _ImageLayout.Align := TAlignLayout.MostTop;
  _ImageLayout.parent := panel;
  _ImageLayout.Height := 96;

  _Image := TImage.Create(_ImageLayout);
  _Image.Align := TAlignLayout.Center;
  _Image.Width := 64;
  _Image.Height := 64;
  _Image.Visible := true;
  _Image.parent := _ImageLayout;
  case icon of
    0:
      _Image.Bitmap := frmhome.OKImage.Bitmap;
    1:
      _Image.Bitmap := frmhome.InfoImage.Bitmap;
    2:
      _Image.Bitmap := frmhome.warningImage.Bitmap;
    3:
      _Image.Bitmap := frmhome.ErrorImage.Bitmap;
  end;

  _lblMessage := TLabel.Create(panel);
  _lblMessage.Align := TAlignLayout.Client;
  _lblMessage.Visible := true;
  _lblMessage.parent := panel;
  _lblMessage.Text := mess;
  _lblMessage.TextSettings.HorzAlign := TTextAlign.Center;
  _lblMessage.Margins.Left := 10;
  _lblMessage.Margins.Right := 10;

  _ButtonLayout := TLayout.Create(panel);
  _ButtonLayout.Visible := true;
  _ButtonLayout.Align := TAlignLayout.MostBottom;
  _ButtonLayout.parent := panel;
  _ButtonLayout.Height := 48;

  _YesButton := TButton.Create(_ButtonLayout);
  _YesButton.Align := TAlignLayout.Right;
  _YesButton.Width := _ButtonLayout.Width / 2;
  _YesButton.Visible := true;
  _YesButton.parent := _ButtonLayout;
  _YesButton.Text := YesText;
  _YesButton.OnClick := _onyesClick;

  _NoButton := TButton.Create(_ButtonLayout);
  _NoButton.Align := TAlignLayout.Left;
  _NoButton.Width := _ButtonLayout.Width / 2;
  _NoButton.Visible := true;
  _NoButton.parent := _ButtonLayout;
  _NoButton.Text := NoText;
  _NoButton.OnClick := _onNoClick;


end;

destructor YesNoDialog.Destroy;
begin

  inherited;

end;


/////////////////////////////////////////////////////////////////////////////////





procedure PasswordDialog._onYesClick(Sender : Tobject);
begin

   _onYesPress( _edit.text );
    TNotificationLayout( Owner ).ClosePopup;

end;
procedure PasswordDialog._onNoClick(Sender : Tobject);
begin

  _onNoPress( _edit.text );
  TNotificationLayout( Owner ).ClosePopup;

end;


constructor  PasswordDialog.create( Owner : TComponent ; Yes, No: TProc<AnsiString>; mess: AnsiString;
      YesText: AnsiString = 'Yes'; NoText: AnsiString = 'No';
      icon: integer = 2);
var
  panel : TPanel;
begin

  inherited Create( owner );

  _onYesPress := Yes;
  _onNoPress := No;

  //parent := TfmxObject ( owner );
  self.Height := 250;
  self.Width := 350 ;//min( 400 , owner.Width );

  //Align := TAlignLayout.None;
  //position.Y := ( TControl( owner ).Height / 2 ) - ( height / 2);
  //position.X := - Width;

  //AnimateFloat('position.x' , ( TControl( owner ).Width / 2 ) - ( width / 2 ));

  panel := TPanel.Create(self);
  panel.Parent := self;
  panel.Align := TAlignlayout.Contents;
  panel.Visible := true;

  _protectLayout := TLayout.Create(panel);
  _protectLayout.Parent := panel;
  _protectLayout.Align := TAlignLayout.Bottom;
  _protectLayout.Height := 48 ;
  _protectLayout.Visible := true;

 { _staticInfoLabel := TLabel.Create(_protectLayout);
  _staticInfoLabel.Parent := _protectLayout;
  _staticInfoLabel.Visible := true;
  _staticInfoLabel.Align := TAlignLayout.Top;
  _staticInfoLabel.Text := 'Rewrite text to confirm';
  _staticInfoLabel.Height := 24;
  _staticInfoLabel.TextAlign := TTextAlign.Center; }


  _edit := Tedit.Create( _protectLayout );
  _edit.Parent := _protectLayout;
  _edit.Align := TAlignLayout.MostBottom;
  _edit.Visible := true;
  _edit.Height := 48;
  _edit.TextAlign := TTextAlign.Center;
  _edit.Password := true;

  _ImageLayout := TLayout.Create(panel);
  _ImageLayout.Visible := true;
  _ImageLayout.Align := TAlignLayout.MostTop;
  _ImageLayout.parent := panel;
  _ImageLayout.Height := 96;

  _Image := TImage.Create(_ImageLayout);
  _Image.Align := TAlignLayout.Center;
  _Image.Width := 64;
  _Image.Height := 64;
  _Image.Visible := true;
  _Image.parent := _ImageLayout;
  case icon of
    0:
      _Image.Bitmap := frmhome.OKImage.Bitmap;
    1:
      _Image.Bitmap := frmhome.InfoImage.Bitmap;
    2:
      _Image.Bitmap := frmhome.warningImage.Bitmap;
    3:
      _Image.Bitmap := frmhome.ErrorImage.Bitmap;
  end;

  _lblMessage := TLabel.Create(panel);
  _lblMessage.Align := TAlignLayout.Client;
  _lblMessage.Visible := true;
  _lblMessage.parent := panel;
  _lblMessage.Text := mess;
  _lblMessage.TextSettings.HorzAlign := TTextAlign.Center;
  _lblMessage.Margins.Left := 10;
  _lblMessage.Margins.Right := 10;

  _ButtonLayout := TLayout.Create(panel);
  _ButtonLayout.Visible := true;
  _ButtonLayout.Align := TAlignLayout.MostBottom;
  _ButtonLayout.parent := panel;
  _ButtonLayout.Height := 48;

  _YesButton := TButton.Create(_ButtonLayout);
  _YesButton.Align := TAlignLayout.Right;
  _YesButton.Width := _ButtonLayout.Width / 2;
  _YesButton.Visible := true;
  _YesButton.parent := _ButtonLayout;
  _YesButton.Text := YesText;
  _YesButton.OnClick := _onYesClick;

  _NoButton := TButton.Create(_ButtonLayout);
  _NoButton.Align := TAlignLayout.Left;
  _NoButton.Width := _ButtonLayout.Width / 2;
  _NoButton.Visible := true;
  _NoButton.parent := _ButtonLayout;
  _NoButton.Text := NoText;
  _NoButton.OnClick := _onNoClick;


end;

destructor PasswordDialog.Destroy;
begin

  inherited;

end;









end.
