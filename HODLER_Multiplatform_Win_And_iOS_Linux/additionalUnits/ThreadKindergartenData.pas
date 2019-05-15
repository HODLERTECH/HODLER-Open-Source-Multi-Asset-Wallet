unit ThreadKindergartenData;

interface

uses System.SysUtils, System.Classes, CrossPlatformHeaders, fmx.Forms,
  System.Generics.Collections, System.Diagnostics, System.SyncObjs, fmx.Dialogs{$IFDEF LINUX},Posix.Pthread,Posix.Signal{$ENDIF};

type
  ThreadKindergarten = class

  type
    TCareThread = class(TThread)
    private
      FProc: TProc;
      index: Integer;
      owner: ThreadKindergarten;
    protected

    public
      procedure Execute; override;
      constructor Create(const AProc: TProc; id: Integer;
        Aowner: ThreadKindergarten);
    end;

  private
    map: TDictionary<Integer, TCareThread>;
    index: Integer;
    Addmutex, removeMutex: TSemaphore;

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
  temp: TCareThread;
begin
  removeMutex.Acquire;
  try

    if map.TryGetValue(id, temp) then
    begin

      map.Remove(id);

    end;

  finally
    removeMutex.Release;
  end;
end;

procedure ThreadKindergarten.terminateThread(id: Integer);
var
  temp: TCareThread;
begin

  if map.TryGetValue(id, temp) then
  begin

    try

      while not temp.Started do
      begin
        Application.ProcessMessages;
        sleep(10);

      end;

      temp.Terminate;
    except
      on E: Exception do
    end;

  end;

end;

function ThreadKindergarten.CreateAnonymousThread(proc: TProc): TThread;
var
  temp: TCareThread;
begin
  Addmutex.Acquire;
  try

    temp := TCareThread.Create(proc, index, self);
    // temp.Start;
    //temp.FreeOnTerminate:=true;
    map.Add(index, temp);

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
  removeMutex := TSemaphore.Create();
  index := 0;
end;

destructor ThreadKindergarten.Destroy();
var
  it: TDictionary<Integer, TCareThread>.TPairEnumerator;
  i: Integer;
begin

  // it := map.GetEnumerator;

  for i := Length(map.ToArray) - 1 downto 0 do
  begin
    try
      if map.ToArray[i].Value <> nil then
      begin
       // map.ToArray[i].Value.FreeOnTerminate := true;
        map.ToArray[i].Value.Terminate;
        //pthread_kill(map.ToArray[i].Value.ThreadID,9);
      end;
      //map.ToArray[High(map.ToArray)]:=map.ToArray[i];

     // map.Remove(i);
      except
      on E: Exception do
      begin
       map.Remove(map.ToArray[i].Key);
      end;

    end;
  end;

  { while it.MoveNext do
    begin

    terminateThread( it.Current.Key );

    end; }
//{$IF/NDEF LINUX}
  while map.Count <> 0 do
  begin
    try
      Application.ProcessMessages;
    except
      on E: Exception do
      begin
      end;

    end;
      for i := Length(map.ToArray) - 1 downto 0 do
  begin
if  map.ToArray[i].Value<>nil then
    if map.ToArray[i].Value.Finished=true then
      map.Remove(map.ToArray[i].Key);
  end;
    sleep(100);

  end;
//{$EN/DIF}
  // it.free;
  map.free;
  Addmutex.free;
  removeMutex.free();

  //semaphore.free;
  //semaphore := nil;

  inherited;

end;

procedure ThreadKindergarten.TCareThread.Execute;
begin

  FProc();
  owner.removeThread(index);

end;

constructor ThreadKindergarten.TCareThread.Create(const AProc: TProc;
  id: Integer; Aowner: ThreadKindergarten);
begin

  inherited Create(true);
  owner := Aowner;
  FreeOnTerminate := true;
  FProc := AProc;
  index := id;

end;

end.
