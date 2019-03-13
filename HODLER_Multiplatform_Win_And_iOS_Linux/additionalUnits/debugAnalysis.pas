unit debugAnalysis;

interface

uses
  SysUtils, System.Classes, System.IOUtils, FMX.Types, System.DateUtils,
  FMX.Controls, FMX.Layouts, System.Generics.Collections , System.Diagnostics ,
  FMX.Edit, FMX.StdCtrls, FMX.Clipboard, FMX.Platform, FMX.Objects,
  System.Types, StrUtils, FMX.Dialogs

{$IF DEFINED(MSWINDOWS)}
    , System.Win.Registry, Windows
{$ENDIF}
{$IFDEF ANDROID},

  Androidapi.JNI.GraphicsContentViewText,
  Androidapi.JNI.JavaTypes,
  Androidapi.Helpers,
  Androidapi.JNI.Net,
  Androidapi.JNI.Os,
  Androidapi.JNI.Webkit,
  Androidapi.JNIBridge
{$ENDIF}
    ;

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
  timeLogger = class
  private

    map : TDictionary< AnsiString , TStopwatch >;
    logList : TStringList;



  public


    procedure StartLog( name : AnsiString );
    function GetInterval( name : AnsiString ): single;
    procedure AddToLog( name : AnsiString );

    constructor Create( );
    destructor Destroy(); override;
  end;



var
  logData: TStringList;
  LOG_FILE_PATH: AnsiString;

procedure assert(value: boolean; msg: AnsiString; sender: TObject = nil);
procedure ExceptionHandler(sender: TObject; E: Exception);
procedure saveLogFile();
procedure addLog(msg: AnsiString);
procedure SendReport(url: AnsiString; msg: AnsiString);
procedure SendUserReport(msg: AnsiString; SendLog, SendDeviceInfo: boolean);
procedure SendAutoReport(msg: AnsiString; Stack: AnsiString;
  sender: AnsiString = '');
function getdeviceInfo(): AnsiString;
function getDetailedData(): AnsiString;

function memLeakAnsiString( v : AnsiString ): AnsiString;
function RefCount(const _s: AnsiString): integer;
procedure showRefCount(const _s: AnsiString);

implementation

uses misc;

procedure showRefCount(const _s: AnsiString);
begin
  tthread.Synchronize(nil , procedure
  begin
    showmessage( intToStr( refcount( _s ) ) );
  end);

end;

function RefCount(const _s: AnsiString): integer;
var
  ptr: PLongWord;
begin
  ptr := Pointer(_s);
  Dec(Ptr, 2);
  Result := ptr^;
end;

function memLeakAnsiString( v : AnsiString ): AnsiString;

 var
  i: integer;
  a: integer;
  x: integer;
  b: integer;
  n, c: integer;
  output: AnsiString;
  sb: System.UInt8;
  S: array of System.UInt8;
  const
  Codes58: AnsiString =
    '123456789ABCDEFGHJKLMNPQRSTUVWXYZabcdefghijkmnopqrstuvwxyz';
begin
  SetLength(S, (Length(V) * 2));

  for i := 1 to (Length(V) div 2) do
  begin
    sb := System.UInt8(StrToInt('$' + Copy(V, ((i - 1) * 2) + 1, 2)));
    S[i] := sb;
  end;
  n := 34;

  SetLength(output, 34);
  while n > 0 do
  begin
    c := 0;
    for i := 1 to 25 do
    begin
      c := c * 256 + ord(S[i]);
      S[i] := System.UInt8(c div 58);
      c := c mod 58;
    end;
    output[n] := Codes58[c + 1];
    dec(n);
  end;

  for n := 2 to Length(output) do
  begin
    if output[n] = '1' then
    begin
      Delete(output, n, 1);
      continue;
    end;
    break;

  end;
  result := output;
   //S := nil;


  Delete(output , low(output) , length(output) );
  //Delete(S , low(S) , length(S) );

  SetLength(output,0);
  //SetLength(S,0);
  SetLength(V,0);


end;

function getDetailedData(): AnsiString;
{$IF DEFINED(MSWINDOWS)}
var
  Reg: TRegistry;
begin
  REsult := '';
  Reg := TRegistry.Create(KEY_READ);
  if Reg.Access = KEY_READ then
  begin

  end;
  try
    Reg.RootKey := HKEY_LOCAL_MACHINE;
    if Reg.OpenKey('\HARDWARE\DESCRIPTION\System\CentralProcessor\0', False)
    then
      REsult := Reg.ReadString('ProcessorNameString');
  finally
    Reg.Free;
  end;
end;
{$ENDIF}
{$IF DEFINED(ANDROID)}

var
  temp: AnsiString;
begin

  temp := Format('Device Type: %s', [JStringToString(TJBuild.JavaClass.MODEL)]);

  temp := temp + Format('OS: %s',
    [JStringToString(TJBuild_VERSION.JavaClass.RELEASE)]);

  temp := temp + Format('OS Version: %s',
    [JStringToString(TJBuild_VERSION.JavaClass.RELEASE)]);
  REsult := temp;
end;
{$ENDIF}
{$IF DEFINED(LINUX)}
begin
  REsult := '';

end;
{$ENDIF}
{$IF DEFINED(IOS)}
begin
  REsult := '';

end;
{$ENDIF}
// function CPUType: string;

