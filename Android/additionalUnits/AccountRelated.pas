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
  FMX.TabControl, System.Sensors, System.Sensors.Components, FMX.Edit,
  FMX.Clipboard, FMX.VirtualKeyBoard, JSON,
  languages,

  FMX.Media, FMX.Objects, uEncryptedZipFile, System.Zip
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
  FMX.Menus,
  ZXing.BarcodeFormat,
  ZXing.ReadResult,
  ZXing.ScanManager, FMX.EditBox, FMX.SpinBox, FOcr, FMX.Gestures, FMX.Effects,
  FMX.Filter.Effects, System.Actions, FMX.ActnList, System.Math.Vectors,
  FMX.Controls3D, FMX.Layers3D, FMX.StdActns, FMX.MediaLibrary.Actions,
  FMX.ComboEdit;

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
implementation

uses uHome, misc, AccountData, base58, bech32, CurrencyConverter, SyncThr, WIF,
  Bitcoin, coinData, cryptoCurrencyData, Ethereum, secp256k1, tokenData,
  transactions, WalletStructureData;

procedure afterInitialize;
var
  i: Integer;
  cc: CryptoCurrency;
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
    i: Integer;
  begin
    for i := 0 to frmHome.ComponentCount - 1 do
      if frmHome.Components[i] is TEdit then
        SetEditControlColor(TEdit(frmHome.Components[i]), TAlphaColors.Gray);

  end;

begin
  with frmHome do
  begin
    gathener.Enabled := true;
    log.d('DEBUD Start FormShow()');

    if not isWalletDatExists then
    begin
      createWalletDat();
    end;

    try
      parseWalletFile();
    except
      on E: Exception do
      begin
        showmessage('wallet file damaged');
        exit;
      end;
    end;

    log.d('DEBUD Loaded Wallet.dat');

    if length(AccountsNames) = 0 then
    begin
      lblWelcomeDescription.Text := dictionary('ConfigurationTakeOneStep') +
        #13#10 + dictionary('ChooseOption') + ':';
      switchTab(PageControl, WelcomeTabItem);
    end
    else
    begin
      log.d('DEBUD Start Load account');
      if (lastClosedAccount = '') then
        lastClosedAccount := AccountsNames[0];

      ChangeAccountButton.Text := lastClosedAccount;

      try
        LoadCurrentAccount(lastClosedAccount);
      except
        on E: Exception do
        begin
          showmessage('account file damaged ' + E.Message);
          exit;
        end;
      end;
      log.d('DEBUD Account loaded');
      switchTab(PageControl, TTabItem(frmHome.FindComponent('dashbrd')));
    end;
    fixEditBG;
    if not shown then
    begin

      log.d('DEBUD Start Loading Style');
      if CurrentAccount <> nil then
        Tthread.Synchronize(nil,
          procedure
          begin
            getDataOverHTTP('https://hodler2.nq.pl/analitics.php?hash=' +
              GetSTrHashSHA256(CurrentAccount.EncryptedMasterSeed +
              API_PUB), false);
          end);
{$IFDEF ANDROID}
      for i := 0 to frmHome.ComponentCount - 1 do
        if frmHome.Components[i] is TEdit then
        begin
          TEdit(frmHome.Components[i]).KillFocusByReturn := true;
          TEdit(frmHome.Components[i]).ReturnKeyType := TReturnKeyType.Done;
        end;
{$ENDIF}
    end;
    shown := true;
    log.d('DEBUD End FormShow()');
  end;
end;

procedure LoadCurrentAccount(name: AnsiString);
var
  cc: CryptoCurrency;
  fmxObj: TfmxObject;
  exist: Boolean;
  i: Integer;
