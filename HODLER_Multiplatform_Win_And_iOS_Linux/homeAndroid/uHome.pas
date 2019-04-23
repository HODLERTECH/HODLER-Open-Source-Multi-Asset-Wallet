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
  SysUtils, System.Types, System.UITypes, System.Classes, strUtils,
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
  System.Net.HttpClientComponent, System.Net.urlclient, System.Net.HttpClient,
  popupWindowData, TCopyableAddressPanelData, TNewCryptoVertScrollBoxData,

  FMX.Media, FMX.Objects, CurrencyConverter, uEncryptedZipFile, System.Zip,
  TRotateImageData
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
  Androidapi.JNIBridge, System.Android.Service, SystemApp
{$ELSE}
{$ENDIF},
  misc, FMX.Menus,
  ZXing.BarcodeFormat,
  ZXing.ReadResult,
  ZXing.ScanManager, FMX.EditBox, FMX.SpinBox, FMX.Gestures, FMX.Effects,
  FMX.Filter.Effects, System.Actions, FMX.ActnList, System.Math.Vectors,
  FMX.Controls3D, FMX.Layers3D, FMX.StdActns, FMX.MediaLibrary.Actions,
  FMX.ComboEdit, NotificationLayoutData;

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
    wvAddressold: TEdit;
    btnOCR: TButton;
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
    TokenIcons3: TImageList;
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
    DebugEdit: TEdit;
    DebugButton: TButton;
    DebugLabel: TLabel;
    AddNewCoinSettings: TTabItem;
    ToolBar2: TToolBar;
    lblACHeader: TLabel;
    btnACBack: TButton;
    NewCoinDescriptionPanel: TPanel;
    NewCoinDescriptionEdit: TEdit;
    lblNewCoinDescription: TLabel;
    btnOKAddNewCoinSettings: TButton;
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
    SaveSeedIsImportantStaticLabel: TLabel;
    BalancePanel: TPanel;
    lblFiat: TLabel;
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
    lblSendAllFunds: TLabel;
    lblFromFee: TLabel;
    SendVertScrollBox: TVertScrollBox;
    StyleBook1: TStyleBook;
    SendAmountLayout: TLayout;
    ShowAdvancedLayout: TLayout;
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
    DebugBackButton: TButton;
    sendImage: TImage;
    receiveImage: TImage;
    txHistory: TVertScrollBox;
    Layout1: TLayout;
    receiveAddressold: TEdit;
    GenerateSeedProgressBar: TProgressBar;
    NewCoinButton: TButton;
    NewTokenButton: TButton;
    NewCryptoLayout: TLayout;
    ColorAnimation1: TColorAnimation;
    RefreshLayout: TLayout;
    RefreshWalletView: TButton;
    LayoutPresentationFee: TLayout;
    lblFeeHeader: TLabel;
    RefreshWalletViewTimer: TTimer;
    DebugRefreshTime: TLabel;
    btnWVShare: TButton;
    ShowShareSheetAction1: TShowShareSheetAction;
    KeyBoardLayout: TLayout;
    btnImageList: TImageList;
    WelcomeTabItem: TTabItem;
    HodlerLogoImageWTI: TImage;
    Layout6: TLayout;
    btnRestoreWallet: TButton;
    lblWelcome: TLabel;
    lblWelcomeDescription: TLabel;
    Layout7: TLayout;
    HodlerLogoBackGroundImageWTI: TImage;
    Layout8: TLayout;
    Layout9: TLayout;
    Layout10: TLayout;
    HodlerLogoBackGroundImageCP: TImage;
    HodlerLogoImageCP: TImage;
    Layout11: TLayout;
    lblThanks: TLabel;
    lblSetPassword: TLabel;
    btnCreateWallet: TButton;
    btnCreateNewWallet: TButton;
    DashBrdProgressBar: TProgressBar;
    RefreshProgressBar: TProgressBar;
    ConfirmedSeedVertScrollBox: TVertScrollBox;
    ConfirmedSeedFlowLayout: TFlowLayout;
    SearchEdit: TEdit;
    SearchInDashBrdButton: TSpeedButton;
    SearchLayout: TLayout;
    showHideIcons: TImageList;
    OrganizeList: TVertScrollBox;
    BackToBalanceViewButton: TButton;
    OrganizeButton: TButton;
    WalletList: TVertScrollBox;
    ShowHideAdvancedButton: TButton;
    arrowImg: TImage;
    arrowList: TImageList;
    Layout2: TLayout;
    Panel2: TPanel;
    LanguageBox: TPopupBox;
    Panel3: TPanel;
    CurrencyBox: TPopupBox;
    HistoryDetails: TTabItem;
    ToolBar1: TToolBar;
    TransactionDetailsHeaderLabel: TLabel;
    TransactionDetailsBackButton: TButton;
    HistoryTransactionVertScrollBox: TVertScrollBox;
    HistoryTransactionSendReceive: TLabel;
    HistoryTransactionStatusLabel: TLabel;
    HistoryTransactionDateLabel: TLabel;
    Layout16: TLayout;
    TransactionIDStaticLabel: TLabel;
    HistoryTransactionID: TLabel;
    Layout17: TLayout;
    Layout18: TLayout;
    Layout19: TLayout;
    Layout20: TLayout;
    Layout21: TLayout;
    DetailsAddressListStaticLabel: TLabel;
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
    FilesManagerScrollBox: TVertScrollBox;
    RestoreFromFileTabitem: TTabItem;
    RestoreFromFileConfirmButton: TButton;
    RFFHeader: TToolBar;
    RFFHeaderLabel: TLabel;
    btnRFFBack: TButton;
    RFFPassword: TEdit;
    RFFPasswordInfo: TLabel;
    Layout24: TLayout;
    DirectoryImage: TImage;
    HSBIcon: TImage;
    SendDecryptedSeedButton: TButton;
    RestoreFromStringSeedButton: TButton;
    RestoreSeedEncryptedQRButton: TButton;
    LinkLayout: TLayout;
    linkLabel: TLabel;
    bpmnemonicLayout: TLayout;
    MnemonicSeedDescriptionLabel: TLabel;
    HSBbackupLayout: TLayout;
    HSBDescriptionLabel: TLabel;
    EncrypredQRBackupLayout: TLayout;
    EncryptedQRDescriptionLabel: TLabel;
    Layout28: TLayout;
    DecryptedQRDescriptionLabel: TLabel;
    VertScrollBox1: TVertScrollBox;
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
    switchLegacyp2pkhButton: TButton;
    switchCompatiblep2shButton: TButton;
    SwitchSegwitp2wpkhButton: TButton;
    AddressTypelayout: TLayout;
    QRCodeRecvLayout: TLayout;
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
    IPKheaderLabel: TLabel;
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
    RestoreWalletWithPassword: TTabItem;
    RestoreWalletOKButton: TButton;
    Panel6: TPanel;
    RestoreNameEdit: TEdit;
    RestoreWalletNameLabel: TLabel;
    Panel7: TPanel;
    RestorePasswordEdit: TEdit;
    RWPPasswordLabel: TLabel;
    ToolBar6: TToolBar;
    RWPHeaderLabel: TLabel;
    RWWPBackButton: TButton;
    btnImportCoinomi: TButton;
    btnImportExodus: TButton;
    btnImportLadgerNanoS: TButton;
    RestoreHSBButton: TButton;
    Layout35: TLayout;
    btnRestoreSeed: TButton;
    btnRestoreEncQR: TButton;
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
    HSBPassHeaderLabel: TLabel;
    HSBPasswordBackBtn: TButton;
    Layout23: TLayout;
    Layout36: TLayout;
    SystemTimer: TTimer;
    updateBtn: TButton;
    SearchTokenButton: TButton;
    ScrollBox: TVertScrollBox;
    ScrollKeeper: TTimer;
    TCAInfoPanel: TCalloutPanel;
    TCAWaitingLabel: TLabel;
    TransactionWaitForSend: TTabItem;
    TransactionWaitForSendAniIndicator: TAniIndicator;
    Panel13: TPanel;
    TransactionWaitForSendDetailsLabel: TLabel;
    TransactionWaitForSendLinkLabel: TLabel;
    TransactionWaitForSendBackButton: TButton;
    ConfirmSendTabItem: TTabItem;
    SendTransactionButton: TButton;
    ToolBar8: TToolBar;
    ConfirmSendHeaderLabel: TLabel;
    CSBackButton: TButton;
    ConfirmSendPasswordPanel: TPanel;
    ConfirmSendPasswordEdit: TEdit;
    ConfirmSendPasswordLabel: TLabel;
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
    IsPrivKeySwitch: TSwitch;
    ImportPrivKeyStaticLabel: TLabel;
    Layout52: TLayout;
    ImportPrivateKeyButton: TButton;
    StatusBarFixer: TRectangle;
    privTCAPanel1: TPanel;
    PreAlphaWalletLabel: TLabel;
    notPrivTCA1: TCheckBox;
    privTCAPanel2: TPanel;
    PreAlphaImportLabel: TLabel;
    notPrivTCA2: TCheckBox;
    SameYWalletList: TTabItem;
    YaddressesVertScrollBox: TVertScrollBox;
    changeYbutton: TButton;
    StyloSwitch: TPanel;
    DayNightModeStaticLabel: TLabel;
    YAddresses: TLayout;
    FindUnusedAddressButton: TButton;
    PasswordForGenerateYAddressesTabItem: TTabItem;
    NewYaddressesOKButton: TButton;
    Label20: TLabel;
    ToolBar9: TToolBar;
    GNAHeaderLabel: TLabel;
    GNABackBtn: TButton;
    Panel9: TPanel;
    GenerateYAddressPasswordEdit: TEdit;
    YaddressesPasswordLabel: TLabel;
    CalloutPanel1: TCalloutPanel;
    TCAGNAWaitLabel: TLabel;
    TrackBar1: TTrackBar;
    AmountNewAddressesLabel: TLabel;
    Panel14: TPanel;
    SpinBox1: TSpinBox;
    Layout57: TLayout;
    btnNewAddress: TButton;
    btnPrevAddress: TButton;
    QREnlargeLabel: TLabel;
    BigQRCode: TTabItem;
    BigQRCodeImage: TImage;
    Panel15: TPanel;
    OwnXCheckBox: TCheckBox;
    OwnXEdit: TEdit;
    HexFormatLabel: TLabel;
    WIFFormatLabel: TLabel;
    layoutForPrivQR: TLayout;
    HideZeroWalletsCheckBox: TCheckBox;
    Panel16: TPanel;
    PasswordInfoStaticLabel: TLabel;
    LayoutPerByte: TLayout;
    PerByteFeeRatio: TRadioButton;
    PerByteFeeEdit: TEdit;
    LoadMore: TButton;
    RavencoinAddrTypeLayout: TLayout;
    LegacyRavenAddrButton: TButton;
    SegwitRavenAddrButton: TButton;
    InstantSendLayout: TLayout;
    Layout5: TLayout;
    Label5: TLabel;
    PrivateSendLayout: TLayout;
    Label3: TLabel;
    Layout12: TLayout;
    Switch1: TSwitch;
    CopyButtonPitStopEdit: TEdit;
    CopyTextButton: TButton;
    SelectGenetareCoin: TTabItem;
    ToolBar10: TToolBar;
    SGCHeaderLabel: TLabel;
    BackBtnSGC: TButton;
    NextButtonSGC: TButton;
    Panel17: TPanel;
    SelectGenerateCoinStaticLabel: TLabel;
    GenerateCoinVertScrollBox: TVertScrollBox;
    ClaimTabItem: TTabItem;
    ToolBar11: TToolBar;
    CTIHeaderLabel: TLabel;
    CTIHeaderBackButton: TButton;
    Panel18: TPanel;
    PrivateKeyEditSV: TEdit;
    ClaimCoinPrivKeyStaticLabel: TLabel;
    CompressedPrivKeySVCheckBox: TCheckBox;
    Panel19: TPanel;
    AddressSVEdit: TEdit;
    DestinationAddressStaticLabel: TLabel;
    ClaimYourBCHSVButton: TButton;
    ClaimWalletListTabItem: TTabItem;
    ClaimCoinListVertScrollBox: TVertScrollBox;
    Button4: TButton;
    Panel20: TPanel;
    SelectCoinToClaimStaticLabel: TLabel;
    ToolBar12: TToolBar;
    ClaimWalletListHeaderLabel: TLabel;
    ClaimListBackButton: TButton;
    ConfirmSendClaimCoinButton: TButton;
    BCHSVBCHABCReplayProtectionLabel: TLabel;
    MainScreenQRButton: TButton;
    AddCoinFromPrivQRButton: TButton;
    WalletTransactionListTabItem: TTabItem;
    WalletTransactionVertScrollBox: TVertScrollBox;
    Button6: TButton;
    Panel10: TPanel;
    QRCodeFindAddressStaticLabel: TLabel;
    ToolBar13: TToolBar;
    QRAddressSelectWalletHeaderLabel: TLabel;
    QRAddressSelectWalletBackButton: TButton;
    AddCoinFromPrivKeyTabItem: TTabItem;
    ToolBar14: TToolBar;
    AddCoinFromPrivHeaderLabel: TLabel;
    AddCoinFromPrivBackButton: TButton;
    Panel21: TPanel;
    CoinPrivKeyDescriptionEdit: TEdit;
    CoinPrivKeyDescriptionStaticLabel: TLabel;
    Panel22: TPanel;
    CoinPrivKeyPassEdit: TEdit;
    CoinPrivKeyPassStaticLabel: TLabel;
    NewCoinPrivKeyOKButton: TButton;
    ImportPrivKeyLabel: TLabel;
    Layout31: TLayout;
    StaticLabelPriveteKetInfo: TLabel;
    Layout34: TLayout;
    HexPrivKeyDefaultRadioButton: TRadioButton;
    HexPrivKeyCompressedRadioButton: TRadioButton;
    HexPrivKeyNotCompressedRadioButton: TRadioButton;
    Layout51: TLayout;
    LoadingKeyDataAniIndicator: TAniIndicator;
    WIFEdit: TEdit;
    PrivateKeyManageButton: TButton;
    ExportPrivCoinListTabItem: TTabItem;
    Panel23: TPanel;
    ExportPrivSelectAddressStaticLabel: TLabel;
    ToolBar16: TToolBar;
    EPCLTIHeaderLabel: TLabel;
    EPCLTIBackButton: TButton;
    ExportPrivKeyListVertScrollBox: TVertScrollBox;
    PrivOptionsTabItem: TTabItem;
    ToolBar15: TToolBar;
    PrivOptionsStaticLabel: TLabel;
    ImportPrivateKeyInPrivButton: TButton;
    SweepButton: TButton;
    ExportPrivateKeyButton: TButton;
    historyTransactionConfirmation: TEdit;
    HistoryTransactionDate: TEdit;
    HistoryTransactionValue: TEdit;
    EQRView: TTabItem;
    EQRHeader: TToolBar;
    eqrHeaderLabel: TLabel;
    EQRBackBtn: TButton;
    EQRShareBtn: TButton;
    eqrVertScrollBox: TVertScrollBox;
    EQRPreview: TImage;
    EQRInstrction: TMemo;
    lblEQRDescription: TLabel;
    FiatShortcutLayout: TLayout;
    ShortcutFiatLabel: TLabel;
    ShortcutFiatShortcutLabel: TLabel;
    Layout4: TLayout;
    NameShortcutLabel: TLabel;
    TopInfoConfirmedFiatLabel: TLabel;
    TopInfoUnconfirmedFiatLabel: TLabel;
    Layout25: TLayout;
    Layout26: TLayout;
    Layout27: TLayout;
    ToolBar17: TToolBar;
    SYWLHeaderLabel: TLabel;
    SYWLBackButton: TButton;
    GlobalRefreshLayout: TLayout;
    Layout32: TLayout;
    PrivOptionsBackButton: TButton;
    SweepQRButton: TButton;
    GridPanelLayout1: TGridPanelLayout;
    FiatStaticLabel: TLabel;
    WelcometabFiatPopupBox: TPopupBox;
    ThankStaticLabel: TLabel;
    SuggestionsStaticLabel: TLabel;
    ContactAddressStaticLabel: TLabel;
    BTCNoTransactionLayout: TLayout;
    motransactionStaticLabel: TLabel;
    BuyBTCOnLabel: TLabel;
    Image1: TImage;
    coinbaseImage: TImage;
    Layout37: TLayout;
    emptyAddressesLayout: TLayout;
    NoPrivateKeyToExportLabel: TLabel;
    Layout58: TLayout;
    exportemptyAddressesLabel: TLabel;
    LoadAddressesToImortAniIndicator: TAniIndicator;
    GlobalSettingsLayout: TLayout;
    SettingsVertScrollBox: TVertScrollBox;
    LocalSettingsLayout: TLayout;
    GlobalStetingsStaticLabel: TLabel;
    AboutHodlerButton: TButton;
    AboutHodlerTabItem: TTabItem;
    ToolBar18: TToolBar;
    AHWHeaderLabel: TLabel;
    AHWBackButton: TButton;
    AboutHodlerStaticLabel: TLabel;
    AboutHodlerLogo: TImage;
    PrivacyAndSecuritySettings: TTabItem;
    ToolBar19: TToolBar;
    SaPHeaderLabel: TLabel;
    Panel24: TPanel;
    SendErrorMsgLabel: TLabel;
    PrivacyAndSecurityButton: TButton;
    reportIssuesSettingsButton: TButton;
    SecurityInfoStaticLabel: TLabel;
    ReportIssues: TTabItem;
    ToolBar20: TToolBar;
    ReportIssueHeaderLabel: TLabel;
    ReportIssuesBackButton: TButton;
    UserReportMessageMemo: TMemo;
    DescribeStaticLabel: TLabel;
    supportEmailStaticLabel: TLabel;
    Panel25: TPanel;
    UserReportSendLogsLabel: TLabel;
    Panel26: TPanel;
    UserReportDeviceInfoLabel: TLabel;
    PrivateKeyInfoPanel: TPanel;
    PrivateKeyAddressInfoLabel: TLabel;
    PrivateKeyBalanceInfoLabel: TLabel;
    lblPrivateKey: TMemo;
    lblWIFKey: TMemo;
    Layout33: TLayout;
    FoundTokenTabItem: TTabItem;
    ToolBar21: TToolBar;
    FoundTokenHeaderLabel: TLabel;
    FoundTokenVertScrollBox: TVertScrollBox;
    SaPBackButton: TButton;
    KeypoolSanitizer: TTimer;
    FoundTokenOKButton: TButton;
    ChooseHSBStaticLabel: TLabel;
    OpenFileMenagerLayout: TLayout;
    OpenFileMenagerLabel: TLabel;
    OpenFileStaticLabel: TLabel;
    FileMenagerUpImageButton: TImage;
    FileManagerPathLabel: TEdit;
    FileMenagerCancelButton: TButton;
    internalImage: TImage;
    OpenFMParentLayout: TLayout;
    SendAllFundsSwitch: TCheckBox;
    FeeFromAmountSwitch: TCheckBox;
    InstantSendSwitch: TCheckBox;
    DayNightModeSwitch: TCheckBox;
    MoreImage: TImage;
    SearchInDashBrdImage: TImage;
    exportemptyaddressesSwitch: TCheckBox;
    SendErrorMsgSwitch: TCheckBox;
    UserReportSendLogsSwitch: TCheckBox;
    UserReportDeviceInfoSwitch: TCheckBox;
    Layout22: TLayout;
    LightButtonQR: TButton;
    DebugQRImage: TImage;
    AddWalletList: TTabItem;
    ToolBar22: TToolBar;
    AddWalletListHeaderLabel: TLabel;
    AddWalletLiistButtonBack: TButton;
    VertScrollBox3: TVertScrollBox;
    CoinListLayout: TLayout;
    TokenListLayout: TLayout;
    CoinheaderLabel: TLabel;
    TokenHeaderLabel: TLabel;
    AddWalletButton: TButton;
    NanoUnlocker: TButton;
    SendReportIssuesButton: TButton;
    UnlockNanoImage: TImage;
    btnAddContract: TButton;
    btnAddManually: TButton;
    FindERC20autoButton: TButton;
    AddCurrencyListTabItem: TTabItem;
    ToolBar23: TToolBar;
    AddNewCryptoHeaderLabel: TLabel;
    // Label31: TLabel;
    CreateCurrencyFromList: TButton;
    AddNewCryptoCurrencyButton: TButton;
    AddNewCryptoBackButton: TButton;

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
    procedure DebugButtonClick(Sender: TObject);
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
    procedure FeeToUSDUpdate(Sender: TObject);
    procedure syncTimerTimer(Sender: TObject);
    procedure CopyToClipboard(Sender: TObject;
      const EventInfo: TGestureEventInfo; var Handled: Boolean);
    procedure wvAmountChange(Sender: TObject);
    procedure wvAmountTyping(Sender: TObject);
    procedure ReceiveReatToCoin(Sender: TObject);
    procedure changeAddressUniversal(Sender: TObject);
    procedure changeAddressBech32(Sender: TObject);
    procedure DebugBackButtonClick(Sender: TObject);
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
    procedure ClaimYourBCHSVButtonClick(Sender: TObject);
    procedure btnCreateWalletClick(Sender: TObject);
    procedure FormKeyUp(Sender: TObject; var Key: Word; var KeyChar: Char;
      Shift: TShiftState);
    procedure OnCloseDialog(Sender: TObject; const AResult: TModalResult);
    procedure ShowHideAdvancedButtonClick(Sender: TObject);
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
    procedure receiveAddressoldChange(Sender: TObject);
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
    procedure HSBPasswordBackBtnClick(Sender: TObject);
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
    procedure IsPrivKeySwitchSwitch(Sender: TObject);
    procedure AccountsListPanelMouseLeave(Sender: TObject);
    procedure AccountsListPanelExit(Sender: TObject);
    procedure notPrivTCA2Change(Sender: TObject);
    procedure changeYbuttonClick(Sender: TObject);
    procedure DayNightModeSwitchSwitch(Sender: TObject);
    procedure FindUnusedAddressButtonClick(Sender: TObject);
    procedure TrackBar1Change(Sender: TObject);
    procedure SpinBox1Change(Sender: TObject);
    procedure backBtnDecryptSeed(Sender: TObject);
    procedure QRCodeImageClick(Sender: TObject);
    procedure BigQRCodeImageClick(Sender: TObject);
    procedure OwnXCheckBoxChange(Sender: TObject);
    procedure WVsendTOChange(Sender: TObject);
    procedure WVsendTOKeyDown(Sender: TObject; var Key: Word; var KeyChar: Char;
      Shift: TShiftState);
    procedure WVsendTOTyping(Sender: TObject);
    procedure HideZeroWalletsCheckBoxChange(Sender: TObject);
    procedure QRChangeTimerTimer(Sender: TObject);
    procedure SendAllFundsSwitchClick(Sender: TObject);
    procedure LoadMoreClick(Sender: TObject);
    procedure PerByteFeeEditChangeTracking(Sender: TObject);
    procedure InstantSendSwitchClick(Sender: TObject);
    procedure FormFocusChanged(Sender: TObject);
    procedure CopyTextButtonClick(Sender: TObject);
    procedure NextButtonSGCClick(Sender: TObject);
    procedure generateNewAddressClick(Sender: TObject);
    procedure PanelSelectGenerateCoinOnClick(Sender: TObject);
    procedure NewYaddressesOKButtonClick(Sender: TObject);
    procedure MainScreenQRButtonClick(Sender: TObject);
    procedure AddCoinFromPrivQRButtonClick(Sender: TObject);
    procedure PrivateKeyManageButtonClick(Sender: TObject);
    procedure ImportPrivateKeyInPrivButtonClick(Sender: TObject);
    procedure SweepButtonClick(Sender: TObject);
    procedure ExportPrivateKeyButtonClick(Sender: TObject); overload;
    procedure PrivOptionsBackButtonClick(Sender: TObject);
    procedure EPCLTIBackButtonClick(Sender: TObject);
    procedure CTIHeaderBackButtonClick(Sender: TObject);
    procedure EQRBackBtnClick(Sender: TObject);
    procedure EQRShareBtnClick(Sender: TObject);
    procedure EQRShareBtnTap(Sender: TObject; const Point: TPointF);
    procedure SYWLBackButtonClick(Sender: TObject);
    procedure ClaimListBackButtonClick(Sender: TObject);
    procedure SweepQRButtonClick(Sender: TObject);
    procedure NewCoinPrivKeyOKButtonClick(Sender: TObject);
    procedure btnChangeDescryptionBackClick(Sender: TObject);
    procedure coinbaseImageClick(Sender: TObject);
    procedure exportemptyaddressesSwitchClick(Sender: TObject);
    procedure SYWLBackButtonTap(Sender: TObject; const Point: TPointF);
    procedure ConfirmSendClaimCoinButtonClick(Sender: TObject);
    procedure AboutHodlerButtonClick(Sender: TObject);
    procedure PrivacyAndSecurityButtonClick(Sender: TObject);
    procedure reportIssuesSettingsButtonClick(Sender: TObject);
    procedure SendErrorMsgSwitchSwitch(Sender: TObject);
    procedure SendReportIssuesButtonClick(Sender: TObject);
    procedure FoundTokenOKButtonClick(Sender: TObject);
    procedure SaPBackButtonClick(Sender: TObject);
    procedure KeypoolSanitizerTimer(Sender: TObject);
    procedure FileMenagerCancelButtonClick(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure wvFeeChange(Sender: TObject);
    procedure LightButtonQRClick(Sender: TObject);
    procedure AddWalletButtonClick(Sender: TObject);
    procedure MineNano(Sender: TObject);
    procedure NanoUnlockerClick(Sender: TObject);
    procedure lblSendAllFundsClick(Sender: TObject);
    procedure lblFromFeeClick(Sender: TObject);
    procedure Label5Click(Sender: TObject);
    procedure UnlockNanoImageClick(Sender: TObject);
    procedure UnlockNanoImageTap(Sender: TObject; const Point: TPointF);
    procedure BackBtnSGCClick(Sender: TObject);
    procedure AddNewCryptoCurrencyButtonClick(Sender: TObject);
    procedure CreateCurrencyFromListClick(Sender: TObject);
    procedure AddNewCryptoBackButtonClick(Sender: TObject);
    // procedure DayNightModeSwitchClick(Sender: TObject);

  private
    { Private declarations }

    procedure GetImage();
  public
    { Public declarations }
    FServiceConnection: TLocalServiceConnection;
    FScanManager: TScanManager;
    FScanInProgress: Boolean;
    FFrameTake: Integer;
{$IFDEF ANDROID}
    procedure RegisterDelphiNativeMethods();
{$ENDIF}
    procedure ExportPrivKeyListButtonClick(Sender: TObject); overload;
    procedure ExportPrivKeyListButtonClick(Sender: TObject;
      const Point: TPointF); overload;
    // procedure ExportPrivateKeyButtonClick(Sender: TObject; const Point: TPointF);overload;
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
    procedure generateNewAddressesClick(Sender: TObject);
    procedure CoinListCreateFromSeed(Sender: TObject);
    procedure CoinListCreateFromQR(Sender: TObject);
    procedure ClaimCoinSelectInListClick(Sender: TObject);
    procedure TransactionWalletListClick(Sender: TObject);
    procedure CopyParentTagStringToClipboard(Sender: TObject);
    procedure CopyParentTextToClipboard(Sender: TObject);

    procedure RefreshCurrentWallet(Sender: TObject);
    procedure ExceptionHandler(Sender: TObject; E: Exception);
    procedure FoundTokenPanelOnClick(Sender: TObject);
    procedure GenerateETHAddressWithToken(Sender: TObject);

    procedure AddTokenFromWalletList(Sender: TObject);
    procedure AddNewTokenETHPanelClick(Sender: TObject);

  var
    refreshLocalImage: TRotateImage;
    refreshGlobalImage: TRotateImage;
    NotificationLayout: TNotificationLayout;
    receiveAddress, wvAddress: TCopyableAddressPanel;
    newCryptoVertScrollBox: TNewCryptoVertScrollBox;

  var
    cpTimeout: int64;
    shown: Boolean;
    isTokenTransfer: Boolean;
    MovingPanel: TPanel;
    ToMove: TPanel;
    Grab: Boolean;
    procCreateWallet: procedure(Sender: TObject) of Object;
    SourceDictionary: TObjectDictionary<AnsiString, WideString>;
    onFileManagerSelectClick: TProc;
    curWU: Integer;
    CurrencyConverter: tCurrencyConverter;
  end;

procedure requestForPermission(permName: AnsiString);
procedure switchTab(TabControl: TTabControl; TabItem: TTabItem);

const
  SYSTEM_APP: Boolean = {$IFDEF ANDROID}false{$ELSE}false{$ENDIF};
  // Load OS.xml as manifest and place app in /system/priv-app

var
  frmHome: TfrmHome;
  trngBuffer: AnsiString;
  trngBufferCounter: Integer;
  stylo: TStyleManager;
  QRCodeBitmap: TBitmap;
  // newcoinID: nativeint;   // in misc
  walletAddressForNewToken: AnsiString;
  tempMasterSeed: AnsiString;
  decryptSeedBackTabItem: TTabItem;
  cameraBackTabItem: TTabItem;
  dashboardDecimalsPrecision: Integer = 6;

  flagWVPrecision: Boolean = true;
  CurrentCryptoCurrency: CryptoCurrency;
  CurrentCoin: TwalletInfo;

  duringHistorySync: Boolean = false;
  QRWidth: Integer = -1;
  QRHeight: Integer = -1;
  SyncBalanceThr: SynchronizeBalanceThread;

  QRFind: AnsiString;
  tempQRFindEncryptedSeed: AnsiString;
  // AccountsNames: array of AnsiString;
  lastClosedAccount: AnsiString;
  CurrentAccount: Account;
  CurrentStyle: AnsiString;
  BigQRCodeBackTab: TTabItem;
  // ImportCoinID: Integer;    // in misc

  ToClaimWD, FromClaimWD: TwalletInfo;

resourcestring
  QRSearchEncryted = 'QRSearchEncryted';
  QRSearchDecryted = 'QRSearchDecryted';

  // resourcestring
  // CURRENT_VERSION = '0.3.2';

var
  LATEST_VERSION: AnsiString;

implementation

uses ECCObj, Bitcoin, Ethereum, secp256k1, uSeedCreation, coindata, base58,
  AccountRelated,
  TokenData, QRRelated, FileManagerRelated, WalletViewRelated, BackupRelated,
  debugAnalysis, KeypoolRelated, Nano;
{$R *.fmx}
{$R *.SmXhdpiPh.fmx ANDROID}
{$R *.iPhone55in.fmx IOS}
{$R *.Windows.fmx MSWINDOWS}
{$R *.Surface.fmx MSWINDOWS}

procedure TfrmHome.AddWalletButtonClick(Sender: TObject);
var
  panel: TPanel;
  coinName: TLabel;
  balLabel: TLabel;
  coinIMG: TImage;
  i: Integer;
  countToken: Integer;

begin

  WalletViewRelated.AddWalletButtonClick(Sender);

end;

procedure TfrmHome.AddTokenFromWalletList(Sender: TObject);
begin

  WalletViewRelated.AddTokenFromWalletList(Sender);

end;

procedure TfrmHome.AddNewTokenETHPanelClick(Sender: TObject);
var
  T: Token;
  holder: TfmxObject;
begin

  WalletViewRelated.AddNewTokenETHPanelClick(Sender);

end;

procedure TfrmHome.GenerateETHAddressWithToken(Sender: TObject);
begin
  WalletViewRelated.GenerateETHAddressWithToken(Sender);
end;

procedure TfrmHome.FoundTokenPanelOnClick(Sender: TObject);
begin
  TCheckBox(TfmxObject(Sender).TagObject).IsChecked :=
    not TCheckBox(TfmxObject(Sender).TagObject).IsChecked;
end;

procedure TfrmHome.ExceptionHandler(Sender: TObject; E: Exception);
begin
  debugAnalysis.ExceptionHandler(Sender, E);
end;

procedure TfrmHome.RefreshCurrentWallet(Sender: TObject);
begin
  WalletViewRelated.RefreshCurrentWallet(Sender);
end;

procedure TfrmHome.EQRBackBtnClick(Sender: TObject);
begin
  switchTab(PageControl, BackupTabItem);
end;

procedure TfrmHome.EQRShareBtnClick(Sender: TObject);
begin
  shareFile(System.IOUtils.TPath.Combine(
{$IFDEF MSWINDOWS}HOME_PATH{$ELSE}System.IOUtils.TPath.GetDownloadsPath
    (){$ENDIF}, CurrentAccount.name + '_EQR_BIG' + '.png'), false);
end;

procedure TfrmHome.EQRShareBtnTap(Sender: TObject; const Point: TPointF);
begin
  shareFile(System.IOUtils.TPath.Combine(
{$IFDEF MSWINDOWS}HOME_PATH{$ELSE}System.IOUtils.TPath.GetDownloadsPath
    (){$ENDIF}, CurrentAccount.name + '_EQR_BIG' + '.png'), false);
end;

procedure TfrmHome.exportemptyaddressesSwitchClick(Sender: TObject);
begin
  createExportPrivateKeyList(newCoinID);
end;

procedure TfrmHome.ExportPrivateKeyButtonClick(Sender: TObject);
begin
  WalletViewRelated.ExportPrivateKeyButtonClick(Sender);
end;

procedure TfrmHome.ExportPrivKeyListButtonClick(Sender: TObject;
  const Point: TPointF);
begin
  WalletViewRelated.ExportPrivKeyListButtonClick(Sender);
end;

procedure TfrmHome.ExportPrivKeyListButtonClick(Sender: TObject);
begin
  WalletViewRelated.ExportPrivKeyListButtonClick(Sender);
end;

procedure TfrmHome.CopyParentTextToClipboard(Sender: TObject);
begin
  WalletViewRelated.CopyParentTextToClipboard(Sender);
end;

procedure TfrmHome.CopyParentTagStringToClipboard(Sender: TObject);
begin
  WalletViewRelated.CopyParentTagStringToClipboard(Sender);
end;

procedure TfrmHome.TransactionWalletListClick(Sender: TObject);
begin
  OpenWalletView(Sender);
  switchTab(WVTabControl, WVSend);
  WVsendTO.Text := addressfromQR;
  wvAmount.Text := amountFromQR;
  WVRealCurrency.Text :=
    floatToStrF(CurrencyConverter.calculate(strToFloatDef(wvAmount.Text, 0)) *
    (CurrentCryptoCurrency.rate), ffFixed, 18, 2);
end;

procedure TfrmHome.ClaimCoinSelectInListClick(Sender: TObject);
begin

  ToClaimWD := TwalletInfo(TfmxObject(Sender).TagObject);
  switchTab(PageControl, ClaimTabItem);

end;

procedure TfrmHome.ClaimListBackButtonClick(Sender: TObject);
begin
  switchTab(PageControl, AddNewCoin);
end;

procedure TfrmHome.CoinListCreateFromSeed(Sender: TObject);
begin
  TThread.CreateAnonymousThread(
    procedure
    begin
      TThread.Synchronize(nil,
        procedure
        begin

          procCreateWallet(nil);

        end);
    end).Start;
end;

procedure TfrmHome.CoinListCreateFromQR(Sender: TObject);
var
  MasterSeed, tced: AnsiString;
begin

  tced := TCA(RestorePasswordEdit.Text);
  MasterSeed := SpeckDecrypt(tced, tempQRFindEncryptedSeed);

  CreateNewAccountAndSave(RestoreNameEdit.Text, RestorePasswordEdit.Text,
    MasterSeed, true);
  startFullfillingKeypool(MasterSeed);
  // frmHome.FormShow(nil);
  tced := '';
  MasterSeed := '';
  RestorePasswordEdit.Text := '';
end;

procedure TfrmHome.PanelSelectGenerateCoinOnClick(Sender: TObject);
begin

  if (not TCheckBox(TfmxObject(Sender).TagObject).Enabled) then
    exit();
  TCheckBox(TfmxObject(Sender).TagObject).IsChecked :=
    (not TCheckBox(TfmxObject(Sender).TagObject).IsChecked);

end;

procedure TfrmHome.OpenWalletViewFromYWalletList(Sender: TObject);
begin
  OpenWalletView(Sender);

  WVTabControl.ActiveTab := WVReceive;
end;

procedure TfrmHome.deleteYaddress(Sender: TObject);
begin
  AccountRelated.deleteYaddress(Sender);
end;

procedure TfrmHome.YAddressClick(Sender: TObject);
begin
  generateNewYAddress(Sender);
end;

procedure TfrmHome.removeAccount(Sender: TObject);
begin
  AccountRelated.removeAccount(Sender);
end;

procedure TfrmHome.reportIssuesSettingsButtonClick(Sender: TObject);
begin
  switchTab(PageControl, ReportIssues);
end;

procedure TfrmHome.QRChangeTimerTimer(Sender: TObject);
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
  QRRelated.changeQR(Sender);
end;

procedure TfrmHome.QRCodeImageClick(Sender: TObject);
begin

  EnlargeQRCode(QRCodeImage.Bitmap);
end;

procedure TfrmHome.importPrivCoinListPanelClick(Sender: TObject);
begin
  ImportCoinID := TfmxObject(Sender).tag;

  switchTab(PageControl, ImportPrivKeyTabItem);
end;

/// ////////////////////////////////FILE MANAGER///////////////////////////////////////
procedure DrawDirectoriesAndFiles(Inputpath: AnsiString);
begin
  FileManagerRelated.DrawFM(Inputpath);
end;

procedure TfrmHome.FilePanelClick(Sender: TObject);
begin
  frmHome.FileManagerPathLabel.Text := TfmxObject(Sender).TagString;
  onFileManagerSelectClick();
end;

procedure TfrmHome.FilePanelClick(Sender: TObject; const Point: TPointF);
begin
  FilePanelClick(Sender);
end;

procedure TfrmHome.generateNewAddressesClick(Sender: TObject);
begin
  generateNewYAddress(Sender);
end;

procedure TfrmHome.FindERC20autoButtonClick(Sender: TObject);
begin
  WalletViewRelated.FindERC20autoButtonClick(Sender);
end;

procedure TfrmHome.FindUnusedAddressButtonClick(Sender: TObject);
begin
  FindUnusedAddress(Sender);
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
  AccountRelated.DeleteAccount(Sender);
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

procedure TfrmHome.FileMenagerCancelButtonClick(Sender: TObject);
begin
  switchTab(PageControl, RestoreFromFileTabitem);
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
  panel: TPanel;
  lbl: TLabel;

begin
  onFileManagerSelectClick := onSelect;

{$IFDEF ANDROID}
  // showmessage(System.IOUtils.TPath.GetSharedDownloadsPath);
  DrawDirectoriesAndFiles(System.IOUtils.TPath.GetSharedDownloadsPath);
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
begin
  WalletViewRelated.ShowHistoryDetails(Sender);
end;

procedure TfrmHome.hideWallet(Sender: TObject);
begin
  WalletViewRelated.walletHide(Sender);
end;

procedure TfrmHome.HideZeroWalletsCheckBoxChange(Sender: TObject);
begin
  WalletViewRelated.HideEmptyWallets(Sender);
  CurrentAccount.SaveFiles;
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
  Os: TOSVersion;

begin

  if Os.major < 6 then
  begin
    exit;
  end;

  strArray := TJavaObjectArray<JString>.Create(1);
  strArray.Items[0] := TAndroidHelper.StringToJString(permName);
  SharedActivity.requestPermissions(strArray, 1337);
  strArray.free;

end; {$ELSE}

begin

end;
{$ENDIF}

procedure TfrmHome.decryptSeedForSeedRestore(Sender: TObject);
begin
  BackupRelated.decryptSeedForRestore(Sender);
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

  if ToMove = nil then
    exit;

  ToMove.Position.Y := Y + OrganizeList.ViewportPosition.Y - ToMove.Height / 2;
  ToMove.Opacity := 1;

  MovingPanel.DisposeOf;
  OrganizeList.AniCalculations.TouchTracking := [ttVertical];
  ToMove := nil;

end;

procedure TfrmHome.OwnXCheckBoxChange(Sender: TObject);
begin
  if OwnXCheckBox.IsFocused then
  begin

    OwnXEdit.Enabled := OwnXCheckBox.IsChecked;
    IsPrivKeySwitch.Enabled := not OwnXCheckBox.IsChecked;

    if OwnXCheckBox.IsChecked then
    begin

      IsPrivKeySwitch.IsChecked := false;
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
  MovingPanel.parent := OrganizeList;
  OrganizeList.Root.Captured := OrganizeList;
  MovingPanel.BringToFront;
  MovingPanel.Repaint;
  Grab := true;
  TPanel(Sender).Opacity := 0.5;
  OrganizeList.AniCalculations.TouchTracking := [];
end;

procedure TfrmHome.PerByteFeeEditChangeTracking(Sender: TObject);
var
  temp: BigInteger;
  decimals: Integer;
  b: BigInteger;
begin
  temp := curWU;

  decimals := Pos('.', PerByteFeeEdit.Text);
  if decimals = Low(PerByteFeeEdit.Text) - 1 then
  begin
    decimals := 0;
    b := strToIntdef(PerByteFeeEdit.Text, 0);
  end
  else
  begin
    decimals := length(PerByteFeeEdit.Text) - decimals;
    b := StrFloatToBigInteger(PerByteFeeEdit.Text, decimals);
  end;

  temp := (temp * b) div BigInteger.pow(10, decimals);
  wvFee.Text := BigIntegertoFloatStr(temp, CurrentCoin.decimals);
end;

procedure TfrmHome.PopupBox1Change(Sender: TObject);
begin
  WalletViewRelated.changeViewOrder(Sender);
end;

procedure TfrmHome.PrivacyAndSecurityButtonClick(Sender: TObject);
begin
  switchTab(PageControl, PrivacyAndSecuritySettings);
end;

procedure TfrmHome.PrivateKeyManageButtonClick(Sender: TObject);
begin

  switchTab(PageControl, PrivOptionsTabItem);

end;

procedure TfrmHome.Label5Click(Sender: TObject);
begin
  InstantSendSwitch.IsChecked := not InstantSendSwitch.IsChecked;
end;

procedure TfrmHome.LanguageBoxChange(Sender: TObject);
begin
  WalletViewRelated.changeLanguage(Sender);
end;

procedure TfrmHome.lblFromFeeClick(Sender: TObject);
begin
  FeeFromAmountSwitch.IsChecked := not FeeFromAmountSwitch.IsChecked;
end;

procedure TfrmHome.lblSendAllFundsClick(Sender: TObject);
begin
  SendAllFundsSwitch.IsChecked := not SendAllFundsSwitch.IsChecked;
end;

procedure TfrmHome.SwitchViewToOrganize(Sender: TObject;
const EventInfo: TGestureEventInfo; var Handled: Boolean);
var
  panel: TPanel;
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

  if TButton(Sender).parent = SeedWordsFlowLayout then
  begin
    TButton(Sender).parent := ConfirmedSeedFlowLayout;
  end
  else if TButton(Sender).parent = ConfirmedSeedFlowLayout then
  begin
    TButton(Sender).parent := SeedWordsFlowLayout;

  end;

  for i := 0 to SeedWordsFlowLayout.ComponentCount - 1 do
  begin

    if (SeedWordsFlowLayout.Components[i] is TButton) and
      (TButton(SeedWordsFlowLayout.Components[i]).parent = SeedWordsFlowLayout)
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
      .parent = ConfirmedSeedFlowLayout) then
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

  // if currentthread <> mainThread then Error

  backTabItem := frmHome.PageControl.ActiveTab;
  // if not frmHome.shown then
  // begin
  TabControl.ActiveTab := TabItem;
  // end
  // else
  // begin
  // frmHome.tabAnim.Tab := TabItem;
  // frmHome.AccountsListPanel.Visible := false;
  // frmHome.tabAnim.ExecuteTarget(TabControl);
  // end;
  frmHome.passwordForDecrypt.Text := '';
  frmHome.DecryptSeedMessage.Text := '';
