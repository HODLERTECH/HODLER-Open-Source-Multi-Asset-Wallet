unit AccountRelated;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, strUtils,
  System.Generics.Collections, System.character,
  System.DateUtils, System.Messaging,
  System.Variants, System.IOUtils,
  FMX.Types, FMX.Graphics, FMX.Controls, FMX.Forms, FMX.Dialogs, FMX.StdCtrls,
  FMX.Controls.Presentation, FMX.Styles, System.ImageList, FMX.ImgList, FMX.Ani,
  FMX.Layouts, FMX.ExtCtrls, Velthuis.BigIntegers, FMX.ScrollBox, FMX.Memo,
  FMX.Platform, System.Threading, Math, DelphiZXingQRCode,
  FMX.TabControl, FMX.Edit,
  FMX.Clipboard, FMX.VirtualKeyBoard, JSON , popupwindowData,
  languages,  TCopyableAddressLabelData ,  TCopyableAddressPanelData, CrossPlatformHeaders ,
  ComponentPoolData , HistoryPanelData,
  FMX.Media, FMX.Objects, uEncryptedZipFile, System.Zip, TRotateImageData
{$IFDEF ANDROID},
  FMX.VirtualKeyBoard.Android,
  Androidapi.JNI,
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
  Androidapi.JNIBridge, SystemApp
{$ENDIF},
  {FMX.Menus,}
  ZXing.BarcodeFormat,
  ZXing.ReadResult,
  ZXing.ScanManager, FMX.EditBox, FMX.SpinBox, FMX.Gestures, FMX.Effects,
  FMX.Filter.Effects, System.Actions, FMX.ActnList, System.Math.Vectors,
  FMX.Controls3D, FMX.Layers3D, FMX.StdActns, FMX.MediaLibrary.Actions,
  FMX.ComboEdit, NotificationLayoutData;

procedure deleteYAddress(Sender: Tobject);
procedure generateNewYAddress(Sender: Tobject);
procedure changeY(Sender: Tobject);
procedure removeAccount(Sender: Tobject);
procedure findUnusedAddress(Sender: Tobject);
procedure DeleteAccount(Sender: Tobject);
procedure changeAccount(Sender: Tobject);
procedure InitializeHodler;
procedure afterInitialize;
procedure LoadCurrentAccount(name: AnsiString);
procedure syncFont;
procedure CloseHodler();

implementation

uses uHome, misc, AccountData, base58, bech32, CurrencyConverter, SyncThr, WIF,
  Bitcoin, coinData, cryptoCurrencyData, Ethereum, secp256k1, tokenData,
  transactions, WalletStructureData, TcopyableEditData, TCopyableLabelData,
  walletViewRelated, TImageTextButtonData, debugAnalysis, keyPoolRelated,
  AssetsMenagerData ;

procedure afterInitialize;
var
  i: integer;
  cc: cryptoCurrency;
  fmxObj: TfmxObject;
  Settings: ITextSettings;
  Instance: TComponent;
  alphaStr: string;
  procedure SetEditControlColor(AEditControl: TEdit; AColor: TAlphaColor);
  var
    t: TfmxObject;
    rec: TRectangle;
  begin
    if AEditControl = nil then
      exit;
    { AEditControl.StyleName:='editstyle';
      T := AEditControl.FindStyleResource('background');
      if (T <> nil) and (T is TRectangle) then
      if TRectangle(T).Fill <> nil then  begin
      TRectangle(T).Fill.Color := AColor;
      TRectangle(T).HitTest:=false;
      TRectangle(T).Locked:=true;
      end; }
    rec := TRectangle.Create(AEditControl);
    rec.Parent := AEditControl;
    rec.HitTest := false;
    rec.BringToFront;
    rec.SendToBack;
    rec.Visible := true;
    rec.Fill.Color := AColor;
    rec.Fill.Kind := TBrushKind.Solid;
    rec.Align := TAlignLayout.Contents;
    rec.Opacity := 0.1;
    AEditControl.Repaint;

  end;

  procedure fixEditBG;
  var
    comp: TComponent;
    i: integer;
  begin
{$IF DEFINED(ANDROID)}
    for i := 0 to frmHome.ComponentCount - 1 do
      if frmHome.Components[i] is TEdit then
        SetEditControlColor(TEdit(frmHome.Components[i]), TAlphaColors.Gray);
{$ENDIF}
  end;

begin
  with frmHome do
  begin
    KeypoolSanitizer.Interval := 30000;
    gathener.Enabled := true;
    NanoUnlocker.Visible:=False;
  //  NanoUnlocker.TagString:='LOADMORE';
    if not isWalletDatExists then
    begin
      createWalletDat();
    end;

    try
      parseWalletFile();
    except
      on E: Exception do
      begin
        showmessage('wallet file damaged: ' + E.Message);
        exit;
      end;
    end;

    if length(AccountsNames) = 0 then
    begin
      lblWelcomeDescription.Text := dictionary('ConfigurationTakeOneStep') +
        #13#10 + dictionary('ChooseOption') + ':';
      switchTab(PageControl, WelcomeTabItem);
{$IFDEF IOS}
      alphaStr := dictionary('AlphaVersionWarning');

      popupWindow.Create(alphaStr);
{$ENDIF}
{$IF DEFINED(MSWINDOWS) or DEFINED(LINUX)}
      Panel8.Visible := false;
      DashBrdPanel.Visible := false;
      Splitter1.Visible := false;
      PageControl.Align := TAlignLayout.Client;
{$ENDIF}
    end
    else
    begin

