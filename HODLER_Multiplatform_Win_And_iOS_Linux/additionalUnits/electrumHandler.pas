unit electrumHandler;

// electrum handling for bitcoin clones
interface

uses
  System.classes, System.sysutils, StrUtils, WalletStructureData,
  CryptoCurrencyData, tokenData, JSON, System.TimeSpan, System.Diagnostics,
  idTCPClient, idSSLOpenSSL, IdSSLOpenSSLHeaders, System.IOUtils, misc, math,
  IdException;

type
  TSSLClientHandler = class(TIdSSLIOHandlerSocketOpenSSL)
  private type
    TSSLSocketWrapper = class(TIdSSLSocket);
    TSSLContextWrapper = class(TIdSSLContext);
  protected
    procedure DoBeforeConnect(ASender: TIdSSLIOHandlerSocketOpenSSL); override;
    procedure InitComponent; override;
  public
    procedure XonGetPassword(var password: string);
    function SSL: Pointer;
    function Ctx: Pointer;
  end;

  { TSSLClientWrapper }
var
  tcpConnection: array [0 .. 8, 0 .. 99] of TidTCPClient;
  userPeers: array [0 .. 8] of TidTCPClient;
  tcpConnections: array [0 .. 8] of smallint;
function tcpTest: string;
function electrumRPC(coinid: integer; method: string; params: array of string;
  tries: integer = 0; tSock: TidTCPClient = nil): string;
function sendTXHandler(s: string): string;
procedure enetSetup;
function getTCPForCoin(coinid: integer; tries: integer): TidTCPClient;
function createTCPConnection(host: string; port: integer): TidTCPClient;
procedure saveUserPeers;
implementation

function TSSLClientHandler.Ctx: Pointer;
begin
  if Assigned(fSSLContext) then
    Result := TSSLContextWrapper(fSSLContext).fContext
  else
    Result := nil;
end;

procedure TSSLClientHandler.XonGetPassword(var password: string);
begin
  password := 'hodler';
end;

procedure TSSLClientHandler.DoBeforeConnect
  (ASender: TIdSSLIOHandlerSocketOpenSSL);
begin
  inherited;
  if Assigned(fSSLContext) then
    FreeAndNil(fSSLContext);
  if Assigned(fSSLSocket) then
    FreeAndNil(fSSLSocket);
  Init;
end;

procedure TSSLClientHandler.InitComponent;
begin
  inherited;
  SSLOptions.Mode := sslmClient;
  PassThrough := False;
end;

function TSSLClientHandler.SSL: Pointer;
begin
  if Assigned(fSSLContext) then
    Result := TSSLSocketWrapper(SSLSocket).fSSL
  else
    Result := nil;
end;

function jarrToString(jarr: TJSONArray): TArray<string>;
var
  params: TArray<string>;
  i: integer;
begin
  SetLength(params, jarr.Count);
  if jarr.Count > 0 then
  begin
    for i := 0 to jarr.Count - 1 do
    begin
      params[i] := jarr.Items[i].value;
    end;

  end;
  Result := params;
end;

function getSSLPort(params: TArray<string>): integer;
var
  i: integer;
  tmp: string;
begin
  Result := 0;
  for i := 0 to length(params) - 1 do
    if params[i].IndexOf('s') = 0 then
    begin
      tmp := params[i];
      tmp := tmp.Substring(1);
      Result := StrToIntDef(tmp, 0);
      exit;
    end;

end;

function sendTXHandler(s: string): string;
var
  JSON: TJSONObject;
  res: string;
begin
  JSON := TJSONObject.ParseJSONValue(s) as TJSONObject;
  res := JSON.GetValue('result').AsType<string>;
  if isHex(res) then
    Result := 'Transaction sent: ' + res
  else
    Result := 'Transaction failed ' + JSON.GetValue('error').AsType<string>;
  JSON.Free;
end;

function createTCPConnection(host: string; port: integer): TidTCPClient;
var
  err: string;
begin
  try
    Result := TidTCPClient.Create();
    Result.ioHandler := TSSLClientHandler.Create();
    TSSLClientHandler(Result.ioHandler).MaxLineLength := 1024 * 1024 * 8;
    TSSLClientHandler(Result.ioHandler).onGetPassword :=
      TSSLClientHandler(Result.ioHandler).XonGetPassword;
    TSSLClientHandler(Result.ioHandler).SSLOptions.VerifyMode := [];
    TSSLClientHandler(Result.ioHandler).SSLOptions.VerifyDepth := 0;
    TSSLClientHandler(Result.ioHandler).PassThrough := False;
    TSSLClientHandler(Result.ioHandler).SSLOptions.Mode := sslmClient;
    TSSLClientHandler(Result.ioHandler).SSLOptions.method := sslvTLSv1_2;
    TSSLClientHandler(Result.ioHandler).SSLOptions.SSLVersions :=
      [sslvSSLv2, sslvSSLv23, sslvSSLv3, sslvTLSv1, sslvTLSv1_1, sslvTLSv1_2];
    TSSLClientHandler(Result.ioHandler).SSLOptions.CipherList :=
      'ECDHE-RSA-AES256-GCM-SHA384:' + 'ECDHE-RSA-AES128-GCM-SHA256:' +
      'ECDHE-RSA-AES256-SHA384:' + 'ECDHE-RSA-AES128-SHA256:' +
      'ECDHE-RSA-AES256-SHA:' + 'ECDHE-RSA-AES128-SHA:' +
      'DHE-RSA-AES256-GCM-SHA384:' + 'DHE-RSA-AES256-SHA256:' +
      'DHE-RSA-AES256-SHA:' + 'DHE-RSA-AES128-GCM-SHA256:' +
      'DHE-RSA-AES128-SHA256:' + 'DHE-RSA-AES128-SHA:' + 'DES-CBC3-SHA:' +
      '!ADH:!EXP:!RC4:!eNULL@STRENGTH';

    Result.host := host;
    Result.port := port;
    Result.ConnectTimeout := 2500;
    Result.ReadTimeout := 7000;
    Result.Connect;
  except
    on E: Exception do
    begin
      err := E.Message;
      err := Lowercase(err);
      Result.DisposeOf;
      Result := nil;
    end;
  end;
