{*******************************************************}
{                                                       }
{           CodeGear Delphi Runtime Library             }
{ Copyright(c) 2014-2017 Embarcadero Technologies, Inc. }
{              All rights reserved                      }
{                                                       }
{*******************************************************}

unit System.Net.HttpClient.Linux;

interface

implementation

uses
  System.Classes, System.Generics.Collections, System.SysUtils, System.Net.URLClient, System.Net.HttpClient,
  System.NetConsts, System.DateUtils, System.Types, Linuxapi.Curl, System.IOUtils, Posix.SysTypes, Posix.SysStat;

type
  TLinuxHTTPClient = class(THTTPClient)
  private
    class constructor Create;
    class destructor Destroy;
    function GetServerCertInfoFromRequest(const ARequest: THTTPRequest; var ACertificate: TCertificate): Boolean;
    function GetCertInfo(ACertData: PCurlCertInfo; var ACertificate: TCertificate): Boolean;
  protected
    function DoExecuteRequest(const ARequest: THTTPRequest; var AResponse: THTTPResponse;
      const AContentStream: TStream): THTTPClient.TExecutionResult; override;
    function DoSetCredential(AnAuthTargetType: TAuthTargetType; const ARequest: THTTPRequest;
      const ACredential: TCredentialsStorage.TCredential): Boolean; override;
    function DoGetResponseInstance(const AContext: TObject; const AProc: TProc;
      const AsyncCallback: TAsyncCallback; const AsyncCallbackEvent: TAsyncCallbackEvent;
      const ARequest: IURLRequest; const AContentStream: TStream): IAsyncResult; override;
    function DoGetHTTPRequestInstance(const AClient: THTTPClient; const ARequestMethod: string;
      const AURI: TURI): IHTTPRequest; override;
    function DoProcessStatus(const ARequest: IHTTPRequest; const  AResponse: IHTTPResponse): Boolean; override;
    function DoGetSSLCertificateFromServer(const ARequest: THTTPRequest): TCertificate; override;
    procedure DoServerCertificateAccepted(const ARequest: THTTPRequest); override;
    procedure DoGetClientCertificates(const ARequest: THTTPRequest; const ACertificateList: TList<TCertificate>); override;
    function DoClientCertificateAccepted(const ARequest: THTTPRequest; const AnIndex: Integer): Boolean; override;
    class function CreateInstance: TURLClient; override;
  public
    constructor Create;
  end;

  TLinuxHTTPResponse = class;
  TLinuxHTTPRequest = class(THTTPRequest)
  private
    FRequest: PCurl;
    FHeaders: TDictionary<string, string>;
    FTempFileName: string;
    [Weak] FResponse: TLinuxHTTPResponse;
    FErrorBuff: array [0 .. CURL_ERROR_SIZE] of Byte;
    FLastMethodString: string;
    procedure InitRequest;
    procedure CleanupRequest;
  protected
    procedure DoPrepare; override;

    function GetHeaders: TNetHeaders; override;
    procedure AddHeader(const AName, AValue: string); override;
    function RemoveHeader(const AName: string): Boolean; override;

    function GetHeaderValue(const AName: string): string; override;
    procedure SetHeaderValue(const AName, Value: string); override;
    class function CurlReadData(buffer: Pointer; size: size_t; nitems: size_t; instream: Pointer): size_t; cdecl; static;
    class function CurlWriteData(buffer: Pointer; size: size_t; nitems: size_t; instream: Pointer): size_t; cdecl; static;
    class function CurlReadHeaders(buffer: Pointer; size: size_t; nitems: size_t; instream: Pointer): size_t; cdecl; static;
  public
    constructor Create(const AClient: THTTPClient; const ARequestMethod: string; const AURI: TURI);
    destructor Destroy; override;
  end;

  TLinuxHTTPResponse = class(THTTPResponse)
  private
    [Weak] FRequest: TLinuxHTTPRequest;
    FNativeHeaders: TStringList;
    FNativeStatusCode: string;
    FNativeStatusLine: string;
	                                                                               
                                     
    FTotalRead: Int64;
    LeftToSend: Integer;
    function ReceiveData(buffer: Pointer; size: size_t; nitems: size_t): size_t;
    function ReceiveHeader(buffer: Pointer; size: size_t; nitems: size_t): size_t;
    function SendData(buffer: Pointer; size: size_t; nitems: size_t): size_t;
  protected
    procedure DoReadData(const AStream: TStream); override;

    function GetHeaders: TNetHeaders; override;
    function GetStatusCode: Integer; override;
    function GetStatusText: string; override;
    function GetVersion: THTTPProtocolVersion; override;
  public
    constructor Create(const AContext: TObject; const AProc: TProc; const AAsyncCallback: TAsyncCallback;
      const AAsyncCallbackEvent: TAsyncCallbackEvent; const ARequest: TLinuxHTTPRequest;
      const AContentStream: TStream);
    destructor Destroy; override;
  end;