end;

procedure TfrmHome.WVRealCurrencyChange(Sender: TObject);
begin
  WVRealCurrency.Text := StringReplace(WVRealCurrency.Text, ',', '.',
    [rfReplaceAll]);
  if frmHome.WVTabControl.ActiveTab = frmHome.WVSend then
    saveSendCacheToFile();
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
  btnCreateWallet.Text := dictionary('StartRecoveringWallet');
  procCreateWallet := btnQRClick;
  switchTab(PageControl, createPassword);

end;

procedure TfrmHome.SearchTokenButtonClick(Sender: TObject);
var
  found: Integer;
begin

  WalletViewRelated.SearchTokenButtonClick(Sender);

end;

procedure TfrmHome.SelectFileInBackupFileList(Sender: TObject);
begin
  RFFPathEdit.Text := TfmxObject(Sender).TagString;
  RestoreFromFileAccountNameEdit.Text := getUnusedAccountName();
  switchTab(PageControl, HSBPassword);
end;

procedure TfrmHome.RestoreFromFileConfirmButtonClick(Sender: TObject);
var
  failure: Boolean;
  i: Integer;
begin
  failure := false;
  if length(RestoreFromFileAccountNameEdit.Text) < 3 then
  begin
    popupWindow.Create(dictionary('AccountNameTooShort'));
    exit;
  end;

  for i := 0 to length(AccountsNames) - 1 do
  begin

    if AccountsNames[i].name = RestoreFromFileAccountNameEdit.Text then
    begin

      popupWindow.Create(dictionary('AccountNameOccupied'));
      exit();
    end;

  end;

  if not FileExists(RFFPathEdit.Text) then
  begin
    popupWindow.Create(dictionary('FileDoesntExist'));

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
  btnCreateWallet.Text := dictionary('StartRecoveringWallet');
  procCreateWallet := btnImpSeedClick;
  AccountNameEdit.Text := getUnusedAccountName();
  createPasswordBackTabItem := PageControl.ActiveTab;
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
  if frmHome.WVTabControl.ActiveTab = frmHome.WVSend then
    saveSendCacheToFile();
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

