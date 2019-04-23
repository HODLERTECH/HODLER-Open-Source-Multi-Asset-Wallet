unit BackupRelated;

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
  FMX.Clipboard, FMX.VirtualKeyBoard, JSON, Nano,
  languages, WalletStructureData, popupwindowData,

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
  FMX.ComboEdit{$IFDEF MSWINDOWS}
    , Winapi.ShellAPI
{$ENDIF};

procedure decryptSeedForRestore(Sender: TObject);
procedure NewHSB(path, password, accname: AnsiString);
procedure oldHSB(path, password, accname: AnsiString);
function isPasswordZip(path: AnsiString): Boolean;
function PKCheckPassword(Sender: TObject; wd: TWalletInfo = nil): Boolean;
procedure CheckSeed(Sender: TObject);
procedure ImportPriv(Sender: TObject);
procedure splitWords(Sender: TObject);
procedure restoreEQR(Sender: TObject);
procedure SendHSB;
procedure SendEQR;
procedure RestoreFromFile(Sender: TObject);
function SweepCoinsRoutine(priv: AnsiString; isCompressed: Boolean;
  coin: Integer; targetAddr: AnsiString): AnsiString;
procedure Claim(CoinID: Integer);
procedure createClaimCoinList(id: Integer);
function createExportPrivateKeyList(ExportCoinID: Integer): Integer;
function isEQRGenerated: Boolean;

implementation

uses uHome, misc, AccountData, base58, bech32, CurrencyConverter, SyncThr, WIF,
  Bitcoin, coinData, cryptoCurrencyData, Ethereum, secp256k1, tokenData,
  transactions, AccountRelated, walletViewRelated, KeypoolRelated,
  TImageTextButtonData;

function createExportPrivateKeyList(ExportCoinID: Integer): Integer;
{ var
  i: Integer;
  panel: TPanel;
  lbl: TLabel;
  image: TImage;
  bilancelbl: TLabel; }
var
  i: Integer;
begin
  result := 0;
  clearVertScrollBox(frmhome.ExportPrivKeyListVertScrollBox);

  for i := 0 to length(CurrentAccount.myCoins) - 1 do
  begin

    if CurrentAccount.myCoins[i].coin = ExportCoinID then
      result := result + 1;

  end;

  if result > 0 then

    tthread.CreateAnonymousThread(
      procedure
      var
        i: Integer;
        panel: TPanel;
        lbl: TLabel;
        image: TImage;
        bilancelbl: TLabel;
      begin

        tthread.Synchronize(nil,
          procedure
          begin

            frmhome.LoadAddressesToImortAniIndicator.visible := true;
            frmhome.LoadAddressesToImortAniIndicator.enabled := true;
            // frmhome.LoadAddressesToImortAniIndicator.

          end);

        for i := 0 to (length(CurrentAccount.myCoins) - 1) do
        begin
          if CurrentAccount.myCoins[i].coin <> ExportCoinID then
            continue;

          if ((CurrentAccount.myCoins[i].confirmed) <> 0) or
            frmhome.exportemptyaddressesSwitch.ischecked then
          begin
            tthread.Synchronize(nil,
              procedure
              begin

                panel := TPanel.create(frmhome.ExportPrivKeyListVertScrollBox);
                panel.parent := frmhome.ExportPrivKeyListVertScrollBox;
                panel.visible := true;
                panel.align := TAlignLayout.MostTop;
                panel.height := 48;
                panel.tagObject := CurrentAccount.myCoins[i];
{$IF defined(ANDROID) or defined(IOS)}
                panel.OnTap := frmhome.ExportPrivKeyListButtonClick;
{$ELSE}
                panel.onclick := frmhome.ExportPrivKeyListButtonClick;
{$ENDIF}
                panel.Position.Y := -1;

                lbl := TLabel.create(panel);
                lbl.parent := panel;
                lbl.align := TAlignLayout.client;
                lbl.margins.left := 15;
                lbl.margins.right := 15;
                lbl.visible := true;
                lbl.Text := CurrentAccount.myCoins[i].addr;

                image := TImage.create(panel);
                image.parent := panel;
                image.bitmap.LoadFromStream(getcoinIconResource
                  (CurrentAccount.myCoins[i].coin));
                image.align := TAlignLayout.left;
                image.width := 32 + 2 * 15;
                image.visible := true;
                image.margins.Top := 8;
                image.margins.Bottom := 8;

                bilancelbl := TLabel.create(panel);
                bilancelbl.parent := panel;
                bilancelbl.align := TAlignLayout.right;
                bilancelbl.width := 96;
                bilancelbl.visible := true;
                bilancelbl.margins.right := 15;
                bilancelbl.Text := BigIntegerBeautifulStr
                  ((CurrentAccount.myCoins[i].confirmed),
                  CurrentAccount.myCoins[i].decimals);
                bilancelbl.TextSettings.HorzAlign := TTextAlign.Trailing;

              end);

          end;
        end;

        // showmessage( inttoStr(frmhome.ExportPrivKeyListVertScrollBox.Content.ChildrenCount) ) ;
        tthread.Synchronize(nil,
          procedure
          begin
            frmhome.emptyAddressesLayout.visible :=
              (frmhome.ExportPrivKeyListVertScrollBox.Content.
              ChildrenCount <= 1);
            frmhome.LoadAddressesToImortAniIndicator.visible := false;
            frmhome.LoadAddressesToImortAniIndicator.enabled := false;
          end);

      end).Start();

