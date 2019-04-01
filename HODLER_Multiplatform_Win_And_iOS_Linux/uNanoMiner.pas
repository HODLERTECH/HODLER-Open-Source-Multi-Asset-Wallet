unit uNanoMiner;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes,
  System.Variants, StrUtils,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs, Nano,
  System.IOUtils, misc, FMX.Styles, FMX.Layouts, FMX.Platform,
  FMX.StdCtrls, FMX.Menus, FMX.ListBox, FMX.Controls.Presentation
{$IFNDEF LINUX}, Windows,
  FMX.Platform.Win, WinApi.ShellApi,
  WinApi.Messages, Registry{$ENDIF};
{$IFDEF LINUX} type
  HWND = integer; {$ENDIF}

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
{$IFNDEF LINUX}TrayIconData: TNotifyIconData; {$ENDIF}
    TrayIconAdded: Boolean;
{$IFNDEF LINUX} procedure TrayWndProc(var Message: TMessage); {$ENDIF}
  public
    { Public declarations }
  end;
{$IFNDEF LINUX}

const
  WM_ICONTRAY = WM_USER + 1; {$ENDIF}

var
  frmNanoPoW: TfrmNanoPoW;
  stylo: TStyleManager;
  q1: System.Int64;
  shown: Boolean;
  linuxSecs: integer = 0;

implementation

{$R *.fmx}

procedure saveAccState(acc, conf: string);
var
  ts: TStringList;
begin
  ts := TStringList.Create;
  try
    ts.Text := conf;
    ts.SaveToFile(System.IOUtils.TPath.combine(HOME_PATH, acc + '.state'));
  finally
    ts.Free;
  end;

end;

procedure nano_mineBuilt64(cc: NanoCoin);
var
  block: TNanoBlock;
  lastHash, s: string;
  i: integer;
  isCorrupted: Boolean;
begin
  lastHash := '';
  isCorrupted := false;
  repeat
    block := cc.firstBlock;

    if block.account <> '' then
    begin

      TThread.Synchronize(nil,
        procedure
        begin
          frmNanoPoW.list.Items.Add(block.Hash + '  Account: ' + block.account);
        end);
      if not isCorrupted then
      begin
{$IFNDEF LINUX} q1 := GetTickCount; {$ENDIF}
        hashCounter := 0;
        nano_getWork(block);
        hashCounter := 0;

        s := nano_pushBlock(nano_builtToJSON(block));
        lastHash := StringReplace(s, 'https://www.nanode.co/block/', '',
          [rfReplaceAll]);
        if isHex(lastHash) = false then
        begin

          if LeftStr(lastHash, length('Transaction failed')) = 'Transaction failed'
          then
          begin
            isCorrupted := true;
          end
          else
            saveAccState(block.account, block.balance);

          // showmessage(lasthash);

          lastHash := '';
        end;

        if cc.BlockByPrev(lastHash).account = '' then
          if lastHash <> '' then
            nano_pow(lastHash);

      end;
    end;
    cc.removeBlock(block.Hash);
  until length(cc.pendingChain) = 0;
  loadPows;
  for i := 0 to length(pows) - 1 do
    if pows[i].work = '' then
    begin
      hashCounter := 0;
      nano_pow(pows[i].Hash);
      hashCounter := 0;
    end;
end;

procedure HideAppOnTaskbar(AMainForm: TForm);
var
  AppHandle: HWND;
begin
{$IFNDEF LINUX}
  AppHandle := ApplicationHWND; // GetParent(HWND(AMainForm.Handle));
  ShowWindow(AppHandle, SW_HIDE);
  SetWindowLong(AppHandle, GWL_EXSTYLE, GetWindowLong(AppHandle, GWL_EXSTYLE) or
    WS_EX_TOOLWINDOW); {$ENDIF}
end;

procedure mineAll;
var
  cc: NanoCoin;
  path: string;
  i: integer;
