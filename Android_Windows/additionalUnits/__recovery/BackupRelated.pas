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
  {FMX.Menus,}
  ZXing.BarcodeFormat,
  ZXing.ReadResult,
  ZXing.ScanManager, FMX.EditBox, FMX.SpinBox, FMX.Gestures, FMX.Effects,
  FMX.Filter.Effects, System.Actions, FMX.ActnList, System.Math.Vectors,
  FMX.Controls3D, FMX.Layers3D, FMX.StdActns, FMX.MediaLibrary.Actions,
  FMX.ComboEdit;

procedure decryptSeedForRestore(Sender: TObject);
procedure NewHSB(path, password, accname: AnsiString);
procedure oldHSB(path, password, accname: AnsiString);
function isPasswordZip(path: AnsiString): Boolean;
function PKCheckPassword(Sender: TObject): Boolean;
procedure CheckSeed(Sender: TObject);
procedure ImportPriv(Sender: TObject);
procedure splitWords(Sender: TObject);
procedure restoreEQR(Sender: TObject);
procedure SendHSB;
procedure SendEQR;
procedure RestoreFromFile(Sender: TObject);
function SweepCoinsRoutine(priv: AnsiString; isCompressed: Boolean;
coin: Integer; targetAddr: AnsiString):AnsiString;
procedure ClaimSV();

implementation

uses uHome, misc, AccountData, base58, bech32, CurrencyConverter, SyncThr, WIF,
  Bitcoin, coinData, cryptoCurrencyData, Ethereum, secp256k1, tokenData,
  transactions, WalletStructureData, AccountRelated, walletViewRelated;

procedure ClaimSV();
var
  ans : AnsiString;
begin
  if ((frmhome.PrivateKeyEditSV.text = '') or (frmhome.AddressSVEdit.text = '')) then
  begin
    popupWindow.Create('Missing Values');
    exit();
  end;
  try

    ans := SweepCoinsRoutine(frmhome.PrivateKeyEditSV.text ,frmhome.CompressedPrivKeySVCheckBox.ischecked,7,frmhome.AddressSVEdit.text);
    if ans <> '' then


  except on E: Exception do
  begin
    popupWindow.Create( E.Message );
  end;
  end;

end;


procedure RestoreFromFile(Sender: TObject);
var
  openDialog: TOpenDialog;
