unit SystemApp;

/// Functions for handling operating systems routines
{$IFDEF Android}

interface

uses
  SysUtils, Androidapi.JNI,
  Androidapi.JNI.GraphicsContentViewText,
  Androidapi.JNI.App,
  Androidapi.JNI.JavaTypes,
  Androidapi.Helpers,
  FMX.Platform.Android,
  Androidapi.JNI.Provider,
  Androidapi.JNI.Net,
  Androidapi.JNI.WebKit,
  Androidapi.JNI.Os,
  Androidapi.NativeActivity,
  Androidapi.JNIBridge, FMX.Helpers.Android;
function OfflineMode(turnedon: system.uint32): boolean;
function isScreenOn: boolean;
procedure executeAndroid(cmd: String);
type
  JProcess = interface;

  JProcessClass = interface(JObjectClass)
    ['{4A4C247E-B643-4665-A218-C684C841854B}']
    function exitValue: Integer; cdecl; // ()I A: $401
    function getErrorStream: JInputStream; cdecl;
    // ()Ljava/io/InputStream; A: $401
    function getInputStream: JInputStream; cdecl;
    // ()Ljava/io/InputStream; A: $401
    function getOutputStream: JOutputStream; cdecl;
    // ()Ljava/io/OutputStream; A: $401
    function init: JProcess; cdecl; // ()V A: $1
    function waitFor: Integer; cdecl; // ()I A: $401
    procedure destroy; cdecl; // ()V A: $401
  end;

  [JavaSignature('java/lang/Process')]
  JProcess = interface(JObject)
    ['{BAA58731-C3FD-4483-A0D0-CAF3DF665ADC}']
    function exitValue: Integer; cdecl; // ()I A: $401
    function getErrorStream: JInputStream; cdecl;
    // ()Ljava/io/InputStream; A: $401
    function getInputStream: JInputStream; cdecl;
    // ()Ljava/io/InputStream; A: $401
    function getOutputStream: JOutputStream; cdecl;
    // ()Ljava/io/OutputStream; A: $401
    function waitFor: Integer; cdecl; // ()I A: $401
    procedure destroy; cdecl; // ()V A: $401
  end;

  TJProcess = class(TJavaGenericImport<JProcessClass, JProcess>);

