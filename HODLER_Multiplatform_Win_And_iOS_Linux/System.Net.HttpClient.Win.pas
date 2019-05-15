{*******************************************************}
{                                                       }
{           CodeGear Delphi Runtime Library             }
{ Copyright(c) 2014-2017 Embarcadero Technologies, Inc. }
{              All rights reserved                      }
{                                                       }
{*******************************************************}

unit System.Net.HttpClient.Win;

interface

{$HPPEMIT NOUSINGNAMESPACE}

{$HPPEMIT '#pragma comment(lib, "winhttp")'}
{$HPPEMIT '#pragma comment(lib, "crypt32")'}

implementation

uses
  System.SysUtils,
  System.Classes,
  System.Generics.Collections,
  System.Net.URLClient,
  System.NetConsts,
  System.Net.HttpClient,
  System.Types,
  Winapi.Windows,
  Winapi.WinHTTP;

{ Crypto functions needed }
type
  HCRYPTPROV = ULONG_PTR;
  {$EXTERNALSYM HCRYPTPROV}

  _CRYPTOAPI_BLOB = record
    cbData: DWORD;
    pbData: LPBYTE;
  end;
  {$EXTERNALSYM _CRYPTOAPI_BLOB}
  CRYPT_INTEGER_BLOB = _CRYPTOAPI_BLOB;
  {$EXTERNALSYM CRYPT_INTEGER_BLOB}
  PCRYPT_INTEGER_BLOB = ^_CRYPTOAPI_BLOB;
  {$EXTERNALSYM PCRYPT_INTEGER_BLOB}
  CRYPT_OBJID_BLOB = _CRYPTOAPI_BLOB;
  {$EXTERNALSYM CRYPT_OBJID_BLOB}
  CERT_NAME_BLOB = _CRYPTOAPI_BLOB;
  {$EXTERNALSYM CERT_NAME_BLOB}
  PCERT_NAME_BLOB = ^CERT_NAME_BLOB;
  {$EXTERNALSYM PCERT_NAME_BLOB}

  PCRYPT_BIT_BLOB = ^CRYPT_BIT_BLOB;
  {$EXTERNALSYM PCRYPT_BIT_BLOB}
  _CRYPT_BIT_BLOB = record
    cbData: DWORD;
    pbData: LPBYTE;
    cUnusedBits: DWORD;
  end;
  {$EXTERNALSYM _CRYPT_BIT_BLOB}
  CRYPT_BIT_BLOB = _CRYPT_BIT_BLOB;
  {$EXTERNALSYM CRYPT_BIT_BLOB}

  PCRYPT_ALGORITHM_IDENTIFIER = ^CRYPT_ALGORITHM_IDENTIFIER;
  {$EXTERNALSYM PCRYPT_ALGORITHM_IDENTIFIER}
  _CRYPT_ALGORITHM_IDENTIFIER = record
    pszObjId: LPSTR;
    Parameters: CRYPT_OBJID_BLOB;
  end;
  {$EXTERNALSYM _CRYPT_ALGORITHM_IDENTIFIER}
  CRYPT_ALGORITHM_IDENTIFIER = _CRYPT_ALGORITHM_IDENTIFIER;
  {$EXTERNALSYM CRYPT_ALGORITHM_IDENTIFIER}

  PCERT_PUBLIC_KEY_INFO = ^CERT_PUBLIC_KEY_INFO;
  {$EXTERNALSYM PCERT_PUBLIC_KEY_INFO}
  _CERT_PUBLIC_KEY_INFO = record
    Algorithm: CRYPT_ALGORITHM_IDENTIFIER;
    PublicKey: CRYPT_BIT_BLOB;
  end;
  {$EXTERNALSYM _CERT_PUBLIC_KEY_INFO}
  CERT_PUBLIC_KEY_INFO = _CERT_PUBLIC_KEY_INFO;
  {$EXTERNALSYM CERT_PUBLIC_KEY_INFO}

  PCERT_EXTENSION = ^CERT_EXTENSION;
  {$EXTERNALSYM PCERT_EXTENSION}
  _CERT_EXTENSION = record
    pszObjId: LPSTR;
    fCritical: BOOL;
    Value: CRYPT_OBJID_BLOB;
  end;
  {$EXTERNALSYM _CERT_EXTENSION}
  CERT_EXTENSION = _CERT_EXTENSION;
  {$EXTERNALSYM CERT_EXTENSION}


  PCERT_INFO = ^CERT_INFO;
  {$EXTERNALSYM PCERT_INFO}
  _CERT_INFO = record
    dwVersion: DWORD;
    SerialNumber: CRYPT_INTEGER_BLOB;
    SignatureAlgorithm: CRYPT_ALGORITHM_IDENTIFIER;
    Issuer: CERT_NAME_BLOB;
    NotBefore: FILETIME;
    NotAfter: FILETIME;
    Subject: CERT_NAME_BLOB;
    SubjectPublicKeyInfo: CERT_PUBLIC_KEY_INFO;
    IssuerUniqueId: CRYPT_BIT_BLOB;
    SubjectUniqueId: CRYPT_BIT_BLOB;
    cExtension: DWORD;
    rgExtension: PCERT_EXTENSION;
  end;
  {$EXTERNALSYM _CERT_INFO}
  CERT_INFO = _CERT_INFO;
  {$EXTERNALSYM CERT_INFO}


  HCERTSTORE = Pointer;
  {$EXTERNALSYM HCERTSTORE}
  PCERT_CONTEXT = ^CERT_CONTEXT;

  {$EXTERNALSYM PCERT_CONTEXT}
  _CERT_CONTEXT = record
    dwCertEncodingType: DWORD;
    pbCertEncoded: LPBYTE;
    cbCertEncoded: DWORD;
    pCertInfo: PCERT_INFO;
    hCertStore: HCERTSTORE;
  end;
  {$EXTERNALSYM _CERT_CONTEXT}
  CERT_CONTEXT = _CERT_CONTEXT;
  {$EXTERNALSYM CERT_CONTEXT}
  PCCERT_CONTEXT = PCERT_CONTEXT;
  {$EXTERNALSYM PCCERT_CONTEXT}

