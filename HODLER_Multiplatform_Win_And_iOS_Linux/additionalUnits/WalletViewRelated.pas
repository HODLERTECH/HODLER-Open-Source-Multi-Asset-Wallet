unit WalletViewRelated;

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
  FMX.Clipboard, FMX.VirtualKeyBoard, JSON, popupwindowData,
  languages, WalletStructureData,

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
  {FMX.Menus,}
  ZXing.BarcodeFormat,
  ZXing.ReadResult,
  ZXing.ScanManager, FMX.EditBox, FMX.SpinBox, FMX.Gestures, FMX.Effects,
  FMX.Filter.Effects, System.Actions, FMX.ActnList, System.Math.Vectors,
  FMX.Controls3D, FMX.Layers3D, FMX.StdActns, FMX.MediaLibrary.Actions,
  FMX.ComboEdit;
procedure hideEmptyWallets(Sender: TObject);
procedure walletHide(Sender: TObject);
procedure ShowHistoryDetails(Sender: TObject);
procedure changeViewOrder(Sender: TObject);
procedure changeLanguage(Sender: TObject);
procedure backToBalance(Sender: TObject);
procedure chooseToken(Sender: TObject);
procedure addToken(Sender: TObject);
procedure TrySendTransaction(Sender: TObject);
procedure reloadWalletView;
procedure OpenWallet(Sender: TObject);
procedure organizeView(Sender: TObject);
procedure newCoin(Sender: TObject);
procedure CreateWallet(Sender: TObject; Option: AnsiString = '');
procedure ShowETHWallets();
procedure synchro;
procedure SendClick(Sender: TObject);
procedure calcFeeWithSpin;
procedure calcUSDFee;
procedure sendAllFunds;
procedure importCheck;
procedure InstantSendClick;
procedure SetCopyButtonPosition;
procedure CopyTextButtonClick;
procedure PrepareSendTabAndSend(from: TWalletInfo; sendto: AnsiString;
  Amount, Fee: BigInteger; MasterSeed: AnsiString;
  coin: AnsiString = 'bitcoin');
procedure CopyParentTagStringToClipboard(Sender: TObject);
procedure addNewWalletPanelClick(Sender: TObject);
procedure btnCreateNewWalletClick(Sender: TObject);
procedure CopyParentTextToClipboard(Sender: TObject);
procedure CreateCopyImageButtonOnTEdits();
procedure newCoinFromPrivateKey(Sender: TObject);
procedure ExportPrivKeyListButtonClick(Sender: TObject);
procedure ImportPrivateKeyInPrivButtonClick(Sender: TObject);
procedure SweepButtonClick(Sender: TObject);
procedure RefreshCurrentWallet(Sender: TObject);
procedure btnChangeDescriptionClick(Sender: TObject);
procedure SendEncryptedSeedButtonClick(Sender: TObject);
procedure btnChangeDescryptionOKClick(Sender: TObject);
procedure SendErrorMsgSwitchSwitch(Sender: TObject);
procedure SendReportIssuesButtonClick(Sender: TObject);
procedure FoundTokenOKButtonClick(Sender: TObject);
procedure SearchTokenButtonClick(Sender: TObject);
procedure ExportPrivateKeyButtonClick(Sender: TObject);
procedure GenerateETHAddressWithToken(Sender : TObject);
procedure btnAddContractClick(Sender: TObject);
procedure ShowETHWalletsForNewToken( );



var
  SyncOpenWallet: TThread;

implementation

uses uHome, misc, AccountData, base58, bech32, CurrencyConverter, SyncThr, WIF,
  Bitcoin, coinData, cryptoCurrencyData, Ethereum, secp256k1, tokenData,
  transactions, AccountRelated, TCopyableEditData, BackupRelated, debugAnalysis,
  KeypoolRelated , nano , ED25519_Blake2b;




procedure btnAddContractClick(Sender: TObject);
var
  t: Token;
begin

  if walletAddressForNewToken = '' then
  begin

    //GenerateETHAddressWithToken(sender);

    newTokenID := Tcomponent(Sender).Tag;
    frmhome.btnDecryptSeed.OnClick := frmhome.GenerateETHAddressWithToken;
    decryptSeedBackTabItem := frmhome.pageControl.ActiveTab;
    frmhome.PageControl.ActiveTab := frmhome.descryptSeed;
    frmhome.btnDSBack.OnClick := frmhome.backBtnDecryptSeed;

  end
  else
  begin
    t := Token.CreateCustom(frmHome.ContractAddress.Text,
      frmHome.TokenNameField.Text, frmHome.SymbolField.Text,
      strtoint(frmHome.DecimalsField.Text), walletAddressForNewToken);
    t.idInWallet := length(CurrentAccount.myTokens) + 10000;
    CurrentAccount.addToken(t);
    CurrentAccount.SaveFiles();
    CreatePanel(T);
    frmhome.btnSyncClick(nil);
    switchTab(frmhome.PageControl, HOME_TABITEM);
  end;



end;

procedure GenerateETHAddressWithToken(Sender : TObject);
var
  ts: TStringList;
  path: AnsiString;
  out : AnsiString;
  wd: TWalletInfo;
  T: Token;
  isCompressed: Boolean;
  WData: WIFAddressData;
  pub: AnsiString;

  tced: AnsiString;
  MasterSeed: AnsiString;
  holder : TfmxObject;
begin
  with frmhome do
  begin

    tced := TCA(passwordForDecrypt.Text);
    passwordForDecrypt.Text := '';
    MasterSeed := SpeckDecrypt(tced, CurrentAccount.EncryptedMasterSeed);
    if not isHex(MasterSeed) then
    begin
      popupWindow.create(dictionary('FailedToDecrypt'));
      exit;
    end;



    wd := coinData.createCoin(4 , 0, 0, MasterSeed, 'Ethereum (ETH)' );  // if ETH not exist in account -> create first or restore (0,0)

    CurrentAccount.AddCoin(wd);
    TThread.Synchronize(nil,
      procedure
      begin
        CreatePanel(wd);
      end);

    // Issue 112 CurrentAccount.userSaveSeed := false;
    //CurrentAccount.SaveFiles();
    // askforBackup(1000);
    startFullfillingKeypool(MasterSeed);
    MasterSeed := '';


    if (decryptSeedBackTabItem = ChoseToken) or (decryptSeedBackTabItem = AddWalletList ) then
    begin

      T := Token.Create( newTokenID , wd.addr );

      T.idInWallet := Length(CurrentAccount.myTokens) + 10000;

      CurrentAccount.addToken(T);
      CreatePanel(T);




    end
    else if decryptSeedBackTabItem = ManuallyToken then
    begin

      t := Token.CreateCustom(frmHome.ContractAddress.Text,
        frmHome.TokenNameField.Text, frmHome.SymbolField.Text,
        strtoint(frmHome.DecimalsField.Text), wd.addr );

      t.idInWallet := length(CurrentAccount.myTokens) + 10000;

      CurrentAccount.addToken(t);
      // CurrentAccount.SaveFiles();
      CreatePanel(T);

      //switchTab(PageControl, walletView);

    end;

     holder := TfmxObject.Create(nil);
      holder.TagObject := T;
      frmhome.OpenWalletView(holder, PointF(0, 0));
      holder.DisposeOf;


     btnSyncClick(nil);





  end;
end;



procedure ExportPrivateKeyButtonClick(Sender: TObject);
begin
  // createExportPrivateKeyList();
  createAddWalletView();
  frmhome.exportemptyaddressesSwitch.IsChecked := false;

  newCoinListNextTabItem := frmhome.ExportPrivCoinListTabItem;
  AddCoinBackTabItem := frmhome.pageControl.ActiveTab;

  switchTab(frmhome.pageControl, frmhome.AddNewcoin);

  {
    createAddWalletView();
    with frmhome do
    begin
    HexPrivKeyDefaultRadioButton.IsChecked := True;
    Layout31.Visible := false;
    WIFEdit.Text := '';
    // PrivateKeySettingsLayout.Visible := false;
    NewCoinDescriptionEdit.Text := '';
    OwnXEdit.Text := '';
    OwnXCheckBox.IsChecked := false;
    IsPrivKeySwitch.IsChecked := false;
    IsPrivKeySwitch.Enabled := false;
    NewCoinDescriptionPassEdit.Text := '';
    NewCoinDescriptionEdit.Text := '';
    CoinPrivKeyPassEdit.Text := '';
    CoinPrivKeyDescriptionEdit.Text := '';
    newCoinListNextTabItem := AddCoinFromPrivKeyTabItem;
    AddCoinBackTabItem := pageControl.ActiveTab;
    switchTab(pageControl, AddNewCoin);

    end;
  }
end;

procedure SearchTokenButtonClick(Sender: TObject);
var
  found: Integer;
begin

  if ((CurrentCoin.coin <> 4) or (CurrentCryptoCurrency is Token)) then
  begin

    showmessage('SearchTokenButton shouldnt be visible here');
    exit;

  end;

  found := SearchTokens(CurrentCoin.addr, nil);
  if found = 0 then
  begin
    popupWindow.Create('New tokens found: ' + inttostr(found));
  end
  else
  begin

    switchTab(frmhome.pageControl, frmhome.foundTokenTabItem);
  end;

end;

procedure FoundTokenOKButtonClick(Sender: TObject);
var
  FMX: TfmxObject;
  T: Token;
begin

  for FMX in frmhome.FoundTokenVertScrollBox.Content.Children do
  begin
    if (FMX is TPanel) and (FMX.TagObject is TCheckBox) then
    begin
      if TCheckBox(FMX.TagObject).IsChecked then
      begin
        T := Token(TfmxObject(FMX.TagObject).TagObject);
        T.idInWallet := Length(AccountForSearchToken.myTokens) + 10000;

        AccountForSearchToken.addToken(T);
        AccountForSearchToken.SaveFiles();
        if AccountForSearchToken = CurrentAccount then
          CreatePanel(T);
      end
      else
      begin
        Token(TfmxObject(FMX.TagObject).TagObject).Free;
      end;

    end;

  end;

  switchTab(frmhome.pageControl, frmhome.walletView);
end;

procedure SendReportIssuesButtonClick(Sender: TObject);
begin
  SendUserReport(frmhome.UserReportMessageMemo.Text,
    frmhome.UserReportSendLogsSwitch.IsChecked,
    frmhome.UserReportDeviceInfoSwitch.IsChecked);
  popupWindow.Create
    ('Thanks you for taking your time to improve our application');
end;

procedure SendErrorMsgSwitchSwitch(Sender: TObject);
begin
  USER_ALLOW_TO_SEND_DATA := frmhome.SendErrorMsgSwitch.IsChecked;

  refreshWalletDat();
end;

procedure btnChangeDescryptionOKClick(Sender: TObject);
begin
  with frmhome do
  begin
    if CurrentCryptoCurrency is TWalletInfo then
    begin
      CurrentAccount.changeDescription(TWalletInfo(CurrentCryptoCurrency).coin,
        TWalletInfo(CurrentCryptoCurrency).x, ChangeDescryptionEdit.Text);
      // .changeDescription save description in file
    end
    else
    begin
      CurrentCryptoCurrency.description := ChangeDescryptionEdit.Text;
      CurrentAccount.SaveFiles();
    end;

    misc.updateNameLabels();
    switchTab(pageControl, walletView);
  end;
end;

procedure SendEncryptedSeedButtonClick(Sender: TObject);
var
  pngName: string;
begin

  with frmhome do
  begin
    BackupRelated.SendEQR;
    pngName := System.IOUtils.TPath.Combine(
{$IFDEF MSWINDOWS}HOME_PATH{$ELSE}System.IOUtils.TPath.GetDownloadsPath
      (){$ENDIF}, CurrentAccount.name + '_EQR_SMALL' + '.png');
    EQRPreview.Visible := True;
    // PageControl.ActiveTab := EQRView;
    EQRPreview.Bitmap.LoadFromFile(pngName);
    EQRPreview.Repaint;
    EQRPreview.Align := TAlignLayout.Center;
    EQRPreview.Height := 294;
    EQRPreview.Width := 294;

    switchTab(pageControl, EQRView);
  end;

end;

