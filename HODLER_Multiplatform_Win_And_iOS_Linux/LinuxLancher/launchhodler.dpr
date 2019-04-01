program launchhodler;

uses
  System.StartUpCopy,
  FMX.Forms,
  uLauncher in 'uLauncher.pas' {frmLauncher};

{$R *.res}

begin
  Application.Initialize;
  Application.CreateForm(TfrmLauncher, frmLauncher);
  Application.Run;
end.