begin

  clearVertScrollBox(frmHome.WalletList);
  if (SyncBalanceThr <> nil) and (not SyncBalanceThr.Finished) then
  begin

    SyncBalanceThr.Terminate;

    while not(SyncBalanceThr.Finished) do
    begin

      application.ProcessMessages();
      sleep(50);
    end;
    SyncBalanceThr.WaitFor;
    SyncBalanceThr.DisposeOf;
    SyncBalanceThr := nil;

  end;
  if (SyncHistoryThr <> nil) and (not SyncHistoryThr.Finished) then
  begin

    SyncHistoryThr.Terminate;
    while not(SyncHistoryThr.Finished) do
    begin

      application.ProcessMessages();
      sleep(50);
    end;
    SyncHistoryThr.WaitFor;
    SyncHistoryThr.DisposeOf;
    SyncHistoryThr := nil;

  end;

  frmHome.ChangeAccountButton.Text := name;

  if CurrentAccount <> nil then
    CurrentAccount.free;

  lastClosedAccount := name;
  CurrentAccount := Account.Create(name);
  CurrentAccount.LoadFiles;

  for cc in CurrentAccount.myCoins do
  begin
    // if twalletInfo(cc).y <> 0 then continue;

    exist := false;

    for i := 0 to frmHome.WalletList.Content.ChildrenCount - 1 do
    begin

      if (frmHome.WalletList.Content.Children[i].TagObject is TwalletInfo) then
      begin

        if (TwalletInfo(frmHome.WalletList.Content.Children[i].TagObject)
          .X = TwalletInfo(cc).X) and
          (TwalletInfo(frmHome.WalletList.Content.Children[i].TagObject)
          .coin = TwalletInfo(cc).coin) then
        begin
          exist := true;
          break;
        end;

      end;

    end;

    if not exist then
      CreatePanel(cc);

  end;
  for cc in CurrentAccount.myTokens do
    CreatePanel(cc);

  refreshOrderInDashBrd();

  frmHome.CurrencyBox.ItemIndex := frmHome.CurrencyBox.Items.IndexOf
    (frmHome.CurrencyConverter.symbol);

  globalFiat := 0;

  refreshCurrencyValue;

  SyncBalanceThr := SynchronizeBalanceThread.Create();
  SyncHistoryThr := SynchronizeHistoryThread.Create();
  if (CurrentAccount.userSaveSeed = false) then
  begin
    Tthread.CreateAnonymousThread(
      procedure
      begin

        sleep(1000);
        Tthread.Synchronize(nil,
          procedure
          begin

            with frmHome do
              popupWindowYesNo.Create(
                procedure()
                begin

                  btnDecryptSeed.OnClick := SendWalletFile;

                  decryptSeedBackTabItem := PageControl.ActiveTab;
                  PageControl.ActiveTab := descryptSeed;
                  btnDSBack.OnClick := backBtnDecryptSeed;
                end,
                procedure()
                begin

                end, dictionary('CreateBackupWallet'), dictionary('Yes'),
                dictionary('NotNow'), 1);
          end);
      end).Start;

    saveSeedInfoShowed := true;
  end;

  refreshWalletDat;

end;
procedure syncFont;
var comp:TObject;
l:TLabel;
i:integer;
begin
for i:=0 to frmHome.ComponentCount -1 do begin
comp:=frmHome.Components[i];

if comp is TLabel then
begin
application.ProcessMessages;
l:=TLabel(comp);
if length(l.Text)>20 then continue;

l.Canvas.Font.Assign(l.Font);
while l.Canvas.TextWidth(l.Text)>l.Width do begin
l.Font.Size:=l.Font.Size-0.1;
l.Canvas.Font.Assign(l.Font);
l.RecalcSize
end;


end;
end;

end;
procedure InitializeHodler;
var
  i: Integer;
  symbol: AnsiString;
  Lang, style: AnsiString;
  JSON: TJsonObject;
  WData: AnsiString;
begin
  with frmHome do
  begin
  syncFont;
    if FileExists(System.IOUtils.TPath.Combine
      (System.IOUtils.TPath.GetDocumentsPath, 'hodler.wallet.dat')) then
    begin
      WData := Tfile.ReadAllText
        (System.IOUtils.TPath.Combine(System.IOUtils.TPath.GetDocumentsPath,
        'hodler.wallet.dat'));
      if WData[low(WData)] = '{' then
      begin
        JSON := TJsonObject(TJsonObject.ParseJSONValue(WData));
        Lang := JSON.GetValue<string>('languageIndex');
        style := JSON.GetValue<string>('styleName');
        JSON.free;
      end
      else
      begin
        Lang := '0';
        style := 'RT_WHITE';
      end;

    end
    else
    begin
      Lang := '0';
      style := 'RT_WHITE';
    end;

    cpTimeout := 0;
    DebugBtn.Visible := false;
    bpmnemonicLayout.Position.Y := 386;
    loadDictionary(loadLanguageFile('ENG'));
    refreshComponentText();
    Randomize;

    saveSeedInfoShowed := false;
    FormatSettings.DecimalSeparator := '.';
    shown := false;
    CurrentCoin := nil;
    CurrentCryptoCurrency := nil;
    QRChangeTimer.Enabled := true;
    TCAIterations := 5000;

    FFrameTake := 0;
    stylo := TStyleManager.Create;
    loadstyle(style);
    if style = 'RT_DARK' then
      DayNightModeSwitch.IsChecked := true
    else
      DayNightModeSwitch.IsChecked := false;

    // stylo.TrySetStyleFromResource(style);
    FScanManager := TScanManager.Create(TBarcodeFormat.QR_CODE, nil);
    duringSync := false;
    WVsendTO.Caret.Width := 2;
    LanguageBox.ItemIndex := 0;
    CurrencyConverter := tCurrencyConverter.Create();

    if FileExists(System.IOUtils.TPath.Combine
      (System.IOUtils.TPath.GetDocumentsPath, 'hodler.fiat.dat')) then
      LoadCurrencyFiatFromFile();

    for symbol in CurrencyConverter.availableCurrency.Keys do
    begin
      CurrencyBox.Items.Add(symbol);
    end;

    CurrencyBox.ItemIndex := CurrencyBox.Items.IndexOf('USD');
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
{$IFDEF WIN32 or WIN64}
    btnSSys.Visible := false;
{$ENDIF}
    DeleteAccountLayout.Visible := false;
    BackToBalanceViewLayout.Visible := false;
    TransactionFeeLayout.Visible := false;
    btnSend.Position.Y := 1000;
{$IFDEF DEBUG}
    DebugBtn.Visible := true;
{$ELSE}
    DebugBtn.Visible := false;
{$ENDIF}
    setBlackBackground(AccountsListVertScrollBox.Content);
  end;