procedure btnChangeDescriptionClick(Sender: TObject);
begin
  with frmhome do
  begin

    if CurrentCryptoCurrency is TWalletInfo then
    begin
      ChangeDescryptionEdit.Text := CurrentAccount.getDescription
        (TWalletInfo(CurrentCryptoCurrency).coin,
        TWalletInfo(CurrentCryptoCurrency).x);
    end
    else if CurrentCryptoCurrency is Token then
    begin
      if CurrentCryptoCurrency.description = '' then
      begin
        ChangeDescryptionEdit.Text := Token.availableToken
          [Token(CurrentCryptoCurrency).id - 10000].name + ' (' +
          Token.availableToken[Token(CurrentCryptoCurrency).id - 10000]
          .shortcut + ')';
      end
      else
      begin
        ChangeDescryptionEdit.Text := CurrentCryptoCurrency.description;
      end;
    end;

    switchTab(pageControl, ChangeDescryptionScreen);
  end;

end;

procedure RefreshCurrentWallet(Sender: TObject);
var
  th: TThread;

begin
  th := TThread.CreateAnonymousThread(
    procedure
    var
      cc: cryptoCurrency;
    begin
      frmhome.refreshLocalImage.Start();
      cc := CurrentAccount.getWalletWithX(CurrentCoin.x, CurrentCoin.coin)[0];
      // SCC sync x / all y
      /// for cc in currentAccount.getWalletWithX(CurrentCoin.x, CurrentCoin.coin) do
      // begin
      SynchronizeCryptoCurrency(cc);
      // end;

      TThread.Synchronize(nil,
        procedure
        begin
          reloadWalletView;
          updateBalanceLabels;
        end);

      frmhome.refreshLocalImage.Stop();
    end);

  th.FreeOnTerminate := True;
  th.Start;
end;

procedure SweepButtonClick(Sender: TObject);
begin
  with frmhome do
  begin
    createAddWalletView();
    PrivateKeyEditSV.Text := '';

    newCoinListNextTabItem := ClaimWalletListTabItem;

    AddCoinBackTabItem := pageControl.ActiveTab;
    switchTab(pageControl, AddNewcoin);
  end;

end;

procedure ImportPrivateKeyInPrivButtonClick(Sender: TObject);
begin
  createAddWalletView();
  with frmhome do
  begin
    HexPrivKeyDefaultRadioButton.IsChecked := True;
    Layout31.Visible := false;
    WIFEdit.Text := '';
    // PrivateKeySettingsLayout.Visible := false;
    NewCoinDescriptionEdit.Text := '';
    OwnXEdit.Text := '';
    OwnXCheckBox.IsChecked := false;
    IsPrivKeySwitch.IsChecked := false;
    IsPrivKeySwitch.Enabled := false;
    NewCoinDescriptionPassEdit.Text := '';
    NewCoinDescriptionEdit.Text := '';
    CoinPrivKeyPassEdit.Text := '';
    CoinPrivKeyDescriptionEdit.Text := '';
    newCoinListNextTabItem := AddCoinFromPrivKeyTabItem;
    AddCoinBackTabItem := pageControl.ActiveTab;
    switchTab(pageControl, AddNewcoin);

  end;
end;

procedure ExportPrivKeyListButtonClick(Sender: TObject);
begin
  with frmhome do
  begin
    decryptSeedBackTabItem := pageControl.ActiveTab;
    switchTab(pageControl, descryptSeed);
    btnDSBack.OnClick := backBtnDecryptSeed;
    btnDecryptSeed.OnClick := privateKeyPasswordCheck;
    WDToExportPrivKey := TWalletInfo(TfmxObject(Sender).TagObject);
    { if WDToExportPrivKey <> nil then
      begin
      showmessage( WDToExportPrivKey.addr );
      end
      else
      begin
      showmessage( WDToExportPrivKey.addr );
      end; }
  end;

end;

procedure CreateCopyImageButtonOnTEdits();
var
  fmxObj, cp: Tcomponent;
  i: Integer;
begin
  for i := 0 to frmhome.ComponentCount - 1 do
  begin
    fmxObj := frmhome.Components[i];
    if ((fmxObj is Tedit) or (fmxObj is Tmemo)) and
      (TfmxObject(fmxObj).TagString = 'copyable') then
    begin

      CreateButtonWithCopyImg(fmxObj);

    end;
  end;
end;

procedure btnCreateNewWalletClick(Sender: TObject);
begin

  with frmhome do
  begin
    privTCAPanel2.Visible := false;
    notPrivTCA2.IsChecked := false;
    pass.Text := '';
    retypePass.Text := '';
    btnCreateWallet.Text := dictionary('OpenNewWallet');
    procCreateWallet := btnGenSeedClick;
    btnCreateWallet.TagString := '';
    // generate list options - '' default ( user chose coin )
    AccountNameEdit.Text := getUnusedAccountName();
    createPasswordBackTabItem := pageControl.ActiveTab;
    switchTab(pageControl, createPassword);
  end;

end;

procedure addNewWalletPanelClick(Sender: TObject);
begin

  newcoinID := Tcomponent(Sender).Tag;
  ImportCoinID := newcoinID;

  frmhome.OwnXCheckBox.IsChecked := false;
  frmhome.IsPrivKeySwitch.IsChecked := false;
  frmhome.OwnXCheckBox.Enabled := True;
  frmhome.IsPrivKeySwitch.Enabled := True;

  frmhome.OwnXEdit.Text := inttostr(getFirstUnusedXforCoin(newcoinID));

  // frmhome.PrivateKeySettingsLayout.Visible := false;
  frmhome.LoadingKeyDataAniIndicator.Visible := false;
  frmhome.NewCoinDescriptionEdit.Text := AvailableCoin[ImportCoinID].displayName
    + ' (' + AvailableCoin[ImportCoinID].shortcut + ')';

  frmhome.CoinPrivKeyDescriptionEdit.Text := AvailableCoin[ImportCoinID]
    .displayName + ' (' + AvailableCoin[ImportCoinID].shortcut + ')';

  if newCoinListNextTabItem = frmhome.ClaimWalletListTabItem then
  begin
    if newcoinID = 4 then
    begin

      popupWindow.Create
        ('Better solution is to import the ETH key to transfer ETH and tokens to the wallet.');

      exit();
    end;
    if newcoinID = 8 then
    begin

      popupWindow.Create
        ('Not supported');

      exit();
    end;
    createClaimCoinList(newcoinID);
  end;

  if newCoinListNextTabItem = frmhome.ExportPrivCoinListTabItem then
  begin

    if createExportPrivateKeyList(newcoinID) = 0 then
    begin

      popupWindow.Create('No addresses have been created for this coin');
      exit();

    end;

  end;

  switchTab(frmhome.pageControl,
    newCoinListNextTabItem { frmhome.AddNewCoinSettings } );

end;

procedure CopyParentTagStringToClipboard(Sender: TObject);
var
  svc: IFMXExtendedClipboardService;
begin

  if TPlatformServices.Current.SupportsPlatformService(IFMXClipboardService, svc)
  then
  begin

    svc.setClipboard(removeSpace(TfmxObject(Sender).Parent.TagString));
    popupWindow.Create(removeSpace(TfmxObject(Sender).Parent.TagString) + ' ' +
      dictionary('CopiedToClipboard'));
  end;

end;

procedure CopyParentTextToClipboard(Sender: TObject);
var
  svc: IFMXExtendedClipboardService;
begin

  if TPlatformServices.Current.SupportsPlatformService(IFMXClipboardService, svc)
  then
  begin

    if TfmxObject(Sender).Parent.Parent is Tmemo then
    begin
      svc.setClipboard
        (removeSpace(Tmemo(TfmxObject(Sender).Parent.Parent).Text));
      popupWindow.Create(removeSpace(Tmemo(TfmxObject(Sender).Parent.Parent)
        .Text) + ' ' + dictionary('CopiedToClipboard'));
      // exit;
    end;
    if TfmxObject(Sender).Parent is Tedit then
    begin
      svc.setClipboard(removeSpace(Tedit(TfmxObject(Sender).Parent).Text));
      popupWindow.Create(removeSpace(Tedit(TfmxObject(Sender).Parent).Text) +
        ' ' + dictionary('CopiedToClipboard'));
      // exit;
    end;
    if TfmxObject(Sender).Parent is TButton then
    begin
      svc.setClipboard
        (removeSpace(Tedit(TfmxObject(Sender).Parent.Parent).Text));
      popupWindow.Create(removeSpace(Tedit(TfmxObject(Sender).Parent.Parent)
        .Text) + ' ' + dictionary('CopiedToClipboard'));
    end;

  end;

end;