end;

procedure createClaimCoinList(id: Integer);
var
  i: Integer;
  panel: TPanel;
  lbl: TLabel;
  image: TImage;
begin

  clearVertScrollBox(frmhome.ClaimCoinListvertScrollBox);

  for i := 0 to (length(CurrentAccount.myCoins) - 1) do
  begin

    if (CurrentAccount.myCoins[i].coin = id) then
    begin

      panel := TPanel.create(frmhome.ClaimCoinListvertScrollBox);
      panel.parent := frmhome.ClaimCoinListvertScrollBox;
      panel.visible := true;
      panel.align := TAlignLayout.Top;
      panel.height := 48;
      panel.tagObject := CurrentAccount.myCoins[i];
      panel.onclick := frmhome.ClaimCoinSelectInListClick;
      panel.Position.Y := -1;

      lbl := TLabel.create(panel);
      lbl.parent := panel;
      lbl.align := TAlignLayout.client;
      lbl.margins.left := 15;
      lbl.margins.right := 15;
      lbl.visible := true;
      lbl.Text := CurrentAccount.myCoins[i].addr;

      image := TImage.create(panel);
      image.parent := panel;
      image.bitmap.LoadFromStream
        (getcoinIconResource(CurrentAccount.myCoins[i].coin));
      image.align := TAlignLayout.left;
      image.width := 32 + 2 * 15;
      image.visible := true;
      image.margins.Top := 8;
      image.margins.Bottom := 8;
    end;
  end;

end;

procedure Claim(CoinID: Integer);
var
  ans: AnsiString;
  tempPriv, out , pub: AnsiString;
  isCompressed: Boolean;
  WData: WIFAddressData;
  tmp: Integer;
  // targetAddr : AnsiString;

begin
  if ((frmhome.PrivateKeyEditSV.Text = '')) then
  begin
    popupWindow.create('Missing Values');
    exit();
  end;

  tempPriv := removeSpace(frmhome.PrivateKeyEditSV.Text);

  if isHex(tempPriv) and (length(tempPriv) = 64) then
  begin
    out := tempPriv;
    isCompressed := frmhome.CompressedPrivKeySVCheckBox.ischecked;
  end
  else
  begin
    WData := wifToPrivKey(tempPriv);
    isCompressed := WData.isCompressed;
    out := WData.PrivKey;
  end;
  pub := secp256k1_get_public(out , not isCompressed);

  if fromClaimWD <> nil then
    fromClaimWD.Free;

  fromClaimWD := TWalletInfo.create(CoinID, -1, -1,
    Bitcoin_PublicAddrToWallet(pub, AvailableCoin[CoinID].p2pk), '__dashbrd__');
  fromClaimWD.pub := pub;
  fromClaimWD.EncryptedPrivKey := out;
  fromClaimWD.isCompressed := isCompressed;
  if CoinID in [4] then
  begin
    exit; // ETH can contain tokens     better import private key
    parseBalances(getDataOverHTTP(HODLER_URL + 'getBalance.php?coin=' +
      AvailableCoin[CoinID].name + '&address=' + fromClaimWD.addr),
      fromClaimWD);
  end
  else
  begin
    parseBalances(getDataOverHTTP(HODLER_URL + 'getSegwitBalance.php?coin=' +
      AvailableCoin[CoinID].name + segwitParameters(fromClaimWD)), fromClaimWD);
    // '&address=' + fromClaimWD.addr), fromClaimWD);
  end;

  fromClaimWD.UTXO :=
    parseUTXO(getDataOverHTTP(HODLER_URL + 'getSegwitUTXO.php?coin=' +
    AvailableCoin[CoinID].name + segwitParameters(fromClaimWD)
    { '&address=' + fromClaimWD.addr } ), -1); // <<<<< SEGWIT!!!

  // tmp:=CurrentCoin.coin;
  /// CurrentCoin.coin:=7;

  if (toClaimWD.addr = fromClaimWD.addr) or
    (bitcoinCashAddressToCashAddress(fromClaimWD.addr)
    = rightStr(toClaimWD.addr,
    length(bitcoinCashAddressToCashAddress(fromClaimWD.addr)))) then
  begin
    raise Exception.create('Use different destination address');
  end;

  if not isValidForCoin(CoinID, toClaimWD.addr) then
  begin
    raise Exception.create('Wrong Target Address');
  end;

  if fromClaimWD.confirmed <= BigInteger(1700) then
  begin
    raise Exception.create('Amount too small');
  end;



  // WalletViewRelated.PrepareSendTabAndSend(wd, targetAddr, wd.confirmed-BigInteger(1700), BigInteger(1700), '', AvailableCoin[coin].name);
  // CurrentCoin.coin:=tmp;

  frmhome.SendFromLabel.Text := Bitcoin_PublicAddrToWallet(pub,
    AvailableCoin[CoinID].p2pk);
  frmhome.SendToLabel.Text := toClaimWD.addr;
  frmhome.SendFeeLabel.Text := '0.00001700';
  frmhome.SendValueLabel.Text := BigIntegerToFloatStr(fromClaimWD.confirmed -
    BigInteger(1700), AvailableCoin[CoinID].decimals);

  frmhome.BCHSVBCHABCReplayProtectionLabel.visible :=
    ((toClaimWD.coin = 3) or (toClaimWD.coin = 7));

  { try

    ans := SweepCoinsRoutine(frmhome.PrivateKeyEditSV.text ,frmhome.CompressedPrivKeySVCheckBox.ischecked,7,frmhome.AddressSVEdit.text);
    if ans <> '' then


    except on E: Exception do
    begin
    popupWindow.Create( E.Message );
    end;
    end; }

  frmhome.ConfirmSendPasswordPanel.visible := false;
  frmhome.SendTransactionButton.visible := false;
  frmhome.ConfirmSendClaimCoinButton.visible := true;

  switchTab(frmhome.pageControl, frmhome.ConfirmSendTabItem);
  frmhome.PrivateKeyEditSV.Text := '';