begin
  i := 0;
  try
    repeat
      for path in TDirectory.GetDirectories
        (IncludeTrailingPathDelimiter({$IF DEFINED(LINUX)}System.IOUtils.TPath.
        GetHomePath + '/.hodlertech'{$ELSE}System.IOUtils.TPath.combine
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
      inc(i);
    until i = 2;
    halt(0);
  except
    on E: Exception do
    begin
      mineAll();
    end;
  end;
end;

procedure TfrmNanoPoW.FormCloseQuery(Sender: TObject; var CanClose: Boolean);
begin
  CanClose := false;
{$IFNDEF LINUX} frmNanoPoW.Hide; {$ELSE}WindowState := TWindowState.wsMinimized;
{$ENDIF}
end;

procedure TfrmNanoPoW.FormDestroy(Sender: TObject);
begin
{$IFNDEF LINUX}Shell_NotifyIcon(NIM_DELETE, @TrayIconData);
  DeallocateHWnd(TrayWnd); {$ENDIF}
end;

procedure TfrmNanoPoW.FormShow(Sender: TObject);
begin
  if shown then
    Exit;
  frmNanoPoW.Visible := false;
  shown := true;
end;

procedure TfrmNanoPoW.MenuItem1Click(Sender: TObject);
begin
  frmNanoPoW.Show;
end;

procedure TfrmNanoPoW.MenuItem2Click(Sender: TObject);
var
  x: integer;
begin
  x := MessageDlg
    ('CAUTION! If you kill NanoPoW, it won''t mine any pending or send block from Hodler Wallet, do you really want to kill process?',
    TMsgDlgType.mtConfirmation, mbYesNo, 0);
  if x = mrYes then
    Application.Terminate;

end;
{$IFNDEF LINUX}

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
{$ENDIF}

procedure TfrmNanoPoW.SpeedCounterTimer(Sender: TObject);
var
  s: Cardinal;
  speed: single;
  ss: pchar;
begin
  HideAppOnTaskbar(frmNanoPoW);
  s := {$IFNDEF LINUX}(GetTickCount - q1) div 1000{$ELSE} linuxSecs;
  inc(linuxSecs){$ENDIF};
  if s = 0 then
    s := 1;
  speed := ((hashCounter) div s) / 1000;
  frmNanoPoW.Caption := 'Nano PoW Speed: ' + FloatToStrF(speed, ffGeneral, 8, 2)
    + ' kHash/s';
{$IFDEF LINUX} hashCounter := 0;
  linuxSecs := 1 {$ENDIF}
{$IFNDEF LINUX}
    with TrayIconData
  do
  begin
    cbSize := SizeOf();
    Wnd := TrayWnd; // was before Wnd:= FmxHandleToHWND(self.Handle);
    uID := 0;
    uFlags := NIF_MESSAGE + NIF_ICON + NIF_TIP;
    uCallbackMessage := WM_ICONTRAY;
    hIcon := GetClassLong(FmxHandleToHWND(self.Handle), GCL_HICONSM);
  end;
  ss := pchar(frmNanoPoW.Caption);
  StrLCopy(TrayIconData.szTip, pchar(ss), High(TrayIconData.szTip));

  Shell_NotifyIcon(NIM_MODIFY, @TrayIconData); {$ENDIF}
end;
{$IFNDEF LINUX}

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
{$ENDIF}

procedure TfrmNanoPoW.FormCreate(Sender: TObject);
begin   shown:=false;
  frmNanoPoW.Windowstate:=TWindowState.wsMinimized;
  HideAppOnTaskbar(frmNanoPoW);
 {$IFNDEF LINUX} frmNanoPoW.Hide; {$ELSE}WindowState := TWindowState.wsMinimized;
{$ENDIF}
  HOME_PATH := IncludeTrailingPathDelimiter
    ({$IF DEFINED(LINUX64)}System.IOUtils.TPath.GetHomePath + '/.hodlertech'
{$ELSE}System.IOUtils.TPath.combine(System.SysUtils.GetEnvironmentVariable
    ('APPDATA'), 'hodlertech'){$ENDIF});
{$IFNDEF LINUX} TrayWnd := AllocateHWnd(TrayWndProc);
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
  q1 := GetTickCount; {$ENDIF}
  stylo := TStyleManager.Create;
  stylo.TrySetStyleFromResource('MINER_STYLE');

  TThread.CreateAnonymousThread(
    procedure
    begin
      mineAll()
    end).Start;
{$IFNDEF LINUX} frmNanoPoW.Visible := false;
  RunOnStartupHKCU(ParamStr(0));
{$ENDIF}
  frmNanoPoW.Visible := true;
  shown := false;
end;

end.