/// ////////////////////////////////////////////////////

function getdeviceInfo(): AnsiString;
var
  temp: AnsiString;
begin
  REsult := '';

  temp := misc.SYSTEM_NAME;
  if temp <> '' then
    REsult := REsult + 'os=' + temp;

  temp := getDetailedData;
  if temp <> '' then
    REsult := REsult + '&more=' + temp;

end;

procedure SendAutoReport(msg: AnsiString; Stack: AnsiString;
  sender: AnsiString = '');
var
  temp: AnsiString;
begin
  if msg = '' then
    msg := 'empty';
  if Stack = '' then
    Stack := 'empty';
  if sender = '' then
    sender := 'empty';

  temp := 'msg=' + msg + '&' + 'stack=' + Stack + '&' + 'sender=' + sender + '&'
    + 'ver=' + StringReplace(CURRENT_VERSION, '.', 'x', [rfReplaceAll]) + '&' +
    getdeviceInfo();
  tthread.CreateAnonymousThread(
    procedure
    begin
      SendReport('https://hodler1.nq.pl/autoreport.php', temp);
    end).Start;

end;

procedure SendReport(url: AnsiString; msg: AnsiString);
var
  StringURL: STRING;
  StringMSG: String;
begin

  StringURL := url;
  StringMSG := msg;
  postDataOverHTTP(StringURL, StringMSG, False, true);

end;

procedure SendUserReport(msg: AnsiString; SendLog, SendDeviceInfo: boolean);
var
  path: AnsiString;
  errorList, tmpTsl: TStringList;

  temp, log, DeviceInfo: AnsiString;

begin

  if SendLog then
  begin
    errorList := TStringList.Create();
    tmpTsl := TStringList.Create();
    if Tdirectory.Exists( LOG_FILE_PATH ) then
      for path in TDirectory.GetFiles(LOG_FILE_PATH) do
      begin
        temp := ExtractFileName(path);
        temp := leftStr(temp, 3);
        if temp = 'LOG' then
        begin

          tmpTsl.LoadFromFile(path);

          errorList.Add(tmpTsl.DelimitedText);

        end;

      end;
    log := errorList.DelimitedText;
    tmpTsl.Free;
    errorList.Free;
  end
  else
    log := 'empty';

  if SendDeviceInfo then
  begin

    DeviceInfo := getdeviceInfo();

  end
  else
    DeviceInfo := 'empty';

  temp := 'msg=' + msg + '&errlist=' + log + '&more=' + DeviceInfo;

  tthread.CreateAnonymousThread(
    procedure
    begin
      SendReport('https://hodler1.nq.pl/userreport.php', temp);
    end).Start;

end;

procedure addLog(msg: AnsiString);
var
  timeStamp: String;
begin

  if logData = nil then
  begin
    logData := TStringList.Create();
  end;
  DateTimeToString(timeStamp, '[c]', Now);
  logData.Add(timeStamp + ':' + msg);

end;

procedure saveLogFile();
var
  temp: TStringList;
  Y, m, d: Word;
begin
{$IF DEFINED(MSWINDOWS) }
  if (logData <> nil) and (logData.Count > 0) then
  begin
    { temp := TStringList.Create();
      temp.load }
    DecodeDate(Now, Y, m, d);
    // Format('%d.%d.%d', [Y, m, d])

    if not TDirectory.Exists(LOG_FILE_PATH) then
      TDirectory.CreateDirectory( LOG_file_PATh );

    logData.SaveToFile(System.IOUtils.TPath.combine(LOG_FILE_PATH,
      'LOG_' + IntToStr(DateTimeToUnix(Now)) + '.log'));

    logData.DisposeOf;
    logData := nil;
  end;
 {$ENDIF}
end;

procedure ExceptionHandler(sender: TObject; E: Exception);
begin
  addLog('------ERROR------');
  addLog(E.Message);
  addLog('------STACK TRACE------');
  addLog(E.StackTrace);
  addLog('------END------');



  // showmessage( Exception.GetStackInfoStringProc( ExceptAddr ) );
  if USER_ALLOW_TO_SEND_DATA then
    SendAutoReport(E.Message, E.StackTrace, sender.ClassName + ' ' +
      sender.UnitName);

  saveLogFile();

end;

procedure assert(value: boolean; msg: AnsiString; sender: TObject = nil);
begin
{$IFDEF DEBUG}
  if value then
  begin

    raise Exception.Create(msg);

  end;
{$ENDIF}
end;

{ timeLogger }

constructor timeLogger.Create( );
begin
  Inherited ;
  map := TDictionary< AnsiString , TStopwatch>.create();
  logList := TStringList.Create();
end;

destructor timeLogger.Destroy;
begin



  map.Free;
  logList.Free;
  inherited destroy;

end;

procedure timeLogger.StartLog( name : AnsiString );
begin

  map.AddOrSetValue( name , TStopwatch.StartNew );

end;

function timeLogger.GetInterval( name : AnsiString ): Single;
var
  temp : TStopwatch;
begin
  result := 0;
  if map.TryGetValue( name , temp ) then
  begin

    result := temp.Elapsed.TotalSeconds;

  end;

end;

procedure timeLogger.AddToLog( name : AnsiString );
begin

  Loglist.Add(name +': ' + floatToStr(GetInterval(name)) )

end;

end.