const
  Crypt32 = 'Crypt32.dll';

  CERT_CHAIN_FIND_BY_ISSUER_COMPARE_KEY_FLAG         = $0001;
  CERT_CHAIN_FIND_BY_ISSUER_COMPLEX_CHAIN_FLAG       = $0002;
  CERT_CHAIN_FIND_BY_ISSUER_CACHE_ONLY_URL_FLAG      = $0004;
  CERT_CHAIN_FIND_BY_ISSUER_LOCAL_MACHINE_FLAG       = $0008;
  CERT_CHAIN_FIND_BY_ISSUER_NO_KEY_FLAG              = $4000;
  CERT_CHAIN_FIND_BY_ISSUER_CACHE_ONLY_FLAG          = $8000;

  CERT_CHAIN_FIND_BY_ISSUER              = 1;

  CERT_INFO_VERSION_FLAG                 = 1;
  {$EXTERNALSYM CERT_INFO_VERSION_FLAG}
  CERT_INFO_SERIAL_NUMBER_FLAG           = 2;
  {$EXTERNALSYM CERT_INFO_SERIAL_NUMBER_FLAG}
  CERT_INFO_SIGNATURE_ALGORITHM_FLAG     = 3;
  {$EXTERNALSYM CERT_INFO_SIGNATURE_ALGORITHM_FLAG}
  CERT_INFO_ISSUER_FLAG                  = 4;
  {$EXTERNALSYM CERT_INFO_ISSUER_FLAG}
  CERT_INFO_NOT_BEFORE_FLAG              = 5;
  {$EXTERNALSYM CERT_INFO_NOT_BEFORE_FLAG}
  CERT_INFO_NOT_AFTER_FLAG               = 6;
  {$EXTERNALSYM CERT_INFO_NOT_AFTER_FLAG}
  CERT_INFO_SUBJECT_FLAG                 = 7;
  {$EXTERNALSYM CERT_INFO_SUBJECT_FLAG}
  CERT_INFO_SUBJECT_PUBLIC_KEY_INFO_FLAG = 8;
  {$EXTERNALSYM CERT_INFO_SUBJECT_PUBLIC_KEY_INFO_FLAG}
  CERT_INFO_ISSUER_UNIQUE_ID_FLAG        = 9;
  {$EXTERNALSYM CERT_INFO_ISSUER_UNIQUE_ID_FLAG}
  CERT_INFO_SUBJECT_UNIQUE_ID_FLAG       = 10;
  {$EXTERNALSYM CERT_INFO_SUBJECT_UNIQUE_ID_FLAG}
  CERT_INFO_EXTENSION_FLAG               = 11;
  {$EXTERNALSYM CERT_INFO_EXTENSION_FLAG}
  CERT_COMPARE_MASK           = $FFFF;
  {$EXTERNALSYM CERT_COMPARE_MASK}
  CERT_COMPARE_SHIFT          = 16;
  {$EXTERNALSYM CERT_COMPARE_SHIFT}
  CERT_COMPARE_ANY            = 0;
  {$EXTERNALSYM CERT_COMPARE_ANY}
  CERT_COMPARE_SHA1_HASH      = 1;
  {$EXTERNALSYM CERT_COMPARE_SHA1_HASH}
  CERT_COMPARE_NAME           = 2;
  {$EXTERNALSYM CERT_COMPARE_NAME}
  CERT_COMPARE_ATTR           = 3;
  {$EXTERNALSYM CERT_COMPARE_ATTR}
  CERT_COMPARE_MD5_HASH       = 4;
  {$EXTERNALSYM CERT_COMPARE_MD5_HASH}
  CERT_COMPARE_PROPERTY       = 5;
  {$EXTERNALSYM CERT_COMPARE_PROPERTY}
  CERT_COMPARE_PUBLIC_KEY     = 6;
  {$EXTERNALSYM CERT_COMPARE_PUBLIC_KEY}
  CERT_COMPARE_HASH           = CERT_COMPARE_SHA1_HASH;
  {$EXTERNALSYM CERT_COMPARE_HASH}
  CERT_COMPARE_NAME_STR_A     = 7;
  {$EXTERNALSYM CERT_COMPARE_NAME_STR_A}
  CERT_COMPARE_NAME_STR_W     = 8;
  {$EXTERNALSYM CERT_COMPARE_NAME_STR_W}
  CERT_COMPARE_KEY_SPEC       = 9;
  {$EXTERNALSYM CERT_COMPARE_KEY_SPEC}
  CERT_COMPARE_ENHKEY_USAGE   = 10;
  {$EXTERNALSYM CERT_COMPARE_ENHKEY_USAGE}
  CERT_COMPARE_CTL_USAGE      = CERT_COMPARE_ENHKEY_USAGE;
  {$EXTERNALSYM CERT_COMPARE_CTL_USAGE}
  CERT_COMPARE_SUBJECT_CERT   = 11;
  {$EXTERNALSYM CERT_COMPARE_SUBJECT_CERT}
  CERT_COMPARE_ISSUER_OF      = 12;
  {$EXTERNALSYM CERT_COMPARE_ISSUER_OF}
  CERT_COMPARE_EXISTING       = 13;
  {$EXTERNALSYM CERT_COMPARE_EXISTING}
  CERT_COMPARE_SIGNATURE_HASH = 14;
  {$EXTERNALSYM CERT_COMPARE_SIGNATURE_HASH}
  CERT_COMPARE_KEY_IDENTIFIER = 15;
  {$EXTERNALSYM CERT_COMPARE_KEY_IDENTIFIER}
  CERT_COMPARE_CERT_ID        = 16;
  {$EXTERNALSYM CERT_COMPARE_CERT_ID}
  CERT_FIND_ANY            = CERT_COMPARE_ANY shl CERT_COMPARE_SHIFT;
  {$EXTERNALSYM CERT_FIND_ANY}
  CERT_FIND_SHA1_HASH      = CERT_COMPARE_SHA1_HASH shl CERT_COMPARE_SHIFT;
  {$EXTERNALSYM CERT_FIND_SHA1_HASH}
  CERT_FIND_MD5_HASH       = CERT_COMPARE_MD5_HASH shl CERT_COMPARE_SHIFT;
  {$EXTERNALSYM CERT_FIND_MD5_HASH}
  CERT_FIND_SIGNATURE_HASH = CERT_COMPARE_SIGNATURE_HASH shl CERT_COMPARE_SHIFT;
  {$EXTERNALSYM CERT_FIND_SIGNATURE_HASH}
  CERT_FIND_KEY_IDENTIFIER = CERT_COMPARE_KEY_IDENTIFIER shl CERT_COMPARE_SHIFT;
  {$EXTERNALSYM CERT_FIND_KEY_IDENTIFIER}
  CERT_FIND_HASH           = CERT_FIND_SHA1_HASH;
  {$EXTERNALSYM CERT_FIND_HASH}
  CERT_FIND_PROPERTY       = CERT_COMPARE_PROPERTY shl CERT_COMPARE_SHIFT;
  {$EXTERNALSYM CERT_FIND_PROPERTY}
  CERT_FIND_PUBLIC_KEY     = CERT_COMPARE_PUBLIC_KEY shl CERT_COMPARE_SHIFT;
  {$EXTERNALSYM CERT_FIND_PUBLIC_KEY}
  CERT_FIND_SUBJECT_NAME   = CERT_COMPARE_NAME shl CERT_COMPARE_SHIFT or CERT_INFO_SUBJECT_FLAG;
  {$EXTERNALSYM CERT_FIND_SUBJECT_NAME}
  CERT_FIND_SUBJECT_ATTR   = CERT_COMPARE_ATTR shl CERT_COMPARE_SHIFT or CERT_INFO_SUBJECT_FLAG;
  {$EXTERNALSYM CERT_FIND_SUBJECT_ATTR}
  CERT_FIND_ISSUER_NAME    = CERT_COMPARE_NAME shl CERT_COMPARE_SHIFT or CERT_INFO_ISSUER_FLAG;
  {$EXTERNALSYM CERT_FIND_ISSUER_NAME}
  CERT_FIND_ISSUER_ATTR    = CERT_COMPARE_ATTR shl CERT_COMPARE_SHIFT or CERT_INFO_ISSUER_FLAG;
  {$EXTERNALSYM CERT_FIND_ISSUER_ATTR}
  CERT_FIND_SUBJECT_STR_A  = CERT_COMPARE_NAME_STR_A shl CERT_COMPARE_SHIFT or CERT_INFO_SUBJECT_FLAG;
  {$EXTERNALSYM CERT_FIND_SUBJECT_STR_A}
  CERT_FIND_SUBJECT_STR_W  = CERT_COMPARE_NAME_STR_W shl CERT_COMPARE_SHIFT or CERT_INFO_SUBJECT_FLAG;
  {$EXTERNALSYM CERT_FIND_SUBJECT_STR_W}
  CERT_FIND_SUBJECT_STR    = CERT_FIND_SUBJECT_STR_W;
  {$EXTERNALSYM CERT_FIND_SUBJECT_STR}
  CERT_FIND_ISSUER_STR_A   = CERT_COMPARE_NAME_STR_A shl CERT_COMPARE_SHIFT or CERT_INFO_ISSUER_FLAG;
  {$EXTERNALSYM CERT_FIND_ISSUER_STR_A}
  CERT_FIND_ISSUER_STR_W   = CERT_COMPARE_NAME_STR_W shl CERT_COMPARE_SHIFT or CERT_INFO_ISSUER_FLAG;
  {$EXTERNALSYM CERT_FIND_ISSUER_STR_W}
  CERT_FIND_ISSUER_STR     = CERT_FIND_ISSUER_STR_W;
  {$EXTERNALSYM CERT_FIND_ISSUER_STR}
  CERT_FIND_KEY_SPEC       = CERT_COMPARE_KEY_SPEC shl CERT_COMPARE_SHIFT;
  {$EXTERNALSYM CERT_FIND_KEY_SPEC}
  CERT_FIND_ENHKEY_USAGE   = CERT_COMPARE_ENHKEY_USAGE shl CERT_COMPARE_SHIFT;
  {$EXTERNALSYM CERT_FIND_ENHKEY_USAGE}
  CERT_FIND_CTL_USAGE      = CERT_FIND_ENHKEY_USAGE;
  {$EXTERNALSYM CERT_FIND_CTL_USAGE}

  CERT_FIND_SUBJECT_CERT = CERT_COMPARE_SUBJECT_CERT shl CERT_COMPARE_SHIFT;
  {$EXTERNALSYM CERT_FIND_SUBJECT_CERT}
  CERT_FIND_ISSUER_OF    = CERT_COMPARE_ISSUER_OF shl CERT_COMPARE_SHIFT;
  {$EXTERNALSYM CERT_FIND_ISSUER_OF}
  CERT_FIND_EXISTING     = CERT_COMPARE_EXISTING shl CERT_COMPARE_SHIFT;
  {$EXTERNALSYM CERT_FIND_EXISTING}
  CERT_FIND_CERT_ID      = CERT_COMPARE_CERT_ID shl CERT_COMPARE_SHIFT;
  {$EXTERNALSYM CERT_FIND_CERT_ID}

  CRYPT_ASN_ENCODING  = $00000001;
  {$EXTERNALSYM CRYPT_ASN_ENCODING}
  CRYPT_NDR_ENCODING  = $00000002;
  {$EXTERNALSYM CRYPT_NDR_ENCODING}
  X509_ASN_ENCODING   = $00000001;
  {$EXTERNALSYM X509_ASN_ENCODING}
  X509_NDR_ENCODING   = $00000002;
  {$EXTERNALSYM X509_NDR_ENCODING}
  PKCS_7_ASN_ENCODING = $00010000;
  {$EXTERNALSYM PKCS_7_ASN_ENCODING}
  PKCS_7_NDR_ENCODING = $00020000;
  {$EXTERNALSYM PKCS_7_NDR_ENCODING}

  CERT_SIMPLE_NAME_STR = 1;
  {$EXTERNALSYM CERT_SIMPLE_NAME_STR}

  CERT_NAME_STR_CRLF_FLAG = $08000000;
  {$EXTERNALSYM CERT_NAME_STR_CRLF_FLAG}