procedure TfrmHome.WVsendTOTyping(Sender: TObject);
begin
  WVsendTOExit(self);
end;

procedure TfrmHome.backBtnDecryptSeed(Sender: TObject);
begin
  switchTab(PageControl, decryptSeedBackTabItem);
end;

procedure TfrmHome.BackBtnSGCClick(Sender: TObject);
begin
  switchTab(PageControl, SelectGenerateCoinViewBackTabItem);
end;

procedure TfrmHome.BackToBalanceViewButtonClick(Sender: TObject);
begin
  WalletViewRelated.backToBalance(Sender);

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
  receiveAddress.Text := cutEveryNChar(cutAddressEveryNChar,
    receiveAddress.Text, ' ');
end;

procedure TfrmHome.BCHLegacyButtonClick(Sender: TObject);
begin
  receiveAddress.Text := cutEveryNChar(cutAddressEveryNChar,
    TwalletInfo(CurrentCryptoCurrency).addr, ' ')
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
var
  temp: BigInteger;
begin

  if AutomaticFeeRadio.IsChecked then
  begin
    PerByteFeeEdit.Enabled := false;
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
    PerByteFeeEdit.Enabled := false;

  end;

  if PerByteFeeRatio.IsPressed then
  begin

    PerByteFeeEdit.Enabled := true;
    wvFee.Enabled := false;
    FeeSpin.Enabled := false;

    PerByteFeeEditChangeTracking(nil);

  end;

  FeeToUSDUpdate(nil);