end;

procedure RestoreFromFile(Sender: TObject);
var
  openDialog: TOpenDialog;
begin
{$IFDEF ANDROID}
  with frmhome do
  begin
    clearVertScrollBox(BackupFileListVertScrollBox);

    requestForPermission('android.permission.READ_EXTERNAL_STORAGE');
    tthread.CreateAnonymousThread(
      procedure
      var
        i: Integer;
      begin

        for i := 0 to 5 * 30 do
        begin
          if (elevateCheckPermission('android.permission.READ_EXTERNAL_STORAGE')
            = -1) then
          begin
            sleep(200);
          end
          else
          begin

            tthread.CreateAnonymousThread(
              procedure
              var
                strArr: TStringDynArray;
                Button: TImageTextButton;

              begin

                tthread.Synchronize(nil,
                  procedure
                  begin
                    LoadBackupFileAniIndicator.visible := true;
                    LoadBackupFileAniIndicator.enabled := true;
                  end);

                strArr := TDirectory.GetFiles(TDirectory.GetParent
                  (System.IOUtils.TPath.GetSharedDownloadsPath()), '*.hsb.zip',
                  TSearchOption.SoAllDirectories);

                tthread.Synchronize(nil,
                  procedure
                  var
                    i: Integer;
                  begin

                    for i := 0 to length(strArr) - 1 do
                    begin
                      Button := TImageTextButton.create
                        (BackupFileListVertScrollBox);
                      Button.LoadImage('HSB_' + rightStr(currentStyle,
                        length(currentStyle) - 3));
                      Button.TagString := 'hodler_secure_backup_image';
                      Button.visible := true;
                      Button.align := TAlignLayout.Top;
                      Button.height := 48;
                      Button.lbl.Text := extractfilename(strArr[i]);
                      { if LeftStr(strArr[i],
                        length(TDirectory.GetParent(System.IOUtils.TPath.
                        GetSharedDownloadsPath()))) = TDirectory.GetParent
                        (System.IOUtils.TPath.GetSharedDownloadsPath()) then
                        Button.lbl.Text := rightStr(strArr[i],
                        length(strArr[i]) -
                        length(TDirectory.GetParent
                        (System.IOUtils.TPath.GetSharedDownloadsPath())))
                        else
                        Button.lbl.Text := strArr[i]; }
                      Button.TagString := strArr[i];
                      Button.parent := BackupFileListVertScrollBox;
                      Button.onclick := SelectFileInBackupFileList;
                    end;
                    BackupFileListVertScrollBox.height :=
                      min(frmhome.height - (OpenFileMenagerLayout.height +
                      ChooseHSBStaticLabel.height + RFFHeader.height),
                      length(strArr) * Button.height);

                    LoadBackupFileAniIndicator.visible := false;
                    LoadBackupFileAniIndicator.enabled := false;

                  end);

              end).Start;

            tthread.Synchronize(nil,
              procedure
              begin

                restoreFromFileBackTabItem := pageControl.ActiveTab;
                RFFPathEdit.Text := System.IOUtils.TPath.GetDownloadsPath();
                switchTab(pageControl, RestoreFromFileTabitem);

              end);
            // RFFPathEdit.Text := 'C:\';
            // ResotreFromFileBackTabItem
            // restoreFromFileBackTabItem := PageControl.ActiveTab;
            // switchTab(pageControl, RestoreFromFileTabitem);
            break;
          end;
        end;

      end).Start;
  end;
{$ENDIF}
{$IF DEFINED(MSWINDOWS) OR DEFINED(LINUX)}
  openDialog := TOpenDialog.create(frmhome);
  openDialog.Title := 'Open File';
  openDialog.InitialDir := GetCurrentDir;
  openDialog.Filter := 'Zip File|*.zip';
  openDialog.DefaultExt := 'zip';
  openDialog.FilterIndex := 1;

  if openDialog.Execute then
  begin

    frmhome.RFFPathEdit.Text := openDialog.FileName;
    switchTab(frmhome.pageControl, frmhome.HSBPassword);

  end;

  openDialog.Free;