type
  THTTPRequestMethod = (CONNECT, DELETE, GET, HEAD, OPTIONS, POST, PUT, TRACE, MERGE, PATCH, others);

function MethodStringToHTTPMethod(const AMethodString: string): THTTPRequestMethod;
var
  LMethod: string;
begin
  LMethod := AMethodString.ToUpper;
  if LMethod = sHTTPMethodConnect then
    Result := THTTPRequestMethod.CONNECT
  else if LMethod = sHTTPMethodDelete then
    Result := THTTPRequestMethod.DELETE
  else if LMethod = sHTTPMethodGet then
    Result := THTTPRequestMethod.GET
  else if LMethod = sHTTPMethodHead then
    Result := THTTPRequestMethod.HEAD
  else if LMethod = sHTTPMethodOptions then
    Result := THTTPRequestMethod.OPTIONS
  else if LMethod = sHTTPMethodPost then
    Result := THTTPRequestMethod.POST
  else if LMethod = sHTTPMethodPut then
    Result := THTTPRequestMethod.PUT
  else if LMethod = sHTTPMethodTrace then
    Result := THTTPRequestMethod.TRACE
  else if LMethod = sHTTPMethodMerge then
    Result := THTTPRequestMethod.MERGE
  else if LMethod = sHTTPMethodPatch then
    Result := THTTPRequestMethod.PATCH
  else
    Result := THTTPRequestMethod.others;
end;

{ TLinuxHTTPClient }

constructor TLinuxHTTPClient.Create;
begin
  inherited Initializer;
end;

class constructor TLinuxHTTPClient.Create;
begin
  curl_global_init(CURL_GLOBAL_DEFAULT);
end;

class function TLinuxHTTPClient.CreateInstance: TURLClient;
begin
  Result := TLinuxHTTPClient.Create;
end;

class destructor TLinuxHTTPClient.Destroy;
begin
  curl_global_cleanup;
end;

function TLinuxHTTPClient.DoClientCertificateAccepted(const ARequest: THTTPRequest; const AnIndex: Integer): Boolean;
begin
  { Not needed in Linux }
  Result := True;
end;

function TLinuxHTTPClient.DoExecuteRequest(const ARequest: THTTPRequest; var AResponse: THTTPResponse;
  const AContentStream: TStream): TLinuxHTTPClient.TExecutionResult;
var
  LRequest: TLinuxHTTPRequest;
  LList: pcurl_slist;
  LMethod: THTTPRequestMethod;
  LSize: curl_off_t; //long
  LOption: CURLoption;
  LValue: TPair<string, string>;
  LCode: TCurlCode;
  LResponseCode: NativeInt;
  LError: string;