end;

procedure loadUserPeers;
var
  ts: tstringlist;
  peer: tstringlist;
  procedure setPeer(peer: tstringlist; coinid: integer);
  begin
    if peer.Count = 2 then
    begin
      tcpConnection[coinid, tcpConnections[coinid]] :=
        createTCPConnection(peer.Strings[0],
        StrToIntDef(peer.Strings[1], 50002));
      userPeers[coinid] := tcpConnection[coinid, tcpConnections[coinid]];
      inc(tcpConnections[coinid]);

    end;

    peer.DisposeOf;
  end;

begin
  ts := tstringlist.Create;
  try
    if fileexists(HOME_PATH + '/userpeers.dat') then
    begin
      ts.LoadFromFile(HOME_PATH + '/userpeers.dat');
      setPeer(SplitString(ts.Strings[0], ':'), 0);
      setPeer(SplitString(ts.Strings[1], ':'), 1);
      setPeer(SplitString(ts.Strings[2], ':'), 2);
      setPeer(SplitString(ts.Strings[3], ':'), 3);
      setPeer(SplitString(ts.Strings[4], ':'), 7);
    end;
  finally
   ts.DisposeOf;
  end;
end;

procedure saveUserPeers;
var ts:TStringList;
function getUserPeer(id:integer):string;
begin
result:='';
if userPeers[id]<>nil then
result:=userPeers[id].Host+':'+IntToStr(userPeers[id].Port);

end;
begin
  ts := tstringlist.Create;
  ts.Add(getUserPeer(0));
  ts.Add(getUserPeer(1));
  ts.Add(getUserPeer(2));
  ts.Add(getUserPeer(3));
  ts.Add(getUserPeer(7));
  ts.SaveToFile(HOME_PATH + '/userpeers.dat');
  ts.DisposeOf;

end;

procedure setupHandler;
begin
  loadUserPeers;
  tcpConnection[0, tcpConnections[0]] :=
    createTCPConnection('electrum.be', 50002);
  inc(tcpConnections[0]);
  tcpConnection[0, tcpConnections[0]] :=
    createTCPConnection('us.electrum.be', 50002);
  inc(tcpConnections[0]);
  tcpConnection[1, tcpConnections[1]] :=
    createTCPConnection('backup.electrum-ltc.org', 443);
  inc(tcpConnections[1]);
  tcpConnection[2, tcpConnections[2]] :=
    createTCPConnection('drk.p2pay.com', 50002);
  inc(tcpConnections[2]);
  tcpConnection[3, tcpConnections[3]] :=
    createTCPConnection('bch0.kister.net', 50002);
  inc(tcpConnections[3]);
  tcpConnection[7, tcpConnections[7]] :=
    createTCPConnection('satoshi.vision.cash', 50002);
  inc(tcpConnections[7]);
end;

function getTCPForCoin(coinid: integer; tries: integer): TidTCPClient;
begin
result:=nil;
  if tries>=0 then
  Result := tcpConnection[coinid, tries] else
  Result := tcpConnection[coinid, 0] ;
  if (Result = nil) or (tries = -1) then
  begin
    if (tcpConnections[coinid] = 1) and (Result = nil) then
      raise Exception.Create('No electrums for coin ' + inttostr(coinid));
    Result := getTCPForCoin(coinid, random(tcpConnections[coinid]));

  end;
end;

function electrumRPC(coinid: integer; method: string; params: array of string;
  tries: integer = 0; tSock: TidTCPClient = nil): string;
  function arrToParams(arr: array of string): string;
  var
    JSONObj: TJSONObject;
    params: TJSONArray;
    i: integer;
    el: TJSONValue;
  begin
    Result := '';

    params := TJSONArray.Create;
    try
      for i := Low(arr) to High(arr) do
      begin
        if (arr[i] = 'true') or (arr[i] = 'true') then
          params.AddElement(TJSONBool.Create(StrToBoolDef(arr[i], False)))
        else

          params.Add(arr[i]);
      end;
      Result := params.ToJSON;
    except
      params.Free;
      raise;
    end;

  end;

