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
  FMX.TabControl, FMX.Edit,
  FMX.Clipboard, FMX.VirtualKeyBoard, JSON,
  languages,   popupwindowData,

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

procedure changeQR(Sender: TObject);
procedure scanQR(Sender: TObject);
procedure parseCamera;

procedure createQRMask(height , width : integer);

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

  if CurrentCoin = nil then
    exit;

  vPixelB := TAlphaColorRec.Black;
  vPixelW := TAlphaColorRec.white;
  QRCode := TDelphiZXingQRCode.Create();

  try

    bmp := FMX.Graphics.TBitmap.Create();

    s := {$IFDEF ANDROID}'  ' +
{$ENDIF}AvailableCoin[CurrentCoin.coin].name + ':' +
      StringReplace(frmhome.receiveAddress.Text, ' ', '', [rfReplaceAll]) +
      '?amount=' + frmhome.ReceiveValue.Text + '&message=hodler';

    if CurrentCoin.coin in [3, 7] then
      s := {$IFDEF ANDROID}'  ' +
{$ENDIF}'bitcoincash' + ':' + StringReplace(frmhome.receiveAddress.Text, ' ',
        '', [rfReplaceAll]) + '?amount=' + frmhome.ReceiveValue.Text +
        '&message=hodler';

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
        bmp.Assign(BitmapDataToScaledBitmap(QRCodeBitmap, 6));
        // bmp := ;
        // bmp.Unmap(QRCodeBitmap);
      end;
    end
    else
      showmessage('Could map data for qrcode');
  finally
    QRCode.free;
  end;

  if frmhome.QRCodeImage.Bitmap <> nil then
    frmhome.QRCodeImage.Bitmap.Assign(bmp)
  else
  begin
    frmhome.QRCodeImage.Bitmap := bmp;
    exit;
  end;

  try

    if assigned(bmp) then
      bmp.free;

  except

  end;

end;

procedure createQRMask(height , width : integer);
var
  maskBitmapData : Tbitmapdata;
  i , j: Integer;
  window : TRectF;
  dist : Integer;
begin

  dist := ceil (0.4 * Min( height , width ));

  window := RectF( (width/2) - dist , (height/2) - dist , (width/2) + dist , (height/2) + dist   );


  QRMask := TBitmap.Create;
  QRMask.SetSize( width , height );

  if QRMask.map(TMapAccess.ReadWrite ,maskBitmapData) then
  begin
    for i := 0 to height-1 do
    begin
      for j := 0 to width-1 do
      begin

        if not window.Contains( Point(j , i) ) then
          maskBitmapData.SetPixel( j , i , TAlphaColorF.Create( 0 , 0 , 0 , 0.6 ).ToAlphaColor );

      end;
    end;

    QRmask.unmap( maskBitmapData );

  end;
  frmHome.DebugQRImage.Bitmap.Assign( QRMask );

end;

procedure parseCamera;
var

  tempBitmap: TBitmap;
  ReadResult: TReadResult;

  ts: TStringList;
  ac: Account;

  QRRect: TRectF;
  QRfieldRect : TRect;
  dist : integer;

