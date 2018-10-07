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

  FMX.Media, FMX.Objects, CurrencyConverter, uEncryptedZipFile, System.Zip
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
  misc, FMX.Menus,
  ZXing.BarcodeFormat,
  ZXing.ReadResult,
  ZXing.ScanManager, FMX.EditBox, FMX.SpinBox, FOcr, FMX.Gestures, FMX.Effects,
  FMX.Filter.Effects, System.Actions, FMX.ActnList, System.Math.Vectors,
  FMX.Controls3D, FMX.Layers3D, FMX.StdActns, FMX.MediaLibrary.Actions,
  FMX.ComboEdit;
procedure reloadWalletView;

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
    bpmnemonicLayout: TLayout;
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
    privTCAPanel1: TPanel;
    Label18: TLabel;
    notPrivTCA1: TCheckBox;
    privTCAPanel2: TPanel;
    Label19: TLabel;
    notPrivTCA2: TCheckBox;
    SameYWalletList: TTabItem;
    YaddressesVertScrollBox: TVertScrollBox;
    changeYbutton: TButton;
    DayNightModeSwitch: TSwitch;
    Panel8: TPanel;
    DayNightModeStaticLabel: TLabel;
    YAddresses: TLayout;
    FindUnusedAddressButton: TButton;
    PasswordForGenerateYAddressesTabItem: TTabItem;
    Button12: TButton;
    Label20: TLabel;
    ToolBar9: TToolBar;
    Label21: TLabel;
    Button13: TButton;
    Panel9: TPanel;
    GenerateYAddressPasswordEdit: TEdit;
    Label22: TLabel;
    CalloutPanel1: TCalloutPanel;
    Label23: TLabel;
    TrackBar1: TTrackBar;
    Label24: TLabel;
    Panel14: TPanel;
    SpinBox1: TSpinBox;
    Layout57: TLayout;
    btnNewAddress: TButton;
    btnPrevAddress: TButton;
    Label26: TLabel;
    BigQRCode: TTabItem;
    BigQRCodeImage: TImage;
    Panel15: TPanel;
    OwnXCheckBox: TCheckBox;
    OwnXEdit: TEdit;
    lblPrivateKey: TEdit;
    lblWIFKey: TEdit;
    Label25: TLabel;
    Label27: TLabel;
    layoutForPrivQR: TLayout;

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
    procedure ConfirmNewAccountButtonClick(Sender: TObject);
    procedure AddNewAccountButtonClick(Sender: TObject);
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
    procedure AccountsListPanelMouseLeave(Sender: TObject);
    procedure AccountsListPanelExit(Sender: TObject);
    procedure notPrivTCA2Change(Sender: TObject);
    procedure changeYbuttonClick(Sender: TObject);
    procedure DayNightModeSwitchSwitch(Sender: TObject);
    procedure FindUnusedAddressButtonClick(Sender: TObject);
    procedure TrackBar1Change(Sender: TObject);
    procedure SpinBox1Change(Sender: TObject);

    procedure generateNewAddressesClick(Sender: TObject);
    procedure backBtnDecryptSeed(Sender: TObject);
    procedure QRCodeImageClick(Sender: TObject);
    procedure BigQRCodeImageClick(Sender: TObject);
    procedure OwnXCheckBoxChange(Sender: TObject);
    procedure WVsendTOChange(Sender: TObject);
    procedure WVsendTOKeyDown(Sender: TObject; var Key: Word; var KeyChar: Char;
      Shift: TShiftState);
    procedure WVsendTOTyping(Sender: TObject);

  private
    { Private declarations }
    FScanManager: TScanManager;
    FScanInProgress: Boolean;
    FFrameTake: Integer;
    procedure GetImage();
  public
    { Public declarations }
{$IFDEF ANDROID}
    procedure RegisterDelphiNativeMethods();
{$ENDIF}
    procedure OpenWalletView(Sender: TObject; const Point: TPointF); overload;
    procedure OpenWalletView(Sender: TObject); overload;
    procedure OpenWalletViewFromYWalletList(Sender: TObject);
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
    procedure addNewWalletPanelClick(Sender: TObject);
    procedure privateKeyPasswordCheck(Sender: TObject);
    procedure addToken(Sender: TObject);
    procedure choseTokenClick(Sender: TObject);
    procedure WordSeedClick(Sender: TObject);
    procedure decryptSeedForSeedRestore(Sender: TObject);
    procedure hideWallet(Sender: TObject);
    procedure importPrivCoinListPanelClick(Sender: TObject);
    procedure LoadAccountPanelClick(Sender: TObject);
    procedure SelectFileInBackupFileList(Sender: TObject);
    procedure YAddressClick(Sender: TObject);
    procedure deleteYaddress(Sender: TObject);

  var
    cpTimeout: int64;
    shown: Boolean;
    isTokenTransfer: Boolean;
    MovingPanel: TPanel;
    ToMove: TPanel;
    Grab: Boolean;
    procCreateWallet: procedure(Sender: TObject) of Object;
    dictionary: TObjectDictionary<AnsiString, WideString>;
    onFileManagerSelectClick: TProc;
    curWU: Integer;
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
  CurrentStyle: AnsiString;
  BigQRCodeBackTab: TTabItem;
  ImportCoinID: Integer;

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

procedure TfrmHome.OpenWalletViewFromYWalletList(Sender: TObject);
begin
  OpenWalletView(Sender);

  WVTabControl.ActiveTab := WVReceive;
end;

procedure TfrmHome.deleteYaddress(Sender: TObject);
begin
  popupWindowYesNo.Create(
    procedure
    begin

      TwalletInfo(TfmxObject(Sender).TagObject).deleted := true;

      CurrentAccount.SaveFiles;

      changeYbuttonClick(nil);
    end,
    procedure
    begin

    end, 'Do you want archivise this address? It will be given first in adding new addresses.');
end;

procedure TfrmHome.YAddressClick(Sender: TObject);
begin

end;

procedure TfrmHome.generateNewAddressesClick(Sender: TObject);
var
  CCarray: TCryptoCurrencyArray;
  newWD, wd: TwalletInfo;

  indexArray: array of Integer;
  Yarray: array of Integer;
  exist: Boolean;
var
  MasterSeed, tced: AnsiString;
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
        popupWindow.Create(dictionary['FailedToDecrypt']);
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

procedure TfrmHome.removeAccount(Sender: TObject);
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
    currentRow: int64;
    k: int64;
    currentCol: int64;
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
      if bmp <> nil then
        bmp.free;
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