begin
{$IFDEF ANDROID}
  with frmHome do
  begin
    clearVertScrollBox(BackupFileListVertScrollBox);

    requestForPermission('android.permission.READ_EXTERNAL_STORAGE');
    Tthread.CreateAnonymousThread(
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

            Tthread.CreateAnonymousThread(
              procedure
              var
                strArr: TStringDynArray;
                Button: TButton;

              begin

                Tthread.Synchronize(nil,
                  procedure
                  begin
                    LoadBackupFileAniIndicator.Visible := true;
                    LoadBackupFileAniIndicator.Enabled := true;
                  end);

                strArr := TDirectory.GetFiles(TDirectory.GetParent
                  (System.IOUtils.TPath.GetSharedDownloadsPath()), '*.hsb.zip',
                  TSearchOption.SoAllDirectories);

                Tthread.Synchronize(nil,
                  procedure
                  var
                    i: Integer;
                  begin

                    for i := 0 to length(strArr) - 1 do
                    begin
                      Button := TButton.Create(BackupFileListVertScrollBox);
                      Button.Visible := true;
                      Button.Align := TAlignLayout.Top;
                      Button.Height := 48;
                      if LeftStr(strArr[i],
                        length(TDirectory.GetParent(System.IOUtils.TPath.
                        GetSharedDownloadsPath()))) = TDirectory.GetParent
                        (System.IOUtils.TPath.GetSharedDownloadsPath()) then
                        Button.Text := RightStr(strArr[i],
                          length(strArr[i]) -
                          length(TDirectory.GetParent
                          (System.IOUtils.TPath.GetSharedDownloadsPath())))
                      else
                        Button.Text := strArr[i];
                      Button.TagString := strArr[i];
                      Button.Parent := BackupFileListVertScrollBox;
                      Button.OnClick := SelectFileInBackupFileList;
                    end;

                    LoadBackupFileAniIndicator.Visible := false;
                    LoadBackupFileAniIndicator.Enabled := false;

                  end);

              end).Start;

            Tthread.Synchronize(nil,
              procedure
              begin

                RFFPathEdit.Text := System.IOUtils.TPath.GetDownloadsPath();
                switchTab(PageControl, RestoreFromFileTabitem);

              end);
            RFFPathEdit.Text := 'C:\';
            switchTab(PageControl, RestoreFromFileTabitem);
            break;
          end;
        end;

      end).Start;
  end;
{$ENDIF}
{$IF DEFINED(MSWINDOWS) OR DEFINED(IOS)}
  openDialog := TOpenDialog.Create(frmHome);
  openDialog.Title := 'Open File';
  openDialog.InitialDir :=
  {$IFDEF IOS}System.IOUtils.TPath.GetSharedDocumentsPath{$ELSE}GetCurrentDir{$ENDIF};
  openDialog.Filter := 'Zip File|*.zip';
  openDialog.DefaultExt := 'zip';
  openDialog.FilterIndex := 1;

  if openDialog.Execute then
  begin

    frmHome.RFFPathEdit.Text := openDialog.FileName;
    switchTab(frmHome.PageControl, frmHome.HSBPassword);

  end;

  openDialog.free;

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
  with frmHome do
  begin

    tced := TCA(passwordForDecrypt.Text);

    MasterSeed := SpeckDecrypt(tced, CurrentAccount.EncryptedMasterSeed);
    if not isHex(MasterSeed) then
    begin
      popupWindow.Create(dictionary('FailedToDecrypt'));
      passwordForDecrypt.Text := '';
      exit;
    end;

    DecodeDate(Now, Y, m, d);
    FileName := CurrentAccount.name + '_' + Format('%d.%d.%d', [Y, m, d]) + '.'
      + IntToStr(DateTimeToUnix(Now));

    zipPath := System.IOUtils.TPath.Combine
      ({$IFDEF IOS}HOME_PATH{$ELSE}System.IOUtils.TPath.GetDownloadsPath
      (){$ENDIF}, FileName + '.hsb.zip');

    if FileExists(zipPath) then
      DeleteFile(zipPath);
    Zip := TEncryptedZipFile.Create('');
    Zip.Open(zipPath, TZipMode.zmWrite);

    img := StrToQRBitmap(CurrentAccount.EncryptedMasterSeed);
    ImgPath := System.IOUtils.TPath.Combine(HOME_PATH, 'QREncryptedSeed.png');
    img.SaveToFile(ImgPath);

    for it in CurrentAccount.Paths do
    begin

      ts := TStringList.Create();
      ts.LoadFromFile(it);
      tempText := ts.Text;
      ts.Text := speckEncrypt(tced, speckStrPadding(ts.Text));
      ts.SaveToFile(LeftStr(it, length(it) - 3) + 'hsb');
      ts.SaveToFile(it);
      ts.free;
      Zip.Add(it);
      ts := TStringList.Create();
      ts.LoadFromFile(it);
      ts.Text := tempText;
      ts.SaveToFile(it);
      ts.free;
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
    img.free;
    Zip.free;
    switchTab(PageControl, decryptSeedBackTabItem);
    passwordForDecrypt.Text := '';
  end;
end;

procedure SendEQR;
var
  i: Integer;
  Zip: TEncryptedZipFile;
  img: TBitmap;
  tempStr: TStream;
  ImgPath: AnsiString;
  zipPath: AnsiString;

var
  MasterSeed, tced: AnsiString;
  Y, m, d: Word;
begin
  with frmHome do
  begin
    tced := TCA(passwordForDecrypt.Text);
    MasterSeed := SpeckDecrypt(tced, CurrentAccount.EncryptedMasterSeed);
    if not isHex(MasterSeed) then
    begin
      popupWindow.Create(dictionary('FailedToDecrypt'));
      passwordForDecrypt.Text := '';
      exit;
    end;

    img := StrToQRBitmap(CurrentAccount.EncryptedMasterSeed);

    ImgPath := System.IOUtils.TPath.Combine(HOME_PATH, 'QREncryptedSeed.png');
    DecodeDate(Now, Y, m, d);
    zipPath := System.IOUtils.TPath.Combine
      ({$IFDEF IOS}HOME_PATH{$ELSE}System.IOUtils.TPath.GetDownloadsPath
      (){$ENDIF}, 'QREncryptedSeed' + Format('%d.%d.%d', [Y, m, d]) + '.' +
      IntToStr(DateTimeToUnix(Now)) + '.zip');

    img.SaveToFile(ImgPath);
    Zip := TEncryptedZipFile.Create('');
    if FileExists(zipPath) then
      DeleteFile(zipPath);

    Zip.Open(zipPath, TZipMode.zmWrite);
    Zip.Add(ImgPath);
    Zip.Close;
    shareFile(zipPath);

    DeleteFile(ImgPath);
    img.free;
    Zip.free;
    MasterSeed := '';
    tced := '';
    passwordForDecrypt.Text := '';
    userSavedSeed := true;
    refreshWalletDat();

    switchTab(PageControl, BackupTabItem);
  end;
