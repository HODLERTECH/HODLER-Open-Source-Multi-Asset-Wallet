unit debugAnalysis;



interface

uses
  System.SysUtils, System.Classes, System.IOUtils, FMX.Types, System.DateUtils ,FMX.Controls, FMX.Layouts,
  FMX.Edit, FMX.StdCtrls, FMX.Clipboard, FMX.Platform, FMX.Objects,
  System.Types, StrUtils , FMX.Dialogs

{$IF DEFINED(MSWINDOWS)}
  ,  System.Win.Registry
  , Windows
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
  logData : TStringList;
  LOG_FILE_PATH : AnsiString;

  procedure assert( value : boolean ; msg : AnsiString ;  sender : TObject = nil);
  procedure ExceptionHandler( Sender : TObject ; E : Exception );
  procedure saveLogFile();
  procedure addLog( msg : AnsiString );
  procedure SendReport( url : AnsiString ;msg : AnsiString );
  procedure SendUserReport( msg : AnsiString );
  procedure SendAutoReport( msg : AnsiString );
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
  if reg.Access = KEY_READ  then
  begin

  end;
  try
    Reg.RootKey := HKEY_LOCAL_MACHINE;
    if Reg.OpenKey('\HARDWARE\DESCRIPTION\System\CentralProcessor\0', False) then
      Result := Reg.ReadString('ProcessorNameString');
  finally
    Reg.Free;
  end;
end;
{$ENDIF}
{$IF DEFINED(ANDROID)}
begin
  result := '';

end;
{$ENDIF}
{$IF DEFINED(LINUX)}
begin
  result := '';

end;
{$ENDIF}
{$IF DEFINED(IOS)}
begin
  result := '';

end;
{$ENDIF}

//function CPUType: string;

  ///////////////////////////////////////////////////////


function getdeviceInfo(): AnsiString;
begin
  result :=
    'os=' + misc.SYSTEM_NAME +
    '&more=' + getDetailedData;
end;

procedure SendAutoReport( msg : AnsiString );
var
  temp : AnsiString;
begin
  temp := 'msg=' + msg + '&' + getdeviceInfo();
  sendReport( '' ,  temp);

end;

procedure SendReport( url : AnsiString ; msg : AnsiString );
begin

  //postDataOverHTTP( url , msg , false , true );

end;

procedure SendUserReport( msg : AnsiString );
begin

  sendReport( '' , msg );

end;

procedure addLog( msg : AnsiString );
var
  timeStamp : String;
begin

  if logData = nil then
  begin
    logData := TStringList.Create();
  end;
  DateTimeToString(timeStamp , '[c]' , Now);
  logData.Add(timeStamp + ':' + msg );

end;

procedure saveLogFile();
var
  temp : TStringList;
  Y, m, d: Word;
begin

  if (logData <> nil) and (logData.Count > 0) then
  begin
   { temp := TStringList.Create();
    temp.load }
    DecodeDate(Now, Y, m, d);
    //  Format('%d.%d.%d', [Y, m, d])
    logData.SaveToFile( System.IOUtils.TPath.combine( LOG_FILE_PATH , 'LOG_' + IntToStr(DateTimeToUnix(Now)) + '.log' ) );

    logData.DisposeOf;
    logdata := nil;
  end;

end;

procedure ExceptionHandler( Sender : TObject ; E : Exception );
begin
  addLog('------ERROR------');
  addLog( E.Message );
  addLog('------STACK TRACE------');
  addLog( e.StackTrace );
  addLog('------END------');

  saveLogFile();

  //showmessage(e.StackTrace);
end;

procedure assert( value : boolean ; msg : AnsiString ; sender : TObject = nil);
begin
{$IFDEF DEBUG}
  if value then
  begin

    raise Exception.Create(msg);

  end;
{$ENDIF}
end;

end.
