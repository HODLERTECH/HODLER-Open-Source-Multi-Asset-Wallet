program HODLER_Wallet_Mobile;

{$R *.dres}

uses
  FontService,
  System.StartUpCopy,
  FMX.Forms,
  FMX.Styles,
  IOUtils,
  System.SysUtils,
  FMX.Types,
  uHome in 'homeAndroid\uHome.pas' {frmHome} ,
  misc in 'additionalUnits\misc.pas',
  base58 in 'additionalUnits\base58.pas',
  secp256k1 in 'coinCode\secp256k1.pas',
  Bitcoin in 'coinCode\Bitcoin.pas',
  ZXing.OneD.Code93Reader
    in 'additionalUnits\ZXING\Lib\Classes\1D Barcodes\ZXing.OneD.Code93Reader.pas',
  ZXing.OneD.Code128Reader
    in 'additionalUnits\ZXING\Lib\Classes\1D Barcodes\ZXing.OneD.Code128Reader.pas',
  ZXing.OneD.EAN13Reader
    in 'additionalUnits\ZXING\Lib\Classes\1D Barcodes\ZXing.OneD.EAN13Reader.pas',
  ZXing.OneD.EANManufacturerOrgSupport
    in 'additionalUnits\ZXING\Lib\Classes\1D Barcodes\ZXing.OneD.EANManufacturerOrgSupport.pas',
  ZXing.OneD.ITFReader
    in 'additionalUnits\ZXING\Lib\Classes\1D Barcodes\ZXing.OneD.ITFReader.pas',
  ZXing.OneD.OneDReader
    in 'additionalUnits\ZXING\Lib\Classes\1D Barcodes\ZXing.OneD.OneDReader.pas',
  ZXing.OneD.UPCEANExtension2Support
    in 'additionalUnits\ZXING\Lib\Classes\1D Barcodes\ZXing.OneD.UPCEANExtension2Support.pas',
  ZXing.OneD.UPCEANExtension5Support
    in 'additionalUnits\ZXING\Lib\Classes\1D Barcodes\ZXing.OneD.UPCEANExtension5Support.pas',
  ZXing.OneD.UPCEANExtensionSupport
    in 'additionalUnits\ZXING\Lib\Classes\1D Barcodes\ZXing.OneD.UPCEANExtensionSupport.pas',
  ZXing.OneD.UPCEANReader
    in 'additionalUnits\ZXING\Lib\Classes\1D Barcodes\ZXing.OneD.UPCEANReader.pas',
  ZXing.QrCode.QRCodeReader
    in 'additionalUnits\ZXING\Lib\Classes\2D Barcodes\ZXing.QrCode.QRCodeReader.pas',
  ZXing.Datamatrix.DataMatrixReader
    in 'additionalUnits\ZXING\Lib\Classes\2D Barcodes\ZXing.Datamatrix.DataMatrixReader.pas',
  ZXing.QrCode.Internal.DataBlock
    in 'additionalUnits\ZXING\Lib\Classes\2D Barcodes\Decoder\ZXing.QrCode.Internal.DataBlock.pas',
  ZXing.QrCode.Internal.DataMask
    in 'additionalUnits\ZXING\Lib\Classes\2D Barcodes\Decoder\ZXing.QrCode.Internal.DataMask.pas',
  ZXing.QrCode.Internal.DecodedBitStreamParser
    in 'additionalUnits\ZXING\Lib\Classes\2D Barcodes\Decoder\ZXing.QrCode.Internal.DecodedBitStreamParser.pas',
  ZXing.QrCode.Internal.Decoder
    in 'additionalUnits\ZXING\Lib\Classes\2D Barcodes\Decoder\ZXing.QrCode.Internal.Decoder.pas',
  ZXing.QrCode.Internal.ErrorCorrectionLevel
    in 'additionalUnits\ZXING\Lib\Classes\2D Barcodes\Decoder\ZXing.QrCode.Internal.ErrorCorrectionLevel.pas',
  ZXing.QrCode.Internal.FormatInformation
    in 'additionalUnits\ZXING\Lib\Classes\2D Barcodes\Decoder\ZXing.QrCode.Internal.FormatInformation.pas',
  ZXing.QrCode.Internal.Mode
    in 'additionalUnits\ZXING\Lib\Classes\2D Barcodes\Decoder\ZXing.QrCode.Internal.Mode.pas',
  ZXing.QrCode.Internal.QRCodeDecoderMetaData
    in 'additionalUnits\ZXING\Lib\Classes\2D Barcodes\Decoder\ZXing.QrCode.Internal.QRCodeDecoderMetaData.pas',
  ZXing.QrCode.Internal.Version
    in 'additionalUnits\ZXING\Lib\Classes\2D Barcodes\Decoder\ZXing.QrCode.Internal.Version.pas',
  ZXing.Datamatrix.Internal.BitMatrixParser
    in 'additionalUnits\ZXING\Lib\Classes\2D Barcodes\Decoder\ZXing.Datamatrix.Internal.BitMatrixParser.pas',
  ZXing.Datamatrix.Internal.DataBlock
    in 'additionalUnits\ZXING\Lib\Classes\2D Barcodes\Decoder\ZXing.Datamatrix.Internal.DataBlock.pas',
  ZXing.Datamatrix.Internal.DecodedBitStreamParser
    in 'additionalUnits\ZXING\Lib\Classes\2D Barcodes\Decoder\ZXing.Datamatrix.Internal.DecodedBitStreamParser.pas',
  ZXing.Datamatrix.Internal.Decoder
    in 'additionalUnits\ZXING\Lib\Classes\2D Barcodes\Decoder\ZXing.Datamatrix.Internal.Decoder.pas',
  ZXing.Datamatrix.Internal.Version
    in 'additionalUnits\ZXING\Lib\Classes\2D Barcodes\Decoder\ZXing.Datamatrix.Internal.Version.pas',
  ZXing.QrCode.Internal.BitMatrixParser
    in 'additionalUnits\ZXING\Lib\Classes\2D Barcodes\Decoder\ZXing.QrCode.Internal.BitMatrixParser.pas',
  ZXing.QrCode.Internal.AlignmentPattern
    in 'additionalUnits\ZXING\Lib\Classes\2D Barcodes\Detector\ZXing.QrCode.Internal.AlignmentPattern.pas',
  ZXing.QrCode.Internal.AlignmentPatternFinder
    in 'additionalUnits\ZXING\Lib\Classes\2D Barcodes\Detector\ZXing.QrCode.Internal.AlignmentPatternFinder.pas',
  ZXing.QrCode.Internal.Detector
    in 'additionalUnits\ZXING\Lib\Classes\2D Barcodes\Detector\ZXing.QrCode.Internal.Detector.pas',
  ZXing.QrCode.Internal.FinderPattern
    in 'additionalUnits\ZXING\Lib\Classes\2D Barcodes\Detector\ZXing.QrCode.Internal.FinderPattern.pas',
  ZXing.QrCode.Internal.FinderPatternFinder
    in 'additionalUnits\ZXING\Lib\Classes\2D Barcodes\Detector\ZXing.QrCode.Internal.FinderPatternFinder.pas',
  ZXing.QrCode.Internal.FinderPatternInfo
    in 'additionalUnits\ZXING\Lib\Classes\2D Barcodes\Detector\ZXing.QrCode.Internal.FinderPatternInfo.pas',
  ZXing.Datamatrix.Internal.Detector
    in 'additionalUnits\ZXING\Lib\Classes\2D Barcodes\Detector\ZXing.Datamatrix.Internal.Detector.pas',
  ZXing.DecoderResult
    in 'additionalUnits\ZXING\Lib\Classes\Common\ZXing.DecoderResult.pas',
  ZXing.DefaultGridSampler
    in 'additionalUnits\ZXING\Lib\Classes\Common\ZXing.DefaultGridSampler.pas',
  ZXing.Helpers in 'additionalUnits\ZXING\Lib\Classes\Common\ZXing.Helpers.pas',
  ZXing.MultiFormatReader
    in 'additionalUnits\ZXING\Lib\Classes\Common\ZXing.MultiFormatReader.pas',
  ZXing.ResultMetadataType
    in 'additionalUnits\ZXING\Lib\Classes\Common\ZXing.ResultMetadataType.pas',
  ZXing.StringUtils
    in 'additionalUnits\ZXING\Lib\Classes\Common\ZXing.StringUtils.pas',
  ZXing.BarcodeFormat
    in 'additionalUnits\ZXING\Lib\Classes\Common\ZXing.BarcodeFormat.pas',
  ZXing.Common.BitArray
    in 'additionalUnits\ZXING\Lib\Classes\Common\ZXing.Common.BitArray.pas',
  ZXing.Common.BitMatrix
    in 'additionalUnits\ZXING\Lib\Classes\Common\ZXing.Common.BitMatrix.pas',
  ZXing.Common.DetectorResult
    in 'additionalUnits\ZXING\Lib\Classes\Common\ZXing.Common.DetectorResult.pas',
  ZXing.Common.GridSampler
    in 'additionalUnits\ZXING\Lib\Classes\Common\ZXing.Common.GridSampler.pas',
  ZXing.Common.PerspectiveTransform
    in 'additionalUnits\ZXING\Lib\Classes\Common\ZXing.Common.PerspectiveTransform.pas',
  ZXing.EncodeHintType
    in 'additionalUnits\ZXING\Lib\Classes\Common\ZXing.EncodeHintType.pas',
  ZXing.Reader in 'additionalUnits\ZXING\Lib\Classes\Common\ZXing.Reader.pas',
  ZXing.ReadResult
    in 'additionalUnits\ZXING\Lib\Classes\Common\ZXing.ReadResult.pas',
  ZXing.ResultPoint
    in 'additionalUnits\ZXING\Lib\Classes\Common\ZXing.ResultPoint.pas',
  ZXing.Common.Detector.MathUtils
    in 'additionalUnits\ZXING\Lib\Classes\Common\Detector\ZXing.Common.Detector.MathUtils.pas',
  ZXing.Common.Detector.WhiteRectangleDetector
    in 'additionalUnits\ZXING\Lib\Classes\Common\Detector\ZXing.Common.Detector.WhiteRectangleDetector.pas',
  ZXing.Common.ReedSolomon.GenericGF
    in 'additionalUnits\ZXING\Lib\Classes\Common\ReedSolomon\ZXing.Common.ReedSolomon.GenericGF.pas',
  ZXing.Common.ReedSolomon.ReedSolomonDecoder
    in 'additionalUnits\ZXING\Lib\Classes\Common\ReedSolomon\ZXing.Common.ReedSolomon.ReedSolomonDecoder.pas',
  ZXing.BitSource
    in 'additionalUnits\ZXING\Lib\Classes\Common\ZXing.BitSource.pas',
  ZXing.CharacterSetECI
    in 'additionalUnits\ZXING\Lib\Classes\Common\ZXing.CharacterSetECI.pas',
  ZXing.DecodeHintType
    in 'additionalUnits\ZXING\Lib\Classes\Common\ZXing.DecodeHintType.pas',
  ZXing.Binarizer
    in 'additionalUnits\ZXING\Lib\Classes\Filtering\ZXing.Binarizer.pas',
  ZXing.BinaryBitmap
    in 'additionalUnits\ZXING\Lib\Classes\Filtering\ZXing.BinaryBitmap.pas',
  ZXing.GlobalHistogramBinarizer
    in 'additionalUnits\ZXING\Lib\Classes\Filtering\ZXing.GlobalHistogramBinarizer.pas',
  ZXing.HybridBinarizer
    in 'additionalUnits\ZXING\Lib\Classes\Filtering\ZXing.HybridBinarizer.pas',
  ZXing.BaseLuminanceSource
    in 'additionalUnits\ZXING\Lib\Classes\Filtering\ZXing.BaseLuminanceSource.pas',
  ZXing.InvertedLuminanceSource
    in 'additionalUnits\ZXING\Lib\Classes\Filtering\ZXing.InvertedLuminanceSource.pas',
  ZXing.LuminanceSource
    in 'additionalUnits\ZXING\Lib\Classes\Filtering\ZXing.LuminanceSource.pas',
  ZXing.PlanarYUVLuminanceSource
    in 'additionalUnits\ZXING\Lib\Classes\Filtering\ZXing.PlanarYUVLuminanceSource.pas',
  ZXing.RGBLuminanceSource
    in 'additionalUnits\ZXING\Lib\Classes\Filtering\ZXing.RGBLuminanceSource.pas',
  ZXing.ScanManager
    in 'additionalUnits\ZXING\Lib\Classes\ZXing.ScanManager.pas',
  ZXing.Common.BitArrayImplementation
    in 'additionalUnits\ZXING\Lib\Classes\Common\ZXing.Common.BitArrayImplementation.pas',
  ZXing.ResultPointImplementation
    in 'additionalUnits\ZXING\Lib\Classes\Common\ZXing.ResultPointImplementation.pas',
  ZXing.QrCode.Internal.AlignmentPatternImplementation
    in 'additionalUnits\ZXING\Lib\Classes\2D Barcodes\Detector\ZXing.QrCode.Internal.AlignmentPatternImplementation.pas',
  ZXing.QrCode.Internal.FinderPatternImplementation
    in 'additionalUnits\ZXING\Lib\Classes\2D Barcodes\Detector\ZXing.QrCode.Internal.FinderPatternImplementation.pas',
  ZXing.ByteSegments
    in 'additionalUnits\ZXING\Lib\Classes\Common\ZXIng.ByteSegments.pas',
  ZXing.OneD.EAN8Reader
    in 'additionalUnits\ZXING\Lib\Classes\1D Barcodes\ZXing.OneD.EAN8Reader.pas',
  ZXing.OneD.UPCAReader
    in 'additionalUnits\ZXING\Lib\Classes\1D Barcodes\ZXing.OneD.UPCAReader.pas',
  ZXing.OneD.UPCEReader
    in 'additionalUnits\ZXING\Lib\Classes\1D Barcodes\ZXing.OneD.UPCEReader.pas',
  ZXing.OneD.Code39Reader
    in 'additionalUnits\ZXING\Lib\Classes\1D Barcodes\ZXing.OneD.Code39Reader.pas',
  DelphiZXIngQRCode in 'additionalUnits\ZXING\DelphiZXIngQRCode.pas',
  transactions in 'coinCode\transactions.pas',
  btypes in 'additionalUnits\KECCAK\btypes.pas',
  keccak_n in 'additionalUnits\KECCAK\keccak_n.pas',
  Ethereum in 'coinCode\Ethereum.pas',
  coinData in 'coinCode\coinData.pas',
  tokenData in 'coinCode\tokenData.pas',
  bech32 in 'additionalUnits\bech32.pas',
  FMX.Ani in 'FMX.Ani.pas',
  DW.ThreadedTimer in 'DW.ThreadedTimer.pas',
  cryptoCurrencyData in 'coinCode\cryptoCurrencyData.pas',
  languages in 'Languages\languages.pas',
  CurrencyConverter in 'additionalUnits\CurrencyConverter.pas',
  WIF in 'additionalUnits\WIF.pas',
  AccountData in 'additionalUnits\AccountData.pas',
  WalletStructureData in 'WalletStructureData.pas',
  SystemApp in 'SystemApp.pas',
  AccountRelated in 'additionalUnits\AccountRelated.pas',
  QRRelated in 'additionalUnits\QRRelated.pas',
  FileManagerRelated in 'additionalUnits\FileManagerRelated.pas',
  WalletViewRelated in 'additionalUnits\WalletViewRelated.pas',
  BackupRelated in 'additionalUnits\BackupRelated.pas',
  TCopyableEditData in 'components\TCopyableEditData.pas',
  TCopyableLabelData in 'components\TCopyableLabelData.pas',
  CompilerAndRTLVersions in 'additionalUnits\bi\CompilerAndRTLVersions.pas',
  Velthuis.BigDecimals in 'additionalUnits\bi\Velthuis.BigDecimals.pas',
  Velthuis.BigIntegers in 'additionalUnits\bi\Velthuis.BigIntegers.pas',
  Velthuis.BigIntegers.Primes
    in 'additionalUnits\bi\Velthuis.BigIntegers.Primes.pas',
  Velthuis.BigRationals in 'additionalUnits\bi\Velthuis.BigRationals.pas',
  Velthuis.ExactFloatStrings
    in 'additionalUnits\bi\Velthuis.ExactFloatStrings.pas',
  Velthuis.FloatUtils in 'additionalUnits\bi\Velthuis.FloatUtils.pas',
  Velthuis.Loggers in 'additionalUnits\bi\Velthuis.Loggers.pas',
  Velthuis.Numerics in 'additionalUnits\bi\Velthuis.Numerics.pas',
  Velthuis.RandomNumbers in 'additionalUnits\bi\Velthuis.RandomNumbers.pas',
  Velthuis.Sizes in 'additionalUnits\bi\Velthuis.Sizes.pas',
  Velthuis.StrConsts in 'additionalUnits\bi\Velthuis.StrConsts.pas',
  Velthuis.XorShifts in 'additionalUnits\bi\Velthuis.XorShifts.pas',
  TImageTextButtonData in 'components\TImageTextButtonData.pas',
  TRotateImageData in 'components\TRotateImageData.pas',
  debugAnalysis in 'additionalUnits\debugAnalysis.pas',
  KeypoolRelated in 'additionalUnits\KeypoolRelated.pas',
  AssetsMenagerData in 'additionalUnits\AssetsMenagerData.pas',
  CrossPlatformHeaders in 'CrossPlatformHeaders.pas',
  PopupWindowData in 'additionalUnits\PopupWindowData.pas',
  NotificationLayoutData in 'components\NotificationLayoutData.pas',
  ED25519_Blake2b in 'coinCode\ED25519_Blake2b.pas',
  Nano in 'coinCode\Nano.pas',
  TAddressLabelData in 'components\TAddressLabelData.pas',
  TCopyableAddressLabelData in 'components\TCopyableAddressLabelData.pas',
  TCopyableAddressPanelData in 'components\TCopyableAddressPanelData.pas',
  ThreadKindergartenData in 'additionalUnits\ThreadKindergartenData.pas',
  uNanoPowAS in 'NanoPoWAndroidService\uNanoPowAS.pas' {DM: TAndroidService} ,
  HistoryPanelData in 'components\HistoryPanelData.pas',
  SyncThr in 'additionalUnits\SyncThr.pas',
  ComponentPoolData in 'additionalUnits\additionalClass\ComponentPoolData.pas',
  TNewCryptoVertScrollBoxData in 'components\TNewCryptoVertScrollBoxData.pas';

{$R *.res}

var
  H: THandle;

begin

{$IF DEFINED(ANDROID) OR DEFINED(IOS)}
  Application.Initialize;

  Application.FormFactor.Orientations := [TFormOrientation.Portrait];
  Application.CreateForm(TfrmHome, frmHome);
  Application.Run;

{$ELSE}
  VKAutoShowMode := TVKAutoShowMode.Never;

  FMX.Types.GlobalUseDX := true;

  GlobalUseDXInDX9Mode := true;
  GlobalUseDXSoftware := true;
  FMX.Types.GlobalDisableFocusEffect := true;
  H := CreateMutex(nil, False, 'HODLERTECHMUTEX');
  if (H <> 0) and (GetLastError <> ERROR_ALREADY_EXISTS) then
  begin
    try
      Application.Initialize;

      AApplication.CreateForm(TDM, DM);
      pplication.FormFactor.Orientations := [TFormOrientation.Portrait];
      AApplication.CreateForm(TfrmHome, frmHome);
      pplication.Run;
    finally
      ReleaseMutex(H);
    end;
  end;
  CloseHandle(H);
{$ENDIF}

end.