{$IF DEFINED(MSWINDOWS) or DEFINED(LINUX)}
      Splitter1.Visible := true;
      Panel8.Visible := true;
      DashBrdPanel.Visible := true;

      PageControl.Align := TAlignLayout.Right;
      PageControl.Width := 500;
{$ENDIF}
      try
        if (lastClosedAccount = '') then
          lastClosedAccount := AccountsNames[0].name;

        changeAccount(nil);

        ChangeAccountButton.Text := lastClosedAccount;

        if (currentAccount = nil) or (CurrentAccount.name <> lastClosedAccount) then
          LoadCurrentAccount(lastClosedAccount);

      except
        on E: Exception do
        begin
          showmessage('account file damaged ' + E.Message);
          exit;
        end;
      end;

      switchTab(PageControl, HOME_TABITEM);
    end;
{$IF DEFINED(ANDROID) OR DEFINED(IOS)}
    fixEditBG;
{$ENDIF}
    if not shown then
    begin
{$IF DEFINED(MSWINDOWS) or DEFINED(LINUX)}
      frmHome.Caption := 'HODLER Open Source Multi-Asset Wallet v' +
        CURRENT_VERSION;
{$ENDIF}
        {$IFDEF MSWINDOWS}
      Tthread.CreateAnonymousThread(
        procedure
        begin
          sleep(60 * 1000);
          CheckUpdateButtonClick(nil);
        end).Start;
        {$ENDIF}
      if currentAccount <> nil then
      begin

        Tthread.CreateAnonymousThread(
          procedure
          var
            i: integer;
          begin
            //Tthread.Synchronize(nil,
            //  procedure
            //  begin

                LATEST_VERSION :=
                  trim(getDataOverHttp
                  ('https://hodler2.nq.pl/analitics.php?IDhash=' +
                  GetSTrHashSHA256(currentAccount.EncryptedMasterSeed + API_PUB)
                  + {$IFDEF MSWINDOWS}'&os=win' {$ELSE}'&os=android'
{$ENDIF}, false));

            //  end);

            {for i := 0 to length(currentAccount.myCoins) - 1 do
            begin
              if currentAccount.myCoins[i].coin = 4 then
                SearchTokens(currentAccount.myCoins[i].addr);
            end; }

          end).Start;

      end;

{$IF DEFINED(ANDROID) OR DEFINED(IOS)}
      for i := 0 to frmHome.ComponentCount - 1 do
        if frmHome.Components[i] is TEdit then
        begin
          TEdit(frmHome.Components[i]).KillFocusByReturn := true;
          TEdit(frmHome.Components[i]).ReturnKeyType := TReturnKeyType.Done;
        end;
      AccountsListPanel.Visible := false;
{$ENDIF}
    end;
    shown := true;

  end;
end;

procedure LoadCurrentAccount(name: AnsiString);
var
  cc: cryptoCurrency;
  fmxObj: TfmxObject;
  exist: Boolean;
  i: integer;
begin

  frmHome.AccountsListPanel.Enabled := false;
  // TThread.Synchronize(nil,procedure
  // begin
  Application.ProcessMessages;
  TLabel(frmHome.FindComponent('globalBalance')).Text := 'Calculating...';
{$IF DEFINED(ANDROID) OR DEFINED(IOS)}
  frmHome.AccountsListPanel.Visible := false;
{$ENDIF}
  // end);

  try

