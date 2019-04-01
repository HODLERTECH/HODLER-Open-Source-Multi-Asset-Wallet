unit NotificationLayoutData;

interface

uses
  System.SysUtils, System.Classes, FMX.Types, FMX.Controls, FMX.Layouts,
  System.uiTypes,
  FMX.Edit, FMX.StdCtrls, FMX.Clipboard, FMX.Platform, FMX.Objects,
  FMX.graphics,
  System.Types, StrUtils, FMX.Dialogs, crossplatformHeaders,
  System.Generics.Collections, FMX.VirtualKeyboard;

type
  PasswordDialog = class(TLayout)
  public
    // protectWord : AnsiString;

    _protectLayout: TLayout;
    _staticInfoLabel: TLabel;
    _edit: TEdit;
    // _ProtectWordLabel : TLAbel;

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
    procedure OnKeybaordPress(Sender: TObject; var Key: Word; var KeyChar: Char; Shift: TShiftState);
 
    constructor create(Owner: TComponent; Yes, No: TProc<AnsiString>;
      mess: AnsiString; YesText: AnsiString = 'Yes'; NoText: AnsiString = 'No';
      icon: integer = 2);

    destructor destroy(); Override;

  end;

type
  ProtectedConfirmDialog = class(TLayout)
  public
    protectWord: AnsiString;

    _protectLayout: TLayout;
    _staticInfoLabel: TLabel;
    _edit: TEdit;
    _ProtectWordLabel: TLabel;

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
    // procedure _OnExit(sender: TObject);
    procedure checkProtect(sender: TObject);

    procedure OnKeybaordPress(Sender: TObject; var Key: Word; var KeyChar: Char; Shift: TShiftState);


    constructor create( Owner : TComponent ; Yes, No: TProc; mess: AnsiString;
      YesText: AnsiString = 'Yes'; NoText: AnsiString = 'No';
      icon: integer = 2);

    destructor destroy(); Override;

  end;

type
  YesNoDialog = class(TLayout)
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
    // procedure _OnExit(sender: TObject);

  public
    constructor create(Owner: TComponent; Yes, No: TProc; mess: AnsiString;
      YesText: AnsiString = 'Yes'; NoText: AnsiString = 'No';
      icon: integer = 2);

    destructor destroy(); Override;
  end;

type
  TNotificationLayout = class(TLayout)

    popupStack: TStack<TLayout>;
    notificationStack: TStack<TLayout>;

    CurrentPOpup: TLayout;
    PopupQueue: TQueue<TLayout>;

    backGround: TRectangle;

    inThinking: Tpanel;

    constructor create(Owner: TComponent); override;
    destructor destroy(); Override;

    procedure backGroundClick(sender: TObject);

    procedure ClosePopup();

  procedure moveCurrentPopupToTop();
  procedure centerCurrentPopup();

  procedure addPopupToStack( popup :TLayout );
  //procedure layoutClick(Sender : TObject);

    // procedure AddNotification( msg : AnsiString ; time : integer = 15 );

    procedure popupProtectedConfirm(Yes: TProc; No: TProc; mess: AnsiString;
      YesText: AnsiString = 'Yes'; NoText: AnsiString = 'No';
      icon: integer = 2);

    procedure popupPasswordConfirm(Yes: TProc<AnsiString>;
      No: TProc<AnsiString>; mess: AnsiString; YesText: AnsiString = 'OK';
      NoText: AnsiString = 'Cancel'; icon: integer = 2);

    procedure popupConfirm(Yes, No: TProc; mess: AnsiString;
      YesText: AnsiString = 'Yes'; NoText: AnsiString = 'No';
      icon: integer = 2);

    procedure RunInThinkingWindow(proc: TProc);
    procedure ShowThinkingWindow();
    procedure CloseThinkingWindow();

    procedure TryShowBackground();
    procedure TryHideBackGround();

    // procedure popup( msg : AnsiString );
    // procedure popup(

  end;