end;

procedure TfrmHome.changeYbuttonClick(Sender: TObject);
begin
  changeY(Sender);
  PageControl.ActiveTab := SameYWalletList;

end;

procedure TfrmHome.choseTokenClick(Sender: TObject);
begin
  WalletViewRelated.chooseToken(Sender);
  // switchTab(PageControl, TTabItem(frmHome.FindComponent('dashbrd')));
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
begin
  WalletViewRelated.addToken(Sender);
  switchTab(PageControl, ChoseToken);
end;

procedure TfrmHome.privateKeyPasswordCheck(Sender: TObject);
begin
  try
    if BackupRelated.PKCheckPassword(Sender, WDToExportPrivKey) then
      switchTab(PageControl, ExportKeyScreen);
  except
    on E: Exception do
    begin
      popupWindow.Create(E.Message);
    end;
  end;

end;

procedure TfrmHome.AboutHodlerButtonClick(Sender: TObject);
begin
  switchTab(PageControl, AboutHodlerTabItem);
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

procedure TfrmHome.AddNewCryptoBackButtonClick(Sender: TObject);
begin
  switchTab(PageControl, HOME_TABITEM);
end;

procedure TfrmHome.AddNewCryptoCurrencyButtonClick(Sender: TObject);
begin

  WalletViewRelated.AddNewCryptoCurrencyButtonClick(Sender);