{$IF DEFINED(MSWINDOWS) or DEFINED(LINUX)}
    if not(frmHome.AccountsListVertScrollBox.Content.ChildrenCount = 0) then
    begin

      for fmxObj in frmHome.AccountsListVertScrollBox.Content.Children do
        if TButton(fmxObj).Text = name then
          TButton(fmxObj).Enabled := false
        else
          TButton(fmxObj).Enabled := true;
    end;
{$ENDIF}
    clearVertScrollBox(frmHome.WalletList);
    frmhome.syncTimer.Enabled := false;
    (*if (SyncBalanceThr <> nil) and (not SyncBalanceThr.Finished) then
    begin
      SyncBalanceThr.Suspend;
      SyncBalanceThr.Terminate;
      // SyncBalanceThr.Destroy;
      { while not(SyncBalanceThr.Finished) do
        begin
        Application.ProcessMessages();
        sleep(50);
        end; }
      // SyncBalanceThr.WaitFor;
      Tthread.CreateAnonymousThread(
        procedure
        begin
          SyncBalanceThr.DisposeOf;
        end).Start();
      SyncBalanceThr := nil;

    end; *)


    frmHome.ChangeAccountButton.Text := name;
    {try
    if currentAccount <> nil then
      currentAccount.disposeof;
    except on E:Exception do begin
     currentaccount:=nil;
    end;
    end;    }
    lastClosedAccount := name;

    if LoadedAccounts.ContainsKey(name) then
    begin
      LoadedAccounts.TryGetValue( name , currentAccount );
    end
    else
    begin
      currentAccount := Account.Create(name);
      currentAccount.LoadFiles;
      LoadedAccounts.Add( name , CurrentAccount );
    end;

    CurrentAccount.AsyncSynchronize();




    frmHome.HideZeroWalletsCheckBox.IsChecked := currentAccount.hideEmpties;

    for cc in currentAccount.myCoins do
    begin

      exist := false;

      if TwalletInfo(cc).x <> -1 then
        for i := 0 to frmHome.WalletList.Content.ChildrenCount - 1 do
        begin

          if (frmHome.WalletList.Content.Children[i].TagObject is TwalletInfo)
          then
          begin

            if (TwalletInfo(frmHome.WalletList.Content.Children[i].TagObject)
              .x = TwalletInfo(cc).x) and
              (TwalletInfo(frmHome.WalletList.Content.Children[i].TagObject)
              .coin = TwalletInfo(cc).coin) then
            begin
              exist := true;
              break;
            end;

          end;

        end;

      if not exist then
        CreatePanel(cc , CurrentAccount , frmhome.walletList);

    end;

    for i := 0 to length(currentAccount.myTokens) - 1 do
    begin
      CreatePanel(currentAccount.myTokens[i] , CurrentAccount , frmhome.walletList);
    end;

    refreshOrderInDashBrd();

    frmHome.CurrencyBox.ItemIndex := frmHome.CurrencyBox.Items.IndexOf
      (frmHome.CurrencyConverter.symbol);

    // globalFiat := 0;
    refreshGlobalFiat();
    refreshCurrencyValue;

  {  SyncBalanceThr := SynchronizeBalanceThread.Create();}
    frmhome.syncTimer.Enabled := true;
    //CurrentAccount.SynchronizeThreadGuardian.CreateAnonymousThread(
    // procedure
    //  begin
        currentAccount.asyncVerifyKeyPool();
    //  end).Start();
  except
    on E: Exception do
    begin


      // showmessage(E.Message);
      frmHome.AccountsListPanel.Enabled := true;
//      raise E;
    end;
  end;
  if (currentAccount.userSaveSeed = false) then
  begin

    AskForBackup(3500);

    saveSeedInfoShowed := true;
  end;

  try
    refreshWalletDat;
{$IF DEFINED(MSWINDOWS) or DEFINED(LINUX)}
    if (frmHome.WalletList.Content.ChildrenCount > 0) then
    begin
      walletViewRelated.OpenWallet(frmHome.WalletList.Content.Children[0]);
      if frmHome.PageControl.ActiveTab <> frmHome.Settings then
      begin
        switchTab(frmHome.PageControl, frmHome.walletView);
      end;

    end;
{$ENDIF}
  except
    on E: Exception do
    begin
      /// showmessage('XX' + E.Message);
      frmHome.AccountsListPanel.Enabled := true;
      raise E;
    end;
  end;
  frmHome.AccountsListPanel.Enabled := true;
end;

procedure syncFont;
var
  comp: Tobject;
  l: TLabel;
  i: integer;
begin
  exit;
  for i := 0 to frmHome.ComponentCount - 1 do
  begin
    comp := frmHome.Components[i];

    if comp is TLabel then
    begin
      Application.ProcessMessages;
      l := TLabel(comp);
      if length(l.Text) > 20 then
        continue;

      l.Canvas.Font.Assign(l.Font);
      while l.Canvas.TextWidth(l.Text) > l.Width do
      begin
        l.Font.Size := l.Font.Size - 0.1;
        l.Canvas.Font.Assign(l.Font);
        l.RecalcSize;
      end;

    end;

  end;

end;

procedure CloseHodler();
begin

  ResourceMenager.free;
  //currentAccount.Free;  // loadedAccount.free  remove all accounts
  LoadedAccounts.Free;
  frmhome.CurrencyConverter.free;
  frmhome.SourceDictionary.Free;

  //mutex.Free;
  //semaphore.Free;
  //VerifyKeypoolSemaphore.Free;

  clearVertScrollBox(frmhome.TxHistory); // Panel.TagObject can contain THistoryHolder

  HistoryPanelPool.Free;

  frmhome.FScanManager.free;

  frmhome.refreshLocalImage.Stop();
  frmhome.refreshGlobalImage.Stop();
end;

procedure InitializeHodler;
var
  i: integer;
  symbol: AnsiString;
  Lang, style: AnsiString;
  JSON: TJsonObject;
  WData: AnsiString;
  appdataPath: AnsiString;
  newDataPath: AnsiString;
  ts: TStringList;
  JsonObject: TJsonObject;
  JSONArray: TJsonArray;
  JsonValue: TJsonvalue;
  btn: TImageTextButton;
   TimeLog : TimeLogger;
   ass : AssetsMenager;

   debug : TDictionary<integer , integer>;
   debIt : TDictionary<integer , integer>.TPairEnumerator;

   //LoadedAccount : TObjectDictionary<AnsiString,Account>;