{$ENDIF}
end;

procedure SendHSB;
var
  i: Integer;
  Zip: TEncryptedZipFile;
  img: TBitmap;
  tempStr: TStream;
  tempText: String;
  ImgPath: AnsiString;
  zipPath: AnsiString;
  protectorPath: AnsiString;
  ts: TStringList;
  it: AnsiString;
  FileName: AnsiString;
var
  MasterSeed, tced: AnsiString;
  Y, m, d: Word;
begin
  with frmhome do
  begin

    tced := TCA(passwordForDecrypt.Text);

    MasterSeed := SpeckDecrypt(tced, CurrentAccount.EncryptedMasterSeed);
    if not isHex(MasterSeed) then
    begin
      popupWindow.create(dictionary('FailedToDecrypt'));
      passwordForDecrypt.Text := '';
      exit;
    end;
    startFullfillingKeypool(MasterSeed);
    DecodeDate(Now, Y, m, d);
    FileName := CurrentAccount.name + '_' + Format('%d.%d.%d', [Y, m, d]) + '.'
      + IntToStr(DateTimeToUnix(Now));

    zipPath := System.IOUtils.TPath.Combine
      ({$IFDEF IOS}HOME_PATH{$ELSE}System.IOUtils.TPath.GetDownloadsPath
      (){$ENDIF}, FileName + '.hsb.zip');

    if FileExists(zipPath) then
      DeleteFile(zipPath);
    Zip := TEncryptedZipFile.create('');
    Zip.Open(zipPath, TZipMode.zmWrite);

    img := StrToQRBitmap(CurrentAccount.EncryptedMasterSeed);
    ImgPath := System.IOUtils.TPath.Combine(HOME_PATH, 'QREncryptedSeed.png');
    img.SaveToFile(ImgPath);

    for it in CurrentAccount.Paths do
    begin

      ts := TStringList.create();
      ts.LoadFromFile(it);
      tempText := ts.Text;
      ts.Text := speckEncrypt(tced, speckStrPadding(ts.Text));
      ts.SaveToFile(LeftStr(it, length(it) - 3) + 'hsb');
      ts.SaveToFile(it);
      ts.Free;
      Zip.Add(it);
      ts := TStringList.create();
      ts.LoadFromFile(it);
      ts.Text := tempText;
      ts.SaveToFile(it);
      ts.Free;
    end;
    tced := '';
    MasterSeed := '';
    for it in CurrentAccount.Paths do
    begin
      Zip.Add(LeftStr(it, length(it) - 3) + 'hsb');
    end;
    Zip.Add(ImgPath);
    Zip.Close;
    shareFile(zipPath);
    CurrentAccount.userSaveSeed := true;
    CurrentAccount.SaveFiles();
    DeleteFile(ImgPath);
    img.Free;
    Zip.Free;
    switchTab(pageControl, decryptSeedBackTabItem);
    passwordForDecrypt.Text := '';
  end;
end;