var
  socket: TidTCPClient;
  tmps: TidTCPClient;
  err: string;
  flock: Tobject;
begin
  flock := Tobject.Create;
  TMonitor.Enter(flock);
  if tries = tcpConnections[coinid] then
    exit;

  if tSock = nil then
    socket := getTCPForCoin(coinid, tries)
  else
    tmps := tSock;
  try
    // if socket.Connected = False then
    if tSock = nil then
    begin
      tmps := createTCPConnection(socket.host, socket.port);
      tSock := tmps;
    end;
    if tmps = nil then
    begin
      raise Exception.Create('temporary socket is nil');

    end;
    tmps.socket.WriteLn('{"jsonrpc":"2.0","method":"' + method + '","params":' +
      arrToParams(params) + ',"id":"' + inttohex(random($FFFFFFFF), 8) + '"}');
    if tmps.Connected then
    begin
      Result := tmps.ioHandler.ReadLn();
      // writeln(result);
      tmps.socket.WriteBufferClear;
      if tSock <> tmps then
        tmps.DisposeOf;
    end
    else
    begin
      tmps.DisposeOf;
      Result := '';
    end;
  except
    on E: Exception do
    begin
      if not(E is EIdConnClosedGracefully) then
      begin
        tmps.DisposeOf;
        err := E.Message;
        err := Lowercase(E.Message);
        Result := electrumRPC(coinid, method, params, tries + 1);
      end;
    end;

  end;
  TMonitor.exit(flock);
  flock.DisposeOf;
end;

procedure setupPeers(coinid: integer);
var
  jobj: TJSONObject;
  jarr, peer: TJSONArray;
  s, res: string;
  i, conn, port: integer;
begin
  try
    s := electrumRPC(coinid, 'server.peers.subscribe', []);
    jobj := TJSONObject.ParseJSONValue(s) as TJSONObject;
    jarr := (jobj.GetValue('result').AsType<TJSONArray>);
    conn := 0;
    for i := 0 to jarr.Count - 1 do
    begin
      if conn = 10 then
        break;

      peer := jarr.Items[i].AsType<TJSONArray>;
      port := getSSLPort(jarrToString(peer.Items[2].AsType<TJSONArray>));
      if port = 1 then
        continue;

      if (port > 0) and (tcpConnections[coinid] < 100) then
      begin
        try
          tcpConnection[coinid, tcpConnections[coinid]] :=
            createTCPConnection(peer.Items[1].AsType<string>, port);
          if tcpConnection[coinid, tcpConnections[coinid]] <> nil then
            if tcpConnection[coinid, tcpConnections[coinid]].Connected then
            begin

              tcpConnection[coinid, tcpConnections[coinid]].socket.WriteLn
                ('{"jsonrpc":"2.0","method":"server.peers.subscribe","params":[],"id":"'
                + inttohex(random($FFFFFFFF), 8) + '"}');
              res := tcpConnection[coinid, tcpConnections[coinid]]
                .socket.ReadLn();
              inc(tcpConnections[coinid]);
              inc(conn);
            end;
        except
          on E: Exception do
          begin
            tcpConnection[coinid, tcpConnections[coinid]].DisposeOf;
            // Can't connect
          end;

        end;

      end;
    end;
  except
    on E: Exception do
    begin
      // writeln(e.message);
    end;
  end;
end;

function tcpTest: string;
var
  s: string;
  i: integer;
  ts: tstringlist;
  t: int64;
begin
  // t := GetTickCount();
  s := 'Connecting to peers...';
  setupPeers(1);
  exit(electrumRPC(1, 'blockchain.estimatefee', ['1']));
  for i := 0 to 999 do
  begin
    // s := s + #13#10 + inttostr(i) + ' ' + inttostr(GetTickCount() - t) + 'ms ' +
    // electrumRPC(1, 'blockchain.estimatefee', ['1']);

  end;
  ts := tstringlist.Create();
  ts.Text := s;
  ts.SaveToFile('ele.txt');
  ts.Free;
  Result := 'done';
end;

procedure enetSetup;
begin
  setupHandler;
  TThread.CreateAnonymousThread(
    procedure
    begin
      setupPeers(0);
      setupPeers(1);
      setupPeers(2);
      setupPeers(3);
      setupPeers(7);
    end).Start;
end;

initialization

{$DEFINE OPENSSL_NO_IDEA}
{$IFDEF MSWINDOWS}
  IdSSLOpenSSLHeaders.IdOpenSSLSetLibPath(ExtractFileDir(ParamStr(0)));
{$ENDIF}
{$IFDEF LINUX64}
 IdSSLOpenSSLHeaders.IdOpenSSLSetLibPath(ExtractFileDir(ParamStr(0)));
{$ENDIF}
{$IFDEF ANDROID}
IdSSLOpenSSLHeaders.IdOpenSSLSetLibPath(TPath.GetDocumentsPath);
{$ENDIF}
IdSSLOpenSSLHeaders.Load;
WhichFailedToLoad();

end.
