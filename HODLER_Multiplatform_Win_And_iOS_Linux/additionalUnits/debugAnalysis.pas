unit debugAnalysis;



interface

uses
  System.SysUtils, System.Classes, FMX.Types, FMX.Controls, FMX.Layouts,
  FMX.Edit, FMX.StdCtrls, FMX.Clipboard, FMX.Platform, FMX.Objects,
  System.Types, StrUtils , FMX.Dialogs;

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
  logData : AnsiString = '';

  procedure assert( value : boolean ; msg : AnsiString ;  sender : TObject = nil);



implementation

procedure assert( value : boolean ; msg : AnsiString ; sender : TObject = nil);
begin
{$IFDEF DEBUG}
  if value then
  begin

    tthread.Synchronize(nil , procedure
    begin
      showmessage('Critical error ' + msg);
    end);

  end;
{$ENDIF}
end;

end.