implementation

uses
  uhome , misc;


procedure TNotificationLayout.TryShowBackground();
begin




  backGround.HitTest := true;
  backGround.Visible := true;
  backGround.AnimateFloat('opacity', 1, 0.2);
end;

procedure TNotificationLayout.TryHideBackGround();
begin
  if inthinking.isVisible then
    exit();
  if CurrentPOpup <> nil then
    exit();


  backGround.AnimateFloat('opacity', 0, 0.2);
  backGround.HitTest := false;
end;

procedure TNotificationLayout.RunInThinkingWindow(proc: TProc);
begin

  tthread.CreateAnonymousThread(
    procedure
    begin

      ShowThinkingWindow();
      tthread.Synchronize( tthread.Current , procedure
      begin
        proc();
      end);


      CloseThinkingWindow();

    end).Start;

end;

procedure TNotificationLayout.ShowThinkingWindow();
begin

  tthread.Synchronize( tthread.current,
    procedure
    begin
      TryShowBackground();
      inThinking.Visible := true;
    end);

end;

procedure TNotificationLayout.CloseThinkingWindow();
begin

  tthread.Synchronize( tthread.current,
    procedure
    begin
      inThinking.Visible := false;
      TryHideBackGround();
    end);
end;
procedure TNotificationLayout.addPopupToStack( popup :TLayout );
begin

  if (popupStack.Count = 0) and (CurrentPOpup = nil) then
  begin

    CurrentPOpup := popup;

    self.BringToFront;

    //popup.AnimateFloat( 'position.x' , (Self.Width /2 ) - (popup.width /2 ) , 0.2 );
    popup.Position.X :=   (Self.Width /2 ) - (popup.width /2 ) ;
    backGround.HitTest := true;
    background.Visible := true;
    //backGround.AnimateFloat( 'opacity' , 1 , 0.2 );
    backGround.Opacity := 1;
    popup.bringTofront();

  end
  else
  begin

    popupStack.Push( popup );
    //popup.Position.X := (Self.Width /2 ) - (popup.width /2 ) ;

  end;

end;

procedure TNotificationLayout.moveCurrentPopupToTop();
begin
  try
  
    if CurrentPOpup <> nil then
      CurrentPOpup.AnimateFloat('position.y', 0, 0.2);
 
  except
    on E: Exception do
    begin
    end;

  end;
end;

procedure TNotificationLayout.centerCurrentPopup();
begin
  try
    if CurrentPOpup <> nil then
      CurrentPOpup.AnimateFloat('position.y', (Self.Height / 2) -
        (CurrentPOpup.Height / 2), 0.2);
  Except
    on E: Exception do
    begin
    end;
  end;
end;

procedure TNotificationLayout.ClosePopup;
var
  KeyboardService: IFMXVirtualKeyboardService;
begin
  try
{$IFDEF ANDROID}
    if TPlatformServices.Current.SupportsPlatformService
      (IFMXVirtualKeyboardService, IInterface(KeyboardService)) then
      if KeyboardService <> nil then
        KeyboardService.HideVirtualKeyboard;
{$ENDIF}

  //Currentpopup.AnimateFloat( 'position.x' ,  self.width + currentpopup.width  , 0.2 );
  CurrentPOpup.Position.X := self.width + currentpopup.width;

  if popupStack.Count <> 0 then
  begin

    currentPopup := popupStack.Pop;
    currentpopup.position.X := (Self.Width /2 ) - (currentpopup.width /2 );

  end
  else
  begin

    //backGround.AnimateFloat( 'opacity' , 0 , 0.2 );
    backGround.Opacity := 0;
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

  end;






except on E:Exception do begin end; end;

end;

procedure TNotificationLayout.backGroundClick(sender: TObject);
begin

  ClosePopup;

end;

