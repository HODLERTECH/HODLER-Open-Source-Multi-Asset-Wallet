unit PopupWindowData;

interface
uses
  System.SysUtils, System.Classes, FMX.Types, FMX.Controls, FMX.Layouts,
  FMX.Edit, FMX.StdCtrls, FMX.Clipboard, FMX.Platform, FMX.Objects,
  System.Types, StrUtils, CrossPlatformHeaders ,fmx.dialogs , math;

{type
  A = class
  i : integer;
  constructor create();
  end;

type
  B = class(A)
  constructor create();
  end; }

type
  popupWindow = class(TPopup)
  public

    messageLabel: TLabel;

    procedure _onEnd(sender: TObject);

    constructor Create(mess: AnsiString);

  end;

type
  popupWindowOK = class(TPopup)
  private

    _ImageLayout: TLayout;
    _Image: TImage;

    _OKbutton: TButton;
    _lblMessage: TLabel;

    _onOKButtonPress: TProc;

    procedure _OKButtonpress(sender: TObject);
    procedure _onEnd(sender: TObject);

  public
    constructor Create(OK: TProc; mess: AnsiString;
      ButtonText: AnsiString = 'OK'; icon: integer = 1);

  end;

{type
  popupWindowYesNo = class(TPopup)
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
    procedure _OnExit(sender: TObject);

  public
    constructor Create(Yes, No: TProc; mess: AnsiString;
      YesText: AnsiString = 'Yes'; NoText: AnsiString = 'No';
      icon: integer = 2);
  end;  }

{type
  PopupWindowProtectYesNo = class(popupWindowYesNo)
  private
    _edit : Tedit;
    protectWord : AnsiString;

    procedure checkProtect( Sender : TObject );
  public

    constructor Create(Yes, No: TProc; mess: AnsiString;
      YesText: AnsiString = 'Yes'; NoText: AnsiString = 'No';
      icon: integer = 2);



  end; }

implementation
uses Uhome;

{constructor PopupWindowProtectYesNo.Create(Yes: TProc; No: TProc; mess: AnsiString; YesText: AnsiString = 'Yes'; NoText: AnsiString = 'No'; icon: Integer = 2);

var
  panel : TPanel;

begin

  inherited Create( yes , no , mess , yesText , noText , icon );

  panel := _imageLayout.Parent as Tpanel;

  _edit := Tedit.Create( Panel );
  _edit.Parent := Panel;
  _edit.Align := TAlignLayout.Bottom;
  _edit.Height := 48;
  _edit.Visible := true;
  _edit.DisableFocusEffect := false;


  protectWord := 'dupa';

  _YesButton.OnClick := checkProtect;
  //PopupModal := TModalResult;
  //popup();

end;

procedure PopupWindowProtectYesNo.checkProtect(Sender : TObject );
begin

  if _edit.text = protectWord then
  begin
    _onYesClick(Sender);
  end
  else
  begin
    popupWindow.Create('wrong word');
  end;

end;

       }




{constructor popupWindowYesNo.Create(Yes: TProc; No: TProc; mess: AnsiString;

YesText: AnsiString = 'Yes'; NoText: AnsiString = 'No'; icon: integer = 2);
var
  panel, Panel2: TPanel;
  rect: TRectangle;
  i: integer;
begin
  inherited Create(frmhome);

  _onYesPress := Yes;
  _onNoPress := No;

  parent := frmhome;
  Height := 250;
  Width := min( 400 , frmhome.Width );

  //PlacementRectangle := TBounds.Create(RectF(0, 0, 0, 0));
  PlacementRectangle := TBounds.Create( frmhome.Bounds );
  //PlacementTarget := frmhome.StatusBarFixer;
  Placement := TPlacement.center;

  //VerticalOffset := ( frmhome.Height / 2 ) - ( height / 2) - 10 + Height;
  //HorizontalOffset := 0 ;

  //AnimateFloat('VerticalOffset',  ( frmhome.Height / 2 ) - ( height / 2) - 10 , 10 );
  //position.X := 0;
  //position.Y := 0;

  Visible := true;





  panel := TPanel.Create(self);
  panel.Align := TAlignLayout.Client;
  panel.Height := 48;
  panel.Visible := true;
  panel.tag := i;
  panel.parent := self;

  rect := TRectangle.Create(panel);
  rect.parent := panel;
  rect.Align := TAlignLayout.Contents;
  rect.Fill.Color := frmhome.StatusBarFixer.Fill.Color;

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

  Popup();

  OnClosePopup := _OnExit;

end;

procedure popupWindowYesNo._OnExit(sender: TObject);
begin

  parent := nil;
  Tthread.CreateAnonymousThread(
    procedure
    begin
      Tthread.Synchronize(nil,
        procedure
        begin
          DisposeOf();
        end);
    end).start;

end;

procedure popupWindowYesNo._onYesClick;
begin
  IsOpen := false;
  _onYesPress();

  ClosePopup();
  // Release;

end;

procedure popupWindowYesNo._onNoClick;
begin
  IsOpen := false;

  _onNoPress();

  ClosePopup();
  // Release;


end;  }