end;

procedure restoreEQR(Sender: TObject);
var
  MasterSeed, tced: AnsiString;
  ac: Account;
  i: Integer;
begin
  with frmHome do
  begin
    tced := TCA(RestorePasswordEdit.Text);
    MasterSeed := SpeckDecrypt(tced, tempQRFindEncryptedSeed);
    if not isHex(MasterSeed) then
    begin
      popupWindow.Create(dictionary('FailedToDecrypt'));
      exit;
    end;

    if (RestoreNameEdit.Text = '') or (length(RestoreNameEdit.Text) < 3) then
    begin
      popupWindow.Create(dictionary('AccountNameTooShort'));
      exit();
    end;

    for i := 0 to length(AccountsNames) - 1 do
    begin

      if AccountsNames[i] = RestoreNameEdit.Text then
      begin
        popupWindow.Create(dictionary('AccountNameOccupied'));
        exit();
      end;

    end;

    createSelectGenerateCoinView();
    frmHome.NextButtonSGC.OnClick := frmHome.CoinListCreateFromQR;
    switchTab(PageControl, frmHome.SelectGenetareCoin);

    tced := '';
    MasterSeed := '';

  end;
end;

procedure splitWords(Sender: TObject);
var
  tempList: TStringList;
  it: AnsiString;
  Button: TButton;
  maks, i: Integer;
begin
  with frmHome do
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
      Button := TButton.Create(SeedWordsFlowLayout);
      Button.Text := it;
      Button.Height := 36;
      Button.Width := Button.Width + length(it) * 3;
      Button.Visible := true;
      Button.Parent := SeedWordsFlowLayout;
      Button.OnClick := frmHome.WordSeedClick;

    end;
    for i := 0 to SeedWordsFlowLayout.ComponentCount - 1 do
    begin

      if SeedWordsFlowLayout.Components[i] is TButton then
      begin
        if maks < (TButton(SeedWordsFlowLayout.Components[i]).Position.Y +
          TButton(SeedWordsFlowLayout.Components[i]).Height) then
          maks := ceil(TButton(SeedWordsFlowLayout.Components[i]).Position.Y +
            TButton(SeedWordsFlowLayout.Components[i]).Height);
      end;

    end;

    SeedWordsFlowLayout.Height := maks;
    ConfirmedSeedFlowLayout.Height := 1;
    tempList.free;
  end;

end;

function SweepCoinsRoutine(priv: AnsiString; isCompressed: Boolean;
coin: Integer; targetAddr: AnsiString): AnsiString;
var
  out , pub: AnsiString;
  WData: WIFAddressData;
  wd: TWalletInfo;
  tmp:integer;