procedure TNotificationLayout.popupPasswordConfirm(Yes, No: TProc<String>;
mess: AnsiString; YesText: AnsiString = 'OK'; NoText: AnsiString = 'Cancel';
icon: integer = 2);
var
  popup: TLayout;
begin

  popup := PasswordDialog.create(Self, Yes, No, mess, YesText, NoText, icon);
  popup.Parent := Self;
  popup.Align := TAlignLayout.None;
  popup.Position.Y := (Self.Height / 2) - (popup.Height / 2);
  popup.Position.X := -popup.width;
  popup.Visible := true;

  addPopupToStack( popup );

  {CurrentPOpup := popup;

  Self.BringToFront;

  popup.AnimateFloat('position.x', (Self.width / 2) - (popup.width / 2), 0.2);
  backGround.HitTest := true;

  background.Visible := true;
  backGround.AnimateFloat( 'opacity' , 1 , 0.2 )  }

end;

procedure TNotificationLayout.popupConfirm(Yes, No: TProc; mess: AnsiString;
YesText: AnsiString = 'Yes'; NoText: AnsiString = 'No'; icon: integer = 2);
var
  popup: TLayout;
begin

  popup := YesNoDialog.create(Self, Yes, No, mess, YesText, NoText, icon);
  popup.Parent := Self;
  popup.Align := TAlignLayout.None;
  popup.Position.Y := (Self.Height / 2) - (popup.Height / 2);
  popup.Position.X := -popup.width;
  popup.Visible := true;

  addPopupToStack( popup );

  {CurrentPOpup := popup;

  Self.BringToFront;

  popup.AnimateFloat('position.x', (Self.width / 2) - (popup.width / 2), 0.2);
  backGround.HitTest := true;

  background.Visible := true;
  backGround.AnimateFloat( 'opacity' , 1 , 0.2 )}

end;

procedure TNotificationLayout.popupProtectedConfirm(Yes: TProc; No: TProc;
mess: AnsiString; YesText: AnsiString = 'Yes'; NoText: AnsiString = 'No';
icon: integer = 2);
var
  popup: TLayout;
begin

  popup := ProtectedConfirmDialog.create(Self, Yes, No, mess, YesText,
    NoText, icon);
  popup.Parent := Self;
  popup.Align := TAlignLayout.None;
  popup.Position.Y := (Self.Height / 2) - (popup.Height / 2);
  popup.Position.X := -popup.width;
  popup.Visible := true;

  addPopupToStack( popup );

  {CurrentPOpup := popup;

  Self.BringToFront;

  popup.AnimateFloat('position.x', (Self.width / 2) - (popup.width / 2), 0.2);
  backGround.HitTest := true;
  background.Visible := true;
  backGround.AnimateFloat( 'opacity' , 1 , 0.2 ) }

end;

constructor TNotificationLayout.create(Owner: TComponent);
var
  locGradient: TGradient;
  aniInd: TAniIndicator;
  lbl: TLabel;
begin
  inherited create(Owner);
  popupStack := TStack<TLayout>.create();

  backGround := TRectangle.create(Self);
  backGround.Visible := false;
  backGround.Opacity := 0;
  backGround.Parent := Self;
  backGround.Align := TAlignLayout.Contents;
  backGround.Fill.Color := TAlphaColorF.create(0, 0, 0, 0.5).ToAlphaColor;
  backGround.OnClick := backGroundClick;

  inThinking := Tpanel.create(Self);
  inThinking.Parent := Self;
  inThinking.Visible := false;
  inThinking.Height := 350;
  inThinking.width := 350;
  inThinking.Align := TAlignLayout.Center;

  aniInd := TAniIndicator.create(inThinking);
  aniInd.Parent := inThinking;
  aniInd.Align := TAlignLayout.Top;
  aniInd.Height := 250;
  aniInd.Enabled := true;

  lbl := TLabel.create(inThinking);
  lbl.Parent := inThinking;
  lbl.Text := 'Thinking... Please wait.';
  lbl.Align := TAlignLayout.client;
  lbl.TextSettings.HorzAlign := TTextAlign.Center;

