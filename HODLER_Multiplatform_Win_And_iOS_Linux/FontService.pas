unit FontService;

interface

uses
  FMX.Platform,FMX.Graphics;

type
  TmyFMXSystemFontService = class(TInterfacedObject, IFMXSystemFontService)
  public
    function GetDefaultFontFamilyName: string;
    function GetDefaultFontSize: Single;
  end;

implementation  

function TmyFMXSystemFontService.GetDefaultFontFamilyName: string;
begin
  Result := 'Segoe';
end;

function TmyFMXSystemFontService.GetDefaultFontSize: Single;
begin
  Result := 9.999;
end;

procedure InitFont;
begin
  if TPlatformServices.Current.SupportsPlatformService(IFMXSystemFontService) then
    TPlatformServices.Current.RemovePlatformService(IFMXSystemFontService);

  TPlatformServices.Current.AddPlatformService(IFMXSystemFontService, TmyFMXSystemFontService.Create);
end;

initialization

InitFont;

end.