unit TCopyableAddressLabelData;

interface

uses
  System.SysUtils, System.Classes, FMX.Types, FMX.Controls, FMX.Layouts,
  FMX.Edit, FMX.StdCtrls, FMX.Clipboard, FMX.Platform, FMX.Objects,
  System.Types, StrUtils, popupwindowData , TaddressLabelData ,CrossPlatformHeaders ;

type
  TCopyableAddressLabel = class(TLayout)
  private
    { Private declarations }
    procedure copy_Text(Sender: TObject);

    procedure setText( val : AnsiString ); overload;
    procedure setText( val : AnsiString ; prefixLength : Integer ); overload ;
    function getText() : AnsiString;
  protected
    { Protected declarations }
  public
    { Public declarations }
    addrlbl : TAddressLabel;
    button: TButton;
    image: Timage;
    // destructor Destroy; override;


    property Text: AnsiString read getText write setText;

  published
    constructor Create(AOwner: TComponent); override;
    // constructor CreateFrom(edit : Tedit);

  end;

procedure Register;

implementation

uses misc, languages, uhome;

procedure Register;
begin
  RegisterComponents('Samples', [TCopyableAddressLabel]);
end;
procedure TCopyableAddressLabel.setText( val : AnsiString ; prefixLength : Integer );
begin

  addrlbl.SetText( val , prefixLength );

end;
procedure TCopyableAddressLabel.setText( val : AnsiString );
begin

  addrlbl.SetText( val );

end;
function TCopyableAddressLabel.getText() : AnsiString;
begin

  result := addrlbl.Text;

end;
procedure TCopyableAddressLabel.copy_Text(Sender: TObject);
var
  svc: IFMXExtendedClipboardService;
begin

  if TPlatformServices.Current.SupportsPlatformService(IFMXClipboardService, svc)
  then
  begin

    svc.setClipboard( getText() );
    popupWindow.Create( getText() + ' ' +
      dictionary('CopiedToClipboard'));

  end;
end;

constructor TCopyableAddressLabel.Create(AOwner: TComponent);
var
  Stream: TResourceStream;
begin

  inherited;


      addrLbl := TAddressLabel.Create(self);
      addrLbl.parent := self;
      addrlbl.Align := TAlignLayout.client;
      addrLbl.Visible := true;
      addrLbl.TextSettings.HorzAlign := TTextAlign.Leading;




  image := Timage.Create(self);
  Stream := TResourceStream.Create(HInstance,
    'COPY_IMG_' + RightStr(CurrentStyle, length(CurrentStyle) - 3), RT_RCDATA);
  try
    image.Bitmap.LoadFromStream(Stream);
  finally
    Stream.Free;
  end;

  image.Parent := self;
  image.Align := TAlignLayout.right;
  image.Width := 24;
  image.Margins.Top := 5;
  image.Margins.Bottom := 5;
  image.Margins.Left := 5;
  image.Margins.right := 5;
  image.Visible := true;
  image.TagString := 'copy_image';
  image.OnClick := copy_Text;

end;
end.