procedure PrepareSendTabAndSend(from: TWalletInfo; sendto: AnsiString;
Amount, Fee: BigInteger; MasterSeed: AnsiString; coin: AnsiString = 'bitcoin');
begin

  with frmhome do
  begin

    TThread.CreateAnonymousThread(
      procedure
      var
        ans: AnsiString;
        tries: Integer;
      begin

        TThread.Synchronize(nil,
          procedure

          begin

            TransactionWaitForSendAniIndicator.Visible := True;
            TransactionWaitForSendAniIndicator.Enabled := True;
            TransactionWaitForSendDetailsLabel.Visible := True;
            if from.coin<>8 then TransactionWaitForSendDetailsLabel.Text :=
              'Sending... It may take a few seconds' else
            TransactionWaitForSendDetailsLabel.Text := 'Mining transaction, please be patient';
            TransactionWaitForSendLinkLabel.Visible := false;
            TransactionWaitForSendBackButton.Visible := false;

            switchTab(pageControl, TransactionWaitForSend);
          end);
        ans := '';
        tries := 0;
        // while (ans = '') and (tries < 5) do
        // begin
        ans := sendCoinsTO(from, sendto, Amount, Fee, MasterSeed, coin);
        // inc(tries);
        // end;
        TThread.Synchronize(nil,
          procedure
          var
            ts: TStringList;
            i: Integer;
          begin
            try
              TransactionWaitForSendAniIndicator.Visible := false;
              TransactionWaitForSendAniIndicator.Enabled := false;
              TransactionWaitForSendDetailsLabel.Visible := false;
              TransactionWaitForSendLinkLabel.Visible := True;
              TransactionWaitForSendBackButton.Visible := True;

              if LeftStr(ans, Length('Transaction sent')) = 'Transaction sent'
              then
              begin
                { TThread.CreateAnonymousThread(
                  procedure
                  begin
                  SynchronizeCryptoCurrency(CurrentCryptoCurrency);
                  end).Start; }
                TransactionWaitForSendLinkLabel.Text :=
                  'Click here to see details in Explorer';
                TransactionWaitForSendDetailsLabel.Text := 'Transaction sent';

                StringReplace(ans, #$A, ' ', [rfReplaceAll]);
                ts := SplitString(ans, ' ');
                TransactionWaitForSendLinkLabel.TagString :=
                  getURLToExplorer(CurrentCoin.coin, ts[ts.Count - 1]);
                TransactionWaitForSendLinkLabel.Text :=
                  TransactionWaitForSendLinkLabel.TagString;
                ts.Free;
                TransactionWaitForSendDetailsLabel.Visible := True;
                TransactionWaitForSendLinkLabel.Visible := True;
              end
              else
              begin
                TransactionWaitForSendDetailsLabel.Visible := True;
                TransactionWaitForSendLinkLabel.Visible := false;
                ts := SplitString(ans, #$A);
                // showmessage('_' + ans + '_');
                if ts.Count = 0 then
                begin

                  TransactionWaitForSendDetailsLabel.Text :=
                    'Unknown Error' + ans;

                end
                else
                begin
                  TransactionWaitForSendDetailsLabel.Text := ts[0];
                  for i := 1 to ts.Count - 1 do
                    if ts[i] <> '' then
                    begin
                      TransactionWaitForSendDetailsLabel.Text :=
                        TransactionWaitForSendDetailsLabel.Text + #13#10 +
                        'Error: ' + ts[i];
                      // break;
                    end;
                end;

                ts.Free;
              end;
            except
              on E: Exception do
                showmessage(E.Message);
            end;
          end);

      end).Start;

  end;

end;

procedure CopyTextButtonClick;
var
  svc: IFMXExtendedClipboardService;
begin

  if TPlatformServices.Current.SupportsPlatformService(IFMXClipboardService, svc)
  then
  begin
    if frmhome.CopyTextButton.Parent is Tedit then
    begin
      svc.setClipboard(removeSpace(Tedit(frmhome.CopyTextButton.Parent).Text));
      popupWindow.Create(removeSpace(Tedit(frmhome.CopyTextButton.Parent).Text)
        + ' ' + dictionary('CopiedToClipboard'));
    end;

  end;

  // TEdit(frmhome.CopyTextButton.Parent).Text;
end;

procedure SetCopyButtonPosition;
begin
  if (frmhome.focused <> nil) and (frmhome.focused is Tedit) and
    (Tedit(frmhome.focused).TagString = 'copyable') then
  begin

    frmhome.CopyTextButton.Parent := Tedit(frmhome.focused);

  end
  else if (frmhome.focused is TButton) and
    (TButton(frmhome.focused).name = frmhome.CopyTextButton.name) then
  begin

  end
  else
  begin

    frmhome.CopyTextButton.Parent := frmhome.CopyButtonPitStopEdit;

  end;
end;

procedure InstantSendClick;
begin

  with frmhome do
    if InstantSendSwitch.IsChecked = True then
    begin
      wvFee.Text := BigIntegertoFloatStr
        (100000 * Length(CurrentAccount.aggregateUTXO(CurrentCoin)),
        CurrentCoin.decimals);
      PerByteFeeEdit.Enabled := false;
      FeeSpin.Enabled := false;
      wvFee.Enabled := false;
      AutomaticFeeRadio.IsChecked := false;
      AutomaticFeeRadio.Enabled := false;
      FixedFeeRadio.IsChecked := True;
      FixedFeeRadio.Enabled := false;
      PerByteFeeRatio.IsChecked := false;
      PerByteFeeRatio.Enabled := false;
    end
    else
    begin
      PerByteFeeEdit.Enabled := True;
      FeeSpin.Enabled := True;
      wvFee.Enabled := false;
      AutomaticFeeRadio.IsChecked := True;
      AutomaticFeeRadio.Enabled := True;
      FixedFeeRadio.IsChecked := false;
      FixedFeeRadio.Enabled := True;
      PerByteFeeRatio.IsChecked := false;
      PerByteFeeRatio.Enabled := True;
    end;

  frmhome.FeeToUSDUpdate(nil);

end;

procedure sendAllFunds;
begin
  with frmhome do
  begin
    if SendAllFundsSwitch.IsFocused then
    begin
      if SendAllFundsSwitch.IsChecked then
      begin

        if CurrentCryptoCurrency is TWalletInfo then
        begin

        wvAmount.Text := BigIntegertoFloatStr
          ((BigInteger.Min(CurrentAccount.getSpendable
          (TWalletInfo(CurrentCryptoCurrency)),
          CurrentAccount.aggregateBalances(TWalletInfo(CurrentCryptoCurrency))
            .confirmed)), CurrentCryptoCurrency.decimals);

        end
        else
        begin
          wvAmount.Text := BigIntegertoFloatStr(CurrentCryptoCurrency.confirmed,
            CurrentCryptoCurrency.decimals);
        end;

        WVRealCurrency.Text :=
          floatToStrF(CurrencyConverter.calculate(strToFloatDef(wvAmount.Text,
          0) * CurrentCryptoCurrency.rate), ffFixed, 18, 2);
        FeeFromAmountSwitch.IsChecked := True;
        FeeFromAmountSwitch.Enabled := false;
      end
      else
      begin
        wvAmount.Text := BigIntegertoFloatStr(0,
          CurrentCryptoCurrency.decimals);
        WVRealCurrency.Text := '0.00';
        FeeFromAmountSwitch.IsChecked := false;

        FeeFromAmountSwitch.Enabled := True;
      end;
    end;
  end;
end;

procedure calcUSDFee;
var
  satb: Integer;
  curWUstr: AnsiString;
begin
  with frmhome do
  begin
    if isTokenTransfer then
    begin
      lblFeeHeader.Text := languages.dictionary('GasPriceWEI') + ': ';
      lblFee.Text := wvFee.Text + ' = ' +
        floatToStrF(CurrencyConverter.calculate(strToFloatDef(wvFee.Text,
        0) * 66666 * CurrentCoin.rate / (1000000.0 * 1000000.0 * 1000000.0)),
        ffFixed, 18, 6) + ' ' + CurrencyConverter.symbol;
    end
    else if isEthereum then
    begin
      lblFeeHeader.Text := dictionary('GasPriceWEI') + ': ';
      lblFee.Text := wvFee.Text + ' ' + AvailableCoin[CurrentCoin.coin].shortcut
        + ' = ' + floatToStrF
        (CurrencyConverter.calculate(strToFloatDef(wvFee.Text,
        0) * CurrentCoin.rate * 21000 / (1000000.0 * 1000000.0 * 1000000.0)),
        ffFixed, 18, 6) + ' ' + CurrencyConverter.symbol;
    end
    else
    begin
      lblFeeHeader.Text := dictionary('TransactionFee') + ': ';
      if curWU = 0 then
        curWU := 440; // 2 in 2 out default
      satb := BigInteger(StrFloatToBigInteger(wvFee.Text,
        CurrentCryptoCurrency.decimals) div curWU).asInteger;
      if (CurrentCoin.coin = 0) or (CurrentCoin.coin = 1) then
      begin
        curWUstr := ' sat/WU) ';
        satb := satb div 4;
      end
      else
        curWUstr := ' sat/b) ';

      lblFee.Text := wvFee.Text + ' (' + inttostr(satb) + curWUstr +
        AvailableCoin[CurrentCoin.coin].shortcut + ' = ' +
        floatToStrF(CurrencyConverter.calculate(strToFloatDef(wvFee.Text,
        0) * CurrentCoin.rate), ffFixed, 18, 6) + ' ' +
        CurrencyConverter.symbol;
    end;

  end;
end;

procedure calcFeeWithSpin;
var
  a: BigInteger;
begin
  with frmhome do
  begin
    if not isEthereum then
    begin
      a := ((180 * Length(CurrentAccount.aggregateUTXO(CurrentCoin)) +
        (34 * 2) + 12));
      curWU := a.asInteger;
      a := (a * StrFloatToBigInteger(CurrentCoin.efee[round(FeeSpin.Value) - 1],
        CurrentCoin.decimals)) div 1024;
      if (CurrentCoin.coin = 0) or (CurrentCoin.coin = 1) then
        a := a * 4;
      a := Max(a.asInteger, 500);
      wvFee.Text := BigIntegertoFloatStr(a, CurrentCoin.decimals);
      // CurrentCoin.efee[round(FeeSpin.Value) - 1] ;
      lblBlockInfo.Text := dictionary('ConfirmInNext') + ' ' +
        inttostr(round(FeeSpin.Value)) + ' ' + dictionary('Blocks');
    end
    else
      FeeSpin.Value := 1.0;
  end;
end;

procedure SendClick(Sender: TObject);
var
  Amount, Fee: BigInteger;
  Address: AnsiString;
begin
  with frmhome do
  begin

    if not isEthereum then
      Fee := StrFloatToBigInteger(wvFee.Text,
        AvailableCoin[CurrentCoin.coin].decimals)
    else
    begin
      if isTokenTransfer then
        Fee := BigInteger.Parse(wvFee.Text) * 66666
      else
        Fee := BigInteger.Parse(wvFee.Text) * 21000;
    end;

    if (not isTokenTransfer) then
    begin
      Amount := StrFloatToBigInteger(wvAmount.Text,
        AvailableCoin[CurrentCoin.coin].decimals);
      if FeeFromAmountSwitch.IsChecked then
      begin
        Amount := Amount - Fee;
      end;

    end;

    if (isEthereum) and (isTokenTransfer) then
      Amount := StrFloatToBigInteger(wvAmount.Text,
        CurrentCryptoCurrency.decimals);

    if WVsendTO.Text = '' then
    begin
      popupWindow.Create(dictionary('AddressFieldEmpty'));
      exit;
    end;
    if isBech32Address(removeSpace(WVsendTO.Text)) and (CurrentCoin.coin <> 0)
    then
    begin
      popupWindow.Create(dictionary('Bech32Unsupported'));
      exit;
    end;
    if not isValidForCoin(CurrentCoin.coin, removeSpace(WVsendTO.Text)) then
    begin

      popupWindow.Create(dictionary('WrongAddress'));
      exit;
    end;
    if CurrentCoin.coin = 8 then
      Fee := 0;
    if (not isTokenTransfer) then
      if Amount + Fee > (CurrentAccount.aggregateBalances(CurrentCoin).confirmed)
      then
      begin
        popupWindow.Create(dictionary('AmountExceed'));
        exit;
      end;
    Address := removeSpace(WVsendTO.Text);
    if (CurrentCryptoCurrency is TWalletInfo) and
      (TWalletInfo(CurrentCryptoCurrency).coin in [3, 7]) and
      isCashAddress(Address) then
    begin
      if isValidBCHCashAddress(Address) then
      begin

        Address := BCHCashAddrToLegacyAddr(Address);

      end
      else
      begin
        popupWindow.Create(dictionary('WrongAddress'));
        exit;
      end;
    end;
    if CurrentCoin.coin = 4 then
    begin
      { if not isValidEthAddress(address) then
        begin
        popupWindowYesNo.Create(
        procedure // yes
        begin

        end,
        procedure
        begin // no

        TThread.CreateAnonymousThread(
        procedure
        begin
        TThread.Synchronize(nil,
        procedure
        begin
        if ValidateBitcoinAddress(Address) then
        begin

        try
        prepareConfirmSendTabItem();
        except
        on E: Exception do
        begin
        popupWindow.Create(E.Message);
        exit();
        end
        end;

        switchTab(PageControl, ConfirmSendTabItem);

        end;
        end);

        end).Start;

        end, 'This address may be incorrect. Do you want to check again?');
        exit;
        end; }
    end;
    if CurrentCoin.coin = 8 then
    begin
      try
        prepareConfirmSendTabItem();
      except
        on E: Exception do
        begin
          popupWindow.Create(E.Message);
          exit();
        end;
      end;

      switchTab(pageControl, ConfirmSendTabItem);
      ConfirmSendPasswordEdit.Text := '';
    end;
    if ValidateBitcoinAddress(Address) then
    begin
      try
        prepareConfirmSendTabItem();
      except
        on E: Exception do
        begin
          popupWindow.Create(E.Message);
          exit();
        end;
      end;

      switchTab(pageControl, ConfirmSendTabItem);

    end
    else
    begin

    end;
    ConfirmSendPasswordEdit.Text := '';

  end;
end;

procedure ShowETHWalletsForNewToken( );
var
  i: Integer;
  Panel: TPanel;
  adrLabel: TLabel;
  balLabel: TLabel;
  coinIMG: TImage;
  wd: TWalletInfo;
  CountETH: Integer;
begin
  //CountETH := 0;
  clearVertScrollBox(frmhome.AvailableCoinsBox);

  for i := 0 to Length(CurrentAccount.myCoins) - 1 do
  begin
    if CurrentAccount.myCoins[i].coin = 4 then // if ETH
    begin
      //CountETH := CountETH + 1;
      with frmhome.AvailableCoinsBox do
      begin
        wd := CurrentAccount.myCoins[i];
        Panel := TPanel.Create(frmhome.AvailableCoinsBox);
        Panel.Align := Panel.Align.alTop;
        Panel.Height := 48;
        Panel.Width := frmhome.AvailableCoinsBox.Width;
        Panel.Visible := True;
        Panel.Parent := frmhome.AvailableCoinsBox;
        Panel.TagString := CurrentAccount.myCoins[i].addr;
        Panel.OnClick := frmhome.AddNewTokenETHPanelClick;

        adrLabel := TLabel.Create(frmhome.AvailableCoinsBox);
        adrLabel.StyledSettings := adrLabel.StyledSettings -
          [TStyledSetting.Size];
        adrLabel.TextSettings.Font.Size := dashBoardFontSize;

        adrLabel.Parent := Panel;
        adrLabel.TagString := CurrentAccount.myCoins[i].addr;

        if wd.description = '' then
        begin
          adrLabel.Text := AvailableCoin[wd.coin].displayName + ' (' +
            AvailableCoin[wd.coin].shortcut + ')';
        end
        else
        begin

          adrLabel.Text := wd.description;
        end;
        adrLabel.Visible := True;
        adrLabel.Width := 500;
        adrLabel.Height := 48;
        adrLabel.Position.x := 52;
        adrLabel.Position.Y := 0;
        adrLabel.hittest := False;

        balLabel := TLabel.Create(frmhome.WalletList);
        balLabel.StyledSettings := balLabel.StyledSettings -
          [TStyledSetting.Size];
        balLabel.TextSettings.Font.Size := 12;
        balLabel.Parent := Panel;
        balLabel.TagString := CurrentAccount.myCoins[i].addr;
        balLabel.Text := CurrentAccount.myCoins[i].addr;

        balLabel.TextSettings.HorzAlign := TTextAlign.Center;
        balLabel.Visible := True;
        balLabel.Width := 500;
        balLabel.Height := 14;
        balLabel.Align := TAlignLayout.Bottom;
        balLabel.hittest := False;

        coinIMG := TImage.Create(frmhome.AvailableCoinsBox);
        coinIMG.Parent := Panel;

        coinIMG.Bitmap.loadFromStream(getCoinIconResource(wd.coin));

        coinIMG.Height := 32.0;
        coinIMG.Width := 50;
        coinIMG.Position.x := 4;
        coinIMG.Position.Y := 8;
        coinIMG.hittest := False;
        coinIMG.TagString := CurrentAccount.myCoins[i].addr;
      end;

    end;

  end;
end;

procedure ShowETHWallets( );
var
  i: Integer;
  Panel: TPanel;
  adrLabel: TLabel;
  balLabel: TLabel;
  coinIMG: TImage;
  wd: TWalletInfo;
  CountETH: Integer;
begin
  CountETH := 0;
  clearVertScrollBox(frmhome.AvailableCoinsBox);

  for i := 0 to Length(CurrentAccount.myCoins) - 1 do
  begin
    if CurrentAccount.myCoins[i].coin = 4 then // if ETH
    begin
      CountETH := CountETH + 1;
      with frmhome.AvailableCoinsBox do
      begin
        wd := CurrentAccount.myCoins[i];
        Panel := TPanel.Create(frmhome.AvailableCoinsBox);
        Panel.Align := Panel.Align.alTop;
        Panel.Height := 48;
        Panel.Width := frmhome.AvailableCoinsBox.Width;
        Panel.Visible := True;
        Panel.Parent := frmhome.AvailableCoinsBox;
        Panel.TagString := CurrentAccount.myCoins[i].addr;
        Panel.OnClick := frmhome.addToken;

        adrLabel := TLabel.Create(frmhome.AvailableCoinsBox);
        adrLabel.StyledSettings := adrLabel.StyledSettings -
          [TStyledSetting.Size];
        adrLabel.TextSettings.Font.Size := dashBoardFontSize;

        adrLabel.Parent := Panel;
        adrLabel.TagString := CurrentAccount.myCoins[i].addr;

        if wd.description = '' then
        begin
          adrLabel.Text := AvailableCoin[wd.coin].displayName + ' (' +
            AvailableCoin[wd.coin].shortcut + ')';
        end
        else
        begin

          adrLabel.Text := wd.description;
        end;
        adrLabel.Visible := True;
        adrLabel.Width := 500;
        adrLabel.Height := 48;
        adrLabel.Position.x := 52;
        adrLabel.Position.Y := 0;
        adrLabel.OnClick := frmhome.addToken;

        balLabel := TLabel.Create(frmhome.WalletList);
        balLabel.StyledSettings := balLabel.StyledSettings -
          [TStyledSetting.Size];
        balLabel.TextSettings.Font.Size := 12;
        balLabel.Parent := Panel;
        balLabel.TagString := CurrentAccount.myCoins[i].addr;
        balLabel.Text := CurrentAccount.myCoins[i].addr;

        balLabel.TextSettings.HorzAlign := TTextAlign.Center;
        balLabel.Visible := True;
        balLabel.Width := 500;
        balLabel.Height := 14;
        balLabel.Align := TAlignLayout.Bottom;
        balLabel.OnClick := frmhome.addToken;

        coinIMG := TImage.Create(frmhome.AvailableCoinsBox);
        coinIMG.Parent := Panel;

        coinIMG.Bitmap.loadFromStream(getCoinIconResource(wd.coin));

        coinIMG.Height := 32.0;
        coinIMG.Width := 50;
        coinIMG.Position.x := 4;
        coinIMG.Position.Y := 8;
        coinIMG.OnClick := frmhome.addToken;
        coinIMG.TagString := CurrentAccount.myCoins[i].addr;
      end;

    end;

  end;

  if CountETH = 0 then
  begin

    frmhome.AvailableCoinsBox.TagString := '';
    frmhome.addToken(frmhome.AvailableCoinsBox);

  end
  else
    switchTab(frmhome.pageControl, frmhome.AddNewToken);
end;

procedure synchro;
var

  aTask: ITask;
begin

  if (SyncBalanceThr <> nil) then
  begin
    if SyncBalanceThr.Finished then
    begin

      SyncBalanceThr.DisposeOf;
      SyncBalanceThr := nil;
      SyncBalanceThr := SynchronizeBalanceThread.Create();

    end
    else if SyncBalanceThr.TimeFromStart() > 1.0 / 1040.0 then
    begin

      SyncBalanceThr.Terminate;
      SyncBalanceThr.WaitFor;
      SyncBalanceThr.DisposeOf;
      SyncBalanceThr := nil;
      SyncBalanceThr := SynchronizeBalanceThread.Create();

    end;
  end;

end;

procedure CreateWallet(Sender: TObject; Option: AnsiString = '');
var
  alphaStr: AnsiString;
  c: Char;
  num, low, up: Boolean;
  i: Integer;
begin

  TfmxObject(Sender).TagString := ''; // set default options for next account

  num := false;
  low := false;
  up := false;
  with frmhome do
  begin

    if pass.Text <> retypePass.Text then
    begin
      passwordMessage.Text := dictionary('PasswordNotMatch');
      exit;
    end;
    if pass.Text.Length < 8 then
    begin

      popupWindow.Create(dictionary('PasswordShort'));
      exit();

    end
    else
    begin

      for c in pass.Text do
      begin
        if isNumber(c) then
          num := True;
        if IsUpper(c) then
          up := True;
        if IsLower(c) then
          low := True;
      end;
      if not(num and up and low) then
      begin
        popupWindow.Create(dictionary('PasswordShort'));
        exit();

      end;

    end;

    if (AccountNameEdit.Text = '') or (Length(AccountNameEdit.Text) < 3) then
    begin
      popupWindow.Create(dictionary('AccountNameTooShort'));
      exit();
    end;

    for i := 0 to Length(AccountsNames) - 1 do
    begin

      if AccountsNames[i].name = AccountNameEdit.Text then
      begin
        popupWindow.Create(dictionary('AccountNameOccupied'));
        exit();
      end;

    end;

    createSelectGenerateCoinView();
    frmhome.NextButtonSGC.OnClick := frmhome.CoinListCreateFromSeed;
    if Option = '' then
    begin

      switchTab(pageControl, SelectGenetareCoin);
    end
    else if Option = 'claim' then
    begin

      for i := 0 to frmhome.GenerateCoinVertScrollBox.Content.
        ChildrenCount - 1 do
      begin

        if TPanel(frmhome.GenerateCoinVertScrollBox.Content.Children[i]).Tag = 7
        then
          TCheckBox(TPanel(frmhome.GenerateCoinVertScrollBox.Content.Children[i]
            ).TagObject).IsChecked := True;
      end;
      frmhome.NextButtonSGC.OnClick(nil);
    end;

    { TThread.CreateAnonymousThread(
      procedure
      begin
      TThread.Synchronize(nil,
      procedure
      begin

      procCreateWallet(nil);

      end);
      end).Start; }

  end;
end;

procedure newCoinFromPrivateKey(Sender: TObject);
begin
  TThread.CreateAnonymousThread(
    procedure

    var
      MasterSeed, tced: AnsiString;
      walletInfo: TWalletInfo;
      arr: array of Integer;
      wd: TWalletInfo;
      i, j: Integer;
      newID: Integer;
    var
      ts: TStringList;
      path: AnsiString;
      out : AnsiString;
      isCompressed: Boolean;
      WData: WIFAddressData;
      pub: AnsiString;
      flagElse: Boolean;
      sorted: Boolean;
      DEBUGstring: AnsiString;
      holder: TfmxObject;
    begin

      i := 0;
      with frmhome do
        tced := TCA(CoinPrivKeyPassEdit.Text);
      // CoinPrivKeyDescriptionEdit NewCoinDescriptionPassEdit.Text := '';
      MasterSeed := SpeckDecrypt(tced, CurrentAccount.EncryptedMasterSeed);
      if not isHex(MasterSeed) then
      begin

        TThread.Synchronize(nil,
          procedure
          begin
            popupWindow.Create(dictionary('FailedToDecrypt'));
          end);

        exit;
      end;
      startFullfillingKeypool(MasterSeed);
      if isHex(frmhome.WIFEdit.Text) then
      begin

        TThread.Synchronize(nil,
          procedure
          begin
            frmhome.NewCoinPrivKeyOKButton.Enabled := false;
          end);

        frmhome.APICheckCompressed(Sender);

        TThread.Synchronize(nil,
          procedure
          begin
            frmhome.NewCoinPrivKeyOKButton.Enabled := True;
          end);

        if (Length(frmhome.WIFEdit.Text) = 64) then
        begin

          // Tthread.Synchronize(nil , procedure
          // begin
          if not(frmhome.HexPrivKeyCompressedRadioButton.IsChecked or
            frmhome.HexPrivKeyNotCompressedRadioButton.IsChecked) then
            exit;
          out := frmhome.WIFEdit.Text;
          if frmhome.HexPrivKeyCompressedRadioButton.IsChecked then
            isCompressed := True
          else if frmhome.HexPrivKeyNotCompressedRadioButton.IsChecked then
            isCompressed := false
          else
            raise Exception.Create('compression not defined');
          // end);

        end
        else
        begin

          popupWindow.Create('Private Key must have 64 characters');

          exit;
        end;

      end
      else
      begin
        if frmhome.WIFEdit.Text <>
          privKeyToWif(wifToPrivKey(frmhome.WIFEdit.Text)) then
        begin

          TThread.Synchronize(nil,
            procedure
            begin
              popupWindow.Create('Wrong WIF');
            end);

          exit;
        end;
        WData := wifToPrivKey(frmhome.WIFEdit.Text);
        isCompressed := WData.isCompressed;
        out := WData.PrivKey;
      end;

      pub := secp256k1_get_public(out , not isCompressed);
      if newcoinID = 4 then
      begin

        wd := TWalletInfo.Create(newcoinID, -1, -1,
          Ethereum_PublicAddrToWallet(pub),
          frmhome.CoinPrivKeyDescriptionEdit.Text);
        wd.pub := pub;
        wd.EncryptedPrivKey := speckEncrypt((TCA(MasterSeed)), out);
        wd.isCompressed := isCompressed;
      end
      else
      if newCoinID = 8 then
      begin

        pub := nano_privToPub(frmhome.CoinPrivKeyDescriptionEdit.Text);
        wd := NanoCoin.Create(8 , -1 , -1 ,nano_accountFromHexKey(pub), '' );
        wd.pub := pub;
        wd.EncryptedPrivKey := speckEncrypt((TCA(MasterSeed)), frmhome.CoinPrivKeyDescriptionEdit.Text );

      end
      else
      begin
        wd := TWalletInfo.Create(newcoinID, -1, -1,
          Bitcoin_PublicAddrToWallet(pub, AvailableCoin[newcoinID].p2pk),
          frmhome.CoinPrivKeyDescriptionEdit.Text);
        wd.pub := pub;
        wd.EncryptedPrivKey := speckEncrypt((TCA(MasterSeed)), out);
        wd.isCompressed := isCompressed;

      end;

      // Issue 112 CurrentAccount.userSaveSeed := false;
      CurrentAccount.SaveFiles();

      // askforBackup(1000);

      TThread.Synchronize(nil,
        procedure
        begin
          CurrentAccount.AddCoin(wd);
          CreatePanel(wd);
        end);
      CurrentAccount.SaveFiles();
      MasterSeed := '';

      if newcoinID = 4 then
      begin
        // SearchTokens(wd.addr);
      end;

      TThread.Synchronize(nil,
        procedure
        begin
          holder := TfmxObject.Create(nil);
          holder.TagObject := wd;
          frmhome.OpenWalletView(holder, PointF(0, 0));
          holder.DisposeOf;
          holder := nil;
        end);
      wipeAnsiString(MasterSeed);

    end).Start;

end;

procedure newCoin(Sender: TObject);
// begin
// TThread.CreateAnonymousThread(
// procedure
var
  MasterSeed, tced: AnsiString;
  walletInfo: TWalletInfo;
  arr: array of Integer;
  wd: TWalletInfo;
  i, j: Integer;
  newID: Integer;
var
  ts: TStringList;
  path: AnsiString;
  out : AnsiString;
  isCompressed: Boolean;
  WData: WIFAddressData;
  pub: AnsiString;
  flagElse: Boolean;
  sorted: Boolean;
  DEBUGstring: AnsiString;
  holder: TfmxObject;
begin

  i := 0;
  with frmhome do
    tced := TCA(NewCoinDescriptionPassEdit.Text);
  MasterSeed := SpeckDecrypt(tced, CurrentAccount.EncryptedMasterSeed);
  if not isHex(MasterSeed) then
  begin

    TThread.Synchronize(nil,
      procedure
      begin
        popupWindow.Create(dictionary('FailedToDecrypt'));
      end);

    exit;
  end;

  newID := getFirstUnusedXforCoin(newcoinID);

  if frmhome.OwnXCheckBox.IsChecked then
    newID := strtoint(frmhome.OwnXEdit.Text);

  walletInfo := coinData.createCoin(newcoinID, newID, 0, MasterSeed,
    frmhome.NewCoinDescriptionEdit.Text);

  CurrentAccount.AddCoin(walletInfo);
  TThread.Synchronize(nil,
    procedure
    begin
      CreatePanel(walletInfo);
    end);

  // Issue 112 CurrentAccount.userSaveSeed := false;
  CurrentAccount.SaveFiles();
  // askforBackup(1000);
  startFullfillingKeypool(MasterSeed);
  MasterSeed := '';
  TThread.Synchronize(nil,
    procedure
    begin
      holder := TfmxObject.Create(nil);
      holder.TagObject := walletInfo;
      frmhome.OpenWalletView(holder, PointF(0, 0));
      holder.DisposeOf;
    end);

  TThread.Synchronize(nil,
    procedure
    begin
      frmhome.btnSyncClick(nil);
    end);

  // end).Start();
end;

procedure organizeView(Sender: TObject);
var
  Panel: TPanel;
  fmxObj, child, temp: TfmxObject;

  Button: TButton;
  i: Integer;
  Control: TControl;
begin
  with frmhome do
  begin

    vibrate(100);
    clearVertScrollBox(OrganizeList);
    for i := 0 to WalletList.Content.ChildrenCount - 1 do
    begin
      fmxObj := WalletList.Content.Children[i];

      Panel := TPanel.Create(frmhome.OrganizeList);
      Panel.Align := TAlignLayout.Top;
      Panel.Position.Y := TPanel(fmxObj).Position.Y - 1;
      Panel.Height := 48;
      Panel.Visible := True;
      Panel.Parent := frmhome.OrganizeList;
      Panel.TagObject := fmxObj.TagObject;
      Panel.Touch.InteractiveGestures := [TInteractiveGesture.LongTap];

{$IF DEFINED(ANDROID) OR DEFINED(IOS)}
      Panel.OnGesture := frmhome.PanelDragStart;
{$ELSE}
      Panel.OnMouseDown := frmhome.PanelDragStart;
{$ENDIF}
      for child in fmxObj.Children do
      begin
        if child.TagString <> 'balance' then
          temp := child.Clone(Panel);
        temp.Parent := Panel;

      end;
      Button := TButton.Create(Panel);
      Button.Width := Panel.Height;
      Button.Align := TAlignLayout.MostRight;
      Button.Text := 'X';
      Button.Visible := True;
      Button.Parent := Panel;
      Button.OnClick := hideWallet;
    end;

    OrganizeList.Repaint;

{$IF DEFINED(ANDROID) OR DEFINED(IOS)}
    switchTab(pageControl, HOME_TABITEM);
{$ENDIF}
    DeleteAccountLayout.Visible := True;
    Layout1.Visible := false;

    SearchInDashBrdButton.Visible := false;
    NewCryptoLayout.Visible := false;
    WalletList.Visible := false;
    OrganizeList.Visible := True;
    BackToBalanceViewLayout.Visible := True;
    btnSync.Visible := false;
  end;
end;

procedure OpenWallet(Sender: TObject);
var
  wd: TWalletInfo;
  a: BigInteger;
  Control: Tcomponent;
  ts: TMemoryStream;
begin

  if frmhome.pageControl.ActiveTab = HOME_TABITEM then
    frmhome.WVTabControl.ActiveTab := frmhome.WVBalance;

  frmhome.AutomaticFeeRadio.IsChecked := True;
  frmhome.TopInfoConfirmedValue.Text := ' Calculating...';
  frmhome.TopInfoUnconfirmedValue.Text := ' Calculating...';
  lastHistCC := 10;
  if TfmxObject(Sender).Tag = -2 then
    CurrentCryptoCurrency := TWalletInfo(TfmxObject(Sender).TagObject)
  else
    CurrentCryptoCurrency := findUnusedReceiving
      (TWalletInfo(TfmxObject(Sender).TagObject));
  // ShowMessage(postDataOverHTTP(HODLER_URL+'/batchSync.php?coin='+availableCoin[0].shortcut, batchSync(0),false,True));
  frmhome.InstantSendLayout.Visible :=
    TWalletInfo(CurrentCryptoCurrency).coin = 2;

  reloadWalletView; // po co  jak jest w watku ?

  if SyncOpenWallet <> nil then
  begin
    if not SyncOpenWallet.Finished then
    begin
      SyncOpenWallet.Terminate;
      // SyncOpenWallet.WaitFor;
    end;

    SyncOpenWallet.DisposeOf;
    SyncOpenWallet := TThread.CreateAnonymousThread(
      procedure
      begin
        // SynchronizeCryptoCurrency(CurrentCryptoCurrency);
        TThread.Synchronize(nil,
          procedure
          begin
            reloadWalletView;
          end);

      end);
    SyncOpenWallet.FreeOnTerminate := false;
    SyncOpenWallet.Start;
  end
  else
  begin

    SyncOpenWallet := TThread.CreateAnonymousThread(
      procedure
      begin

        // SynchronizeCryptoCurrency(CurrentCryptoCurrency);
        TThread.Synchronize(nil,
          procedure
          begin
            reloadWalletView;
          end);

      end);
    SyncOpenWallet.FreeOnTerminate := false;
    SyncOpenWallet.Start;

  end;

  with frmhome do
  begin

{$IFDEF MSWINDOWS or LINUX}
    Splitter1.Visible := True;
    pageControl.Visible := True;
    WVTabControl.ActiveTab := WVBalance;
{$ENDIF}
    if isEthereum or isTokenTransfer then
    begin
{$IF DEFINED(ANDROID) OR DEFINED(IOS)}
      LayoutPerByte.Visible := false;
{$ELSE}
      PerByteFeeLayout.Visible := false;
{$ENDIF}
      YAddresses.Visible := false;
      btnNewAddress.Visible := false;
      btnPrevAddress.Visible := false;
      lblFeeHeader.Text := dictionary('GasPriceWEI') + ':';
      lblFee.Text := '';
      wvFee.Text := CurrentCoin.efee[0];

      if isTokenTransfer then
      begin
        lblFee.Text := wvFee.Text + '  = ' +
          floatToStrF(CurrencyConverter.calculate(strToFloatDef(wvFee.Text,
          0) * 66666 * CurrentCoin.rate / (1000000.0 * 1000000.0 * 1000000.0)),
          ffFixed, 18, 6) + ' ' + CurrencyConverter.symbol;
      end;

    end
    else
    begin

      if (CurrentCoin.x <> -1) and (CurrentCoin.Y <> -1) then
        YAddresses.Visible := True
      else
        YAddresses.Visible := false;

      if CurrentCoin.coin = 2 then
      begin
        SendSettingsFlowLayout.Height := 84;
        TransactionFeeLayout.Height := 228;

      end
      else
      begin
        SendSettingsFlowLayout.Height := 42;
        TransactionFeeLayout.Height := 228 - 42;
      end;
      InstantSendSwitch.IsChecked := false;
{$IF DEFINED(ANDROID) OR DEFINED(IOS)}
      LayoutPerByte.Visible := True;
      LayoutPerByte.Position.Y := 196;
      LayoutPresentationFee.Position.Y := 228;
      LayoutPresentationFee.Align := TAlignLayout.Top;
      LayoutPresentationFee.RecalcAbsoluteNow;
      QRCodeImage.Position.Y := 16;
      QRCodeImage.Size.Height := 256;
      TransactionFeeLayout.RecalcUpdateRect;
      TransactionFeeLayout.Repaint;
{$ELSE}
      PerByteFeeLayout.Visible := True;
{$ENDIF}
      btnNewAddress.Visible := True;
      btnPrevAddress.Visible := True;
      lblFeeHeader.Text := dictionary('TransactionFee') + ':';
      lblFee.Text := '0.00 ' + CurrentCryptoCurrency.shortcut;
      wvFee.Text := CurrentCoin.efee[round(FeeSpin.Value) - 1];
    end;
    if wvFee.Text = '' then
      wvFee.Text := '0';
    TransactionFeeLayout.BeginUpdate;
    TransactionFeeLayout.RecalcUpdateRect;
    TransactionFeeLayout.Repaint;
    TransactionFeeLayout.EndUpdate;
    wvAmount.Text := BigIntegertoFloatStr(0, CurrentCryptoCurrency.decimals);
    ReceiveValue.Text := BigIntegertoFloatStr(0,
      CurrentCryptoCurrency.decimals);
    ReceiveAmountRealCurrency.Text := '0.00';
    WVRealCurrency.Text := floatToStrF(strToFloatDef(wvAmount.Text, 0) *
      CurrentCryptoCurrency.rate, ffFixed, 15, 2);
    // ShortcutValetInfoImage.DisableInterpolation:=True;
    if CurrentCryptoCurrency is TWalletInfo then
      ShortcutValetInfoImage.MultiResBitmap[0].Bitmap.loadFromStream
        (ResourceMenager.getAssets(AvailableCoin
        [TWalletInfo(CurrentCryptoCurrency).coin].ResourceName));
    if CurrentCryptoCurrency is Token then
      ShortcutValetInfoImage.MultiResBitmap[0].Bitmap.loadFromStream
        (Token(CurrentCryptoCurrency).getIconResource);
    ShortcutValetInfoImage.WrapMode := TImageWrapMode.Place;
    ShortcutValetInfoImage.Align := TAlignLayout.Center;
    // ShortcutValetInfoImage.Height:= ShortcutValetInfoImage.MultiResBitmap[0].Bitmap.Height;
    // ;
    // ShortcutValetInfoImage.Bitmap :=
    // wvGFX.Bitmap := CurrentCryptoCurrency.getIcon();

    lblCoinShort.Text := CurrentCryptoCurrency.shortcut + '';
    lblReceiveCoinShort.Text := CurrentCryptoCurrency.shortcut + '';
    QRChangeTimerTimer(nil);
{$IF DEFINED(ANDROID) OR DEFINED(IOS)}
    receiveAddress.Text := cutEveryNChar(cutAddressEveryNChar,
      CurrentCryptoCurrency.addr);
{$ELSE}
    receiveAddress.Text := CurrentCryptoCurrency.addr;
{$ENDIF}
    WVsendTO.Text := '';
    SendAllFundsSwitch.IsChecked := false;
    FeeFromAmountSwitch.IsChecked := false;
    FeeFromAmountLayout.Visible := not isTokenTransfer;
    if isEthereum or isTokenTransfer then
    begin

      lblBlockInfo.Visible := false;
      FeeSpin.Visible := false;
      // FeeSpin.Opacity := 0;
      FeeSpin.Enabled := false;

    end
    else
    begin

      lblBlockInfo.Visible := True;
      FeeSpin.Visible := True;
      FeeSpin.Enabled := True;
      // FeeSpin.Opacity := 1;

    end;

    AddressTypelayout.Visible := false;
    BCHAddressesLayout.Visible := false;
    RavencoinAddrTypeLayout.Visible := false;

    if CurrentCryptoCurrency is TWalletInfo then
    begin

      if (TWalletInfo(CurrentCryptoCurrency).coin = 0) or
        (TWalletInfo(CurrentCryptoCurrency).coin = 1) then
        AddressTypelayout.Visible := True;

      if (TWalletInfo(CurrentCryptoCurrency).x = -1) and
        (TWalletInfo(CurrentCryptoCurrency).Y = -1) and
        (TWalletInfo(CurrentCryptoCurrency).isCompressed = false) then
        AddressTypelayout.Visible := false;

      if TWalletInfo(CurrentCryptoCurrency).coin in [3, 7] then
        BCHAddressesLayout.Visible := True;

      if (TWalletInfo(CurrentCryptoCurrency).coin = 5) or
        (TWalletInfo(CurrentCryptoCurrency).coin = 6) then
        RavencoinAddrTypeLayout.Visible := True;

    end;

    QRChangeTimerTimer(nil);
    if (CurrentCryptoCurrency is TWalletInfo) and
      (TWalletInfo(CurrentCryptoCurrency).coin = 4) then
      SearchTokenButton.Visible := True
    else
      SearchTokenButton.Visible := false;

    if (not isEthereum) and (CurrentCryptoCurrency is TWalletInfo) then
    begin

      a := ((180 * Length(TWalletInfo(CurrentCryptoCurrency).UTXO) +
        (34 * 2) + 12));
      curWU := a.asInteger;
      a := (a * StrFloatToBigInteger(CurrentCoin.efee[round(FeeSpin.Value) - 1],
        CurrentCoin.decimals)) div 1024;
      if (CurrentCoin.coin = 0) or (CurrentCoin.coin = 1) then
        a := a * 4;
      try
        a := Max(a.asInteger, 500);
      except
        on E: Exception do
        begin
          a := ((180 * Length(TWalletInfo(CurrentCryptoCurrency).UTXO) +
            (34 * 2) + 12)) * 10;
          a := Max(a.asInteger, 500);
        end;
      end;

      wvFee.Text := BigIntegertoFloatStr(a, CurrentCoin.decimals);
      // CurrentCoin.efee[round(FeeSpin.Value) - 1] ;
      lblBlockInfo.Text := dictionary('ConfirmInNext') + ' ' +
        inttostr(round(FeeSpin.Value)) + ' ' + dictionary('Blocks');
    end;
    if (TWalletInfo(CurrentCryptoCurrency).coin = 3) or
      (TWalletInfo(CurrentCryptoCurrency).coin = 7) then
    begin
      frmhome.BCHCashAddrButtonClick(Sender);
    end;
    UnlockNanoImage.Visible := TWalletInfo(CurrentCryptoCurrency).coin = 8;
    if TWalletInfo(CurrentCryptoCurrency).coin = 8 then
    begin
      frmhome.ShowAdvancedLayout.Visible := false;
      frmhome.TransactionFeeLayout.Visible := false;
      frmhome.YAddresses.Visible := false;
      frmhome.btnNewAddress.Visible := false;
      frmhome.btnPrevAddress.Visible := false;
      if NanoCoin(CurrentCryptoCurrency).isUnlocked then
      begin
        UnlockNanoImage.Bitmap.LoadFromStream( ResourceMenager.getAssets('OPENED') );
      end
      else
      begin
        UnlockNanoImage.Bitmap.LoadFromStream( ResourceMenager.getAssets('CLOSED') );
      end;

    end
    else
      frmhome.ShowAdvancedLayout.Visible := True;

    if pageControl.ActiveTab = HOME_TABITEM then
      WVTabControl.ActiveTab := WVBalance;

    loadSendCacheFromFile();

  end;
end;

procedure reloadWalletView;
var
  wd: TWalletInfo;
  a: BigInteger;
  cc: cryptoCurrency;
  sumConfirmed, sumUnconfirmed: BigInteger;
  SumFiat: Double;
begin

  with frmhome do
  begin

    isTokenTransfer := CurrentCryptoCurrency is Token;
    CurrentCoin := nil;
    if isTokenTransfer then
    begin

      if Length(CurrentAccount.myCoins) <> 0 then
      begin
        for wd in CurrentAccount.myCoins do
          if lowercase(wd.addr) = lowercase(CurrentCryptoCurrency.addr) then
          begin
            CurrentCoin := wd;
            break;
          end;
      end;

      if CurrentCoin = nil then
        raise Exception.Create('Not found ETH account');

    end
    else
      CurrentCoin := TWalletInfo(CurrentCryptoCurrency);
    NanoUnlocker.Visible := (CurrentCoin.coin = 8) and
      (CurrentCryptoCurrency.unconfirmed <> 0);
    NanoUnlocker.Text := 'Click here to pocket ' + BigIntegerBeautifulStr
      (CurrentCryptoCurrency.unconfirmed, CurrentCryptoCurrency.decimals)
      + ' NANO';
    if frmhome.NanoUnlocker.Enabled = false then
      frmhome.NanoUnlocker.Text := 'Mining NANO...';

    NanoUnlocker.Height := 48;
    NanoUnlocker.Cursor := crHandPoint;
    NanoUnlocker.TagObject := CurrentCryptoCurrency;

    createHistoryList(CurrentCryptoCurrency, 0, lastHistCC);

    if TWalletInfo(CurrentCryptoCurrency).coin in [3, 7] then
      frmhome.wvAddress.Text := bitcoinCashAddressToCashAddress
        (CurrentCryptoCurrency.addr, false)
    else
      frmhome.wvAddress.Text := CurrentCryptoCurrency.addr;

    if (not(TWalletInfo(CurrentCryptoCurrency).coin in [4, 8])) and
      (not isTokenTransfer) then
    begin
      sumConfirmed := 0;
      sumUnconfirmed := 0;
      SumFiat := 0;
      for cc in CurrentAccount.getWalletWithX(CurrentCoin.x,
        CurrentCoin.coin) do
      begin
        sumConfirmed := sumConfirmed + cc.confirmed;
        sumUnconfirmed := sumUnconfirmed + cc.unconfirmed;
        SumFiat := SumFiat + cc.getFiat();
      end;

      lbBalance.Text := BigIntegerBeautifulStr
        (CurrentAccount.aggregateBalances(CurrentCoin).confirmed,
        CurrentCryptoCurrency.decimals);
      lbBalanceLong.Text := BigIntegertoFloatStr
        (CurrentAccount.aggregateBalances(CurrentCoin).confirmed,
        CurrentCryptoCurrency.decimals);
      lblFiat.Text := floatToStrF(CurrentAccount.aggregateFiats(CurrentCoin),
        ffFixed, 15, 2);

      TopInfoConfirmedValue.Text := ' ' + BigIntegertoFloatStr
        (CurrentAccount.aggregateBalances(CurrentCoin).confirmed,
        CurrentCryptoCurrency.decimals) + ' ' + CurrentCryptoCurrency.shortcut;
      TopInfoConfirmedFiatLabel.Text :=
        floatToStrF(CurrentAccount.aggregateConfirmedFiats(CurrentCoin),
        ffFixed, 15, 2) + ' ' + CurrencyConverter.symbol;

      TopInfoUnconfirmedValue.Text := ' ' + BigIntegertoFloatStr
        (CurrentAccount.aggregateBalances(CurrentCoin).unconfirmed,
        CurrentCryptoCurrency.decimals) + ' ' + CurrentCryptoCurrency.shortcut;
      TopInfoUnconfirmedFiatLabel.Text :=
        floatToStrF(CurrentAccount.aggregateUNConfirmedFiats(CurrentCoin),
        ffFixed, 15, 2) + ' ' + CurrencyConverter.symbol;

      ShortcutFiatLabel.Text :=
        floatToStrF(CurrentAccount.aggregateFiats(CurrentCoin), ffFixed, 15, 2);
    end
    else
    begin
      lbBalance.Text := BigIntegerBeautifulStr(CurrentCryptoCurrency.confirmed,
        CurrentCryptoCurrency.decimals);

      lbBalanceLong.Text := BigIntegertoFloatStr
        (CurrentCryptoCurrency.confirmed, CurrentCryptoCurrency.decimals);

      lblFiat.Text := floatToStrF(CurrentCryptoCurrency.getFiat(),
        ffFixed, 15, 2);

      TopInfoConfirmedValue.Text := ' ' + BigIntegertoFloatStr
        (CurrentCryptoCurrency.confirmed, CurrentCryptoCurrency.decimals) + ' '
        + CurrentCryptoCurrency.shortcut;
      TopInfoConfirmedFiatLabel.Text :=
        floatToStrF(CurrentCryptoCurrency.getConfirmedFiat, ffFixed, 15, 2) +
        ' ' + CurrencyConverter.symbol;

      TopInfoUnconfirmedValue.Text := ' ' + BigIntegertoFloatStr
        (CurrentCryptoCurrency.unconfirmed, CurrentCryptoCurrency.decimals) +
        ' ' + CurrentCryptoCurrency.shortcut;
      TopInfoUnconfirmedFiatLabel.Text :=
        floatToStrF(CurrentCryptoCurrency.getUNConfirmedFiat, ffFixed, 15, 2) +
        ' ' + CurrencyConverter.symbol;

      if TWalletInfo(CurrentCryptoCurrency).coin = 8 then
      begin
        TopInfoConfirmedValue.Text := ' ' + BigIntegerBeautifulStr
          (CurrentCryptoCurrency.confirmed, CurrentCryptoCurrency.decimals) +
          ' ' + CurrentCryptoCurrency.shortcut;
        TopInfoConfirmedFiatLabel.Text :=
          floatToStrF(CurrentCryptoCurrency.getConfirmedFiat, ffFixed, 15, 2) +
          ' ' + CurrencyConverter.symbol;

        TopInfoUnconfirmedValue.Text := ' ' + BigIntegerBeautifulStr
          (CurrentCryptoCurrency.unconfirmed, CurrentCryptoCurrency.decimals) +
          ' ' + CurrentCryptoCurrency.shortcut;
        TopInfoUnconfirmedFiatLabel.Text :=
          floatToStrF(CurrentCryptoCurrency.getUNConfirmedFiat, ffFixed, 15, 2)
          + ' ' + CurrencyConverter.symbol;
      end;
      ShortcutFiatLabel.Text := floatToStrF(CurrentCryptoCurrency.getFiat(),
        ffFixed, 15, 2);
    end;

    FiatShortcutLayout.Width := ShortcutFiatLabel.Canvas.TextWidth
      (ShortcutFiatLabel.Text) * ShortcutFiatLabel.TextSettings.Font.Size
      / 12 + 20;
    ShortcutFiatShortcutLabel.Text := CurrencyConverter.symbol;

    TopInfoUnconfirmedFiatLabel.Width :=
      Max(TopInfoUnconfirmedFiatLabel.Canvas.TextWidth
      (TopInfoUnconfirmedFiatLabel.Text) * TopInfoUnconfirmedFiatLabel.Font.Size
      / 12, TopInfoConfirmedFiatLabel.Canvas.TextWidth
      (TopInfoConfirmedFiatLabel.Text) * TopInfoConfirmedFiatLabel.Font.Size
      / 12) + 6;
    TopInfoConfirmedFiatLabel.Width := TopInfoUnconfirmedFiatLabel.Width;

    if CurrentCryptoCurrency is TWalletInfo then
    begin
      NameShortcutLabel.Text := CurrentAccount.getDescription
        (TWalletInfo(CurrentCryptoCurrency).coin,
        TWalletInfo(CurrentCryptoCurrency).x);
    end
    else
    begin
      if CurrentCryptoCurrency.description = '' then
      begin
        NameShortcutLabel.Text := CurrentCryptoCurrency.name + ' (' +
          CurrentCryptoCurrency.shortcut + ')';
      end
      else
      begin
        NameShortcutLabel.Text := CurrentCryptoCurrency.description;
      end;
    end;

    if (CurrentCoin.coin = 0) and ((frmhome.TxHistory.ChildrenCount) = 0) then
    begin
      frmhome.BTCNoTransactionLayout.Visible := True;
    end
    else
    begin
      frmhome.BTCNoTransactionLayout.Visible := false;
    end;
  end;
end;

procedure TrySendTransaction(Sender: TObject);
var
  MasterSeed, tced, Address, CashAddr: AnsiString;
var
  Amount, Fee, tempFee: BigInteger;
begin
  with frmhome do
  begin

    tced := TCA(ConfirmSendPasswordEdit.Text);
    ConfirmSendPasswordEdit.Text := '';
    MasterSeed := SpeckDecrypt(tced, CurrentAccount.EncryptedMasterSeed);
    if not isHex(MasterSeed) then
    begin
      popupWindow.Create(dictionary('FailedToDecrypt'));
      exit;
    end;
    if not((isEthereum) or (isTokenTransfer) or (CurrentCoin.coin=8)) then
      if Length(CurrentAccount.aggregateUTXO(CurrentCoin)) = 0 then
      begin
        popupWindow.Create
          ('There is no inputs to spend, please wait for transaction confirmation');
        exit;
      end;
    if not isEthereum then
    begin
      Fee := StrFloatToBigInteger(wvFee.Text, AvailableCoin[CurrentCoin.coin]
        .decimals);
      if currentcoin.coin=8 then fee:=0;
      
      tempFee := Fee;
    end
    else
    begin
      Fee := BigInteger.Parse(wvFee.Text);

      if isTokenTransfer then
        tempFee := BigInteger.Parse(wvFee.Text) * 66666
      else
        tempFee := BigInteger.Parse(wvFee.Text) * 21000;
    end;
    if (not isTokenTransfer) then
    begin
      Amount := StrFloatToBigInteger(wvAmount.Text,
        AvailableCoin[CurrentCoin.coin].decimals);
      if FeeFromAmountSwitch.IsChecked then
      begin
        Amount := Amount - tempFee;
      end;

    end;

    if (isEthereum) and (isTokenTransfer) then
      Amount := StrFloatToBigInteger(wvAmount.Text,
        CurrentCryptoCurrency.decimals);

    if { (not isEthereum) and } (not isTokenTransfer) then
    begin
      if Amount + tempFee > (CurrentAccount.aggregateBalances(CurrentCoin)
        .confirmed) then
      begin
        popupWindow.Create(dictionary('AmountExceed'));
        exit;
      end;

    end;
    if ((Amount) = 0) or (((Fee) = 0) and (CurrentCoin.coin<>8)) then
    begin
      popupWindowOK.Create(
        procedure
        begin

          TThread.CreateAnonymousThread(
            procedure
            begin

              TThread.Synchronize(nil,
                procedure
                begin
                  switchTab(pageControl, walletView);
                end);
            end).Start;

        end, dictionary('InvalidValues'));

      exit
    end;

    Address := removeSpace(WVsendTO.Text);

    if (CurrentCryptoCurrency is TWalletInfo) and
      (TWalletInfo(CurrentCryptoCurrency).coin in [3, 7]) then
    begin
      CashAddr := StringReplace(lowercase(Address), 'bitcoincash:', '',
        [rfReplaceAll]);
      if (LeftStr(CashAddr, 1) = 'q') or (LeftStr(CashAddr, 1) = 'p') then
      begin
        try
          Address := BCHCashAddrToLegacyAddr(Address);
        except
          on E: Exception do
          begin
            showmessage('Wrong bech32 address');
            exit;
          end;
        end;
      end;
    end;

    PrepareSendTabAndSend(CurrentCoin, Address, Amount, Fee, MasterSeed,
      AvailableCoin[CurrentCoin.coin].name);

    clearSendCache();

  end;

end;

procedure addToken(Sender: TObject);
var
  Panel: TPanel;
  coinName: TLabel;
  coinIMG: TImage;
  i: Integer;
begin
  // save wallet address for later use
  // wallet address is used to create token
  walletAddressForNewToken := TfmxObject(Sender).TagString;

  clearVertScrollBox(frmhome.AvailableTokensBox);

  for i := 0 to Length(Token.availableToken) - 1 do
  begin

    if Token.availableToken[i].Address = '' then
      // if token is no longer exist
      Continue;

    with frmhome.AvailableTokensBox do
    begin
      Panel := TPanel.Create(frmhome.AvailableTokensBox);
      Panel.Align := Panel.Align.alTop;
      Panel.Height := 48;
      Panel.Visible := True;
      Panel.Tag := i;
      Panel.Parent := frmhome.AvailableTokensBox;
      Panel.OnClick := frmhome.choseTokenClick;
      if i = 0 then
        Panel.TagString := '' // hodler.tech must be first in list
      else
        Panel.TagString := Token.availableToken[i].name;

      coinName := TLabel.Create(frmhome.AvailableTokensBox);
      coinName.Parent := Panel;
      coinName.Text := Token.availableToken[i].name;
      coinName.Visible := True;
      coinName.Width := 500;
      coinName.Position.x := 52;
      coinName.Position.Y := 16;
      coinName.Tag := i;
      coinName.OnClick := frmhome.choseTokenClick;

      coinIMG := TImage.Create(frmhome.AvailableTokensBox);
      coinIMG.Parent := Panel;
      coinIMG.Bitmap.loadFromStream
        (ResourceMenager.getAssets(Token.availableToken[i].ResourceName));
      // frmhome.TokenIcons.Source[i].MultiResBitmap[0].Bitmap;

      coinIMG.Height := 32.0;
      coinIMG.Width := 50;
      coinIMG.Position.x := 4;
      coinIMG.Position.Y := 8;
      coinIMG.OnClick := frmhome.choseTokenClick;
      coinIMG.Tag := i;

    end;
  end;

  frmhome.AvailableTokensBox.Sort(
    function(item1, item2: TfmxObject): Integer
    begin
      if item1.TagString > item2.TagString then
        exit(1);
      if item1.TagString < item2.TagString then
        exit(-1);
      exit(0);
    end);

end;

procedure chooseToken(Sender: TObject);
var
  T: Token;
  popup: TPopup;
  Panel: TPanel;
  mess: popupWindow;
  holder: TfmxObject;
begin
  for T in CurrentAccount.myTokens do
  begin

    if (T.addr = walletAddressForNewToken) and
      (T.id = (Tcomponent(Sender).Tag + 10000)) then
    begin

      mess := popupWindow.Create(dictionary('TokenExist'));

      exit;
    end;

  end;

  if walletAddressForNewToken <> '' then
  begin
  T := Token.Create(Tcomponent(Sender).Tag, walletAddressForNewToken);

  T.idInWallet := Length(CurrentAccount.myTokens) + 10000;

  CurrentAccount.addToken(T);
  CreatePanel(T);
  holder := TfmxObject.Create(nil);
  holder.TagObject := T;
  frmhome.OpenWalletView(holder, PointF(0, 0));
  holder.DisposeOf;
  end
  else
  begin
    newTokenID := Tcomponent(Sender).Tag;
    frmhome.btnDecryptSeed.OnClick := frmhome.GenerateETHAddressWithToken;
    decryptSeedBackTabItem := frmhome.pageControl.ActiveTab;
    frmhome.pageControl.ActiveTab := frmhome.descryptSeed;
    frmhome.btnDSBack.OnClick := frmhome.backBtnDecryptSeed;
  end;

end;

procedure backToBalance(Sender: TObject);
var
  fmxObj: TfmxObject;
  i: Integer;
begin

  try
    with frmhome do
    begin
      for i := 0 to OrganizeList.Content.ChildrenCount - 1 do
      begin
        fmxObj := OrganizeList.Content.Children[i];
        cryptoCurrency(fmxObj.TagObject).orderInWallet :=
          round(TPanel(fmxObj).Position.Y);
      end;

      syncTimer.Enabled := false;

      if (SyncBalanceThr <> nil) and (SyncBalanceThr.Finished = false) then
      begin
        try
          SyncBalanceThr.Terminate();
        except
          on E: Exception do
          begin

          end;
        end;
      end;

      SyncBalanceThr.WaitFor;

      CurrentAccount.SaveFiles();

      clearVertScrollBox(WalletList);

      lastClosedAccount := CurrentAccount.name;
      refreshWalletDat();

      currentAccount.Free;
      CurrentAccount := nil;

      TLabel(frmhome.FindComponent('globalBalance')).Text := '0.00';
      AccountRelated.afterInitialize;

      syncTimer.Enabled := True;
      SyncBalanceThr.Terminate();

      if SyncBalanceThr.Finished then
      begin

        SyncBalanceThr.DisposeOf;
        SyncBalanceThr := nil;
        SyncBalanceThr := SynchronizeBalanceThread.Create();

      end;

      closeOrganizeView(nil);
    end;
  Except
    on E: Exception do
    begin

    end;
  end;
end;

procedure changeLanguage(Sender: TObject);
begin

  with frmhome do
  begin

    WelcomeTabLanguageBox.ItemIndex := TPopupBox(Sender).ItemIndex;
    LanguageBox.ItemIndex := TPopupBox(Sender).ItemIndex;

    loadDictionary(loadLanguageFile(TPopupBox(Sender).Items[TPopupBox(Sender)
      .ItemIndex]));
    refreshComponentText();
    if LanguageBox.IsFocused or WelcomeTabLanguageBox.IsFocused then
      refreshWalletDat();
  end;

end;

procedure changeViewOrder(Sender: TObject);
var
  i, j: Integer;
  swapFlag, rep: Boolean;
  temp: Single;
  function compLex(a, b: cryptoCurrency): Integer;
  var
    adesc, bdesc: AnsiString;
  begin
    if a.description = '' then
      adesc := a.name
    else
      adesc := a.description;

    if b.description = '' then
      bdesc := b.name
    else
      bdesc := b.description;

    if adesc = bdesc then
      exit(0);
    if adesc > bdesc then
      exit(1);
    exit(-1);

  end;

  function compVal(a, b: cryptoCurrency): Integer;
  var
    adesc, bdesc: AnsiString;
  begin

    if a.getFiat < b.getFiat then
      exit(-1);
    if a.getFiat > b.getFiat then
      exit(1);
    if a.confirmed > b.confirmed then
      exit(1);
    if a.confirmed < b.confirmed then
      exit(-1);
    exit(0);
  end;
  function compAmount(a, b: cryptoCurrency): Integer;
  var
    adesc, bdesc: AnsiString;
  begin

    if a.confirmed > b.confirmed then
      exit(1);
    if a.confirmed < b.confirmed then
      exit(-1);
    exit(0);
  end;

begin
  with frmhome do
  begin

    rep := True;
    while (rep) do
    begin
      rep := false;
      for i := 0 to OrganizeList.Content.ChildrenCount - 1 do
      begin

        for j := 0 to OrganizeList.Content.ChildrenCount - 1 do
        begin
          swapFlag := false;

          case PopupBox1.ItemIndex of

            0:
              if (compLex(cryptoCurrency(OrganizeList.Content.Children[i]
                .TagObject), cryptoCurrency(OrganizeList.Content.Children[j]
                .TagObject)) > 0) and
                (TPanel(OrganizeList.Content.Children[i]).Position.Y <
                TPanel(OrganizeList.Content.Children[j]).Position.Y) then
                swapFlag := True;

            1:
              if (compVal(cryptoCurrency(OrganizeList.Content.Children[i]
                .TagObject), cryptoCurrency(OrganizeList.Content.Children[j]
                .TagObject)) > 0) and
                (TPanel(OrganizeList.Content.Children[i]).Position.Y >
                TPanel(OrganizeList.Content.Children[j]).Position.Y) then
                swapFlag := True;

            2:
              if (compAmount(cryptoCurrency(OrganizeList.Content.Children[i]
                .TagObject), cryptoCurrency(OrganizeList.Content.Children[j]
                .TagObject)) > 0) and
                (TPanel(OrganizeList.Content.Children[i]).Position.Y >
                TPanel(OrganizeList.Content.Children[j]).Position.Y) then
                swapFlag := True;

          end;

          if swapFlag then
          begin

            temp := TPanel(OrganizeList.Content.Children[i]).Position.Y;
            TPanel(OrganizeList.Content.Children[i]).Position.Y :=
              TPanel(OrganizeList.Content.Children[j]).Position.Y - 1;
            TPanel(OrganizeList.Content.Children[j]).Position.Y := temp - 1;

            if (i = 8) and (j = 11) then
            begin
              compLex(cryptoCurrency(OrganizeList.Content.Children[i]
                .TagObject), cryptoCurrency(OrganizeList.Content.Children[j]
                .TagObject));
            end;

            rep := True;

          end;

        end;

      end

    end;

  end;
end;

procedure hideEmptyWallets(Sender: TObject);
var
  Panel: TPanel;
  cc: cryptoCurrency;
  tempBalances: TBalances;
  i: Integer;
begin
  with frmhome do
  begin

    for i := 0 to WalletList.Content.ChildrenCount - 1 do
    begin

      Panel := TPanel(WalletList.Content.Children[i]);
      cc := cryptoCurrency(Panel.TagObject);

      if cc is TWalletInfo then
      begin

        if TWalletInfo(cc).coin = 4 then
        begin

          Panel.Visible := (cc.confirmed > 0);

        end
        else
        begin
          tempBalances := CurrentAccount.aggregateBalances(TWalletInfo(cc));
          Panel.Visible := (tempBalances.confirmed > 0);

        end;

      end
      else
      begin

        Panel.Visible := (cc.confirmed > 0);

      end;

      Panel.Visible :=
        (Panel.Visible or (not HideZeroWalletsCheckBox.IsChecked));

    end;
    refreshOrderInDashBrd();

  end;
end;

procedure ShowHistoryDetails(Sender: TObject);
var
  th: transactionHistory;
  fmxObject: TfmxObject;
  i: Integer;
  Panel: TPanel;
  addrlbl: TCopyableEdit;
  valuelbl: TLabel;
  leftLayout: TLayout;
  rightLayout: TLayout;
begin
  with frmhome do
  begin

    if TfmxObject(Sender).TagObject = nil then
      exit;

    th := THistoryHolder(TfmxObject(Sender).TagObject).history;

    HistoryTransactionValue.Text := BigIntegertoFloatStr(th.CountValues,
      CurrentCryptoCurrency.decimals);
    if th.confirmation > 0 then
      historyTransactionConfirmation.Text := inttostr(th.confirmation) +
        ' Confirmation(s)'
    else
      historyTransactionConfirmation.Text := 'Unconfirmed';

    HistoryTransactionDate.Text := FormatDateTime('dd mmm yyyy hh:mm',
      UnixToDateTime(strToIntdef(th.Data, 0)));
    HistoryTransactionID.Text := th.TransactionID;
    if th.typ = 'IN' then
      HistoryTransactionSendReceive.Text := dictionary('Receive')
    else if (th.typ = 'OUT') then
      HistoryTransactionSendReceive.Text := dictionary('Sent')
    else if (th.typ = 'INTERNAL') then
      HistoryTransactionSendReceive.Text := dictionary('Internal')
    else
    begin
      showmessage('History Transaction type error');
      exit();
    end;
    i := 0;
    while i <= HistoryTransactionVertScrollBox.Content.ChildrenCount - 1 do
    begin
      fmxObject := HistoryTransactionVertScrollBox.Content.Children[i];

      if LeftStr(fmxObject.name, Length('HistoryValueAddressPanel_')) = 'HistoryValueAddressPanel_'
      then
      begin
        fmxObject.DisposeOf;
        i := 0;
      end;
      inc(i);

    end;
    for i := 0 to Length(th.values) - 1 do
    begin
      Panel := TPanel.Create(HistoryTransactionVertScrollBox);
      Panel.Align := TAlignLayout.Top;
      Panel.Height := 42;
      Panel.Visible := True;
      Panel.Tag := i;
      Panel.TagString := th.addresses[i];
      Panel.name := 'HistoryValueAddressPanel_' + inttostr(i);
      Panel.Parent := HistoryTransactionVertScrollBox;
      Panel.Position.Y := 1000 + Panel.Height * i;
      Panel.Margins.Left := 0;
      Panel.Margins.Right := 0;
      Panel.Margins.Bottom := 6;
{$IFDEF ANDRIOD}
      Panel.OnGesture := CopyToClipboard;
      Panel.Touch.GestureManager := GestureManager1;
      Panel.Touch.InteractiveGestures := [TInteractiveGesture.DoubleTap,
        TInteractiveGesture.LongTap];
{$ENDIF}
      { leftLayout := TLayout.Create(Panel);
        leftLayout.Visible := true;
        leftLayout.Align := TAlignLayout.Left;
        leftLayout.Width := 10;
        leftLayout.Parent := Panel;

        rightLayout := TLayout.Create(Panel);
        rightLayout.Visible := true;
        rightLayout.Align := TAlignLayout.Right;
        rightLayout.Width := 10;
        rightLayout.Parent := Panel; }

      valuelbl := TLabel.Create(Panel);
      valuelbl.Height := 21;
      valuelbl.Align := TAlignLayout.Top;
      valuelbl.Visible := True;
      valuelbl.Parent := Panel;
      valuelbl.Position.Y := 26;
      valuelbl.Text := BigIntegertoFloatStr(th.values[i],
        CurrentCryptoCurrency.decimals);
      valuelbl.TextSettings.HorzAlign := TTextAlign.Trailing;
      valuelbl.TagString := th.addresses[i];
      valuelbl.HitTest := True;

      addrlbl := TCopyableEdit.Create(Panel);
      addrlbl.ReadOnly := True;
      // addrlbl.StyleLookup := 'transparentedit';
      addrlbl.Height := 21;
      addrlbl.Align := TAlignLayout.Top;
      addrlbl.Visible := True;
      addrlbl.Parent := Panel;
      addrlbl.Text := th.addresses[i];
      addrlbl.TextSettings.HorzAlign := TTextAlign.Leading;
      addrlbl.TagString := th.addresses[i];
      addrlbl.HitTest := True;
      // addrlbl.TagString := 'copyable';

{$IFDEF ANDRIOD}
      valuelbl.OnGesture := CopyToClipboard;
      valuelbl.Touch.GestureManager := GestureManager1;
      valuelbl.Touch.InteractiveGestures := [TInteractiveGesture.DoubleTap,
        TInteractiveGesture.LongTap];
      // addrlbl.OnGesture := CopyToClipboard;
      // addrlbl.Touch.GestureManager := GestureManager1;
      // addrlbl.Touch.InteractiveGestures := [TInteractiveGesture.DoubleTap,
      // TInteractiveGesture.LongTap];
{$ENDIF}
    end;

    switchTab(pageControl, HistoryDetails);

  end;
end;

procedure walletHide(Sender: TObject);
var
  Panel: TPanel;
  fmxObj: TfmxObject;
  wdArray: TCryptoCurrencyArray;
  i: Integer;
begin

  try
    if Sender is TButton then
    begin

      Panel := TPanel(TfmxObject(Sender).Parent);

      if (Panel.TagObject is TWalletInfo) and
        (TWalletInfo(Panel.TagObject).coin <> 4) then
      begin

        wdArray := CurrentAccount.getWalletWithX(TWalletInfo(Panel.TagObject).x,
          TWalletInfo(Panel.TagObject).coin);

        for i := 0 to Length(wdArray) - 1 do
        begin
          wdArray[i].deleted := True;
        end;

      end
      else
      begin
        cryptoCurrency(Panel.TagObject).deleted := True;
      end;

      Panel.DisposeOf;
    end;
  except
    on E: Exception do
    begin
    end;
  end;
end;

procedure importCheck;
var
  comkey: AnsiString;
  notkey: AnsiString;
  WData: AnsiString;
  ts: TStringList;
  wd: TWalletInfo;
  request: AnsiString;
begin
  with frmhome do
  begin

    try
      if isHex(WIFEdit.Text) then
      begin
        if (Length(WIFEdit.Text) <> 64) then

        begin
          popupWindow.Create('Key too short');
          exit;
        end;

        if HexPrivKeyCompressedRadioButton.IsChecked then
        begin
          LoadingKeyDataAniIndicator.Enabled := false;
          LoadingKeyDataAniIndicator.Visible := false;
        end
        else if HexPrivKeyNotCompressedRadioButton.IsChecked then
        begin
          LoadingKeyDataAniIndicator.Enabled := false;
          LoadingKeyDataAniIndicator.Visible := false;
        end
        else
        begin

          if Layout31.Visible = True then
          begin
            popupWindow.Create
              ('You must check whether your hey is compressed or not');
            exit;
          end;

          LoadingKeyDataAniIndicator.Enabled := True;
          LoadingKeyDataAniIndicator.Visible := True;
          if not newcoinID in [4 , 8] then
          begin

            { tthread.CreateAnonymousThread(
              procedure
              var
              comkey: AnsiString;
              notkey: AnsiString;
              WData: AnsiString;
              ts: TStringList;
              wd: TwalletInfo;
              request: AnsiString;
              begin }

            comkey := secp256k1_get_public(WIFEdit.Text, false);
            notkey := secp256k1_get_public(WIFEdit.Text, True);

            wd := coinData.createCoin(newcoinID, -1, -1,
              Bitcoin_PublicAddrToWallet(comkey, AvailableCoin[newcoinID].p2pk),
              'Imported');
            wd.pub := comkey;
            request := HODLER_URL + 'getSegwitBalance.php?coin=' + AvailableCoin
              [wd.coin].name + '&' + segwitParameters(wd);
            WData := getDataOverHTTP(request);
            ts := TStringList.Create();
            ts.Text := WData;
            if strToFloatDef(ts[0], 0) + strToFloatDef(ts[1], 0) = 0 then
            begin
              WData := getDataOverHTTP(HODLER_URL + 'getSegwitHistory.php?coin='
                + AvailableCoin[wd.coin].name + '&' + segwitParameters(wd));

              if Length(WData) > 10 then
              begin

                TThread.Synchronize(nil,
                  procedure
                  begin
                    HexPrivKeyCompressedRadioButton.IsChecked := True;
                    ts.Free;
                    ts := nil;
                    wd.Free;
                    wd := nil;
                    exit;
                  end);

              end;
            end
            else
            begin
              TThread.Synchronize(nil,
                procedure
                begin
                  HexPrivKeyCompressedRadioButton.IsChecked := True;
                  ts.Free;
                  ts := nil;
                  wd.Free;
                  wd := nil;
                  exit;
                end);
            end;
            if ts <> nil then
              ts.Free;
            if wd <> nil then
              wd.Free;

            wd := TWalletInfo.Create(newcoinID, -1, -1,
              Bitcoin_PublicAddrToWallet(notkey,
              AvailableCoin[newcoinID].p2pk), '');
            wd.pub := comkey;

            WData := getDataOverHTTP(HODLER_URL + 'getBalance.php?coin=' +
              AvailableCoin[wd.coin].name + '&address=' + wd.addr);
            ts := TStringList.Create();
            ts.Text := WData;

            if strToFloatDef(ts[0], 0) + strToFloatDef(ts[1], 0) = 0 then
            begin
              WData := getDataOverHTTP(HODLER_URL + 'getHistory.php?coin=' +
                AvailableCoin[wd.coin].name + '&address=' + wd.addr);
              if Length(WData) > 10 then
              begin
                TThread.Synchronize(nil,
                  procedure
                  begin
                    HexPrivKeyNotCompressedRadioButton.IsChecked := True;
                    ts.Free;
                    ts := nil;
                    wd.Free;
                    wd := nil;
                    exit; // +
                  end);
              end;
            end
            else
            begin
              TThread.Synchronize(nil,
                procedure
                begin
                  HexPrivKeyNotCompressedRadioButton.IsChecked := True;
                  ts.Free;
                  ts := nil;
                  wd.Free;
                  wd := nil;
                  exit;
                end);
            end;
            if ts <> nil then
              ts.Free;
            if wd <> nil then
              wd.Free;

            TThread.Synchronize(nil,
              procedure
              begin
                LoadingKeyDataAniIndicator.Enabled := false;
                LoadingKeyDataAniIndicator.Visible := false;
                Layout31.Visible := True;
              end);

            // end).Start();

            exit;
          end
          // Parsing for ETH
          //if newcoinID = 4 then   ?
          else
          begin
            { tthread.CreateAnonymousThread(
              procedure
              var
              comkey: AnsiString;
              notkey: AnsiString;
              StrData: AnsiString;
              ts: TStringList;
              wd: TwalletInfo;
              request: AnsiString;
              begin }

            {comkey := secp256k1_get_public(WIFEdit.Text, True);

            wd := TWalletInfo.Create(newcoinID, -1, -1,
              Ethereum_PublicAddrToWallet(comkey), 'Imported');
            wd.pub := comkey;  }

            TThread.Synchronize(nil,
              procedure
              begin
                LoadingKeyDataAniIndicator.Enabled := false;
                LoadingKeyDataAniIndicator.Visible := false;
                Layout31.Visible := True;
                HexPrivKeyNotCompressedRadioButton.IsChecked := True;
              end);

            //wd.Free;

            // end).Start();
            exit;

          end;

        end
      end
      else if WIFEdit.Text <> privKeyToWif(wifToPrivKey(WIFEdit.Text)) then
      begin
        popupWindow.Create('Wrong WIF');
        exit;
      end;

    except
      on E: Exception do
      begin
        popupWindow.Create('Private key is not valid');
        exit;
      end;
    end;
    TThread.Synchronize(nil,
      procedure
      begin
        btnDecryptSeed.OnClick := ImportPrivateKey;
        decryptSeedBackTabItem := pageControl.ActiveTab;
        // PageControl.ActiveTab := descryptSeed;
        btnDSBack.OnClick := backBtnDecryptSeed;
      end);

  end;
end;

end.

