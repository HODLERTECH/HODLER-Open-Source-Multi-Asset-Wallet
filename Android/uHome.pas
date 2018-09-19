{ *****************************
  License GPL

  Initial Authors
  Daniel Mazur
  Tobiasz Horodko

  27/03/18 Alicante

  04/05/18 Delphi 10.2 IDE switch
  ***************************** }

unit uHome;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, strUtils,
  SyncThr, System.Generics.Collections, System.character,
  System.DateUtils, System.Messaging,
  System.Variants, System.IOUtils,
  FMX.Types, FMX.Graphics, FMX.Controls, FMX.Forms, FMX.Dialogs, FMX.StdCtrls,
  FMX.Controls.Presentation, FMX.Styles, System.ImageList, FMX.ImgList, FMX.Ani,
  FMX.Layouts, FMX.ExtCtrls, Velthuis.BigIntegers, FMX.ScrollBox, FMX.Memo,
  FMX.Platform, System.Threading, Math, DelphiZXingQRCode,
  FMX.TabControl, System.Sensors, System.Sensors.Components, FMX.Edit,
  FMX.Clipboard, bech32, cryptoCurrencyData, FMX.VirtualKeyBoard, JSON,
  languages, WIF, AccountData, WalletStructureData,

  FMX.Media, FMX.Objects, CurrencyConverter, uEncryptedZipFile, System.Zip // ,
  // FMX.StdActns, FMX.MediaLibrary.Actions, System.Actions, FMX.ActnList//,
  // FMX.Gestures, FOcr, FMX.EditBox, FMX.SpinBox
{$IFDEF ANDROID},
  // JavaInterfaces,
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
  misc, FMX.Menus,
  ZXing.BarcodeFormat,
  ZXing.ReadResult,
  ZXing.ScanManager, FMX.EditBox, FMX.SpinBox, FOcr, FMX.Gestures, FMX.Effects,
  FMX.Filter.Effects, System.Actions, FMX.ActnList, System.Math.Vectors,
  FMX.Controls3D, FMX.Layers3D, FMX.StdActns, FMX.MediaLibrary.Actions,
  FMX.ComboEdit;

type

  TfrmHome = class(TForm)
    PageControl: TTabControl;
    walletDatCreation: TTabItem;
    HeaderForWDC: TToolBar;
    labelHeaderForWDC: TLabel;
    PanelLoading: TPanel;
    AniIndicator1: TAniIndicator;
    gathener: TTimer;
    MotionSensor: TMotionSensor;
    OrientationSensor: TOrientationSensor;
    labelForGenerating: TLabel;
    createPassword: TTabItem;
    headerForCP: TToolBar;
    labelheaderforCP: TLabel;
    pnForEncryption: TPanel;
    swForEncryption: TSwitch;
    labelForEncyprion: TLabel;
    panelPassword: TPanel;
    PanelRetypePassword: TPanel;
    btnGenSeed: TButton;
    pass: TEdit;
    retypePass: TEdit;
    lblEnterPass: TLabel;
    lblRetypePass: TLabel;
    seedGenerated: TTabItem;
    headerForSG: TToolBar;
    labelHeaderForSG: TLabel;
    PanelSG: TPanel;
    lblSeed: TLabel;
    BackupMemo: TMemo;
    btnSeedGeneratedProceed: TButton;
    QRReader: TTabItem;
    QRHeader: TToolBar;
    lblQRHeader: TLabel;
    btnQRBack: TButton;
    CameraComponent1: TCameraComponent;
    imgCamera: TImage;
    walletView: TTabItem;
    headerforWV: TToolBar;
    WVTabControl: TTabControl;
    WVBalance: TTabItem;
    WVReceive: TTabItem;
    WVSend: TTabItem;
    lbBalance: TLabel;
    WVSettings: TTabItem;
    btnBack: TButton;
    zx_gfxStorage: TTabItem;
    gfxStorage: TScrollBox;
    gfxBitcoin: TImage;
    gfxLitecoin: TImage;
    gfxDash: TImage;
    gfxBitcoinCash: TImage;
    btnSync: TButton;
    Settings: TTabItem;
    SHeader: TToolBar;
    lblSHeader: TLabel;
    btnSBack: TButton;
    btnSWipe: TButton;
    btnSSys: TButton;
    descryptSeed: TTabItem;
    DSHeader: TToolBar;
    lblDSHeader: TLabel;
    btnDSBack: TButton;
    panelDecryptSeedPass: TPanel;
    passwordForDecrypt: TEdit;
    lbldecryptSeedPass: TLabel;
    btnDecryptSeed: TButton;
    wvGFX: TImage;
    lblSendTo: TLabel;
    WVsendTO: TEdit;
    lblAmount: TLabel;
    wvAmount: TEdit;
    lblFee: TLabel;
    wvFee: TEdit;
    btnSend: TButton;
    FeeSpin: TSpinBox;
    btnAddNewWallet: TButton;
    wvAddress: TEdit;
    btnOCR: TButton;
    FOcr1: TFOcr;
    ReadOCR: TTabItem;
    imgCameraOCR: TImage;
    OCRHeader: TToolBar;
    lblOCRHeader: TLabel;
    btnORCBack: TButton;
    btnReadOCR: TButton;
    QRChangeTimer: TTimer;
    gfxEthereum: TImage;
    btnImpSeed: TButton;
    SeedCreation: TTabItem;
    SCHeader: TToolBar;
    lblSCHeader: TLabel;
    PanelEnterSeed: TPanel;
    lblEnterSeed: TLabel;
    btnCheckSeed: TButton;
    AddNewCoin: TTabItem;
    SelectNewCoinBox: TVertScrollBox;
    ANWHeader: TToolBar;
    lblANWHeader: TLabel;
    btnANWBack: TButton;
    ImageList1: TImageList;
    TokenIcons: TImageList;
    checkSeed: TTabItem;
    btnConfirm: TButton;
    CSHeader: TToolBar;
    lblCSHeader: TLabel;
    btnCSBack: TButton;
    btnSkip: TButton;
    lblRetypeSeed: TLabel;
    btnAddNewToken: TButton;
    AddNewToken: TTabItem;
    ANTHeader: TToolBar;
    lblANTHeader: TLabel;
    btnANTBack: TButton;
    AvailableCoinsBox: TVertScrollBox;
    ExportKeyScreen: TTabItem;
    EKSHeader: TToolBar;
    lblEKSHeader: TLabel;
    btnEKSBack: TButton;
    lblPrivateKey: TLabel;
    btnExportPrivKey: TButton;
    ChoseToken: TTabItem;
    CTHeader: TToolBar;
    lblCTHeader: TLabel;
    btnCTBack: TButton;
    AvailableTokensBox: TVertScrollBox;
    btnAddManually: TButton;
    ManuallyToken: TTabItem;
    MTHeader: TToolBar;
    lblMTHeader: TLabel;
    btnMTBack: TButton;
    ContractAddressPanel: TPanel;
    ContractAddress: TEdit;
    lblContractAddress: TLabel;
    DecimalsPanel: TPanel;
    DecimalsField: TEdit;
    lblDecimals: TLabel;
    SymbolPanel: TPanel;
    SymbolField: TEdit;
    lblSymbol: TLabel;
    TokenNamePanel: TPanel;
    TokenNameField: TEdit;
    lblTokenName: TLabel;
    btnAddContract: TButton;
    btnSCBack: TButton;
    SwitchSavedSeed: TSwitch;
    WarningPanel: TPanel;
    lblWarningText: TLabel;
    ShowMsgView: TTabItem;
    MessagePanel: TPanel;
    btnSMVYes: TButton;
    btnSMVNo: TButton;
    imageSMV: TImage;
    lblMessageText: TLabel;
    panelButtonYesNo: TPanel;
    passwordMessage: TLabel;
    DecryptSeedMessage: TLabel;
    btnMTQR: TButton;
    DebugBtn: TButton;
    DebugScreen: TTabItem;
    Edit1: TEdit;
    Button2: TButton;
    Label1: TLabel;
    AddNewCoinSettings: TTabItem;
    ToolBar2: TToolBar;
    lblACHeader: TLabel;
    btnACBack: TButton;
    NewCoinDescriptionPanel: TPanel;
    NewCoinDescriptionEdit: TEdit;
    lblNewCoinDescription: TLabel;
    btnOKAddNewCoinSettings: TButton;
    Label4: TLabel;
    NewCoinDescriptionPassPanel: TPanel;
    NewCoinDescriptionPassEdit: TEdit;
    lblNewCoinDescriptionPass: TLabel;
    btnChangeDescription: TButton;
    ChangeDescryptionScreen: TTabItem;
    ChangeDescryptionHeader: TToolBar;
    lblChangeDescryptionHeader: TLabel;
    btnChangeDescryptionBack: TButton;
    ChangeDescryptionPanel: TPanel;
    ChangeDescryptionEdit: TEdit;
    lblChangeDescryption: TLabel;
    btnChangeDescryptionOK: TButton;
    Panel4: TPanel;
    Label9: TLabel;
    BalancePanel: TPanel;
    lblFiat: TLabel;
    Edit4: TEdit;
    lbBalanceLong: TLabel;
    GestureManager1: TGestureManager;
    ActionList: TActionList;
    tabAnim: TChangeTabAction;
    ShortcutValetInfoPanel: TPanel;
    btnAddressQR: TButton;
    ShortcutValetInfoImage: TImage;
    TopInfoConfirmed: TLabel;
    topInfoUnconfirmed: TLabel;
    WVRealCurrency: TEdit;
    AutomaticFeeRadio: TRadioButton;
    FixedFeeRadio: TRadioButton;
    SendAllFundsSwitch: TSwitch;
    FeeFromAmountSwitch: TSwitch;
    lblSendAllFunds: TLabel;
    lblFromFee: TLabel;
    SendVertScrollBox: TVertScrollBox;
    StyleBook1: TStyleBook;
    SendAmountLayout: TLayout;
    Layout3: TLayout;
    TransactionFeeLayout: TLayout;
    SendToLayout: TLayout;
    AutomaticFeeLayout: TLayout;
    FixedFeeLayout: TLayout;
    AddressQRLayout: TLayout;
    SendAllFundsLayout: TLayout;
    FeeFromAmountLayout: TLayout;
    lblCoinFiat: TLabel;
    lblCoinShort: TLabel;
    SwitchSendAllFundsLayout: TLayout;
    SendSettingsFlowLayout: TFlowLayout;
    SwitchFromFeeLayout: TLayout;
    IconLayout: TLayout;
    BalanceTextLayout: TLayout;
    TopInfoConfirmedValue: TLabel;
    ShortcutValetInfoValueLayout: TLayout;
    TopInfoUnconfirmedValue: TLabel;
    syncTimer: TTimer;
    lblBlockInfo: TLabel;
    wordlist: TMemo;
    SeedField: TMemo;
    SeedWordsBox: TVertScrollBox;
    Memo1: TMemo;
    ReceiveValue: TEdit;
    ReceiveVertScrollBox: TVertScrollBox;
    QRCodeImage: TImage;
    ArtificialSpace: TLayout;
    lblReceiveAmount: TLabel;
    SeedWordsFlowLayout: TFlowLayout;
    WarningImage: TImage;
    ErrorImage: TImage;
    OKImage: TImage;
    InfoImage: TImage;
    ReceiveAmountLayout: TLayout;
    ReceiveAmountRealCurrency: TEdit;
    lblReceiveCoinShort: TLabel;
    lblReceiveRealCurrency: TLabel;
    LongBalancePanel: TPanel;
    Button8: TButton;
    sendImage: TImage;
    receiveImage: TImage;
    txHistory: TVertScrollBox;
    Layout1: TLayout;
    receiveAddress: TEdit;
    GenerateSeedProgressBar: TProgressBar;
    NewCoinButton: TButton;
    NewTokenButton: TButton;
    NewCryptoLayout: TLayout;
    ColorAnimation1: TColorAnimation;
    Layout4: TLayout;
    RefreshWalletView: TButton;
    Layout5: TLayout;
    lblFeeHeader: TLabel;
    Panel1: TPanel;
    RefreshWalletViewTimer: TTimer;
    DebugRefreshTime: TLabel;
    btnWVShare: TButton;
    ShowShareSheetAction1: TShowShareSheetAction;
    KeyBoardLayout: TLayout;
    btnImageList: TImageList;
    WelcomeTabItem: TTabItem;
    Image1: TImage;
    Layout6: TLayout;
    btnRestoreWallet: TButton;
    lblWelcome: TLabel;
    lblWelcomeDescription: TLabel;
    Layout7: TLayout;
    Image2: TImage;
    Layout8: TLayout;
    Layout9: TLayout;
    Layout10: TLayout;
    Image3: TImage;
    Image4: TImage;
    Layout11: TLayout;
    lblThanks: TLabel;
    lblSetPassword: TLabel;
    btnCreateWallet: TButton;
    btnCreateNewWallet: TButton;
    Layout12: TLayout;
    DashBrdProgressBar: TProgressBar;
    RefreshProgressBar: TProgressBar;
    ConfirmedSeedVertScrollBox: TVertScrollBox;
    ConfirmedSeedFlowLayout: TFlowLayout;
    SearchEdit: TEdit;
    SearchInDashBrdButton: TSpeedButton;
    SearchLayout: TLayout;
    showHideIcons: TImageList;
    FloatAnimation1: TFloatAnimation;
    RectAnimation1: TRectAnimation;
    OrganizeList: TVertScrollBox;
    BackToBalanceViewButton: TButton;
    OrganizeButton: TButton;
    WalletList: TVertScrollBox;
    ShowHideAdvancedButton: TButton;
    ImageList2: TImageList;
    arrowImg: TImage;
    arrowList: TImageList;
    Layout2: TLayout;
    Panel2: TPanel;
    LanguageBox: TPopupBox;
    Panel3: TPanel;
    CurrencyBox: TPopupBox;
    HistoryDetails: TTabItem;
    ToolBar1: TToolBar;
    Label2: TLabel;
    TransactionDetailsBackButton: TButton;
    HistoryTransactionVertScrollBox: TVertScrollBox;
    HistoryTransactionSendReceive: TLabel;
    HistoryTransactionValue: TLabel;
    Label6: TLabel;
    historyTransactionConfirmation: TLabel;
    Label8: TLabel;
    HistoryTransactionDate: TLabel;
    Layout16: TLayout;
    Label11: TLabel;
    HistoryTransactionID: TLabel;
    Layout17: TLayout;
    Layout18: TLayout;
    Layout19: TLayout;
    Layout20: TLayout;
    Layout21: TLayout;
    Label3: TLabel;
    DebugSaveSeedButton: TButton;
    RestoreOptions: TTabItem;
    Layout13: TLayout;
    Layout14: TLayout;
    Image5: TImage;
    Image6: TImage;
    Layout15: TLayout;
    ResotreWalletHeaderLabel: TLabel;
    BackupTabItem: TTabItem;
    ToolBar3: TToolBar;
    BackupHeaderLabel: TLabel;
    BackupBackButton: TButton;
    SendEncryptedSeedButton: TButton;
    SendWalletFileButton: TButton;
    SeedMnemonicBackupButton: TButton;
    CreateBackupButton: TButton;
    RestoreFromFileButton: TButton;
    fileManager: TTabItem;
    SelectFilePath: TButton;
    FilesManagerScrollBox: TVertScrollBox;
    FileManagerPathLabel: TLabel;
    Layout22: TLayout;
    FileManagerPathUpButton: TButton;
    RestoreFromFileTabitem: TTabItem;
    RestoreFromFileConfirmButton: TButton;
    RFFHeader: TToolBar;
    RFFHeaderLabel: TLabel;
    btnRFFBack: TButton;
    RFFSelectFileButton: TButton;
    RFFPassword: TEdit;
    RFFPasswordInfo: TLabel;
    Layout24: TLayout;
    DirectoryImage: TImage;
    HSBIcon: TImage;
    RestoreDecryptedSeedQRButton: TButton;
    SendDecryptedSeedButton: TButton;
    RestoreFromStringSeedButton: TButton;
    RestoreSeedEncryptedQRButton: TButton;
    LinkLayout: TLayout;
    linkLabel: TLabel;
    Layout25: TLayout;
    MnemonicSeedDescriptionLabel: TLabel;
    Layout26: TLayout;
    HSBDescriptionLabel: TLabel;
    Layout27: TLayout;
    EncryptedQRDescriptionLabel: TLabel;
    Layout28: TLayout;
    DecryptedQRDescriptionLabel: TLabel;
    VertScrollBox1: TVertScrollBox;
    Button3: TButton;
    SettingsLanguageLabel: TLabel;
    SettingsCurrencyLabel: TLabel;
    ImportCoinomiSeedButton: TButton;
    ImportExodusSeedButton: TButton;
    ImportLadgerNanoSSeedButton: TButton;
    RestoreOtherOpiotnsButton: TButton;
    VertScrollBox2: TVertScrollBox;
    restoreOptionsLayout: TLayout;
    Layout30: TLayout;
    OtherOptionsImage: TImage;
    Layout29: TLayout;
    WelcomeTabLanguageBox: TPopupBox;
    Label5: TLabel;
    switchLegacyp2pkhButton: TButton;
    switchCompatiblep2shButton: TButton;
    SwitchSegwitp2wpkhButton: TButton;
    AddressTypelayout: TLayout;
    Layout32: TLayout;
    Layout33: TLayout;
    WaitWalletGenerate: TTabItem;
    WaitForGenerationProgressBar: TProgressBar;
    WaitForGenerationLabel: TLabel;
    Panel5: TPanel;
    BCHAddressesLayout: TLayout;
    BCHLegacyButton: TButton;
    BCHCashAddrButton: TButton;
    ImportPrivKeyTabItem: TTabItem;
    SaveNewPrivateKeyButton: TButton;
    IPKBack: TButton;
    ToolBar4: TToolBar;
    Label7: TLabel;
    IPKQRButton: TButton;
    AddNewAccountButton: TButton;
    AddAccount: TTabItem;
    ToolBar5: TToolBar;
    AAccHeaderLabel: TLabel;
    AAccBackButton: TButton;
    ConfirmNewAccountButton: TButton;
    Action1: TAction;
    AccountNamePanel: TPanel;
    AccountNameEdit: TEdit;
    AccountNameLabel: TLabel;
    RestoreWalletWithPassword: TTabItem;
    RestoreWalletOKButton: TButton;
    Panel6: TPanel;
    RestoreNameEdit: TEdit;
    RestoreWalletNameLabel: TLabel;
    Panel7: TPanel;
    RestorePasswordEdit: TEdit;
    Label13: TLabel;
    ToolBar6: TToolBar;
    Label14: TLabel;
    RWWPBackButton: TButton;
    Button1: TButton;
    Button4: TButton;
    Button5: TButton;
    Button6: TButton;
    Layout35: TLayout;
    Button7: TButton;
    Button9: TButton;
    Button10: TButton;
    ImportPrivKeyCoinList: TTabItem;
    IPKCLHeader: TToolBar;
    ImportPrivCoinListHeaderLabel: TLabel;
    IPKCLBackButton: TButton;
    ImportPrivKeyCoinListVertScrollBox: TVertScrollBox;
    AccountsListPanel: TPanel;
    ChangeAccountButton: TButton;
    AccountsListVertScrollBox: TVertScrollBox;
    RestoreFromFileAccountNameEdit: TEdit;
    RestoreFromFileAccountNameLabel: TLabel;
    BackupFileListVertScrollBox: TVertScrollBox;
    LoadBackupFileAniIndicator: TAniIndicator;
    HSBPassword: TTabItem;
    RFFPathEdit: TLabel;
    ToolBar7: TToolBar;
    Label12: TLabel;
    Button11: TButton;
    Image7: TImage;
    Layout23: TLayout;
    Layout36: TLayout;
    SystemTimer: TTimer;
    updateBtn: TButton;
    SearchTokenButton: TButton;
    FindERC20autoButton: TButton;
    ScrollBox: TVertScrollBox;
    ScrollKeeper: TTimer;
    TCAInfoPanel: TCalloutPanel;
    Label15: TLabel;
    TransactionWaitForSend: TTabItem;
    TransactionWaitForSendAniIndicator: TAniIndicator;
    Panel13: TPanel;
    TransactionWaitForSendDetailsLabel: TLabel;
    TransactionWaitForSendLinkLabel: TLabel;
    TransactionWaitForSendBackButton: TButton;
    ConfirmSendTabItem: TTabItem;
    SendTransactionButton: TButton;
    Label16: TLabel;
    ToolBar8: TToolBar;
    ConfirmSendHeaderLabel: TLabel;
    CSBackButton: TButton;
    Panel10: TPanel;
    ConfirmSendPasswordEdit: TEdit;
    Label17: TLabel;
    Panel12: TPanel;
    Layout38: TLayout;
    Layout39: TLayout;
    Layout40: TLayout;
    SendFromLabel: TLabel;
    SendFromStaticLabel: TLabel;
    Layout41: TLayout;
    Layout42: TLayout;
    Layout43: TLayout;
    SendFeeLabel: TLabel;
    SendFeeStaticLabel: TLabel;
    Layout44: TLayout;
    Layout45: TLayout;
    Layout46: TLayout;
    SendValueLabel: TLabel;
    SendValueStaticLabel: TLabel;
    Layout47: TLayout;
    Layout48: TLayout;
    Layout49: TLayout;
    SendToLabel: TLabel;
    SendToStaticLabel: TLabel;
    SendDetailsLabel: TLabel;
    Layout53: TLayout;
    Layout54: TLayout;
    Layout55: TLayout;
    WaitTimeLabel: TLabel;
    DeleteAccountLayout: TLayout;
    DeleteAccountButton: TButton;
    OrganizeDragInfoLabel: TLabel;
    PopupBox1: TPopupBox;
    BackToBalanceViewLayout: TLayout;
    BackWithoutSavingButton: TButton;
    CopyPrivateKeyButton: TButton;
    Layout56: TLayout;
    PrivKeyQRImage: TImage;
    Panel11: TPanel;
    Layout50: TLayout;
    Switch1: TSwitch;
    ImportPrivKeyStaticLabel: TLabel;
    Layout52: TLayout;
    PrivateKeySettingsLayout: TLayout;
    Layout31: TLayout;
    Label10: TLabel;
    Layout34: TLayout;
    HexPrivKeyDefaultRadioButton: TRadioButton;
    HexPrivKeyCompressedRadioButton: TRadioButton;
    HexPrivKeyNotCompressedRadioButton: TRadioButton;
    Layout51: TLayout;
    ImportPrivKeyLabel: TLabel;
    WIFEdit: TEdit;
    LoadingKeyDataAniIndicator: TAniIndicator;
    ImportPrivateKeyButton: TButton;
    StatusBarFixer: TRectangle;

    procedure btnOptionsClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure btnQRClick(Sender: TObject);
    procedure ImageControl4Click(Sender: TObject);
    procedure gathenerTimer(Sender: TObject);
    procedure FormMouseMove(Sender: TObject; Shift: TShiftState; X, Y: Single);
    procedure FormShow(Sender: TObject);
    procedure btnGenSeedClick(Sender: TObject);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
    procedure FormResize(Sender: TObject);
    procedure btnSeedGeneratedProceedClick(Sender: TObject);
    procedure btnQRBackClick(Sender: TObject);
    procedure CameraComponent1SampleBufferReady(Sender: TObject;
      const ATime: TMediaTime);
    procedure btnWVSettingsClick(Sender: TObject);
    procedure btnBackClick(Sender: TObject);
    procedure btnSWipeClick(Sender: TObject);
    procedure btnSSysClick(Sender: TObject);
    procedure btnSyncClick(Sender: TObject);
    procedure btnSendClick(Sender: TObject);
    procedure btnOCRClick(Sender: TObject);
    procedure btnReadOCRClick(Sender: TObject);
    procedure QRChangeTimerTimer(Sender: TObject);
    procedure btnImpSeedClick(Sender: TObject);
    procedure btnCheckSeedClick(Sender: TObject);
    procedure btnAddNewCoinClick(Sender: TObject);
    procedure btnANWBackClick(Sender: TObject);
    procedure btnCSBackClick(Sender: TObject);
    procedure btnConfirmClick(Sender: TObject);
    procedure btnSkipClick(Sender: TObject);
    procedure btnExportPrivKeyClick(Sender: TObject);
    procedure btnANTBackClick(Sender: TObject);
    procedure btnAddNewTokenClick(Sender: TObject);
    procedure btnEKSBackClick(Sender: TObject);
    procedure btnCTBackClick(Sender: TObject);
    procedure btnMTBackClick(Sender: TObject);
    procedure btnAddManuallyClick(Sender: TObject);
    procedure btnAddContractClick(Sender: TObject);
    procedure btnSCBackClick(Sender: TObject);
    procedure SwitchSavedSeedSwitch(Sender: TObject);
    procedure btnSMVCancelClick(Sender: TObject);
    procedure btnSMVNoClick(Sender: TObject);
    procedure btnSMVYesClick(Sender: TObject);
    procedure btnSBackClick(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure DebugBtnClick(Sender: TObject);
    procedure btnACBackClick(Sender: TObject);
    procedure btnOKAddNewCoinSettingsClick(Sender: TObject);
    procedure btnChangeDescriptionClick(Sender: TObject);
    procedure btnChangeDescryptionOKClick(Sender: TObject);

    procedure tabAnimUpdate(Sender: TObject);
    procedure FeeSpinChange(Sender: TObject);
    procedure SwitchVWPrecision(Sender: TObject);
    // procedure saveSenderTextToClipboard(Sender: TObject);
    procedure changeFeeWay(Sender: TObject);
    procedure USDtoCoin(Sender: TObject);
    procedure CoinToUSD(Sender: TObject);
    procedure SendAllFundsOnSwitch(Sender: TObject);
    procedure FeeToUSDUpdate(Sender: TObject);
    procedure syncTimerTimer(Sender: TObject);
    procedure CopyToClipboard(Sender: TObject;
      const EventInfo: TGestureEventInfo; var Handled: Boolean);
    procedure wvAmountChange(Sender: TObject);
    procedure wvAmountTyping(Sender: TObject);
    procedure ReceiveReatToCoin(Sender: TObject);
    procedure changeAddressUniversal(Sender: TObject);
    procedure changeAddressBech32(Sender: TObject);
    procedure Button8Click(Sender: TObject);
    procedure btnRestoreWalletClick(Sender: TObject);
    procedure DebugScreenClick(Sender: TObject);
    procedure Image1Click(Sender: TObject);
    procedure WVRealCurrencyClick(Sender: TObject);
    procedure WVRealCurrencyExit(Sender: TObject);
    procedure wvAmountExit(Sender: TObject);
    procedure wvAmountClick(Sender: TObject);
    procedure ReceiveValueClick(Sender: TObject);
    procedure ReceiveAmountRealCurrencyClick(Sender: TObject);
    procedure ReceiveAmountRealCurrencyExit(Sender: TObject);
    procedure ShowShareSheetAction1BeforeExecute(Sender: TObject);
    procedure FormVirtualKeyboardShown(Sender: TObject;
      KeyboardVisible: Boolean; const Bounds: TRect);
    procedure FormVirtualKeyboardHidden(Sender: TObject;
      KeyboardVisible: Boolean; const Bounds: TRect);
    procedure closeVirtualKeyBoard(Sender: TObject);
    procedure WVsendTOKeyUp(Sender: TObject; var Key: Word; var KeyChar: Char;
      Shift: TShiftState);
    procedure RefreshKeyBoard(Sender: TObject);
    procedure btnCreateNewWalletClick(Sender: TObject);
    procedure btnCreateWalletClick(Sender: TObject);
    procedure FormKeyUp(Sender: TObject; var Key: Word; var KeyChar: Char;
      Shift: TShiftState);
    procedure OnCloseDialog(Sender: TObject; const AResult: TModalResult);
    procedure ShowHideAdvancedButtonClick(Sender: TObject);
    procedure WVsendTOPaint(Sender: TObject; Canvas: TCanvas;
      const ARect: TRectF);
    procedure WVSendClick(Sender: TObject);
    procedure SearchInDashBrdButtonClick(Sender: TObject);
    procedure SearchEditChangeTracking(Sender: TObject);
    procedure SearchEditChange(Sender: TObject);
    procedure SearchEditExit(Sender: TObject);
    procedure WVRealCurrencyChange(Sender: TObject);
    procedure ReceiveValueChange(Sender: TObject);
    procedure ReceiveAmountRealCurrencyChange(Sender: TObject);
    procedure Panel1DragOver(Sender: TObject; const Data: TDragObject;
      const Point: TPointF; var Operation: TDragOperation);
    procedure Panel1Click(Sender: TObject);
    procedure SwitchViewToOrganize(Sender: TObject;
      const EventInfo: TGestureEventInfo; var Handled: Boolean);
    procedure BackToBalanceViewButtonClick(Sender: TObject);
    procedure PanelDragDrop(Sender: TObject; const Data: TDragObject;
      const Point: TPointF);
    procedure Panel1DragDrop(Sender: TObject; const Data: TDragObject;
      const Point: TPointF);
    procedure OrganizeListMouseMove(Sender: TObject; Shift: TShiftState;
      X, Y: Single);
    procedure OrganizeButtonClick(Sender: TObject);
    procedure OrganizeListMouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Single);
    procedure LanguageBoxChange(Sender: TObject);
    procedure CurrencyBoxChange(Sender: TObject);
    procedure SendEncryptedSeed(Sender: TObject);
    procedure DebugSaveSeedButtonClick(Sender: TObject);
    procedure RestoreFromStringSeedButtonClick(Sender: TObject);
    procedure RestoreDecryptedSeedQRButtonClick(Sender: TObject);
    procedure btnDecryptedQRClick(Sender: TObject);
    procedure SendDecryptedSeed { ButtonClick } (Sender: TObject);
    procedure SendWalletFile(Sender: TObject);
    procedure CreateBackupButtonClick(Sender: TObject);
    procedure SeedMnemonicBackupButtonClick(Sender: TObject);
    procedure SendWalletFileButtonClick(Sender: TObject);
    procedure SendEncryptedSeedButtonClick(Sender: TObject);
    procedure RestoreSeedEncryptedQRButtonClick(Sender: TObject);
    // procedure RestoreFromFileButtonClick(Sender: TObject);
    procedure ShowFileManager(Sender: TObject); overload;

    procedure FileManagerSelectClick(Sender: TObject);
    procedure FileManagerPathUpButtonClick(Sender: TObject);
    procedure btnRFFBackClick(Sender: TObject);
    procedure RestoreFromFileButtonClick(Sender: TObject);
    procedure RestoreFromFileConfirmButtonClick(Sender: TObject);

    procedure RestoreFromEncryptedQR(Sender: TObject);
    procedure SendDecryptedSeedButtonClick(Sender: TObject);
    procedure LinkLayoutClick(Sender: TObject);
    procedure Button3Click(Sender: TObject);
    procedure RestoreOtherOpiotnsButtonClick(Sender: TObject);
    procedure switchLegacyp2pkhButtonClick(Sender: TObject);
    procedure switchCompatiblep2shButtonClick(Sender: TObject);
    procedure SwitchSegwitp2wpkhButtonClick(Sender: TObject);
    procedure receiveAddressChange(Sender: TObject);
    procedure BCHLegacyButtonClick(Sender: TObject);
    procedure BCHCashAddrButtonClick(Sender: TObject);
    procedure IPKBackClick(Sender: TObject);
    procedure ImportPrivateKey(Sender: TObject);
    procedure ImportPrivateKeyButtonClick(Sender: TObject);
    //procedure SaveNewPrivateKeyButtonClick(Sender: TObject);
    procedure ConfirmNewAccountButtonClick(Sender: TObject);
    // procedure AccountsNamesPopupBoxChange(Sender: TObject);
    procedure AddNewAccountButtonClick(Sender: TObject);
    // procedure HexPrivKeyCompressedCheckBoxChange(Sender: TObject);
    // procedure HexPrivKeyNotCompressedCheckBoxChange(Sender: TObject);

    procedure WVsendTOExit(Sender: TObject);
    procedure IPKCLBackButtonClick(Sender: TObject);
    procedure ChangeAccountButtonClick(Sender: TObject);
    procedure Button11Click(Sender: TObject);
    procedure SystemTimerTimer(Sender: TObject);
    procedure updateBtnClick(Sender: TObject);
    procedure SearchTokenButtonClick(Sender: TObject);
    procedure FindERC20autoButtonClick(Sender: TObject);
    procedure FormGesture(Sender: TObject; const EventInfo: TGestureEventInfo;
      var Handled: Boolean);
    procedure ScrollKeeperTimer(Sender: TObject);
    procedure removeAccount(Sender: TObject);
    procedure DeleteAccountButtonClick(Sender: TObject);
    procedure closeOrganizeView(Sender: TObject);
    procedure PopupBox1Change(Sender: TObject);
    procedure BackupBackButtonClick(Sender: TObject);
    procedure TransactionWaitForSendBackButtonClick(Sender: TObject);
    procedure TransactionWaitForSendLinkLabelClick(Sender: TObject);
    procedure CopyPrivateKeyButtonClick(Sender: TObject);
    procedure CSBackButtonClick(Sender: TObject);
    procedure SendTransactionButtonClick(Sender: TObject);
    procedure APICheckCompressed(Sender: TObject);
    procedure switch1Switch(Sender: TObject);

  private
    { Private declarations }
    FScanManager: TScanManager;
    FScanInProgress: Boolean;
    FFrameTake: Integer;
    procedure GetImage();

    // const ScanRequestCode = 0;
    // var FMessageSubscriptionID: Integer;

    // procedure HandleActivityMessage(const Sender: TObject; const M: TMessage);
    // function OnActivityResult(RequestCode, ResultCode: Integer; Data: JIntent): Boolean;

  public
    { Public declarations }
{$IFDEF ANDROID}
    procedure RegisterDelphiNativeMethods();
{$ENDIF}
    procedure OpenWalletView(Sender: TObject; const Point: TPointF); overload;
    procedure OpenWalletView(Sender: TObject); overload;

    // procedure switchView(Sender: TObject; const Point: TPointF); overload;
    // procedure switchView(Sender: TObject); overload;

    // procedure WVTokenChoseInWallet(Sender: TObject;
    // const Point: TPointF); overload;
    // procedure WVTokenChoseInWallet(Sender: TObject); overload;

    procedure ShowHistoryDetails(Sender: TObject;
      const Point: TPointF); overload;
    procedure ShowHistoryDetails(Sender: TObject); overload;

    procedure DirectoryPanelClick(Sender: TObject;
      const Point: TPointF); overload;
    procedure DirectoryPanelClick(Sender: TObject); overload;

    procedure FilePanelClick(Sender: TObject; const Point: TPointF); overload;
    procedure FilePanelClick(Sender: TObject); overload;

    procedure PanelDragStart(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Single); overload;
    procedure PanelDragStart(Sender: TObject; const Point: TPointF); overload;
    procedure PanelDragStart(Sender: TObject;
      const EventInfo: TGestureEventInfo; var Handled: Boolean); overload;

    procedure ShowFileManager(Sender: TObject; onSelect: TProc); overload;

    procedure TrySendTX(Sender: TObject);
    // procedure decriptOKforNewWallet(Sender: TObject);
    procedure addNewWalletPanelClick(Sender: TObject);
    procedure privateKeyPasswordCheck(Sender: TObject);
    procedure addToken(Sender: TObject);
    procedure choseTokenClick(Sender: TObject);
    procedure backBtnDecryptSeed(Sender: TObject);

    procedure WordSeedClick(Sender: TObject);
    procedure decryptSeedForSeedRestore(Sender: TObject);
    procedure hideWallet(Sender: TObject);
    procedure importPrivCoinListPanelClick(Sender: TObject);
    procedure LoadAccountPanelClick(Sender: TObject);
    procedure SelectFileInBackupFileList(Sender: TObject);

  var
    shown: Boolean;
    isTokenTransfer: Boolean;
    MovingPanel: TPanel;
    ToMove: TPanel;
    Grab: Boolean;
    procCreateWallet: procedure(Sender: TObject) of Object;
    dictionary: TObjectDictionary<AnsiString, WideString>;
    onFileManagerSelectClick: TProc;

  end;