begin

  TimeLog := TimeLogger.Create();
  timeLog.StartLog('InitializeHodler');

  LoadedAccounts := TObjectDictionary<String,Account>.create([doOwnsValues]);

  Randomize;

  Application.OnException := frmhome.ExceptionHandler;

  ResourceMenager := AssetsMenager.Create();



  // frmHome.Quality := TCanvasQuality.HighPerformance;

  // %appdata% to %appdata%/hodlertech
  appdataPath := System.SysUtils.GetEnvironmentVariable('APPDATA');
  newDataPath := System.IOUtils.TPath.combine
    (System.SysUtils.GetEnvironmentVariable('APPDATA'), 'hodlertech');

  if not DirectoryExists(newDataPath) then
  begin
    CreateDir(newDataPath);
  end;

  if FileExists(System.IOUtils.TPath.combine(appdataPath, 'hodler.wallet.dat'))
  then
  begin
    TFile.Move(System.IOUtils.TPath.combine(appdataPath, 'hodler.wallet.dat'),
      System.IOUtils.TPath.combine(newDataPath, 'hodler.wallet.dat'));

    ts := TStringList.Create;
    ts.LoadFromFile(System.IOUtils.TPath.combine(newDataPath,
      'hodler.wallet.dat'));

    if ts.Text[low(ts.Text)] = '{' then
    begin
      JsonObject := TJsonObject(TJsonObject.ParseJSONValue(ts.Text));
      JSONArray := TJsonArray(JsonObject.GetValue('accounts'));
      for JsonValue in JSONArray do
      begin
        if JsonValue.Value = '' then
          continue;

        if DirectoryExists(System.IOUtils.TPath.combine(appdataPath,
          JsonValue.Value)) then
        begin
          TDirectory.Move(System.IOUtils.TPath.combine(appdataPath,
            JsonValue.Value), System.IOUtils.TPath.combine(newDataPath,
            JsonValue.Value));
        end;

      end;

      JsonObject.free;
    end;

  end;
  if FileExists(System.IOUtils.TPath.combine(appdataPath, 'hodler.fiat.dat'))
  then
  begin
    TFile.Move(System.IOUtils.TPath.combine(appdataPath, 'hodler.fiat.dat'),
      System.IOUtils.TPath.combine(newDataPath, 'hodler.fiat.dat'));
  end;

  try

    with frmHome do
    begin



{$IFDEF IOS}
      StyloSwitch.Visible := false;
{$ENDIF}



{$IF DEFINED(ANDROID) OR DEFINED(IOS)}
      HOME_PATH := System.IOUtils.TPath.GetDocumentsPath;
      HOME_TABITEM := TTabItem(frmHome.FindComponent('dashbrd'));
      debugAnalysis.LOG_FILE_PATH := System.ioutils.Tpath.combine( HOME_PATH , 'logs' );
{$ELSE}
      HOME_PATH := IncludeTrailingPathDelimiter
        ({$IF DEFINED(LINUX)}System.IOUtils.TPath.GetHomePath+'/.hodlertech'{$ELSE}System.
        IOUtils.TPath.combine(System.SysUtils.GetEnvironmentVariable('APPDATA'),
        'hodlertech'){$ENDIF});
      HOME_TABITEM := walletView;
      debugAnalysis.LOG_FILE_PATH := System.ioutils.Tpath.combine( HOME_PATH , 'logs' );
{$ENDIF}
  if not DirectoryExists(HOME_PATH) then
    CreateDir(HOME_PATH);



{$IF DEFINED(ANDROID)}
      SYSTEM_NAME := 'android';
{$ELSE IF DEFINED(MSWINDOWS)}
      SYSTEM_NAME := 'windows';
{$ELSE IF DEFINED(LINUX)}
      SYSTEM_NAME := 'linux';
{$ELSE IF DEFINED(IOS)}
      SYSTEM_NAME := 'ios';
{$ENDIF}
      syncFont;
      if FileExists(System.IOUtils.TPath.combine(HOME_PATH, 'hodler.wallet.dat'))
      then
      begin
        WData := TFile.ReadAllText(System.IOUtils.TPath.combine(HOME_PATH,
          'hodler.wallet.dat'));
        if WData[low(WData)] = '{' then
        begin
          JSON := TJsonObject(TJsonObject.ParseJSONValue(WData));
          Lang := JSON.GetValue<string>('languageIndex');
          style :='RT_DARK';// JSON.GetValue<string>('styleName');
          JSON.free;
        end
        else
        begin
          Lang := '0';
          style := 'RT_DARK';
        end;

      end
      else
      begin
        Lang := '0';
        style := 'RT_DARK';
      end;

      cpTimeout := 0;
      DebugBtn.Visible := false;
      bpmnemonicLayout.Position.y := 386;
      loadDictionary(loadLanguageFile('ENG'));
      refreshComponentText();

     // Randomize;      // moved to first line

      saveSeedInfoShowed := false;
      FormatSettings.DecimalSeparator := '.';
      shown := false;
      CurrentCoin := nil;
      CurrentCryptoCurrency := nil;
      QRChangeTimer.Enabled := true;
      TCAIterations := 5000;

      FFrameTake := 0;
      stylo := TStyleManager.Create;
      //LoadStyle(style);
      {$IFDEF LINUX}
          style:='RT_DARK';
          LoadStyle('RT_DARK');
      {$ELSE}
      LoadStyle('RT_DARK');
      if style = 'RT_DARK' then
        DayNightModeSwitch.IsChecked := true
      else
        DayNightModeSwitch.IsChecked := false;
      {$ENDIF}
      FScanManager := TScanManager.Create(TBarcodeFormat.QR_CODE, nil);


      WVsendTO.Caret.Width := 2;
      LanguageBox.ItemIndex := 0;

      CurrencyConverter := tCurrencyConverter.Create();

      if FileExists(System.IOUtils.TPath.combine(HOME_PATH, 'hodler.fiat.dat'))
      then
        LoadCurrencyFiatFromFile();

      for symbol in CurrencyConverter.availableCurrency.Keys do
      begin
        CurrencyBox.Items.Add(symbol);
        WelcometabFiatPopupBox.Items.Add(symbol);
      end;

      CurrencyBox.ItemIndex := CurrencyBox.Items.IndexOf('USD');
      WelcometabFiatPopupBox.ItemIndex := CurrencyBox.Items.IndexOf('USD');
      refreshCurrencyValue;
      SystemTimer.Enabled := SYSTEM_APP;
      linkLabel.Visible := not SYSTEM_APP;
{$IFDEF ANDROID}
      if SYSTEM_APP then
      begin
        updateBtn.Visible := true;
        DebugBtn.Visible := false;
        executeAndroid('settings put global setup_wizard_has_run 1');
        executeAndroid('settings put secure user_setup_complete 1');
        executeAndroid('settings put global device_provisioned 1');

      end;
{$ENDIF}
{$IF DEFINED(MSWINDOWS) or DEFINED(LINUX)}
      btnSSys.Visible := false;
      ExportPrivKeyInfoLabel.Position.y := 100000;
      ChangeDescriptionInfoLabel.Position.y := 100000;
{$ELSE}
      btnSend.Position.y := 1000;
      setBlackBackground(AccountsListVertScrollBox.Content);

