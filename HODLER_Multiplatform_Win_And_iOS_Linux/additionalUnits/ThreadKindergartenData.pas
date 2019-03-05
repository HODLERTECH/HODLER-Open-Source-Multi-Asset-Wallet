unit ThreadKindergartenData;

interface

uses System.SysUtils, System.Classes, CrossPlatformHeaders, fmx.Forms,
  System.Generics.Collections, System.Diagnostics, System.SyncObjs ,FMX.Dialogs;

type
  ThreadKindergarten = class

  type
    TCareThread = class(TThread)
    private
      FProc: TProc;
      index: Integer;
      owner : ThreadKindergarten;
    protected

    public
      procedure Execute; override;
      constructor Create(const AProc: TProc; id: Integer ; Aowner : ThreadKindergarten);
    end;

  private
    map: TDictionary<Integer, TCareThread>;
    index: Integer;
    Addmutex , removeMutex: TSemaphore;

  public
    constructor Create();
    destructor Destroy(); override;

    function CreateAnonymousThread(proc: TProc): TThread;
    procedure removeThread(id: Integer);
    procedure terminateThread(id: Integer);

  end;

implementation

{ ThreadKindergarten }

uses SyncThr;

procedure ThreadKindergarten.removeThread(id: Integer);
var
  temp : TCareThread;
begin
  removeMutex.Acquire;
  try

    if map.TryGetValue( id , temp ) then
    begin


      map.Remove( id );

    end;

  finally
    removeMutex.Release;
  end;
end;

procedure ThreadKindergarten.terminateThread(id: Integer);
var
  temp : TCareThread;
begin

  if map.TryGetValue( id , temp ) then
  begin


    try

      while not temp.Started do
      begin
        Application.ProcessMessages;
        sleep(10);

      end;

      temp.Terminate;
    except on E: Exception do
    end;

  end;

end;

function ThreadKindergarten.CreateAnonymousThread(proc: TProc): TThread;
var
  temp: TCareThread;
begin
  addmutex.Acquire;
  try

    temp := TCareThread.create(proc, index , self);
    //temp.Start;
    map.Add(index, temp );

    index := index + 1;

    result := temp;

  finally
    Addmutex.Release;
  end;
end;

constructor ThreadKindergarten.Create();
begin
  inherited;
  map := TDictionary<Integer, TCareThread>.Create();
  Addmutex := TSemaphore.Create();
  removeMutex := TSemaphore.create();
  index := 0;
end;

destructor ThreadKindergarten.Destroy();
var
  it : TDictionary< integer , TCareThread >.TPairEnumerator;
  i: integer;
begin

  it := map.GetEnumerator;
  for i := 0 to Length(map.ToArray)-1 do
    map.ToArray[i].Value.Terminate;
{  while it.MoveNext do
  begin

    terminateThread( it.Current.Key );

  end; }
  while map.Count <> 0 do
  begin
  try
    Application.ProcessMessages;
except on e:Exception do begin end;

  end;
    Sleep(100);

  end;

  it.free;
  map.Free;
  Addmutex.Free;
  removeMutex.Free();


  semaphore.Free;
  semaphore := nil;

  inherited;

end;

procedure ThreadKindergarten.TCareThread.Execute;
begin

  FProc();
  owner.removeThread( index );

end;

constructor ThreadKindergarten.TCareThread.Create(const AProc: TProc; id: Integer ; Aowner : ThreadKindergarten);
begin

  inherited create(true);
  owner := Aowner;
  FreeOnTerminate := true;
  FProc := AProc;
  index := id;

end;

end.