procedure requestForPermission(permName: AnsiString);
procedure switchTab(TabControl: TTabControl; TabItem: TTabItem);
procedure LoadCurrentAccount(name: AnsiString);

const
  SYSTEM_APP: Boolean = {$IFDEF ANDROID}false{$ELSE}false{$ENDIF};
  // Load OS.xml as manifest and place app in /system/priv-app

var
  frmHome: TfrmHome;
  trngBuffer: AnsiString;
  trngBufferCounter: Integer;
  stylo: TStyleManager;
  QRCodeBitmap: TBitmap;
  newcoinID: nativeint;
  walletAddressForNewToken: AnsiString;
  tempMasterSeed: AnsiString;
  decryptSeedBackTabItem: TTabItem;
  cameraBackTabItem: TTabItem;
  dashboardDecimalsPrecision: Integer = 6;
  dashBoardFontSize: Integer = 18;
  flagWVPrecision: Boolean = true;
  CurrentCryptoCurrency: CryptoCurrency;
  CurrentCoin: TwalletInfo;
  duringSync: Boolean = false;
  duringHistorySync: Boolean = false;
  QRWidth: Integer = -1;
  QRHeight: Integer = -1;
  SyncBalanceThr: SynchronizeBalanceThread;
  SyncHistoryThr: SynchronizeHistoryThread;
  CurrencyConverter: tCurrencyConverter;
  QRFind: AnsiString;
  tempQRFindEncryptedSeed: AnsiString;

  AccountsNames: array of AnsiString;
  lastClosedAccount: AnsiString;
  CurrentAccount: Account;

  ImportCoinID: Integer;

  // tempPassword : AnsiString;
resourcestring
  QRSearchEncryted = 'QRSearchEncryted';
  QRSearchDecryted = 'QRSearchDecryted';

implementation

uses ECCObj, Bitcoin, Ethereum, secp256k1, uSeedCreation, coindata, base58,
  TokenData;
{$R *.fmx}
{$R *.SmXhdpiPh.fmx ANDROID}
{$R *.iPhone55in.fmx IOS}
{$R *.LgXhdpiPh.fmx ANDROID}
{$R *.Windows.fmx MSWINDOWS}
{$R *.Surface.fmx MSWINDOWS}

