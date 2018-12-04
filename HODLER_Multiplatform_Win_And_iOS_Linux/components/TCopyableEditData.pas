unit TCopyableEditData;

interface

uses
  System.SysUtils, System.Classes, FMX.Types, FMX.Controls, FMX.Layouts , FMX.Edit , FMX.StdCtrls, FMX.Clipboard,  FMX.Platform , FMX.Objects
  , System.Types , StrUtils;

type
  TCopyableEdit = class(TEdit)
  private
    { Private declarations }
    procedure copy(Sender : TObject);
  protected
    { Protected declarations }
  public
    { Public declarations }
    button : TButton;
    image : Timage;
    //destructor Destroy; override;




  published
    constructor Create(AOwner: TComponent); override;
    //constructor CreateFrom(edit : Tedit);

  end;

Function CreateButtonWithCopyImg(AOwner : TComponent):Tbutton;

procedure Register;

implementation

uses misc , languages , uhome ;

//destructor TCopyableEdit.Destroy;
//begin

  //button.DisposeOf;
  //button := nil;

//end;

Function CreateButtonWithCopyImg(AOwner : TComponent):Tbutton;
var
  button : TButton;
  image : Timage;
var
  Stream: TResourceStream;
begin
  button := TButton.Create( AOwner );
  button.Parent := TfmxObject(AOwner);
  button.Visible := true;
  //Button.Text := 'CP'; // change to Image
  Button.Align := TAlignLayout.MostRight;
  Button.Width := 32;
  Button.OnClick := frmhome.CopyParentTextToClipboard;

  image := TImage.Create(button);
  Stream := TResourceStream.Create(HInstance, 'COPY_IMG_' + RightStr( CurrentStyle , length(CurrentStyle)-3 ), RT_RCDATA);
  try
    image.Bitmap.LoadFromStream(Stream);
  finally
    Stream.Free;
  end;

  image.Parent := button;
  image.Align := TAlignLayout.Client;
  image.Margins.Top := 5;
  image.Margins.Bottom := 5;
  image.Margins.Left := 5;
  image.Margins.Right := 5;
  image.Visible := true;
  image.TagString := 'copy_image';
  image.OnClick := frmhome.CopyParentTextToClipboard;

  exit(button);
end;

procedure Register;
begin
  RegisterComponents('Samples', [TCopyableEdit]);
end;
procedure TCopyableEdit.copy(Sender : TObject);
var
  svc: IFMXExtendedClipboardService;
begin

  if TPlatformServices.Current.SupportsPlatformService(IFMXClipboardService, svc)
  then
  begin

      svc.setClipboard( Tedit(TfmxObject(Sender).Parent).Text );
      popupWindow.Create( Tedit(TfmxObject(Sender).Parent).Text +
        ' ' + dictionary('CopiedToClipboard'));

  end;

end;

constructor TCopyableEdit.Create(AOwner: TComponent);

begin
  Inherited create(AOwner);

  button := CreateButtonWithCopyImg(self);


end;
{constructor TCopyableEdit.CreateFrom(edit : Tedit);
begin
  inherited;
  //self.Assign(  TCopyAbleEdit( edit )  );
  edit.DisposeOf;
  button := TButton.Create( self );
  button.Parent := self;
  button.Visible := true;
  Button.Text := 'CP'; // change to Image
  Button.Align := TAlignLayout.MostRight;
  Button.Width := 32;
  Button.OnClick := copy;
  self.Padding.Right := -Button.Width;
end;}

end.