begin
  LRequest := TLinuxHTTPRequest(ARequest);
  // Cleanup Response Headers
  SetLength(LRequest.FResponse.FHeaders, 0);
  LRequest.FResponse.FNativeHeaders.Clear;
  LRequest.FResponse.FTotalRead := 0;
  LRequest.FResponse.LeftToSend := 0;
  try
    LList := nil;
    try
      LMethod := MethodStringToHTTPMethod(LRequest.FMethodString);
      if LMethod in [THTTPRequestMethod.PUT, THTTPRequestMethod.POST] then
      begin
        LList := curl_slist_append(LList, MarshaledAString(UTF8String('Expect:')));
        if Assigned(LRequest.FSourceStream) then
        begin
          LSize := LRequest.FSourceStream.Size - LRequest.FSourceStream.Position;
          if LSize < 0 then
            LSize := 0;
        end
        else
          LSize := 0;
        LRequest.FResponse.LeftToSend := LSize;
        if LMethod = THTTPRequestMethod.PUT then
          LOption := CURLOPT_INFILESIZE_LARGE
        else
          LOption := CURLOPT_POSTFIELDSIZE;
        curl_easy_setopt(LRequest.FRequest, LOption, LSize);
      end;

      for LValue in LRequest.FHeaders do
        LList := curl_slist_append(LList, MarshaledAString(UTF8String(LValue.Key + ': ' + LValue.Value)));
      curl_easy_setopt(LRequest.FRequest, CURLOPT_HTTPHEADER, LList);

      LCode := curl_easy_perform(LRequest.FRequest);
    finally
      if LList <> nil then
        curl_slist_free_all(LList);
    end;

    case LCode of
      CURLE_OK:
      begin
        Result := TExecutionResult.Success;
        if curl_easy_getinfo(LRequest.FRequest, CURLINFO_RESPONSE_CODE, @LResponseCode) = CURLE_OK then
          TLinuxHTTPResponse(AResponse).FNativeStatusCode := LResponseCode.ToString;
      end;

      CURLE_SSL_ISSUER_ERROR{?}, CURLE_SSL_INVALIDCERTSTATUS{?}, CURLE_PEER_FAILED_VERIFICATION{?}, CURLE_SSL_CACERT {Server}:
        Result := TExecutionResult.ServerCertificateInvalid;

//      CURLE_SSL_CERTPROBLEM: { Local client certificate problem }
//        Result := TExecutionResult.UnknownError;

      else
        LError := UTF8ToString(@LRequest.FErrorBuff[0]);
        if LError = '' then
          LError := UTF8ToString(curl_easy_strerror(LCode));
        raise ENetHTTPClientException.CreateResFmt(@SNetHttpClientErrorAccessing, [
          Integer(LCode), LRequest.FURL.ToString, LError]);
    end;
  finally
    // Update Headers & Cookies
    LRequest.FResponse.GetHeaders;
  end;
end;

procedure TLinuxHTTPClient.DoGetClientCertificates(const ARequest: THTTPRequest;
  const ACertificateList: TList<TCertificate>);
begin
  inherited;
  { Not needed in Linux }
end;

function TLinuxHTTPClient.DoGetHTTPRequestInstance(const AClient: THTTPClient; const ARequestMethod: string;
  const AURI: TURI): IHTTPRequest;
begin
  Result := TLinuxHTTPRequest.Create(AClient, ARequestMethod, AURI);
end;

function TLinuxHTTPClient.DoGetResponseInstance(const AContext: TObject; const AProc: TProc;
  const AsyncCallback: TAsyncCallback; const AsyncCallbackEvent: TAsyncCallbackEvent; const ARequest: IURLRequest;
  const AContentStream: TStream): IAsyncResult;
begin
  Result := TLinuxHTTPResponse.Create(AContext, AProc, AsyncCallback, AsyncCallbackEvent, ARequest as TLinuxHTTPRequest,
    AContentStream);
end;

function TLinuxHTTPClient.DoGetSSLCertificateFromServer(const ARequest: THTTPRequest): TCertificate;
var
  LRequest: TLinuxHTTPRequest;
begin
  LRequest := TLinuxHTTPRequest(ARequest);
  if not GetServerCertInfoFromRequest(LRequest, Result) then
    Result := Default(TCertificate);
end;