constructor popupWindowOK.Create(OK: TProc; mess: AnsiString;
ButtonText: AnsiString = 'OK'; icon: integer = 1);
var
  panel, Panel2: TPanel;
  i: integer;
  rect: TRectangle;
begin
  inherited Create(frmhome.pageControl);
  parent := frmhome.pageControl;
  Height := 200;
  Width := 300;
  Placement := TPlacement.Center;

  Visible := true;
  PlacementRectangle := TBounds.Create(RectF(0, 0, 0, 0));

  panel := TPanel.Create(self);
  panel.Align := TAlignLayout.Client;
  panel.Height := 48;
  panel.Visible := true;
  panel.tag := i;
  panel.parent := self;

  rect := TRectangle.Create(panel);
  rect.parent := panel;
  rect.Align := TAlignLayout.Contents;
  rect.Fill.Color := frmhome.StatusBarFixer.Fill.Color;

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

  _OKbutton := TButton.Create(panel);
  _OKbutton.Align := TAlignLayout.Bottom;
  _OKbutton.Height := 48;
  _OKbutton.Visible := true;
  _OKbutton.parent := panel;
  _OKbutton.OnClick := _OKButtonpress;
  _OKbutton.Text := ButtonText;

  _onOKButtonPress := OK;

  self.OnClosePopup := _onEnd;

  Popup();
end;

procedure popupWindowOK._OKButtonpress(sender: TObject);
begin
  IsOpen := false;
  _onOKButtonPress();

  ClosePopup();

end;

procedure popupWindowOK._onEnd(sender: TObject);
begin

  parent := nil;
  Tthread.CreateAnonymousThread(
    procedure
    begin
      Tthread.Synchronize(nil,
        procedure
        begin
          DisposeOf();
        end);
    end).start;
end;

constructor popupWindow.Create(mess: AnsiString);
var
  panel, Panel2: TPanel;
  i: integer;
  rect: TRectangle;
begin

  inherited Create(frmhome.PageControl);
  Placement := TPlacement.center;
  parent := frmhome.pagecontrol;
  Height := 100;
  Width := 300;
  PlacementTarget := frmhome.pageControl;

  Visible := true;
  //PlacementRectangle := TBounds.Create(RectF(0, 0, 0, 0));

  panel := TPanel.Create(self);
  panel.Align := TAlignLayout.Client;
  panel.Visible := true;
  panel.tag := i;
  panel.parent := self;

  rect := TRectangle.Create(panel);
  rect.parent := panel;
  rect.Align := TAlignLayout.Contents;
  rect.Fill.Color := frmhome.StatusBarFixer.Fill.Color;

  messageLabel := TLabel.Create(panel);
  messageLabel.Align := TAlignLayout.Client;
  messageLabel.Visible := true;
  messageLabel.parent := panel;
  messageLabel.Text := mess;
  messageLabel.TextSettings.HorzAlign := TTextAlign.Center;

  self.OnClosePopup := _onEnd;
  //Placement := TPlacement.Center;
  Popup();
end;

procedure popupWindow._onEnd(sender: TObject);
begin

  IsOpen := false;

  parent := nil;
  Tthread.CreateAnonymousThread(
    procedure
    begin
      Tthread.Synchronize(nil,
        procedure
        begin
          DisposeOf();
        end);
    end).start;

end;

end.
