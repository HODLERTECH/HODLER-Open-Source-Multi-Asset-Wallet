unit uLauncher;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs,
  Posix.Base,
  Posix.Fcntl;

type
  TfrmLauncher = class(TForm)
    procedure FormShow(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  frmLauncher: TfrmLauncher;
type
  TStreamHandle = pointer;
implementation

{$R *.fmx}
function popen(const command: MarshaledAString; const _type: MarshaledAString): TStreamHandle; cdecl;
      external libc name _PU + 'popen';
function pclose(filehandle: TStreamHandle): int32; cdecl; external libc name _PU + 'pclose';
function fgets(buffer: pointer; size: int32; Stream: TStreamHandle): pointer; cdecl; external libc name _PU + 'fgets';

function runCommand(const acommand: MarshaledAString): String;
// run a linux shell command and return output
// Adapted from http://chapmanworld.com/2017/04/06/calling-linux-commands-from-delphi/
var
  handle: TStreamHandle;
  data: array [0 .. 511] of uint8;

  function bufferToString(buffer: pointer; maxSize: uint32): string;
  var
    cursor: ^uint8;
    endOfBuffer: nativeuint;
  begin
    if not assigned(buffer) then
      exit;
    cursor := buffer;
    endOfBuffer := nativeuint(cursor) + maxSize;
    while (nativeuint(cursor) < endOfBuffer) and (cursor^ <> 0) do
    begin
      result := result + chr(cursor^);
      cursor := pointer(succ(nativeuint(cursor)));
    end;
  end;

begin
  result := '';
  handle := popen(acommand, 'r');
  try
    while fgets(@data[0], sizeof(data), handle) <> nil do
    begin
      result := result + bufferToString(@data[0], sizeof(data));
    end;
  finally
    pclose(handle);
  end;
end;


procedure TfrmLauncher.FormShow(Sender: TObject);
var psx:AnsiString;
s:String;
begin
psx:='"'+ExtractFileDir(ParamStr(0))+'/hodler" 2>&1';
s:=runCommand(@psx[1]);
frmLauncher.visible:=false;
if Pos('libcurl.so',s)>0 then
ShowMessage('There is no libcurl3 installed in system, HODLER will not start');
halt(0);
end;

end.
