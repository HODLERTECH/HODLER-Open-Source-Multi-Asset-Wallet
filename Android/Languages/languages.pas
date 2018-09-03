unit languages;

interface


uses system.Generics.Collections , System.Classes , System.Types , SysUtils , System.IOUtils , Fmx.Dialogs;

{$IFDEF ANDROID}

const
  StrStartIteration = 0;

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
 //////////////////////////////////////////////////////////////////////////////////
 ///
Function loadLanguageFile(lang : AnsiString) : WideString;

implementation
//////////////////////////////////////////////////////////////////////////////////

Function loadLanguageFile(lang : AnsiString) : WideString;
var
  List: TStringList;
  Stream: TResourceStream;
begin
  lang := AnsiUpperCase(lang);

{$IFDEF ANDROID}

  List := TStringList.Create;
  try
    List.LoadFromFile(System.ioUtils.TPath.GetDocumentsPath + PathDelim + lang + '.lang' , TEncoding.BigEndianUnicode);
  Except
  on E : Exception do
    begin
      showmessage(E.Message);
    end;
      //List.Free;
  end;

{$ELSE}
  Stream := TResourceStream.Create(HInstance, lang + '_lang', RT_RCDATA);
  try
    List := TStringList.Create;
    try
      List.LoadFromStream(Stream , TEncoding.BigEndianUnicode);

    finally
      //List.Free;
    end;
  finally
    Stream.Free;
  end;
{$ENDIF}

  Result := List.Text;
  list.Free;

end;

end.