procedure TfrmHome.QRCodeImageClick(Sender: TObject);
begin

  EnlargeQRCode(QRCodeImage.Bitmap);
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
  ImgLayout: TLayout;
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
    lbl.TextSettings.HorzAlign := TTextAlign.Leading;
    lbl.Visible := true;
    lbl.Parent := Panel;
    if extractfilename(path) <> '' then
      lbl.Text := extractfilename(path)
    else
      lbl.Text := path;

    ImgLayout := TLayout.Create(Panel);
    ImgLayout.Parent := Panel;
    ImgLayout.Align := TAlignLayout.Left;
    ImgLayout.Width := 66;
    ImgLayout.Visible := true;

    IconIMG := TImage.Create(ImgLayout);
    IconIMG.Parent := ImgLayout;
    IconIMG.Bitmap := frmHome.DirectoryImage.Bitmap;
    IconIMG.Height := 32.0;
    IconIMG.Width := 50;
    IconIMG.Position.X := 12;
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

procedure TfrmHome.FindUnusedAddressButtonClick(Sender: TObject);
var
  cc: CryptoCurrency;
  minY: Integer;
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

      Tthread.CreateAnonymousThread(
        procedure
        begin

          Tthread.Synchronize(nil,
            procedure
            var
              i: Integer;
            begin

              DeleteAccount(CurrentAccount.name);
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
    Panel.TagString := th.addresses[i];
    Panel.name := 'HistoryValueAddressPanel_' + IntToStr(i);
    Panel.Parent := HistoryTransactionVertScrollBox;
    Panel.Position.Y := 1000 + Panel.Height * i;
    Panel.OnGesture := CopyToClipboard;
    Panel.Touch.GestureManager := GestureManager1;
    Panel.Touch.InteractiveGestures := [TInteractiveGesture.DoubleTap,
      TInteractiveGesture.LongTap];

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
  wdArray: TCryptoCurrencyArray;
  i: Integer;
begin
  if Sender is TButton then
  begin

    Panel := TPanel(TfmxObject(Sender).Parent);

    if (Panel.TagObject is TwalletInfo) and
      (TwalletInfo(Panel.TagObject).coin <> 4) then
    begin

      wdArray := CurrentAccount.getWalletWithX(TwalletInfo(Panel.TagObject).X,
        TwalletInfo(Panel.TagObject).coin);

      for i := 0 to length(wdArray) - 1 do
      begin
        wdArray[i].deleted := true;
      end;

    end
    else
    begin
      CryptoCurrency(Panel.TagObject).deleted := true;
    end;

    Panel.DisposeOf;
  end;

end;

{$IFDEF ANDROID}

procedure requestHandler(requestCode: Integer;
permissions: TJavaObjectArray<JString>; grantResults: TJavaArray<Integer>);
begin
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
  passwordForDecrypt.Text := '';
  MasterSeed := SpeckDecrypt(tced, CurrentAccount.EncryptedMasterSeed);
  if not isHex(MasterSeed) then
  begin
    popupWindow.Create(dictionary['FailedToDecrypt']);
    exit;
  end;
  switchTab(PageControl, seedGenerated);
  BackupMemo.Lines.Clear;
  BackupMemo.Lines.Add(dictionary['MasterseedMnemonic'] + ':');
  BackupMemo.Lines.Add(toMnemonic(MasterSeed));
  tempMasterSeed := MasterSeed;
  MasterSeed := '';

end;

procedure TfrmHome.PanelDragDrop(Sender: TObject; const Data: TDragObject;
const Point: TPointF);
var
  dadService: IFMXDragDropService;
begin
end;

procedure TfrmHome.OrganizeListMouseMove(Sender: TObject; Shift: TShiftState;
X, Y: Single);
var
  fmxObj: TfmxObject;
begin
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

  MovingPanel.DisposeOf;
  OrganizeList.AniCalculations.TouchTracking := [ttVertical];

end;

procedure TfrmHome.OwnXCheckBoxChange(Sender: TObject);
begin
  if OwnXCheckBox.IsFocused then
  begin

    OwnXEdit.Enabled := OwnXCheckBox.IsChecked;
    Switch1.Enabled := not OwnXCheckBox.IsChecked;

    if OwnXCheckBox.IsChecked then
    begin

      Switch1.IsChecked := false;
    end
    else
    begin
      OwnXEdit.Text := '';
    end;
  end;
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
  ToMove := TPanel(Sender);
  MovingPanel := TPanel(TPanel(Sender).Clone(OrganizeList));
  MovingPanel.Align := TAlignLayout.None;
  MovingPanel.Parent := OrganizeList;
  OrganizeList.Root.Captured := OrganizeList;
  MovingPanel.BringToFront;
  MovingPanel.Repaint;
  Grab := true;
  TPanel(Sender).Opacity := 0.5;
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
    frmHome.tabAnim.Tab := TabItem;
    frmHome.AccountsListPanel.Visible := false;
    frmHome.tabAnim.ExecuteTarget(TabControl);
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
end;

procedure TfrmHome.WVRealCurrencyExit(Sender: TObject);
begin
  if (WVRealCurrency.Text = '') then
    WVRealCurrency.Text := '0.00';
end;

procedure TfrmHome.WVSendClick(Sender: TObject);
begin
  arrowImg.Height := ShowHideAdvancedButton.TextSettings.Font.Size * 0.75;
  arrowImg.Width := arrowImg.Height * 2;
end;

procedure TfrmHome.RefreshKeyBoard(Sender: TObject);
var
  FService: IFMXVirtualKeyboardService;
  FToolbarService: IFMXVirtualKeyBoardToolbarService;
begin
  TPlatformServices.Current.SupportsPlatformService(IFMXVirtualKeyboardService,
    IInterface(FService));

  if FService <> nil then
  begin
    FService.HideVirtualKeyboard();
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
            showmessage('Wrong password or damaged file');

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
    frmHome.FormShow(nil);
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
            showmessage('Damaged file');

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

    RemoveDir(ac.DirPath);
    frmHome.FormShow(nil);
    showmessage('Failed to decrypt files');
    exit;
  end;
  ac := Account.Create(accname);
  try
    ac.LoadFiles;
  except
    on E: Exception do
    begin
      RemoveDir(ac.DirPath);
      frmHome.FormShow(nil);
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

procedure TfrmHome.RestoreFromFileConfirmButtonClick(Sender: TObject);
var
  failure: Boolean;
begin
  failure := false;
  if length(RestoreFromFileAccountNameEdit.Text) < 3 then
  begin
    showmessage('Account name too short');
    exit;
  end;
  if not FileExists(RFFPathEdit.Text) then
  begin
    showmessage('file doesn''t exist');
    exit;
  end;
  if isPasswordZip(RFFPathEdit.Text) then
    oldHSB(RFFPathEdit.Text, RFFPassword.Text,
      RestoreFromFileAccountNameEdit.Text)
  else
    NewHSB(RFFPathEdit.Text, RFFPassword.Text,
      RestoreFromFileAccountNameEdit.Text);

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

procedure TfrmHome.WVsendTOChange(Sender: TObject);
begin
  WVsendTOExit(self);
end;

procedure TfrmHome.WVsendTOExit(Sender: TObject);
begin
  if Pos(' ', WVsendTO.Text) > 0 then
    WVsendTO.Text := StringReplace(WVsendTO.Text, ' ', '', [rfReplaceAll]);
end;

procedure TfrmHome.WVsendTOKeyDown(Sender: TObject; var Key: Word;
var KeyChar: Char; Shift: TShiftState);
begin
  WVsendTOExit(self);
end;

procedure TfrmHome.WVsendTOPaint(Sender: TObject; Canvas: TCanvas;
const ARect: TRectF);
var
  brush: TStrokeBrush;
begin

end;

procedure TfrmHome.WVsendTOTyping(Sender: TObject);
begin
  WVsendTOExit(self);
end;

procedure TfrmHome.backBtnDecryptSeed(Sender: TObject);
begin
  switchTab(PageControl, decryptSeedBackTabItem);
end;

procedure TfrmHome.BackToBalanceViewButtonClick(Sender: TObject);
var
  fmxObj: TfmxObject;
  i: Integer;
begin

  for i := 0 to OrganizeList.Content.ChildrenCount - 1 do
  begin
    fmxObj := OrganizeList.Content.Children[i];
    CryptoCurrency(fmxObj.TagObject).orderInWallet :=
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

  if (SyncHistoryThr <> nil) and (SyncHistoryThr.Finished = false) then
  begin

    try
      SyncHistoryThr.Terminate();
    except
      on E: Exception do
      begin

      end;
    end;

  end;

  CurrentAccount.SaveFiles();
  clearVertScrollBox(WalletList);
  lastClosedAccount := CurrentAccount.name;
  refreshWalletDat();
  TLabel(frmHome.FindComponent('globalBalance')).Text := '0.00';
  FormShow(nil);

  syncTimer.Enabled := true;

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
  if LeftStr(receiveAddress.Text, length('bitcoincash:')) = 'bitcoincash:' then
    receiveAddress.Text := RightStr(receiveAddress.Text,
      length(receiveAddress.Text) - length('bitcoincash:'));
  receiveAddress.Text := cutEveryNChar(4, receiveAddress.Text, ' ');
end;

procedure TfrmHome.BCHLegacyButtonClick(Sender: TObject);
begin
  receiveAddress.Text := cutEveryNChar(4, TwalletInfo(CurrentCryptoCurrency)
    .addr, ' ')
end;

procedure TfrmHome.BigQRCodeImageClick(Sender: TObject);
begin
  PageControl.ActiveTab := BigQRCodeBackTab;
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

procedure TfrmHome.changeYbuttonClick(Sender: TObject);
var
  cc: CryptoCurrency;
  Panel: TPanel;
  bilanceLbl: TLabel;
  addrlbl: TLabel;
  deleteBtn: TButton;
  generateNewAddresses: TButton;
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
    bilanceLbl.Margins.Left := 15;
    bilanceLbl.Margins.Right := 15;
    bilanceLbl.Text := bigintegerbeautifulStr(cc.confirmed, cc.decimals);
    bilanceLbl.Align := TAlignLayout.Right;
    bilanceLbl.Width := Panel.Width / 4;
    bilanceLbl.TextSettings.HorzAlign := TTextAlign.Trailing;

    deleteBtn := TButton.Create(Panel);
    deleteBtn.Parent := Panel;
    deleteBtn.Visible := true;
    deleteBtn.Align := TAlignLayout.MostRight;
    deleteBtn.Width := 48;
    deleteBtn.Text := 'X';
    deleteBtn.TagObject := cc;
    deleteBtn.OnClick := deleteYaddress;

  end;

  generateNewAddresses := TButton.Create(YaddressesVertScrollBox);
  generateNewAddresses.Parent := YaddressesVertScrollBox;
  generateNewAddresses.Visible := true;
  generateNewAddresses.Align := TAlignLayout.Top;
  generateNewAddresses.Text := 'Add new addresses';
  generateNewAddresses.OnClick := generateNewAddressesClick;
  generateNewAddresses.Height := 48;
  generateNewAddresses.TagObject := CurrentCoin;
  generateNewAddresses.Position.Y := 1000000000;

  PageControl.ActiveTab := SameYWalletList;

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

procedure TfrmHome.DayNightModeSwitchSwitch(Sender: TObject);
begin

  if DayNightModeSwitch.IsFocused then
  begin
    if DayNightModeSwitch.IsChecked then
    begin
      loadstyle('RT_DARK');

      refreshWalletDat();
    end
    else
    begin

      loadstyle('RT_WHITE');

      refreshWalletDat();

    end;
  end;

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
end;

procedure TfrmHome.privateKeyPasswordCheck(Sender: TObject);
var
  MasterSeed, tced: AnsiString;
var
  Bitmap: TBitmap;
  tempStr: AnsiString;
begin

  tced := TCA(passwordForDecrypt.Text);
  passwordForDecrypt.Text := '';
  MasterSeed := SpeckDecrypt(tced, CurrentAccount.EncryptedMasterSeed);
  if (CurrentCoin.X = -1) and (CurrentCoin.Y = -1) then
  begin

    tempStr := SpeckDecrypt(TCA(MasterSeed), CurrentCoin.EncryptedPrivKey);

    if not isHex(tempStr) then
    begin
      DecryptSeedMessage.Text := dictionary['FailedToDecrypt'];
      exit;
    end;

    lblPrivateKey.Text := cutEveryNChar(4, tempStr);
    lblWIFKey.Text := PrivKeyToWIF(tempStr, CurrentCoin.isCompressed,
      AvailableCoin[TwalletInfo(CurrentCoin).coin].wifByte);
    tempStr := '';
    MasterSeed := '';

  end
  else
  begin

    if not isHex(MasterSeed) then
    begin
      DecryptSeedMessage.Text := dictionary['FailedToDecrypt'];
      wipeAnsiString(MasterSeed);
      exit;
    end;

    lblPrivateKey.Text := priv256forhd(CurrentCoin.coin, CurrentCoin.X,
      CurrentCoin.Y, MasterSeed);
    lblWIFKey.Text := PrivKeyToWIF(lblPrivateKey.Text, CurrentCoin.coin <> 4,
      AvailableCoin[TwalletInfo(CurrentCoin).coin].wifByte);
    // lblPrivateKey.Text := cutEveryNChar(4,lblPrivateKey.Text );
    wipeAnsiString(MasterSeed);

  end;

  Bitmap := StrToQRBitmap(removeSpace(lblPrivateKey.Text));
  PrivKeyQRImage.Bitmap.Assign(Bitmap);
  Bitmap.free;

  switchTab(PageControl, ExportKeyScreen);

end;

procedure TfrmHome.AccountsListPanelExit(Sender: TObject);
begin
  AccountsListPanel.Visible := false;
end;

procedure TfrmHome.AccountsListPanelMouseLeave(Sender: TObject);
begin
  AccountsListPanel.Visible := false;
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
end;

procedure TfrmHome.TrackBar1Change(Sender: TObject);
begin

  if TrackBar1.IsFocused then
  begin

    if TrackBar1.Value <= 10 then
      SpinBox1.Value := TrackBar1.Value
    else
      SpinBox1.Value := (TrackBar1.Value - 10) * 5 + 10;

  end;

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
  ConfirmSendPasswordEdit.Text := '';
  MasterSeed := SpeckDecrypt(tced, CurrentAccount.EncryptedMasterSeed);
  if not isHex(MasterSeed) then
  begin
    popupWindow.Create(dictionary['FailedToDecrypt']);
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
  if { (not isEthereum) and } (not isTokenTransfer) then
    if amount + tempFee > (CurrentAccount.aggregateBalances(CurrentCoin)
      .confirmed) then
    begin
      popupWindow.Create(dictionary['AmountExceed']);
      exit;
    end;

  if ((amount) = 0) or ((fee) = 0) then
  begin
    popupWindowOK.Create(
      procedure
      begin

        Tthread.CreateAnonymousThread(
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
      end;
    end;
  end;

  Tthread.CreateAnonymousThread(
    procedure
    var
      ans: AnsiString;
    begin

      Tthread.Synchronize(nil,
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

      Tthread.Synchronize(nil,
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
            SynchronizeCryptoCurrency(CurrentCryptoCurrency);
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
            TransactionWaitForSendDetailsLabel.Visible := true;
            TransactionWaitForSendLinkLabel.Visible := true;
          end
          else
          begin
            TransactionWaitForSendDetailsLabel.Visible := true;
            TransactionWaitForSendLinkLabel.Visible := false;
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
    popupWindow.Create(dictionary['CopiedToClipboard']);

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

  if TPlatformServices.Current.SupportsPlatformService(IFMXClipboardService, svc)
  then
  begin

    if Sender is TPanel then
    begin

      svc.setClipboard(TPanel(Sender).TagString);
      popupWindow.Create(dictionary['CopiedToClipboard']);

      vibrate(200);
    end;

    if (Sender is TEdit) then
    begin

      if svc.GetClipboard().ToString() <> removeSpace(TEdit(Sender).Text) then
      begin
        svc.setClipboard(removeSpace(TEdit(Sender).Text));
        popupWindow.Create(dictionary['CopiedToClipboard']);
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
end;

// button in warning window
procedure TfrmHome.btnSMVNoClick(Sender: TObject);
begin
  switchTab(PageControl, lastView);
  lastChose := 0;
end;

// button in warning window
procedure TfrmHome.btnSMVYesClick(Sender: TObject);
begin
  switchTab(PageControl, lastView);
  lastChose := 1;
end;

procedure reloadWalletView;
var
  wd: TwalletInfo;
  a: BigInteger;
  cc: CryptoCurrency;
  sumConfirmed, sumUnconfirmed: BigInteger;
  SumFiat: Double;
begin

  with frmHome do
  begin

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

    if (TwalletInfo(CurrentCryptoCurrency).coin <> 4) and (not isTokenTransfer)
    then
    begin
      sumConfirmed := 0;
      sumUnconfirmed := 0;
      SumFiat := 0;
      for cc in CurrentAccount.getWalletWithX(CurrentCoin.X,
        CurrentCoin.coin) do
      begin
        sumConfirmed := sumConfirmed + cc.confirmed;
        sumUnconfirmed := sumUnconfirmed + cc.unconfirmed;
        SumFiat := SumFiat + cc.getFiat();
      end;

      lbBalance.Text := bigintegerbeautifulStr(sumConfirmed,
        CurrentCryptoCurrency.decimals);
      lbBalanceLong.Text := BigIntegertoFloatStr(sumConfirmed,
        CurrentCryptoCurrency.decimals);
      lblFiat.Text := floatToStrF(SumFiat, ffFixed, 15, 2);

      TopInfoConfirmedValue.Text := ' ' + BigIntegertoFloatStr(sumConfirmed,
        CurrentCryptoCurrency.decimals);
      TopInfoUnconfirmedValue.Text := ' ' + BigIntegertoFloatStr(sumUnconfirmed,
        CurrentCryptoCurrency.decimals);

    end
    else
    begin
      lbBalance.Text := bigintegerbeautifulStr(CurrentCryptoCurrency.confirmed,
        CurrentCryptoCurrency.decimals);

      lbBalanceLong.Text := BigIntegertoFloatStr
        (CurrentCryptoCurrency.confirmed, CurrentCryptoCurrency.decimals);

      lblFiat.Text := floatToStrF(CurrentCryptoCurrency.getFiat(),
        ffFixed, 15, 2);

      TopInfoConfirmedValue.Text := ' ' + BigIntegertoFloatStr
        (CurrentCryptoCurrency.confirmed, CurrentCryptoCurrency.decimals);
      TopInfoUnconfirmedValue.Text := ' ' + BigIntegertoFloatStr
        (CurrentCryptoCurrency.unconfirmed, CurrentCryptoCurrency.decimals);
    end;

  end;
end;

procedure TfrmHome.OpenWalletView(Sender: TObject; const Point: TPointF);
var
  wd: TwalletInfo;
  a: BigInteger;
begin

  CurrentCryptoCurrency := CryptoCurrency(TfmxObject(Sender).TagObject);
  reloadWalletView;

  if isEthereum or isTokenTransfer then
  begin
    YAddresses.Visible := false;
    btnNewAddress.Visible := false;
    btnPrevAddress.Visible := false;
    lblFeeHeader.Text := dictionary['GasPriceWEI'] + ':';
    lblFee.Text := '';
    wvFee.Text := CurrentCoin.efee[0];

    if isTokenTransfer then
    begin
      lblFee.Text := wvFee.Text + '  = ' +
        floatToStrF(CurrencyConverter.calculate(strToFloatDef(wvFee.Text,
        0) * 66666 * CurrentCryptoCurrency.rate / (1000000.0 * 1000000.0 *
        1000000.0)), ffFixed, 18, 6) + ' ' + CurrencyConverter.symbol;
    end;

  end
  else
  begin
    YAddresses.Visible := true;
    btnNewAddress.Visible := true;
    btnPrevAddress.Visible := true;
    lblFeeHeader.Text := dictionary['TransactionFee'] + ':';
    lblFee.Text := '0.00 ' + CurrentCryptoCurrency.shortcut;
    wvFee.Text := CurrentCoin.efee[round(FeeSpin.Value) - 1];
  end;
  if wvFee.Text = '' then
    wvFee.Text := '0';

  wvAmount.Text := BigIntegertoFloatStr(0, CurrentCryptoCurrency.decimals);
  ReceiveValue.Text := BigIntegertoFloatStr(0, CurrentCryptoCurrency.decimals);
  ReceiveAmountRealCurrency.Text := '0.00';
  WVRealCurrency.Text := floatToStrF(strToFloatDef(wvAmount.Text, 0) *
    CurrentCryptoCurrency.rate, ffFixed, 15, 2);
  ShortcutValetInfoImage.Bitmap := CurrentCryptoCurrency.getIcon();
  wvGFX.Bitmap := CurrentCryptoCurrency.getIcon();

  lblCoinShort.Text := CurrentCryptoCurrency.shortcut + '   ';
  lblReceiveCoinShort.Text := CurrentCryptoCurrency.shortcut + '   ';
  QRChangeTimerTimer(nil);
  receiveAddress.Text := cutEveryNChar(4, CurrentCryptoCurrency.addr);

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

    lblBlockInfo.Visible := true;
    FeeSpin.Visible := true;
    FeeSpin.Enabled := true;
    // FeeSpin.Opacity := 1;

  end;
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

  if not isEthereum then
  begin

    a := ((180 * length(TwalletInfo(CurrentCryptoCurrency).UTXO) +
      (34 * 2) + 12));
    curWU := a.asInteger;
    a := (a * StrFloatToBigInteger(CurrentCoin.efee[round(FeeSpin.Value) - 1],
      CurrentCoin.decimals)) div 1024;
    a := Max(a, 999);
    wvFee.Text := BigIntegertoFloatStr(a, CurrentCoin.decimals);
    // CurrentCoin.efee[round(FeeSpin.Value) - 1] ;
    lblBlockInfo.Text := dictionary['ConfirmInNext'] + ' ' +
      IntToStr(round(FeeSpin.Value)) + ' ' + dictionary['Blocks'];
  end;

  // changeYbutton.Text := 'Change address (' + intToStr(CurrentCoin.x) +','+inttoStr(CurrentCoin.y) + ')';
  if PageControl.ActiveTab = TTabItem(frmHome.FindComponent('dashbrd')) then
    WVTabControl.ActiveTab := WVBalance;
  switchTab(PageControl, walletView);
end;

procedure TfrmHome.OpenWalletView(Sender: TObject);
begin
  OpenWalletView(Sender, TPoint.Zero);
end;

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
  switchTab(PageControl, SeedCreation);
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

    Tthread.CreateAnonymousThread(
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
            Tthread.Synchronize(nil,
              procedure
              begin
                btnQRClick(nil);
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

procedure TfrmHome.btnGenSeedClick(Sender: TObject);
var
  alphaStr: AnsiString;
begin
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
end;

procedure TfrmHome.btnSCBackClick(Sender: TObject);
begin
  switchTab(PageControl, createPassword);
end;

procedure TfrmHome.btnANWBackClick(Sender: TObject);
begin
  switchTab(PageControl, TTabItem(frmHome.FindComponent('dashbrd')));
end;

// checking rewriting seed
procedure TfrmHome.btnConfirmClick(Sender: TObject);
var
  ts: TStringList;
  i: Integer;
begin
  ts := TStringList.Create();

  for i := 0 to ConfirmedSeedFlowLayout.ChildrenCount - 1 do
  begin
    ts.Add(TButton(ConfirmedSeedFlowLayout.Children[i]).Text);
  end;
  if LowerCase(fromMnemonic(ts)) = LowerCase(tempMasterSeed) then
  begin
    tempMasterSeed := '';
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
  firstSync := true;

  LoadCurrentAccount(TfmxObject(Sender).TagString);
  AccountsListPanel.Visible := false;
end;

procedure TfrmHome.notPrivTCA2Change(Sender: TObject);
begin
  notPrivTCA1.IsChecked := notPrivTCA2.IsChecked;
end;

procedure TfrmHome.ChangeAccountButtonClick(Sender: TObject);
var
  name: AnsiString;
  fmxObj: TfmxObject;
  Panel: TPanel;
  Button: TButton;
  AccountName: TLabel;
  i: Integer;
  Flag: Boolean;
begin

  AccountsListPanel.Visible := not AccountsListPanel.Visible;

  for i := AccountsListVertScrollBox.Content.ChildrenCount - 1 downto 0 do
  begin
    fmxObj := AccountsListVertScrollBox.Content.Children[i];

    Flag := false; //
    for name in AccountsNames do
    begin

      if name = fmxObj.TagString then
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

  for name in AccountsNames do
  begin
    Flag := true;

    for i := 0 to AccountsListVertScrollBox.Content.ChildrenCount - 1 do
    begin
      fmxObj := AccountsListVertScrollBox.Content.Children[i];

      if name = fmxObj.TagString then
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
  passwordForDecrypt.Text := '';
  MasterSeed := SpeckDecrypt(tced, CurrentAccount.EncryptedMasterSeed);
  if not isHex(MasterSeed) then
  begin
    popupWindow.Create(dictionary['FailedToDecrypt']);
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
end;

procedure TfrmHome.OrganizeButtonClick(Sender: TObject);
var
  Panel: TPanel;
  fmxObj, child, temp: TfmxObject;

  Button: TButton;
  i: Integer;

begin

  vibrate(100);
  clearVertScrollBox(OrganizeList);
  for i := 0 to WalletList.Content.ChildrenCount - 1 do
  begin
    fmxObj := WalletList.Content.Children[i];

    Panel := TPanel.Create(frmHome.OrganizeList);
    Panel.Align := TAlignLayout.Top;
    Panel.Position.Y := TPanel(fmxObj).Position.Y - 1;
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
    Button.Visible := true;
    Button.Parent := Panel;
    Button.OnClick := hideWallet;
  end;

  OrganizeList.Repaint;
  switchTab(PageControl, TTabItem(frmHome.FindComponent('dashbrd')));
  DeleteAccountLayout.Visible := true;
  Layout1.Visible := false;

  SearchInDashBrdButton.Visible := false;
  NewCryptoLayout.Visible := false;
  WalletList.Visible := false;
  OrganizeList.Visible := true;
  BackToBalanceViewLayout.Visible := true;
  btnSync.Visible := false;

end;

procedure TfrmHome.ShowHideAdvancedButtonClick(Sender: TObject);
begin

  TransactionFeeLayout.Visible := not TransactionFeeLayout.Visible;
  TransactionFeeLayout.Position.Y := Layout3.Position.Y + 1;

  if TransactionFeeLayout.Visible then
  begin
    arrowImg.Bitmap := arrowList.Source[1].MultiResBitmap[0].Bitmap;
    ShowHideAdvancedButton.Text := dictionary['HideAdvanced'];
  end
  else
  begin
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
  switchTab(PageControl, checkSeed);
end;

procedure TfrmHome.btnOKAddNewCoinSettingsClick(Sender: TObject);

begin

  Tthread.CreateAnonymousThread(
    procedure
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
      // NewCoinDescriptionPassEdit.Text := '';
      MasterSeed := SpeckDecrypt(tced, CurrentAccount.EncryptedMasterSeed);
      if not isHex(MasterSeed) then
      begin

        Tthread.Synchronize(nil,
          procedure
          begin
            popupWindow.Create(dictionary['FailedToDecrypt']);
          end);

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

        if OwnXCheckBox.IsChecked then
          newID := strtoint(OwnXEdit.Text);

        walletInfo := coindata.createCoin(newcoinID, newID, 0, MasterSeed,
          NewCoinDescriptionEdit.Text);

        CurrentAccount.AddCoin(walletInfo);
        CreatePanel(walletInfo);
        MasterSeed := '';

        switchTab(PageControl, TTabItem(frmHome.FindComponent('dashbrd')));
      end
      else
      begin

        if isHex(WIFEdit.Text) then
        begin

          APICheckCompressed(Sender);

          if (length(WIFEdit.Text) = 64) then
          begin

            Tthread.Synchronize(nil,
              procedure
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
              end);

          end
          else
          begin

            Tthread.Synchronize(nil,
              procedure
              begin
                popupWindow.Create('Private Key must have 64 characters');
              end);

            exit;
          end;

        end
        else
        begin
          if WIFEdit.Text <> PrivKeyToWIF(wifToPrivKey(WIFEdit.Text)) then
          begin

            Tthread.Synchronize(nil,
              procedure
              begin
                popupWindow.Create('Wrong WIF');
              end);

            exit;
          end;
          Data := wifToPrivKey(WIFEdit.Text);
          isCompressed := Data.isCompressed;
          out := Data.PrivKey;
        end;

        {
          else
        }

        pub := secp256k1_get_public(out , not isCompressed);
        if newcoinID = 4 then
        begin

          wd := TwalletInfo.Create(newcoinID, -1, -1,
            Ethereum_PublicAddrToWallet(pub), NewCoinDescriptionEdit.Text);
          wd.pub := pub;
          wd.EncryptedPrivKey := speckEncrypt((TCA(MasterSeed)), out);
          wd.isCompressed := isCompressed;
        end
        else
        begin
          wd := TwalletInfo.Create(newcoinID, -1, -1,
            Bitcoin_PublicAddrToWallet(pub, AvailableCoin[newcoinID].p2pk),
            NewCoinDescriptionEdit.Text);
          wd.pub := pub;
          wd.EncryptedPrivKey := speckEncrypt((TCA(MasterSeed)), out);
          wd.isCompressed := isCompressed;

        end;

        Tthread.Synchronize(nil,
          procedure
          begin
            CurrentAccount.AddCoin(wd);
            CreatePanel(wd);
          end);

        MasterSeed := '';

        if newcoinID = 4 then
        begin
          SearchTokens(wd.addr);
        end;
        Tthread.Synchronize(nil,
          procedure
          begin
            switchTab(PageControl, TTabItem(frmHome.FindComponent('dashbrd')));
          end);

      end;
      Tthread.Synchronize(nil,
        procedure
        begin
          btnSyncClick(nil);
        end);

    end).Start();
end;

procedure TfrmHome.btnChangeDescriptionClick(Sender: TObject);
begin
  ChangeDescryptionEdit.Text := CurrentCryptoCurrency.description;
  switchTab(PageControl, ChangeDescryptionScreen);
end;

procedure TfrmHome.Button8Click(Sender: TObject);
begin
  switchTab(PageControl, TTabItem(frmHome.FindComponent('dashbrd')));

end;

procedure TfrmHome.btnRestoreWalletClick(Sender: TObject);
begin
  privTCAPanel2.Visible := false;
  notPrivTCA2.IsChecked := false;
  switchTab(PageControl, RestoreOptions);
end;

procedure TfrmHome.btnRFFBackClick(Sender: TObject);
begin
  switchTab(PageControl, RestoreOptions);
end;

procedure TfrmHome.btnCreateNewWalletClick(Sender: TObject);
begin
  privTCAPanel2.Visible := false;
  notPrivTCA2.IsChecked := false;
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

  if (AccountNameEdit.Text = '') or (length(AccountNameEdit.Text) < 3) then
  begin
    popupWindow.Create(' Your wallet must have name at least 3 chars long');
    exit();
  end;

  alphaStr := dictionary['AlphaVersionWarning'];

  popupWindowYesNo.Create(
    procedure
    begin

      Tthread.CreateAnonymousThread(
        procedure
        begin
          Tthread.Synchronize(nil,
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
  CurrentAccount.SaveFiles();
  switchTab(PageControl, walletView);
end;

procedure TfrmHome.btnCTBackClick(Sender: TObject);
begin
  switchTab(PageControl, AddNewToken);
end;

procedure TfrmHome.btnExportPrivKeyClick(Sender: TObject);
begin

  decryptSeedBackTabItem := PageControl.ActiveTab;
  switchTab(PageControl, descryptSeed);
  btnDSBack.OnClick := backBtnDecryptSeed;
  btnDecryptSeed.OnClick := privateKeyPasswordCheck;

end;

procedure TfrmHome.btnANTBackClick(Sender: TObject);
begin
  switchTab(PageControl, TTabItem(frmHome.FindComponent('dashbrd')));
end;

procedure TfrmHome.btnEKSBackClick(Sender: TObject);
begin
  lblPrivateKey.Text := '';
  lblWIFKey.Text := '';
  WVTabControl.ActiveTab := WVBalance;
  switchTab(PageControl, walletView);
end;

procedure TfrmHome.btnAddManuallyClick(Sender: TObject);
begin
  switchTab(PageControl, ManuallyToken);
end;

procedure TfrmHome.btnMTBackClick(Sender: TObject);
begin
  switchTab(PageControl, ChoseToken);
end;

procedure TfrmHome.btnSyncClick(Sender: TObject);
var

  aTask: ITask;
begin
  { if PageControl.ActiveTab = walletView then
    begin
    SynchronizeCryptoCurrency(CurrentCryptoCurrency);
    reloadWalletView;
    exit;
    end; }
  // if (SyncBalanceThr=nil)and(SyncHistoryThr=nil) then
  if (frmHome.PageControl.ActiveTab = frmHome.walletView) then
    reloadWalletView;

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
  switchTab(PageControl, AddNewToken);
end;

procedure TfrmHome.btnAddNewCoinClick(Sender: TObject);
begin
  createAddWalletView();

  HexPrivKeyDefaultRadioButton.IsChecked := true;
  Layout31.Visible := false;
  WIFEdit.Text := '';
  PrivateKeySettingsLayout.Visible := false;
  NewCoinDescriptionEdit.Text := '';
  OwnXEdit.Text := '';
  OwnXCheckBox.IsChecked := false;
  Switch1.IsChecked := false;

  switchTab(PageControl, AddNewCoin);
end;

procedure TfrmHome.btnBackClick(Sender: TObject);
begin
  CurrentCryptoCurrency := nil;
  CurrentCoin := nil;
  switchTab(PageControl, TTabItem(frmHome.FindComponent('dashbrd')));
end;

procedure TfrmHome.btnQRBackClick(Sender: TObject);
begin

  CameraComponent1.Active := false;
  switchTab(PageControl, cameraBackTabItem);
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
    if amount + fee > (CurrentAccount.aggregateBalances(CurrentCoin).confirmed)
    then
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
        begin

          Tthread.CreateAnonymousThread(
            procedure
            begin
              Tthread.Synchronize(nil,
                procedure
                begin
                  if ValidateBitcoinAddress(Address) then
                  begin
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
    try
      prepareConfirmSendTabItem();
    except
      on E: Exception do
      begin
        showmessage(E.Message);
        exit();
      end;
    end;

    switchTab(PageControl, ConfirmSendTabItem);
  end;
  ConfirmSendPasswordEdit.Text := '';
end;

procedure TfrmHome.btnOCRClick(Sender: TObject);
begin
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
  Tthread.Synchronize(Tthread.CurrentThread, GetImage);
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
  scale: Double;
  ac: Account;

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

  Tthread.CreateAnonymousThread(
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

        Tthread.Synchronize(nil,
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

                  switchTab(PageControl,
                    TTabItem(frmHome.FindComponent('dashbrd')));

                end
                else
                begin
                  switchTab(PageControl,
                    TTabItem(frmHome.FindComponent('dashbrd')));
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
              else if cameraBackTabItem = TTabItem(frmHome.FindComponent
                ('dashbrd')) then
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
  RestorePasswordEdit.Text := '';
end;

procedure TfrmHome.FeeSpinChange(Sender: TObject);
var
  a: BigInteger;
begin
  if not isEthereum then
  begin
    a := ((180 * length(TwalletInfo(CurrentCryptoCurrency).UTXO) +
      (34 * 2) + 12));
    curWU := a.asInteger;
    a := (a * StrFloatToBigInteger(CurrentCoin.efee[round(FeeSpin.Value) - 1],
      CurrentCoin.decimals)) div 1024;
    a := Max(a, 999);
    wvFee.Text := BigIntegertoFloatStr(a, CurrentCoin.decimals);
    // CurrentCoin.efee[round(FeeSpin.Value) - 1] ;
    lblBlockInfo.Text := dictionary['ConfirmInNext'] + ' ' +
      IntToStr(round(FeeSpin.Value)) + ' ' + dictionary['Blocks'];
  end
  else
    FeeSpin.Value := 1.0;
end;

procedure TfrmHome.FeeToUSDUpdate(Sender: TObject);
var
  satb: Integer;
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
    if curWU = 0 then
      curWU := 440; // 2 in 2 out default
    satb := BigInteger(StrFloatToBigInteger(wvFee.Text,
      CurrentCryptoCurrency.decimals) div curWU).asInteger;

    lblFee.Text := wvFee.Text + ' (' + IntToStr(satb) + ' sat/b) ' +
      AvailableCoin[CurrentCoin.coin].shortcut + ' = ' +
      floatToStrF(CurrencyConverter.calculate(strToFloatDef(wvFee.Text,
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
  Lang, style: AnsiString;
  JSON: TJsonObject;
  Data: AnsiString;
begin

  if FileExists(System.IOUtils.TPath.Combine
    (System.IOUtils.TPath.GetDocumentsPath, 'hodler.wallet.dat')) then
  begin
    Data := Tfile.ReadAllText(System.IOUtils.TPath.Combine
      (System.IOUtils.TPath.GetDocumentsPath, 'hodler.wallet.dat'));
    if Data[low(Data)] = '{' then
    begin
      JSON := TJsonObject(TJsonObject.ParseJSONValue(Data));
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

  setBlackBackground(AccountsListVertScrollBox.Content);
end;

procedure TfrmHome.FormGesture(Sender: TObject;
const EventInfo: TGestureEventInfo; var Handled: Boolean);
begin
end;

{$IFDEF ANDROID}

procedure OnRequestPermissionsResultNative(AEnv: PJNIEnv; AThis: JNIObject;
requestCode: Integer; permissions: JNIObjectArray; granted: JNIIntArray);
var
  i: Integer;
begin

  Tthread.CreateAnonymousThread(
    procedure
    begin
      Tthread.Synchronize(nil,
        procedure
        begin
          showmessage('OK');
        end);
    end).Start;
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
        )) and (AccountsListPanel.Visible) then
      begin
        AccountsListPanel.Visible := false;
        exit;
      end
      else if ((PageControl.ActiveTab = TTabItem(frmHome.FindComponent
        ('dashbrd'))) and (not AccountsListPanel.Visible)) or
        (CurrentAccount = nil) then
      begin

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
    (CurrencyConverter.symbol);

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

                end, dictionary['CreateBackupWallet'], dictionary['Yes'],
                dictionary['NotNow'], 1);
          end);
      end).Start;

    saveSeedInfoShowed := true;
  end;

  refreshWalletDat;

end;

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
    lblWelcomeDescription.Text := dictionary['ConfigurationTakeOneStep'] +
      #13#10 + dictionary['ChooseOption'] + ':';
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
  if focused is TEdit then
    if (TEdit(focused).name = 'wvAddress') or
      (TEdit(focused).name = 'receiveAddress') then
    begin

      exit;
    end;
  X := (round(frmHome.Height * 0.5));
  KeyBoardLayout.Height := frmHome.Height + X;
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
    if swForEncryption.IsChecked then
      TCAIterations := 10000;
    CreateNewAccountAndSave(AccountNameEdit.Text, pass.Text, trngBuffer, false);
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
  { if CurrentCryptoCurrency is TwalletInfo then
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
    myURI := myURI + 'https://etherscan.io/tx/'; }
  myURI := getURLToExplorer(CurrentCoin.coin,
    StringReplace(HistoryTransactionID.Text, ' ', '', [rfReplaceAll]));
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
  for fmxObj in WalletList.Content.Children do
  begin
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
  SearchEdit.Visible := false;
  TLabel(frmHome.FindComponent('HeaderLabel')).Visible := true;
  SearchEdit.Text := '';
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
      wvAmount.Text := BigIntegertoFloatStr(0, CurrentCryptoCurrency.decimals);
      WVRealCurrency.Text := '0.00';
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
    passwordForDecrypt.Text := '';
    exit;
  end;
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
  img.free;
  Zip.free;
  passwordForDecrypt.Text := '';
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
    passwordForDecrypt.Text := '';
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
  tempText: String;
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
    passwordForDecrypt.Text := '';
    exit;
  end;

  DecodeDate(Now, Y, m, d);
  fileName := CurrentAccount.name + '_' + Format('%d.%d.%d', [Y, m, d]) + '.' +
    IntToStr(DateTimeToUnix(Now));
  zipPath := System.IOUtils.TPath.Combine
    (System.IOUtils.TPath.GetDownloadsPath(), fileName + '.hsb.zip');
  if FileExists(zipPath) then
    DeleteFile(zipPath);
  Zip := TEncryptedZipFile.Create('');
  Zip.Open(zipPath, TZipMode.zmWrite);
  img := StrToQRBitmap(CurrentAccount.EncryptedMasterSeed);
  ImgPath := System.IOUtils.TPath.Combine
    (System.IOUtils.TPath.GetDocumentsPath(), 'QREncryptedSeed.png');
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
  DeleteFile(ImgPath);
  img.free;
  Zip.free;
  switchTab(PageControl, decryptSeedBackTabItem);
  passwordForDecrypt.Text := '';
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

procedure TfrmHome.SpinBox1Change(Sender: TObject);
begin
  if SpinBox1.IsFocused then
  begin
    if SpinBox1.Value >= 10 then
      TrackBar1.Value := ((SpinBox1.Value - 10) / 5) + 10
    else
      TrackBar1.Value := SpinBox1.Value;

  end;
end;

procedure TfrmHome.switch1Switch(Sender: TObject);
begin
  PrivateKeySettingsLayout.Visible := Switch1.IsChecked;
end;

procedure TfrmHome.SearchInDashBrdButtonClick(Sender: TObject);
begin
  TLabel(frmHome.FindComponent('HeaderLabel')).Visible := false;
  SearchEdit.Visible := true;
  SetFocused(SearchEdit);
end;

{ procedure TfrmHome.SearchTokenButtonClick(Sender: TObject);
  begin

  if ((CurrentCoin.coin <> 4) or (CurrentCryptoCurrency is Token)) then
  begin

  showmessage('SearchTokenButton shouldnt be visible here');
  exit;

  end;

  SearchTokens(CurrentCoin.addr);
  end; }

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
var
  comkey: AnsiString;
  notkey: AnsiString;
  Data: AnsiString;
  ts: TStringList;
  wd: TwalletInfo;
  request: AnsiString;
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
        if newcoinID <> 4 then
        begin

          comkey := secp256k1_get_public(WIFEdit.Text, false);
          notkey := secp256k1_get_public(WIFEdit.Text, true);
          wd := TwalletInfo.Create(newcoinID, -1, -1,
            Bitcoin_PublicAddrToWallet(comkey, AvailableCoin[newcoinID].p2pk),
            'Imported');
          wd.pub := comkey;
          request := HODLER_URL + 'getSegwitBalance.php?coin=' + AvailableCoin
            [wd.coin].name + '&' + segwitParameters(wd);
          Data := getDataOverHTTP(request);
          ts := TStringList.Create();
          ts.Text := Data;
          if strToFloatDef(ts[0], 0) + strToFloatDef(ts[1], 0) = 0 then
          begin
            Data := getDataOverHTTP(HODLER_URL + 'getSegwitHistory.php?coin=' +
              AvailableCoin[wd.coin].name + '&' + segwitParameters(wd));
            if length(Data) > 10 then
            begin

              Tthread.Synchronize(nil,
                procedure
                begin
                  HexPrivKeyCompressedRadioButton.IsChecked := true;
                  ts.free;
                  ts := nil;
                  wd.free;
                  wd := nil;
                  exit;
                end);

            end;
          end
          else
          begin
            Tthread.Synchronize(nil,
              procedure
              begin
                HexPrivKeyCompressedRadioButton.IsChecked := true;
                ts.free;
                ts := nil;
                wd.free;
                wd := nil;
                exit;
              end);
          end;
          if ts <> nil then
            ts.free;
          if wd <> nil then
            wd.free;

          wd := TwalletInfo.Create(newcoinID, -1, -1,
            Bitcoin_PublicAddrToWallet(notkey,
            AvailableCoin[newcoinID].p2pk), '');
          wd.pub := comkey;

          Data := getDataOverHTTP(HODLER_URL + 'getBalance.php?coin=' +
            AvailableCoin[wd.coin].name + '&address=' + wd.addr);
          ts := TStringList.Create();
          ts.Text := Data;

          if strToFloatDef(ts[0], 0) + strToFloatDef(ts[1], 0) = 0 then
          begin
            Data := getDataOverHTTP(HODLER_URL + 'getHistory.php?coin=' +
              AvailableCoin[wd.coin].name + '&address=' + wd.addr);
            if length(Data) > 10 then
            begin
              Tthread.Synchronize(nil,
                procedure
                begin
                  HexPrivKeyNotCompressedRadioButton.IsChecked := true;
                  ts.free;
                  ts := nil;
                  wd.free;
                  wd := nil;
                  exit; // +
                end);
            end;
          end
          else
          begin
            Tthread.Synchronize(nil,
              procedure
              begin
                HexPrivKeyNotCompressedRadioButton.IsChecked := true;
                ts.free;
                ts := nil;
                wd.free;
                wd := nil;
                exit;
              end);
          end;
          if ts <> nil then
            ts.free;
          if wd <> nil then
            wd.free;

          Tthread.Synchronize(nil,
            procedure
            begin
              LoadingKeyDataAniIndicator.Enabled := false;
              LoadingKeyDataAniIndicator.Visible := false;
              Layout31.Visible := true;
            end);

          exit;
        end;
        // Parsing for ETH
        if newcoinID = 4 then
        begin

          comkey := secp256k1_get_public(WIFEdit.Text, true);

          wd := TwalletInfo.Create(newcoinID, -1, -1,
            Ethereum_PublicAddrToWallet(comkey), 'Imported');
          wd.pub := comkey;

          Tthread.Synchronize(nil,
            procedure
            begin
              LoadingKeyDataAniIndicator.Enabled := false;
              LoadingKeyDataAniIndicator.Visible := false;
              Layout31.Visible := true;
              HexPrivKeyNotCompressedRadioButton.IsChecked := true;
            end);

          wd.free;

          exit;

        end;

      end
    end

  except
    on E: Exception do
    begin
      popupWindow.Create('Private key is not valid');
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
  Tthread.CreateAnonymousThread(
    procedure
    var
      i: Integer;
    begin

      for i := 0 to 5 * 30 do
      begin
        if (TAndroidHelper.Context.checkCallingOrSelfPermission
          (StringToJString('android.permission.READ_EXTERNAL_STORAGE')) = -1)
        then
        begin
          sleep(200);
        end
        else
        begin
{$ENDIF}
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

{$IFDEF ANDROID}
              strArr := TDirectory.GetFiles(TDirectory.GetParent
                (System.IOUtils.TPath.GetSharedDownloadsPath()), '*.hsb.zip',
                TSearchOption.SoAllDirectories);
{$ELSE}
              strArr := TDirectory.GetFiles('C:\', '*.hsb.zip',
                TSearchOption.SoAllDirectories);
{$ENDIF}
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
                        length(TDirectory.GetParent(System.IOUtils.TPath.
                        GetSharedDownloadsPath())))
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
{$IFDEF ANDROID}
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
{$ELSE}
          RFFPathEdit.Text := 'C:\';
          switchTab(PageControl, RestoreFromFileTabitem);
{$ENDIF}
          end; end.