function isEQRGenerated: Boolean;
begin
  result := FileExists(System.IOUtils.TPath.Combine(
{$IF DEFINED(MSWINDOWS) OR DEFINED(LINUX)}HOME_PATH{$ELSE}System.IOUtils.TPath.GetDownloadsPath
    (){$ENDIF}, CurrentAccount.name + '_EQR_BIG' + '.png')) and
    FileExists(System.IOUtils.TPath.Combine(
{$IF DEFINED(MSWINDOWS) OR DEFINED(LINUX)}HOME_PATH{$ELSE}System.IOUtils.TPath.GetDownloadsPath
    (){$ENDIF}, CurrentAccount.name + '_EQR_SMALL' + '.png'));
end;

procedure SendEQR;
var
  i: Integer;
  img, qrimg: TBitmap;
  tempStr: TStream;
  FileName: string;
  Stream: TResourceStream;
  Y, m, d: Word;
begin
         if not FileExists( CurrentAccount.SmallQRImagePath ) then
    begin

      img := StrToQRBitmap( CurrentAccount.EncryptedMasterSeed,8 );

      img.SaveToFile(CurrentAccount.SmallQRImagePath);
      img.free;
    end;
    if not FileExists(CurrentAccount.BigQRImagePath) then
    begin

      qrimg := StrToQRBitmap(CurrentAccount.EncryptedMasterSeed, 16);
      img := TBitmap.create();
      Stream := TResourceStream.create(HInstance, 'IMG_EQR', RT_RCDATA);
      try
        img.LoadFromStream(Stream);
      finally
        Stream.Free;
      end;
      img.Canvas.BeginScene;
      img.Canvas.DrawBitmap(qrimg, RectF(0, 0, 797, 797),
        RectF(294, 514, 797 + 294, 797 + 514), 1);
      img.Canvas.EndScene;

      img.SaveToFile(CurrentAccount.BigQRImagePath);
      img.Free;
      qrimg.Free;

    end;



    CurrentAccount.userSaveSeed := true;
    //CurrentAccount.SaveSeedFile();
    // ? userSavedSeed := true;
    //refreshWalletDat();
end;

procedure restoreEQR(Sender: TObject);
var
  MasterSeed, tced,s: AnsiString;
  ac: Account;
  i: Integer;
begin
  with frmhome do
  begin
  s:=RestorePasswordEdit.Text;
  tced := TCA(s);
    MasterSeed := SpeckDecrypt(tced, tempQRFindEncryptedSeed);
    if not isHex(MasterSeed) then
    begin
      popupWindow.create(dictionary('FailedToDecrypt'));
      exit;
    end;

    if (RestoreNameEdit.Text = '') or (length(RestoreNameEdit.Text) < 3) then
    begin
      popupWindow.create(dictionary('AccountNameTooShort'));
      exit();
    end;

    for i := 0 to length(AccountsNames) - 1 do
    begin

      if AccountsNames[i].name = RestoreNameEdit.Text then
      begin
        popupWindow.create(dictionary('AccountNameOccupied'));
        exit();
      end;

    end;

    createSelectGenerateCoinView();
    frmhome.NextButtonSGC.onclick := frmhome.CoinListCreateFromQR;
    switchTab(pageControl, frmhome.SelectGenetareCoin);

    tced := '';
    MasterSeed := '';
    s:='';
  end;
end;

procedure splitWords(Sender: TObject);
var
  tempList: TStringList;
  it: AnsiString;
  Button: TButton;
  maks, i: Integer;
begin
  with frmhome do
  begin
    maks := 0;

    i := SeedWordsFlowLayout.ComponentCount - 1;
    while i >= 0 do
    begin
      if SeedWordsFlowLayout.Components[i].ClassType = TButton then
      begin
        SeedWordsFlowLayout.Components[i].DisposeOf;
        i := SeedWordsFlowLayout.ComponentCount - 1
      end
      else
        dec(i);
    end;

    tempList := SplitString(toMnemonic(tempMasterSeed));
    tempList.Sort;

    for it in tempList do
    begin
      Button := TButton.create(SeedWordsFlowLayout);
      Button.Text := it;
      Button.height := 36;
      Button.width := Button.width + length(it) * 3;
      Button.visible := true;
      Button.parent := SeedWordsFlowLayout;
      Button.onclick := frmhome.WordSeedClick;

    end;
    for i := 0 to SeedWordsFlowLayout.ComponentCount - 1 do
    begin

      if SeedWordsFlowLayout.Components[i] is TButton then
      begin
        if maks < (TButton(SeedWordsFlowLayout.Components[i]).Position.Y +
          TButton(SeedWordsFlowLayout.Components[i]).height) then
          maks := ceil(TButton(SeedWordsFlowLayout.Components[i]).Position.Y +
            TButton(SeedWordsFlowLayout.Components[i]).height);
      end;

    end;

    SeedWordsFlowLayout.height := maks;
    ConfirmedSeedFlowLayout.height := 1;
    tempList.Free;
  end;