end;

destructor TNotificationLayout.destroy;
begin
  inherited;
  popupStack.Free;
end;

procedure ProtectedConfirmDialog._onYesClick(sender: TObject);
begin
  if _edit.Text = protectWord then
  begin

    _onYesPress();
    TNotificationLayout(Owner).ClosePopup;

  end;

end;

procedure ProtectedConfirmDialog._onNoClick(sender: TObject);
begin
  _onNoPress();
  TNotificationLayout(Owner).ClosePopup;
end;

procedure ProtectedConfirmDialog.checkProtect(sender: TObject);
begin

  if _edit.Text = protectWord then
  begin
    _onYesClick(sender);
  end
  else
  begin
    // popupWindow.Create('wrong word');
  end;

end;

constructor ProtectedConfirmDialog.create(Owner: TComponent; Yes, No: TProc;
mess: AnsiString; YesText: AnsiString = 'Yes'; NoText: AnsiString = 'No';
icon: integer = 2);
var
  panel: Tpanel;
begin

  inherited create(Owner);

  _onYesPress := Yes;
  _onNoPress := No;

  // parent := TfmxObject ( owner );
  Self.Height := 350;
  Self.width := 350; // min( 400 , owner.Width );

  Self.protectWord := frmhome.wordlist.Lines[Random(2000)] + ' ' +
    frmhome.wordlist.Lines[Random(2000)];

  // Align := TAlignLayout.None;
  // position.Y := ( TControl( owner ).Height / 2 ) - ( height / 2);
  // position.X := - Width;

  // AnimateFloat('position.x' , ( TControl( owner ).Width / 2 ) - ( width / 2 ));

  panel := Tpanel.create(Self);
  panel.Parent := Self;
  panel.Align := TAlignLayout.Contents;
  panel.Visible := true;

  _protectLayout := TLayout.create(panel);
  _protectLayout.Parent := panel;
  _protectLayout.Align := TAlignLayout.Bottom;
  _protectLayout.Height := 48 * 2 + 24;
  _protectLayout.Visible := true;

  _staticInfoLabel := TLabel.create(_protectLayout);
  _staticInfoLabel.Parent := _protectLayout;
  _staticInfoLabel.Visible := true;
  _staticInfoLabel.Align := TAlignLayout.Top;
  _staticInfoLabel.Text := 'Rewrite text to confirm';
  _staticInfoLabel.Height := 24;
  _staticInfoLabel.TextAlign := TTextAlign.Center;

  _ProtectWordLabel := TLabel.create(_protectLayout);
  _ProtectWordLabel.Parent := _protectLayout;
  _ProtectWordLabel.Text := protectWord;
  _ProtectWordLabel.Align := TAlignLayout.Bottom;
  _ProtectWordLabel.Height := 48;
  _ProtectWordLabel.StyledSettings := _ProtectWordLabel.StyledSettings -
    [TStyledSetting.size];
  { adrLabel.StyledSettings := adrLabel.StyledSettings - [TStyledSetting.size];
    adrLabel.TextSettings.Font.size := dashBoardFontSize; }
  _ProtectWordLabel.TextSettings.Font.size := 24;
  _ProtectWordLabel.TextAlign := TTextAlign.Center;

  _ProtectWordLabel.Visible := true;

  _edit := TEdit.create(_protectLayout);
  _edit.Parent := _protectLayout;
  _edit.Align := TAlignLayout.MostBottom;
  _edit.Visible := true;
  _edit.Height := 48;
  _edit.TextAlign := TTextAlign.Center;

  _ImageLayout := TLayout.create(panel);
  _ImageLayout.Visible := true;
  _ImageLayout.Align := TAlignLayout.MostTop;
  _ImageLayout.Parent := panel;
  _ImageLayout.Height := 96;

  _Image := TImage.create(_ImageLayout);
  _Image.Align := TAlignLayout.Center;
  _Image.width := 64;
  _Image.Height := 64;
  _Image.Visible := true;
  _Image.Parent := _ImageLayout;
  case icon of
    0:
      _Image.Bitmap.LoadFromStream( resourceMenager.getAssets('OK_IMAGE') ); // := frmhome.OKImage.Bitmap;
    1:
      _Image.Bitmap.LoadFromStream( resourceMenager.getAssets('INFO_IMAGE') ); // := frmhome.InfoImage.Bitmap;
    2:
      _Image.Bitmap.LoadFromStream( resourceMenager.getAssets('WARNING_IMAGE') ); // := frmhome.warningImage.Bitmap;
    3:
      _Image.Bitmap.LoadFromStream( resourceMenager.getAssets('ERROR_IMAGE') ); // := frmhome.ErrorImage.Bitmap;
  end;

  _lblMessage := TLabel.create(panel);
  _lblMessage.Align := TAlignLayout.client;
  _lblMessage.Visible := true;
  _lblMessage.Parent := panel;
  _lblMessage.Text := mess;
  _lblMessage.TextSettings.HorzAlign := TTextAlign.Center;
  _lblMessage.Margins.Left := 10;
  _lblMessage.Margins.Right := 10;

  _ButtonLayout := TLayout.create(panel);
  _ButtonLayout.Visible := true;
  _ButtonLayout.Align := TAlignLayout.MostBottom;
  _ButtonLayout.Parent := panel;
  _ButtonLayout.Height := 48;

  _YesButton := TButton.create(_ButtonLayout);
  _YesButton.Align := TAlignLayout.Right;
  _YesButton.width := _ButtonLayout.width / 2;
  _YesButton.Visible := true;
  _YesButton.Parent := _ButtonLayout;
  _YesButton.Text := YesText;
  _YesButton.OnClick := checkProtect;

  _NoButton := TButton.create(_ButtonLayout);
  _NoButton.Align := TAlignLayout.Left;
  _NoButton.width := _ButtonLayout.width / 2;
  _NoButton.Visible := true;
  _NoButton.Parent := _ButtonLayout;
  _NoButton.Text := NoText;
  _NoButton.OnClick := _onNoClick;

  _edit.OnKeyUp := OnKeybaordPress;


