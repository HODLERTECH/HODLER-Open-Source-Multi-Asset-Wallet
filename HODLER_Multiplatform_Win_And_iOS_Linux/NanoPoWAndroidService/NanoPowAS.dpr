program NanoPowAS;

uses
  System.Android.ServiceApplication,
  uNanoPowAS in 'uNanoPowAS.pas' {DM: TAndroidService};

{$R *.res}

begin
  Application.Initialize;
  Application.CreateForm(TDM, DM);
  Application.Run;
end.