function TLinuxHTTPClient.DoProcessStatus(const ARequest: IHTTPRequest; const AResponse: IHTTPResponse): Boolean;
var
  LRequest: TLinuxHTTPRequest;
  LResponse: TLinuxHTTPResponse;
begin
  LRequest := ARequest as TLinuxHTTPRequest;
  LResponse := AResponse as TLinuxHTTPResponse;
  // If the result is true then the while ends
  Result := True;
  if IsAutoRedirect(LResponse) then
  begin
    LRequest.FURL := ComposeRedirectURL(LRequest, LResponse);
    if IsAutoRedirectWithGET(LRequest, LResponse) then
    begin
      LRequest.FMethodString := sHTTPMethodGet; // Change to GET
      LRequest.FSourceStream := nil;            // Dont send any data
      LRequest.SetHeaderValue(sContentType, '');// Dont set content type
    end;
    Result := False;
  end;
end;

procedure TLinuxHTTPClient.DoServerCertificateAccepted(const ARequest: THTTPRequest);
var
  LRequest: TLinuxHTTPRequest;
begin
  inherited;
  LRequest := TLinuxHTTPRequest(ARequest);
  curl_easy_setopt(LRequest.FRequest, CURLOPT_SSL_VERIFYHOST, 0);
  curl_easy_setopt(LRequest.FRequest, CURLOPT_SSL_VERIFYPEER, 0);
end;

function TLinuxHTTPClient.DoSetCredential(AnAuthTargetType: TAuthTargetType; const ARequest: THTTPRequest;
  const ACredential: TCredentialsStorage.TCredential): Boolean;
var
  LRequest: TLinuxHTTPRequest;
begin
  LRequest := TLinuxHTTPRequest(ARequest);
  if AnAuthTargetType = TAuthTargetType.Server then
  begin
    curl_easy_setopt(LRequest.FRequest, CURLOPT_USERNAME, UTF8String(ACredential.UserName));
    curl_easy_setopt(LRequest.FRequest, CURLOPT_PASSWORD, UTF8String(ACredential.Password));
  end
  else
  begin
    curl_easy_setopt(LRequest.FRequest, CURLOPT_PROXYUSERNAME, UTF8String(ACredential.UserName));
    curl_easy_setopt(LRequest.FRequest, CURLOPT_PROXYPASSWORD, UTF8String(ACredential.Password));
  end;
  Result := True;
end;

function TLinuxHTTPClient.GetCertInfo(ACertData: PCurlCertInfo; var ACertificate: TCertificate): Boolean;
var
  LDataList: pcurl_slist;
  LData: string;
  LPos: Integer;
  LKey, LValue: string;

  function GetDateFromGMT: TDateTime;
  begin
    LValue := LValue.Replace(' ', 'T', []);
    LPos := LValue.IndexOf(' ');
    if LPos > 0 then
      LValue := LValue.Substring(0, LPos);
    TryISO8601ToDate(LValue, Result);
  end;

begin
  Result := False;
  LDataList := ACertData.certinfo^;
  if LDataList <> nil then
  begin
    Result := True;
    repeat
      LData := UTF8ToString(LDataList^.data);
      LPos := LData.IndexOf(':');
      LKey := LData.Substring(0, LPos);
      LValue := LData.Substring(LPos + 1);

      if SameText(LKey, 'Subject') then // do not localize
        ACertificate.Subject := LValue // do not localize
      else if SameText(LKey, 'Issuer') then // do not localize
        ACertificate.Issuer := LValue
      else if SameText(LKey, 'Expire date') then // do not localizev
        ACertificate.Expiry := GetDateFromGMT
      else if SameText(LKey, 'Start date') then // do not localize
        ACertificate.Start := GetDateFromGMT
      else if SameText(LKey, 'Signature Algorithm') then // do not localize
        ACertificate.AlgSignature := LValue;

      LDataList := LDataList^.next;
    until LDataList = nil;
  end;
end;