begin
  with frmhome do
  begin


    if PageControl.ActiveTab = ReadOCR then
    begin
      //CameraComponent1.SampleBufferToBitmap(imgCameraOCR.Bitmap, true);
      exit;
    end;

    if CameraComponent1.Active then
    begin
      CameraComponent1.SampleBufferToBitmap(imgCamera.Bitmap, true);
    end
    else
    begin
      switchTab( pagecontrol , cameraBackTabItem);
      exit;

    end;

    if QRMask = nil then
    begin
      createQRMask( imgCamera.Bitmap.Height , imgCamera.Bitmap.Width );
    end;

    dist := ceil (0.4 * Min( imgCamera.Bitmap.height , imgCamera.Bitmap.width ));

    QRRect := RectF( (imgCamera.Bitmap.width/2) - dist , (imgCamera.Bitmap.height/2) - dist , (imgCamera.Bitmap.width/2) + dist , (imgCamera.Bitmap.height/2) + dist   );


    QRfieldRect := Rect( Round( qrrECT.Left ) ,Round( qrrECT.tOP ) , Round( qrrECT.Right ) ,Round( qrrECT.Bottom ) ) ;

    



    //imgCamera.Bitmap.ApplyMask( QRMask.CreateMask );

    //imgCamera.Bitmap.Assign( QRMask );

    //if frmhome.DebugQRImage.Bitmap = nil then
    //  frmhome.DebugQRImage.Bitmap := TBitmap.Create();
    //frmhome.DebugQRImage.bitmap.assign(scanBitmap);
    frmhome.Layout22.BringToFront;

    ReadResult := nil;
{$IFDEF IOS} if not FScanInProgress then {$ENDIF}
      tthread.CreateAnonymousThread(

        procedure
        var
          scanBitmap: TBitmap;
        begin
          scanBitmap := TBitmap.Create();
          scanBitmap.Height := QRfieldRect.Height;
          scanBitmap.Width :=  QRfieldRect.Width;
          scanBitmap.CopyFromBitmap(imgCamera.Bitmap , QRFIELDRect , 0 , 0 );
          tthread.Synchronize( nil , procedure
          begin

          end);
          try
            FScanInProgress := true;
            try
                ReadResult := FScanManager.Scan(scanBitmap);
            except
              on E: Exception do
              begin
                //ReadResult.free;
                //scanBitmap.free;
                FScanInProgress := false;
                exit;
              end;
            end;

            tthread.Synchronize(nil,
              procedure
              var
                i, j: Integer;
                foundWallet: boolean;
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
                      if (lowercase(ts.Strings[0]) <>
                        lowercase(AvailableCoin[CurrentCoin.coin].name) ) and not ( CurrentCoin.coin in [3, 7 ,8] ) then
                      begin

                          popupWindow.Create(dictionary('QRCodeFor') + ' ' +
                            ts.Strings[0]);
                      end
                      else
                      begin

                        WVsendTO.Text := ts.Strings[1];
                        for i := 2 to ts.Count - 2 do
                        begin
                          if ts.Strings[i] = 'amount' then
                          begin
                            wvAmount.Text := ts.Strings[i + 1];
                            WVRealCurrency.Text :=
                              floatToStrF(CurrencyConverter.calculate
                              (strToFloatDef(wvAmount.Text, 0)) *
                              (CurrentCryptoCurrency.rate), ffFixed, 18, 2);
                          end;
                        end;

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

                      switchTab(PageControl, HOME_TABITEM);

                    end
                    else
                    begin
                      switchTab(PageControl, HOME_TABITEM);
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
                      RestoreNameEdit.Text := getUnusedAccountName();
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
                  else if cameraBackTabItem = AddCoinFromPrivKeyTabItem then
                  begin
                    WIFEdit.Text := ReadResult.Text;
                    switchTab(PageControl, AddCoinFromPrivKeyTabItem);
                    //exit;
                  end
                  else if cameraBackTabItem = ClaimTabItem then
                  begin
                    PrivateKeyEditSV.Text := ReadResult.Text;
                    switchTab(PageControl, ClaimTabItem);
                    //exit;
                  end
                  else if cameraBackTabItem = HOME_TABITEM then
                  begin
                    amountFromQR := '';
                    ts := parseQRCode(ReadResult.Text);
                    if ts.Count = 1 then
                    begin
                      addressFromQR := ts[0];
                      createTransactionWalletList(getCoinsIDFromAddress
                        (addressFromQR));
                      // switchTab(pageControl , WalletTransactionListTabItem);
                    end
                    else
                    begin

                      if ts[0] = 'bitcoincash' then
                      begin
                        addressFromQR := ts[1];
                        createTransactionWalletList(getCoinsIDFromAddress
                          (addressFromQR));

                      end
                      else
                      begin

                        foundWallet := false;
                        for i := 0 to frmhome.WalletList.Content.
                          ChildrenCount - 1 do
                        begin
                          if (frmhome.WalletList.Content.Children[i]
                            .TagObject is TwalletInfo) and
                            (AvailableCoin
                            [TwalletInfo(frmhome.WalletList.Content.Children[i]
                            .TagObject).coin].qrname = ts[0]) then
                          begin

                            addressFromQR := ts[1];
                            createTransactionWalletList
                              ([TwalletInfo(frmhome.WalletList.Content.Children[i]
                              .TagObject).coin]);
                            // switchTab(pageControl , WalletTransactionListTabItem);

                            { openWalletView(frmhome.WalletList.Content.
                              Children[i]);
                              switchTab(WVTabControl, WVSend);
                              WVsendTO.Text := ts.Strings[1]; }
                            for j := 2 to ts.Count - 2 do
                            begin
                              if ts.Strings[j] = 'amount' then
                                amountFromQR := ts.Strings[j + 1];
                            end;
                            foundWallet := true;
                            break;
                          end;

                        end;

                        if not foundWallet then
                        begin
                          switchTab(PageControl, HOME_TABITEM);
                          popupWindow.Create(dictionary('WalletNotDetermined'));

                        end

                      end;

                    end;

                    ts.free;
                  end
                  else if cameraBackTabItem = AddNewCoinSettings then
                  begin
                    IsPrivKeySwitch.IsChecked := true;
                    WIFEdit.Text := ReadResult.Text;
                    switchTab(PageControl, AddNewCoinSettings);
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
    with frmhome do
    begin
      try

        cameraBackTabItem := PageControl.ActiveTab;
        CameraComponent1.Active := false;
        CameraComponent1.Kind := FMX.Media.TCameraKind.BackCamera;
        CameraComponent1.Quality :=
          FMX.Media.TVideoCaptureQuality.MediumQuality;
        if QRHeight = -1 then
        begin
          QRHeight := CameraComponent1.GetCaptureSetting.Height;
          QRWidth := CameraComponent1.GetCaptureSetting.Width;
        end;

        CameraComponent1.SetCaptureSetting(TVideoCaptureSetting.Create(QRWidth,
          QRHeight, 30));
        CameraComponent1.FocusMode := FMX.Media.TFocusMode.ContinuousAutoFocus;
        CameraComponent1.Active := true;
        switchTab(PageControl, TTabItem(frmhome.FindComponent('qrreader')));

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

    tthread.CreateAnonymousThread(
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
            tthread.Synchronize(nil,
              procedure
              begin
                frmhome.btnQRClick(nil);
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