end;

procedure TfrmHome.addNewWalletPanelClick(Sender: TObject);
begin
  WalletViewRelated.addNewWalletPanelClick(Sender);
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
  if CurrentCoin.description <> '__dashbrd__' then
    switchTab(PageControl, walletView)
  else
    switchTab(PageControl, HOME_TABITEM);
  TThread.CreateAnonymousThread(
    procedure()
    begin
      // SyncThr.SynchronizeCryptoCurrency(CurrentCoin);
      // reloadWalletView;
      sleep(2000);
      RefreshCurrentWallet(Sender);
    end).Start();
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
begin
  WalletViewRelated.TrySendTransaction(Sender);
end;

procedure TfrmHome.UnlockNanoImageClick(Sender: TObject);
var
  Nano: NanoCoin;
begin

  if CurrentCryptoCurrency is NanoCoin then
  begin
    if NanoCoin(CurrentCryptoCurrency).isUnlocked then
      exit;
    // frmhome.UnlockNanoImage.Hint:='When unlocked, receive blocks will be autopocketed';
    NotificationLayout.popupPasswordConfirm(
      procedure(pass: AnsiString)
      var
        tced, MasterSeed: AnsiString;
      begin

        tced := TCA(pass);

        MasterSeed := SpeckDecrypt(tced, CurrentAccount.EncryptedMasterSeed);
        passwordForDecrypt.Text := '';
        if not isHex(MasterSeed) then
        begin
          popupWindow.Create(dictionary('FailedToDecrypt'));
          exit;
        end;

        Nano := NanoCoin(CurrentCryptoCurrency);

        Nano.unlock(MasterSeed);

        wipeansistring(MasterSeed);
        frmHome.UnlockNanoImage.Bitmap.LoadFromStream
          (ResourceMenager.getAssets('OPENED'));

        // PageControl.ActiveTab:=decryptSeedBackTabItem;

      end,
      procedure(pass: AnsiString)
      begin

      end, 'Enter the password to pocket the pending NANO');


    // btnDecryptSeed.onclick := UnlockPendingNano;
    // decryptSeedBackTabItem := PageControl.ActiveTab;
    // PageControl.ActiveTab := descryptSeed;
    // btnDSBack.onclick := backBtnDecryptSeed;

  end
