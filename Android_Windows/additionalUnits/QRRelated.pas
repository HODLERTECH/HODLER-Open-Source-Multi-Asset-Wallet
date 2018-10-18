unit QRRelated;

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

procedure changeQR(Sender: TObject);
procedure scanQR(Sender: TObject);
procedure parseCamera;

implementation

uses uHome, misc, AccountData, base58, bech32, CurrencyConverter, SyncThr, WIF,
  Bitcoin, coinData, cryptoCurrencyData, Ethereum, secp256k1, tokenData,
  transactions, WalletStructureData, AccountRelated;

procedure changeQR(Sender: TObject);
	var
	  vPixelB: Integer;
	  vPixelW: Integer;
	  QRCode: TDelphiZXingQRCode;
	  QRCodeBitmap: TBitmapData;
	  Row: Integer;
	  bmp: FMX.Graphics.TBitmap;
	  Column: Integer;
	  j: Integer;
	  currentRow: Int64;
	  k: Int64;
	  currentCol: Int64;
	  X, Y: Integer;
	  PP: Pointer;
	  s: AnsiString;
begin
  with frmHome do begin
  if CurrentCoin=nil then exit;
  
    vPixelB := TAlphaColorRec.Black;
    vPixelW := TAlphaColorRec.white;
    QRCode := TDelphiZXingQRCode.Create();

    try

      bmp := FMX.Graphics.TBitmap.Create();

      s := {$IFDEF ANDROID}'  ' +
{$ENDIF}AvailableCoin[CurrentCoin.coin].name + ':' +
        StringReplace(receiveAddress.Text, ' ', '', [rfReplaceAll]) + '?amount='
        + ReceiveValue.Text + '&message=hodler';

      QRCode.Encoding := TQRCodeEncoding(0);
      QRCode.QuietZone := 6;
      QRCode.Data := s;
      QRCode.Data := s;
      QRCode.Data := s;
      bmp.SetSize(QRCode.Rows, QRCode.Columns);

      if bmp.Map(TMapAccess.maReadWrite, QRCodeBitmap) then
        bmp.Unmap(QRCodeBitmap);
      bmp.Canvas.Clear(TAlphaColorRec.white);
      if bmp.Map(TMapAccess.maReadWrite, QRCodeBitmap) then
      begin
        PP := QRCodeBitmap.Data;
        for Y := 0 to QRCode.Rows - 1 do
        begin
          for X := 0 to QRCode.Columns - 1 do
          begin

            if (QRCode.IsBlack[Y, X]) then
            begin
              QRCodeBitmap.SetPixel(Y, X, vPixelB);
            end
            else
            begin
              QRCodeBitmap.SetPixel(Y, X, vPixelW);
            end;

          end;
        end;

        QRCodeBitmap.Data := PP;
        if QRCodeBitmap.Data <> nil then
        begin
          bmp.free;
          bmp := BitmapDataToScaledBitmap(QRCodeBitmap, 6);
          bmp.Unmap(QRCodeBitmap);
        end;
      end
      else
        showmessage('Could map data for qrcode');
    finally
      QRCode.free;
    end;

    QRCodeImage.Bitmap := bmp;

    try
      
      if bmp <> nil then
        bmp.free;
     
    except

    end;
  end;
end;

procedure parseCamera;
var
  scanBitmap: TBitmap;
  tempBitmap: TBitmap;
  ReadResult: TReadResult;
  QRRect: TRectF;
  ts: TStringList;
  scale: double;
  ac: Account;

