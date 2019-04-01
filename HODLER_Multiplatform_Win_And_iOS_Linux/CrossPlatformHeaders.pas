unit CrossPlatformHeaders;

interface
type
  AnsiString = string;

type
  WideString = string;

type
  AnsiChar = Char;
{$IF DEFINED(ANDROID) OR DEFINED(IOS) }

const
  StrStartIteration =  0 ;


{$ELSE}

const
  StrStartIteration = 1;
{$ENDIF}

implementation

end.
