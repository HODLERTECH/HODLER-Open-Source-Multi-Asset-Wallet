unit AssetsMenagerData;

interface

uses
  System.SysUtils, System.Classes, FMX.Types, FMX.Controls, FMX.Layouts,
  FMX.Edit, FMX.StdCtrls, FMX.Clipboard, FMX.Platform, FMX.Objects,
  System.Types, StrUtils, FMX.Dialogs, System.Generics.Collections;

{$IF DEFINED(ANDROID) OR DEFINED(IOS) OR DEFINED(LINUX)}

const
  StrStartIteration = {$IFNDEF LINUX} 0 {$ELSE}1{$ENDIF};

type
  AnsiString = string;

type
  WideString = string;

type
  AnsiChar = Char;
{$ELSE}

const
  StrStartIteration = 1;
{$ENDIF}

type
  AssetsMenager = class
  private
    map: TObjectDictionary<AnsiString, TStream>;
    procedure addToMap(name: AnsiString);

  public
    function getAssets(resourceName: AnsiString): TStream;
    procedure addOrSetResource( resName : AnsiString ; stream : TStream);


    constructor create();
    destructor Destroy(); override;

  end;

implementation

procedure AssetsMenager.addOrSetResource( resName : AnsiString ; stream : TStream);
var
  temp : Tpair<AnsiString , TStream>;
begin

  if not map.ContainsKey(resName) then
  begin

    try
      map.Add(resname, Stream);
    except on E: Exception do
    end;

  end
  else
  begin

    temp := map.ExtractPair( resname );

    temp.Value.Free();

    map.Add(resname, Stream);

  end;

end;

procedure AssetsMenager.addToMap(name: AnsiString);
var
  Stream: TStream;
begin

  try
    Stream := TResourceStream.create(HInstance, name, RT_RCDATA);

    map.Add(name, Stream);
  except
    on E: Exception do
  end;


  // stream.Free;  // ?

end;

function AssetsMenager.getAssets(resourceName: AnsiString): TStream;
begin

  if not map.TryGetValue(resourceName, result) then
  begin

    addToMap(resourceName);

    if not map.TryGetValue(resourceName, result) then
    begin

      if not map.TryGetValue('IMG_NOT_FOUND', result) then
      begin
        // showmessage( 'Can not load resource ' + resourceName );
        raise Exception.create('Can not load resource ' + resourceName);

      end;

    end;

  end;

end;

constructor AssetsMenager.create();
begin
  inherited;
  map := TObjectDictionary<AnsiString, TStream>.create([doOwnsValues]);
  addToMap('IMG_NOT_FOUND');
end;

destructor AssetsMenager.Destroy();
begin

  map.Clear;
  map.free;
  inherited;
end;

end.