type
  _SecPkgContext_IssuerListInfoEx = record
    aIssuers: PCERT_NAME_BLOB;
    cIssuers: DWORD;
  end;
  {$EXTERNALSYM _SecPkgContext_IssuerListInfoEx}
  SecPkgContext_IssuerListInfoEx = _SecPkgContext_IssuerListInfoEx;
  {$EXTERNALSYM SecPkgContext_IssuerListInfoEx}
  PSecPkgContext_IssuerListInfoEx = ^SecPkgContext_IssuerListInfoEx;
  {$EXTERNALSYM PSecPkgContext_IssuerListInfoEx}

  _CERT_TRUST_STATUS = record
    dwErrorStatus: DWORD;
    dwInfoStatus: DWORD;
  end;
  {$EXTERNALSYM _CERT_TRUST_STATUS}
  CERT_TRUST_STATUS = _CERT_TRUST_STATUS;
  {$EXTERNALSYM CERT_TRUST_STATUS}
  PCERT_TRUST_STATUS = ^_CERT_TRUST_STATUS;
  {$EXTERNALSYM PCERT_TRUST_STATUS}


  _CERT_CHAIN_ELEMENT = record
    cbSize: DWORD;
    pCertContext: PCCERT_CONTEXT;
    TrustStatus: CERT_TRUST_STATUS;
    pRevocationInfo: Pointer;//    pRevocationInfo: PCERT_REVOCATION_INFO;
    pIssuanceUsage: Pointer;//    pIssuanceUsage: PCERT_ENHKEY_USAGE;
    pApplicationUsage: Pointer;//    pApplicationUsage: PCERT_ENHKEY_USAGE;
    pwszExtendedErrorInfo: LPCWSTR;
  end;
  {$EXTERNALSYM _CERT_CHAIN_ELEMENT}
  CERT_CHAIN_ELEMENT = _CERT_CHAIN_ELEMENT;
  {$EXTERNALSYM CERT_CHAIN_ELEMENT}
  PCERT_CHAIN_ELEMENT = ^_CERT_CHAIN_ELEMENT;
  {$EXTERNALSYM PCERT_CHAIN_ELEMENT}
  PPCERT_CHAIN_ELEMENT = ^PCERT_CHAIN_ELEMENT;

  _CERT_SIMPLE_CHAIN = record
    cbSize: DWORD;
    TrustStatus: CERT_TRUST_STATUS;
    cElement: DWORD;
    rgpElement: PPCERT_CHAIN_ELEMENT;
    pTrustListInfo: Pointer;//pTrustListInfo: PCERT_TRUST_LIST_INFO;
    fHasRevocationFreshnessTime: BOOL;
    dwRevocationFreshnessTime: DWORD;
  end;
  {$EXTERNALSYM _CERT_SIMPLE_CHAIN}
  CERT_SIMPLE_CHAIN = _CERT_SIMPLE_CHAIN;
  {$EXTERNALSYM CERT_SIMPLE_CHAIN}
  PCERT_SIMPLE_CHAIN = ^_CERT_SIMPLE_CHAIN;
  {$EXTERNALSYM PCERT_SIMPLE_CHAIN}
  PPCERT_SIMPLE_CHAIN = ^PCERT_SIMPLE_CHAIN;


  PCCERT_CHAIN_CONTEXT = ^_CERT_CHAIN_CONTEXT;
  {$EXTERNALSYM PCCERT_CHAIN_CONTEXT}
  PPCCERT_CHAIN_CONTEXT = ^PCCERT_CHAIN_CONTEXT;
  _CERT_CHAIN_CONTEXT = record
    cbSize: DWORD;
    TrustStatus: CERT_TRUST_STATUS;
    cChain: DWORD;
    rgpChain: PPCERT_SIMPLE_CHAIN;
    cLowerQualityChainContext: DWORD;
    rgpLowerQualityChainContext: PPCCERT_CHAIN_CONTEXT;
    fHasRevocationFreshnessTime: BOOL;
    dwRevocationFreshnessTime: DWORD;
  end;
  {$EXTERNALSYM _CERT_CHAIN_CONTEXT}
  CERT_CHAIN_CONTEXT = _CERT_CHAIN_CONTEXT;
  {$EXTERNALSYM CERT_CHAIN_CONTEXT}

  PFN_CERT_CHAIN_FIND_BY_ISSUER_CALLBACK = procedure;

  _CERT_CHAIN_FIND_BY_ISSUER_PARA = record
    cbSize: DWORD;
    pszUsageIdentifier: LPCSTR;
    dwKeySpec: DWORD;
    dwAcquirePrivateKeyFlags: DWORD;
    cIssuer: DWORD;
    rgIssuer: PCERT_NAME_BLOB;
    pfnFindCallback: PFN_CERT_CHAIN_FIND_BY_ISSUER_CALLBACK;
    pvFindArg: Pointer;
    pdwIssuerChainIndex: PDWORD;
    pdwIssuerElementIndex: PDWORD;
  end;
  {$EXTERNALSYM _CERT_CHAIN_FIND_BY_ISSUER_PARA}
  CERT_CHAIN_FIND_BY_ISSUER_PARA = _CERT_CHAIN_FIND_BY_ISSUER_PARA;
  {$EXTERNALSYM CERT_CHAIN_FIND_BY_ISSUER_PARA}
  PCERT_CHAIN_FIND_BY_ISSUER_PARA = ^CERT_CHAIN_FIND_BY_ISSUER_PARA;
  {$EXTERNALSYM PCERT_CHAIN_FIND_BY_ISSUER_PARA}


{$WARN SYMBOL_PLATFORM OFF}

function CertFindCertificateInStore(hCertStore: HCERTSTORE;
  dwCertEncodingType, dwFindFlags, dwFindType: DWORD; pvFindPara: Pointer;
  pPrevCertContext: PCCERT_CONTEXT): PCCERT_CONTEXT; stdcall; external Crypt32 name 'CertFindCertificateInStore' delayed;
{$EXTERNALSYM CertFindCertificateInStore}


function CertFindChainInStore(hCertStore: HCERTSTORE;
  dwCertEncodingType, dwFindFlags, dwFindType: DWORD; pvFindPara: Pointer;
  pPrevChainContext: PCCERT_CHAIN_CONTEXT): PCCERT_CHAIN_CONTEXT; stdcall; external Crypt32 name 'CertFindChainInStore' delayed;
{$EXTERNALSYM CertFindChainInStore}

function CertOpenSystemStore(hProv: HCRYPTPROV; szSubsystemProtocol: LPCTSTR): HCERTSTORE; stdcall; external Crypt32 name 'CertOpenSystemStoreW' delayed;
{$EXTERNALSYM CertOpenSystemStore}

function CertCloseStore(hCertStore: HCERTSTORE; dwFlags: DWORD): BOOL; stdcall; external Crypt32 name 'CertCloseStore' delayed;
{$EXTERNALSYM CertCloseStore}

procedure CertFreeCertificateChain(pChainContext: PCCERT_CHAIN_CONTEXT); stdcall; external Crypt32 name 'CertFreeCertificateChain' delayed;
{$EXTERNALSYM CertFreeCertificateChain}

function CertDuplicateCertificateContext(pCertContext: PCCERT_CONTEXT): PCCERT_CONTEXT; stdcall; external Crypt32 name 'CertDuplicateCertificateContext' delayed;
{$EXTERNALSYM CertDuplicateCertificateContext}

function CertFreeCertificateContext(pCertContext: PCCERT_CONTEXT): BOOL; stdcall; external Crypt32 name 'CertFreeCertificateContext' delayed;
{$EXTERNALSYM CertFreeCertificateContext}

function CertNameToStr(dwCertEncodingType: DWORD; pName: PCERT_NAME_BLOB; dwStrType: DWORD; psz: LPTSTR;
  csz: DWORD): DWORD; stdcall; external Crypt32 name 'CertNameToStrW' delayed;
{$EXTERNALSYM CertNameToStr}

{$WARN SYMBOL_PLATFORM DEFAULT}

///////////////////////
///  main classes   ///
///////////////////////

type
  TCertificateStore = class
  public
    class constructor Create;
    class destructor Destroy;
  end;

type
  TWinHttpLib = class(TObject)
  private
    const winhttp = 'winhttp.dll';
  private
    class var FHandle: THandle;
    class var FSession: HINTERNET;
    class var FStore: HCERTSTORE;
  public
    class constructor Create;
    class destructor Destroy;
    procedure LockHandleGC;
    function CertStore: HCERTSTORE;
    class property Handle: THandle read FHandle;
  end;

var
  GLib: TWinHttpLib = nil;

type
  TWinHTTPClient = class(THTTPClient)
  private
    FWSession: HINTERNET;

    FCertificateList: TList<TCertificate>;
    FWinCertList: TList<PCCERT_CONTEXT>;

    function ChooseAuthScheme(SupportedSchemes: DWORD): DWORD;
