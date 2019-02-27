unit uNanoMiner;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes,
  System.Variants,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs, Nano,
  System.IOUtils, misc, FMX.Styles,
  FMX.StdCtrls, FMX.Controls.Presentation, Windows, FMX.Layouts, FMX.Platform,
  FMX.Platform.Win, WinApi.ShellApi,
  FMX.ListBox, WinApi.Messages, FMX.Menus, Registry;

type
  TfrmNanoPoW = class(TForm)
    lblName: TLabel;
    grpBlocks: TGroupBox;
    SpeedCounter: TTimer;
    list: TListBox;
    PopupMenu: TPopupMenu;
    MenuItem1: TMenuItem;
    MenuItem2: TMenuItem;
    procedure FormCreate(Sender: TObject);
    procedure SpeedCounterTimer(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure MenuItem1Click(Sender: TObject);
    procedure MenuItem2Click(Sender: TObject);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
    procedure FormShow(Sender: TObject);
  private
    TrayWnd: HWND;
    TrayIconData: TNotifyIconData;
    TrayIconAdded: Boolean;
    procedure TrayWndProc(var Message: TMessage);

  public
    { Public declarations }
  end;

const
  WM_ICONTRAY = WM_USER + 1;

var
  frmNanoPoW: TfrmNanoPoW;
  stylo: TStyleManager;
  q1: System.Int64;
  shown:boolean;
implementation

{$R *.fmx}

procedure nano_mineBuilt64(cc: NanoCoin);
var
  block: TNanoBlock;
  lastHash,s:string;
  i:integer;
begin
     lastHash:='';
  repeat
    block := cc.firstBlock;

    if block.account <> '' then
    begin

      TThread.Synchronize(nil,
        procedure
        begin
          frmNanoPow.list.Items.Add(block.Hash + '  Account: ' +
            block.account);
        end);
      q1 := GetTickCount;
      hashCounter := 0;
      nano_getWork(block);
      hashCounter := 0;

     s:= nano_pushBlock(nano_builtToJSON(block));
  lastHash:=StringReplace(s,'https://www.nanode.co/block/','',[rfReplaceAll]);
  if isHex(lastHash)=false then lastHash:='';
  if cc.BlockByPrev(lastHash).account='' then  
    if lastHash<>'' then
      nano_pow(lastHash);
      end;
    cc.removeBlock(block.Hash);
  until Length(cc.pendingChain) = 0;
  loadPows;
  for i:=0 to Length(pows)-1 do
    if pows[i].work='' then
    nano_pow(pows[i].hash);
end;

procedure HideAppOnTaskbar(AMainForm: TForm);
var
  AppHandle: HWND;
begin

  AppHandle := ApplicationHWND; // GetParent(HWND(AMainForm.Handle));
  ShowWindow(AppHandle, SW_HIDE);
  SetWindowLong(AppHandle, GWL_EXSTYLE, GetWindowLong(AppHandle, GWL_EXSTYLE) or
    WS_EX_TOOLWINDOW);
end;

procedure mineAll;
var
  cc: NanoCoin;
  path: string;

begin

  repeat
    for path in TDirectory.GetDirectories
      (IncludeTrailingPathDelimiter({$IF DEFINED(LINUX)}System.IOUtils.TPath.
      GetDocumentsPath{$ELSE}System.IOUtils.TPath.combine
      (System.SysUtils.GetEnvironmentVariable('APPDATA'),
      'hodlertech'){$ENDIF})) do
    begin
      if DirectoryExists(TPath.combine(path, 'Pendings')) then
      begin
        cc := NanoCoin.Create();
        cc.chaindir := TPath.combine(path, 'Pendings');
        cc.pendingChain := nano_loadChain(TPath.combine(path, 'Pendings'));
        nano_mineBuilt64(cc);
        cc.Free;
      end;
      Sleep(100);
    end;
  until True = false;
end;

procedure TfrmNanoPoW.FormCloseQuery(Sender: TObject; var CanClose: Boolean);
begin
  CanClose := false;
  frmNanoPow.Hide;
end;

procedure TfrmNanoPoW.FormDestroy(Sender: TObject);
begin
  Shell_NotifyIcon(NIM_DELETE, @TrayIconData);
  DeallocateHWnd(TrayWnd);
end;

procedure TfrmNanoPoW.FormShow(Sender: TObject);
begin
if shown then Exit;
frmNanoPow.Visible:=false;
  shown:=true;
end;

procedure TfrmNanoPoW.MenuItem1Click(Sender: TObject);
begin
  frmNanoPow.Show;
end;

procedure TfrmNanoPoW.MenuItem2Click(Sender: TObject);
var
  x: Integer;
begin
  x := MessageDlg
    ('CAUTION! If you kill NanoPoW, it won''t mine any pending or send block from Hodler Wallet, do you really want to kill process?',
    TMsgDlgType.mtConfirmation, mbYesNo, 0);
  if x = mrYes then
    Application.Terminate;

end;

procedure TfrmNanoPoW.TrayWndProc(var Message: TMessage);
var
  P: TPoint;
begin
  if Message.MSG = WM_ICONTRAY then
  begin

    case Message.LParam of
      WM_RBUTTONDOWN:
        begin
          GetCursorPos(P);
          PopupMenu.Popup(P.x, P.Y);
        end;
    end;
  end
  else
    Message.Result := DefWindowProc(TrayWnd, Message.MSG, Message.WParam,
      Message.LParam);
end;

procedure TfrmNanoPoW.SpeedCounterTimer(Sender: TObject);
var
  s: Cardinal;
  speed: single;
begin
  HideAppOnTaskbar(frmNanoPow);
  s := (GetTickCount - q1) div 1000;
  speed := ((hashCounter) div s) / 1000;
  frmNanoPow.Caption := 'Nano PoW Speed: ' + FloatToStrF(speed, ffGeneral,
    8, 2) + ' kHash/s';
end;

procedure RunOnStartupHKCU(const sCmdLine: string);
var
  sKey: string;
  Section: string;
  ApplicationTitle: string;
begin
  ApplicationTitle := 'Nano PoW';
  sKey := 'Once';
  Section := 'Software\Microsoft\Windows\CurrentVersion\Run' + sKey + #0;

  with TRegIniFile.Create('') do
    try
      RootKey := HKEY_CURRENT_USER;
      WriteString(Section, ApplicationTitle, sCmdLine);
    finally
      Free;
    end;
end;

procedure TfrmNanoPoW.FormCreate(Sender: TObject);
begin
        HOME_PATH := IncludeTrailingPathDelimiter
        ({$IF DEFINED(LINUX)}System.IOUtils.TPath.GetDocumentsPath{$ELSE}System.
        IOUtils.TPath.combine(System.SysUtils.GetEnvironmentVariable('APPDATA'),
        'hodlertech'){$ENDIF});
  TrayWnd := AllocateHWnd(TrayWndProc);
  with TrayIconData do
  begin
    cbSize := SizeOf();
    Wnd := TrayWnd; // was before Wnd:= FmxHandleToHWND(self.Handle);
    uID := 0;
    uFlags := NIF_MESSAGE + NIF_ICON + NIF_TIP;
    uCallbackMessage := WM_ICONTRAY;
    hIcon := GetClassLong(FmxHandleToHWND(self.Handle), GCL_HICONSM);
    szTip := 'Nano PoW';
  end;
  Shell_NotifyIcon(NIM_ADD, @TrayIconData);
  stylo := TStyleManager.Create;
  stylo.TrySetStyleFromResource('MINER_STYLE');
  q1 := GetTickCount;
  TThread.CreateAnonymousThread(
    procedure
    begin
      mineAll()
    end).Start;
  RunOnStartupHKCU(ParamStr(0));
  frmNanoPow.Visible:=false;
  shown:=False;
end;

end.