end;

procedure changeAccount(Sender: Tobject);
var
  accName: AnsiString;
  fmxObj: TfmxObject;
  Panel: TPanel;
  Button: TButton;
  AccountName: TLabel;
  i: Integer;
  Flag: Boolean;
begin
  with frmHome do
  begin
    AccountsListPanel.Visible := not AccountsListPanel.Visible;

    for i := AccountsListVertScrollBox.Content.ChildrenCount - 1 downto 0 do
    begin
      fmxObj := AccountsListVertScrollBox.Content.Children[i];

      Flag := false; //
      for accName in AccountsNames do
      begin

        if accName = fmxObj.TagString then
        begin
          Flag := true;
          break;
        end;

      end;

      if not Flag then
      begin
        fmxObj.DisposeOf;
      end;

    end;

    for accName in AccountsNames do
    begin
      Flag := true;

      for i := 0 to AccountsListVertScrollBox.Content.ChildrenCount - 1 do
      begin
        fmxObj := AccountsListVertScrollBox.Content.Children[i];

        if accName = fmxObj.TagString then
        begin
          Flag := false;
          break;

        end;

      end;

      if Flag then
      begin
        Button := TButton.Create(frmHome.AccountsListVertScrollBox);
        Button.Align := TAlignLayout.Top;
        Button.Height := 48;
        Button.Visible := true;
        Button.Parent := frmHome.AccountsListVertScrollBox;
        Button.TagString := accName;
        Button.OnClick := LoadAccountPanelClick;
        Button.Text := accName;

      end;

    end;

    AccountsListPanel.Height :=
      min(PageControl.Height - ChangeAccountButton.Height,
      length(AccountsNames) * 48 + 48);
  end;
end;