end;

procedure TfrmHome.UnlockNanoImageTap(Sender: TObject; const Point: TPointF);
begin
  UnlockNanoImageClick(Sender);
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
  if frmHome.WVTabControl.ActiveTab = frmHome.WVSend then
    saveSendCacheToFile();
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

procedure TfrmHome.wvFeeChange(Sender: TObject);
begin
  if frmHome.WVTabControl.ActiveTab = frmHome.WVSend then

    saveSendCacheToFile();
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

procedure TfrmHome.CopyPrivateKeyButtonClick(Sender: TObject);
var
  svc: IFMXExtendedClipboardService;
begin

end;

procedure TfrmHome.ConfirmNewAccountButtonClick(Sender: TObject);
var
  str: AnsiString;
  newAcc: Account;
begin

  pass.Text := '';
  retypePass.Text := '';
  btnCreateWallet.Text := dictionary('OpenNewWallet');
  procCreateWallet := btnGenSeedClick;
  switchTab(PageControl, createPassword);

end;

procedure TfrmHome.ConfirmSendClaimCoinButtonClick(Sender: TObject);
var
  temp: TwalletInfo;
begin
  CurrentCoin := FromClaimWD;
  WalletViewRelated.PrepareSendTabAndSend(FromClaimWD, ToClaimWD.addr,
    FromClaimWD.confirmed - BigInteger(1700), BigInteger(1700), '',
    availableCoin[FromClaimWD.coin].name);

end;

procedure TfrmHome.CopyTextButtonClick(Sender: TObject);
begin
  WalletViewRelated.CopyTextButtonClick();
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
      popupWindow.Create(dictionary('CopiedToClipboard'));

      vibrate(200);
    end;
    if Sender is TLabel then
    begin

      svc.setClipboard(TLabel(Sender).TagString);
      popupWindow.Create(dictionary('CopiedToClipboard'));

      vibrate(200);
    end;

  end;

end;

procedure TfrmHome.CreateBackupButtonClick(Sender: TObject);
begin
  switchTab(PageControl, BackupTabItem);
end;

procedure TfrmHome.CreateCurrencyFromListClick(Sender: TObject);
begin
  newCryptoVertScrollBox.createCryptoAndAddPanelTo(frmHome.WalletList);
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

procedure TfrmHome.OpenWalletView(Sender: TObject; const Point: TPointF);
begin
  WalletViewRelated.OpenWallet(Sender);
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

  NotificationLayout.popupProtectedConfirm(
    procedure()
    begin
      wipeWalletDat;
{$IFDEF ANDROID}
      SharedActivity.finish;
{$ELSE}
      frmHome.Close;
{$ENDIF}
    end,
    procedure()
    begin

    end, dictionary('SureWipeWallet') + #13#10 +
    dictionary('CantRestoreCoins'));

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
begin
  BackupRelated.checkSeed(Sender);
end;

procedure TfrmHome.btnOptionsClick(Sender: TObject);
begin
  switchTab(PageControl, Settings);
end;

procedure TfrmHome.btnQRClick(Sender: TObject);
begin
  QRRelated.scanQR(Sender);
end;

procedure TfrmHome.btnGenSeedClick(Sender: TObject);
var
  alphaStr: AnsiString;
begin
  SetLength(trngBuffer, 4 * 1024);

  // turn on phone's sensors
  // they will be used for collect random data
{$IF DEFINED(ANDROID) OR DEFINED(IOS)}
  MotionSensor.Active := true;
  OrientationSensor.Active := true;
{$ENDIF}
  // turn on timer that counts random value from sensors
  gathener.Enabled := true;
  switchTab(PageControl, walletDatCreation);

end;

procedure TfrmHome.btnAddContractClick(Sender: TObject);
var
  T: Token;
begin

  WalletViewRelated.btnAddContractClick(Sender);

end;

procedure TfrmHome.btnSBackClick(Sender: TObject);
begin
  switchTab(PageControl, HOME_TABITEM);
end;

procedure TfrmHome.btnSCBackClick(Sender: TObject);
begin
  switchTab(PageControl, createPassword);
end;

procedure TfrmHome.btnANWBackClick(Sender: TObject);
begin
  switchTab(PageControl,
    AddCoinBackTabItem { TTabItem(frmHome.FindComponent('dashbrd')) } );
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
    popupWindow.Create(dictionary('SeedsArentSame'));
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
    availableCoin[TwalletInfo(CurrentCryptoCurrency).coin].p2pk);

  receiveAddress.Text := cutEveryNChar(cutAddressEveryNChar,
    receiveAddress.Text, ' ');
end;

procedure TfrmHome.switchCompatiblep2shButtonClick(Sender: TObject);
begin
  receiveAddress.Text := Bitcoin.generatep2sh(TwalletInfo(CurrentCryptoCurrency)
    .pub, availableCoin[TwalletInfo(CurrentCryptoCurrency).coin].p2sh);

  receiveAddress.Text := cutEveryNChar(cutAddressEveryNChar,
    receiveAddress.Text, ' ');
end;

procedure TfrmHome.SwitchSegwitp2wpkhButtonClick(Sender: TObject);
begin
  receiveAddress.setText
    (Bitcoin.generatep2wpkh(TwalletInfo(CurrentCryptoCurrency).pub,
    availableCoin[TwalletInfo(CurrentCryptoCurrency).coin].hrp), 3);

  receiveAddress.Text := cutEveryNChar(cutAddressEveryNChar,
    receiveAddress.Text, ' ');
end;

procedure TfrmHome.LoadAccountPanelClick(Sender: TObject);
begin
  if OrganizeList.Visible = true then
    closeOrganizeView(nil);
  LoadCurrentAccount(TfmxObject(Sender).TagString);
  AccountsListPanel.Visible := false;
end;

procedure TfrmHome.LoadMoreClick(Sender: TObject);
var
  tmp: Single;
begin

  createHistoryList(CurrentCryptoCurrency, txHistory.ComponentCount - 1,
    txHistory.ComponentCount + 9);

end;

procedure TfrmHome.MainScreenQRButtonClick(Sender: TObject);
begin

  QRRelated.scanQR(Sender);
  showmessage('qr');
end;

procedure TfrmHome.generateNewAddressClick(Sender: TObject);
begin
  generateNewYAddress(Sender);
end;

procedure TfrmHome.MineNano(Sender: TObject);
begin
  nano_DoMine(CryptoCurrency(NanoUnlocker.TagObject), passwordForDecrypt.Text);
  passwordForDecrypt.Text := '';
  PageControl.ActiveTab := walletView;
end;

procedure TfrmHome.NanoUnlockerClick(Sender: TObject);
begin
  btnDecryptSeed.OnClick := MineNano;
  decryptSeedBackTabItem := PageControl.ActiveTab;
  PageControl.ActiveTab := descryptSeed;
  btnDSBack.OnClick := backBtnDecryptSeed;
end;

procedure TfrmHome.NewCoinPrivKeyOKButtonClick(Sender: TObject);
begin
  WalletViewRelated.newCoinFromPrivateKey(Sender);
end;

procedure TfrmHome.NewYaddressesOKButtonClick(Sender: TObject);
begin
  generateNewYAddress(Sender);
end;

procedure TfrmHome.NextButtonSGCClick(Sender: TObject);
begin
  TThread.CreateAnonymousThread(
    procedure
    begin
      TThread.Synchronize(nil,
        procedure
        begin

          procCreateWallet(nil);

        end);
    end).Start;
end;

procedure TfrmHome.notPrivTCA2Change(Sender: TObject);
begin
  notPrivTCA1.IsChecked := notPrivTCA2.IsChecked;
end;

procedure TfrmHome.ChangeAccountButtonClick(Sender: TObject);
begin
{$IFDEF ANDROID}
{$ENDIF}
  AccountRelated.changeAccount(Sender);
end;

procedure TfrmHome.HSBPasswordBackBtnClick(Sender: TObject);
begin
  switchTab(PageControl, RestoreFromFileTabitem);
end;

procedure TfrmHome.CSBackButtonClick(Sender: TObject);
begin
  if not ConfirmSendClaimCoinButton.Visible then
    switchTab(PageControl, walletView)
  else
    switchTab(PageControl, HOME_TABITEM)
end;

procedure TfrmHome.CTIHeaderBackButtonClick(Sender: TObject);
begin
  switchTab(PageControl, ClaimWalletListTabItem);
end;

procedure TfrmHome.SendTransactionButtonClick(Sender: TObject);
begin

  TrySendTX(Sender);

end;

procedure TfrmHome.PrivOptionsBackButtonClick(Sender: TObject);
begin
  switchTab(PageControl, Settings);
end;

procedure TfrmHome.EPCLTIBackButtonClick(Sender: TObject);
begin
  switchTab(PageControl, AddNewCoin);
end;

procedure TfrmHome.AddCoinFromPrivQRButtonClick(Sender: TObject);
begin
  QRRelated.scanQR(Sender);