end;

function SweepCoinsRoutine(priv: AnsiString; isCompressed: Boolean;
coin: Integer; targetAddr: AnsiString): AnsiString;
var
  out , pub: AnsiString;
  WData: WIFAddressData;
  wd: TWalletInfo;
  tmp: Integer;
begin

  priv := removeSpace(priv);
  targetAddr := removeSpace(targetAddr);

  if isHex(priv) and (length(priv) = 64) then
  begin
    out := priv;
  end
  else
  begin
    WData := wifToPrivKey(priv);
    isCompressed := WData.isCompressed;
    out := WData.PrivKey;
  end;
  pub := secp256k1_get_public(out , not isCompressed);

  wd := TWalletInfo.create(coin, -1, -1, Bitcoin_PublicAddrToWallet(pub,
    AvailableCoin[ImportCoinID].p2pk), 'Imported');
  wd.pub := pub;
  wd.EncryptedPrivKey := out;
  wd.isCompressed := isCompressed;
  parseBalances(getDataOverHTTP(HODLER_URL + 'getBalance.php?coin=' +
    AvailableCoin[coin].name + '&address=' + wd.addr), wd);
  wd.UTXO := parseUTXO(getDataOverHTTP(HODLER_URL + 'getUTXO.php?coin=' +
    AvailableCoin[coin].name + '&address=' + wd.addr), -1);
  tmp := CurrentCoin.coin;
  CurrentCoin.coin := coin;

  if (targetAddr = wd.addr) or (bitcoinCashAddressToCashAddress(wd.addr)
    = rightStr(targetAddr, length(bitcoinCashAddressToCashAddress(wd.addr))))
  then
  begin
    raise Exception.create('Use different destination address');
  end;

  if not isValidForCoin(coin, targetAddr) then
  begin
    raise Exception.create('Wrong Target Address');
  end;

  if wd.confirmed <= BigInteger(1700) then
  begin
    raise Exception.create('Amount too small');
  end;

  walletViewRelated.PrepareSendTabAndSend(wd, targetAddr,
    wd.confirmed - BigInteger(1700), BigInteger(1700), '',
    AvailableCoin[coin].name);
  CurrentCoin.coin := tmp;
  // free wd ?
end;

procedure ImportPriv(Sender: TObject);
var
  ts: TStringList;
  path: AnsiString;
  out : AnsiString;
  wd: TWalletInfo;
  isCompressed: Boolean;
  WData: WIFAddressData;
  pub: AnsiString;

  tced: AnsiString;
  MasterSeed: AnsiString;
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
    startFullfillingKeypool(MasterSeed);
    /// ///////////////////////////////////////////

    if isHex(WIFEdit.Text) and (length(WIFEdit.Text) = 64) then
    begin
      out := WIFEdit.Text;
      if HexPrivKeyCompressedRadioButton.ischecked then
        isCompressed := true
      else if HexPrivKeyNotCompressedRadioButton.ischecked then
        isCompressed := false
      else
        raise Exception.create('compression not defined');

    end
    else
    begin
      WData := wifToPrivKey(WIFEdit.Text);
      isCompressed := WData.isCompressed;
      out := WData.PrivKey;
    end;
    if ImportCoinID <> 4 then
    begin
      pub := secp256k1_get_public(out , not isCompressed);

      wd := TWalletInfo.create(ImportCoinID, -1, -1,
        Bitcoin_PublicAddrToWallet(pub, AvailableCoin[ImportCoinID].p2pk),
        'Imported');
      wd.pub := pub;
      wd.EncryptedPrivKey := speckEncrypt((TCA(MasterSeed)), out);
      wd.isCompressed := isCompressed;
    end
    else if ImportCoinID = 4 then
    begin
      pub := secp256k1_get_public(out , true);
      wd := TWalletInfo.create(ImportCoinID, -1, -1,
        Ethereum_PublicAddrToWallet(pub), 'Imported');
      wd.pub := pub;
      wd.EncryptedPrivKey := speckEncrypt((TCA(MasterSeed)), out);
      wd.isCompressed := false;
    end;
    CurrentAccount.AddCoin(wd);
    CreatePanel(wd , CurrentAccount , frmhome.walletList);

    MasterSeed := '';

    if ImportCoinID = 4 then
    begin
      SearchTokens(wd.addr);
    end;
  end;
end;

procedure CheckSeed(Sender: TObject);
var
  withoutWhiteChar: AnsiString;
  seedFromWords: AnsiString;
  it: AnsiString;
  inputWordsList: TStringList;