function TLinuxHTTPClient.GetServerCertInfoFromRequest(const ARequest: THTTPRequest; var ACertificate: TCertificate): Boolean;
var
  LClone: PCurl;
  LRequest: TLinuxHTTPRequest;
  LCode: TCURLcode;
  LCertData: PCurlCertInfo;
begin
  LRequest := TLinuxHTTPRequest(ARequest);
  LClone := curl_easy_duphandle(LRequest.FRequest);
  try
    { for getting the server certificate information, we need to }
    { disable the verification process. }
    curl_easy_setopt(LClone, CURLOPT_SSL_VERIFYHOST, 0);
    curl_easy_setopt(LClone, CURLOPT_SSL_VERIFYPEER, 0);
    curl_easy_setopt(LClone, CURLOPT_CUSTOMREQUEST, UTF8String(sHTTPMethodHead));
    curl_easy_setopt(LClone, CURLOPT_NOBODY, 1);

    curl_easy_perform(LClone);
    LCode := curl_easy_getinfo(LClone, CURLINFO_CERTINFO, @LCertData);
    if LCode = CURLE_OK then
      Result := GetCertInfo(LCertData, ACertificate)
    else
      raise ENetHTTPCertificateException.CreateRes(@SNetHttpCertificatesError);

  finally
    curl_easy_cleanup(LClone);
  end;
end;

{ TLinuxHTTPRequest }

                                                                                             
procedure TLinuxHTTPRequest.AddHeader(const AName, AValue: string);
const
  CDelims: array [Boolean] of Char = (',', ';');
var
  LCookie: Boolean;
  LList, LValues: TStringList;
  I: Integer;

  procedure TrimList(AList: TStrings);
  var
    I: Integer;
  begin
    for I := 0 to AList.Count - 1 do
      AList[I] := AList[I].Trim;
  end;