procedure TfrmHome.removeAccount(Sender: TObject);
begin
  if Sender is TButton then
  begin
    popupWindowYesNo.Create(
      procedure
      begin

        tthread.CreateAnonymousThread(
          procedure
          begin

            tthread.Synchronize(nil,
              procedure
              var
                i: Integer;
              begin

                DeleteAccount(TButton(Sender).TagString);

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

procedure TfrmHome.QRChangeTimerTimer(Sender: TObject);
  procedure qrFix;
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
      // if ms <> nil then
      // ms.Free;
      if bmp <> nil then
        bmp.free;
      // if bmp2 <> nil then
      // bmp2.Free;
    except

    end;
  end;

begin

  if ReceiveValue.IsFocused then
  begin
    if ReceiveValue.Text = '' then
    begin
      ReceiveAmountRealCurrency.Text := '0.00';
    end
    else
    begin
      ReceiveAmountRealCurrency.Text :=
        floatToStrF((strToFloat(ReceiveValue.Text) * CurrencyConverter.calculate
        (CurrentCryptoCurrency.rate)), ffFixed, 18, 2);
    end;

  end;
  qrFix;
end;

procedure TfrmHome.importPrivCoinListPanelClick(Sender: TObject);
begin
  ImportCoinID := TfmxObject(Sender).Tag;

  switchTab(PageControl, ImportPrivKeyTabItem);
end;

/// ////////////////////////////////FILE MANAGER///////////////////////////////////////
procedure DrawDirectoriesAndFiles(Inputpath: AnsiString);
var
  fmxObj: TfmxObject;
  Panel: TPanel;
  lbl: TLabel;
  path: AnsiString;
  IconIMG: TImage;
  Dir, Files: TStringDynArray;
begin
  clearVertScrollBox(frmHome.FilesManagerScrollBox);

  frmHome.FileManagerPathLabel.Text := Inputpath;

  if Inputpath <> '' then
  begin
    Dir := TDirectory.GetDirectories(Inputpath);
    Files := TDirectory.GetFiles(Inputpath);
  end
  else
  begin
    Dir := TDirectory.GetLogicalDrives();
    Files := [];
  end;

  for path in Dir do
  begin

    Panel := TPanel.Create(frmHome.FilesManagerScrollBox);
    Panel.Align := TAlignLayout.Top;
    Panel.Height := 48;
    Panel.Visible := true;
    Panel.TagString := path;
    Panel.Parent := frmHome.FilesManagerScrollBox;

{$IFDEF ANDROID}
    Panel.OnTap := frmHome.DirectoryPanelClick;
{$ELSE}
    Panel.OnClick := frmHome.DirectoryPanelClick;
{$ENDIF}
    lbl := TLabel.Create(Panel);
    lbl.Align := TAlignLayout.Client;
    lbl.TextSettings.HorzAlign := TTextAlign.taTrailing;
    lbl.Visible := true;
    lbl.Parent := Panel;
    if extractfilename(path) <> '' then
      lbl.Text := extractfilename(path)
    else
      lbl.Text := path;

    IconIMG := TImage.Create(Panel);
    IconIMG.Parent := Panel;
    IconIMG.Bitmap := frmHome.DirectoryImage.Bitmap;
    IconIMG.Height := 32.0;
    IconIMG.Width := 50;
    IconIMG.Position.X := 4;
    IconIMG.Position.Y := 8;

  end;

  for path in Files do
  begin
    if RightStr(path, 4) = '.zip' then
    begin

      Panel := TPanel.Create(frmHome.FilesManagerScrollBox);
      Panel.Align := TAlignLayout.Top;
      Panel.Height := 48;
      Panel.Visible := true;
      Panel.TagString := path;
      Panel.Parent := frmHome.FilesManagerScrollBox;

{$IFDEF ANDROID}
      Panel.OnTap := frmHome.FilePanelClick;
{$ELSE}
      Panel.OnClick := frmHome.FilePanelClick;
{$ENDIF}
      lbl := TLabel.Create(Panel);
      lbl.Align := TAlignLayout.Client;
      lbl.TextSettings.HorzAlign := TTextAlign.taTrailing;
      lbl.Visible := true;
      lbl.Parent := Panel;
      lbl.Text := extractfilename(path);

      IconIMG := TImage.Create(Panel);
      IconIMG.Parent := Panel;
      IconIMG.Bitmap := frmHome.HSBIcon.Bitmap;
      IconIMG.Height := 32.0;
      IconIMG.Width := 50;
      IconIMG.Position.X := 4;
      IconIMG.Position.Y := 8;

    end;

  end;

end;

procedure TfrmHome.FilePanelClick(Sender: TObject);
begin
  frmHome.FileManagerPathLabel.Text := TfmxObject(Sender).TagString;
end;

procedure TfrmHome.FilePanelClick(Sender: TObject; const Point: TPointF);
begin
  FilePanelClick(Sender);
end;

procedure TfrmHome.FindERC20autoButtonClick(Sender: TObject);
begin
  SearchTokens(walletAddressForNewToken);

  switchTab(PageControl, TTabItem(frmHome.FindComponent('dashbrd')));
end;

procedure TfrmHome.DirectoryPanelClick(Sender: TObject);
begin

  DrawDirectoriesAndFiles(TfmxObject(Sender).TagString);
end;

procedure TfrmHome.closeOrganizeView(Sender: TObject);
begin

  DeleteAccountLayout.Visible := false;
  Layout1.Visible := true;
  SearchInDashBrdButton.Visible := true;
  NewCryptoLayout.Visible := true;
  WalletList.Visible := true;
  OrganizeList.Visible := false;
  BackToBalanceViewLayout.Visible := false;
  btnSync.Visible := true;
end;

procedure TfrmHome.DeleteAccountButtonClick(Sender: TObject);
begin

  //
  popupWindowYesNo.Create(
    procedure
    begin

      tthread.CreateAnonymousThread(
        procedure
        begin

          tthread.Synchronize(nil,
            procedure
            var
              i: Integer;
            begin

              DeleteAccount(CurrentAccount.name);
              CurrentAccount.free;
              CurrentAccount := nil;
              lastClosedAccount := '';
              refreshWalletDat();

              //RefreshAccountList(nil);
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


  // LoadCurrentAccount(AccountsNames[0]);

end;

procedure TfrmHome.DirectoryPanelClick(Sender: TObject; const Point: TPointF);
begin
  DirectoryPanelClick(Sender);
end;

procedure TfrmHome.FileManagerPathUpButtonClick(Sender: TObject);
begin

  if FileManagerPathLabel.Text <> '' then
    DrawDirectoriesAndFiles(TDirectory.GetParent(FileManagerPathLabel.Text));

end;

procedure TfrmHome.FileManagerSelectClick(Sender: TObject);
begin
  onFileManagerSelectClick();
end;

procedure TfrmHome.ShowFileManager(Sender: TObject);
begin

  ShowFileManager(Sender,
    procedure
    begin
      RFFPathEdit.Text := FileManagerPathLabel.Text;
      switchTab(PageControl, HSBPassword);
    end);
end;

procedure TfrmHome.ShowFileManager(Sender: TObject; onSelect: TProc);
var
  path: String;
  Panel: TPanel;
  lbl: TLabel;

begin
  onFileManagerSelectClick := onSelect;

{$IFDEF ANDROID}
  DrawDirectoriesAndFiles(System.IOUtils.TPath.GetSharedDocumentsPath);
{$ELSE}
  DrawDirectoriesAndFiles('C:\');
{$ENDIF}
  switchTab(PageControl, fileManager);
end;

/// /////////////////////////////////////////////////////////////////////////////////////////

procedure TfrmHome.ShowHistoryDetails(Sender: TObject; const Point: TPointF);
begin
  ShowHistoryDetails(Sender);
end;

procedure TfrmHome.ShowHistoryDetails(Sender: TObject);
var
  th: transactionHistory;
  fmxObject: TfmxObject;
  i: Integer;
  Panel: TPanel;
  addrlbl: TLabel;
  valuelbl: TLabel;
  leftLayout: TLayout;
  rightLayout: TLayout;
begin

  th := CurrentCryptoCurrency.history[TfmxObject(Sender).Tag];

  HistoryTransactionValue.Text := BigIntegertoFloatStr(th.CountValues,
    CurrentCryptoCurrency.decimals);
  if th.confirmation > 0 then
    historyTransactionConfirmation.Text := IntToStr(th.confirmation) +
      ' Confirmation(s)'
  else
    historyTransactionConfirmation.Text := 'Unconfirmed';

  HistoryTransactionDate.Text := FormatDateTime('dd mmm yyyy hh:mm',
    UnixToDateTime(strToIntdef(th.Data, 0)));
  HistoryTransactionID.Text := cutEveryNChar(4, th.TransactionID);
  if th.typ = 'IN' then
    HistoryTransactionSendReceive.Text := 'Receive'
  else if th.typ = 'OUT' then
    HistoryTransactionSendReceive.Text := 'Send'
  else
  begin
    showmessage('History Transaction type error');
    exit();
  end;
  i := 0;
  while i <= HistoryTransactionVertScrollBox.Content.ChildrenCount - 1 do
  begin
    fmxObject := HistoryTransactionVertScrollBox.Content.Children[i];

    if LeftStr(fmxObject.name, length('HistoryValueAddressPanel_')) = 'HistoryValueAddressPanel_'
    then
    begin
      fmxObject.DisposeOf;
      i := 0;
    end;
    inc(i);

  end;
  for i := 0 to length(th.values) - 1 do
  begin
    Panel := TPanel.Create(HistoryTransactionVertScrollBox);
    Panel.Align := TAlignLayout.Top;
    Panel.Height := 36;
    Panel.Visible := true;
    Panel.Tag := i;
    Panel.name := 'HistoryValueAddressPanel_' + IntToStr(i);
    Panel.Parent := HistoryTransactionVertScrollBox;
    Panel.Position.Y := 1000 + Panel.Height * i;

    leftLayout := TLayout.Create(Panel);
    leftLayout.Visible := true;
    leftLayout.Align := TAlignLayout.Left;
    leftLayout.Width := 10;
    leftLayout.Parent := Panel;

    rightLayout := TLayout.Create(Panel);
    rightLayout.Visible := true;
    rightLayout.Align := TAlignLayout.Right;
    rightLayout.Width := 10;
    rightLayout.Parent := Panel;

    valuelbl := TLabel.Create(Panel);
    valuelbl.Align := TAlignLayout.Client;
    valuelbl.Visible := true;
    valuelbl.Parent := Panel;
    valuelbl.Text := BigIntegertoFloatStr(th.values[i],
      CurrentCryptoCurrency.decimals);
    valuelbl.TextSettings.HorzAlign := TTextAlign.Trailing;

    addrlbl := TLabel.Create(Panel);
    addrlbl.Align := TAlignLayout.Client;
    addrlbl.Visible := true;
    addrlbl.Parent := Panel;
    addrlbl.Text := th.addresses[i];
    addrlbl.TextSettings.HorzAlign := TTextAlign.Leading;

  end;

  switchTab(PageControl, HistoryDetails);
end;

procedure TfrmHome.hideWallet(Sender: TObject);
var
  Panel: TPanel;
  fmxObj: TfmxObject;
begin
  if Sender is TButton then
  begin
    Panel := TPanel(TfmxObject(Sender).Parent);

    CryptoCurrency(Panel.TagObject).deleted := true;

    Panel.DisposeOf;
  end;

end;

{$IFDEF ANDROID}

procedure requestHandler(requestCode: Integer;
permissions: TJavaObjectArray<JString>; grantResults: TJavaArray<Integer>);
begin
  // ShowMessage(inttostr(requestCode));

end;
{$ENDIF}

procedure requestForPermission(permName: AnsiString);
{$IFDEF ANDROID}
var
  strArray: TJavaObjectArray<JString>;

begin
  strArray := TJavaObjectArray<JString>.Create(1);
  strArray.Items[0] := TAndroidHelper.StringToJString(permName);
  SharedActivity.requestPermissions(strArray, 1337);
  // SharedActivity.onRequestPermissionsResult:=@requestHandler;
  strArray.free;

end; {$ELSE}

begin

end;
{$ENDIF}

procedure TfrmHome.decryptSeedForSeedRestore(Sender: TObject);
var
  MasterSeed, tced: AnsiString;
begin

  tced := TCA(passwordForDecrypt.Text);
  MasterSeed := SpeckDecrypt(tced, CurrentAccount.EncryptedMasterSeed);
  if not isHex(MasterSeed) then
  begin
    popupWindow.Create(dictionary['FailedToDecrypt']);
    // DecryptSeedMessage.Text := 'Failed to decrypt master seed';
    exit;
  end;

  // tempPassword := passwordForDecrypt.Text;

  switchTab(PageControl, seedGenerated);
  BackupMemo.Lines.Clear;
  // .Lines.Add('Master seed:');
  // BackupMemo.Lines.Add(cutEveryNChar(4 , trngBuffer));
  BackupMemo.Lines.Add(dictionary['MasterseedMnemonic'] + ':');
  BackupMemo.Lines.Add(toMnemonic(MasterSeed));
  // for I := 0 to 3 do
  // BackupMemo.Lines.Add(cutEveryNChar(4 , MidStr(trngBuffer , Low(trngBuffer) + i*16 , 16)));

  tempMasterSeed := MasterSeed;

  MasterSeed := '';

end;

procedure TfrmHome.PanelDragDrop(Sender: TObject; const Data: TDragObject;
const Point: TPointF);
var
  dadService: IFMXDragDropService;
begin
  // if Sender is TPanel then
  // dadService.BeginDragDrop(self , Sender);
end;

procedure TfrmHome.OrganizeListMouseMove(Sender: TObject; Shift: TShiftState;
X, Y: Single);
var
  fmxObj: TfmxObject;
begin

  { for fmxObj in WalletList.Content.Children do
    begin
    if y + OrganizeList.ViewportPosition.y < ToMove.Position.Y then
    begin
    if (Tpanel(fmxObj).Position.Y > Y + OrganizeList.ViewportPosition.y) and ( TPanel(fmxObj).Position.Y < ToMove.Position.Y)  then
    begin
    Tpanel(fmxObj).Position.Y := TPanel(fmxObj).Position.Y + TPanel(fmxObj).Height;
    end;

    end;
    end; }

  if Grab then
  begin

    if Y < 70 then
    begin
      OrganizeList.ScrollBy(0, 6);
    end;
    if Y > OrganizeList.Height - 70 then
    begin
      OrganizeList.ScrollBy(0, -6);
    end;

    ToMove.Position.Y := Y + OrganizeList.ViewportPosition.Y -
      ToMove.Height / 2;
    MovingPanel.Position.Y := Y + OrganizeList.ViewportPosition.Y -
      ToMove.Height / 2;
  end;

end;

procedure TfrmHome.OrganizeListMouseUp(Sender: TObject; Button: TMouseButton;
Shift: TShiftState; X, Y: Single);
var
  fmxObj: TfmxObject;
begin
  Grab := false;
  ToMove.Position.Y := Y + OrganizeList.ViewportPosition.Y - ToMove.Height / 2;
  ToMove.Opacity := 1;

  { for fmxObj in WalletList.Content.Children do
    begin
    if fmxObj.Tag = ToMove.Tag then
    begin
    TPanel(fmxObj).Position.Y := Y + OrganizeList.ViewportPosition.Y -
    ToMove.Height / 2;
    break;
    end;
    end; }

  MovingPanel.DisposeOf;
  OrganizeList.AniCalculations.TouchTracking := [ttVertical];
  // movingPanel.DisposeOf;
end;

procedure TfrmHome.PanelDragStart(Sender: TObject;
const EventInfo: TGestureEventInfo; var Handled: Boolean);
begin
  PanelDragStart(Sender, TPoint.Zero);
end;

procedure TfrmHome.PanelDragStart(Sender: TObject; Button: TMouseButton;
Shift: TShiftState; X, Y: Single);
begin

  PanelDragStart(Sender, TPointF.Create(X, Y));
end;

procedure TfrmHome.PanelDragStart(Sender: TObject; const Point: TPointF);
begin
  vibrate(100);

  // Showmessage(floattostr(Tpanel(Sender).Position.Y));
  ToMove := TPanel(Sender);
  MovingPanel := TPanel(TPanel(Sender).Clone(OrganizeList));
  MovingPanel.Align := TAlignLayout.None;
  MovingPanel.Parent := OrganizeList;
  // MovingPanel.Position.Y := Point.Y + OrganizeList.ViewportPosition.y;

  OrganizeList.Root.Captured := OrganizeList;
  MovingPanel.BringToFront;
  MovingPanel.Repaint;
  Grab := true;
  TPanel(Sender).Opacity := 0.5;
  // SetFocused(MovingPanel);
  OrganizeList.AniCalculations.TouchTracking := [];
end;

procedure TfrmHome.PopupBox1Change(Sender: TObject);
var
  i, j: Integer;
  swapFlag, rep: Boolean;
  temp: Single;
  function compLex(a, b: CryptoCurrency): Integer;
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

  function compVal(a, b: CryptoCurrency): Integer;
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
  function compAmount(a, b: CryptoCurrency): Integer;
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
  rep := true;
  while (rep) do
  begin
    rep := false;
    for i := 0 to OrganizeList.Content.ChildrenCount - 1 do
    begin

      for j := 0 to OrganizeList.Content.ChildrenCount - 1 do
      begin
        swapFlag := false;

        case PopupBox1.ItemIndex of
          { 0:
            begin
            Tpanel(OrganizeList.Content.Children[i]).Position.Y := CryptoCurrency(OrganizeList.Content.Children[j]
            .TagObject).orderInWallet-1;
            break;
            end; }

          0:
            if (compLex(CryptoCurrency(OrganizeList.Content.Children[i]
              .TagObject), CryptoCurrency(OrganizeList.Content.Children[j]
              .TagObject)) > 0) and
              (TPanel(OrganizeList.Content.Children[i]).Position.Y <
              TPanel(OrganizeList.Content.Children[j]).Position.Y) then
              swapFlag := true;

          1:
            if (compVal(CryptoCurrency(OrganizeList.Content.Children[i]
              .TagObject), CryptoCurrency(OrganizeList.Content.Children[j]
              .TagObject)) > 0) and
              (TPanel(OrganizeList.Content.Children[i]).Position.Y >
              TPanel(OrganizeList.Content.Children[j]).Position.Y) then
              swapFlag := true;

          2:
            if (compAmount(CryptoCurrency(OrganizeList.Content.Children[i]
              .TagObject), CryptoCurrency(OrganizeList.Content.Children[j]
              .TagObject)) > 0) and
              (TPanel(OrganizeList.Content.Children[i]).Position.Y >
              TPanel(OrganizeList.Content.Children[j]).Position.Y) then
              swapFlag := true;

        end;

        if swapFlag then
        begin

          temp := TPanel(OrganizeList.Content.Children[i]).Position.Y;
          TPanel(OrganizeList.Content.Children[i]).Position.Y :=
            TPanel(OrganizeList.Content.Children[j]).Position.Y - 1;
          TPanel(OrganizeList.Content.Children[j]).Position.Y := temp - 1;

          if (i = 8) and (j = 11) then
          begin
            compLex(CryptoCurrency(OrganizeList.Content.Children[i].TagObject),
              CryptoCurrency(OrganizeList.Content.Children[j].TagObject));
          end;

          rep := true;

        end;

      end;

    end

  end;

end;

procedure TfrmHome.LanguageBoxChange(Sender: TObject);
var
  Data: WideString;
begin

  WelcomeTabLanguageBox.ItemIndex := TPopupBox(Sender).ItemIndex;
  LanguageBox.ItemIndex := TPopupBox(Sender).ItemIndex;

  Data := loadLanguageFile(TPopupBox(Sender).Items[TPopupBox(Sender)
    .ItemIndex]);

  loadDictionary(Data);
  refreshComponentText();
  if LanguageBox.IsFocused or WelcomeTabLanguageBox.IsFocused then
    refreshWalletDat();

end;

procedure TfrmHome.SwitchViewToOrganize(Sender: TObject;
const EventInfo: TGestureEventInfo; var Handled: Boolean);
var
  Panel: TPanel;
  fmxObj, child, temp: TfmxObject;

  Button: TButton;

begin

  OrganizeButtonClick(Sender);

end;

procedure TfrmHome.WordSeedClick(Sender: TObject);
var
  i, maks: Integer;
  ConfirmedHeight: Integer;
  VSB: TVertScrollBox;
  Button: TButton;
begin
  maks := 0;
  ConfirmedHeight := 0;

  if TButton(Sender).Parent = SeedWordsFlowLayout then
  begin
    TButton(Sender).Parent := ConfirmedSeedFlowLayout;
  end
  else if TButton(Sender).Parent = ConfirmedSeedFlowLayout then
  begin
    TButton(Sender).Parent := SeedWordsFlowLayout;

  end;

  for i := 0 to SeedWordsFlowLayout.ComponentCount - 1 do
  begin

    if (SeedWordsFlowLayout.Components[i] is TButton) and
      (TButton(SeedWordsFlowLayout.Components[i]).Parent = SeedWordsFlowLayout)
    then
    begin
      if maks < (TButton(SeedWordsFlowLayout.Components[i]).Position.Y +
        TButton(SeedWordsFlowLayout.Components[i]).Height) then
      begin
        maks := ceil(TButton(SeedWordsFlowLayout.Components[i]).Position.Y +
          TButton(SeedWordsFlowLayout.Components[i]).Height);
      end;
    end;

  end;

  for i := 0 to SeedWordsFlowLayout.ComponentCount - 1 do
  begin

    if (SeedWordsFlowLayout.Components[i] is TButton) and
      (TButton(SeedWordsFlowLayout.Components[i])
      .Parent = ConfirmedSeedFlowLayout) then
    begin
      if ConfirmedHeight < (TButton(SeedWordsFlowLayout.Components[i])
        .Position.Y + TButton(SeedWordsFlowLayout.Components[i]).Height) then
      begin
        ConfirmedHeight := ceil(TButton(SeedWordsFlowLayout.Components[i])
          .Position.Y + TButton(SeedWordsFlowLayout.Components[i]).Height);
      end;
    end;

  end;

  SeedWordsFlowLayout.Height := maks;
  ConfirmedSeedFlowLayout.Height := ConfirmedHeight;
end;

procedure switchTab(TabControl: TTabControl; TabItem: TTabItem);
begin

  if not frmHome.shown then
  begin
    TabControl.ActiveTab := TabItem;
  end
  else
  begin
    // backTabItem := frmhome.Pagecontrol.ActiveTab;

    frmHome.tabAnim.Tab := TabItem;
    frmHome.tabAnim.ExecuteTarget(TabControl);
    // frmHome.tabAnim.Execute();
  end;
  frmHome.passwordForDecrypt.Text := '';
  frmHome.DecryptSeedMessage.Text := '';
end;

procedure TfrmHome.WVRealCurrencyChange(Sender: TObject);
begin
  WVRealCurrency.Text := StringReplace(WVRealCurrency.Text, ',', '.',
    [rfReplaceAll]);
end;

procedure TfrmHome.WVRealCurrencyClick(Sender: TObject);
var
  selected: Boolean;
begin

  if strToFloatDef(WVRealCurrency.Text, 0) = 0 then
  begin
    WVRealCurrency.Text := '';
  end;

  // RefreshKeyBoard(sender);

end;

procedure TfrmHome.WVRealCurrencyExit(Sender: TObject);
begin
  if (WVRealCurrency.Text = '') then
    WVRealCurrency.Text := '0.00';
end;

procedure TfrmHome.WVSendClick(Sender: TObject);
begin
  // WVsendTO.CaretPosition := 0;
  arrowImg.Height := ShowHideAdvancedButton.TextSettings.Font.Size * 0.75;
  arrowImg.Width := arrowImg.Height * 2;
  // arrowImg.Position.Y := (ShowHideAdvancedButton.Height - ShowHideAdvancedButton.TextSettings.Font.Size) / 2.0;
  // arrowImg.Position.X := arrowImg.

end;

procedure TfrmHome.RefreshKeyBoard(Sender: TObject);
var
  FService: IFMXVirtualKeyboardService;
  FToolbarService: IFMXVirtualKeyBoardToolbarService;
begin
  { TPlatformServices.Current.SupportsPlatformService( IFMXVirtualKeyBoardToolbarService , IInterface(FToolbarService));
    if FToolbarservice <> nil then
    begin
    FToolbarService.SetToolbarEnabled(false);

    end; }

  TPlatformServices.Current.SupportsPlatformService(IFMXVirtualKeyboardService,
    IInterface(FService));

  if FService <> nil then
  begin
    FService.HideVirtualKeyboard();

    // FService.ShowVirtualKeyboard(Tedit(sender));
  end;

end;

procedure TfrmHome.RestoreDecryptedSeedQRButtonClick(Sender: TObject);
begin
  QRFind := QRSearchDecryted;
  pass.Text := '';
  retypePass.Text := '';
  btnCreateWallet.Text := dictionary['StartRecoveringWallet'];
  procCreateWallet := btnQRClick;
  switchTab(PageControl, createPassword);

end;

{
  procedure TfrmHome.HandleActivityMessage(const Sender: TObject; const M: TMessage);
  begin
  if M is TMessageResultNotification then
  OnActivityResult(TMessageResultNotification(M).RequestCode, TMessageResultNotification(M).ResultCode,
  TMessageResultNotification(M).Value);
  end;

  function TfrmHome.OnActivityResult(RequestCode, ResultCode: Integer; Data: JIntent): Boolean;
  var
  filename : string;
  begin
  Result := False;

  TMessageManager.DefaultManager.Unsubscribe(TMessageResultNotification, FMessageSubscriptionID);
  FMessageSubscriptionID := 0;

  // For more info see https://github.com/zxing/zxing/wiki/Scanning-Via-Intent
  if RequestCode = ScanRequestCode then
  begin
  if ResultCode = TJActivity.JavaClass.RESULT_OK then
  begin
  if Assigned(Data) then
  begin
  filename := JStringToString(Data.getStringExtra(StringToJString('RESULT_PATH')));

  Button3.Text := filename;

  //Toast(Format('Found %s format barcode:'#10'%s', [ScanFormat, ScanContent]), LongToast);
  end;
  end
  else if ResultCode = TJActivity.JavaClass.RESULT_CANCELED then
  begin
  //Toast('You cancelled the scan', ShortToast);
  end;
  Result := True;
  end;
  end;

  procedure TfrmHome.RestoreFromFileButtonClick(Sender: TObject);
  var
  Intent : JIntent;
  begin

  FMessageSubscriptionID := TMessageManager.DefaultManager.SubscribeToMessage
  (TMessageResultNotification, HandleActivityMessage);

  //showmessage('dbg1');

  Intent := TJIntent.JavaClass.init;
  Intent.setClassName(SharedActivityContext, StringToJString('com.lamerman.FileDialog'));

  //showmessage('dbg2');

  SharedActivity.startActivityForResult(Intent, 0) ;

  //showmessage('dbg3');


  //Edit1.Text := JStringToString(Data.getStringExtra(StringToJString('RESULT_PATH')));


  end; }
procedure TfrmHome.SearchTokenButtonClick(Sender: TObject);
begin
  if ((CurrentCoin.coin <> 4) or (CurrentCryptoCurrency is Token)) then
  begin

    showmessage('SearchTokenButton shouldnt be visible here');
    exit;

  end;

  SearchTokens(CurrentCoin.addr);
end;

procedure TfrmHome.SelectFileInBackupFileList(Sender: TObject);
begin
  RFFPathEdit.Text := TfmxObject(Sender).TagString;
  switchTab(PageControl, HSBPassword);
end;

procedure TfrmHome.RestoreFromFileConfirmButtonClick(Sender: TObject);
var
  Zip: TEncryptedZipFile;
  str: AnsiString;
  dezip: TZipFile;
  it: AnsiString;
  ac: Account;
  failure:boolean;
begin
   failure:=false;
  if not FileExists(RFFPathEdit.Text) then
  begin
    showmessage('file doesn''t exist');
    exit;
  end;



  // if CurrentAccount = nil then
  // CurrentAccount := Account.Create(RestoreFromFileAccountNameEdit.Text);

  Zip := TEncryptedZipFile.Create(RFFPassword.Text);
  Zip.Open(RFFPathEdit.Text, TZipMode.zmRead);

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
          on F: Exception do begin
            showmessage('Wrong password or damaged file');
            end;
        end;
    end;

  end;
  if failure then exit;
  
  Zip.Close;
  Zip.free;
   ac := Account.Create(RestoreFromFileAccountNameEdit.Text);
  ac.SaveFiles();
  ac.free;
  ac := Account.Create(RestoreFromFileAccountNameEdit.Text);
  ac.LoadFiles;
  ac.userSaveSeed := true;
  ac.SaveFiles;
  AddAccountToFile(ac);

  ac.free;

  LoadCurrentAccount(RestoreFromFileAccountNameEdit.Text);
  FormShow(nil);

end;

procedure TfrmHome.RestoreFromStringSeedButtonClick(Sender: TObject);
begin

  pass.Text := '';
  retypePass.Text := '';
  btnCreateWallet.Text := dictionary['StartRecoveringWallet'];
  procCreateWallet := btnImpSeedClick;
  switchTab(PageControl, createPassword);

end;

procedure TfrmHome.RestoreSeedEncryptedQRButtonClick(Sender: TObject);
begin
  QRFind := QRSearchEncryted;
  btnQRClick(nil);
end;

procedure TfrmHome.WVsendTOExit(Sender: TObject);
begin
  if Pos(' ', WVsendTO.Text) > 0 then
    WVsendTO.Text := StringReplace(WVsendTO.Text, ' ', '', [rfReplaceAll]);
end;

procedure TfrmHome.WVsendTOKeyUp(Sender: TObject; var Key: Word;
var KeyChar: Char; Shift: TShiftState);
begin
  if Key = vkReturn then
  begin
    // ShowMessage('return key pressed');
    // SetFocused(wvAmount);
  end;
end;

procedure TfrmHome.WVsendTOPaint(Sender: TObject; Canvas: TCanvas;
const ARect: TRectF);
var
  brush: TStrokeBrush;
begin
  { brush := TStrokeBrush.Create(TBrushKind.Solid , TAlphacolors.White);
    brush.Thickness := 3.0;

    //Tedit(Sender).S

    with Canvas do
    begin
    BeginUpdate;
    //DrawLine( TPointF.Create(ARect.TopLeft.X ,Arect.BottomRight.y - Brush.Thickness ) ,
    // TPointF.Create(ARect.BottomRight.X ,Arect.BottomRight.y - Brush.Thickness ) , 1 , brush); // test
    FillRect(ARect , 0 , 0 , AllCorners , 0.2 , Brush);
    //DrawRect(Arect , 0 , 0 , AllCorners , 1 , brush);
    //DrawRect;
    endUpdate;
    end;

    brush.Free; }
end;

{ procedure TfrmHome.WVTokenChoseInWallet(Sender: TObject);
  begin
  WVTokenChoseInWallet(Sender, TPointF.Zero);
  end; }

procedure TfrmHome.backBtnDecryptSeed(Sender: TObject);
begin
  // PageControl.ActiveTab := decryptSeedBackTabItem;
  switchTab(PageControl, decryptSeedBackTabItem);
end;

procedure TfrmHome.BackToBalanceViewButtonClick(Sender: TObject);
var
  fmxObj: TfmxObject;
  i: Integer;
begin

  for fmxObj in OrganizeList.Content.Children do
  begin
    CryptoCurrency(fmxObj.TagObject).orderInWallet :=
      round(TPanel(fmxObj).Position.Y);
  end;

  if SyncBalanceThr.Finished = false then
  begin
    try
      SyncBalanceThr.Suspend();
    except
      on E: Exception do
      begin

      end;
    end;
  end;

  if SyncHistoryThr.Finished = false then
  begin

    try
      SyncHistoryThr.Suspend();
    except
      on E: Exception do
      begin

      end;
    end;

  end;

  CurrentAccount.SaveFiles();

  clearVertScrollBox(WalletList);

  TLabel(frmHome.FindComponent('globalBalance')).Text := '0.00';
  FormShow(nil);

  SyncBalanceThr.Terminate();
  SyncHistoryThr.Terminate();

  if SyncBalanceThr.Finished then
  begin

    SyncBalanceThr.DisposeOf;
    SyncBalanceThr := nil;
    SyncBalanceThr := SynchronizeBalanceThread.Create();

  end;
  if SyncHistoryThr.Finished then
  begin
    SyncHistoryThr.DisposeOf;
    SyncHistoryThr := nil;
    SyncHistoryThr := SynchronizeHistoryThread.Create();
  end;

  closeOrganizeView(nil);
end;

procedure TfrmHome.BackupBackButtonClick(Sender: TObject);
begin
  switchTab(PageControl, Settings);
end;

procedure TfrmHome.BCHCashAddrButtonClick(Sender: TObject);
begin
  receiveAddress.Text := bitcoinCashAddressToCashAddress
    (TwalletInfo(CurrentCryptoCurrency).addr);
  receiveAddress.Text := cutEveryNChar(4, receiveAddress.Text, ' ');
end;

procedure TfrmHome.BCHLegacyButtonClick(Sender: TObject);
begin
  receiveAddress.Text := cutEveryNChar(4, TwalletInfo(CurrentCryptoCurrency)
    .addr, ' ')
end;

// invoked when add new token
procedure TfrmHome.changeAddressBech32(Sender: TObject);
var
  hex: AnsiString;
  intArr: bech32.TIntegerArray;
  temp: TBytes;
  i: Integer;
  bechdat: AnsiString;

begin
  if not((CurrentCryptoCurrency is TwalletInfo) and
    (TwalletInfo(CurrentCryptoCurrency).coin = 0)) then
    exit;

  hex := base58.Decode58(CurrentCryptoCurrency.addr);
  temp := hexatoTbytes(hex);
  SetLength(intArr, length(temp));

  for i := 0 to length(temp) - 1 do
  begin
    intArr[i] := Integer(temp[i]);
  end;
  // bechdat := bech32.encode('bc', intArr);

  // ShowMessage(hex + '      ' + bechdat);

end;

procedure TfrmHome.changeAddressUniversal(Sender: TObject);
begin
  receiveAddress.Text := CurrentCryptoCurrency.addr;
end;

procedure TfrmHome.changeFeeWay(Sender: TObject);
begin
  if AutomaticFeeRadio.IsPressed then
  begin
    FeeSpin.Enabled := true;
    wvFee.Enabled := false;
    if FeeSpin.Value = FeeSpin.Max then
    begin
      FeeSpin.ValueDec;
      FeeSpin.ValueInc;
    end
    else
    begin
      FeeSpin.ValueInc;
      FeeSpin.ValueDec;
    end;

    FeeSpin.Value
  end;
  if FixedFeeRadio.IsPressed then
  begin
    FeeSpin.Enabled := false;
    wvFee.Enabled := true;
  end;

end;

procedure TfrmHome.choseTokenClick(Sender: TObject);
var
  t: Token;
  popup: TPopup;
  Panel: TPanel;
  mess: popupWindow;
begin
  for t in CurrentAccount.myTokens do
  begin

    if (t.addr = walletAddressForNewToken) and
      (t.id = (TComponent(Sender).Tag + 10000)) then
    begin

      mess := popupWindow.Create(dictionary['TokenExist']);

      exit;
    end;

  end;

  t := Token.Create(TComponent(Sender).Tag, walletAddressForNewToken);

  t.idInWallet := length(CurrentAccount.myTokens) + 10000;

  CurrentAccount.addToken(t);
  CreatePanel(t);

  switchTab(PageControl, TTabItem(frmHome.FindComponent('dashbrd')));
  btnSyncClick(nil);

end;

procedure TfrmHome.DebugBtnClick(Sender: TObject);
begin

  switchTab(PageControl, DebugScreen);
end;

procedure TfrmHome.DebugSaveSeedButtonClick(Sender: TObject);
begin

  btnDecryptSeed.OnClick := decryptSeedForSeedRestore;

  decryptSeedBackTabItem := PageControl.ActiveTab;
  PageControl.ActiveTab := descryptSeed;
  // switchTab(PageControl, descryptSeed);
  btnDSBack.OnClick := backBtnDecryptSeed;

end;

procedure TfrmHome.DebugScreenClick(Sender: TObject);
begin

end;

// invoked when selecting wallet
procedure TfrmHome.addToken(Sender: TObject);
var
  Panel: TPanel;
  coinName: TLabel;
  coinIMG: TImage;
  i: Integer;
begin
  // save wallet address for later use
  // wallet address is used to create token
  walletAddressForNewToken := TfmxObject(Sender).TagString;

  clearVertScrollBox(frmHome.AvailableTokensBox);

  for i := 0 to length(Token.availableToken) - 1 do
  begin

    with frmHome.AvailableTokensBox do
    begin
      Panel := TPanel.Create(frmHome.AvailableTokensBox);
      Panel.Align := Panel.Align.alTop;
      Panel.Height := 48;
      Panel.Visible := true;
      Panel.Tag := i;
      Panel.Parent := frmHome.AvailableTokensBox;
      Panel.OnClick := frmHome.choseTokenClick;

      coinName := TLabel.Create(frmHome.AvailableTokensBox);
      coinName.Parent := Panel;
      coinName.Text := Token.availableToken[i].name;
      coinName.Visible := true;
      coinName.Width := 500;
      coinName.Position.X := 52;
      coinName.Position.Y := 16;
      coinName.Tag := i;
      coinName.OnClick := frmHome.choseTokenClick;

      coinIMG := TImage.Create(frmHome.AvailableTokensBox);
      coinIMG.Parent := Panel;
      coinIMG.Bitmap := frmHome.TokenIcons.Source[i].MultiResBitmap[0].Bitmap;

      coinIMG.Height := 32.0;
      coinIMG.Width := 50;
      coinIMG.Position.X := 4;
      coinIMG.Position.Y := 8;
      coinIMG.OnClick := frmHome.choseTokenClick;
      coinIMG.Tag := i;

    end;
  end;
  switchTab(PageControl, ChoseToken);
  // PageControl.ActiveTab := ChoseToken;
end;

procedure TfrmHome.privateKeyPasswordCheck(Sender: TObject);
var
  MasterSeed, tced: AnsiString;
var
  Bitmap: TBitmap;
begin

  tced := TCA(passwordForDecrypt.Text);
  MasterSeed := SpeckDecrypt(tced, CurrentAccount.EncryptedMasterSeed);
  if not isHex(MasterSeed) then
  begin
    DecryptSeedMessage.Text := dictionary['FailedToDecrypt'];
    exit;
  end;

  // lblPrivateKey.Text := seed split every 4 char     example '0123 4567 89AB CDEF ...'
  lblPrivateKey.Text := cutEveryNChar(4, priv256forhd(CurrentCoin.coin,
    CurrentCoin.X, CurrentCoin.Y, MasterSeed));

  MasterSeed := '';

  Bitmap := StrToQRBitmap(removeSpace(lblPrivateKey.Text));
  PrivKeyQRImage.Bitmap.Assign(Bitmap);
  Bitmap.free;

  switchTab(PageControl, ExportKeyScreen);

end;

procedure TfrmHome.AddNewAccountButtonClick(Sender: TObject);
begin
  switchTab(PageControl, AddAccount);
  AccountsListPanel.Visible := false;
end;

procedure TfrmHome.addNewWalletPanelClick(Sender: TObject);
begin
  newcoinID := TComponent(Sender).Tag;
  switchTab(PageControl, AddNewCoinSettings);
  // PageControl.ActiveTab := AddNewCoinSettings;

end;

procedure TfrmHome.TransactionWaitForSendBackButtonClick(Sender: TObject);
begin
  switchTab(PageControl, walletView);
end;

procedure TfrmHome.TransactionWaitForSendLinkLabelClick(Sender: TObject);
var
  myURI: AnsiString;

  URL: WideString;
  {$IFDEF ANDROID}
var
  Intent: JIntent;
{$ENDIF}
begin
  myURI := TfmxObject(Sender).TagString;

  URL := myURI;
//ShellExecute(0, 'OPEN', PWideChar(URL), '', '', { SW_SHOWNORMAL } 1);

{$IFDEF ANDROID}
  Intent := TJIntent.Create;
  Intent.setAction(TJIntent.JavaClass.ACTION_VIEW);
  Intent.setData(StrToJURI(myURI));
  SharedActivity.startActivity(Intent);
{$ENDIF ANDROID}

end;

procedure TfrmHome.TrySendTX(Sender: TObject);
var
  MasterSeed, tced, Address, CashAddr: AnsiString;
var
  amount, fee, tempFee: BigInteger;
begin

  tced := TCA(ConfirmSendPasswordEdit.Text);
  ConfirmSendPasswordEdit.Text:='';
  MasterSeed := SpeckDecrypt(tced, CurrentAccount.EncryptedMasterSeed);
  if not isHex(MasterSeed) then
  begin
    popupWindow.Create(dictionary['FailedToDecrypt']);
    // DecryptSeedMessage.Text := 'Failed to decrypt master seed';
    exit;
  end;

  if not isEthereum then
  begin
    fee := StrFloatToBigInteger(wvFee.Text, AvailableCoin[CurrentCoin.coin]
      .decimals);
    tempFee := fee;
  end
  else
  begin
    fee := BigInteger.Parse(wvFee.Text);

    if isTokenTransfer then
      tempFee := BigInteger.Parse(wvFee.Text) * 66666
    else
      tempFee := BigInteger.Parse(wvFee.Text) * 21000;
  end;

  // showmessage( booltoStr(isTokenTransfer) );

  if (not isTokenTransfer) then
  begin
    amount := StrFloatToBigInteger(wvAmount.Text,
      AvailableCoin[CurrentCoin.coin].decimals);
    if FeeFromAmountSwitch.IsChecked then
    begin
      amount := amount - tempFee;
    end;

  end;

  if (isEthereum) and (isTokenTransfer) then
    amount := StrFloatToBigInteger(wvAmount.Text,
      CurrentCryptoCurrency.decimals);
  // ShowMessage(amount.ToString+' '+tempfee.ToString);
  if { (not isEthereum) and } (not isTokenTransfer) then
    if amount + tempFee > (CurrentCryptoCurrency.confirmed) then
    begin
      popupWindow.Create(dictionary['AmountExceed']);
      exit;
    end;

  if ((amount) = 0) or ((fee) = 0) then
  begin
    popupWindowOK.Create(
      procedure
      begin

        tthread.CreateAnonymousThread(
          procedure
          begin
            switchTab(PageControl, walletView);
          end).Start;

      end, dictionary['InvalidValues']);

    exit
  end;

  Address := removeSpace(WVsendTO.Text);

  if (CurrentCryptoCurrency is TwalletInfo) and
    (TwalletInfo(CurrentCryptoCurrency).coin = 3) then
  begin
    CashAddr := StringReplace(LowerCase(Address), 'bitcoincash:', '',
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
      end
    end;
  end;

  // ShowMessage(amount.ToString+' '+tempfee.ToString);

  tthread.CreateAnonymousThread(
    procedure
    var
      ans: AnsiString;
    begin

      tthread.Synchronize(nil,
        procedure
        begin
          TransactionWaitForSendAniIndicator.Visible := true;
          TransactionWaitForSendAniIndicator.Enabled := true;
          TransactionWaitForSendDetailsLabel.Visible := true;
          TransactionWaitForSendDetailsLabel.Text :=
            'Sending... It may take a few seconds';
          TransactionWaitForSendLinkLabel.Visible := false;

          switchTab(PageControl, TransactionWaitForSend);
        end);

      ans := sendCoinsTO(CurrentCoin, Address, amount, fee, MasterSeed,
        AvailableCoin[CurrentCoin.coin].name);

      SynchronizeCryptoCurrency(CurrentCryptoCurrency);

      tthread.Synchronize(nil,
        procedure
        var
          ts: TStringList;
          i: Integer;
        begin
          TransactionWaitForSendAniIndicator.Visible := false;
          TransactionWaitForSendAniIndicator.Enabled := false;
          TransactionWaitForSendDetailsLabel.Visible := false;
          TransactionWaitForSendLinkLabel.Visible := true;
          if LeftStr(ans, length('Transaction sent')) = 'Transaction sent' then
          begin
            TransactionWaitForSendLinkLabel.Text :=
              'Click here to see details in Explorer';
            TransactionWaitForSendDetailsLabel.Text := 'Transaction sent';

            StringReplace(ans, #$A, ' ', [rfReplaceAll]);
            ts := SplitString(ans, ' ');
            TransactionWaitForSendLinkLabel.TagString :=
              getURLToExplorer(CurrentCoin.coin, ts[ts.Count - 1]);
            TransactionWaitForSendLinkLabel.Text :=
              TransactionWaitForSendLinkLabel.TagString;
            ts.free;
            // showmessage(getURLToExplorer( CurrentCoin.coin , ts[ts.Count-1]) + #$A + ans);
            TransactionWaitForSendDetailsLabel.Visible := true;
            TransactionWaitForSendLinkLabel.Visible := true;
          end
          else
          begin
            TransactionWaitForSendDetailsLabel.Visible := true;
            TransactionWaitForSendLinkLabel.Visible := false;
            // StringReplace( ans , #$A , ' ' , [rfReplaceAll] );
            ts := SplitString(ans, #$A);
            TransactionWaitForSendDetailsLabel.Text := ts[0];
            for i := 1 to ts.Count - 1 do
              if ts[i] <> '' then
              begin
                TransactionWaitForSendDetailsLabel.Text :=
                  TransactionWaitForSendDetailsLabel.Text + #13#10 +
                  'Error: ' + ts[i];
                break;
              end;

            ts.free;
          end;

          // TransactionWaitForSendLinkLabel.Text := ans;
        end);

    end).Start;


end;

procedure TfrmHome.updateBtnClick(Sender: TObject);
begin
{$IFDEF ANDROID}
  executeAndroid('am start -a org.lineageos.updater');
{$ENDIF}
end;

procedure TfrmHome.USDtoCoin(Sender: TObject);
begin
  if WVRealCurrency.IsFocused then
  begin
    if WVRealCurrency.Text = '' then
    begin
      wvAmount.Text := BigIntegertoFloatStr(0, CurrentCryptoCurrency.decimals);
    end
    else
    begin
      wvAmount.Text :=
        floatToStrF((strToFloatDef(WVRealCurrency.Text, 0) /
        CurrencyConverter.calculate(CurrentCryptoCurrency.rate)), ffFixed, 20,
        CurrentCryptoCurrency.decimals);
      SendAllFundsSwitch.IsChecked := false;
    end;

    FeeFromAmountSwitch.Enabled := true;
  end;

end;

procedure TfrmHome.wvAmountChange(Sender: TObject);
var
  i: Single;
begin
  case length(wvAmount.Text) of
    0 .. 8:
      i := 24;
    9 .. 14:
      i := 20;
    15 .. 20:
      i := 16;
    21 .. 25:
      i := 10;
  else
    i := 0;

  end;

  wvAmount.TextSettings.Font.Size := i;
  wvAmount.Text := StringReplace(wvAmount.Text, ',', '.', [rfReplaceAll]);
end;

procedure TfrmHome.wvAmountClick(Sender: TObject);
begin
  if strToFloatDef(wvAmount.Text, 0) = 0 then
    wvAmount.Text := '';

  // refreshKeyBoard(sender);
end;

procedure TfrmHome.wvAmountExit(Sender: TObject);
begin
  if wvAmount.Text = '' then
    wvAmount.Text := BigIntegertoFloatStr(0, CurrentCoin.decimals);
end;

procedure TfrmHome.wvAmountTyping(Sender: TObject);
begin
  wvAmountChange(Sender);
end;

procedure TfrmHome.CoinToUSD(Sender: TObject);
begin
  if wvAmount.IsFocused then
  begin
    if wvAmount.Text = '' then
    begin
      WVRealCurrency.Text := '0.00';
    end
    else
    begin
      WVRealCurrency.Text :=
        floatToStrF(CurrencyConverter.calculate(strToFloatDef(wvAmount.Text, 0))
        * (CurrentCryptoCurrency.rate), ffFixed, 18, 2);
      SendAllFundsSwitch.IsChecked := false;
    end;

    FeeFromAmountSwitch.Enabled := true;
  end;

end;

procedure TfrmHome.ConfirmNewAccountButtonClick(Sender: TObject);
var
  str: AnsiString;
  newAcc: Account;
begin

  pass.Text := '';
  retypePass.Text := '';
  btnCreateWallet.Text := dictionary['OpenNewWallet'];
  procCreateWallet := btnGenSeedClick;
  switchTab(PageControl, createPassword);

end;

procedure TfrmHome.CopyPrivateKeyButtonClick(Sender: TObject);
var
  svc: IFMXExtendedClipboardService;
begin
  if TPlatformServices.Current.SupportsPlatformService(IFMXClipboardService, svc)
  then
  begin

    svc.setClipboard(removeSpace(lblPrivateKey.Text));
    popupWindow.Create(removeSpace(lblPrivateKey.Text) + ' ' + dictionary
      ['CopiedToClipboard']);

  end;
end;

procedure TfrmHome.CopyToClipboard(Sender: TObject;
const EventInfo: TGestureEventInfo; var Handled: Boolean);
var
{$IFDEF ANDROID}
  Vibrator: JVibrator;
{$ENDIF}
  svc: IFMXExtendedClipboardService;
begin
  // showmessage('debug');
  if TPlatformServices.Current.SupportsPlatformService(IFMXClipboardService, svc)
  then
  begin

    if Sender is TEdit then
    begin

      if svc.GetClipboard().ToString() <> removeSpace(TEdit(Sender).Text) then
      begin

        svc.setClipboard(removeSpace(TEdit(Sender).Text));
        popupWindow.Create(removeSpace(TEdit(Sender).Text) + ' ' + dictionary
          ['CopiedToClipboard']);
{$IFDEF ANDROID}
        Vibrator := TJvibrator.Wrap
          ((SharedActivityContext.getSystemService
          (TJContext.JavaClass.VIBRATOR_SERVICE) as ILocalObject)
          .GetObjectID());
        Vibrator.vibrate(200);

{$ENDIF}
      end;
    end;

  end;

end;

procedure TfrmHome.CreateBackupButtonClick(Sender: TObject);
begin
  switchTab(PageControl, BackupTabItem);
end;

procedure TfrmHome.CurrencyBoxChange(Sender: TObject);
begin
  CurrencyConverter.setCurrency(CurrencyBox.Items[CurrencyBox.ItemIndex]);
  refreshCurrencyValue();

  if CurrencyBox.IsFocused then
    refreshWalletDat();
end;

// button SKIP on screen with field to repeat seed
procedure TfrmHome.btnSkipClick(Sender: TObject);
begin
  userSavedSeed := true;
  refreshWalletDat();

  switchTab(PageControl, TTabItem(frmHome.FindComponent('dashbrd')));
end;

procedure TfrmHome.btnSMVCancelClick(Sender: TObject);
begin
  switchTab(PageControl, lastView);
  // PageControl.ActiveTab := lastView;
end;

// button in warning window
procedure TfrmHome.btnSMVNoClick(Sender: TObject);
begin
  switchTab(PageControl, lastView);
  // PageControl.ActiveTab := lastView;
  lastChose := 0;
end;

// button in warning window
procedure TfrmHome.btnSMVYesClick(Sender: TObject);
begin
  switchTab(PageControl, lastView);
  // PageControl.ActiveTab := lastView;
  lastChose := 1;
end;

{ procedure TfrmHome.decriptOKforNewWallet(Sender: TObject);
  var
  MasterSeed, tced: AnsiString;
  walletInfo: TWalletInfo;
  begin
  tced := TCA(passwordForDecrypt.Text);
  MasterSeed := SpeckDecrypt(tced, encryptedSeed);
  if not isHex(MasterSeed) then
  begin
  DecryptSeedMessage.Text := 'Failed to decrypt master seed';
  exit;
  end;

  walletInfo := coindata.createCoin(newcoinID, countWalletBy(newcoinID), 0,
  MasterSeed);

  clearVertScrollBox(frmHome.WalletList);
  insertToWd(walletInfo);

  repaintWalletList;

  FormShow(nil);

  end; }
{ procedure TfrmHome.WVTokenChoseInWallet(Sender: TObject; const Point: TPointF);
  var
  id: Integer;
  begin


  FeeFromAmountLayout.Visible := false;

  id := TComponent(Sender).Tag;
  currentToken := id - 10000;
  CurrentCryptoCurrency := myTokens[currentToken];

  isTokenTransfer := true;
  currentWallet := getwalletId(myTokens[id - 10000].addr); // WARNING
  frmHome.wvAddress.Text := myWallets[currentWallet].addr;

  createHistoryList(myTokens[currentToken]);

  wvFee.Text := myWallets[currentWallet].efee[0];
  if wvFee.Text = '' then
  wvFee.Text := '0';

  lblFeeHeader.Text := dictionary['GasPriceWEI'] + ': ';
  lblFee.Text := wvFee.Text + '  = ' +
  floatToStrF(CurrencyConverter.calculate(strToFloat(wvFee.Text) * 66666 *
  myWallets[getwalletId(myTokens[currentToken].addr)].rate /
  (1000000.0 * 1000000.0 * 1000000.0)), ffFixed, 18, 2) + ' ' +
  CurrencyConverter.symbol;

  lbBalance.Text := BigIntegerBeautifulStr(myTokens[id - 10000].confirmed,
  myTokens[id - 10000].decimals);
  lbBalanceLong.Text := BigIntegertoFloatStr(myTokens[id - 10000].confirmed,
  myTokens[id - 10000].decimals);

  wvAmount.Text := BigIntegertoFloatStr(0, myTokens[currentToken].decimals);
  WVRealCurrency.Text := '0.00';

  ReceiveValue.Text := BigIntegertoFloatStr(0, myTokens[currentToken].decimals);
  ReceiveAmountRealCurrency.Text := '0.00';

  wvGFX.Bitmap := myTokens[id - 10000].getIcon;
  ShortcutValetInfoImage.Bitmap := myTokens[id - 10000].getIcon;

  // TopInfoConfirmed.Text := 'Available ' + myTokens[id - 10000].shortcut +
  // ' balance: ';
  TopInfoConfirmedValue.Text := ' ' + BigIntegertoFloatStr
  (myTokens[currentToken].confirmed, myTokens[currentToken].decimals);

  // topInfoUnconfirmed.Text := 'Confirming balance: ';
  TopInfoUnconfirmedValue.Text := ' ' + BigIntegertoFloatStr
  (myTokens[currentToken].unconfirmed, myTokens[currentToken].decimals);

  lblCoinShort.Text := myTokens[currentToken].shortcut + '   ';
  lblReceiveCoinShort.Text := myTokens[currentToken].shortcut + '   ';

  receiveAddress.Text := myWallets[currentWallet].addr;

  QRChangeTimerTimer(nil);

  WVTabControl.ActiveTab := WVBalance;

  lblFiat.Text := floatToStrF(CurrentCryptoCurrency.getFiat(), ffFixed, 15, 2);

  WVsendTO.Text := '';
  lblBlockInfo.Visible := false;
  FeeSpin.Visible := false;

  SendAllFundsSwitch.IsChecked := false;
  FeeFromAmountSwitch.IsChecked := false;

  AddressTypelayout.Visible := false;
  BCHAddressesLayout.Visible := false;

  switchTab(PageControl, walletView);
  end; }

procedure TfrmHome.OpenWalletView(Sender: TObject; const Point: TPointF);
var
  wd: TwalletInfo;
begin

  CurrentCryptoCurrency := CryptoCurrency(TfmxObject(Sender).TagObject);

  isTokenTransfer := CurrentCryptoCurrency is Token;

  if isTokenTransfer then
  begin
    for wd in CurrentAccount.myCoins do
      if wd.addr = CurrentCryptoCurrency.addr then
      begin
        CurrentCoin := wd;
        break;
      end;
  end
  else
    CurrentCoin := TwalletInfo(CurrentCryptoCurrency);

  createHistoryList(CurrentCryptoCurrency);

  frmHome.wvAddress.Text := CurrentCryptoCurrency.addr;

  FeeFromAmountLayout.Visible := not isTokenTransfer;

  WVTabControl.ActiveTab := WVBalance;

  if isEthereum or isTokenTransfer then
  begin

    lblBlockInfo.Visible := false;
    FeeSpin.Visible := false;
    FeeSpin.Opacity := 0;
    FeeSpin.Enabled := false;

  end
  else
  begin

    lblBlockInfo.Visible := true;
    FeeSpin.Visible := true;
    FeeSpin.Enabled := true;
    FeeSpin.Opacity := 1;

  end;

  lbBalance.Text := BigIntegerBeautifulStr(CurrentCryptoCurrency.confirmed,
    CurrentCryptoCurrency.decimals);

  lbBalanceLong.Text := BigIntegertoFloatStr(CurrentCryptoCurrency.confirmed,
    CurrentCryptoCurrency.decimals);

  // POLE Z KWOTA DO WYSLANIA
  wvAmount.Text := BigIntegertoFloatStr(0, CurrentCryptoCurrency.decimals);

  lblFiat.Text := floatToStrF(CurrentCryptoCurrency.getFiat(), ffFixed, 15, 2);

  if isEthereum or isTokenTransfer then
  begin
    lblFeeHeader.Text := dictionary['GasPriceWEI'] + ':';
    lblFee.Text := '';
    wvFee.Text := CurrentCoin.efee[0];

    if isTokenTransfer then
    begin
      lblFee.Text := wvFee.Text + '  = ' +
        floatToStrF(CurrencyConverter.calculate(strToFloatDef(wvFee.Text,
        0) * 66666 * CurrentCryptoCurrency.rate / (1000000.0 * 1000000.0 *
        1000000.0)), ffFixed, 18, 2) + ' ' + CurrencyConverter.symbol;
    end;

  end
  else
  begin
    lblFeeHeader.Text := dictionary['TransactionFee'] + ':';
    lblFee.Text := '0.00 ' + CurrentCryptoCurrency.shortcut;
    wvFee.Text := CurrentCoin.efee[round(FeeSpin.Value) - 1];
  end;
  if wvFee.Text = '' then
    wvFee.Text := '0';

  ReceiveValue.Text := BigIntegertoFloatStr(0, CurrentCryptoCurrency.decimals);

  ReceiveAmountRealCurrency.Text := '0.00';

  WVRealCurrency.Text := floatToStrF(strToFloatDef(wvAmount.Text, 0) *
    CurrentCryptoCurrency.rate, ffFixed, 15, 2);

  ShortcutValetInfoImage.Bitmap := CurrentCryptoCurrency.getIcon();

  wvGFX.Bitmap := CurrentCryptoCurrency.getIcon();

  TopInfoConfirmedValue.Text := ' ' + BigIntegertoFloatStr
    (CurrentCryptoCurrency.confirmed, CurrentCryptoCurrency.decimals);

  TopInfoUnconfirmedValue.Text := ' ' + BigIntegertoFloatStr
    (CurrentCryptoCurrency.unconfirmed, CurrentCryptoCurrency.decimals);

  lblCoinShort.Text := CurrentCryptoCurrency.shortcut + '   ';

  lblReceiveCoinShort.Text := CurrentCryptoCurrency.shortcut + '   ';

  QRChangeTimerTimer(nil);

  receiveAddress.Text := cutEveryNChar(4, CurrentCryptoCurrency.addr);

  lblFiat.Text := floatToStrF(CurrentCryptoCurrency.getFiat(), ffFixed, 15, 2);

  WVsendTO.Text := '';

  SendAllFundsSwitch.IsChecked := false;
  FeeFromAmountSwitch.IsChecked := false;

  if CurrentCryptoCurrency is TwalletInfo then
  begin

    if (TwalletInfo(CurrentCryptoCurrency).coin = 0) then
      AddressTypelayout.Visible := true
    else
      AddressTypelayout.Visible := false;

    if (TwalletInfo(CurrentCryptoCurrency).X = -1) and
      (TwalletInfo(CurrentCryptoCurrency).Y = -1) and
      (TwalletInfo(CurrentCryptoCurrency).isCompressed = false) then
      AddressTypelayout.Visible := false;

    if TwalletInfo(CurrentCryptoCurrency).coin = 3 then
      BCHAddressesLayout.Visible := true
    else
      BCHAddressesLayout.Visible := false;

  end
  else
  begin
    AddressTypelayout.Visible := false;
    BCHAddressesLayout.Visible := false;
  end;
  if (CurrentCryptoCurrency is TwalletInfo) and
    (TwalletInfo(CurrentCryptoCurrency).coin = 4) then
    SearchTokenButton.Visible := true
  else
    SearchTokenButton.Visible := false;
  switchTab(PageControl, walletView);

end;

procedure TfrmHome.OpenWalletView(Sender: TObject);
begin
  OpenWalletView(Sender, TPoint.Zero);
end;

(* procedure TfrmHome.switchView(Sender: TObject; const Point: TPointF);
  begin


  // BitmapListAnimation1.Start;

  FeeFromAmountLayout.Visible := true;

  isTokenTransfer := false;
  currentWallet := TComponent(Sender).Tag;
  CurrentCryptoCurrency := myWallets[currentWallet];

  frmHome.wvAddress.Text := myWallets[currentWallet].addr;
  WVTabControl.ActiveTab := WVBalance;
  createHistoryList(myWallets[currentWallet]);
  // lbBalance.Text := BigIntegerBeautifulStr(myWallets[currentWallet].confirmed , availableCoin[myWallets[currentWallet].coin].decimals);
  // lbBalanceLong.Text := BigIntegerToFloatStr(myWallets[currentWallet].confirmed , availableCoin[myWallets[currentWallet].coin].decimals);

  // showmessage(inttoStr(currentWallet)+'  '+inttoStr(myWallets[currentWallet].coin));

  if isEthereum then
  begin
  lblBlockInfo.Visible := false;
  FeeSpin.Visible := false;
  FeeSpin.Opacity := 0;
  FeeSpin.Enabled := false;

  // to są napisy w zakladce HISTORY
  lbBalance.Text := BigIntegerBeautifulStr(myWallets[currentWallet].confirmed,
  availableCoin[myWallets[currentWallet].coin].decimals);

  { BigIntegerBeautifulStr(myWallets[currentWallet].confirmed
  - StrToInt64Def(myWallets[currentWallet].efee[0], 0),
  availableCoin[myWallets[currentWallet].coin].decimals); }

  lbBalanceLong.Text := BigIntegertoFloatStr
  (myWallets[currentWallet].confirmed,
  availableCoin[myWallets[currentWallet].coin].decimals);
  { BigIntegerToFloatStr(//(0 , availableCoin[myWallets[currentWallet].coin].decimals);{
  max(0 , (myWallets[currentWallet].confirmed -
  bigInteger(StrToInt64Def(myWallets[currentWallet].efee[0], 0))) ),
  availableCoin[myWallets[currentWallet].coin].decimals); }
  end
  else
  begin
  lblBlockInfo.Visible := true;
  FeeSpin.Visible := true;
  FeeSpin.Enabled := true;
  FeeSpin.Opacity := 1;

  lbBalance.Text := BigIntegerBeautifulStr(myWallets[currentWallet].confirmed,
  availableCoin[myWallets[currentWallet].coin].decimals); // -
  // StrfloatToBigInteger( myWallets[currentWallet].efee[round(FeeSpin.Value) - 1] ,
  // availableCoin[myWallets[currentWallet].coin].decimals)
  { - round(StrToFloatDef(myWallets[currentWallet].efee[round(FeeSpin.Value) -
  1], 0.0) * (Math.power(10,availableCoin[myWallets[currentWallet].coin].decimals))), }
  // ,availableCoin[myWallets[currentWallet].coin].decimals);

  lbBalanceLong.Text := BigIntegertoFloatStr
  (myWallets[currentWallet].confirmed,
  availableCoin[myWallets[currentWallet].coin].decimals); { -
  StrfloatToBigInteger( myWallets[currentWallet].efee[round(FeeSpin.Value) - 1] ,
  availableCoin[myWallets[currentWallet].coin].decimals)
  {- round(StrToFloatDef(myWallets[currentWallet].efee[round(FeeSpin.Value) -
  1], 0.0) * (Math.power(10,availableCoin[myWallets[currentWallet].coin].decimals))), }
  // ,availableCoin[myWallets[currentWallet].coin].decimals);
  end;
  if isTokenTransfer then
  begin
  lblBlockInfo.Visible := false;
  FeeSpin.Visible := false;
  end;
  // POLE Z KWOTA DO WYSLANIA
  wvAmount.Text := BigIntegertoFloatStr(0, myWallets[currentWallet].decimals);

  lblFiat.Text := myWallets[currentWallet].fiat;

  if isEthereum then
  begin
  lblFeeHeader.Text := dictionary['GasPriceWEI'] + ':';
  lblFee.Text := '';
  wvFee.Text := myWallets[currentWallet].efee[0];
  end
  else
  begin
  lblFeeHeader.Text := dictionary['TransactionFee'] + ':';
  lblFee.Text := '0.00 ' + availableCoin
  [myWallets[currentWallet].coin].shortcut;
  wvFee.Text := myWallets[currentWallet].efee[round(FeeSpin.Value) - 1];
  end;
  if wvFee.Text = '' then
  wvFee.Text := '0';

  ReceiveValue.Text := BigIntegertoFloatStr(0,
  myWallets[currentWallet].decimals);
  ReceiveAmountRealCurrency.Text := '0.00';

  WVRealCurrency.Text := floatToStrF(strToFloatDef(wvAmount.Text, 0) *
  myWallets[currentWallet].rate, ffFixed, 15, 2);

  ShortcutValetInfoImage.Bitmap := getCoinIcon(myWallets[currentWallet].coin);

  wvGFX.Bitmap := getCoinIcon(myWallets[currentWallet].coin);

  // TopInfoConfirmed.Text := 'Available ' + availableCoin
  // [myWallets[currentWallet].coin].shortcut + ' balance: ';
  TopInfoConfirmedValue.Text := ' ' + getConfirmedAsString
  (myWallets[currentWallet]);

  // topInfoUnconfirmed.Text := 'Confirming balance: ';
  TopInfoUnconfirmedValue.Text := ' ' + BigIntegertoFloatStr
  (myWallets[currentWallet].unconfirmed,
  availableCoin[myWallets[currentWallet].coin].decimals);

  lblCoinShort.Text := availableCoin[myWallets[currentWallet].coin]
  .shortcut + '   ';

  lblReceiveCoinShort.Text := availableCoin[myWallets[currentWallet].coin]
  .shortcut + '   ';

  QRChangeTimerTimer(nil);

  receiveAddress.Text := cutEveryNChar(4, myWallets[currentWallet].addr);

  lblFiat.Text := floatToStrF(CurrentCryptoCurrency.getFiat(), ffFixed, 15, 2);

  WVsendTO.Text := '';

  SendAllFundsSwitch.IsChecked := false;
  FeeFromAmountSwitch.IsChecked := false;

  if TwalletInfo(CurrentCryptoCurrency).coin = 0 then
  AddressTypelayout.Visible := true
  else
  AddressTypelayout.Visible := false;

  if TwalletInfo(CurrentCryptoCurrency).coin = 3 then
  BCHAddressesLayout.Visible := true
  else
  BCHAddressesLayout.Visible := false;

  switchTab(PageControl, walletView);

  end;

  procedure TfrmHome.switchView(Sender: TObject);
  begin
  switchView(Sender, TPoint.Zero);
  end; *)

procedure TfrmHome.tabAnimUpdate(Sender: TObject);
begin

end;

// delete wallet button
procedure TfrmHome.btnSWipeClick(Sender: TObject);
begin

  popupWindowYesNo.Create(
    procedure()
    begin
      wipeWalletDat;
{$IFDEF WINDOWS}
      frmHome.Close;
{$ENDIF}
{$IFDEF ANDROID}
      SharedActivity.finish;
{$ENDIF}
    end,
    procedure()
    begin

    end, dictionary['SureWipeWallet'] + #13#10 + dictionary
    ['CantRestoreCoins']);

end;

procedure TfrmHome.btnWVSettingsClick(Sender: TObject);
begin
  switchTab(WVTabControl, WVSettings);
  // WVTabControl.ActiveTab := WVSettings;
end;

procedure TfrmHome.btnDecryptedQRClick(Sender: TObject);
var
  alphaStr: AnsiString;
begin

end;

procedure TfrmHome.btnImpSeedClick(Sender: TObject);
var
  alphaStr: AnsiString;
begin
  {
    if pass.Text <> retypePass.Text then
    begin
    passwordMessage.Text := 'Passwords does not match';
    exit;
    end;
    if pass.Text.length < 5 then
    begin
    popupWindow.Create('Password is too short. Minimum length is 5');
    exit();
    end;

    alphaStr :=
    'You use the alpha version of the HODLER multiwallet, it may be unstable.' +
    ' The current version of the program is used only for functionality tests and for sending feedback.'
    + ' Confirm below that you have understood this message and accept it.';

    popupWindowYesNo.Create(
    procedure
    begin

    TThread.CreateAnonymousThread(
    procedure
    begin
    TThread.Synchronize(nil,
    procedure
    begin }

  switchTab(PageControl, SeedCreation);

  { end);
    end).Start;

    end,
    procedure
    begin
    end, alphaStr);
    // PageControl.ActiveTab := SeedCreation; }

end;

procedure TfrmHome.btnCheckSeedClick(Sender: TObject);
var
  withoutWhiteChar: AnsiString;
  seedFromWords: AnsiString;
  it: AnsiString;
  inputWordsList: TStringList;

begin
  withoutWhiteChar := StringReplace(frmHome.SeedField.Text, ' ', '',
    [rfReplaceAll]);
  withoutWhiteChar := StringReplace(withoutWhiteChar, #13, '', [rfReplaceAll]);
  withoutWhiteChar := StringReplace(withoutWhiteChar, #10, '', [rfReplaceAll]);

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

procedure TfrmHome.btnOptionsClick(Sender: TObject);
begin

  switchTab(PageControl, Settings);
  // PageControl.ActiveTab := Settings;
end;

procedure TfrmHome.btnQRClick(Sender: TObject);

const
  camPerm = 'android.permission.CAMERA';

begin
{$IFDEF ANDROID}
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
          if TAndroidHelper.Context.checkCallingOrSelfPermission
            (StringToJString(camPerm)) = -1 then
          begin
            sleep(250);
          end
          else
          begin
            tthread.Synchronize(nil,
              procedure
              begin
                btnQRClick(nil);
              end);

            break;

          end;

        end;

      end).Start;

    exit;

    // SharedActivity.getIntent.
    // TAndroidHelper.
  end;
{$ENDIF}
  // context
  if {$IFDEF ANDROID}TAndroidHelper.Context.checkCallingOrSelfPermission
    (StringToJString(camPerm)) = 0 {$ELSE} true {$ENDIF} then
  begin

    try

      cameraBackTabItem := PageControl.ActiveTab;

      // PageControl.ActiveTab := TTabItem(frmHome.FindComponent('qrreader'));
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
      // btnDSBack.OnClick := backBtnDecryptSeed;

    except
      on E: Exception do
      begin
      end;
    end;

  end;

end;

procedure TfrmHome.btnGenSeedClick(Sender: TObject);
var
  alphaStr: AnsiString;
begin
  { if pass.Text <> retypePass.Text then
    begin
    passwordMessage.Text := 'Passwords does not match';
    exit;
    end;
    if pass.Text.length < 5 then
    begin
    popupWindow.Create('Password is too short. Minimum length is 5');
    exit();
    end;

    alphaStr :=
    'You use the alpha version of the HODLER multiwallet, it may be unstable.' +
    ' The current version of the program is used only for functionality tests and for sending feedback.'
    + ' Confirm below that you have understood this message and accept it.';

    popupWindowYesNo.Create(
    procedure
    begin

    TThread.CreateAnonymousThread(
    procedure
    begin
    TThread.Synchronize(nil,
    procedure
    begin }

  // PageControl.ActiveTab := walletDatCreation;

  SetLength(trngBuffer, 4 * 1024);

  // turn on phone's sensors
  // they will be used for collect random data
{$IFDEF ANDROID}
  MotionSensor.Active := true;
  OrientationSensor.Active := true;
{$ENDIF}
  // turn on timer that counts random value from sensors
  gathener.Enabled := true;

  switchTab(PageControl, walletDatCreation);
  { end);
    end).Start;

    end,
    procedure
    begin
    end, alphaStr); }

end;

procedure TfrmHome.btnAddContractClick(Sender: TObject);
var
  t: Token;
begin

  t := Token.CreateCustom(frmHome.ContractAddress.Text,
    frmHome.TokenNameField.Text, frmHome.SymbolField.Text,
    strtoint(frmHome.DecimalsField.Text), walletAddressForNewToken);

  t.idInWallet := length(CurrentAccount.myTokens) + 10000;

  CurrentAccount.addToken(t);
  CurrentAccount.SaveFiles();

  btnSyncClick(nil);

  switchTab(PageControl, TTabItem(frmHome.FindComponent('dashbrd')));

end;

procedure TfrmHome.btnSBackClick(Sender: TObject);
begin
  switchTab(PageControl, TTabItem(frmHome.FindComponent('dashbrd')));
  // PageControl.ActiveTab := TTabItem(frmHome.FindComponent('dashbrd'));
end;

procedure TfrmHome.btnSCBackClick(Sender: TObject);
begin
  switchTab(PageControl, createPassword);
  // PageControl.ActiveTab := createPassword;
end;

procedure TfrmHome.btnANWBackClick(Sender: TObject);
begin
  switchTab(PageControl, TTabItem(frmHome.FindComponent('dashbrd')));
  // PageControl.ActiveTab := Settings;
end;

// checking rewriting seed
procedure TfrmHome.btnConfirmClick(Sender: TObject);
var
  ts: TStringList;
  i: Integer;
begin
  ts := TStringList.Create(); // SplitString(frmHome.Memo1.Text);

  for i := 0 to ConfirmedSeedFlowLayout.ChildrenCount - 1 do
  begin
    ts.Add(TButton(ConfirmedSeedFlowLayout.Children[i]).Text);
  end;
  // showmessage( ts.DelimitedText  );

  if LowerCase(fromMnemonic(ts)) = LowerCase(tempMasterSeed) then
  begin
    tempMasterSeed := ''; // clear     seed can't be saved in var
    // FormShow(nil);

    userSavedSeed := true;
    refreshWalletDat();

    switchTab(PageControl, TTabItem(frmHome.FindComponent('dashbrd')));
  end
  else
  begin
    popupWindow.Create(dictionary['SeedsArentSame']);
  end;

  ts.free;

end;

procedure TfrmHome.btnCSBackClick(Sender: TObject);
begin
  // switchTab(PageControl, seedGenerated);
  PageControl.ActiveTab := seedGenerated;
end;

procedure TfrmHome.RestoreOtherOpiotnsButtonClick(Sender: TObject);
begin

  if restoreOptionsLayout.Visible = false then
  begin
    restoreOptionsLayout.Visible := true;
    OtherOptionsImage.Bitmap := arrowList.Source[1].MultiResBitmap[0].Bitmap;
  end
  else
  begin
    restoreOptionsLayout.Visible := false;
    OtherOptionsImage.Bitmap := arrowList.Source[0].MultiResBitmap[0].Bitmap;
  end;

end;

procedure TfrmHome.switchLegacyp2pkhButtonClick(Sender: TObject);
begin
  receiveAddress.Text := Bitcoin.generatep2pkh
    (TwalletInfo(CurrentCryptoCurrency).pub,
    AvailableCoin[TwalletInfo(CurrentCryptoCurrency).coin].p2pk);

  receiveAddress.Text := cutEveryNChar(4, receiveAddress.Text, ' ');
end;

procedure TfrmHome.switchCompatiblep2shButtonClick(Sender: TObject);
begin
  receiveAddress.Text := Bitcoin.generatep2sh(TwalletInfo(CurrentCryptoCurrency)
    .pub, AvailableCoin[TwalletInfo(CurrentCryptoCurrency).coin].p2sh);

  receiveAddress.Text := cutEveryNChar(4, receiveAddress.Text, ' ');
end;

procedure TfrmHome.SwitchSegwitp2wpkhButtonClick(Sender: TObject);
begin
  receiveAddress.Text := Bitcoin.generatep2wpkh
    (TwalletInfo(CurrentCryptoCurrency).pub);

  receiveAddress.Text := cutEveryNChar(4, receiveAddress.Text, ' ');
end;

procedure TfrmHome.LoadAccountPanelClick(Sender: TObject);
begin
  if OrganizeList.Visible = true then
    closeOrganizeView(nil);
  firstSync := true ;

  LoadCurrentAccount(TfmxObject(Sender).TagString);
end;

procedure TfrmHome.ChangeAccountButtonClick(Sender: TObject);
var
  name: AnsiString;
  fmxObj: TfmxObject;
  Panel: TPanel;
  Button: TButton;
  AccountName: TLabel;
  i: Integer;
  flag: Boolean;
begin

  AccountsListPanel.Visible := not AccountsListPanel.Visible;

  for i := AccountsListVertScrollBox.Content.ChildrenCount - 1 downto 0 do
  begin
    fmxObj := AccountsListVertScrollBox.Content.Children[i];

    flag := false; //
    for name in AccountsNames do
    begin

      if name = fmxObj.TagString then
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

  for name in AccountsNames do
  begin
    flag := true;

    for i := 0 to AccountsListVertScrollBox.Content.ChildrenCount - 1 do
    begin
      fmxObj := AccountsListVertScrollBox.Content.Children[i];

      if name = fmxObj.TagString then
      begin
        flag := false;
        break;

      end;

    end;

    if flag then
    begin

      { Panel := TPanel.Create(frmHome.AccountsListVertScrollBox);
        Panel.Align := TAlignLayout.Top;
        Panel.Height := 48;
        Panel.Visible := true;
        Panel.Parent := frmHome.AccountsListVertScrollBox;
        Panel.TagString := name;
        Panel.OnClick := LoadAccountPanelClick;

        AccountName := TLabel.Create(Panel);
        AccountName.Parent := Panel;
        AccountName.Text := name;
        AccountName.Align := TAlignLayout.Client;
        AccountName.Visible := true; }

      Button := TButton.Create(frmHome.AccountsListVertScrollBox);
      Button.Align := TAlignLayout.Top;
      Button.Height := 48;
      Button.Visible := true;
      Button.Parent := frmHome.AccountsListVertScrollBox;
      Button.TagString := name;
      Button.OnClick := LoadAccountPanelClick;
      Button.Text := name;

    end;

  end;

  AccountsListPanel.Height :=
    min(PageControl.Height - ChangeAccountButton.Height,
    length(AccountsNames) * 48 + 48);

end;

procedure TfrmHome.Button11Click(Sender: TObject);
begin
  switchTab(PageControl, RestoreFromFileTabitem);
end;

procedure TfrmHome.CSBackButtonClick(Sender: TObject);
begin

  switchTab(PageControl, walletView);
end;

procedure TfrmHome.SendTransactionButtonClick(Sender: TObject);
begin

  TrySendTX(Sender);

end;

procedure TfrmHome.Button2Click(Sender: TObject);
var
  List: TStringList;
  Stream: TResourceStream;
  intArr: TIntegerArray;
  checksum: TIntegerArray;
  payload: TCharArray;
  c: Char;
  i: Integer;
  adrInfo: TAddressInfo;
  ac: Account;
  addr: AnsiString;
  hex: AnsiString;
  ans: AnsiString;
  bigInt: BigInteger;
begin

  Edit1.Text := getethValidaddress(Edit4.Text);

end;

procedure TfrmHome.Button3Click(Sender: TObject);
begin
  synchronizeCurrencyValue();
end;

procedure TfrmHome.ImportPrivateKey(Sender: TObject);
var
  ts: TStringList;
  path: AnsiString;
  out : AnsiString;
  wd: TwalletInfo;
  isCompressed: Boolean;
  Data: WIFAddressData;
  pub: AnsiString;

  tced: AnsiString;
  MasterSeed: AnsiString;
begin

  tced := TCA(passwordForDecrypt.Text);
  MasterSeed := SpeckDecrypt(tced, CurrentAccount.EncryptedMasterSeed);
  if not isHex(MasterSeed) then
  begin
    popupWindow.Create(dictionary['FailedToDecrypt']);
    // DecryptSeedMessage.Text := 'Failed to decrypt master seed';
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
    Data := wifToPrivKey(WIFEdit.Text);
    isCompressed := Data.isCompressed;
    out := Data.PrivKey;
  end;
  if ImportCoinID <> 4 then
  begin
    pub := secp256k1_get_public(out , not isCompressed);

    wd := TwalletInfo.Create(ImportCoinID, -1, -1,
      Bitcoin_PublicAddrToWallet(pub, AvailableCoin[ImportCoinID].p2pk),
      'Imported');
    wd.pub := pub;
    wd.EncryptedPrivKey := speckEncrypt((TCA(MasterSeed)), out);
    wd.isCompressed := isCompressed;
  end
  else if ImportCoinID = 4 then
  begin
    pub := secp256k1_get_public(out , true);
    wd := TwalletInfo.Create(ImportCoinID, -1, -1,
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

  switchTab(PageControl, TTabItem(frmHome.FindComponent('dashbrd')));
end;

procedure TfrmHome.IPKBackClick(Sender: TObject);
begin
  switchTab(PageControl, Settings);
end;

procedure TfrmHome.IPKCLBackButtonClick(Sender: TObject);
begin
  switchTab(PageControl, Settings);
end;

procedure TfrmHome.btnACBackClick(Sender: TObject);
begin
  switchTab(PageControl, AddNewCoin);
  // PageControl.ActiveTab := AddNewWallet;
end;

procedure TfrmHome.OrganizeButtonClick(Sender: TObject);
var
  Panel: TPanel;
  fmxObj, child, temp: TfmxObject;

  Button: TButton;

begin

  vibrate(100);
  clearVertScrollBox(OrganizeList);
  // walletlist.Repaint;

  for fmxObj in WalletList.Content.Children do
  begin

    Panel := TPanel.Create(frmHome.OrganizeList);
    Panel.Align := TAlignLayout.Top;
    Panel.Position.Y := TPanel(fmxObj).Position.Y;
    Panel.Height := 48;
    Panel.Visible := true;
    Panel.Parent := frmHome.OrganizeList;
    Panel.TagObject := fmxObj.TagObject;
    Panel.Touch.InteractiveGestures := [TInteractiveGesture.LongTap];

{$IFDEF ANDROID}
    Panel.OnGesture := frmHome.PanelDragStart;
{$ELSE}
    Panel.OnMouseDown := frmHome.PanelDragStart;
{$ENDIF}
    //
    // Panel.OnGesture := frmHome.StartDragPanel;
    // Panel.OnDragDrop := PanelDragDrop;

    // Panel.DragMode := TDragMode.dmAutomatic;

    for child in fmxObj.Children do
    begin
      if child.TagString <> 'balance' then
        temp := child.Clone(Panel);
      temp.Parent := Panel;

    end;
    Button := TButton.Create(Panel);
    Button.Width := Panel.Height;
    Button.Align := TAlignLayout.Mostright;
    Button.Text := 'X';
    // Button.Tag := fmxObj.Tag;
    Button.Visible := true;
    Button.Parent := Panel;
    Button.OnClick := hideWallet;
  end;

  for fmxObj in OrganizeList.Content.Children do
  begin
    // TPanel(fmxObj).Position.Y := TPanel(fmxObj.TagObject).Position.Y - 1;
  end;

  OrganizeList.Repaint;

  switchTab(PageControl, TTabItem(frmHome.FindComponent('dashbrd')));
  DeleteAccountLayout.Visible := true;
  Layout1.Visible := false;

  SearchInDashBrdButton.Visible := false;
  NewCryptoLayout.Visible := false;
  WalletList.Visible := false;
  OrganizeList.Visible := true;
//  BackToBalanceViewButton.Visible := true;
  BackToBalanceViewLayout.Visible :=true;
  btnSync.Visible := false;

end;

procedure TfrmHome.ShowHideAdvancedButtonClick(Sender: TObject);
begin

  TransactionFeeLayout.Visible := not TransactionFeeLayout.Visible;
  TransactionFeeLayout.Position.Y := Layout3.Position.Y + 1;

  if TransactionFeeLayout.Visible then
  begin
    // ShowHideAdvancedIcon.Bitmap := showHideIcons.Source[1].MultiResBitmap[0].Bitmap;
    arrowImg.Bitmap := arrowList.Source[1].MultiResBitmap[0].Bitmap;
    ShowHideAdvancedButton.Text := dictionary['HideAdvanced'];
  end
  else
  begin
    // ShowHideAdvancedIcon.Bitmap := showHideIcons.Source[0].MultiResBitmap[0].Bitmap;
    arrowImg.Bitmap := arrowList.Source[0].MultiResBitmap[0].Bitmap;
    ShowHideAdvancedButton.Text := dictionary['ShowAdvanced'];
  end;

end;

procedure TfrmHome.btnSeedGeneratedProceedClick(Sender: TObject);
var
  tempList: TStringList;
  it: AnsiString;
  Button: TButton;
  maks, i: Integer;
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
  // clearVertScrollBox( SeedWordsBox );
  tempList.Sort;

  for it in tempList do
  begin
    Button := TButton.Create(SeedWordsFlowLayout);
    Button.Text := it;

    // button.Align := TAlignLayout.Top;
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
  // Memo1.Text := '';

  tempList.free;
  switchTab(PageControl, checkSeed);
  // PageControl.ActiveTab := checkSeed;
end;

procedure TfrmHome.btnOKAddNewCoinSettingsClick(Sender: TObject);
var
  MasterSeed, tced: AnsiString;
  walletInfo: TwalletInfo;
  arr: array of Integer;
  wd: TwalletInfo;
  i: Integer;
  newID: Integer;
var
  ts: TStringList;
  path: AnsiString;
  out : AnsiString;
  isCompressed: Boolean;
  Data: WIFAddressData;
  pub: AnsiString;
begin
  i := 0;

  tced := TCA(NewCoinDescriptionPassEdit.Text);
  MasterSeed := SpeckDecrypt(tced, CurrentAccount.EncryptedMasterSeed);
  if not isHex(MasterSeed) then
  begin
    DecryptSeedMessage.Text := dictionary['FailedToDecrypt'];
    exit;
  end;

  if not Switch1.IsChecked then
  begin

    SetLength(arr, CurrentAccount.countWalletBy(newcoinID));
    for wd in CurrentAccount.myCoins do
    begin
      if wd.coin = newcoinID then
      begin
        arr[i] := wd.X;
        inc(i);
      end;
    end;
    newID := i;
    for i := 0 to length(arr) - 1 do
    begin
      if arr[i] <> i then
      begin
        newID := i;
        break;
      end;
    end;

    walletInfo := coindata.createCoin(newcoinID, newID, 0, MasterSeed,
      NewCoinDescriptionEdit.Text);

    CurrentAccount.AddCoin(walletInfo);
    CreatePanel(walletInfo);
    MasterSeed := '';

    switchTab(PageControl, TTabItem(frmHome.FindComponent('dashbrd')));
  end
  else
  begin

    APICheckCompressed(Sender);

    if isHex(WIFEdit.Text) then
    begin
      if (length(WIFEdit.Text) = 64) then
      begin
        if not(HexPrivKeyCompressedRadioButton.IsChecked or
          HexPrivKeyNotCompressedRadioButton.IsChecked) then
          exit;
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
        popupWindow.Create('Private Key must have 64 characters');
        exit;
      end;

    end
    else
    begin
      Data := wifToPrivKey(WIFEdit.Text);
      isCompressed := Data.isCompressed;
      out := Data.PrivKey;
    end;

    pub := secp256k1_get_public(out , not isCompressed);
    if ImportCoinID = 4 then
    begin
      wd := TwalletInfo.Create(ImportCoinID, -1, -1,
        Ethereum_PublicAddrToWallet(pub), NewCoinDescriptionEdit.Text);
      wd.pub := pub;
      wd.EncryptedPrivKey := speckEncrypt((TCA(MasterSeed)), out);
      wd.isCompressed := isCompressed;
    end
    else
    begin
      wd := TwalletInfo.Create(ImportCoinID, -1, -1,
        Bitcoin_PublicAddrToWallet(pub, AvailableCoin[ImportCoinID].p2pk),
        NewCoinDescriptionEdit.Text);
      wd.pub := pub;
      wd.EncryptedPrivKey := speckEncrypt((TCA(MasterSeed)), out);
      wd.isCompressed := isCompressed;

    end;

    CurrentAccount.AddCoin(wd);
    CreatePanel(wd);

    MasterSeed := '';

    if ImportCoinID = 4 then
    begin
      SearchTokens(wd.addr);
    end;

    switchTab(PageControl, TTabItem(frmHome.FindComponent('dashbrd')));

  end;
  btnSyncClick(nil);
end;

procedure TfrmHome.btnChangeDescriptionClick(Sender: TObject);
begin
  ChangeDescryptionEdit.Text := CurrentCryptoCurrency.description;
  switchTab(PageControl, ChangeDescryptionScreen);
  // PageControl.ActiveTab := ChangeDescryptionScreen;
end;

procedure TfrmHome.Button8Click(Sender: TObject);
begin
  switchTab(PageControl, TTabItem(frmHome.FindComponent('dashbrd')));
  // switchTab(PageControl, );
end;

procedure TfrmHome.btnRestoreWalletClick(Sender: TObject);
begin
  { pass.Text := '';
    retypePass.Text := '';
    btnCreateWallet.Text := dictionary['StartRecoveringWallet'];
    procCreateWallet := btnImpSeedClick;
    switchTab(PageControl, createPassword); }

  switchTab(PageControl, RestoreOptions);

end;

procedure TfrmHome.btnRFFBackClick(Sender: TObject);
begin
  switchTab(PageControl, RestoreOptions);
end;

procedure TfrmHome.btnCreateNewWalletClick(Sender: TObject);
begin

  pass.Text := '';
  retypePass.Text := '';
  btnCreateWallet.Text := dictionary['OpenNewWallet'];
  procCreateWallet := btnGenSeedClick;
  switchTab(PageControl, createPassword);

end;

procedure TfrmHome.btnCreateWalletClick(Sender: TObject);
var
  alphaStr: AnsiString;
  c: Char;
  num, low, up: Boolean;
begin
  num := false;
  low := false;
  up := false;
  if pass.Text <> retypePass.Text then
  begin
    passwordMessage.Text := dictionary['PasswordNotMatch'];
    exit;
  end;
  if pass.Text.length < 8 then
  begin

    popupWindow.Create(dictionary['PasswordShort']);
    exit();

  end
  else
  begin

    for c in pass.Text do
    begin
      if isNumber(c) then
        num := true;
      if IsUpper(c) then
        up := true;
      if IsLower(c) then
        low := true;
    end;
    if not(num and up and low) then
    begin
      popupWindow.Create(dictionary['PasswordShort']);
      exit();

    end;

  end;

  if AccountNameEdit.Text = '' then
  begin
    popupWindow.Create(' Your wallet must have name ');
    exit();
  end;

  alphaStr := dictionary['AlphaVersionWarning'];

  popupWindowYesNo.Create(
    procedure
    begin

      tthread.CreateAnonymousThread(
        procedure
        begin
          tthread.Synchronize(nil,
            procedure
            begin

              procCreateWallet(nil);

            end);
        end).Start;

    end,
    procedure
    begin
    end, alphaStr);

end;

procedure TfrmHome.btnChangeDescryptionOKClick(Sender: TObject);
begin
  CurrentCryptoCurrency.description := ChangeDescryptionEdit.Text;
  // refreshWalletDat();
  // repaintWalletList;
  // saveTokensToFile();
  CurrentAccount.SaveFiles();

  switchTab(PageControl, walletView);

  // PageControl.ActiveTab := walletView;
end;

procedure TfrmHome.btnCTBackClick(Sender: TObject);
begin
  switchTab(PageControl, AddNewToken);
  // PageControl.ActiveTab := AddNewToken;
end;

procedure TfrmHome.btnExportPrivKeyClick(Sender: TObject);
begin

  decryptSeedBackTabItem := PageControl.ActiveTab;
  switchTab(PageControl, descryptSeed);
  // PageControl.ActiveTab := descryptSeed;

  btnDSBack.OnClick := backBtnDecryptSeed;

  btnDecryptSeed.OnClick := privateKeyPasswordCheck;

end;

procedure TfrmHome.btnANTBackClick(Sender: TObject);
begin
  // PageControl.ActiveTab := Settings;
  switchTab(PageControl, TTabItem(frmHome.FindComponent('dashbrd')));
end;

procedure TfrmHome.btnEKSBackClick(Sender: TObject);
begin

  // lblPrivateKey.Text := '';
  lblPrivateKey.Text := '';
  WVTabControl.ActiveTab := WVBalance;
  // pageControl.ActiveTab := walletView;
  switchTab(PageControl, walletView);
end;

procedure TfrmHome.btnAddManuallyClick(Sender: TObject);
begin
  switchTab(PageControl, ManuallyToken);
  // PageControl.ActiveTab := ManuallyToken;
end;

procedure TfrmHome.btnMTBackClick(Sender: TObject);
begin
  switchTab(PageControl, ChoseToken);
  // PageControl.ActiveTab := ChoseToken;
end;

procedure TfrmHome.btnSyncClick(Sender: TObject);
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

  if SyncHistoryThr <> nil then
  begin

    if SyncHistoryThr.Finished then
    begin
      SyncHistoryThr.DisposeOf;
      SyncHistoryThr := nil;
      SyncHistoryThr := SynchronizeHistoryThread.Create();
    end
    else if SyncHistoryThr.TimeFromStart() > 1.0 / 1040.0 then
    begin

      SyncHistoryThr.Terminate;
      SyncHistoryThr.WaitFor;
      SyncHistoryThr.DisposeOf;
      SyncHistoryThr := nil;
      SyncHistoryThr := SynchronizeHistoryThread.Create();

    end;

  end;

end;

// Show available ETH wallet during adding new Token
procedure TfrmHome.btnAddNewTokenClick(Sender: TObject);
var
  i: Integer;
  Panel: TPanel;
  adrLabel: TLabel;
  balLabel: TLabel;
  coinIMG: TImage;
  wd: TwalletInfo;
begin

  clearVertScrollBox(frmHome.AvailableCoinsBox);

  for i := 0 to length(CurrentAccount.myCoins) - 1 do
  begin
    if CurrentAccount.myCoins[i].coin = 4 then // if ETH
    begin

      with frmHome.AvailableCoinsBox do
      begin
        wd := CurrentAccount.myCoins[i];
        Panel := TPanel.Create(frmHome.AvailableCoinsBox);
        Panel.Align := Panel.Align.alTop;
        Panel.Height := 48;
        Panel.Visible := true;
        Panel.Parent := frmHome.AvailableCoinsBox;
        Panel.TagString := CurrentAccount.myCoins[i].addr;
        Panel.OnClick := frmHome.addToken;

        adrLabel := TLabel.Create(frmHome.AvailableCoinsBox);
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
        adrLabel.Visible := true;
        adrLabel.Width := 500;
        adrLabel.Height := 48;
        adrLabel.Position.X := 52;
        adrLabel.Position.Y := 0;
        adrLabel.OnClick := frmHome.addToken;

        balLabel := TLabel.Create(frmHome.WalletList);
        balLabel.StyledSettings := balLabel.StyledSettings -
          [TStyledSetting.Size];
        balLabel.TextSettings.Font.Size := 12;
        balLabel.Parent := Panel;
        balLabel.TagString := CurrentAccount.myCoins[i].addr;
        balLabel.Text := CurrentAccount.myCoins[i].addr;

        balLabel.TextSettings.HorzAlign := TTextAlign.center;
        balLabel.Visible := true;
        balLabel.Width := 500;
        balLabel.Height := 14;
        balLabel.Align := TAlignLayout.Bottom;
        balLabel.OnClick := frmHome.addToken;

        coinIMG := TImage.Create(frmHome.AvailableCoinsBox);
        coinIMG.Parent := Panel;

        coinIMG.Bitmap := getCoinIcon(wd.coin);

        coinIMG.Height := 32.0;
        coinIMG.Width := 50;
        coinIMG.Position.X := 4;
        coinIMG.Position.Y := 8;
        coinIMG.OnClick := frmHome.addToken;
        coinIMG.TagString := CurrentAccount.myCoins[i].addr;
      end;

    end;

  end;

  // PageControl.ActiveTab := AddNewToken;
  switchTab(PageControl, AddNewToken);
end;

procedure TfrmHome.btnAddNewCoinClick(Sender: TObject);
begin
  createAddWalletView();

  HexPrivKeyDefaultRadioButton.IsChecked := true;
  Layout31.Visible := false;
  WIFEdit.Text := '';
  PrivateKeySettingsLayout.Visible := false;

  switchTab(PageControl, AddNewCoin);
end;

procedure TfrmHome.btnBackClick(Sender: TObject);
begin
  CurrentCryptoCurrency := nil;
  CurrentCoin := nil;
  switchTab(PageControl, TTabItem(frmHome.FindComponent('dashbrd')));
  // PageControl.ActiveTab := TTabItem(frmHome.FindComponent('dashbrd'));
end;

procedure TfrmHome.btnQRBackClick(Sender: TObject);
begin

  CameraComponent1.Active := false;
  switchTab(PageControl, cameraBackTabItem);
  // PageControl.ActiveTab := cameraBackTabItem;
end;

procedure TfrmHome.btnSendClick(Sender: TObject);
var
  amount, fee: BigInteger;
  Address: AnsiString;
begin

  if not isEthereum then
    fee := StrFloatToBigInteger(wvFee.Text,
      AvailableCoin[CurrentCoin.coin].decimals)
  else
  begin
    if isTokenTransfer then
      fee := BigInteger.Parse(wvFee.Text) * 66666
    else
      fee := BigInteger.Parse(wvFee.Text) * 21000;
  end;

  if (not isTokenTransfer) then
  begin
    amount := StrFloatToBigInteger(wvAmount.Text,
      AvailableCoin[CurrentCoin.coin].decimals);
    if FeeFromAmountSwitch.IsChecked then
    begin
      amount := amount - fee;
    end;

  end;

  if (isEthereum) and (isTokenTransfer) then
    amount := StrFloatToBigInteger(wvAmount.Text,
      CurrentCryptoCurrency.decimals);

  if WVsendTO.Text = '' then
  begin
    popupWindow.Create(dictionary['AddressFieldEmpty']);
    exit;
  end;

  if isBech32Address(WVsendTO.Text) and (CurrentCoin.coin <> 0) then
  begin
    popupWindow.Create(dictionary['Bech32Unsupported']);
    exit;
  end;

  if not isValidForCoin(CurrentCoin.coin, WVsendTO.Text) then
  begin

    popupWindow.Create(dictionary['WrongAddress']);
    exit;
  end;
  if { (not isEthereum) and } (not isTokenTransfer) then
    if amount + fee > (CurrentCoin.confirmed) then
    begin
      popupWindow.Create(dictionary['AmountExceed']);
      exit;
    end;

  Address := removeSpace(WVsendTO.Text);
  if (CurrentCryptoCurrency is TwalletInfo) and
    (TwalletInfo(CurrentCryptoCurrency).coin = 3) and isCashAddress(Address)
  then
  begin
    if isValidBCHCashAddress(Address) then
    begin
      Address := BCHCashAddrToLegacyAddr(Address);
    end
    else
    begin
      popupWindow.Create(dictionary['WrongAddress']);
      exit;
    end;
  end;

  if CurrentCoin.coin = 4 then
  begin
    if not isValidEthAddress(CurrentCoin.addr) then
    begin
      popupWindowYesNo.Create(
        procedure // yes
        begin

        end,
        procedure
        begin // no

          tthread.CreateAnonymousThread(
            procedure
            begin
              tthread.Synchronize(nil,
                procedure
                begin
                  if ValidateBitcoinAddress(Address) then
                  begin
                    { btnDecryptSeed.OnClick := TrySendTX;

                      decryptSeedBackTabItem := PageControl.ActiveTab;
                      // PageControl.ActiveTab := descryptSeed;
                      btnDSBack.OnClick := backBtnDecryptSeed;
                      switchTab(PageControl, descryptSeed); }

                    prepareConfirmSendTabItem();
                    switchTab(PageControl, ConfirmSendTabItem);

                  end;
                end);

            end).Start;

        end, 'This address may be incorrect. Do you want to check again?');
      exit;
    end;
  end;

  if ValidateBitcoinAddress(Address) then
  begin
    // btnDecryptSeed.OnClick := TrySendTX;  /

    // decryptSeedBackTabItem := PageControl.ActiveTab;
    // PageControl.ActiveTab := descryptSeed;
    prepareConfirmSendTabItem();
    switchTab(PageControl, ConfirmSendTabItem);
    // btnDSBack.OnClick := backBtnDecryptSeed;

  end;
  ConfirmSendPasswordEdit.Text := '';
end;

procedure TfrmHome.btnOCRClick(Sender: TObject);
begin

  // .ActiveTab := ReadOCR;
  switchTab(PageControl, ReadOCR);
  CameraComponent1.Active := false;
  CameraComponent1.Kind := FMX.Media.TCameraKind.BackCamera;
  CameraComponent1.Quality := FMX.Media.TVideoCaptureQuality.HighQuality;
  CameraComponent1.FocusMode := FMX.Media.TFocusMode.ContinuousAutoFocus;
  CameraComponent1.Active := true;

end;

procedure TfrmHome.btnReadOCRClick(Sender: TObject);
var
  str: AnsiString;
begin
  CameraComponent1.SampleBufferToBitmap(imgCameraOCR.Bitmap, true);
  str := misc.getStringFromImage(imgCameraOCR.Bitmap);
  str := misc.findAddress(str);

  if str = 'Not found' then
  begin

    frmHome.btnReadOCR.Text := dictionary['ReadAgainOCR'];

  end
  else
  begin

    if not ValidateBitcoinAddress(str) = true then
    begin
      // SendMessage.Text :=
      popupWindowOK.Create(
        procedure
        begin
        end, dictionary['OCRInaccurate']);
    end;

    frmHome.WVsendTO.Text := str;

    PageControl.ActiveTab := walletView;
    switchTab(PageControl, walletView);
    WVTabControl.ActiveTab := WVSend;

  end;

end;

procedure TfrmHome.btnSSysClick(Sender: TObject);
{$IFDEF ANDROID}
var
  Intent: JIntent;
{$ENDIF}
begin
{$IFDEF ANDROID}
  Intent := TJIntent.Create;
  Intent := TJIntent.JavaClass.init(TJSettings.JavaClass.ACTION_SETTINGS);
  TAndroidHelper.Activity.startActivity(Intent);
{$ENDIF}
end;

procedure TfrmHome.CameraComponent1SampleBufferReady(Sender: TObject;
const ATime: TMediaTime);
begin
  tthread.Synchronize(tthread.CurrentThread, GetImage);
end;
{$IFDEF VANDROID}

function FindQRRect(Bitmap: TImage): TRectF;
{$ELSE}

function FindQRRect(Bitmap: TBitmap): TRectF;
{$ENDIF}
var
  shorter: Integer;
  a: Integer;
begin
  if Bitmap.Width > Bitmap.Height then
    shorter := ceil(Bitmap.Height)
  else
    shorter := ceil(Bitmap.Width);

  a := (shorter - ceil(shorter * 0.4));
  if shorter = Bitmap.Width then
  begin

    result.Left := ceil(shorter * 0.2);
    result.Right := shorter - ceil(shorter * 0.2);
    result.Top := (Bitmap.Height - a) / 2;
    result.Bottom := Bitmap.Height - ((Bitmap.Height - a) / 2);
  end
  else
  begin
    result.Top := ceil(shorter * 0.2);
    result.Bottom := shorter - ceil(shorter * 0.2);
    result.Left := (Bitmap.Width - a) / 2;
    result.Right := Bitmap.Width - ((Bitmap.Width - a) / 2);

  end;

end;

procedure TfrmHome.GetImage;
var
  scanBitmap: TBitmap;
  tempBitmap: TBitmap;
  ReadResult: TReadResult;
  QRRect: TRectF;
  ts: TStringList;
  scale: double;
  ac: Account;

begin
  if PageControl.ActiveTab = ReadOCR then
  begin
    CameraComponent1.SampleBufferToBitmap(imgCameraOCR.Bitmap, true);
    exit;
  end;
  CameraComponent1.SampleBufferToBitmap(imgCamera.Bitmap, true);
  // {$IFDEF VANDROID}
  // QRRect := FindQRRect(imgCamera);
  // {$ELSE}
  // QRRect := FindQRRect(imgCamera.Bitmap);
  // {$ENDIF}
  scanBitmap := TBitmap.Create();
  scanBitmap.Assign(imgCamera.Bitmap);

  // scanBitmap := imgCamera.Bitmap;

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
            tthread.Synchronize(nil,
              procedure
              begin
                // lblScanStatus.Text := E.Message;
              end);

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
              // if ValidateBitcoinAddress(Trim(ReadResult.Text)) then
              // begin
              // WVsendTO.Text := Trim(ReadResult.Text);
              // showmessage(ReadResult.text);

              { if currentWallet < 0 then
                begin
                btnQRBack.OnClick(nil);
                ShowMSG(PageControl.ActiveTab,
                'Address ' + Trim(ReadResult.Text) +
                ' copied to transaction window');                 //   Nie ma przycisku QR w widoku głównym
                btnSMVNo.Visible := false;
                btnSMVYes.Text := 'OK';
                btnSMVYes.Align := btnSMVYes.Align.alCenter;
                end
                else
                begin }
              // btnQRBack.OnClick(nil);
              if cameraBackTabItem = walletView then
              begin

                ts := parseQRCode(ReadResult.Text);

                if ts.Count = 1 then
                begin
                  WVsendTO.Text := ts.Strings[0];
                end
                else
                begin
                  if ts.Strings[0] <> AvailableCoin[CurrentCoin.coin].name then
                  begin
                    popupWindow.Create(dictionary['QRCodeFor'] + ' ' +
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
                // PageControl.ActiveTab := cameraBackTabItem;
              end
              else if cameraBackTabItem = ManuallyToken then
              begin
                ContractAddress.Text := Trim(ReadResult.Text);
                // PageControl.ActiveTab := cameraBackTabItem;
                switchTab(PageControl, cameraBackTabItem);
              end
              else if cameraBackTabItem = checkSeed then
              begin
                if tempMasterSeed = Trim(ReadResult.Text) then
                begin

                  tempMasterSeed := '';

                  userSavedSeed := true;
                  refreshWalletDat();

                  switchTab(PageControl,
                    TTabItem(frmHome.FindComponent('dashbrd')));

                end
                else
                begin
                  switchTab(PageControl,
                    TTabItem(frmHome.FindComponent('dashbrd')));
                  // popupWindow.Create( 'Wrong QR code' );
                end;

              end
              else if (cameraBackTabItem = RestoreOptions) or
                (cameraBackTabItem = AddAccount) then
              begin

                if QRFind = QRSearchEncryted then
                begin

                  QRFind := '';

                  tempQRFindEncryptedSeed := Trim(ReadResult.Text);

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
                    Trim(ReadResult.Text), true);

                end;

              end
              else if cameraBackTabItem = ImportPrivKeyTabItem then
              begin
                WIFEdit.Text := ReadResult.Text;
                switchTab(PageControl, ImportPrivKeyTabItem);
              end
              else if cameraBackTabItem = TTabItem(frmHome.FindComponent
                ('dashbrd')) then
              begin
                // PageControl.ActiveTab := cameraBackTabItem;
                switchTab(PageControl, cameraBackTabItem);
              end;

              CameraComponent1.Active := false;

              // PageControl.ActiveTab := walletView;
              // switchTab(PageControl, walletView);
              // WVTabControl.ActiveTab := WVSend;

              // end;
              // end
              { else
                begin


                ShowMSG(PageControl.ActiveTab, 'This is not a valid address:' +
                #13#10 + Copy(Trim(ReadResult.Text), 0, 42));
                btnSMVNo.Visible := false;
                btnSMVYes.Text := 'OK';
                btnSMVYes.Align := btnSMVYes.Align.alCenter;
                end; }
            end;
          end);

      finally
        ReadResult.free;
        scanBitmap.free;
        FScanInProgress := false;
      end;
      // CameraComponent1.FlashMode.fmFlashoff;

    end).Start;

end;

procedure TfrmHome.RestoreFromEncryptedQR(Sender: TObject);
var
  MasterSeed, tced: AnsiString;
  ac: Account;
begin

  tced := TCA(RestorePasswordEdit.Text);
  MasterSeed := SpeckDecrypt(tced, tempQRFindEncryptedSeed);
  if not isHex(MasterSeed) then
  begin
    popupWindow.Create(dictionary['FailedToDecrypt']);
    exit;
  end;

  CreateNewAccountAndSave(RestoreNameEdit.Text, RestorePasswordEdit.Text,
    MasterSeed, true);

  tced := '';
  MasterSeed := '';

end;

procedure TfrmHome.FeeSpinChange(Sender: TObject);
begin
  if not isEthereum then
  begin
    wvFee.Text := CurrentCoin.efee[round(FeeSpin.Value) - 1];
    lblBlockInfo.Text := dictionary['ConfirmInNext'] + ' ' +
      IntToStr(round(FeeSpin.Value)) + ' ' + dictionary['Blocks'];
  end
  else
    FeeSpin.Value := 1.0;
end;

procedure TfrmHome.FeeToUSDUpdate(Sender: TObject);
begin
  if isTokenTransfer then
  begin
    lblFeeHeader.Text := dictionary['GasPriceWEI'] + ': ';
    lblFee.Text := wvFee.Text + ' ' +
      floatToStrF(CurrencyConverter.calculate(strToFloatDef(wvFee.Text,
      0) * 66666 * CurrentCryptoCurrency.rate / (1000000.0 * 1000000.0 *
      1000000.0)), ffFixed, 18, 6) + ' ' + CurrencyConverter.symbol;
  end
  else if isEthereum then
  begin
    lblFeeHeader.Text := dictionary['GasPriceWEI'] + ': ';
    lblFee.Text := wvFee.Text + ' ' + AvailableCoin[CurrentCoin.coin].shortcut +
      ' = ' + floatToStrF(CurrencyConverter.calculate(strToFloatDef(wvFee.Text,
      0) * CurrentCoin.rate * 21000 / (1000000.0 * 1000000.0 * 1000000.0)),
      ffFixed, 18, 6) + ' ' + CurrencyConverter.symbol;
  end
  else
  begin
    lblFeeHeader.Text := dictionary['TransactionFee'] + ': ';
    lblFee.Text := wvFee.Text + ' ' + AvailableCoin[CurrentCoin.coin].shortcut +
      ' = ' + floatToStrF(CurrencyConverter.calculate(strToFloatDef(wvFee.Text,
      0) * CurrentCoin.rate), ffFixed, 18, 6) + ' ' + CurrencyConverter.symbol;
  end;
end;

procedure TfrmHome.FormCloseQuery(Sender: TObject; var CanClose: Boolean);
begin
{$IFDEF WIN32 or WIN64}
  stylo.Destroy;

{$ENDIF}
end;

procedure TfrmHome.FormCreate(Sender: TObject);
var
  i: Integer;
  symbol: AnsiString;

begin
  DebugBtn.Visible := false;
  log.d('DEBUD Start FormCreate()');
  loadDictionary(loadLanguageFile('ENG'));
  refreshComponentText();
  log.d('DEBUD Language Loaded');
  Randomize;

  saveSeedInfoShowed := false;
  FormatSettings.DecimalSeparator := '.';
  shown := false;
  CurrentCoin := nil;
  CurrentCryptoCurrency := nil;
  QRChangeTimer.Enabled := true;
  TCAIterations := 5000;

  FFrameTake := 0;
  log.d('DEBUD Style Loaded');
  stylo := TStyleManager.Create;
  stylo.TrySetStyleFromResource('RT_DARK');
  // CameraComponent1.Quality := FMX.Media.TVideoCaptureQuality.MediumQuality;
  FScanManager := TScanManager.Create(TBarcodeFormat.QR_CODE, nil);
  duringSync := false;

  // SyncBalanceThr := SynchronizeBalanceThread.Create();
  // SyncHistoryThr := SynchronizeHistoryThread.Create();

  WVsendTO.Caret.Width := 2;
  LanguageBox.ItemIndex := 0;
  log.d('DEBUD Start Load Currenty Converter');

  CurrencyConverter := tCurrencyConverter.Create();
  if FileExists(System.IOUtils.TPath.Combine
    (System.IOUtils.TPath.GetDocumentsPath, 'hodler.fiat.dat')) then
    LoadCurrencyFiatFromFile();
  log.d('DEBUD Parse fiat.dat');
  for symbol in CurrencyConverter.availableCurrency.Keys do
  begin
    CurrencyBox.Items.Add(symbol);
  end;
  log.d('DEBUD Refresh Currency Value');

  CurrencyBox.ItemIndex := CurrencyBox.Items.IndexOf('USD');
  refreshCurrencyValue;

  // CurrentAccount := Account.Create('default');
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
  // OrganizeButton.Visible := true;
  btnSSys.Visible := false;

{$ELSE}

  // RegisterDelphiNativeMethods();

{$ENDIF}
  DeleteAccountLayout.Visible := false;
  BackToBalanceViewLayout.Visible := false;

end;

procedure TfrmHome.FormGesture(Sender: TObject;
const EventInfo: TGestureEventInfo; var Handled: Boolean);
begin
  // ScrollBoxGesture(Sender,EventInfo,Handled);
end;

{$IFDEF ANDROID}

procedure OnRequestPermissionsResultNative(AEnv: PJNIEnv; AThis: JNIObject;
requestCode: Integer; permissions: JNIObjectArray; granted: JNIIntArray);
var
  i: Integer;
  { LPermissionsArray: TJavaObjectArray<JString>;
    LGrantedArray: TJavaArray<Integer>;
    LPermissions: TPermissionResults;
    I: Integer; }
begin

  tthread.CreateAnonymousThread(
    procedure
    begin
      tthread.Synchronize(nil,
        procedure
        begin
          showmessage('OK');
        end);
    end).Start;

  { // A bug in JNI Bridge means we get a (harmless) logcat here for each
    // WrapJNIArray call as a GlobalRef is deleted as if it were a LocalRef:
    // W/art: Attempt to remove non-JNI local reference, dumping thread
    LGrantedArray := TJavaArray<Integer>.Wrap(WrapJNIArray(granted, TypeInfo(TJavaArray<Integer>)));
    LPermissionsArray := TJavaObjectArray<JString>.Wrap(WrapJNIArray(permissions, TypeInfo(TJavaObjectArray<JString>)));
    if (LGrantedArray.Length > 0) and (LPermissionsArray.Length > 0) and (LGrantedArray.Length = LPermissionsArray.Length) then
    begin
    SetLength(LPermissions, LGrantedArray.Length);
    for I := 0 to LGrantedArray.Length - 1 do
    begin
    LPermissions[I].Granted := LGrantedArray.Items[I] = TJPackageManager.JavaClass.PERMISSION_GRANTED;
    LPermissions[I].Permission := JStringToString(LPermissionsArray.Items[I]);
    end;
    TThread.Queue(nil,
    procedure
    begin
    TOpenSystemHelper(FInstance.SystemHelper).DoPermissionsResult(requestCode, LPermissions);
    end);
    end; }
end;

procedure TfrmHome.RegisterDelphiNativeMethods();
var
  PEnv: PJNIEnv;
  ActivityClass: JNIClass;
  NativeMethod: JNINativeMethod;
begin
  PEnv := TJNIResolver.GetJNIEnv;
  NativeMethod.name := 'onRequestPermissionsResultNative';
  NativeMethod.Signature := '(I[Ljava/lang/String;[I)V';
  // Integer, String [], Integer[] (VOID)
  NativeMethod.FnPtr := @OnRequestPermissionsResultNative;
  ActivityClass := PEnv^.GetObjectClass(PEnv,
    PANativeActivity(System.DelphiActivity).clazz);
  PEnv^.RegisterNatives(PEnv, ActivityClass, @NativeMethod, 1);
  PEnv^.DeleteLocalRef(PEnv, ActivityClass);
end;

{$ENDIF}

procedure TfrmHome.FormKeyUp(Sender: TObject; var Key: Word; var KeyChar: Char;
Shift: TShiftState);
var
  FService: IFMXVirtualKeyboardService;
begin
  if Key = vkHardwareBack then
  begin
    Key := 0;
    TPlatformServices.Current.SupportsPlatformService
      (IFMXVirtualKeyboardService, IInterface(FService));

    if (FService <> nil) and (TVirtualKeyboardState.Visible
      in FService.VirtualKeyBoardState) then
    begin
      Key := 0;
      FService.HideVirtualKeyboard;
    end
    else
    begin

      if (PageControl.ActiveTab = createPassword) or
        (PageControl.ActiveTab = SeedCreation) then
      begin
        switchTab(PageControl, WelcomeTabItem);
      end
      else if PageControl.ActiveTab = walletDatCreation then
      begin
{$IFDEF ANDROID}
        SharedActivity.moveTaskToBack(true);
{$ENDIF}
      end
      else if PageControl.ActiveTab = QRReader then
      begin
        switchTab(PageControl, cameraBackTabItem);
      end
      else if (PageControl.ActiveTab = TTabItem(frmHome.FindComponent('dashbrd')
        )) or (CurrentAccount = nil) then
      begin
        { MessageDlg('Exit HODLER?', TMsgDlgType.mtConfirmation,
          [TMsgDlgBtn.mbOK, TMsgDlgBtn.mbCancel], -1, OnCloseDialog); }
{$IFDEF ANDROID}
        if not SYSTEM_APP then
          SharedActivity.finish;
{$ELSE}
        frmHome.Close();
{$ENDIF}
      end
      else
      begin
        switchTab(PageControl, TTabItem(frmHome.FindComponent('dashbrd')));
      end;
    end;
  end;
end;

procedure TfrmHome.OnCloseDialog(Sender: TObject; const AResult: TModalResult);
begin
  if AResult = mrOk then
    Close;
end;

procedure TfrmHome.FormMouseMove(Sender: TObject; Shift: TShiftState;
X, Y: Single);
begin
  if gathener.Enabled then

    trngBuffer := trngBuffer + floattoStr(X * random($FFFF) * trngBufferCounter)
      + floattoStr(Y * random($FFFF)) + IntToStr(random($FFFFFFFF))
end;

procedure TfrmHome.FormResize(Sender: TObject);
begin
{$IFDEF WIN32 or WIN64}
  // FIREMONKEY DOES NOT HAVE FORM CONSTRAITS
  if frmHome.ClientWidth <> 384 then
    frmHome.ClientWidth := 384;
  if frmHome.ClientHeight <> 567 then
    frmHome.ClientHeight := 567;
{$ENDIF}
end;

procedure LoadCurrentAccount(name: AnsiString);
var
  cc: CryptoCurrency;
  fmxObj: TfmxObject;
begin

  if not(frmHome.AccountsListVertScrollBox.Content.ChildrenCount = 0) then
  begin

    for fmxObj in frmHome.AccountsListVertScrollBox.Content.Children do
      if TButton(fmxObj).Text = name then
        TButton(fmxObj).Enabled := false
      else
        TButton(fmxObj).Enabled := true;
  end;

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

  CurrentAccount := Account.Create(name);
  CurrentAccount.LoadFiles;

  for cc in CurrentAccount.myCoins do
    CreatePanel(cc);

  for cc in CurrentAccount.myTokens do
    CreatePanel(cc);

  refreshOrderInDashBrd();

  frmHome.CurrencyBox.ItemIndex := frmHome.CurrencyBox.Items.IndexOf
    (CurrencyConverter.symbol);

  globalFiat := 0;

  refreshCurrencyValue;

  SyncBalanceThr := SynchronizeBalanceThread.Create();
  SyncHistoryThr := SynchronizeHistoryThread.Create();

  if (CurrentAccount.userSaveSeed = false) then
  begin
    tthread.CreateAnonymousThread(
      procedure
      begin

        sleep(1000);

        tthread.Synchronize(nil,
          procedure
          begin

            with frmHome do
              popupWindowYesNo.Create(
                procedure()
                begin

                  btnDecryptSeed.OnClick := SendWalletFile;

                  decryptSeedBackTabItem := PageControl.ActiveTab;
                  PageControl.ActiveTab := descryptSeed;
                  // switchTab(PageControl, descryptSeed);
                  btnDSBack.OnClick := backBtnDecryptSeed;

                end,
                procedure()
                begin

                end, dictionary['CreateBackupWallet'], dictionary['Yes'],
                dictionary['NotNow'], 1);
          end);
      end).Start;

    saveSeedInfoShowed := true;
  end;

  refreshWalletDat;

end;

procedure TfrmHome.FormShow(Sender: TObject);
var
  i: Integer;
  cc: CryptoCurrency;

begin

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
    // PageControl.ActiveTab := createPassword;
    // if CurrentAccount = nil then
    // CurrentAccount := Account.Create('default');
    lblWelcomeDescription.Text := dictionary['ConfigurationTakeOneStep'] +
      #13#10 + dictionary['ChooseOption'] + ':';
    switchTab(PageControl, WelcomeTabItem);
  end
  else
  begin

    // if CurrentAccount <> nil then
    // CurrentAccount.free();
    log.d('DEBUD Start Load account');
    if (lastClosedAccount = '') then
      lastClosedAccount := AccountsNames[0];

    ChangeAccountButton.Text := lastClosedAccount;

    try
      LoadCurrentAccount(lastClosedAccount);
    except
      on E: Exception do
      begin
        showmessage('account file damaged');
        exit;
      end;
    end;

    log.d('DEBUD Account loaded');

    switchTab(PageControl, TTabItem(frmHome.FindComponent('dashbrd')));

  end;

  if not shown then
  begin
    log.d('DEBUD Start Loading Style');

    if CurrentAccount <> nil then
      tthread.Synchronize(nil,
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

procedure TfrmHome.FormVirtualKeyboardHidden(Sender: TObject;
KeyboardVisible: Boolean; const Bounds: TRect);
var
  FService: IFMXVirtualKeyboardService;
  X: Integer;
begin
  X := (round(frmHome.Height * 0.5));
  PageControl.Height := frmHome.Height;
  ScrollBox.Height := frmHome.Height;
  frmHome.ScrollBox.Align := TAlignLayout.Client;
  frmHome.PageControl.Align := TAlignLayout.Client;
  KeyBoardLayout.Visible := false;
  KeyBoardLayout.Height := 0;
  frmHome.PageControl.Repaint;
  frmHome.ScrollBox.Align := TAlignLayout.Client;
  ScrollBox.RealignContent;
  frmHome.realign;
  ScrollBox.ShowScrollBars := false;
  ScrollBox.ViewportPosition := PointF(0, 0);
end;

procedure TfrmHome.FormVirtualKeyboardShown(Sender: TObject;
KeyboardVisible: Boolean; const Bounds: TRect);
var
  FService: IFMXVirtualKeyboardService;
  FToolbarService: IFMXVirtualKeyBoardToolbarService;
  X, Y: Integer;
begin
  { TPlatformServices.Current.SupportsPlatformService( IFMXVirtualKeyBoardToolbarService , IInterface(FToolbarService));
    if FToolbarservice <> nil then
    begin
    FToolbarService.SetToolbarEnabled(false);
    end; }

  if focused is TEdit then
    if (TEdit(focused).name = 'wvAddress') or
      (TEdit(focused).name = 'receiveAddress') then
    begin

      exit;
    end;
  X := (round(frmHome.Height * 0.5));
  KeyBoardLayout.Height := frmHome.Height + X;
  // frmHome.Height := frmHome.Height + x;
  frmHome.ScrollBox.Align := TAlignLayout.None;
  PageControl.Align := ScrollBox.Align;
  KeyBoardLayout.Parent := frmHome;
  KeyBoardLayout.Align := TAlignLayout.Bottom;
  frmHome.ScrollBox.Content.Height := frmHome.Height + X;
  PageControl.Height := frmHome.Height + X;
  KeyBoardLayout.Visible := true;
  frmHome.realign;
  frmHome.PageControl.Repaint;
  KeyBoardLayout.Repaint;
  ScrollBox.RealignContent;
  // showmessage('open');
  ScrollBox.ShowScrollBars := true;
  ScrollBox.RecalcAbsoluteNow;
  ScrollBox.AutoHide := false;
  ScrollBox.StyleName := 'xxxxxxxxxx';
  for X := 0 to ScrollBox.ComponentCount - 1 do
  begin
    TControl(ScrollBox.Components[X]).Touch.InteractiveGestures :=
      [TInteractiveGesture.Pan];
    if TControl(ScrollBox.Components[X]).ComponentCount > 0 then
      for Y := 0 to ScrollBox.ComponentCount - 1 do
      begin
        TControl(ScrollBox.Components[X].Components[Y])
          .Touch.InteractiveGestures := [TInteractiveGesture.Pan];
      end;
  end;
  // ScrollBox.ScrollBy(0,TControl(focused).LocalToAbsolute(PointF(0,0)).Y);
  { if (PageControl.ActiveTab=WalletView) and (WVTabControl.ActiveTab=WVSend) then
    ScrollBox.ViewportPosition :=
    PointF(0, TControl(focused).LocalToAbsolute(PointF(0, 0)).Y); }
end;

procedure TfrmHome.gathenerTimer(Sender: TObject);
var
  i: Integer;
  ac: Account;
begin
  inc(trngBufferCounter);
  // colecting random data for seed generator
  trngBuffer := trngBuffer + GetSTrHashSHA256(inttohex(random($FFFFFFFF), 8) +
    DateTimeToStr(Now));
{$IFDEF ANDROID}
  if MotionSensor.Sensor <> nil then
    with MotionSensor.Sensor do
    begin
      trngBuffer := trngBuffer + floattoStr(Speed);
      trngBuffer := trngBuffer + floattoStr(AccelerationX);
      trngBuffer := trngBuffer + floattoStr(AccelerationY);
      trngBuffer := trngBuffer + floattoStr(AccelerationZ);
      trngBuffer := trngBuffer + floattoStr(Motion);
    end;
  if OrientationSensor.Sensor <> nil then
    with OrientationSensor.Sensor do
    begin

      trngBuffer := trngBuffer + floattoStr(TiltZ);
      trngBuffer := trngBuffer + floattoStr(HeadingX);
      trngBuffer := trngBuffer + floattoStr(HeadingY);
      trngBuffer := trngBuffer + floattoStr(HeadingZ);
      trngBuffer := trngBuffer + floattoStr(TiltY);
    end;
{$ENDIF}
  GenerateSeedProgressBar.Value := trngBufferCounter div 2;

  if trngBufferCounter mod 20 = 0 then
  begin
    trngBuffer := GetSTrHashSHA256(trngBuffer);
    labelForGenerating.Text := trngBuffer;
  end;
  if trngBufferCounter mod 200 = 0 then
  begin
    // 10sec of gathering random data should be enough to get unique seed
    trngBuffer := GetSTrHashSHA256(trngBuffer + IntToStr(random($FFFFFFFF)));
    gathener.Enabled := false;

    // PageControl.ActiveTab := seedGenerated;


    // switchTab(PageControl, seedGenerated);
    // BackupMemo.Lines.Clear;
    // .Lines.Add('Master seed:');
    // BackupMemo.Lines.Add(cutEveryNChar(4 , trngBuffer));
    // BackupMemo.Lines.Add('Masterseed mnemonic:');
    // BackupMemo.Lines.Add(toMnemonic(trngBuffer));
    // for I := 0 to 3 do
    // BackupMemo.Lines.Add(cutEveryNChar(4 , MidStr(trngBuffer , Low(trngBuffer) + i*16 , 16)));

    // tempMasterSeed := trngBuffer;
    // temporary variable     tempMasterSeed is reset  after use

    if swForEncryption.IsChecked then
      TCAIterations := 10000;

    // if not isWalletDatExists then
    // createWalletDat(trngBuffer, pass.Text);

    CreateNewAccountAndSave(AccountNameEdit.Text, pass.Text, trngBuffer, false);


    // FormShow(nil);

  end;

end;

procedure TfrmHome.Image1Click(Sender: TObject);
begin
  btnSyncClick(nil);
end;

procedure TfrmHome.ImageControl4Click(Sender: TObject);
{$IFDEF ANDROID}
var
  Intent: JIntent;
{$ENDIF}
begin
{$IFDEF ANDROID}
  Intent := TJIntent.Create;
  Intent := TJIntent.JavaClass.init(TJSettings.JavaClass.ACTION_SETTINGS);
  TAndroidHelper.Activity.startActivity(Intent);
{$ENDIF}
end;

procedure TfrmHome.ImportPrivateKeyButtonClick(Sender: TObject);
begin
  //creatImportPrivKeyCoinList();

  HexPrivKeyDefaultRadioButton.IsChecked := true;
  Layout31.Visible := false;
  WIFEdit.Text := '';

  switchTab(PageControl, ImportPrivKeyCoinList);
end;

procedure TfrmHome.LinkLayoutClick(Sender: TObject);
var
  wd: TwalletInfo;
  tt: Token;
  myURI: AnsiString;
{$IFDEF ANDROID}
  Intent: JIntent;

{$ENDIF}
begin
  if CurrentCryptoCurrency is TwalletInfo then
  begin
    wd := TwalletInfo(CurrentCryptoCurrency);

    case wd.coin of
      0:
        myURI := 'https://www.blockchain.com/btc/tx/';
      1:
        myURI := 'http://explorer.litecoin.net/tx/';
      2:
        myURI := 'https://chainz.cryptoid.info/dash/tx.dws?';
      3:
        myURI := 'https://blockchair.com/bitcoin-cash/transaction/';
      4:
        myURI := 'https://etherscan.io/tx/';

    end;

  end
  else
    myURI := myURI + 'https://etherscan.io/tx/';
  // StringReplace(result, '-.', '-0.', [rfReplaceAll])

  myURI := getURLToExplorer(CurrentCoin.coin,
    StringReplace(HistoryTransactionID.Text, ' ', '', [rfReplaceAll]));

  // myURI := myURI + StringReplace(HistoryTransactionID.Text, ' ', '',
  // [rfReplaceAll]);

{$IFDEF ANDROID}
  Intent := TJIntent.Create;
  Intent.setAction(TJIntent.JavaClass.ACTION_VIEW);
  Intent.setData(StrToJURI(myURI));
  SharedActivity.startActivity(Intent);
{$ENDIF ANDROID}
end;

procedure TfrmHome.closeVirtualKeyBoard(Sender: TObject);

var
  FService: IFMXVirtualKeyboardService;
begin

  TPlatformServices.Current.SupportsPlatformService(IFMXVirtualKeyboardService,
    IInterface(FService));
  if FService <> nil then
  begin
    FService.HideVirtualKeyboard();
  end;

end;

procedure TfrmHome.Panel1Click(Sender: TObject);
var
  i: Integer;
begin

end;

procedure TfrmHome.Panel1DragDrop(Sender: TObject; const Data: TDragObject;
const Point: TPointF);
begin
  TPanel(Sender).Position.X := Point.X;
  TPanel(Sender).Position.Y := Point.Y;
end;

procedure TfrmHome.Panel1DragOver(Sender: TObject; const Data: TDragObject;
const Point: TPointF; var Operation: TDragOperation);
begin
  Operation := TDragOperation.Move;
end;

procedure TfrmHome.SwitchVWPrecision(Sender: TObject);
begin
  BalancePanel.Visible := not flagWVPrecision;
  LongBalancePanel.Visible := flagWVPrecision;
  flagWVPrecision := not flagWVPrecision;
end;

procedure TfrmHome.syncTimerTimer(Sender: TObject);
begin
  try
    btnSync.OnClick(self);
  except
    on E: Exception do
    begin
      //
    end;

  end;
end;

procedure TfrmHome.SystemTimerTimer(Sender: TObject);
begin
{$IFDEF ANDROID}
  if isScreenOn then
  begin
    OfflineMode(0);

    TLabel(frmHome.FindComponent('HeaderLabel')).Text := 'Online';
  end
  else
  begin
    OfflineMode(1);
    TLabel(frmHome.FindComponent('HeaderLabel')).Text := 'Offline';
  end;
{$ENDIF}
end;

(*procedure TfrmHome.QRChangeTimerTimer(Sender: TObject);
var
  Local_Row: Integer;
  Local_Column: Integer;
  vPixelB: Integer;
  vPixelW: Integer;
  QRCode: TDelphiZXingQRCode;
  QRCodeBitmap: TBitmapData;
  Row: Integer;
  bmp: FMX.Graphics.TBitmap;
  Column: Integer;
  ms: TMemoryStream;
  bmp2: FMX.Graphics.TBitmap;
  DestW: Int64;
  DestH: Int64;
  pixW: Int64;
  pixH: Int64;
  j: Integer;
  currentRow: Int64;
  k: Int64;
  currentCol: Int64;
  X, Y: Integer;
  rsrc, rDest: TRectF;
  s: AnsiString;
begin

  vPixelB := TAlphaColorRec.Black;
  // determine colour to use
  vPixelW := TAlphaColorRec.white;
  // determine colour to use
  QRCode := TDelphiZXingQRCode.Create();

  try

    bmp := FMX.Graphics.TBitmap.Create();
    s := {$IFDEF ANDROID}'  ' +
{$ENDIF}AvailableCoin[CurrentCoin.coin].name + ':' +
      StringReplace(receiveAddress.Text, ' ', '', [rfReplaceAll]) + '?amount=' +
      ReceiveValue.Text + '&message=hodler';

    QRCode.Data := s;

    QRCode.Encoding := TQRCodeEncoding(0);
    QRCode.QuietZone := 6;

    bmp.SetSize(QRCode.Rows, QRCode.Columns);

    if bmp.Map(TMapAccess.maReadWrite, QRCodeBitmap) then
    begin

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

      // QRCodeBitmap.
      bmp.free;
      bmp := BitmapDataToScaledBitmap(QRCodeBitmap, 6);
      bmp.Unmap(QRCodeBitmap);
    end;
  finally
    QRCode.free;
  end;

  QRCodeImage.Bitmap := bmp;

  try
    // if ms <> nil then
    // ms.Free;
    if bmp <> nil then
      bmp.free;
    // if bmp2 <> nil then
    // bmp2.Free;
  except

  end;

  if ReceiveValue.IsFocused then
  begin
    if ReceiveValue.Text = '' then
    begin
      ReceiveAmountRealCurrency.Text := '0.00';
    end
    else
    begin
      ReceiveAmountRealCurrency.Text :=
        floatToStrF((strToFloat(ReceiveValue.Text) * CurrencyConverter.calculate
        (CurrentCryptoCurrency.rate)), ffFixed, 18, 2);
    end;

  end;

end; *)

procedure TfrmHome.receiveAddressChange(Sender: TObject);
begin
  //
  QRChangeTimerTimer(nil);
end;

procedure TfrmHome.ReceiveAmountRealCurrencyChange(Sender: TObject);
begin
  ReceiveAmountRealCurrency.Text :=
    StringReplace(ReceiveAmountRealCurrency.Text, ',', '.', [rfReplaceAll]);
end;

procedure TfrmHome.ReceiveAmountRealCurrencyClick(Sender: TObject);
begin
  if strToFloatDef(ReceiveAmountRealCurrency.Text, 0) = 0 then
    ReceiveAmountRealCurrency.Text := '';
end;

procedure TfrmHome.ReceiveAmountRealCurrencyExit(Sender: TObject);
begin
  if ReceiveAmountRealCurrency.Text = '' then
    ReceiveAmountRealCurrency.Text := '0.00';
end;

procedure TfrmHome.ReceiveReatToCoin(Sender: TObject);
begin
  if ReceiveAmountRealCurrency.IsFocused then
  begin

    if ReceiveAmountRealCurrency.Text = '' then
    begin
      ReceiveValue.Text := BigIntegertoFloatStr(0,
        CurrentCryptoCurrency.decimals);
    end
    else
    begin
      ReceiveValue.Text :=
        floatToStrF((strToFloatDef(ReceiveAmountRealCurrency.Text,
        0) / CurrencyConverter.calculate(CurrentCryptoCurrency.rate)), ffFixed,
        18, CurrentCryptoCurrency.decimals);
    end;

  end;
end;

procedure TfrmHome.ReceiveValueChange(Sender: TObject);
begin
  ReceiveValue.Text := StringReplace(ReceiveValue.Text, ',', '.',
    [rfReplaceAll]);
end;

procedure TfrmHome.ReceiveValueClick(Sender: TObject);
begin
  if strToFloatDef(ReceiveValue.Text, 0) = 0 then
    ReceiveValue.Text := '';
end;

procedure TfrmHome.SearchEditChange(Sender: TObject);
begin
  if SearchEdit.Text = '' then
    SearchEdit.Visible := false;
end;

procedure TfrmHome.SearchEditChangeTracking(Sender: TObject);
var
  fmxObj: TfmxObject;
  Panel: TPanel;
  lbl: TLabel;
  i: Integer;
begin

  // showmessage( inttoStr(frmhome.walletList.ChildrenCount) );

  for fmxObj in WalletList.Content.Children do
  begin

    // showmessage( fmxObj.ToString );

    if fmxObj is TPanel then
      Panel := TPanel(fmxObj)
    else
      Continue;

    for i := 0 to Panel.ChildrenCount - 1 do
    begin

      if (Panel.Children[i] is TLabel) and
        (TLabel(Panel.Children[i]).TagString = 'name') then
      begin

        if (AnsiContainsText(TLabel(Panel.Children[i]).Text, SearchEdit.Text))
          or (SearchEdit.Text = '') then
        begin
          Panel.Visible := true;
          break;
        end
        else
        begin
          Panel.Visible := false;
          break;
        end;

      end;

    end;

  end;

end;

procedure TfrmHome.SearchEditExit(Sender: TObject);
begin
  // if SearchEdit.Text = '' then
  // begin
  SearchEdit.Visible := false;
  TLabel(frmHome.FindComponent('HeaderLabel')).Visible := true;
  SearchEdit.Text := '';
  // end;
end;

procedure TfrmHome.SendAllFundsOnSwitch(Sender: TObject);
begin
  if SendAllFundsSwitch.IsFocused then
  begin
    if SendAllFundsSwitch.IsChecked then
    begin
      wvAmount.Text := lbBalanceLong.Text;
      WVRealCurrency.Text :=
        floatToStrF(CurrencyConverter.calculate
        (strToFloatDef(lbBalanceLong.Text, 0) * CurrentCryptoCurrency.rate),
        ffFixed, 18, 2);
      FeeFromAmountSwitch.IsChecked := true;
      FeeFromAmountSwitch.Enabled := false;
    end
    else
    begin
      // SetFocused(WvAmount);
      // WvAmount.
      wvAmount.Text := BigIntegertoFloatStr(0, CurrentCryptoCurrency.decimals);
      FeeFromAmountSwitch.IsChecked := false;

      FeeFromAmountSwitch.Enabled := true;
    end;
  end;
end;

procedure TfrmHome.SendDecryptedSeedButtonClick(Sender: TObject);
begin

  btnDecryptSeed.OnClick := SendDecryptedSeed;

  decryptSeedBackTabItem := PageControl.ActiveTab;

  PageControl.ActiveTab := descryptSeed;

  btnDSBack.OnClick := backBtnDecryptSeed;

end;

procedure TfrmHome.SendDecryptedSeed { ButtonClick } (Sender: TObject);
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

  tced := TCA(passwordForDecrypt.Text);
  MasterSeed := SpeckDecrypt(tced, CurrentAccount.EncryptedMasterSeed);
  if not isHex(MasterSeed) then
  begin
    popupWindow.Create(dictionary['FailedToDecrypt']);
    // DecryptSeedMessage.Text := 'Failed to decrypt master seed';
    exit;
  end;
  // tempMasterSeed
  img := StrToQRBitmap(MasterSeed);
  ImgPath := System.IOUtils.TPath.Combine
    (System.IOUtils.TPath.GetDocumentsPath(), 'QRDecryptedSeed.png');
  DecodeDate(Now, Y, m, d);
  zipPath := System.IOUtils.TPath.Combine
    (System.IOUtils.TPath.GetDownloadsPath(), 'QRDecryptedSeed' +
    Format('%d.%d.%d', [Y, m, d]) + '.' + IntToStr(DateTimeToUnix(Now))
    + '.zip');

  img.SaveToFile(ImgPath);

  Zip := TEncryptedZipFile.Create(passwordForDecrypt.Text);

  if FileExists(zipPath) then
    DeleteFile(zipPath);

  Zip.Open(zipPath, TZipMode.zmWrite);
  Zip.Add(ImgPath);
  Zip.Close;

  shareFile(zipPath);

  MasterSeed := '';
  tced := '';

  userSavedSeed := true;
  refreshWalletDat();

  DeleteFile(ImgPath);
  // DeleteFile( zipPath );
  // tempPassword := '';
  img.free;
  Zip.free;

end;

procedure TfrmHome.SendEncryptedSeed(Sender: TObject);
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

  tced := TCA(passwordForDecrypt.Text);
  MasterSeed := SpeckDecrypt(tced, CurrentAccount.EncryptedMasterSeed);
  if not isHex(MasterSeed) then
  begin
    popupWindow.Create(dictionary['FailedToDecrypt']);
    // DecryptSeedMessage.Text := 'Failed to decrypt master seed';
    exit;
  end;

  img := StrToQRBitmap(CurrentAccount.EncryptedMasterSeed);

  ImgPath := System.IOUtils.TPath.Combine
    (System.IOUtils.TPath.GetDocumentsPath(), 'QREncryptedSeed.png');
  DecodeDate(Now, Y, m, d);
  zipPath := System.IOUtils.TPath.Combine
    (System.IOUtils.TPath.GetDownloadsPath(), 'QREncryptedSeed' +
    Format('%d.%d.%d', [Y, m, d]) + '.' + IntToStr(DateTimeToUnix(Now))
    + '.zip');

  img.SaveToFile(ImgPath);

  Zip := TEncryptedZipFile.Create(passwordForDecrypt.Text);

  if FileExists(zipPath) then
    DeleteFile(zipPath);

  Zip.Open(zipPath, TZipMode.zmWrite);
  Zip.Add(ImgPath);
  Zip.Close;

  // passwordForDecrypt.Text := '';

  shareFile(zipPath);

  DeleteFile(ImgPath);
  // DeleteFile( zipPath );
  img.free;
  Zip.free;

  MasterSeed := '';
  tced := '';

  userSavedSeed := true;
  refreshWalletDat();

  switchTab(PageControl, BackupTabItem);

end;

procedure TfrmHome.SendEncryptedSeedButtonClick(Sender: TObject);
begin

  btnDecryptSeed.OnClick := SendEncryptedSeed;

  decryptSeedBackTabItem := PageControl.ActiveTab;
  PageControl.ActiveTab := descryptSeed;
  btnDSBack.OnClick := backBtnDecryptSeed;

end;

procedure TfrmHome.SendWalletFile(Sender: TObject);
var
  i: Integer;
  Zip: TEncryptedZipFile;
  img: TBitmap;
  tempStr: TStream;

  ImgPath: AnsiString;
  zipPath: AnsiString;
  protectorPath: AnsiString;
  ts: TStringList;
  it: AnsiString;
  fileName: AnsiString;
var
  MasterSeed, tced: AnsiString;
  Y, m, d: Word;
begin

  tced := TCA(passwordForDecrypt.Text);
  MasterSeed := SpeckDecrypt(tced, CurrentAccount.EncryptedMasterSeed);
  if not isHex(MasterSeed) then
  begin
    popupWindow.Create(dictionary['FailedToDecrypt']);
    exit;
  end;
  tced := '';
  MasterSeed := '';
  DecodeDate(Now, Y, m, d);
  fileName := CurrentAccount.name + '_' + Format('%d.%d.%d', [Y, m, d]) + '.' +
    IntToStr(DateTimeToUnix(Now));

  zipPath := System.IOUtils.TPath.Combine
    (System.IOUtils.TPath.GetDownloadsPath(), fileName + '.hsb.zip');

  if FileExists(zipPath) then
    DeleteFile(zipPath);

  Zip := TEncryptedZipFile.Create(passwordForDecrypt.Text);

  Zip.Open(zipPath, TZipMode.zmWrite);

  img := StrToQRBitmap(CurrentAccount.EncryptedMasterSeed);
  ImgPath := System.IOUtils.TPath.Combine
    (System.IOUtils.TPath.GetDocumentsPath(), 'QREncryptedSeed.png');
  img.SaveToFile(ImgPath);

  for it in CurrentAccount.Paths do
  begin

    ts := TStringList.Create();
    ts.LoadFromFile(it);
    ts.SaveToFile(LeftStr(it, length(it) - 3) + 'hsb');
    ts.free;

    Zip.Add(it);

  end;
  for it in CurrentAccount.Paths do
  begin
    Zip.Add(LeftStr(it, length(it) - 3) + 'hsb');
  end;
  Zip.Add(ImgPath);
  Zip.Close;

  shareFile(zipPath);

  CurrentAccount.userSaveSeed := true;
  // refreshWalletDat();

  DeleteFile(ImgPath);
  // tempPassword := '';
  img.free;
  Zip.free;

  switchTab(PageControl, decryptSeedBackTabItem);

end;

procedure TfrmHome.SendWalletFileButtonClick(Sender: TObject);
begin
  btnDecryptSeed.OnClick := SendWalletFile;

  decryptSeedBackTabItem := PageControl.ActiveTab;
  PageControl.ActiveTab := descryptSeed;
  btnDSBack.OnClick := backBtnDecryptSeed;
end;

procedure TfrmHome.ShowShareSheetAction1BeforeExecute(Sender: TObject);
begin
  ShowShareSheetAction1.TextMessage := CurrentCryptoCurrency.addr;
end;

procedure TfrmHome.Switch1Switch(Sender: TObject);
begin
  PrivateKeySettingsLayout.Visible := Switch1.IsChecked;
end;

procedure TfrmHome.SearchInDashBrdButtonClick(Sender: TObject);
begin
  TLabel(frmHome.FindComponent('HeaderLabel')).Visible := false;
  SearchEdit.Visible := true;
  SetFocused(SearchEdit);
end;


procedure TfrmHome.SeedMnemonicBackupButtonClick(Sender: TObject);
begin

  btnDecryptSeed.OnClick := decryptSeedForSeedRestore;

  decryptSeedBackTabItem := PageControl.ActiveTab;
  PageControl.ActiveTab := descryptSeed;
  btnDSBack.OnClick := backBtnDecryptSeed;

end;

procedure TfrmHome.SwitchSavedSeedSwitch(Sender: TObject);
begin
  btnSkip.Enabled := frmHome.SwitchSavedSeed.IsChecked;
end;

// must be in the end        caused ide error
procedure TfrmHome.APICheckCompressed(Sender: TObject);
begin

  try
    if isHex(WIFEdit.Text) then
    begin
      if (length(WIFEdit.Text) <> 64) then
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

        if Layout31.Visible = true then
        begin
          popupWindow.Create
            ('You must check whether your hey is compressed or not');
          exit;
        end;

        LoadingKeyDataAniIndicator.Enabled := true;
        LoadingKeyDataAniIndicator.Visible := true;
        if ImportCoinID <> 4 then
        begin

          tthread.CreateAnonymousThread(
            procedure
            var
              comkey: AnsiString;
              notkey: AnsiString;
              Data: AnsiString;
              ts: TStringList;
              wd: TwalletInfo;
              request: AnsiString;
            begin
              comkey := secp256k1_get_public(WIFEdit.Text, false);
              notkey := secp256k1_get_public(WIFEdit.Text, true);

              wd := TwalletInfo.Create(ImportCoinID, -1, -1,
                Bitcoin_PublicAddrToWallet(comkey,
                AvailableCoin[ImportCoinID].p2pk), 'Imported');
              wd.pub := comkey;
              request := HODLER_URL + 'getSegwitBalance.php?coin=' +
                AvailableCoin[wd.coin].name + '&' + segwitParameters(wd);
              Data := getDataOverHTTP(request);
              ts := TStringList.Create();
              ts.Text := Data;

              if strToFloatDef(ts[0], 0) + strToFloatDef(ts[1], 0) = 0 then
              begin
                Data := getDataOverHTTP(HODLER_URL +
                  'getSegwitHistory.php?coin=' + AvailableCoin[wd.coin].name +
                  '&' + segwitParameters(wd));
                // ->
                if length(Data) > 10 then
                begin

                  tthread.Synchronize(nil,
                    procedure
                    begin
                      HexPrivKeyCompressedRadioButton.IsChecked := true;
                      // btnOKAddNewCoinSettingsClick(Sender);
                      ts.free;
                      wd.free;
                      exit;
                    end);

                end;
              end
              else
              begin
                tthread.Synchronize(nil,
                  procedure
                  begin
                    HexPrivKeyCompressedRadioButton.IsChecked := true;
                    // btnOKAddNewCoinSettingsClick(Sender);
                    ts.free;
                    wd.free;
                    exit;
                  end);
              end;
              ts.free;
              wd.free;

              // // // // // // // // // // // // // // // // // // // //

              wd := TwalletInfo.Create(ImportCoinID, -1, -1,
                Bitcoin_PublicAddrToWallet(notkey,
                AvailableCoin[ImportCoinID].p2pk), '');
              wd.pub := comkey;

              Data := getDataOverHTTP(HODLER_URL + 'getBalance.php?coin=' +
                AvailableCoin[wd.coin].name + '&address=' + wd.addr);
              ts := TStringList.Create();
              ts.Text := Data;
              // *
              if strToFloatDef(ts[0], 0) + strToFloatDef(ts[1], 0) = 0 then
              begin
                Data := getDataOverHTTP(HODLER_URL + 'getHistory.php?coin=' +
                  AvailableCoin[wd.coin].name + '&address=' + wd.addr);
                if length(Data) > 10 then
                begin
                  tthread.Synchronize(nil,
                    procedure
                    begin
                      HexPrivKeyNotCompressedRadioButton.IsChecked := true;
                      // btnOKAddNewCoinSettingsClick(Sender);
                      ts.free;
                      wd.free;
                      exit; // +
                    end);
                end;
              end
              else
              begin
                tthread.Synchronize(nil,
                  procedure
                  begin
                    HexPrivKeyNotCompressedRadioButton.IsChecked := true;
                    // btnOKAddNewCoinSettingsClick(Sender);
                    ts.free;
                    wd.free;
                    exit;
                  end);
              end;
              /// /****

              ts.free;
              wd.free;

              tthread.Synchronize(nil,
                procedure
                begin
                  LoadingKeyDataAniIndicator.Enabled := false;
                  LoadingKeyDataAniIndicator.Visible := false;
                  Layout31.Visible := true;
                end);

            end).Start();
          exit;
        end;
        // Parsing for ETH
        if ImportCoinID = 4 then
        begin
          tthread.CreateAnonymousThread(
            procedure
            var
              comkey: AnsiString;
              notkey: AnsiString;
              Data: AnsiString;
              ts: TStringList;
              wd: TwalletInfo;
              request: AnsiString;
            begin
              comkey := secp256k1_get_public(WIFEdit.Text, true);

              wd := TwalletInfo.Create(ImportCoinID, -1, -1,
                Ethereum_PublicAddrToWallet(comkey), 'Imported');
              wd.pub := comkey;

              tthread.Synchronize(nil,
                procedure
                begin
                  LoadingKeyDataAniIndicator.Enabled := false;
                  LoadingKeyDataAniIndicator.Visible := false;
                  Layout31.Visible := true;
                  HexPrivKeyNotCompressedRadioButton.IsChecked := true;
                  //SaveNewPrivateKeyButtonClick(Sender);
                end);

            end).Start();
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
      popupWindow.Create('WIF is not valid');
      exit;
    end;
  end;

  btnDecryptSeed.OnClick := ImportPrivateKey;

  decryptSeedBackTabItem := PageControl.ActiveTab;
  PageControl.ActiveTab := descryptSeed;
  btnDSBack.OnClick := backBtnDecryptSeed;
end;

procedure TfrmHome.ScrollKeeperTimer(Sender: TObject);
var
  FService: IFMXVirtualKeyboardService;
begin

  TPlatformServices.Current.SupportsPlatformService(IFMXVirtualKeyboardService,
    IInterface(FService));

  if (FService = nil) or
    ((FService <> nil) and (not(TVirtualKeyboardState.Visible
    in FService.VirtualKeyBoardState))) then
    ScrollBox.ViewportPosition := PointF(0, 0);
end;

procedure TfrmHome.RestoreFromFileButtonClick(Sender: TObject);
begin

  clearVertScrollBox(BackupFileListVertScrollBox);
{$IFDEF ANDROID}
  requestForPermission('android.permission.READ_EXTERNAL_STORAGE');
  // requestForPermission('android.permission.WRITE_EXTERNAL_STORAGE');

  tthread.CreateAnonymousThread(
    procedure
    var
      i: Integer;
    begin

      for i := 0 to 5 * 30 do
      begin
        if (TAndroidHelper.Context.checkCallingOrSelfPermission
          (StringToJString('android.permission.READ_EXTERNAL_STORAGE')) = -1)
        // or (TAndroidHelper.Context.checkCallingOrSelfPermission
        // (StringToJString('android.permission.WRITE_EXTERNAL_STORAGE')) = -1)
        then
        begin
          sleep(200);
        end
        else
        begin
{$ENDIF}
          tthread.CreateAnonymousThread(
            procedure
            var
              strArr: TStringDynArray;
              Button: TButton;

            begin

              tthread.Synchronize(nil,
                procedure
                begin
                  LoadBackupFileAniIndicator.Visible := true;
                  LoadBackupFileAniIndicator.Enabled := true;
                end);

{$IFDEF ANDROID}
              strArr := TDirectory.GetFiles(TDirectory.GetParent
                (System.IOUtils.TPath.GetSharedDownloadsPath()), '*.hsb.zip',
                TSearchOption.SoAllDirectories);
{$ELSE}
              strArr := TDirectory.GetFiles('C:\', '*.hsb.zip',
                TSearchOption.SoAllDirectories);
{$ENDIF}
              tthread.Synchronize(nil,
                procedure
                var
                  i: Integer;
                begin

                  for i := 0 to length(strArr) - 1 do
                  begin
                    // if containsText ( strArr[i] , 'hsb' ) then
                    // begin
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
                        length(TDirectory.GetParent(System.IOUtils.TPath.
                        GetSharedDownloadsPath())))
                    else
                      Button.Text := strArr[i];
                    Button.TagString := strArr[i];
                    Button.Parent := BackupFileListVertScrollBox;
                    Button.OnClick := SelectFileInBackupFileList;
                    // end;
                  end;

                  LoadBackupFileAniIndicator.Visible := false;
                  LoadBackupFileAniIndicator.Enabled := false;

                end);

            end).Start;
{$IFDEF ANDROID}
          tthread.Synchronize(nil,
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
{$ELSE}
          RFFPathEdit.Text := 'C:\';

          switchTab(PageControl, RestoreFromFileTabitem);
{$ENDIF}
          end; end.