begin

  priv := removeSpace(priv);
  targetAddr := removeSpace( targetAddr );

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

  wd := TWalletInfo.Create(coin, -1, -1, Bitcoin_PublicAddrToWallet(pub,
    AvailableCoin[ImportCoinID].p2pk), 'Imported');
  wd.pub := pub;
  wd.EncryptedPrivKey := out;
  wd.isCompressed := isCompressed;
  parseBalances(getDataOverHTTP(HODLER_URL + 'getBalance.php?coin=' +
    AvailableCoin[coin].name + '&address=' + wd.addr), wd);
  wd.UTXO := parseUTXO(getDataOverHTTP(HODLER_URL + 'getUTXO.php?coin=' +
    AvailableCoin[coin].name + '&address=' + wd.addr), -1);
  tmp:=CurrentCoin.coin;
  CurrentCoin.coin:=coin;

  if (targetAddr = wd.addr) or ( bitcoinCashAddressToCashAddress(wd.addr) = rightStr(targetAddr , Length(bitcoinCashAddressToCashAddress(wd.addr))) ) then
  begin
    raise Exception.Create('Use different destination address');
  end;

  if not isValidForCoin( coin , targetAddr ) then
  begin
    raise Exception.Create('Wrong Target Address');
  end;

  if wd.confirmed <= BigInteger(1700) then
  begin
    raise Exception.Create('Amount too small');
  end;



  WalletViewRelated.PrepareSendTabAndSend(wd, targetAddr, wd.confirmed-BigInteger(1700), BigInteger(1700), '', AvailableCoin[coin].name);
  CurrentCoin.coin:=tmp;
  //free wd ?
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
  with frmHome do
  begin

    tced := TCA(passwordForDecrypt.Text);
    passwordForDecrypt.Text := '';
    MasterSeed := SpeckDecrypt(tced, CurrentAccount.EncryptedMasterSeed);
    if not isHex(MasterSeed) then
    begin
      popupWindow.Create(dictionary('FailedToDecrypt'));
      exit;
    end;

    /// ///////////////////////////////////////////

    if isHex(WIFEdit.Text) and (length(WIFEdit.Text) = 64) then
    begin
      out := WIFEdit.Text;
      if HexPrivKeyCompressedRadioButton.IsChecked then
        isCompressed := true
      else if HexPrivKeyNotCompressedRadioButton.IsChecked then
        isCompressed := false
      else
        raise Exception.Create('compression not defined');

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

      wd := TWalletInfo.Create(ImportCoinID, -1, -1,
        Bitcoin_PublicAddrToWallet(pub, AvailableCoin[ImportCoinID].p2pk),
        'Imported');
      wd.pub := pub;
      wd.EncryptedPrivKey := speckEncrypt((TCA(MasterSeed)), out);
      wd.isCompressed := isCompressed;
    end
    else if ImportCoinID = 4 then
    begin
      pub := secp256k1_get_public(out , true);
      wd := TWalletInfo.Create(ImportCoinID, -1, -1,
        Ethereum_PublicAddrToWallet(pub), 'Imported');
      wd.pub := pub;
      wd.EncryptedPrivKey := speckEncrypt((TCA(MasterSeed)), out);
      wd.isCompressed := false;
    end;
    CurrentAccount.AddCoin(wd);
    CreatePanel(wd);

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
  with frmHome do
  begin
    withoutWhiteChar := StringReplace(frmHome.SeedField.Text, ' ', '',
      [rfReplaceAll]);
    withoutWhiteChar := StringReplace(withoutWhiteChar, #13, '',
      [rfReplaceAll]);
    withoutWhiteChar := StringReplace(withoutWhiteChar, #10, '',
      [rfReplaceAll]);

    if (length(withoutWhiteChar) = 64) and (isHex(frmHome.SeedField.Text)) then
    begin
      userSavedSeed := true;

      CreateNewAccountAndSave(AccountNameEdit.Text, pass.Text,
        withoutWhiteChar, true);

      withoutWhiteChar := '';
      frmHome.SeedField.Text := '';

      exit;
    end
    else
    begin
      inputWordsList := SplitString(frmHome.SeedField.Text);

      seedFromWords := fromMnemonic(inputWordsList);

      if seedFromWords = '' then
      begin
        exit;
      end;

      userSavedSeed := true;

      CreateNewAccountAndSave(AccountNameEdit.Text, pass.Text,
        seedFromWords, true);

      seedFromWords := '';
      inputWordsList.free;

      {
        Dodać obsługę błędów
      }

      exit;
    end;
  end;
end;

function PKCheckPassword(Sender: TObject): Boolean;
var
  MasterSeed, tced: AnsiString;