type
  JRuntime = interface;

  JRuntimeClass = interface(JObjectClass)
    ['{34CE9F8C-A7C4-482F-B465-0C9A415DEF70}']
    function availableProcessors: Integer; cdecl; // ()I A: $1
    function exec(prog: JString): JProcess; cdecl; overload;
    // (Ljava/lang/String;)Ljava/lang/Process; A: $1
    function exec(prog: JString; envp: TJavaArray<JString>): JProcess; cdecl;
      overload; // (Ljava/lang/String;[Ljava/lang/String;)Ljava/lang/Process; A: $1
    function exec(prog: JString; envp: TJavaArray<JString>; directory: JFile)
      : JProcess; cdecl; overload;
    // (Ljava/lang/String;[Ljava/lang/String;Ljava/io/File;)Ljava/lang/Process; A: $1
    function exec(progArray: TJavaArray<JString>): JProcess; cdecl; overload;
    // ([Ljava/lang/String;)Ljava/lang/Process; A: $1
    function exec(progArray: TJavaArray<JString>; envp: TJavaArray<JString>)
      : JProcess; cdecl; overload;
    // ([Ljava/lang/String;[Ljava/lang/String;)Ljava/lang/Process; A: $1
    function exec(progArray: TJavaArray<JString>; envp: TJavaArray<JString>;
      directory: JFile): JProcess; cdecl; overload;
    // ([Ljava/lang/String;[Ljava/lang/String;Ljava/io/File;)Ljava/lang/Process; A: $1
    function freeMemory: Int64; cdecl; // ()J A: $101
    function getLocalizedInputStream(stream: JInputStream): JInputStream;
      deprecated; cdecl; // (Ljava/io/InputStream;)Ljava/io/InputStream; A: $1
    function getLocalizedOutputStream(stream: JOutputStream): JOutputStream;
      deprecated; cdecl; // (Ljava/io/OutputStream;)Ljava/io/OutputStream; A: $1
    function getRuntime: JRuntime; cdecl; // ()Ljava/lang/Runtime; A: $9
    function maxMemory: Int64; cdecl; // ()J A: $101
    function removeShutdownHook(hook: JThread): boolean; cdecl;
    // (Ljava/lang/Thread;)Z A: $1
    function totalMemory: Int64; cdecl; // ()J A: $101
    procedure addShutdownHook(hook: JThread); cdecl;
    // (Ljava/lang/Thread;)V A: $1
    procedure exit(code: Integer); cdecl; // (I)V A: $1
    procedure gc; cdecl; // ()V A: $101
    procedure halt(code: Integer); cdecl; // (I)V A: $1
    procedure load(absolutePath: JString); cdecl; // (Ljava/lang/String;)V A: $1
    procedure loadLibrary(nickname: JString); cdecl;
    // (Ljava/lang/String;)V A: $1
    procedure runFinalization; cdecl; // ()V A: $1
    procedure runFinalizersOnExit(run: boolean); deprecated; cdecl;
    // (Z)V A: $9
    procedure traceInstructions(enable: boolean); cdecl; // (Z)V A: $1
    procedure traceMethodCalls(enable: boolean); cdecl; // (Z)V A: $1
  end;

  [JavaSignature('java/lang/Runtime')]
  JRuntime = interface(JObject)
    ['{9F17530C-10D5-48BB-A741-5B3B6598D558}']
    function availableProcessors: Integer; cdecl; // ()I A: $1
    function exec(prog: JString): JProcess; cdecl; overload;
    // (Ljava/lang/String;)Ljava/lang/Process; A: $1
    function exec(prog: JString; envp: TJavaArray<JString>): JProcess; cdecl;
      overload; // (Ljava/lang/String;[Ljava/lang/String;)Ljava/lang/Process; A: $1
    function exec(prog: JString; envp: TJavaArray<JString>; directory: JFile)
      : JProcess; cdecl; overload;
    // (Ljava/lang/String;[Ljava/lang/String;Ljava/io/File;)Ljava/lang/Process; A: $1
    function exec(progArray: TJavaArray<JString>): JProcess; cdecl; overload;
    // ([Ljava/lang/String;)Ljava/lang/Process; A: $1
    function exec(progArray: TJavaArray<JString>; envp: TJavaArray<JString>)
      : JProcess; cdecl; overload;
    // ([Ljava/lang/String;[Ljava/lang/String;)Ljava/lang/Process; A: $1
    function exec(progArray: TJavaArray<JString>; envp: TJavaArray<JString>;
      directory: JFile): JProcess; cdecl; overload;
    // ([Ljava/lang/String;[Ljava/lang/String;Ljava/io/File;)Ljava/lang/Process; A: $1
    function getLocalizedInputStream(stream: JInputStream): JInputStream;
      deprecated; cdecl; // (Ljava/io/InputStream;)Ljava/io/InputStream; A: $1
    function getLocalizedOutputStream(stream: JOutputStream): JOutputStream;
      deprecated; cdecl; // (Ljava/io/OutputStream;)Ljava/io/OutputStream; A: $1
    function removeShutdownHook(hook: JThread): boolean; cdecl;
    // (Ljava/lang/Thread;)Z A: $1
    procedure addShutdownHook(hook: JThread); cdecl;
    // (Ljava/lang/Thread;)V A: $1
    procedure exit(code: Integer); cdecl; // (I)V A: $1
    procedure halt(code: Integer); cdecl; // (I)V A: $1
    procedure load(absolutePath: JString); cdecl; // (Ljava/lang/String;)V A: $1
    procedure loadLibrary(nickname: JString); cdecl;
    // (Ljava/lang/String;)V A: $1
    procedure runFinalization; cdecl; // ()V A: $1
    procedure traceInstructions(enable: boolean); cdecl; // (Z)V A: $1
    procedure traceMethodCalls(enable: boolean); cdecl; // (Z)V A: $1
  end;

  TJRuntime = class(TJavaGenericImport<JRuntimeClass, JRuntime>)
  end;

implementation

function isScreenOn: boolean;
var
  pm: JPowerManager;
  pmObj: JObject;
begin
  pmObj := SharedActivityContext.getSystemService
    (TJContext.JavaClass.POWER_SERVICE);
  pm := TJPowerManager.Wrap((pmObj as ILocalObject).GetObjectID);
  result := pm.isScreenOn;
end;

function OfflineMode(turnedon: system.uint32): boolean;
begin
executeAndroid('settings put global airplane_mode_on '+inttostr(turnedon));
executeAndroid('am broadcast -a android.intent.action.AIRPLANE_MODE');
end;

procedure executeAndroid(cmd: String);
var
  su: JProcess;

begin
  try
    su := TJRuntime.JavaClass.getRuntime.exec(StringToJString(cmd));
  except
    on E: Exception do
    begin
    end;
  end;
end;

end.

{$ELSE}
interface implementation

end.
{$ENDIF}