end;

procedure TfrmHome.DebugButtonClick(Sender: TObject);
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

  showmessage(getDetailedData());

end;

procedure TfrmHome.Button3Click(Sender: TObject);
begin
  prepareTranslateFile();
end;

procedure TfrmHome.ImportPrivateKey(Sender: TObject);
begin
  BackupRelated.ImportPriv(Sender);
  switchTab(PageControl, TTabItem(frmHome.FindComponent('dashbrd')));
end;

procedure TfrmHome.InstantSendSwitchClick(Sender: TObject);
begin
  InstantSendClick();
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
  CoinPrivKeyPassEdit.Text := '';
  WIFEdit.Text := '';
end;

procedure TfrmHome.OrganizeButtonClick(Sender: TObject);
begin
  WalletViewRelated.OrganizeView(Sender);
end;

procedure TfrmHome.ShowHideAdvancedButtonClick(Sender: TObject);
begin

  TransactionFeeLayout.Visible := not TransactionFeeLayout.Visible;
  TransactionFeeLayout.Position.Y := ShowAdvancedLayout.Position.Y + 1;

  if TransactionFeeLayout.Visible then
  begin
    arrowImg.Bitmap := arrowList.Source[1].MultiResBitmap[0].Bitmap;
    ShowHideAdvancedButton.Text := dictionary('HideAdvanced');
  end
  else
  begin
    arrowImg.Bitmap := arrowList.Source[0].MultiResBitmap[0].Bitmap;
    ShowHideAdvancedButton.Text := dictionary('ShowAdvanced');
  end;

end;

procedure TfrmHome.btnSeedGeneratedProceedClick(Sender: TObject);
begin
  BackupRelated.splitWords(Sender);
  switchTab(PageControl, checkSeed);
end;

procedure TfrmHome.btnOKAddNewCoinSettingsClick(Sender: TObject);
begin

  // switchTab(frmhome.PageControl, HOME_TABITEM);
  WalletViewRelated.newCoin(Sender);

end;

procedure TfrmHome.btnChangeDescriptionClick(Sender: TObject);
begin
  WalletViewRelated.btnChangeDescriptionClick(Sender);
end;

procedure TfrmHome.DebugBackButtonClick(Sender: TObject);
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
  switchTab(PageControl, RestoreFromFileBackTabItem);
end;

procedure TfrmHome.btnCreateNewWalletClick(Sender: TObject);
begin

  WalletViewRelated.btnCreateNewWalletClick(Sender);
  { privTCAPanel2.Visible := false;
    notPrivTCA2.IsChecked := false;
    pass.Text := '';
    retypePass.Text := '';
    btnCreateWallet.Text := dictionary('OpenNewWallet');
    procCreateWallet := btnGenSeedClick;


    AccountNameEdit.Text := getUnusedAccountName();
    switchTab(PageControl, createPassword); }

end;

procedure TfrmHome.btnCreateWalletClick(Sender: TObject);
begin
  WalletViewRelated.CreateWallet(Sender);
end;

procedure TfrmHome.btnChangeDescryptionBackClick(Sender: TObject);
begin
  switchTab(PageControl, walletView);
end;

procedure TfrmHome.btnChangeDescryptionOKClick(Sender: TObject);
begin
  WalletViewRelated.btnChangeDescryptionOKClick(Sender);
  { CurrentCryptoCurrency.description := ChangeDescryptionEdit.Text;
    CurrentAccount.SaveFiles();
    switchTab(PageControl, walletView); }
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
  WDToExportPrivKey := CurrentCoin;
end;

procedure TfrmHome.btnANTBackClick(Sender: TObject);
begin
  switchTab(PageControl, HOME_TABITEM);
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
begin
  WalletViewRelated.Synchro;
end;

// Show available ETH wallet during adding new Token
procedure TfrmHome.btnAddNewTokenClick(Sender: TObject);
begin
  WalletViewRelated.ShowETHWallets();
end;

procedure TfrmHome.btnAddNewCoinClick(Sender: TObject);
begin
  createAddWalletView();

  HexPrivKeyDefaultRadioButton.IsChecked := true;
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
  newCoinListNextTAbItem := frmHome.AddNewCoinSettings;
  AddCoinBackTabItem := PageControl.ActiveTab;
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
begin
  WalletViewRelated.SendClick(Sender);
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

    frmHome.btnReadOCR.Text := dictionary('ReadAgainOCR');

  end
  else
  begin

    if not ValidateBitcoinAddress(str) = true then
    begin
      popupWindowOK.Create(
        procedure
        begin
        end, dictionary('OCRInaccurate'));
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
  TThread.Synchronize(TThread.CurrentThread, GetImage);
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
begin
  QRRelated.parseCamera;
end;

procedure TfrmHome.RestoreFromEncryptedQR(Sender: TObject);
begin
  BackupRelated.RestoreEQR(Sender);
end;

procedure TfrmHome.FeeSpinChange(Sender: TObject);
begin
  WalletViewRelated.calcFeeWithSpin;
end;

procedure TfrmHome.FeeToUSDUpdate(Sender: TObject);
begin
  WalletViewRelated.calcUSDFee;
end;

procedure TfrmHome.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  AccountRelated.CloseHodler();
end;

procedure TfrmHome.FormCloseQuery(Sender: TObject; var CanClose: Boolean);
begin
{$IFDEF WIN32 or WIN64}
  stylo.Destroy;

{$ENDIF}
end;

procedure TfrmHome.FormCreate(Sender: TObject);
begin

  try
    AccountRelated.InitializeHodler;
    AccountsListPanel.Visible := false;
  except
    on E: Exception do
      showmessage(E.Message);
  end;

end;