//    function ConvertAuthSchemeFromWin(AnAuthScheme: DWORD): TCredentialsStorage.TAuthSchemeType;
//    function ConvertAuthSchemeToWin(AnAuthScheme: TCredentialsStorage.TAuthSchemeType): DWORD;
  protected
    function DoSetCredential(AnAuthTargetType: TAuthTargetType; const ARequest: THTTPRequest;
      const ACredential: TCredentialsStorage.TCredential): Boolean; override;
    function DoExecuteRequest(const ARequest: THTTPRequest; var AResponse: THTTPResponse;
      const AContentStream: TStream): TWinHTTPClient.TExecutionResult; override;
    /// <summary>Returns a new response instance from the client.</summary>
    function DoGetResponseInstance(const AContext: TObject; const AProc: TProc;
      const AsyncCallback: TAsyncCallback; const AsyncCallbackEvent: TAsyncCallbackEvent;
      const ARequest: IURLRequest; const AContentStream: TStream): IAsyncResult; override;

    function DoGetHTTPRequestInstance(const AClient: THTTPClient; const ARequestMethod: string;
      const AURI: TURI): IHTTPRequest; override;
    function DoProcessStatus(const ARequest: IHTTPRequest; const  AResponse: IHTTPResponse): Boolean; override;

    function DoGetSSLCertificateFromServer(const ARequest: THTTPRequest): TCertificate; override;
    procedure DoServerCertificateAccepted(const ARequest: THTTPRequest); override;

    procedure DoGetClientCertificates(const ARequest: THTTPRequest; const ACertificateList: TList<TCertificate>); override;
    function DoNoClientCertificate(const ARequest: THTTPRequest): Boolean; override;
    function DoClientCertificateAccepted(const ARequest: THTTPRequest; const AnIndex: Integer): Boolean; override;

    class function CreateInstance: TURLClient; override;
  public
    constructor Create;
    destructor Destroy; override;

  end;

  TWinHTTPResponse = class;

  TWinHTTPRequest = class(THTTPRequest)
  private
    FWConnect: HINTERNET;
    FWRequest: HINTERNET;
    FLastProxyAuthScheme: DWORD;
    FLastServerAuthScheme: DWORD;
    FResponseLink: TWinHTTPResponse;
    FHeaders: TNetHeaders;

    procedure CreateHandles(const AURI: TURI);
    procedure UpdateRequest(const AURI: TURI);

    procedure SetWinProxySettings;
  protected
    function GetHeaders: TNetHeaders; override;

    function GetHeaderValue(const AName: string): string; override;
    procedure SetHeaderValue(const AName, AValue: string); override;

    /// <summary>Add a Header to the current request.</summary>
    /// <param name="AName: string">Name of the Header.</param>
    /// <param name="AValue: string">Value associted.</param>
    procedure AddHeader(const AName, AValue: string); override;

    /// <summary>Removes a Header from the request</summary>
    /// <param name="AName: string">Header to be removed.</param>
    function RemoveHeader(const AName: string): Boolean; override;

    procedure DoPrepare; override;

    /// <summary> Setter for the ConnectionTimeout property.</summary>
    procedure SetConnectionTimeout(const Value: Integer); override;
    /// <summary> Setter for the ResponseTimeout property.</summary>
    procedure SetResponseTimeout(const Value: Integer); override;
  public
    constructor Create(const AClient: THTTPClient; const ARequestMethod: string; const AURI: TURI);
    destructor Destroy; override;
  end;

  TWinHTTPResponse = class(THTTPResponse)
  private
    FWRequest: HINTERNET;
    FWConnect: HINTERNET;
    FRequestLink: TWinHTTPRequest;

    procedure UpdateHandles(AWConnect, AWRequest: HINTERNET);
  protected
    procedure DoReadData(const AStream: TStream); override;

    {IURLResponse}
    function GetHeaders: TNetHeaders; override;

    {IHTTPResponse}
    function GetStatusCode: Integer; override;
    function GetStatusText: string; override;
    function GetVersion: THTTPProtocolVersion; override;

  public
    constructor Create(const AContext: TObject; const AProc: TProc; const AAsyncCallback: TAsyncCallback; const AAsyncCallbackEvent: TAsyncCallbackEvent;
      const ARequest: TWinHTTPRequest; const AContentStream: TStream);
    destructor Destroy; override;
  end;

{ Helper functions }

//function StringToHeaders(const Text: string): TNetHeaders;
//var
//  Lines: TArray<string>;
//  LHeader: string;
//  LValue: string;
//  I, J, K: Integer;
//  Found: Boolean;
//  Pos: Integer;
//begin
//  Lines := Text.Split([#13#10], ExcludeEmpty);
//  SetLength(Result, Length(Lines));
//  J := 0;
//  for I := 0 to High(Lines) do
//  begin
//    Pos := Lines[I].IndexOf(':');
//    if Pos > 0 then
//    begin
//      LHeader := Lines[I].Substring(0, Pos).Trim;
//      LValue := Lines[I].Substring(Pos + 1).Trim;
//      Found := False;
//      for K := 0 to J - 1 do
//        if string.CompareText(Result[K].Name, LHeader) = 0 then
//        begin
//          Result[K].Value := Result[K].Value + ', ' + LValue;
//          Found := True;
//        end;
//      if not Found then
//      begin
//        Result[J].Create(LHeader, LValue);
//        Inc(J);
//      end;
//    end;
//  end;
//  SetLength(Result, J);
//end;

procedure StringToHeaders(const Text: string; var AHeadersArray: TNetHeaders; const AResponse: TWinHTTPResponse);
var
  Lines: TArray<string>;
  LHeader: string;
  LValue: string;
  I, J, K: Integer;
  Found: Boolean;
  Pos: Integer;
