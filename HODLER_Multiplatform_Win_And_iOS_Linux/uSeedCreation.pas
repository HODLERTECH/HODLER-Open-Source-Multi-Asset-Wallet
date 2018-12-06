unit uSeedCreation;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs,FMX.Styles,
  FMX.StdCtrls, FMX.Controls.Presentation;

type
  TfrmSeedCreation = class(TForm)
    Header: TToolBar;
    Label1: TLabel;
    procedure FormCreate(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  frmSeedCreation: TfrmSeedCreation;

implementation

{$R *.fmx}

procedure TfrmSeedCreation.FormCreate(Sender: TObject);
begin
//TStyleManager.TrySetStyleFromResource('RT_DARK');
end;

end.
