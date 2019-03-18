unit ComponentPoolData;

interface

uses System.SysUtils, System.Classes, CrossPlatformHeaders, fmx.Forms,
  System.Generics.Collections, System.Diagnostics, System.SyncObjs, FMX.Types;


type
  TcomponentPool<ComponentType : TFmxObject> = class
    private
      container : TStack<ComponentType>;
      genSize : Integer;
      generateThread : Tthread;
      mutex : TSemaphore;

      procedure generatePool( size : integer );
      function createComponent() : ComponentType;

    public
      constructor Create( generateSize : Integer = 10 );
      destructor destroy(); override;

      function getComponent(): ComponentType;

      procedure returnComponent( t : ComponentType );


  end;

implementation

constructor TComponentPool<ComponentType>.create( generateSize : Integer = 10 );
begin
  inherited Create();

  container := TStack<ComponentType>.create();
  gensize := generateSize;

  generatePool( genSize );
  mutex := TSemaphore.Create();

end;

destructor TComponentPool<ComponentType>.destroy();
var
  it : TStack<ComponentType>.TEnumerator;
begin



  if generateThread <> nil then
  begin
    generateThread.Terminate;
    generateThread.WaitFor;
    generateThread.Free;
  end;


  it := container.GetEnumerator;

  while( it.MoveNext )do
  begin

    it.Current.free;

  end;

  it.Free;


  container.Free;
  mutex.Free;

  inherited;
end;

function TComponentPool<ComponentType>.createComponent() : ComponentType;
begin

  result := ComponentType.create( nil );

end;

procedure TComponentPool<ComponentType>.generatePool( size : integer );
begin

  if generateThread <> nil then
  begin
    generateThread.Terminate;
    generateThread.WaitFor;
    generateThread.Free;
  end;

  generateThread := TThread.CreateAnonymousThread( procedure
  begin

    while( container.Count < genSize ) do
    begin
      returnComponent( createComponent );
    end;

  end);

  generateThread.FreeOnTerminate := false;
  generateThread.Start;

end;

procedure TComponentPool<ComponentType>.returnComponent( t : ComponentType );
begin
  if t.owner <> nil then
    raise Exception.Create('Component can not have owner');

  t.parent := nil;

  mutex.Acquire;

  container.Push( t );

  mutex.Release;


end;

function TComponentPool<ComponentType>.getComponent(): ComponentType;
begin
  mutex.Acquire;

  if container.Count > 0 then
  begin

    result := container.Pop;

  end
  else
  begin

    result := createComponent();

  end;

  mutex.Release;


end;

end.