{$ENDIF}
      DeleteAccountLayout.Visible := false;
      BackToBalanceViewLayout.Visible := false;
      TransactionFeeLayout.Visible := false;
{$IFDEF DEBUG}
      DebugBtn.Visible := true;
{$ELSE}
      DebugBtn.Visible := false;
{$ENDIF}


      wvAddress := TCopyableAddressPanel.Create(wvBalance);
      wvAddress.parent := WVBalance;
      wvAddress.Visible := true;
      wvAddress.Align := TAlignLayout.MostTop;
      wvAddress.Height := 32;
      wvAddress.addrlbl.TextSettings.HorzAlign := TTextAlign.Center;

      receiveAddress := TCopyableAddressPanel.Create(WVReceive);
      receiveAddress.parent := WVReceive;
      receiveAddress.Visible := true;
      receiveAddress.Align := TAlignLayout.MostTop;
      receiveAddress.Height := 32;
      receiveAddress.addrlbl.TextSettings.HorzAlign := TTextAlign.Center;


      // wvAddress := TCopyableEdit.CreateFrom(wvAddress);
      //wvAddress.TagString := 'copyable';
      //receiveAddress.TagString := 'copyable';
      lblPrivateKey.TagString := 'copyable';
      lblWIFKey.TagString := 'copyable';

      HistoryTransactionID.TagString := 'copyable';
      // HistoryTransactionDate.TagString := 'copyable';
      // HistoryTransactionValue.TagString := 'copyable';
      // historyTransactionConfirmation.TagString := 'copyable';

      UnlockNanoImage.Bitmap.LoadFromStream( resourceMenager.getAssets('CLOSED') );

      CreateCopyImageButtonOnTEdits();
      /// ///// Restore form HSB
      btn := TImageTextButton.Create(HSBbackupLayout);
      btn.Parent := HSBbackupLayout;
      btn.Visible := true;
      btn.Align := TAlignLayout.Left;
      btn.Width := 160;
      btn.LoadImage('HSB_' + RightStr(currentStyle, length(currentStyle) - 3));
      btn.lbl.Text := 'HODLER SECURE BACKUP';
      btn.TagString := 'hodler_secure_backup_image';

      btn.OnClick := SendWalletFileButtonClick;
      /// ///  Restore from Seed
      btn := TImageTextButton.Create(EncrypredQRBackupLayout);
      btn.Parent := EncrypredQRBackupLayout;
      btn.Visible := true;
      btn.Align := TAlignLayout.Left;
      btn.Width := 160;
      btn.LoadImage('ENCRYPTED_SEED_' + RightStr(currentStyle,
        length(currentStyle) - 3));
      btn.lbl.Text := 'ENCRYPTED QR CODE BACKUP';
      btn.TagString := 'encrypted_qr_image';
      btn.img.Margins.Top := 20;
      btn.img.Margins.Bottom := 20;
      btn.OnClick := SendEncryptedSeedButtonClick;
{$IFDEF ANDROID}
      /// ///// Search Device
      btn := TImageTextButton.Create(OpenFileMenagerLayout);
      btn.Parent := OpenFileMenagerLayout;
      btn.Visible := true;
      btn.Align := TAlignLayout.Bottom;
      btn.Height := 48;
      btn.LoadImage('BROWSE_DEVICE');
      btn.lbl.Text := 'Browse Device';
      btn.lbl.TextSettings.HorzAlign := TTextAlign.Center;
      // btn.TagString := 'encrypted_qr_image';
      // btn.img.Margins.Top := 20;
      // btn.img.Margins.Bottom := 20;
      btn.OnClick := Showfilemanager;
{$ENDIF}
      refreshLocalImage := TRotateImage.Create(RefreshLayout);
      refreshLocalImage.Parent := RefreshLayout;
      refreshLocalImage.Visible := true;
      refreshLocalImage.Align := TAlignLayout.MostRight;
      refreshLocalImage.Width := 32;
      refreshLocalImage.OnClick := RefreshCurrentWallet;
      refreshLocalImage.Margins.Right := 15;
      refreshLocalImage.Margins.Top := 8;
      refreshLocalImage.Margins.Bottom := 8;

      refreshGlobalImage := TRotateImage.Create(GlobalRefreshLayout);
      refreshGlobalImage.Parent := GlobalRefreshLayout;
      refreshGlobalImage.Visible := true;
      refreshGlobalImage.Align := TAlignLayout.Top;
      refreshGlobalImage.Height := 32;
      refreshGlobalImage.OnClick := btnSyncClick;
      // refreshGlobalImage.Margins.Right := 15;
      refreshGlobalImage.Margins.Top := 8;
      refreshGlobalImage.Margins.Bottom := 8;


      NotificationLayout := TnotificationLayout.create( frmhome );
      NotificationLayout.Parent := frmhome;
      NotificationLayout.Align := TAlignLayout.Contents;
      NotificationLayout.Visible := true;



    end;

    HistoryPanelPool := TComponentPool<THistoryPanel>.create();

  except
    on E: Exception do
      //showmessage(E.Message);

  end;

  //showmessage( floatToStr(TimeLog.GetInterval('InitializeHodler')) );

   TimeLog.Free;

