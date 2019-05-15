unit TCopyableLabelData;

interface

uses
  System.SysUtils, System.Classes, FMX.Types, FMX.Controls, FMX.Layouts,
  FMX.Edit, FMX.StdCtrls, FMX.Clipboard, FMX.Platform, FMX.Objects,
  System.Types, StrUtils, popupwindowData;

type
  TCopyableLabel = class(TLabel)
  private
    { Private declarations }
    procedure copy_Text(Sender: TObject);
  protected
    { Protected declarations }
  public
    { Public declarations }
    button: TButton;
    image: Timage;
    // destructor Destroy; override;

  published
    constructor Create(AOwner: TComponent); override;
    // constructor CreateFrom(edit : Tedit);

  end;

procedure Register;

implementation

uses misc, languages, uhome;

procedure Register;
begin
  RegisterComponents('Samples', [TCopyableLabel]);
end;

procedure TCopyableLabel.copy_Text(Sender: TObject);
var
  svc: IFMXExtendedClipboardService;
begin

  if TPlatformServices.Current.SupportsPlatformService(IFMXClipboardService, svc)
  then
  begin

    svc.setClipboard(TLabel(TfmxObject(Sender).Parent).Text);
    popupWindow.Create(TLabel(TfmxObject(Sender).Parent).Text + ' ' +
      dictionary('CopiedToClipboard'));

  end;
end;

constructor TCopyableLabel.Create(AOwner: TComponent);
var
  Stream: TResourceStream;
begin

  inherited;

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