procedure TfrmHome.FormFocusChanged(Sender: TObject);
begin
  // SetCopyButtonPosition;
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

  TThread.CreateAnonymousThread(
    procedure
    begin
      TThread.Synchronize(nil,
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

      if (PageControl.ActiveTab = createPassword) then
      begin
        switchTab(PageControl, createPasswordBackTabItem);
      end
      else if (PageControl.ActiveTab = SeedCreation) then
      begin
        switchTab(PageControl, WelcomeTabItem);
      end
      else if PageControl.ActiveTab = walletDatCreation then
      begin
{$IFDEF ANDROID}
        SharedActivity.moveTaskToBack(true);
{$ENDIF}
      end // switchTab(PageControl, PrivOptionsTabItem); fileManager
      else if PageControl.ActiveTab = ClaimTabItem then
      begin
        switchTab(PageControl, ClaimWalletListTabItem);
      end
      else if PageControl.ActiveTab = RestoreFromFileTabitem then
      begin
        switchTab(PageControl, RestoreFromFileBackTabItem);
      end
      else if PageControl.ActiveTab = ExportPrivCoinListTabItem then
      begin
        switchTab(PageControl, PrivOptionsTabItem);
      end
      else if (PageControl.ActiveTab = fileManager) or
        (PageControl.ActiveTab = HSBPassword) then
      begin
        switchTab(PageControl, RestoreFromFileTabitem);
      end
      else if PageControl.ActiveTab = PasswordForGenerateYAddressesTabItem then
      begin
        switchTab(PageControl, decryptSeedBackTabItem);
      end
      else if PageControl.ActiveTab = AddNewCoin then
      begin
        switchTab(PageControl, AddCoinBackTabItem);
      end
      else if (PageControl.ActiveTab = AddCoinFromPrivKeyTabItem) or
        (PageControl.ActiveTab = ClaimWalletListTabItem) then
      begin
        switchTab(PageControl, AddNewCoin);
      end
      else if PageControl.ActiveTab = AddNewCoinSettings then
      begin
        switchTab(PageControl, AddNewCoin);
      end
      else if (PageControl.ActiveTab = EQRView) or
        (PageControl.ActiveTab = seedGenerated) then
      begin
        switchTab(PageControl, BackupTabItem);
      end
      else if PageControl.ActiveTab = ChoseToken then
      begin
        switchTab(PageControl, AddNewToken);
      end
      else if PageControl.ActiveTab = SameYWalletList then
      begin
        switchTab(PageControl, walletView);
      end
      else if PageControl.ActiveTab = descryptSeed then
      begin
        switchTab(PageControl, decryptSeedBackTabItem);
      end
      else if PageControl.ActiveTab = ChangeDescryptionScreen then
      begin
        switchTab(PageControl, walletView);
      end
      else if PageControl.ActiveTab = RestoreOptions then
      begin
        switchTab(PageControl, WelcomeTabItem);
      end
      else if PageControl.ActiveTab = QRReader then
      begin
        switchTab(PageControl, cameraBackTabItem);
      end //
      else if PageControl.ActiveTab = checkSeed then
      begin
        switchTab(PageControl, seedGenerated);
      end
      else if (PageControl.ActiveTab = BackupTabItem) or
        (PageControl.ActiveTab = PrivOptionsTabItem) then
      begin
        switchTab(PageControl, Settings);
      end
      else if (PageControl.ActiveTab = TTabItem(frmHome.FindComponent('dashbrd')
        )) and (AccountsListPanel.Visible) then
      begin
        AccountsListPanel.Visible := false;
        exit;
      end
      else if ((PageControl.ActiveTab = TTabItem(frmHome.FindComponent
        ('dashbrd'))) and OrganizeList.Visible) then
      begin
        closeOrganizeView(nil);
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
      + floattoStr(Y * random($FFFF)) + inttostr(random($FFFFFFFF)) +
      ISecureRandomBuffer
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

procedure TfrmHome.FormShow(Sender: TObject);
begin
  FServiceConnection := TLocalServiceConnection.Create;
  FServiceConnection.StartService('NanoPowAS');
  // FServiceConnection.BindService('NanoPoWAS');
  try
    AccountRelated.afterInitialize;
    FServiceConnection := TLocalServiceConnection.Create;
    // ;
  except
    on E: Exception do
      showmessage(E.Message);
  end;

end;

procedure TfrmHome.FormVirtualKeyboardHidden(Sender: TObject;
KeyboardVisible: Boolean; const Bounds: TRect);
var
  FService: IFMXVirtualKeyboardService;
  X: Integer;
begin
  try
    NotificationLayout.centerCurrentPopup;

    if PageControl.ActiveTab = EQRView then
      exit;
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
  Except
    on E: Exception do
    begin

    end;
  end;
end;

procedure TfrmHome.FormVirtualKeyboardShown(Sender: TObject;
KeyboardVisible: Boolean; const Bounds: TRect);
var
  FService: IFMXVirtualKeyboardService;
  FToolbarService: IFMXVirtualKeyBoardToolbarService;
  X, Y: Integer;
  sameY: Integer;
begin
  try
    NotificationLayout.moveCurrentPopupToTop;

    if PageControl.ActiveTab = EQRView then
      exit;
    Y := 0;
    if focused is TEdit then
    begin
      if (TEdit(focused).name = 'wvAddress') or
        (TEdit(focused).name = 'receiveAddress') then
      begin

        exit;
      end;
      if (PageControl.ActiveTab = walletView) and
        (TEdit(focused).ReadOnly = false) then
      begin
        Y := round((focused as TEdit).LocalToAbsolute(PointF((focused as TEdit)
          .Position.X, (focused as TEdit).Position.Y)).Y -
          (frmHome.Height div 3));
        // if Y<(frmHome.Height div 3) then Y:=0;

      end;
    end;
    X := (round(frmHome.Height * 1));
    KeyBoardLayout.Height := frmHome.Height + X;
    frmHome.ScrollBox.Align := TAlignLayout.None;
    PageControl.Align := ScrollBox.Align;
    KeyBoardLayout.parent := frmHome;
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
    sameY := round(ScrollBox.ViewportPosition.Y);
    if Y <> 0 then
    begin
      repeat
        if Y > ScrollBox.ViewportPosition.Y then
          ScrollBox.ViewportPosition :=
            PointF(0, ScrollBox.ViewportPosition.Y + 10);
        if Y < ScrollBox.ViewportPosition.Y then
          ScrollBox.ViewportPosition :=
            PointF(0, ScrollBox.ViewportPosition.Y - 10);
        application.ProcessMessages;
        if sameY = round(ScrollBox.ViewportPosition.Y) then
          break;

      until abs(Y - round(ScrollBox.ViewportPosition.Y)) < 15;
    end;
  Except
    on E: Exception do
    begin
    end;
  end;

end;

procedure TfrmHome.FoundTokenOKButtonClick(Sender: TObject);
var
  FMX: TfmxObject;
  T: Token;
begin

  WalletViewRelated.FoundTokenOKButtonClick(Sender);

end;

procedure TfrmHome.gathenerTimer(Sender: TObject);
var
  i: Integer;
  ac: Account;
begin
  inc(trngBufferCounter);
  // colecting random data for seed generator
  trngBuffer := trngBuffer + GetSTrHashSHA256(inttohex(random($FFFFFFFF), 8) +
    DateTimeToStr(Now)) + ISecureRandomBuffer;
{$IF DEFINED(ANDROID) OR DEFINED(IOS)}
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
  if PageControl.ActiveTab = walletDatCreation then
  begin

    GenerateSeedProgressBar.Value := trngBufferCounter div 2;

    if trngBufferCounter mod 10 = 0 then
    begin
      trngBuffer := GetSTrHashSHA256(trngBuffer);
      labelForGenerating.Text := trngBuffer;
    end;
    if trngBufferCounter mod 200 = 0 then
    begin
      // 10sec of gathering random data should be enough to get unique seed
      trngBuffer := GetSTrHashSHA256(trngBuffer + inttostr(random($FFFFFFFF)) +
        ISecureRandomBuffer);
      gathener.Enabled := false;
      if swForEncryption.IsChecked then
        TCAIterations := 10000;
      CreateNewAccountAndSave(AccountNameEdit.Text, pass.Text,
        trngBuffer, false);
    end;
  end
  else
  begin
    trngBufferCounter := 0;
    trngBuffer := GetSTrHashSHA256(trngBuffer);
  end;
end;

procedure TfrmHome.Image1Click(Sender: TObject);
var
  wd: TwalletInfo;
  tt: Token;
  myURI: AnsiString;
  URL: WideString;
{$IFDEF ANDROID}
  Intent: JIntent;

{$ENDIF}
begin
  myURI := 'https://www.coinbase.com/';
{$IFDEF ANDROID}
  Intent := TJIntent.Create;
  Intent.setAction(TJIntent.JavaClass.ACTION_VIEW);
  Intent.setData(StrToJURI(myURI));
  SharedActivity.startActivity(Intent);

{$ELSE}
  URL := myURI;
  ShellExecute(0, 'OPEN', PWideChar(URL), '', '', { SW_SHOWNORMAL } 1);
{$ENDIF}
end;
{ begin
  btnSyncClick(nil);
  end; }

procedure TfrmHome.coinbaseImageClick(Sender: TObject);
var
  wd: TwalletInfo;
  tt: Token;
  myURI: AnsiString;
  URL: WideString;
{$IFDEF ANDROID}
  Intent: JIntent;

{$ENDIF}
begin
  myURI := 'https://www.coinbase.com/';
{$IFDEF ANDROID}
  Intent := TJIntent.Create;
  Intent.setAction(TJIntent.JavaClass.ACTION_VIEW);
  Intent.setData(StrToJURI(myURI));
  SharedActivity.startActivity(Intent);

{$ELSE}
  URL := myURI;
  ShellExecute(0, 'OPEN', PWideChar(URL), '', '', { SW_SHOWNORMAL } 1);
{$ENDIF}
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

procedure TfrmHome.ImportPrivateKeyInPrivButtonClick(Sender: TObject);
begin
  WalletViewRelated.ImportPrivateKeyInPrivButtonClick(Sender);
end;

procedure TfrmHome.LightButtonQRClick(Sender: TObject);
begin
  if CameraComponent1.TorchMode <> TTorchMode.ModeOn then
    CameraComponent1.TorchMode := TTorchMode.ModeOn
  else
    CameraComponent1.TorchMode := TTorchMode.Modeoff;
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

procedure TfrmHome.SYWLBackButtonClick(Sender: TObject);
begin
  switchTab(PageControl, walletView);
end;

procedure TfrmHome.SYWLBackButtonTap(Sender: TObject; const Point: TPointF);
begin
  switchTab(PageControl, walletView);
end;

procedure TfrmHome.receiveAddressoldChange(Sender: TObject);
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
  panel: TPanel;
  lbl: TLabel;
  i: Integer;
begin
  for fmxObj in WalletList.Content.Children do
  begin
    if fmxObj is TPanel then
      panel := TPanel(fmxObj)
    else
      Continue;

    for i := 0 to panel.ChildrenCount - 1 do
    begin

      if (panel.Children[i] is TLabel) and
        (TLabel(panel.Children[i]).TagString = 'name') then
      begin

        if (AnsiContainsText(TLabel(panel.Children[i]).Text, SearchEdit.Text))
          or (SearchEdit.Text = '') then
        begin
          panel.Visible := true;
          break;
        end
        else
        begin
          panel.Visible := false;
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

procedure TfrmHome.SendDecryptedSeedButtonClick(Sender: TObject);
begin

  decryptSeedBackTabItem := PageControl.ActiveTab;
  PageControl.ActiveTab := descryptSeed;
  btnDSBack.OnClick := backBtnDecryptSeed;
end;

procedure TfrmHome.SendAllFundsSwitchClick(Sender: TObject);
begin
  WalletViewRelated.sendallfunds;
end;

procedure TfrmHome.SendEncryptedSeed(Sender: TObject);
begin
  BackupRelated.SendEQR;
end;

procedure TfrmHome.SendEncryptedSeedButtonClick(Sender: TObject);
var
  pngName: string;
begin
  WalletViewRelated.SendEncryptedSeedButtonClick(Sender);

end;

procedure TfrmHome.SendErrorMsgSwitchSwitch(Sender: TObject);
begin
  WalletViewRelated.SendErrorMsgSwitchSwitch(Sender);
end;

procedure TfrmHome.SendReportIssuesButtonClick(Sender: TObject);
begin
  WalletViewRelated.SendReportIssuesButtonClick(Sender);
end;

procedure TfrmHome.SendWalletFile(Sender: TObject);
begin
  if SYSTEM_APP then
    decryptSeedForSeedRestore(Sender)
  else
    BackupRelated.SendHSB;
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
  ShowShareSheetAction1.TextMessage := receiveAddress.Text;
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

procedure TfrmHome.SweepButtonClick(Sender: TObject);
begin
  WalletViewRelated.SweepButtonClick(Sender);
end;

procedure TfrmHome.SweepQRButtonClick(Sender: TObject);
begin
  QRRelated.scanQR(Sender);
end;

procedure TfrmHome.IsPrivKeySwitchSwitch(Sender: TObject);
begin
  // PrivateKeySettingsLayout.Visible := IsPrivKeySwitch.IsChecked;
end;

procedure TfrmHome.KeypoolSanitizerTimer(Sender: TObject);
begin
  sanitizePool;
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
  WalletViewRelated.importCheck;
end;

procedure TfrmHome.SaPBackButtonClick(Sender: TObject);
begin
  switchTab(PageControl, Settings);
end;

procedure TfrmHome.ScrollKeeperTimer(Sender: TObject);
var
  FService: IFMXVirtualKeyboardService;
begin
{$IFDEF ANDROID}
  TPlatformServices.Current.SupportsPlatformService(IFMXVirtualKeyboardService,
    IInterface(FService));

  if (FService = nil) or
    ((FService <> nil) and (not(TVirtualKeyboardState.Visible
    in FService.VirtualKeyBoardState))) then
    ScrollBox.ViewportPosition := PointF(0, 0);
{$ENDIF}
  // syncFont;
end;

procedure TfrmHome.RestoreFromFileButtonClick(Sender: TObject);
begin
  BackupRelated.RestoreFromFile(Sender);
end;

procedure TfrmHome.ClaimYourBCHSVButtonClick(Sender: TObject);
begin

  try
    claim(newCoinID);
  except
    on E: Exception do
    begin
      popupWindow.Create(E.Message);
    end;
  end;

end;

end.