procedure DeleteAccount(Sender: Tobject);
begin
  with frmHome do
  begin
    popupWindowYesNo.Create(
      procedure
      begin

        Tthread.CreateAnonymousThread(
          procedure
          begin

            Tthread.Synchronize(nil,
              procedure
              var
                i: Integer;
              begin

                misc.DeleteAccount(CurrentAccount.name);
                CurrentAccount.free;
                CurrentAccount := nil;
                lastClosedAccount := '';
                refreshWalletDat();
                AccountsListPanel.Visible := false;
                closeOrganizeView(nil);
                FormShow(nil);

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
  cc: CryptoCurrency;
  minY: Integer;
begin
  with frmHome do
  begin
    minY := Integer.MaxValue;
    TfmxObject(Sender).TagObject := CurrentCoin;

    for cc in CurrentAccount.getWalletWithX(CurrentCoin.X, CurrentCoin.coin) do
    begin
      if ((cc.confirmed + cc.unconfirmed) = 0) and (length(cc.history) = 0) and
        (TwalletInfo(cc).Y < minY) then
      begin
        minY := TwalletInfo(cc).Y;
        TfmxObject(Sender).TagObject := cc;
      end;
    end;

    if TfmxObject(Sender).TagObject = CurrentCoin then
    begin
      if ((CurrentCoin.confirmed + CurrentCoin.unconfirmed) = 0) and
        (length(CurrentCoin.history) = 0) then
      begin
        popupWindow.Create('Current address was not used');
      end
      else
      begin
        generateNewAddressesClick(Sender);
        exit;
      end;
    end;

    OpenWalletView(Sender);

    WVTabControl.ActiveTab := WVReceive;
  end;
end;

procedure deleteYAddress(Sender: Tobject);
begin
  popupWindowYesNo.Create(
    procedure
    begin

      TwalletInfo(TfmxObject(Sender).TagObject).deleted := true;

      CurrentAccount.SaveFiles;

      changeY(nil);
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

  indexArray: array of Integer;
  Yarray: array of Integer;
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

    Tthread.CreateAnonymousThread(
      procedure
      var
        i: Integer;
        cc: CryptoCurrency;
        it: Integer;
      begin
        Tthread.Synchronize(nil,
          procedure
          begin
            switchTab(PageControl, walletDatCreation);
            labelForGenerating.Text := 'Generating new addresses...';
            GenerateSeedProgressBar.Value := 2;

          end);

        tced := TCA(GenerateYAddressPasswordEdit.Text);
        GenerateYAddressPasswordEdit.Text := '';
        MasterSeed := SpeckDecrypt(tced, CurrentAccount.EncryptedMasterSeed);
        tced := '';
        if not isHex(MasterSeed) then
        begin
          popupWindow.Create(dictionary(('FailedToDecrypt')));
          exit;
        end;

        Tthread.Synchronize(nil,
          procedure
          begin
            switchTab(PageControl, walletDatCreation);
            GenerateSeedProgressBar.Value := 10;

          end);

        wd := TwalletInfo(CurrentCoin);

        SetLength(indexArray, 0);

        CCarray := CurrentAccount.getWalletWithX(wd.X, wd.coin);
        SetLength(Yarray, length(CCarray));
        i := 0;
        for cc in CCarray do
        begin
          Yarray[i] := TwalletInfo(cc).Y;
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
          newWD := Bitcoin_createHD(wd.coin, wd.X, indexArray[i], MasterSeed);

          CurrentAccount.AddCoin(newWD);

          Tthread.Synchronize(nil,
            procedure
            begin

              GenerateSeedProgressBar.Value := 10 + (i + 1) * 90 /
                length(indexArray);

            end);

        end;

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
  cc: CryptoCurrency;
  Panel: TPanel;
  bilanceLbl: TLabel;
  addrlbl: TLabel;
  deleteBtn: TButton;
  generateNewAddresses: TButton;
begin
  with frmHome do
  begin
    clearVertScrollBox(YaddressesVertScrollBox);

    for cc in CurrentAccount.getWalletWithX(CurrentCoin.X, CurrentCoin.coin) do
    begin
      if cc.deleted = true then
        Continue;

      Panel := TPanel.Create(YaddressesVertScrollBox);
      Panel.Parent := YaddressesVertScrollBox;
      Panel.Visible := true;
      Panel.Align := TAlignLayout.Top;
      Panel.Height := 48;
      Panel.TagObject := cc;
      Panel.OnClick := OpenWalletViewFromYWalletList;

      addrlbl := TLabel.Create(Panel);
      addrlbl.Parent := Panel;
      addrlbl.Visible := true;
      addrlbl.Margins.Left := 15;
      addrlbl.Margins.Right := 15;
      addrlbl.Text := cc.addr;
      addrlbl.Align := TAlignLayout.Client;

      bilanceLbl := TLabel.Create(Panel);
      bilanceLbl.Parent := Panel;
      bilanceLbl.Visible := true;
      bilanceLbl.Margins.Left := 0;
      bilanceLbl.Margins.Right := 15;
      bilanceLbl.Text := bigintegerbeautifulStr(cc.confirmed, cc.decimals);
      bilanceLbl.Align := TAlignLayout.Right;
      bilanceLbl.Width := frmHome.Width / 6;
      bilanceLbl.TextSettings.HorzAlign := TTextAlign.Trailing;

      deleteBtn := TButton.Create(Panel);
      deleteBtn.Parent := Panel;
      deleteBtn.Visible := true;
      deleteBtn.Align := TAlignLayout.MostRight;
      deleteBtn.Width := 48;
      deleteBtn.Text := 'X';
      deleteBtn.TagObject := cc;
      deleteBtn.OnClick := deleteYAddress;

    end;

    generateNewAddresses := TButton.Create(YaddressesVertScrollBox);
    generateNewAddresses.Parent := YaddressesVertScrollBox;
    generateNewAddresses.Visible := true;
    generateNewAddresses.Align := TAlignLayout.Top;
    generateNewAddresses.Text := 'Add new addresses';
    generateNewAddresses.OnClick := frmHome.generateNewAddressesClick;
    generateNewAddresses.Height := 48;
    generateNewAddresses.TagObject := CurrentCoin;
    generateNewAddresses.Position.Y := 1000000000;
  end;
end;

procedure removeAccount(Sender: Tobject);
begin
  with frmHome do
  begin
    if Sender is TButton then
    begin
      popupWindowYesNo.Create(
        procedure
        begin

          Tthread.CreateAnonymousThread(
            procedure
            begin

              Tthread.Synchronize(nil,
                procedure
                var
                  i: Integer;
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
                  closeOrganizeView(nil);
                  AccountsListPanel.Visible := false;

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
