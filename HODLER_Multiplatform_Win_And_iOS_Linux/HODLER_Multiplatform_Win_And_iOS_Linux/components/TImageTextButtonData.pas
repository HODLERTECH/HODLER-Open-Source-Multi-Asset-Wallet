unit TImageTextButtonData;

interface

uses
  System.SysUtils, System.Classes, FMX.Types, FMX.Controls, FMX.Layouts,
  FMX.Edit, FMX.StdCtrls, FMX.Clipboard, FMX.Platform, FMX.Objects,
  System.Types, StrUtils, FMX.Dialogs, misc;

type
  TImageTextButton = class(TButton)
  private
    { Private declarations }
    procedure _onClick(Sender: TObject);
  protected
    { Protected declarations }
  public
    img: TImage;
    lbl: Tlabel;

    constructor Create(AOwner: TComponent); override;
    procedure LoadImage(ResourceName: AnsiString);
  published
    { Published declarations }
  end;

procedure Register;

implementation

procedure Register;
begin
  RegisterComponents('Samples', [TImageTextButton]);
end;

{ TImageTextButtonData }

procedure TImageTextButton._onClick(Sender: TObject);
begin
  OnClick(Sender);
end;

procedure TImageTextButton.LoadImage(ResourceName: AnsiString);
var
  stream: TResourceStream;
begin
  stream := TResourceStream.Create(HInstance, ResourceName, RT_RCDATA);
  try
    img.Bitmap.LoadFromStream(stream);
  finally
    stream.Free;
  end;
end;

constructor TImageTextButton.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);

  img := TImage.Create(self);
  img.Parent := self;
  img.Visible := true;
  img.Align := TAlignLayout.Left;
  img.Width := 64;
  img.HitTest := false;
  img.OnClick := _onClick;

  lbl := Tlabel.Create(self);
  lbl.Parent := self;
  lbl.Visible := true;
  lbl.Align := TAlignLayout.Client;
  lbl.HitTest := true;
  lbl.OnClick := _onClick;

end;

end.