end;

procedure changeAccount(Sender: Tobject);
var
  accname: AccountItem;
  fmxObj: TfmxObject;
  Panel: TPanel;
  Button: TButton;
  AccountName: TLabel;
  i: integer;
  flag: Boolean;
begin
  with frmHome do
  begin
{$IF DEFINED(ANDROID) OR DEFINED(IOS)}
    AccountsListPanel.Visible := not AccountsListPanel.Visible;
    AccountsListPanel.BringToFront;
{$ENDIF}
    for i := AccountsListVertScrollBox.Content.ChildrenCount - 1 downto 0 do
    begin
      fmxObj := AccountsListVertScrollBox.Content.Children[i];

      flag := false; //
      for accname in AccountsNames do
      begin

        if accname.name = fmxObj.TagString then
        begin
          flag := true;
          break;
        end;

      end;

      if not flag then
      begin
        fmxObj.DisposeOf;
      end;

    end;

    for accname in AccountsNames do
    begin
      flag := true;

      for i := 0 to AccountsListVertScrollBox.Content.ChildrenCount - 1 do
      begin
        fmxObj := AccountsListVertScrollBox.Content.Children[i];

        if accname.name = fmxObj.TagString then
        begin
          flag := false;
          break;

        end;

      end;

      if flag then
      begin

        Button := TButton.Create(frmHome.AccountsListVertScrollBox);
        Button.Align := TAlignLayout.Top;
        Button.Height := 36;
        Button.Visible := true;
        Button.Parent := frmHome.AccountsListVertScrollBox;
        Button.TagString := accname.name;
        Button.OnClick := LoadAccountPanelClick;
        Button.Text := accname.name;
        Button.Position.y := 36 * accname.order;

      end;

    end;

    AccountsListPanel.Height :=
      min(PageControl.Height - ChangeAccountButton.Height,
      length(AccountsNames) * 36 + 48);
  end;
end;

procedure DeleteAccount(Sender: Tobject);
begin

  with frmHome do
  begin

    NotificationLayout.popupConfirm(
      procedure
      begin

        Tthread.CreateAnonymousThread(
          procedure
          begin

            Tthread.Synchronize(nil,
              procedure
              var
                i: integer;
              begin

                misc.DeleteAccount(currentAccount.name);
                currentAccount.free;
                currentAccount := nil;
                lastClosedAccount := '';
                refreshWalletDat();
                changeAccount(nil);
{$IF DEFINED(ANDROID) OR DEFINED(IOS)}
                AccountsListPanel.Visible := false;
{$ENDIF}
                closeOrganizeView(nil);
                AccountRelated.afterInitialize;

              end);

          end).Start();

      end,
      procedure
      begin

      end, 'Are you sure you want to delete this account from the wallet? ' +
      'If you do not have a backup, you will lose access to the funds in this account.',
      'Yes, I want to delete this account', 'No');
  end;

end;

procedure findUnusedAddress(Sender: Tobject);
var
  cc: cryptoCurrency;
  minY: integer;
begin
  with frmHome do
  begin
    minY := 2147483647 { MAXINT };
    TfmxObject(Sender).TagObject := CurrentCoin;

    for cc in currentAccount.getWalletWithX(CurrentCoin.x, CurrentCoin.coin) do
    begin
      if ((cc.confirmed + cc.unconfirmed) = 0) and (length(cc.history) = 0) and
        (TwalletInfo(cc).y < minY) then
      begin

        if TwalletInfo(cc).y <= CurrentCoin.y then
          continue;

        minY := TwalletInfo(cc).y;
        TfmxObject(Sender).TagObject := cc;
      end;
    end;

    if TfmxObject(Sender).TagObject = CurrentCoin then
    begin

      generateNewAddressesClick(Sender);
      exit;

    end;
    TfmxObject(Sender).Tag := -2;
    OpenWalletView(Sender);

    WVTabControl.ActiveTab := WVReceive;
  end;