begin
  with frmhome do
  begin

    if PageControl.ActiveTab = ReadOCR then
    begin
      CameraComponent1.SampleBufferToBitmap(imgCameraOCR.Bitmap, true);
      exit;
    end;
    CameraComponent1.SampleBufferToBitmap(imgCamera.Bitmap, true);
    scanBitmap := TBitmap.Create();
    scanBitmap.Assign(imgCamera.Bitmap);
    ReadResult := nil;

    tthread.CreateAnonymousThread(
      procedure
      begin

      try
          FScanInProgress := true;
          try
            ReadResult := FScanManager.Scan(scanBitmap);
          except
            on E: Exception do
            begin

              exit;
            end;
          end;

          tthread.Synchronize(nil,
            procedure
            var
              i: Integer;

          var
            wd: TwalletInfo;
          begin
            if (ReadResult <> nil) then
            begin
              if cameraBackTabItem = walletView then
              begin

                ts := parseQRCode(ReadResult.Text);

                if ts.Count = 1 then
                begin
                  WVsendTO.Text := ts.Strings[0];
                end
                else
                begin
                  if ts.Strings[0] <> AvailableCoin[CurrentCoin.coin].name
                  then
                  begin
                    popupWindow.Create(dictionary('QRCodeFor') + ' ' +
                      ts.Strings[0]);
                    ts.free;
                    exit;
                  end;
                  WVsendTO.Text := ts.Strings[1];
                  for i := 2 to ts.Count - 2 do
                  begin
                    if ts.Strings[i] = 'amount' then
                      wvAmount.Text := ts.Strings[i + 1];
                  end;
                end;
                ts.free;

                switchTab(PageControl, cameraBackTabItem);
              end
              else if cameraBackTabItem = ManuallyToken then
              begin
                ContractAddress.Text := trim(ReadResult.Text);
                switchTab(PageControl, cameraBackTabItem);
              end
              else if cameraBackTabItem = checkSeed then
              begin
                if tempMasterSeed = trim(ReadResult.Text) then
                begin

                  tempMasterSeed := '';

                  userSavedSeed := true;
                  refreshWalletDat();

                  switchTab(PageControl , HOME_TABITEM);

                end
                else
                begin
                  switchTab(PageControl,HOME_TABITEM);
                end;

              end
              else if (cameraBackTabItem = RestoreOptions) or
                (cameraBackTabItem = AddAccount) then
              begin

                if QRFind = QRSearchEncryted then
                begin

                  QRFind := '';
                  tempQRFindEncryptedSeed := trim(ReadResult.Text);
                  RestoreWalletOKButton.OnClick := RestoreFromEncryptedQR;
                  decryptSeedBackTabItem := PageControl.ActiveTab;
                  PageControl.ActiveTab := RestoreWalletWithPassword;
                  RWWPBackButton.OnClick := backBtnDecryptSeed;
                  RestoreNameEdit.Text := '';
                  RestorePasswordEdit.Text := '';
                  switchTab(PageControl, RestoreWalletWithPassword);

                end;

              end
              else if cameraBackTabItem = createPassword then
              begin

                if (QRFind = QRSearchDecryted) then
                begin

                  QRFind := '';

                  CreateNewAccountAndSave(AccountNameEdit.Text, pass.Text,
                    trim(ReadResult.Text), true);

                end;

              end
              else if cameraBackTabItem = ImportPrivKeyTabItem then
              begin
                WIFEdit.Text := ReadResult.Text;
                switchTab(PageControl, ImportPrivKeyTabItem);
              end
              else if cameraBackTabItem = HOME_TABITEM then
              begin
                switchTab(PageControl, cameraBackTabItem);
              end;

              CameraComponent1.Active := false;

            end;
          end);

      finally
        ReadResult.free;
        scanBitmap.free;
        FScanInProgress := false;
      end;

    end).Start;

    end;

end;

procedure scanQR(Sender: TObject);

const
  camPerm = 'android.permission.CAMERA';
  procedure doQR;
  begin
  with frmHome do begin
    try

      cameraBackTabItem := PageControl.ActiveTab;
      CameraComponent1.Active := false;
      CameraComponent1.Kind := FMX.Media.TCameraKind.BackCamera;
      CameraComponent1.Quality := FMX.Media.TVideoCaptureQuality.MediumQuality;
      if QRHeight = -1 then
      begin
        QRHeight := CameraComponent1.GetCaptureSetting.Height;
        QRWidth := CameraComponent1.GetCaptureSetting.Width;
      end;

      CameraComponent1.SetCaptureSetting(TVideoCaptureSetting.Create(QRWidth,
        QRHeight, 30));
      CameraComponent1.FocusMode := FMX.Media.TFocusMode.ContinuousAutoFocus;
      CameraComponent1.Active := true;
      switchTab(PageControl, TTabItem(frmHome.FindComponent('qrreader')));

    except
      on E: Exception do
      begin
      end;
    end;
  end;
  end;

var
  Os: TOSVersion;

begin
{$IFDEF ANDROID}
  if Os.major < 6 then
  begin
    doQR;
    exit;
  end;

  if TAndroidHelper.Context.checkCallingOrSelfPermission
    (StringToJString(camPerm)) = -1 then
  begin
    requestForPermission(camPerm);

    Tthread.CreateAnonymousThread(
      procedure
      var
        i: Integer;
      begin
        i := 0;

        for i := 0 to 240 do
        begin
          if elevateCheckPermission(camPerm) = -1 then
          begin
            sleep(250);
          end
          else
          begin
            Tthread.Synchronize(nil,
              procedure
              begin
                frmHome.btnQRClick(nil);
              end);

            break;

          end;

        end;

      end).Start;

    exit;
  end;
{$ENDIF}
  // context
  if {$IFDEF ANDROID}TAndroidHelper.Context.checkCallingOrSelfPermission
    (StringToJString(camPerm)) = 0 {$ELSE} true {$ENDIF} then
  begin

    doQR;

  end;
end;

end.