end;

procedure ProtectedConfirmDialog.OnKeybaordPress(Sender: TObject;
  var Key: Word; var KeyChar: Char; Shift: TShiftState);
begin
  if Key = vkReturn then
  begin
    checkProtect(nil);
  end;
  
end;

destructor ProtectedConfirmDialog.destroy;
begin

  inherited;

end;

/// /////////////////////////////////
procedure YesNoDialog._onYesClick(sender: TObject);
begin

  _onYesPress();
  TNotificationLayout(Owner).ClosePopup;

end;

procedure YesNoDialog._onNoClick(sender: TObject);
begin

  _onNoPress();
  TNotificationLayout(Owner).ClosePopup;

end;

constructor YesNoDialog.create(Owner: TComponent; Yes, No: TProc;
mess: AnsiString; YesText: AnsiString = 'Yes'; NoText: AnsiString = 'No';
icon: integer = 2);
var
  panel: Tpanel;
begin

  inherited create(Owner);

  _onYesPress := Yes;
  _onNoPress := No;

  // parent := TfmxObject ( owner );
  Self.Height := 250;
  Self.width := 350; // min( 400 , owner.Width );

  // Align := TAlignLayout.None;
  // position.Y := ( TControl( owner ).Height / 2 ) - ( height / 2);
  // position.X := - Width;

  // AnimateFloat('position.x' , ( TControl( owner ).Width / 2 ) - ( width / 2 ));

  panel := Tpanel.create(Self);
  panel.Parent := Self;
  panel.Align := TAlignLayout.Contents;
  panel.Visible := true;

  _ImageLayout := TLayout.create(panel);
  _ImageLayout.Visible := true;
  _ImageLayout.Align := TAlignLayout.MostTop;
  _ImageLayout.Parent := panel;
  _ImageLayout.Height := 96;

  _Image := TImage.create(_ImageLayout);
  _Image.Align := TAlignLayout.Center;
  _Image.width := 64;
  _Image.Height := 64;
  _Image.Visible := true;
  _Image.Parent := _ImageLayout;
  case icon of
    0:
      _Image.Bitmap.LoadFromStream( resourceMenager.getAssets('OK_IMAGE') ); // := frmhome.OKImage.Bitmap;
    1:
      _Image.Bitmap.LoadFromStream( resourceMenager.getAssets('INFO_IMAGE') ); // := frmhome.InfoImage.Bitmap;
    2:
      _Image.Bitmap.LoadFromStream( resourceMenager.getAssets('WARNING_IMAGE') ); // := frmhome.warningImage.Bitmap;
    3:
      _Image.Bitmap.LoadFromStream( resourceMenager.getAssets('ERROR_IMAGE') ); // := frmhome.ErrorImage.Bitmap;
  end;

  _lblMessage := TLabel.create(panel);
  _lblMessage.Align := TAlignLayout.client;
  _lblMessage.Visible := true;
  _lblMessage.Parent := panel;
  _lblMessage.Text := mess;
  _lblMessage.TextSettings.HorzAlign := TTextAlign.Center;
  _lblMessage.Margins.Left := 10;
  _lblMessage.Margins.Right := 10;

  _ButtonLayout := TLayout.create(panel);
  _ButtonLayout.Visible := true;
  _ButtonLayout.Align := TAlignLayout.MostBottom;
  _ButtonLayout.Parent := panel;
  _ButtonLayout.Height := 48;

  _YesButton := TButton.create(_ButtonLayout);
  _YesButton.Align := TAlignLayout.Right;
  _YesButton.width := _ButtonLayout.width / 2;
  _YesButton.Visible := true;
  _YesButton.Parent := _ButtonLayout;
  _YesButton.Text := YesText;
  _YesButton.OnClick := _onYesClick;

  _NoButton := TButton.create(_ButtonLayout);
  _NoButton.Align := TAlignLayout.Left;
  _NoButton.width := _ButtonLayout.width / 2;
  _NoButton.Visible := true;
  _NoButton.Parent := _ButtonLayout;
  _NoButton.Text := NoText;
  _NoButton.OnClick := _onNoClick;