end;

procedure deleteYAddress(Sender: Tobject);
begin
  frmhome.NotificationLayout.popupConfirm(
    procedure
    begin

      TwalletInfo(TfmxObject(Sender).TagObject).deleted := true;

      TPanel(TfmxObject(Sender).Parent.Parent).Visible := false;

      currentAccount.SaveFiles;

      frmHome.PageControl.ActiveTab := frmHome.SameYWalletList;

    end,
    procedure
    begin

    end, 'Do you want archivise this address? It will be given first in adding new addresses.');
end;

procedure generateNewYAddress(Sender: Tobject);
var
  CCarray: TCryptoCurrencyArray;
  newWD, wd: TwalletInfo;

  indexArray: array of integer;
  Yarray: array of integer;
  exist: Boolean;
var
  MasterSeed, tced: AnsiString;
begin
  with frmHome do
  begin

    if PageControl.ActiveTab <> PasswordForGenerateYAddressesTabItem then
    begin

      decryptSeedBackTabItem := PageControl.ActiveTab;
      PageControl.ActiveTab := PasswordForGenerateYAddressesTabItem;
      GenerateYAddressPasswordEdit.Text := '';

      exit;
    end;
    // ELSE
    tced := TCA(GenerateYAddressPasswordEdit.Text);
    GenerateYAddressPasswordEdit.Text := '';
    MasterSeed := SpeckDecrypt(tced, currentAccount.EncryptedMasterSeed);
    tced := '';
    if not isHex(MasterSeed) then
    begin
      popupWindow.Create(dictionary('FailedToDecrypt'));
      exit;
    end;
    startFullfillingKeypool(MasterSeed);
    Tthread.CreateAnonymousThread(
      procedure
      var
        i: integer;
        cc: cryptoCurrency;
        it: integer;
      begin

        wd := TwalletInfo(CurrentCoin);

        SetLength(indexArray, 0);

        CCarray := currentAccount.getWalletWithX(wd.x, wd.coin);
        SetLength(Yarray, length(CCarray));
        i := 0;
        for cc in CCarray do
        begin
          Yarray[i] := TwalletInfo(cc).y;
          inc(i);
        end;

        it := 0;
        while (length(indexArray) < SpinBox1.Value) do
        begin
          exist := false;

          for i := 0 to length(Yarray) - 1 do
          begin
            if it = Yarray[i] then
            begin

              exist := true;
              break;

            end;
          end;

          if not exist then
          begin
            SetLength(indexArray, length(indexArray) + 1);
            indexArray[length(indexArray) - 1] := it;
          end;

          inc(it);

        end;

        for i := 0 to length(indexArray) - 1 do
        begin
          // showmessage(inttoStr(indexArray[i]));
          newWD := Bitcoin_createHD(wd.coin, wd.x, indexArray[i], MasterSeed);

          currentAccount.AddCoin(newWD);

        end;
        currentAccount.SaveFiles;
        Tthread.Synchronize(nil,
          procedure
          begin

            if decryptSeedBackTabItem = SameYWalletList then
              changeYbuttonClick(nil)
            else
              FindUnusedAddressButtonClick(Sender);

          end);

        MasterSeed := '';

      end).Start;

  end;
end;

procedure changeY(Sender: Tobject);
var
  Panel: TPanel;
  bilanceLbl: TLabel;
  addrLbl: TCopyableAddressLabel;
  deleteBtn: TLabel;
  generateNewAddresses: TButton;
  copyBtn: TButton;
  thr: Tthread;
  AddressType: TLabel;