begin
  with frmhome do
  begin
    withoutWhiteChar := StringReplace(frmhome.SeedField.Text, ' ', '',
      [rfReplaceAll]);
    withoutWhiteChar := StringReplace(withoutWhiteChar, #13, '',
      [rfReplaceAll]);
    withoutWhiteChar := StringReplace(withoutWhiteChar, #10, '',
      [rfReplaceAll]);

    if (length(withoutWhiteChar) = 64) and (isHex(frmhome.SeedField.Text)) then
    begin
      userSavedSeed := true;

      CreateNewAccountAndSave(AccountNameEdit.Text, pass.Text,
        withoutWhiteChar, true);

      withoutWhiteChar := '';
      frmhome.SeedField.Text := '';
      LoadCurrentAccount(AccountNameEdit.Text);
      AccountRelated.afterInitialize;
      exit;
    end
    else
    begin

      if trim(frmhome.SeedField.Text) = '' then
        exit;

      inputWordsList := SplitString(frmhome.SeedField.Text);
      seedFromWords := fromMnemonic(inputWordsList);
      if (seedFromWords =
        '0000000000000000000000000000000000000000000000000000000000000000') or
        (seedFromWords = '') then
      begin
        exit;
      end;
      userSavedSeed := true;
      CreateNewAccountAndSave(AccountNameEdit.Text, pass.Text,
        seedFromWords, true);

      seedFromWords := '';
      inputWordsList.Free;
      //LoadCurrentAccount(AccountNameEdit.Text);
      //AccountRelated.afterInitialize;
      {
        Dodaæ obs³ugê b³êdów
      }

      exit;
    end;
  end;
end;

function PKCheckPassword(Sender: TObject; wd: TWalletInfo = nil): Boolean;
var
  MasterSeed, tced: AnsiString;
