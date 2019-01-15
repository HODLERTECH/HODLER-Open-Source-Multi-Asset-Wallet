unit AssetsMenagerData;

interface
uses
 System.SysUtils, System.Classes, FMX.Types, FMX.Controls, FMX.Layouts,
  FMX.Edit, FMX.StdCtrls, FMX.Clipboard, FMX.Platform, FMX.Objects,
  System.Types, StrUtils , FMX.Dialogs , System.Generics.Collections;

type
  AssetsMenager = class
    private
    map : TObjectDictionary< AnsiString , TResourceStream >;
    procedure addToMap( name : AnsiString );

    public
    function getAssets( resourceName : AnsiString ): TResourceStream ;

    constructor create();
    destructor free();

  end;

implementation

procedure AssetsMenager.addToMap( name : AnsiString );
var
  Stream : TresourceStream;
begin

  try
    Stream := TResourceStream.Create(HInstance, name, RT_RCDATA);

    map.Add( name , Stream );
  except on E: Exception do
  end;
  

  //stream.Free;  // ?

end;

function AssetsMenager.getAssets( resourceName : AnsiString ): TResourceStream ;
begin

  if not map.TryGetValue( resourceName , result ) then
  begin

    addToMap( resourcename );

    if not map.TryGetValue( resourceName , result ) then
    begin

      if not map.TryGetValue( 'IMG_NOT_FOUND' , result ) then
      begin
        // showmessage( 'Can not load resource ' + resourceName );
        raise Exception.Create('Can not load resource ' + resourceName );

      end;

    end;

  end;

end;

constructor AssetsMenager.create();
begin
  map := TObjectDictionary< AnsiString , TResourceStream >.create();
  addToMap('IMG_NOT_FOUND');
end;

destructor AssetsMenager.free();
begin

  map.Clear;
  map.Free;
end;

end.