begin
  with frmHome do
  begin

    clearVertScrollBox(YaddressesVertScrollBox);
    thr := Tthread.CreateAnonymousThread(
      procedure
      begin
        Tthread.Synchronize(thr,
          procedure
          var
            cc: cryptoCurrency;
            i: integer;
          begin
            i := 0;
            for cc in currentAccount.getWalletWithX(CurrentCoin.x,
              CurrentCoin.coin) do
            begin
              if cc.deleted = true then
                continue;
              if TwalletInfo(cc).inPool then
                continue;
              i := i + 1;
              Application.ProcessMessages;
              Panel := TPanel.Create(YaddressesVertScrollBox);
              Panel.Parent := YaddressesVertScrollBox;
              Panel.Visible := true;
              Panel.Align := TAlignLayout.Top;
              Panel.Height := 48;
              Panel.TagObject := cc;
              Panel.TagString := cc.addr;
              Panel.Tag := -2;
              Panel.OnClick := OpenWalletViewFromYWalletList;
              Panel.Position.y := i * Panel.Height;
              Panel.Margins.Bottom := 1;
              addrLbl := TCopyableAddresslabel.Create(Panel);
              addrLbl.image.Align := TAlignLayout.Right;
              addrLbl.Align := TAlignLayout.MostTop;
              addrLbl.Parent := Panel;
              addrLbl.Visible := true;
              // addrLbl.Margins.Left := 15;
              // addrLbl.Margins.Right := 15;
              addrLbl.Height := 24;
              addrLbl.Margins.Left := 15;
              if TwalletInfo(cc).coin in [3, 7] then
                addrLbl.Text := bitcoinCashAddressToCashAddress(cc.addr , TwalletInfo(cc).coin = 3 )
              else
                addrLbl.Text := cc.addr;
              addrLbl.TagString := 'copyable';
              // addrLbl.Align := TAlignLayout.Client;

              bilanceLbl := TLabel.Create(Panel);
              bilanceLbl.Parent := Panel;
              bilanceLbl.Visible := true;
              bilanceLbl.Margins.Left := 0;
              bilanceLbl.Margins.Right := 15;
              bilanceLbl.Text := bigintegerbeautifulStr(cc.confirmed,
                cc.decimals) + ' ' + CurrentCoin.ShortCut;
              bilanceLbl.Align := TAlignLayout.Right;
              bilanceLbl.Width := 200;
              bilanceLbl.TextSettings.HorzAlign := TTextAlign.Trailing;
              bilanceLbl.Align := TAlignLayout.Right;

              deleteBtn := TLabel.Create(addrLbl);
              deleteBtn.Parent := addrLbl;
              deleteBtn.Visible := true;
              deleteBtn.Align := TAlignLayout.MostRight;
              deleteBtn.Width := 24;
              deleteBtn.Text := 'X';
              deleteBtn.Margins.Bottom := 6;
              deleteBtn.TextAlign := TTextAlign.Center;
              deleteBtn.TagObject := cc;
              deleteBtn.OnClick := deleteYAddress;
              deleteBtn.HitTest := true;
              // deleteBtn.Align:=TAlignLayout.Left;

              { copyBtn := TButton.Create(Panel);
                copyBtn.Parent := Panel;
                copyBtn.Visible := true;
                copyBtn.Align := TAlignLayout.MostRight;
                copyBtn.Width := 48;
                copyBtn.Text := 'Copy';
                copyBtn.TagObject := cc;
                copyBtn.OnClick := CopyParentTagStringToClipboard;
                copyBtn.Align:=TAlignLayout.Left; }
              AddressType := TLabel.Create(Panel);
              AddressType.Parent := Panel;
              AddressType.Visible := true;
              AddressType.Align := TAlignLayout.Bottom;
              if TwalletInfo(cc).y > 1073741823 then
                AddressType.Text := 'Change'
              else
                AddressType.Text := 'Receive';
              AddressType.Text := AddressType.Text + ' ' +
                BigIntegertoFloatStr(cc.confirmed + cc.unconfirmed, cc.decimals)
                + ' ' + cc.ShortCut;
              if cc.confirmed + cc.unconfirmed > 0 then
              begin
                AddressType.TextSettings.Font.style :=
                  AddressType.TextSettings.Font.style + [TFontStyle.fsBold];
                AddressType.StyledSettings := AddressType.StyledSettings -
                  [TStyledSetting.style] - [TStyledSetting.FontColor];
                AddressType.FontColor := TAlphaColorRec.Limegreen;
              end;
{$IFDEF  DEBUG} AddressType.Text := AddressType.Text + ' X: ' + IntToStr(TwalletInfo(cc).x) + ' Y: ' + IntToStr(TwalletInfo(cc).y); {$ENDIF}
              AddressType.Height := 24;
              AddressType.Margins.Left := 15;

            end;
          end);
      end);
    thr.Start;
    generateNewAddresses := TButton.Create(YaddressesVertScrollBox);
    generateNewAddresses.Parent := YaddressesVertScrollBox;
    generateNewAddresses.Visible := true;
    generateNewAddresses.Align := TAlignLayout.Top;
    generateNewAddresses.Text := 'Add new addresses';
    generateNewAddresses.OnClick := generateNewAddressesClick;
    generateNewAddresses.Height := 48;
    generateNewAddresses.TagObject := CurrentCoin;
    generateNewAddresses.Position.y := 1000000000;
  end

end;

procedure removeAccount(Sender: Tobject);
begin
  with frmHome do
  begin
    if Sender is TButton then
    begin
      frmhome.NotificationLayout.popupConfirm(
        procedure
        begin

          Tthread.CreateAnonymousThread(
            procedure
            begin

              Tthread.Synchronize(nil,
                procedure
                var
                  i: integer;
                begin

                  misc.DeleteAccount(TButton(Sender).TagString);

                  for i := 0 to AccountsListVertScrollBox.Content.
                    ChildrenCount - 1 do
                  begin
                    if TButton(AccountsListVertScrollBox.Content.Children[i])
                      .Text = TButton(Sender).TagString then
                    begin
                      TButton(AccountsListVertScrollBox.Content.Children[i])
                        .DisposeOf;
                    end;

                  end;
                  refreshWalletDat();
{$IF DEFINED(ANDROID) OR DEFINED(IOS)}
                  closeOrganizeView(nil);
                  AccountsListPanel.Visible := false;
{$ENDIF}
                end);

            end).Start();

        end,
        procedure
        begin

        end, 'Are you sure you want to delete this account from the wallet? ' +
        'If you do not have a backup, you will lose access to the funds in this account.',
        'Yes, I want to delete this account', 'No');

    end;
  end;
end;

end.