begin
  Lines := Text.Split([#13#10], 1);
  SetLength(AHeadersArray, Length(Lines));
  J := 0;
  for I := 0 to High(Lines) do
  begin
    Pos := Lines[I].IndexOf(':');
    if Pos > 0 then
    begin
      LHeader := Lines[I].Substring(0, Pos).Trim;
      LValue := Lines[I].Substring(Pos + 1).Trim;

      if (AResponse <> nil) and SameText(LHeader, sSetCookie) then
         AResponse.InternalAddCookie(LValue)
      else
      begin
        Found := False;
        for K := 0 to J - 1 do
          if string.CompareText(AHeadersArray[K].Name, LHeader) = 0 then
          begin
            AHeadersArray[K].Value := AHeadersArray[K].Value + ', ' + LValue;
            Found := True;
          end;
        if not Found then
        begin
          AHeadersArray[J].Create(LHeader, LValue);
          Inc(J);
        end;
      end;
    end;
  end;
  SetLength(AHeadersArray, J);
end;

function ObjectName(const AURI: TURI): string;
begin
  Result := AURI.Path;
  if AURI.Query <> '' then
    Result := Result + '?' + AURI.Query;
end;

function ReadHeader(ARequest: HINTERNET; AHeaderFlag: DWORD; const AHeaderName: string = ''): string;
var
  LSize: Cardinal;
  Buff: TBytes;
  LFlags: DWORD;
  LHeaderName: PWideChar;
begin
  LFLags := AHeaderFlag;
  if AHeaderName <> '' then
  begin
    LFLags := LFLags or WINHTTP_QUERY_CUSTOM;
    LHeaderName := PWideChar(AHeaderName);
  end
  else
    LHeaderName := WINHTTP_HEADER_NAME_BY_INDEX;

  LSize := 0;
  WinHttpQueryHeaders(ARequest, LFLags, LHeaderName, nil, LSize, WINHTTP_NO_HEADER_INDEX);

  if GetLastError = ERROR_WINHTTP_HEADER_NOT_FOUND then
    Result := ''
  else
  begin
    if GetLastError <> ERROR_INSUFFICIENT_BUFFER then
      raise ENetHTTPException.CreateResFmt(@SNetHttpHeadersError, [GetLastError, SysErrorMessage(GetLastError, GLib.Handle)]);

    SetLength(Buff, LSize);
    if WinHttpQueryHeaders(ARequest, LFLags, LHeaderName, @Buff[0], LSize, WINHTTP_NO_HEADER_INDEX) = False then
      raise ENetHTTPException.CreateResFmt(@SNetHttpHeadersError, [GetLastError, SysErrorMessage(GetLastError, GLib.Handle)]);

    Result := TEncoding.Unicode.GetString(Buff, 0, LSize);
  end;
end;

function BlobToStr(AEncoding: DWORD; Blob: PCERT_NAME_BLOB): PWideChar;
var
  LSize: DWORD;
  LFormat: DWORD;
begin
  LFormat := CERT_SIMPLE_NAME_STR or CERT_NAME_STR_CRLF_FLAG;
  LSize := CertNameToStr(AEncoding, Blob, LFormat, nil, 0);
  GetMem(Result, LSize * SizeOf(Char));
  CertNameToStr(AEncoding, Blob, LFormat, Result, LSize);
end;

procedure HttpCertWinInfoToTCertificate(const AWinCert: TWinHttpCertificateInfo; var ACertificate: TCertificate);
var
  LTmpTime: TSystemTime;
begin
  FileTimeToSystemTime(AWinCert.ftExpiry, LTmpTime);
  ACertificate.Expiry := SystemTimeToDateTime(LTmpTime);
  FileTimeToSystemTime(AWinCert.ftStart, LTmpTime);
  ACertificate.Start := SystemTimeToDateTime(LTmpTime);
  ACertificate.Subject := AWinCert.lpszSubjectInfo;
  ACertificate.Issuer := AWinCert.lpszIssuerInfo;
  ACertificate.ProtocolName := AWinCert.lpszProtocolName;
  ACertificate.AlgSignature := AWinCert.lpszSignatureAlgName;
  ACertificate.AlgEncryption := AWinCert.lpszEncryptionAlgName;
  ACertificate.KeySize := AWinCert.dwKeySize;
end;

function GetKeySize(ACryptCert: PCCERT_CONTEXT): DWORD;
begin
                                                      
  Result := 0;
end;

procedure CryptCertToHttpCert(ACryptCert: PCCERT_CONTEXT; var AHttpCert: TWinHttpCertificateInfo);
begin
// lpszSubjectInfo & lpszIssuerInfo need to be released using FreeMem
  AHttpCert.ftExpiry := ACryptCert.pCertInfo.NotAfter;
  AHttpCert.ftStart := ACryptCert.pCertInfo.NotBefore;
  AHttpCert.lpszSubjectInfo := BlobToStr(ACryptCert.dwCertEncodingType, @ACryptCert.pCertInfo.Subject);
  AHttpCert.lpszIssuerInfo := BlobToStr(ACryptCert.dwCertEncodingType, @ACryptCert.pCertInfo.Issuer);
  AHttpCert.lpszProtocolName := nil;
  AHttpCert.lpszSignatureAlgName := nil;
  AHttpCert.lpszEncryptionAlgName := nil;
  AHttpCert.dwKeySize := GetKeySize(ACryptCert);
end;

procedure CryptCertToTCertificate(ACryptCert: PCCERT_CONTEXT; var ACertificate: TCertificate);
var
  LHttpCert: TWinHttpCertificateInfo;
begin
  CryptCertToHttpCert(ACryptCert, LHttpCert);
  HttpCertWinInfoToTCertificate(LHttpCert, ACertificate);
  FreeMem(LHttpCert.lpszSubjectInfo);
  FreeMem(LHttpCert.lpszIssuerInfo);
end;



{ TWinHTTPClient }

class function TWinHTTPClient.CreateInstance: TURLClient;
begin
  Result := TWinHTTPClient.Create;
end;

//function TWinHTTPClient.ConvertAuthSchemeFromWin(AnAuthScheme: DWORD): TCredentialsStorage.TAuthSchemeType;
//begin
//  case AnAuthScheme of
//    WINHTTP_AUTH_SCHEME_NEGOTIATE:
//      Result := TCredentialsStorage.TAuthSchemeType.Negotiate;
//    WINHTTP_AUTH_SCHEME_NTLM:
//      Result := TCredentialsStorage.TAuthSchemeType.NTLM;
//    WINHTTP_AUTH_SCHEME_DIGEST:
//      Result := TCredentialsStorage.TAuthSchemeType.Digest;
//    WINHTTP_AUTH_SCHEME_BASIC:
//      Result := TCredentialsStorage.TAuthSchemeType.Basic;
//    else
//      raise ENetCredentialException.Create('Authentication Scheme not supported');
//  end;
//end;
//
//function TWinHTTPClient.ConvertAuthSchemeToWin(AnAuthScheme: TCredentialsStorage.TAuthSchemeType): DWORD;
//begin
//  case AnAuthScheme of
//    TCredentialsStorage.TAuthSchemeType.Negotiate:
//      Result := WINHTTP_AUTH_SCHEME_NEGOTIATE;
//    TCredentialsStorage.TAuthSchemeType.NTLM:
//      Result := WINHTTP_AUTH_SCHEME_NTLM;
//    TCredentialsStorage.TAuthSchemeType.Digest:
//      Result := WINHTTP_AUTH_SCHEME_DIGEST;
//    TCredentialsStorage.TAuthSchemeType.Basic:
//      Result := WINHTTP_AUTH_SCHEME_BASIC;
//    else
//      raise ENetCredentialException.Create('Authentication Scheme not supported');
//  end;
//end;

//procedure HTTPCallback(hInternet: HINTERNET; dwContext: Pointer; dwInternetStatus: DWORD;
//    lpvStatusInformation: Pointer; dwStatusInformationLength: DWORD); stdcall;
//var
//  LRequest: TWinHTTPRequest;
//begin
//
//  case dwInternetStatus of
//    WINHTTP_CALLBACK_STATUS_SECURE_FAILURE:
//    begin
//      LRequest := TWinHTTPRequest(dwContext);
//    end;
//  end;
//
//end;

constructor TWinHTTPClient.Create;
begin
  inherited Initializer;

  FWinCertList := TList<PCCERT_CONTEXT>.Create;
  FCertificateList := TList<TCertificate>.Create;

  GLib.LockHandleGC;
  FWSession := WinHttpOpen('', WINHTTP_ACCESS_TYPE_NO_PROXY, WINHTTP_NO_PROXY_NAME, WINHTTP_NO_PROXY_BYPASS, 0);
  if FWSession = nil then
    raise ENetHTTPClientException.CreateRes(@SNetHttpClientHandleError);

//  WinHttpSetStatusCallback(FWSession, HTTPCallback, WINHTTP_CALLBACK_FLAG_ALL_NOTIFICATIONS, nil);
end;

destructor TWinHTTPClient.Destroy;
var
  I: Integer;
begin
  for I := 0 to FWinCertList.Count - 1 do
    CertFreeCertificateContext(FWinCertList[I]);
  FWinCertList.Free;
  FCertificateList.Free;
  if FWSession <> nil then
    WinHttpCloseHandle(FWSession);
  inherited;
end;

function TWinHTTPClient.DoClientCertificateAccepted(const ARequest: THTTPRequest; const AnIndex: Integer): Boolean;
var
  LRequest: TWinHTTPRequest;
begin
  inherited;
  LRequest := TWinHTTPRequest(ARequest);
  Result := WinHttpSetOption(LRequest.FWRequest, WINHTTP_OPTION_CLIENT_CERT_CONTEXT, FWinCertList[AnIndex], SizeOf(CERT_CONTEXT) );
end;

function TWinHTTPClient.DoExecuteRequest(const ARequest: THTTPRequest; var AResponse: THTTPResponse;
  const AContentStream: TStream): TWinHTTPClient.TExecutionResult;
var
  LRes: Boolean;
  LBuffer: TArray<System.Byte>;
  LBytesWritten: DWORD;
  LRequest: TWinHTTPRequest;
  LDataLength: Int64;
  LWritten: Int64;
  LToWrite: LongInt;
  LOptionValue: DWORD;
  LastError: Cardinal;
  LHeader: TNetHeader;
const
  BUFFERSIZE = 64 * 1024;  // Usual TCP Window Size
begin
  Result := TExecutionResult.Success;
  LRequest := TWinHTTPRequest(ARequest);

  if LRequest.FHeaders = nil then
    LRequest.FHeaders := LRequest.GetHeaders
  else
  begin
    for LHeader in LRequest.FHeaders do
      if LRequest.GetHeaderValue(LHeader.Name) = '' then
        LRequest.AddHeader(LHeader.Name, LHeader.Value);
  end;

  LDataLength := 0;
  if LRequest.FSourceStream <> nil then
    LDataLength := LRequest.FSourceStream.Size - LRequest.FSourceStream.Position;

  //Set callback context to LRequest
//  WinHttpSetOption(LRequest.FWRequest, WINHTTP_OPTION_CONTEXT_VALUE, @LRequest, SizeOf(Pointer));

  //Disable automatic redirects
  LOptionValue := WINHTTP_DISABLE_REDIRECTS;
  WinHttpSetOption(LRequest.FWRequest, WINHTTP_OPTION_DISABLE_FEATURE, @LOptionValue, sizeof(LOptionValue));

  //Disable automatic addition of cookie headers to requests, it's done by framework
  LOptionValue := WINHTTP_DISABLE_COOKIES;
  WinHttpSetOption(LRequest.FWRequest, WINHTTP_OPTION_DISABLE_FEATURE, @LOptionValue, sizeof(LOptionValue));

  // Send Request
  LRes := WinHttpSendRequest(LRequest.FWRequest, WINHTTP_NO_ADDITIONAL_HEADERS, 0, WINHTTP_NO_REQUEST_DATA, 0, LDataLength, 0);
  if not LRes then
  begin
    LastError := GetLastError;
    case LastError of
      ERROR_WINHTTP_SECURE_FAILURE:
        Exit(TExecutionResult.ServerCertificateInvalid);
      ERROR_WINHTTP_CLIENT_AUTH_CERT_NEEDED:
        Exit(TExecutionResult.ClientCertificateNeeded);
      else
        raise ENetHTTPClientException.CreateResFmt(@SNetHttpClientSendError, [GetLastError, SysErrorMessage(GetLastError, GLib.Handle)]);
    end;
  end;

  // Send data
  if LDataLength > 0 then
  begin
    SetLength(LBuffer, BUFFERSIZE);
    LWritten := 0;
    while LWritten < LDataLength do
    begin
      LToWrite := BUFFERSIZE;
      if LDataLength - LWritten < LToWrite then
        LToWrite := LDataLength - LWritten;
      LRequest.FSourceStream.ReadBuffer(LBuffer, LToWrite);
      // Write data to the server.
      if not WinHttpWriteData(LRequest.FWRequest, LBuffer[0], LToWrite, @LBytesWritten) then
        raise ENetHTTPClientException.CreateResFmt(@SNetHttpClientSendError, [GetLastError, SysErrorMessage(GetLastError, GLib.Handle)]);
      if LongInt(LBytesWritten) < LToWrite then
        LRequest.FSourceStream.Position := LRequest.FSourceStream.Position - (LToWrite - LongInt(LBytesWritten));
      LWritten := LWritten + LBytesWritten;
    end;
  end;

  // Wait to receive response
  LRes := WinHttpReceiveResponse(LRequest.FWRequest, nil);
  if not LRes then
  begin
    LastError := GetLastError;
    case LastError of
      ERROR_WINHTTP_SECURE_FAILURE:
        Exit(TExecutionResult.ServerCertificateInvalid);
      ERROR_WINHTTP_CLIENT_AUTH_CERT_NEEDED:
        Exit(TExecutionResult.ClientCertificateNeeded);
      else
        raise ENetHTTPClientException.CreateResFmt(@SNetHttpClientReceiveError, [GetLastError, SysErrorMessage(GetLastError, GLib.Handle)]);
    end;
  end;
  SetLength(TWinHTTPResponse(AResponse).FHeaders, 0); // Reset response headers
  LRequest.FResponseLink := TWinHTTPResponse(AResponse);
end;

procedure TWinHTTPClient.DoGetClientCertificates(const ARequest: THTTPRequest;
  const ACertificateList: TList<TCertificate>);
var
  LRequest: TWinHTTPRequest;
  LStore: HCERTSTORE;
  LIssuerList: PSecPkgContext_IssuerListInfoEx;
  LClientCert: PCCERT_CONTEXT;
  LSearchCriteria: CERT_CHAIN_FIND_BY_ISSUER_PARA;
  LIssuerListSize: DWORD;
  LPrevChainContext, LClientCertChain: PCCERT_CHAIN_CONTEXT;

  procedure AddToCertificateList(const AClientCert: PCCERT_CONTEXT);
  var
    LCertificate: TCertificate;
  begin
    CertDuplicateCertificateContext(AClientCert); // Need to be released (CertFreeCertificateContext)
    CryptCertToTCertificate(AClientCert, LCertificate);
    FCertificateList.Add(LCertificate);
    FWinCertList.Add(AClientCert);
  end;
begin
  inherited;

  if FWinCertList.Count = 0 then
  begin
    LRequest := TWinHTTPRequest(ARequest);

    LIssuerList := nil;
    LIssuerListSize := SizeOf(LIssuerList);
    LStore := GLib.CertStore;

    if WinHttpQueryOption(LRequest.FWRequest, WINHTTP_OPTION_CLIENT_CERT_ISSUER_LIST, LIssuerList, LIssuerListSize) and (LIssuerList <> nil) then
    begin
      FillChar(LSearchCriteria, SizeOf(LSearchCriteria), 0);
      LSearchCriteria.cbSize := SizeOf(LSearchCriteria);
      LSearchCriteria.cIssuer := LIssuerList.cIssuers;
      LSearchCriteria.rgIssuer := LIssuerList.aIssuers;

      if LStore <> nil then
      begin
        LPrevChainContext := nil;
        while True do
        begin
          LClientCertChain := CertFindChainInStore(LStore, X509_ASN_ENCODING,
            CERT_CHAIN_FIND_BY_ISSUER_CACHE_ONLY_URL_FLAG or CERT_CHAIN_FIND_BY_ISSUER_CACHE_ONLY_FLAG,
            CERT_CHAIN_FIND_BY_ISSUER, @LSearchCriteria, LPrevChainContext);

          if LClientCertChain <> nil then
          begin
            LPrevChainContext := LClientCertChain;
            LClientCert := LClientCertChain.rgpChain^.rgpElement^.pCertContext;
            AddToCertificateList(LClientCert);
          end else
            Break;
        end;
      end;
      GlobalFree(HGLOBAL(LIssuerList));
    end else
    begin
      if LStore <> nil then
      begin
        LClientCert := nil;
        while True do
        begin
          LClientCert := CertFindCertificateInStore(LStore,
            X509_ASN_ENCODING or PKCS_7_ASN_ENCODING,
            0, CERT_FIND_ANY, nil, LClientCert);
          if LClientCert <> nil then
            AddToCertificateList(LClientCert)
          else
            Break;
        end;
      end;
    end;
  end;
  ACertificateList.Clear;
  ACertificateList.AddRange(FCertificateList);
end;

function TWinHTTPClient.DoGetHTTPRequestInstance(const AClient: THTTPClient; const ARequestMethod: string;
  const AURI: TURI): IHTTPRequest;
begin
  Result := TWinHTTPRequest.Create(TWinHTTPClient(AClient), ARequestMethod, AURI);
end;

function TWinHTTPClient.DoGetResponseInstance(const AContext: TObject; const AProc: TProc;
  const AsyncCallback: TAsyncCallback; const AsyncCallbackEvent: TAsyncCallbackEvent;
  const ARequest: IURLRequest; const AContentStream: TStream): IAsyncResult;
begin
  Result := TWinHTTPResponse.Create(AContext, AProc, AsyncCallback, AsyncCallbackEvent, ARequest as TWinHttpRequest, AContentStream);
end;

function TWinHTTPClient.DoGetSSLCertificateFromServer(const ARequest: THTTPRequest): TCertificate;
var
  LRequest: TWinHTTPRequest;
  LCert: TWinHttpCertificateInfo;
  LSize: DWORD;
begin
  Result := Default(TCertificate);
  LRequest := TWinHTTPRequest(ARequest);
  LSize := SizeOf(LCert);
  if WinHttpQueryOption(LRequest.FWRequest, WINHTTP_OPTION_SECURITY_CERTIFICATE_STRUCT, LCert, LSize) = TRUE then
  begin
    HttpCertWinInfoToTCertificate(LCert, Result);
    LocalFree(HLOCAL(LCert.lpszSubjectInfo));
    LocalFree(HLOCAL(LCert.lpszIssuerInfo));
  end;
end;

function TWinHTTPClient.DoProcessStatus(const ARequest: IHTTPRequest; const AResponse: IHTTPResponse): Boolean;
var
  LRequest: TWinHTTPRequest;
  LResponse: TWinHTTPResponse;
  LURI: TURI;
begin
  LRequest := ARequest as TWinHTTPRequest;
  LResponse := AResponse as TWinHTTPResponse;
  // If the result is true then the while ends
  Result := True;
  if IsAutoRedirect(LResponse) then
  begin
    LURI := ComposeRedirectURL(LRequest, LResponse);
    if IsAutoRedirectWithGET(LRequest, LResponse) then
    begin
      LRequest.FMethodString := sHTTPMethodGet; // Change to GET
      LRequest.FSourceStream := nil;            // Dont send any data
      LRequest.SetHeaderValue(sContentType, '');// Dont set content type
    end;

    LRequest.UpdateRequest(LURI);
    LResponse.UpdateHandles(LRequest.FWConnect, LRequest.FWRequest);
    Result := False;
  end;
end;

function TWinHTTPClient.DoNoClientCertificate(
  const ARequest: THTTPRequest): Boolean;
var
  LRequest: TWinHTTPRequest;
begin
  LRequest := ARequest as TWinHTTPRequest;
  Result := WinHttpSetOption(LRequest.FWRequest, WINHTTP_OPTION_CLIENT_CERT_CONTEXT,
    WINHTTP_NO_CLIENT_CERT_CONTEXT, 0);
end;

procedure TWinHTTPClient.DoServerCertificateAccepted(const ARequest: THTTPRequest);
var
  LFlags: DWORD;
begin
  inherited;
  LFlags := SECURITY_FLAG_IGNORE_UNKNOWN_CA or SECURITY_FLAG_IGNORE_CERT_WRONG_USAGE or
    SECURITY_FLAG_IGNORE_CERT_CN_INVALID or SECURITY_FLAG_IGNORE_CERT_DATE_INVALID;

  WinHttpSetOption(TWinHTTPRequest(ARequest).FWRequest, WINHTTP_OPTION_SECURITY_FLAGS, @LFlags, SizeOf(LFlags));
end;

function TWinHTTPClient.DoSetCredential(AnAuthTargetType: TAuthTargetType; const ARequest: THTTPRequest;
  const ACredential: TCredentialsStorage.TCredential): Boolean;
var
  AuthTarget: DWORD;
  Target: DWORD;
  FirstScheme: DWORD;
  SupportedSchemes: DWORD;
  AuthScheme: DWORD;
  LRequest: TWinHTTPRequest;
begin
  LRequest := TWinHTTPRequest(ARequest);
  if AnAuthTargetType = TAuthTargetType.Server then
  begin
    AuthTarget := WINHTTP_AUTH_TARGET_SERVER;
    AuthScheme := LRequest.FLastServerAuthScheme;
  end
  else
  begin
    AuthTarget := WINHTTP_AUTH_TARGET_PROXY;
    AuthScheme := LRequest.FLastProxyAuthScheme;
  end;

  if AuthScheme = 0 then // we haven't a previous scheme
  begin
    if WinHttpQueryAuthSchemes(TWinHTTPRequest(ARequest).FWRequest, SupportedSchemes, FirstScheme, Target) then
    begin
      AuthScheme := ChooseAuthScheme(SupportedSchemes);
      if AnAuthTargetType = TAuthTargetType.Server then
        LRequest.FLastServerAuthScheme := AuthScheme
      else
        LRequest.FLastProxyAuthScheme := AuthScheme;
    end
  end;
  Result := WinHttpSetCredentials(TWinHTTPRequest(ARequest).FWRequest, AuthTarget, AuthScheme, PWideChar(ACredential.UserName),
    PWideChar(ACredential.Password), nil);
end;

function TWinHTTPClient.ChooseAuthScheme(SupportedSchemes: DWORD): DWORD;
begin
  if (SupportedSchemes and WINHTTP_AUTH_SCHEME_NEGOTIATE) <> 0 then
    Result := WINHTTP_AUTH_SCHEME_NEGOTIATE
  else if (SupportedSchemes and WINHTTP_AUTH_SCHEME_NTLM) <> 0 then
    Result := WINHTTP_AUTH_SCHEME_NTLM
  else if (SupportedSchemes and WINHTTP_AUTH_SCHEME_PASSPORT) <> 0 then
    Result := WINHTTP_AUTH_SCHEME_PASSPORT
  else if (SupportedSchemes and WINHTTP_AUTH_SCHEME_DIGEST) <> 0 then
    Result := WINHTTP_AUTH_SCHEME_DIGEST
  else if (SupportedSchemes and WINHTTP_AUTH_SCHEME_BASIC) <> 0 then
    Result := WINHTTP_AUTH_SCHEME_BASIC
  else
    Result := 0;
end;

{ TWinHTTPRequest }

constructor TWinHTTPRequest.Create(const AClient: THTTPClient; const ARequestMethod: string; const AURI: TURI);
begin
  inherited Create(AClient, ARequestMethod, AURI);

  if FResponseLink = nil then
    CreateHandles(AURI);
end;

procedure TWinHTTPRequest.CreateHandles(const AURI: TURI);
var
  LFlags: DWORD;
  LPort: INTERNET_PORT;
begin
  if AURI.Port > 0 then
    LPort := AURI.Port
  else
    LPort := INTERNET_DEFAULT_PORT;
  FWConnect := WinHttpConnect(TWinHTTPClient(FClient).FWSession, PWideChar(AURI.Host), LPort, 0);
  if FWConnect = nil then
    raise ENetHTTPRequestException.CreateResFmt(@SNetHttpRequestConnectError, [AURI.Host]);

  LFlags := 0;
  if AURI.Scheme = TURI.SCHEME_HTTPS then
    LFlags := LFlags or WINHTTP_FLAG_SECURE;

  FWRequest := WinHttpOpenRequest( FWConnect, PWideChar(GetMethodString), PWideChar(ObjectName(AURI)), nil,
    WINHTTP_NO_REFERER, WINHTTP_DEFAULT_ACCEPT_TYPES, LFlags);
  if FWRequest = nil then
    raise ENetHTTPRequestException.CreateResFmt(@SNetHttpRequestOpenError, [GetLastError, SysErrorMessage(GetLastError, GLib.Handle)]);

  if WinHttpSetTimeouts(FWRequest, 0, ConnectionTimeout, ResponseTimeout, ResponseTimeout) = False then
    raise ENetHTTPRequestException.CreateResFmt(@SNetHttpRequestSetTimeoutError, [GetLastError,
      SysErrorMessage(GetLastError, GLib.Handle)]);
end;

destructor TWinHTTPRequest.Destroy;
begin
  if FResponseLink = nil then
  begin
    if FWRequest <> nil then
      WinHttpCloseHandle(FWRequest);
    if FWConnect <> nil then
      WinHttpCloseHandle(FWConnect);
  end
  else
    FResponseLink.FRequestLink := nil;
  inherited;
end;

procedure TWinHTTPRequest.AddHeader(const AName, AValue: string);
begin
  if WinHttpAddRequestHeaders(FWRequest, PWideChar(AName+': '+ AValue), $ffffffff,
    WINHTTP_ADDREQ_FLAG_COALESCE_WITH_COMMA) = False then
    raise ENetHTTPRequestException.CreateResFmt(@SNetHttpRequestAddHeaderError, [GetLastError, SysErrorMessage(GetLastError), GLib.Handle]);
end;

function TWinHTTPRequest.GetHeaders: TNetHeaders;
begin
  StringToHeaders(ReadHeader(FWRequest, WINHTTP_QUERY_RAW_HEADERS_CRLF or WINHTTP_QUERY_FLAG_REQUEST_HEADERS), Result, nil);
end;

function TWinHTTPRequest.GetHeaderValue(const AName: string): string;
begin
  Result := ReadHeader(FWRequest, WINHTTP_QUERY_FLAG_REQUEST_HEADERS, AName);
end;

procedure TWinHTTPRequest.DoPrepare;
var
  LClient: TWinHTTPClient;
  LProtocols: THTTPSecureProtocols;
  LOption: DWORD;
begin
  inherited;
  SetWinProxySettings;

                                                                                                  
  LClient := TWinHTTPClient(FClient);
  LProtocols := LClient.SecureProtocols;
  if LProtocols <> CHTTPDefSecureProtocols then
  begin
    LOption := 0;
    if THTTPSecureProtocol.SSL2 in LProtocols then
      LOption := LOption or WINHTTP_FLAG_SECURE_PROTOCOL_SSL2;
    if THTTPSecureProtocol.SSL3 in LProtocols then
      LOption := LOption or WINHTTP_FLAG_SECURE_PROTOCOL_SSL3;
    if THTTPSecureProtocol.TLS1 in LProtocols then
      LOption := LOption or WINHTTP_FLAG_SECURE_PROTOCOL_TLS1;
    if THTTPSecureProtocol.TLS11 in LProtocols then
      LOption := LOption or WINHTTP_FLAG_SECURE_PROTOCOL_TLS1_1;
    if THTTPSecureProtocol.TLS12 in LProtocols then
      LOption := LOption or WINHTTP_FLAG_SECURE_PROTOCOL_TLS1_2;
    WinHttpSetOption(LClient.FWSession, WINHTTP_OPTION_SECURE_PROTOCOLS, @LOption, SizeOf(LOption));
  end;
end;

function TWinHTTPRequest.RemoveHeader(const AName: string): Boolean;
var
  i: Integer;
begin
  Result := True;
  if GetHeaderValue(AName) = '' then
    Result := False
  else if WinHttpAddRequestHeaders(FWRequest, PWideChar(AName+':'), $ffffffff, WINHTTP_ADDREQ_FLAG_REPLACE) = False then
    raise ENetHTTPRequestException.CreateResFmt(@SNetHttpRequestRemoveHeaderError, [GetLastError, SysErrorMessage(GetLastError, GLib.Handle)]);
  for i := 0 to Length(FHeaders) - 1 do
    if SameText(FHeaders[i].Name, AName) then
    begin
      Delete(FHeaders, i, 1);
      Break;
    end;
end;

procedure TWinHTTPRequest.SetConnectionTimeout(const Value: Integer);
begin
  inherited;
  if WinHttpSetTimeouts(FWRequest, 0, Value, ResponseTimeout, ResponseTimeout) = False then
    raise ENetHTTPRequestException.CreateResFmt(@SNetHttpRequestSetTimeoutError, [GetLastError,
      SysErrorMessage(GetLastError, GLib.Handle)]);
end;

procedure TWinHTTPRequest.SetHeaderValue(const AName, AValue: string);
var
  i: Integer;
begin
  // Add or replace a header value
  if WinHttpAddRequestHeaders(FWRequest, PWideChar(AName+': '+ AValue), $ffffffff, WINHTTP_ADDREQ_FLAG_REPLACE or WINHTTP_ADDREQ_FLAG_ADD) = False then
    raise ENetHTTPRequestException.CreateResFmt(@SNetHttpRequestAddHeaderError, [GetLastError, SysErrorMessage(GetLastError, GLib.Handle)]);
  for i := 0 to Length(FHeaders) - 1 do
    if SameText(FHeaders[i].Name, AName) then
    begin
      FHeaders[i].Value := AValue;
      Break;
    end;
end;

procedure TWinHTTPRequest.SetResponseTimeout(const Value: Integer);
begin
  inherited;
  if WinHttpSetTimeouts(FWRequest, 0, ConnectionTimeout, Value, Value) = False then
    raise ENetHTTPRequestException.CreateResFmt(@SNetHttpRequestSetTimeoutError, [GetLastError,
      SysErrorMessage(GetLastError, GLib.Handle)]);
end;

procedure TWinHTTPRequest.UpdateRequest(const AURI: TURI);
begin
  FURL := AURI;
  if FWRequest <> nil then
    WinHttpCloseHandle(FWRequest);
  if FWConnect <> nil then
    WinHttpCloseHandle(FWConnect);
  CreateHandles(AURI);
end;

procedure TWinHTTPRequest.SetWinProxySettings;
var
  LClient: TWinHTTPClient;

  function GetProxyInfo(const AURL: string; var AProxy, AProxyBypass: string): Boolean;
  var
    LAutoDetectProxy: Boolean;
    LProxyConfig: TWinHTTPCurrentUserIEProxyConfig;
    LWinHttpProxyInfo: TWinHTTPProxyInfo;
    LAutoProxyOptions: TWinHTTPAutoProxyOptions;
  begin
    Result := True;
    AProxy := '';
    AProxyBypass := '';
    FillChar(LAutoProxyOptions, SizeOf(LAutoProxyOptions), 0);

    if WinHttpGetIEProxyConfigForCurrentUser(LProxyConfig) then
    begin
      if LProxyConfig.fAutoDetect then
      begin
        LAutoProxyOptions.dwFlags := WINHTTP_AUTOPROXY_AUTO_DETECT;
        LAutoProxyOptions.dwAutoDetectFlags := WINHTTP_AUTO_DETECT_TYPE_DHCP or WINHTTP_AUTO_DETECT_TYPE_DNS_A;
      end;

      if LProxyConfig.lpszAutoConfigURL <> '' then
      begin
        LAutoProxyOptions.dwFlags := WINHTTP_AUTOPROXY_CONFIG_URL;
        LAutoProxyOptions.lpszAutoConfigUrl := LProxyConfig.lpszAutoConfigUrl;
        LAutoDetectProxy := True;
      end
      else
      begin
        AProxy := LProxyConfig.lpszProxy;
        AProxyBypass := LProxyConfig.lpszProxyBypass;
        LAutoDetectProxy := False;
      end;
    end
    else
    begin
      // if the proxy configuration is not found then try to autodetect it (If the Internet Explorer settings are not configured for system accounts)
      LAutoProxyOptions.dwFlags := WINHTTP_AUTOPROXY_AUTO_DETECT;
      LAutoProxyOptions.dwAutoDetectFlags := WINHTTP_AUTO_DETECT_TYPE_DHCP or WINHTTP_AUTO_DETECT_TYPE_DNS_A;
      LAutoDetectProxy := True;
    end;

    if (AProxy = '') and LAutoDetectProxy then
    begin
      // From https://msdn.microsoft.com/en-us/library/aa383153%28VS.85%29.aspx
      // Try with fAutoLogonIfChallenged parameter set to false, if ERROR_WINHTTP_LOGIN_FAILURE then try
      // with fAutoLogonIfChallenged parameter set to true.
      LAutoProxyOptions.fAutoLogonIfChallenged := False;
      if WinHttpGetProxyForUrl(LClient.FWSession, LPCWSTR(AURL), LAutoProxyOptions, LWinHttpProxyInfo) then
      begin
        AProxy := LWinHttpProxyInfo.lpszProxy;
        AProxyBypass := LWinHttpProxyInfo.lpszProxyBypass;
      end
      else
      begin
        if GetLastError = ERROR_WINHTTP_LOGIN_FAILURE then
        begin
          LAutoProxyOptions.fAutoLogonIfChallenged := True;
          if WinHttpGetProxyForUrl(LClient.FWSession, LPCWSTR(AURL), LAutoProxyOptions, LWinHttpProxyInfo) then
          begin
            AProxy := LWinHttpProxyInfo.lpszProxy;
            AProxyBypass := LWinHttpProxyInfo.lpszProxyBypass;
          end
          else
            Result := False;
        end
        else
          Result := False;
      end;
    end;
    GlobalFree(HGLOBAL(LProxyConfig.lpszAutoConfigUrl));
    GlobalFree(HGLOBAL(LProxyConfig.lpszProxy));
    GlobalFree(HGLOBAL(LProxyConfig.lpszProxyBypass));
    if AProxy = '' then
      Result := False;
  end;

  function GetProxyString: string;
  begin
    Result := '';
    if LClient.ProxySettings.Scheme <> '' then
      Result := Result + LClient.ProxySettings.Scheme + '://';
    Result := Result + LClient.ProxySettings.Host + ':' + LClient.ProxySettings.Port.ToString;
  end;

var
  LProxyInfo: TWinHttpProxyInfo;
  LOptionValue: DWORD;
  LProxyString: string;
  LProxy, LProxyBypass: string;
begin
  LClient := TWinHTTPClient(FClient);

  if LClient.ProxySettings.Host <> '' then
  begin
    LProxyString := GetProxyString;
    if not SameText('http://direct:80', LProxyString) then
    begin
      LProxyInfo.dwAccessType := WINHTTP_ACCESS_TYPE_NAMED_PROXY;
      LProxyInfo.lpszProxy := PWideChar(LProxyString);
      LProxyInfo.lpszProxyBypass := PWideChar('');
      LOptionValue := SizeOf(LProxyInfo);
      WinHttpSetOption(FWRequest, WINHTTP_OPTION_PROXY, @LProxyInfo, LOptionValue);
      if LClient.ProxySettings.UserName <> '' then
        // we try to use the usual auth scheme to try to avoid a round trip
        WinHttpSetCredentials(FWRequest, WINHTTP_AUTH_TARGET_PROXY, WINHTTP_AUTH_SCHEME_BASIC,
          PWideChar(LClient.ProxySettings.UserName), PWideChar(LClient.ProxySettings.Password), nil);
    end;
  end
  else
  begin
    if GetProxyInfo(FURL.ToString, LProxy, LProxyBypass) then
    begin
      LProxyInfo.dwAccessType := WINHTTP_ACCESS_TYPE_NAMED_PROXY;
      LProxyInfo.lpszProxy := PWideChar(LProxy);
      LProxyInfo.lpszProxyBypass := PWideChar(LProxyBypass);
      LOptionValue := SizeOf(LProxyInfo);
      WinHttpSetOption(FWRequest, WINHTTP_OPTION_PROXY, @LProxyInfo, LOptionValue);
    end;
  end;
end;

{ TWinHTTPResponse }

constructor TWinHTTPResponse.Create(const AContext: TObject; const AProc: TProc; const AAsyncCallback: TAsyncCallback;
  const AAsyncCallbackEvent: TAsyncCallbackEvent; const ARequest: TWinHTTPRequest; const AContentStream: TStream);
begin
  inherited Create(AContext, AProc, AAsyncCallback, AAsyncCallbackEvent, ARequest, AContentStream);
  FRequestLink := ARequest;
  FWConnect := ARequest.FWConnect;
  FWRequest := ARequest.FWRequest;
end;

destructor TWinHTTPResponse.Destroy;
begin
  if FRequestLink <> nil then
    FRequestLink.FResponseLink := nil
  else
  begin
    if FWRequest <> nil then
      WinHttpCloseHandle(FWRequest);
    if FWConnect <> nil then
      WinHttpCloseHandle(FWConnect);
  end;
  inherited;
end;

function TWinHTTPResponse.GetStatusCode: Integer;
begin
  Result := ReadHeader(FWRequest, WINHTTP_QUERY_STATUS_CODE).ToInteger;
end;

function TWinHTTPResponse.GetHeaders: TNetHeaders;
begin
  if Length(FHeaders) = 0 then
    StringToHeaders(ReadHeader(FWRequest, WINHTTP_QUERY_RAW_HEADERS_CRLF), FHeaders, Self);
  Result := FHeaders;
end;

function TWinHTTPResponse.GetStatusText: string;
begin
  Result := ReadHeader(FWRequest, WINHTTP_QUERY_STATUS_TEXT);
end;

function TWinHTTPResponse.GetVersion: THTTPProtocolVersion;
var
  Version: string;
begin

  Version := ReadHeader(FWRequest, WINHTTP_QUERY_VERSION);

  if string.CompareText(Version, 'HTTP/1.0') = 0 then
    Result := THTTPProtocolVersion.HTTP_1_0
  else if string.CompareText(Version, 'HTTP/1.1') = 0 then
    Result := THTTPProtocolVersion.HTTP_1_1
  else if string.CompareText(Version, 'HTTP/2.0') = 0 then
    Result := THTTPProtocolVersion.HTTP_2_0
  else
    Result := THTTPProtocolVersion.UNKNOWN_HTTP;
end;

procedure TWinHTTPResponse.UpdateHandles(AWConnect, AWRequest: HINTERNET);
begin
  FWConnect := AWConnect;
  FWRequest := AWRequest;
end;

procedure TWinHTTPResponse.DoReadData(const AStream: TStream);
var
  LSize: Cardinal;
  LDownloaded: Cardinal;
  LBuffer: TBytes;
  LExpected, LReaded: Int64;
  LStatusCode: Integer;
  Abort: Boolean;
begin
  LReaded := 0;
  LExpected := GetContentLength;
  if LExpected = 0 then
    LExpected := -1;
  LStatusCode := GetStatusCode;
  Abort := False;
  FRequestLink.DoReceiveDataProgress(LStatusCode, LExpected, LReaded, Abort);
  if not Abort then
    repeat
      // Get the size of readed data in LSize
      if not WinHttpQueryDataAvailable(FWRequest, @LSize) then
        raise ENetHTTPResponseException.CreateResFmt(@SNetHttpRequestReadDataError, [GetLastError, SysErrorMessage(GetLastError, GLib.Handle)]);

      if LSize = 0 then
        Break;

      SetLength(LBuffer, LSize + 1);

      if not WinHttpReadData(FWRequest, LBuffer[0], LSize, @LDownloaded) then
        raise ENetHTTPResponseException.CreateResFmt(@SNetHttpRequestReadDataError, [GetLastError, SysErrorMessage(GetLastError, GLib.Handle)]);

      // This condition should never be reached since WinHttpQueryDataAvailable
      // reported that there are bits to read.
      if LDownloaded = 0 then
        Break;

      AStream.WriteBuffer(LBuffer, LDownloaded);
      LReaded := LReaded + LDownloaded;
      FRequestLink.DoReceiveDataProgress(LStatusCode, LExpected, LReaded, Abort);
    until (LSize = 0) or Abort;
end;

{ TCertificateStore }

class constructor TCertificateStore.Create;
begin
end;

class destructor TCertificateStore.Destroy;
begin
end;

{ TWinHttpLib }

class constructor TWinHttpLib.Create;
begin
  FHandle := GetModuleHandle(winhttp);
end;

class destructor TWinHttpLib.Destroy;
begin
  if FStore <> nil then
    CertCloseStore(FStore, 0);
  if FSession <> nil then
    WinHttpCloseHandle(FSession);
end;

procedure TWinHttpLib.LockHandleGC;
begin
  TMonitor.Enter(Self);
  try
    // Create a long living session to stop a background handle garbage collection
    if FSession = nil then
    begin
      FSession := WinHttpOpen('', WINHTTP_ACCESS_TYPE_NO_PROXY, WINHTTP_NO_PROXY_NAME, WINHTTP_NO_PROXY_BYPASS, 0);
      if FSession = nil then
        raise ENetHTTPClientException.CreateRes(@SNetHttpClientHandleError);
    end;
  finally
    TMonitor.Exit(Self);
  end;
end;

function TWinHttpLib.CertStore: HCERTSTORE;
begin
  TMonitor.Enter(Self);
  try
    if FStore = nil then
      FStore := CertOpenSystemStore(0, 'MY');
    Result := FStore;
  finally
    TMonitor.Exit(Self);
  end;
end;

initialization
  GLib := TWinHttpLib.Create;
  TURLSchemes.RegisterURLClientScheme(TWinHTTPClient, 'HTTP');
  TURLSchemes.RegisterURLClientScheme(TWinHTTPClient, 'HTTPS');

finalization
  TURLSchemes.UnRegisterURLClientScheme('HTTP');
  TURLSchemes.UnRegisterURLClientScheme('HTTPS');
  FreeAndNil(GLib);
end.