var
  Bitmap: TBitmap;
  tempStr: AnsiString;
{$IFDEF MSWINDOWS}lblPrivateKey: TMemo; {$ENDIF}
begin

  result := true;
  with frmHome do
  begin

    tced := TCA(passwordForDecrypt.Text);
    passwordForDecrypt.Text := '';
    MasterSeed := SpeckDecrypt(tced, CurrentAccount.EncryptedMasterSeed);
    if (CurrentCoin.X = -1) and (CurrentCoin.Y = -1) then
    begin

      tempStr := SpeckDecrypt(TCA(MasterSeed), CurrentCoin.EncryptedPrivKey);

      if not isHex(tempStr) then
      begin
        raise Exception.Create(dictionary('FailedToDecrypt'));
        exit(false);
      end;
      // {$IFDEF MSWINDOWS}lblPrivateKey:=PrivateKeyMemo;{$ENDIF}
      lblPrivateKey.Text := cutEveryNChar(4, tempStr);
      lblWIFKey.Text := PrivKeyToWIF(tempStr, CurrentCoin.isCompressed,
        AvailableCoin[TWalletInfo(CurrentCoin).coin].wifByte);
      tempStr := '';
      MasterSeed := '';

    end
    else
    begin

      if not isHex(MasterSeed) then
      begin
        raise Exception.Create(dictionary('FailedToDecrypt'));
        wipeAnsiString(MasterSeed);
        exit(false);
      end;
      // {$IFDEF MSWINDOWS}lblPrivateKey:=PrivateKeyMemo;{$ENDIF}
      lblPrivateKey.Text := priv256forhd(CurrentCoin.coin, CurrentCoin.X,
        CurrentCoin.Y, MasterSeed);
      lblWIFKey.Text := PrivKeyToWIF(lblPrivateKey.Text, CurrentCoin.coin <> 4,
        AvailableCoin[TWalletInfo(CurrentCoin).coin].wifByte);

      wipeAnsiString(MasterSeed);

    end;

    Bitmap := StrToQRBitmap(removeSpace(lblPrivateKey.Text));
    PrivKeyQRImage.Bitmap.Assign(Bitmap);
    Bitmap.free;
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
  Zip := TEncryptedZipFile.Create(password);
  Zip.Open(path, TZipMode.zmRead);
  ac := Account.Create(accname);
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
  ac.free;

  Zip.Close;
  Zip.free;
  if failure then
  begin
    RemoveDir(ac.DirPath);
    popupWindow.Create('Wrong password or damaged file');
    // frmHome.FormShow(nil);
    exit;
  end;
  ac := Account.Create(accname);
  ac.LoadFiles;
  ac.userSaveSeed := true;
  ac.SaveFiles;
  AddAccountToFile(ac);

  ac.free;

  LoadCurrentAccount(accname);
  frmHome.FormShow(nil);
end;

function isPasswordZip(path: AnsiString): Boolean;
var
  Zip: TZipFile;
  ZipHeader: TZipHeader;
  ts: TStream;
begin
  result := false;
  Zip := TZipFile.Create;
  Zip.Open(path, TZipMode.zmRead);
  ts := TStream.Create;
  Zip.Read(0, ts, ZipHeader);
  if ZipHeader.Flag and 1 = 1 then
    result := true;
  Zip.free;
  ts.free;
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
  Zip := TEncryptedZipFile.Create('');
  Zip.Open(path, TZipMode.zmRead);
  ac := Account.Create(accname);
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
      ts := TStringList.Create;
      ts.LoadFromFile(it);
      if isHex(trim(ts.Text)) then
        ts.Text := SpeckDecrypt(tced, trim(ts.Text));
      ts.SaveToFile(it);
    finally
      ts.free;
    end;
  end;
  ac.free;

  Zip.Close;
  Zip.free;
  if failure then
  begin
    popupWindow.Create('Wrong password or damaged file');
    RemoveDir(ac.DirPath);
    // frmHome.FormShow(nil);
    // showmessage('Failed to decrypt files');
    exit;
  end;
  ac := Account.Create(accname);
  try
    ac.LoadFiles;
  except
    on E: Exception do
    begin
      RemoveDir(ac.DirPath);
      popupWindow.Create('Wrong password or damaged file');
      // frmHome.FormShow(nil);
      exit;
    end;
  end;
  ac.userSaveSeed := true;
  ac.SaveFiles;
  AddAccountToFile(ac);

  ac.free;

  LoadCurrentAccount(accname);
  frmHome.FormShow(nil);
end;

procedure decryptSeedForRestore(Sender: TObject);
var
  MasterSeed, tced: AnsiString;
begin
  with frmHome do
  begin

    tced := TCA(passwordForDecrypt.Text);
    passwordForDecrypt.Text := '';
    MasterSeed := SpeckDecrypt(tced, CurrentAccount.EncryptedMasterSeed);
    if not isHex(MasterSeed) then
    begin
      popupWindow.Create(dictionary('FailedToDecrypt'));
      exit;
    end;
    switchTab(PageControl, seedGenerated);
    BackupMemo.Lines.Clear;
    BackupMemo.Lines.Add(dictionary('MasterseedMnemonic') + ':');
    BackupMemo.Lines.Add(toMnemonic(MasterSeed));
    tempMasterSeed := MasterSeed;
    MasterSeed := '';
  end;
end;

end.
