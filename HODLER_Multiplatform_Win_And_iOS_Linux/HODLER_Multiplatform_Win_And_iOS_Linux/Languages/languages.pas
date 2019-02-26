unit languages;

interface

uses system.Generics.Collections, system.Classes, system.Types, SysUtils,
  system.IOUtils, Fmx.Dialogs, Json, Fmx.TabControl, Fmx.stdCtrls, Fmx.Controls,
  Fmx.edit;

{$IF DEFINED(ANDROID) OR DEFINED(IOS) OR DEFINED(LINUX) }

const
  StrStartIteration = {$IFNDEF LINUX} 0 {$ELSE}1{$ENDIF};

type
  AnsiString = string;

type
  WideString = String;

type
  AnsiChar = Char;
{$ELSE}

const
  StrStartIteration = 1;
{$ENDIF}
  /// ///////////////////////////////////////////////////////////////////////////////
  ///
Function loadLanguageFile(lang: AnsiString): WideString;
function dictionary(key: AnsiString): WideString;
procedure prepareTranslateFile();

implementation

uses
  uHome;
/// ///////////////////////////////////////////////////////////////////////////////

procedure prepareTranslateFile();
var
  i: integer;
  comp: TComponent;
  data: TJsonObject;
  ts: TStringList;

begin

  data := TJsonObject.Create();

  for i := 0 to frmHome.ComponentCount - 1 do
  begin
    comp := frmHome.Components[i];
    if comp is TTabItem then
      Continue;

    if comp.Name = 'FileManagerPathLabel' then
      Continue;

    if comp is TEdit then
      Continue;

    if comp is TPresentedTextControl then
    begin
      data.AddPair(trim(comp.Name), TPresentedTextControl(comp).text);
    end

    else if comp is TTextControl then
    begin
      data.AddPair(trim(comp.Name), TTextControl(comp).text);
    end;

  end;

  // data save to file;

  ts := TStringList.Create();
  ts.text := data.ToString();
  ts.SaveToFile(system.IOUtils.TPath.Combine
    (system.IOUtils.TPath.GetDocumentsPath, 'ENG.langSRC'));
  ts.Free;
  data.Free;

end;

function dictionary(key: AnsiString): WideString;
var
  value: WideString;
begin

  if frmHome.SourceDictionary.TryGetValue(key, value) then
  begin

    exit(value);

  end;

  result := key;

end;

Function loadLanguageFile(lang: AnsiString): WideString;
var
  List: TStringList;
  Stream: TResourceStream;
begin
  lang := AnsiUpperCase(lang);

  (* {$IFDEF ANDROID}

    List := TStringList.Create;
    try
    List.LoadFromFile(System.ioUtils.TPath.GetDocumentsPath + PathDelim + lang + 'lang.json' , TEncoding.BigEndianUnicode);
    Except
    on E : Exception do
    begin
    showmessage(E.Message);
    end;
    //List.Free;
    end;

    {$ELSE} *)
  Stream := TResourceStream.Create(HInstance, lang + '_lang', RT_RCDATA);
  try
    List := TStringList.Create;
    try
      List.LoadFromStream(Stream, TEncoding.BigEndianUnicode);

    finally
      // List.Free;
    end;
  finally
    Stream.Free;
  end;
  // {$ENDIF}

  result := List.text;
  List.Free;

end;

end.