begin
  inherited;

  LCookie := SameText(AName, sCookie);

  LList := TStringList.Create(#0, CDelims[LCookie], [soStrictDelimiter, soUseLocale]);
  LList.CaseSensitive := False;
  LValues := TStringList.Create(#0, CDelims[LCookie], [soStrictDelimiter, soUseLocale]);
  try
    LList.DelimitedText := GetHeaderValue(AName);
    TrimList(LList);

    LValues.DelimitedText := AValue;
    TrimList(LValues);
    for I := 0 to LValues.Count - 1 do
      if LCookie and (LValues.Names[I] <> '') then
        LList.Values[LValues.Names[I]] := LValues.ValueFromIndex[I]
      else if (LValues[I] <> '') and (LList.IndexOf(LValues[I]) = -1) then
        LList.Add(LValues[I]);

    SetHeaderValue(AName, LList.DelimitedText);
  finally
    LList.Free;
    LValues.Free;
  end;
end;

constructor TLinuxHTTPRequest.Create(const AClient: THTTPClient; const ARequestMethod: string; const AURI: TURI);
begin
  inherited Create(AClient, ARequestMethod, AURI);
  FHeaders := TDictionary<string, string>.Create;
  InitRequest;
end;

destructor TLinuxHTTPRequest.Destroy;
begin
  CleanupRequest;
  FHeaders.Free;
  if FTempFileName <> '' then
    TFile.Delete(FTempFileName);
  inherited Destroy;
end;

procedure TLinuxHTTPRequest.InitRequest;
begin
  FRequest := curl_easy_init;
  { Setup common options for LibCurl }
  curl_easy_setopt(FRequest, CURLOPT_WRITEFUNCTION, @CurlReadData);
  curl_easy_setopt(FRequest, CURLOPT_WRITEDATA, Self);
  curl_easy_setopt(FRequest, CURLOPT_HEADERFUNCTION, @CurlReadHeaders);
  curl_easy_setopt(FRequest, CURLOPT_HEADERDATA, Self);
  curl_easy_setopt(FRequest, CURLOPT_CERTINFO, 1);
  curl_easy_setopt(FRequest, CURLOPT_TCP_KEEPALIVE, 1);
  curl_easy_setopt(FRequest, CURLOPT_NOPROGRESS, 1);
  curl_easy_setopt(FRequest, CURLOPT_ERRORBUFFER, @FErrorBuff[0]);
end;

procedure TLinuxHTTPRequest.CleanupRequest;
begin
  if FRequest <> nil then
  begin
    curl_easy_cleanup(FRequest);
    FRequest := nil;
  end;
end;

class function TLinuxHTTPRequest.CurlReadData(buffer: Pointer; size, nitems: size_t;
  instream: Pointer): size_t;
begin
  if instream <> nil then
    Result := TLinuxHTTPRequest(instream).FResponse.ReceiveData(buffer, size, nitems)
  else
    Result := 0;
end;

class function TLinuxHTTPRequest.CurlReadHeaders(buffer: Pointer; size: size_t; nitems: size_t; instream: Pointer): size_t;
begin
  if instream <> nil then
    Result := TLinuxHTTPRequest(instream).FResponse.ReceiveHeader(buffer, size, nitems)
  else
    Result := 0;
end;

class function TLinuxHTTPRequest.CurlWriteData(buffer: Pointer; size, nitems: size_t; instream: Pointer): size_t;
begin
  if instream <> nil then
    Result := TLinuxHTTPRequest(instream).FResponse.SendData(buffer, size, nitems)
  else
    Result := 0;
end;

procedure TLinuxHTTPRequest.DoPrepare;
var
  LTmpFile: TFileStream;
begin
  inherited;
  if (FLastMethodString <> '') and not SameText(FLastMethodString, FMethodString) then
  begin
    CleanupRequest;
    InitRequest;
  end;
  FLastMethodString := FMethodString;

  curl_easy_setopt(FRequest, CURLOPT_URL, UTF8String(FURL.ToString));
  if FURL.Username <> '' then
  begin
    SetCredential(TCredentialsStorage.TCredential.Create(TAuthTargetType.Server, '', FURL.ToString,
      FURL.Username, FURL.Password));
    curl_easy_setopt(FRequest, CURLOPT_USERNAME, UTF8String(FURL.Username));
    curl_easy_setopt(FRequest, CURLOPT_PASSWORD, UTF8String(FURL.Password));
  end;

  if FClient.ProxySettings.Host <> '' then
  begin
    curl_easy_setopt(FRequest, CURLOPT_PROXY, UTF8String(FClient.ProxySettings.Host));
    if FClient.ProxySettings.Port > 0 then
      curl_easy_setopt(FRequest, CURLOPT_PROXYPORT, FClient.ProxySettings.Port);
  end;

  if FClientCertPath <> '' then
  begin
    if ExtractFileExt(FClientCertPath).ToLower = 'p12' then
      curl_easy_setopt(FRequest, CURLOPT_SSLCERTTYPE, UTF8String('P12'))
    else
      curl_easy_setopt(FRequest, CURLOPT_SSLCERTTYPE, UTF8String('PEM'));

    if curl_easy_setopt(FRequest, CURLOPT_SSLCERT, UTF8String(FClientCertPath)) <> CURLE_OK then
      raise ENetHTTPCertificateException.CreateRes(@SNetHttpCertificateImportError);
  end
  else
  begin
    if FClientCertificate <> nil then
    begin
      FTempFileName := TPath.GetTempFileName + '.pem';
      LTmpFile := TFileStream.Create(FTempFileName, fmCreate, S_IRUSR);
      try
        FClientCertificate.Position := 0;
        LTmpFile.CopyFrom(FClientCertificate, FClientCertificate.Size);
      finally
        LTmpFile.Free;
      end;

      curl_easy_setopt(FRequest, CURLOPT_SSLCERTTYPE, UTF8String('PEM'));
      if curl_easy_setopt(FRequest, CURLOPT_SSLCERT, UTF8String(FTempFileName)) <> CURLE_OK then
        raise ENetHTTPCertificateException.CreateRes(@SNetHttpCertificateImportError);
    end;
  end;

  if FClientCertPassword <> '' then
    curl_easy_setopt(FRequest, CURLOPT_KEYPASSWD, UTF8String(FClientCertPath));

  { Handle request methods }
  case MethodStringToHTTPMethod(FMethodString) of
    THTTPRequestMethod.GET, THTTPRequestMethod.CONNECT,
    THTTPRequestMethod.OPTIONS, THTTPRequestMethod.TRACE,
    THTTPRequestMethod.MERGE, THTTPRequestMethod.PATCH,
    THTTPRequestMethod.DELETE, THTTPRequestMethod.others:
      curl_easy_setopt(FRequest, CURLOPT_CUSTOMREQUEST, PUTF8Char(UTF8String(FMethodString)) );

    THTTPRequestMethod.PUT:
    begin
      curl_easy_setopt(FRequest, CURLOPT_UPLOAD, 1);
      curl_easy_setopt(FRequest, CURLOPT_READFUNCTION, @CurlWriteData);
      curl_easy_setopt(FRequest, CURLOPT_READDATA, Self);
    end;

    THTTPRequestMethod.HEAD:
    begin
      curl_easy_setopt(FRequest, CURLOPT_CUSTOMREQUEST, UTF8String(FMethodString));
      curl_easy_setopt(FRequest, CURLOPT_NOBODY, 1);
    end;

    THTTPRequestMethod.POST:
    begin
      curl_easy_setopt(FRequest, CURLOPT_POST, 1);
      curl_easy_setopt(FRequest, CURLOPT_READFUNCTION, @CurlWriteData);
      curl_easy_setopt(FRequest, CURLOPT_READDATA, Self);
    end;
  end;
end;

function TLinuxHTTPRequest.GetHeaders: TNetHeaders;
var
  Value: TPair<string, string>;
  CntHeader: Integer;
begin
  SetLength(Result, 500); // Max 500 headers
  CntHeader := 0;
  for Value in FHeaders do
  begin
    Result[CntHeader].Create(Value.Key, Value.Value);
    Inc(CntHeader);
  end;
  SetLength(Result, CntHeader);
end;

function TLinuxHTTPRequest.GetHeaderValue(const AName: string): string;
begin
  Result := '';
  FHeaders.TryGetValue(AName, Result);
end;

function TLinuxHTTPRequest.RemoveHeader(const AName: string): Boolean;
begin
  Result := True;
  if GetHeaderValue(AName) = '' then
    Result := False
  else
    FHeaders.Remove(AName);
end;

procedure TLinuxHTTPRequest.SetHeaderValue(const AName, Value: string);
begin
  inherited;
  FHeaders.AddOrSetValue(AName, Value);
end;

{ TLinuxHTTPResponse }

constructor TLinuxHTTPResponse.Create(const AContext: TObject; const AProc: TProc; const AAsyncCallback: TAsyncCallback;
  const AAsyncCallbackEvent: TAsyncCallbackEvent; const ARequest: TLinuxHTTPRequest; const AContentStream: TStream);
begin
  inherited Create(AContext, AProc, AAsyncCallback, AAsyncCallbackEvent, ARequest, AContentStream);
  FRequest := ARequest;
  FRequest.FResponse := Self;
  FNativeHeaders := TStringList.Create;
end;

destructor TLinuxHTTPResponse.Destroy;
begin
  FNativeHeaders.Free;
  inherited;
end;

procedure TLinuxHTTPResponse.DoReadData(const AStream: TStream);
begin
  inherited;
  // Do nothing
end;

function TLinuxHTTPResponse.GetHeaders: TNetHeaders;
var
  I, P: Integer;
  LPos: Integer;
  LName: string;
  LValue: string;

  procedure AddOrSetHeader;
  var
    J: Integer;
  begin
    for J := 0 to P - 1 do
    begin
      if SameText(FHeaders[J].Name, LName) then
      begin
        FHeaders[J].Value := FHeaders[J].Value + ', ' + LValue;
        Exit;
      end;
    end;
    FHeaders[P].Create(LName, LValue);
    Inc(P);
  end;

begin
  if Length(FHeaders) = 0 then
  begin
    SetLength(FHeaders, FNativeHeaders.Count);
    P := 0;
    for I := 0 to FNativeHeaders.Count - 1 do
    begin
      LPos := FNativeHeaders[I].IndexOf(':');
      LName := FNativeHeaders[I].Substring(0, LPos);
      LValue := FNativeHeaders[I].Substring(LPos + 1).Trim;
      if SameText(LName, sSetCookie) then
        InternalAddCookie(LValue)
      else
        AddOrSetHeader;
    end;
    SetLength(Result, P);
  end;
  Result := FHeaders;
end;

function TLinuxHTTPResponse.GetStatusCode: Integer;
begin
  TryStrToInt(FNativeStatusCode, Result);
end;

function TLinuxHTTPResponse.GetStatusText: string;
begin
  Result := FNativeStatusLine;
end;

function TLinuxHTTPResponse.GetVersion: THTTPProtocolVersion;
var
  LVersion: string;
  LValues: TArray<string>;
begin
  if FNativeStatusLine <> '' then
  begin
    LValues := FNativeStatusLine.Split([' ']);
    LVersion := LValues[0];
    if string.CompareText(LVersion, 'HTTP/1.0') = 0 then
      Result := THTTPProtocolVersion.HTTP_1_0
    else if string.CompareText(LVersion, 'HTTP/1.1') = 0 then
      Result := THTTPProtocolVersion.HTTP_1_1
    else if string.CompareText(LVersion, 'HTTP/2.0') = 0 then
      Result := THTTPProtocolVersion.HTTP_2_0
    else
      Result := THTTPProtocolVersion.UNKNOWN_HTTP;
  end
  else
    Result := THTTPProtocolVersion.UNKNOWN_HTTP;
end;

function TLinuxHTTPResponse.ReceiveData(buffer: Pointer; size, nitems: size_t): size_t;
var
  LAbort: Boolean;
  LContentLength: Int64;
  LStatusCode: Integer;
  LTotal: Integer;

  function GetEarlyStatusCode: Integer;
  var
    LTmp: TArray<string>;
  begin
    Result := GetStatusCode;
    if Result = 0 then
    begin
      LTmp := FNativeStatusLine.Split([' ']);
      if Length(LTmp) > 2 then
      begin
        FNativeStatusCode := LTmp[1];
        Result := GetStatusCode;
      end;
    end;
  end;

begin
  LAbort := False;
  LTotal := nitems * size;
  Inc(FTotalRead, LTotal);
  LContentLength := GetContentLength;
  LStatusCode := GetEarlyStatusCode;
  FRequest.DoReceiveDataProgress(LStatusCode, LContentLength, FTotalRead, LAbort);
  if not LAbort then
    Result := FStream.Write(buffer^, LTotal)
  else
    Result := 0
end;

function TLinuxHTTPResponse.ReceiveHeader(buffer: Pointer; size, nitems: size_t): size_t;
var
  LHeader: string;
  LPos: Integer;
begin
  LHeader := UTF8ToString(buffer).Trim;
  LPos := LHeader.IndexOf(':');
  if LPos > 0 then
    FNativeHeaders.Add(LHeader)
  else
    if LHeader <> '' then
      FNativeStatusLine := LHeader;

  Result := size * nitems;
end;

function TLinuxHTTPResponse.SendData(buffer: Pointer; size, nitems: size_t): size_t;
begin
  if LeftToSend > 0 then
  begin
    Result := FRequest.FSourceStream.Read(buffer^, size * nitems);
    Dec(LeftToSend, Result);
  end
  else
    Result := 0;
end;

initialization
  TURLSchemes.RegisterURLClientScheme(TLinuxHTTPClient, 'HTTP');
  TURLSchemes.RegisterURLClientScheme(TLinuxHTTPClient, 'HTTPS');

finalization
  TURLSchemes.UnRegisterURLClientScheme('HTTP');
  TURLSchemes.UnRegisterURLClientScheme('HTTPS');
end.
