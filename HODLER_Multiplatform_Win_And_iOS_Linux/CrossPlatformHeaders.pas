unit CrossPlatformHeaders;

interface
type
  AnsiString = string;

type
  WideString = string;

type
  AnsiChar = Char;
{$IF DEFINED(ANDROID) OR DEFINED(IOS) OR DEFINED(LINUX)}

const
  StrStartIteration = {$IFNDEF LINUX} 0 {$ELSE}1{$ENDIF};


{$ELSE}

const
  StrStartIteration = 1;
{$ENDIF}

implementation

end.
