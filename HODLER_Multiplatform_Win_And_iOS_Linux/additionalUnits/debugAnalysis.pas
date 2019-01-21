unit debugAnalysis;

interface

uses
  SysUtils, System.Classes, System.IOUtils, FMX.Types, System.DateUtils,
  FMX.Controls, FMX.Layouts,
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

implementation

uses misc;

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

  if (logData <> nil) and (logData.Count > 0) then
  begin
    { temp := TStringList.Create();
      temp.load }
    DecodeDate(Now, Y, m, d);
    // Format('%d.%d.%d', [Y, m, d])
    logData.SaveToFile(System.IOUtils.TPath.combine(LOG_FILE_PATH,
      'LOG_' + IntToStr(DateTimeToUnix(Now)) + '.log'));

    logData.DisposeOf;
    logData := nil;
  end;

end;

procedure ExceptionHandler(sender: TObject; E: Exception);
begin
  addLog('------ERROR------');
  addLog(E.Message);
  addLog('------STACK TRACE------');
  addLog(E.StackTrace);
  addLog('------END------');

  saveLogFile();

  // showmessage( Exception.GetStackInfoStringProc( ExceptAddr ) );
  if USER_ALLOW_TO_SEND_DATA then
    SendAutoReport(E.Message, E.StackTrace, sender.ClassName + ' ' +
      sender.UnitName);

  // {$IFDEF DEBUG}
  // showmessage( E.Message );
  // {$ENDIF}

  // showmessage(e.StackTrace);
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

end.