end;


destructor YesNoDialog.destroy;
begin

  inherited;

end;

/// //////////////////////////////////////////////////////////////////////////////

procedure PasswordDialog._onYesClick(sender: TObject);
begin
  TNotificationLayout(Owner).RunInThinkingWindow(
    procedure
    begin
      _onYesPress(_edit.Text);
    end);

  TNotificationLayout(Owner).ClosePopup;

end;

procedure PasswordDialog._onNoClick(sender: TObject);
begin

  _onNoPress(_edit.Text);
  TNotificationLayout(Owner).ClosePopup;

end;

constructor PasswordDialog.create(Owner: TComponent; Yes, No: TProc<AnsiString>;
mess: AnsiString; YesText: AnsiString = 'Yes'; NoText: AnsiString = 'No';
icon: integer = 2);
var
  panel: Tpanel;
begin

  inherited create(Owner);

  _onYesPress := Yes;
  _onNoPress := No;

  // parent := TfmxObject ( owner );
  Self.Height := 250;
  Self.width := 350; // min( 400 , owner.Width );

  // Align := TAlignLayout.None;
  // position.Y := ( TControl( owner ).Height / 2 ) - ( height / 2);
  // position.X := - Width;

  // AnimateFloat('position.x' , ( TControl( owner ).Width / 2 ) - ( width / 2 ));

  panel := Tpanel.create(Self);
  panel.Parent := Self;
  panel.Align := TAlignLayout.Contents;
  panel.Visible := true;

  _protectLayout := TLayout.create(panel);
  _protectLayout.Parent := panel;
  _protectLayout.Align := TAlignLayout.Bottom;
  _protectLayout.Height := 48;
  _protectLayout.Visible := true;

  { _staticInfoLabel := TLabel.Create(_protectLayout);
    _staticInfoLabel.Parent := _protectLayout;
    _staticInfoLabel.Visible := true;
    _staticInfoLabel.Align := TAlignLayout.Top;
    _staticInfoLabel.Text := 'Rewrite text to confirm';
    _staticInfoLabel.Height := 24;
    _staticInfoLabel.TextAlign := TTextAlign.Center; }

  _edit := TEdit.create(_protectLayout);
  _edit.Parent := _protectLayout;
  _edit.Align := TAlignLayout.MostBottom;
  _edit.Visible := true;
  _edit.Height := 48;
  _edit.TextAlign := TTextAlign.Center;
  _edit.Password := true;

  _ImageLayout := TLayout.create(panel);
  _ImageLayout.Visible := true;
  _ImageLayout.Align := TAlignLayout.MostTop;
  _ImageLayout.Parent := panel;
  _ImageLayout.Height := 96;

  _Image := TImage.create(_ImageLayout);
  _Image.Align := TAlignLayout.Center;
  _Image.width := 64;
  _Image.Height := 64;
  _Image.Visible := true;
  _Image.Parent := _ImageLayout;
  case icon of
    0:
      _Image.Bitmap.LoadFromStream( resourceMenager.getAssets('OK_IMAGE') ); // := frmhome.OKImage.Bitmap;
    1:
      _Image.Bitmap.LoadFromStream( resourceMenager.getAssets('INFO_IMAGE') ); // := frmhome.InfoImage.Bitmap;
    2:
      _Image.Bitmap.LoadFromStream( resourceMenager.getAssets('WARNING_IMAGE') ); // := frmhome.warningImage.Bitmap;
    3:
      _Image.Bitmap.LoadFromStream( resourceMenager.getAssets('ERROR_IMAGE') ); // := frmhome.ErrorImage.Bitmap;
  end;

  _lblMessage := TLabel.create(panel);
  _lblMessage.Align := TAlignLayout.client;
  _lblMessage.Visible := true;
  _lblMessage.Parent := panel;
  _lblMessage.Text := mess;
  _lblMessage.TextSettings.HorzAlign := TTextAlign.Center;
  _lblMessage.Margins.Left := 10;
  _lblMessage.Margins.Right := 10;

  _ButtonLayout := TLayout.create(panel);
  _ButtonLayout.Visible := true;
  _ButtonLayout.Align := TAlignLayout.MostBottom;
  _ButtonLayout.Parent := panel;
  _ButtonLayout.Height := 48;

  _YesButton := TButton.create(_ButtonLayout);
  _YesButton.Align := TAlignLayout.Right;
  _YesButton.width := _ButtonLayout.width / 2;
  _YesButton.Visible := true;
  _YesButton.Parent := _ButtonLayout;
  _YesButton.Text := YesText;
  _YesButton.OnClick := _onYesClick;

  _NoButton := TButton.create(_ButtonLayout);
  _NoButton.Align := TAlignLayout.Left;
  _NoButton.width := _ButtonLayout.width / 2;
  _NoButton.Visible := true;
  _NoButton.Parent := _ButtonLayout;
  _NoButton.Text := NoText;
  _NoButton.OnClick := _onNoClick;

  _edit.OnKeyUp := OnkeyBaordPress;

end;

procedure PasswordDialog.OnKeybaordPress(Sender: TObject;
  var Key: Word; var KeyChar: Char; Shift: TShiftState);
begin
  if Key = vkReturn then
  begin
    _onyesClick(nil);
  end;

end;

destructor PasswordDialog.destroy;
begin

  inherited;

end;

end.