var
  bitmap: TBitmap;
  tempStr: AnsiString;
{$IF DEFINED(MSWINDOWS) OR DEFINED(LINUX)}lblPrivateKey: TMemo; {$ENDIF}
begin
  if wd = nil then
  begin
    // {$IFDEF MSWINDOWS}
    // wd := CurrentCoin;
    // {$ELSE}
    showmessage(' ERROR wd empty ');
    // {$ENDIF}
    exit
  end;

  result := true;
  with frmhome do
  begin

    tced := TCA(passwordForDecrypt.Text);
    passwordForDecrypt.Text := '';
    MasterSeed := SpeckDecrypt(tced, CurrentAccount.EncryptedMasterSeed);
    if (wd.X = -1) and (wd.Y = -1) then
    begin

      tempStr := SpeckDecrypt(TCA(MasterSeed), wd.EncryptedPrivKey);

      if not isHex(tempStr) then
      begin
        raise Exception.create(dictionary('FailedToDecrypt'));
        exit(false);
      end;
      startFullfillingKeypool(MasterSeed);
      // {$IFDEF MSWINDOWS}lblPrivateKey:=PrivateKeyMemo;{$ENDIF}
      lblPrivateKey.Text := tempStr;
      lblWIFKey.Text := PrivKeyToWIF(tempStr, wd.isCompressed,
        AvailableCoin[TWalletInfo(wd).coin].wifByte);
      tempStr := '';
      wipeAnsiString(MasterSeed);

    end
    else
    begin

      if not isHex(MasterSeed) then
      begin
        raise Exception.create(dictionary('FailedToDecrypt'));
        wipeAnsiString(MasterSeed);
        exit(false);
      end;
      startFullfillingKeypool(MasterSeed);
      lblPrivateKey.Text := priv256forhd(wd.coin, wd.X, wd.Y, MasterSeed);
      if wd.coin <> 4 then
        lblWIFKey.Text := PrivKeyToWIF(lblPrivateKey.Text, wd.coin <> 4,
          AvailableCoin[TWalletInfo(wd).coin].wifByte);
      if wd.coin = 8 then
      begin

        lblPrivateKey.Text := nano_getPriv(NanoCoin(wd), MasterSeed);
        lblWIFKey.Text := '';
      end;
      wipeAnsiString(MasterSeed);

    end;
    PrivateKeyBalanceInfoLabel.Text := BigIntegerToFloatStr(wd.confirmed,
      wd.decimals);
    PrivateKeyAddressInfoLabel.Text := wd.addr;
{$IF DEFINED(ANDROID) OR DEFINED(IOS)}
    lblPrivateKey.Text := cutEveryNChar(length(lblPrivateKey.Text) div 2,
      lblPrivateKey.Text , #13#10);
    if wd.coin <> 8 then
      lblWIFKey.Text := cutEveryNChar(length(lblWIFKey.Text) div 2,
        lblWIFKey.Text , #13#10)
    else
      lblWIFKey.Text := '';
{$ENDIF}
    bitmap := StrToQRBitmap(removeSpace(lblPrivateKey.Text));
    PrivKeyQRImage.bitmap.Assign(bitmap);
    bitmap.Free;
  end;

end;

procedure oldHSB(path, password, accname: AnsiString);
var
  Zip: TEncryptedZipFile;
  str: AnsiString;
  dezip: TZipFile;
  it: AnsiString;
  ac: Account;
  failure: Boolean;
begin
  failure := false;
  Zip := TEncryptedZipFile.create(password);
  Zip.Open(path, TZipMode.zmRead);
  ac := Account.create(accname);
  ac.SaveFiles();
  for it in ac.Paths do
  begin

    try

      Zip.Extract(extractfilename(it), ac.DirPath);
    except
      on E: Exception do
        try
          Zip.Extract(LeftStr(extractfilename(it), length(extractfilename(it)) -
            3) + 'hsb', ac.DirPath);
          RenameFile(LeftStr(it, length(it) - 3) + 'hsb', it);
        except
          on F: Exception do
          begin
            failure := true;
            // showmessage('Wrong password or damaged file');

          end;
        end;
    end;

  end;
  ac.Free;

  Zip.Close;
  Zip.Free;
  if failure then
  begin
    RemoveDir(ac.DirPath);
    popupWindow.create('Wrong password or damaged file');
    // frmHome.FormShow(nil);
    exit;
  end;
  ac := Account.create(accname);
  ac.LoadFiles;
  ac.userSaveSeed := true;
  ac.SaveFiles;
  AddAccountToFile(ac);

  ac.Free;

  LoadCurrentAccount(accname);
  AccountRelated.afterInitialize;
end;

function isPasswordZip(path: AnsiString): Boolean;
var
  Zip: TZipFile;
  ZipHeader: TZipHeader;
  ts: TStream;
begin
  result := false;
  Zip := TZipFile.create;
  Zip.Open(path, TZipMode.zmRead);
  ts := TStream.create;
  Zip.Read(0, ts, ZipHeader);
  if ZipHeader.Flag and 1 = 1 then
    result := true;
  Zip.Free;
  ts.Free;
end;

procedure NewHSB(path, password, accname: AnsiString);
var
  Zip: TEncryptedZipFile;
  str: AnsiString;
  dezip: TZipFile;
  it: AnsiString;
  ac: Account;
  failure: Boolean;
  tced: AnsiString;
  ts: TStringList;
begin
  failure := false;
  tced := TCA(password);
  Zip := TEncryptedZipFile.create('');
  Zip.Open(path, TZipMode.zmRead);
  ac := Account.create(accname);
  ac.SaveFiles();
  for it in ac.Paths do
  begin

    try

      Zip.Extract(extractfilename(it), ac.DirPath);
    except
      on E: Exception do
        try
          Zip.Extract(LeftStr(extractfilename(it), length(extractfilename(it)) -
            3) + 'hsb', ac.DirPath);
          RenameFile(LeftStr(it, length(it) - 3) + 'hsb', it);
        except
          on F: Exception do
          begin
            failure := true;
            // showmessage('Damaged file');

          end;
        end;
    end;
    try
      ts := TStringList.create;
      ts.LoadFromFile(it);
      if isHex(trim(ts.Text)) then
        ts.Text := SpeckDecrypt(tced, trim(ts.Text));
      ts.SaveToFile(it);
    finally
      ts.Free;
    end;
  end;
  ac.Free;

  Zip.Close;
  Zip.Free;
  if failure then
  begin
    popupWindow.create('Wrong password or damaged file');
    RemoveDir(ac.DirPath);
    // frmHome.FormShow(nil);
    // showmessage('Failed to decrypt files');
    exit;
  end;
  ac := Account.create(accname);
  try
    ac.LoadFiles;
  except
    on E: Exception do
    begin
      RemoveDir(ac.DirPath);
      popupWindow.create('Wrong password or damaged file');
      // frmHome.FormShow(nil);
      exit;
    end;
  end;
  ac.userSaveSeed := true;
  ac.SaveFiles;
  AddAccountToFile(ac);

  ac.Free;

  LoadCurrentAccount(accname);
  AccountRelated.afterInitialize;
end;

procedure decryptSeedForRestore(Sender: TObject);
var
  MasterSeed, tced: AnsiString;
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
    startFullfillingKeypool(MasterSeed);
    switchTab(pageControl, seedGenerated);
    BackupMemo.Lines.Clear;
    BackupMemo.Lines.Add(dictionary('MasterseedMnemonic') + ':');
    BackupMemo.Lines.Add(toMnemonic(MasterSeed));
    tempMasterSeed := MasterSeed;
    MasterSeed := '';
  end;
end;

end.
