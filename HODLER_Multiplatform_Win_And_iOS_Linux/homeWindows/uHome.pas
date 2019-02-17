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
  {$IFDEF MSWINDOWS}
   Windows,
{$ENDIF}SysUtils, System.Types, System.UITypes, System.Classes, strUtils,
  SyncThr, System.Generics.Collections, System.character,
  System.DateUtils, System.Messaging,
  System.Variants, System.IOUtils,
  FMX.Types, FMX.Graphics, FMX.Controls, FMX.Forms, FMX.Dialogs, FMX.StdCtrls,
  FMX.Controls.Presentation, FMX.Styles, System.ImageList, FMX.ImgList, FMX.Ani,
  FMX.Layouts, FMX.ExtCtrls, Velthuis.BigIntegers, FMX.ScrollBox, FMX.Memo,
  FMX.Platform, System.Threading, Math, DelphiZXingQRCode,
  FMX.TabControl, FMX.ActnList, FMX.StdActns,
  FMX.MediaLibrary.Actions, System.Actions, FMX.Gestures, FMX.Objects,
  FMX.Media, FMX.EditBox, FMX.SpinBox,
  FMX.Edit,
  FMX.Clipboard, bech32, cryptoCurrencyData, FMX.VirtualKeyBoard, JSON,
  languages, WIF, AccountData, WalletStructureData,
     TCopyableAddressPanelData ,
  System.Net.HttpClientComponent, System.Net.urlclient, System.Net.HttpClient,
  CurrencyConverter, uEncryptedZipFile, System.Zip, TRotateImageData , popupwindowData , notificationLayoutData , TaddressLabelData
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
{$IFDEF MSWINDOWS}
  URLMon,
{$ENDIF}
  misc, {FMX.Menus,}
  ZXing.BarcodeFormat,
  ZXing.ReadResult,
  ZXing.ScanManager,
{$IF NOT DEFINED(LINUX)} System.Sensors, System.Sensors.Components, {$ENDIF} FMX.ComboEdit;

type

  TfrmHome = class(TForm)
    PageControl: TTabControl;
    walletDatCreation: TTabItem;
    HeaderForWDC: TToolBar;
    labelHeaderForWDC: TLabel;
    PanelLoading: TPanel;
    AniIndicator1: TAniIndicator;
    gathener: TTimer;
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
    wvAddressOld: TEdit;
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
    SaveSeedIsImportantStaticLabel: TLabel;
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
    receiveAddressOld: TEdit;
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
    Label6: TLabel;
    Label8: TLabel;
    Layout16: TLayout;
    Label11: TLabel;
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
    IPKBack: TButton;
    ImportPrivateKeyButton: TButton;
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
    AccountNameLabel: TLabel;
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
    Image7: TImage;
    Layout23: TLayout;
    Layout36: TLayout;
    SystemTimer: TTimer;
    updateBtn: TButton;
    Panel8: TPanel;
    btnOptions: TButton;
    ChangeAccountButton: TButton;
    HeaderLabel: TLabel;
    DashBrdPanel: TPanel;
    Splitter1: TSplitter;
    btnSync: TButton;
    DashBrdProgressBar: TProgressBar;
    NoPrintScreenImage: TImage;
    StyleBook2: TStyleBook;
    SearchTokenButton: TButton;
    Layout37: TLayout;
    CheckUpdateButton: TButton;
    ConfirmSendTabItem: TTabItem;
    SendTransactionButton: TButton;
    Label15: TLabel;
    ToolBar8: TToolBar;
    ConfirmSendHeaderLabel: TLabel;
    CSBackButton: TButton;
    ConfirmSendPasswordPanel: TPanel;
    ConfirmSendPasswordEdit: TEdit;
    ConfirmSendPasswordLabel: TLabel;
    SendFromLabel: TLabel;
    SendValueLabel: TLabel;
    SendFeeLabel: TLabel;
    SendToLabel: TLabel;
    SendFromStaticLabel: TLabel;
    SendToStaticLabel: TLabel;
    SendValueStaticLabel: TLabel;
    SendFeeStaticLabel: TLabel;
    Layout38: TLayout;
    Layout41: TLayout;
    Layout44: TLayout;
    Layout47: TLayout;
    SendDetailsLabel: TLabel;
    Layout50: TLayout;
    IsPrivKeySwitch: TSwitch;
    ImportPrivKeyStaticLabel: TLabel;
    Panel11: TPanel;
    Panel12: TPanel;
    TransactionWaitForSend: TTabItem;
    TransactionWaitForSendAniIndicator: TAniIndicator;
    Panel13: TPanel;
    TransactionWaitForSendDetailsLabel: TLabel;
    TransactionWaitForSendBackButton: TButton;
    TransactionWaitForSendLinkLabel: TLabel;
    Layout53: TLayout;
    WaitTimeLabel: TLabel;
    WelcomeTabInfoLabel: TLabel;
    AddAccountInfoLabel: TLabel;
    BackupInfoLabel: TLabel;
    AddERC20InfoLabel: TLabel;
    SendInfoLabel: TLabel;
    ExportPrivKeyInfoLabel: TLabel;
    ChangeDescriptionInfoLabel: TLabel;
    WipeWalletDataInfoLabel: TLabel;
    OrganizeInfoLabel: TLabel;
    CreateBackupInfoLabel: TLabel;
    CheckUpdateInfoLabel: TLabel;
    DeleteAccountButton: TButton;
    DeleteAccountLayout: TLayout;
    BackToBalanceViewLayout: TLayout;
    BackWithoutSavingButton: TButton;
    PrivKeyQRImage: TImage;
    Layout56: TLayout;
    CopyPrivateKeyButton: TButton;
    OrganizeDragInfoLabel: TLabel;
    PopupBox1: TPopupBox;
    PerByteFeeLayout: TLayout;
    PerByteFeeRatio: TRadioButton;
    PerByteFeeEdit: TEdit;
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
    Label23: TLabel;
    Panel14: TPanel;
    AmountNewAddressesLabel: TLabel;
    SpinBox1: TSpinBox;
    Layout57: TLayout;
    TrackBar1: TTrackBar;
    SameYWalletList: TTabItem;
    YaddressesVertScrollBox: TVertScrollBox;
    Panel15: TPanel;
    OwnXCheckBox: TCheckBox;
    OwnXEdit: TEdit;
    Panel16: TPanel;
    DayNightModeStaticLabel: TLabel;
    privTCAPanel2: TPanel;
    PreAlphaImportLabel: TLabel;
    notPrivTCA2: TCheckBox;
    TCAInfoPanel: TCalloutPanel;
    TCAWaitingLabel: TLabel;
    Yaddresses: TLayout;
    changeYbutton: TButton;
    StatusBarFixer: TRectangle;
    HideZeroWalletsCheckBox: TCheckBox;
    lblWIFKey: TEdit;
    WIFFormatLabel: TLabel;
    HexFormatLabel: TLabel;
    btnNewAddress: TButton;
    btnPrevAddress: TButton;
    privTCAPanel1: TPanel;
    PreAlphaWalletLabel: TLabel;
    notPrivTCA1: TCheckBox;
    LoadMore: TButton;
    FindUnusedAddressButton: TButton;
    RavencoinAddrTypeLayout: TLayout;
    LegacyRavenAddrButton: TButton;
    SegwitRavenAddrButton: TButton;
    PrivateSendLayout: TLayout;
    Label2: TLabel;
    Layout39: TLayout;
    Switch1: TSwitch;
    InstantSendLayout: TLayout;
    Layout42: TLayout;
    Label5: TLabel;
    CopyTextButton: TButton;
    lblPrivateKey: TEdit;
    CopyButtonPitStopEdit: TEdit;
    SelectGenetareCoin: TTabItem;
    ToolBar10: TToolBar;
    SGCHeaderLabel: TLabel;
    BackBtnSGC: TButton;
    NextButtonSGC: TButton;
    Panel17: TPanel;
    SelectGenerateCoinStaticLabel: TLabel;
    GenerateCoinVertScrollBox: TVertScrollBox;
    claimButton: TButton;
    ClaimTabItem: TTabItem;
    ToolBar11: TToolBar;
    CTIHeaderLabel: TLabel;
    CTIHeaderBackButton: TButton;
    Panel18: TPanel;
    PrivateKeyEditSV: TEdit;
    Label7: TLabel;
    Panel19: TPanel;
    AddressSVEdit: TEdit;
    Label9: TLabel;
    ClaimYourBCHSVButton: TButton;
    CompressedPrivKeySVCheckBox: TCheckBox;
    Button1: TButton;
    BCHSVBCHABCReplayProtectionLabel: TLabel;
    ClaimWalletListTabItem: TTabItem;
    ClaimCoinListVertScrollBox: TVertScrollBox;
    Button4: TButton;
    Panel20: TPanel;
    SelectCoinToClaimStaticLabel: TLabel;
    ToolBar12: TToolBar;
    Label12: TLabel;
    Button5: TButton;
    ConfirmSendClaimCoinButton: TButton;
    MainScreenQRButton: TButton;
    WalletTransactionListTabItem: TTabItem;
    WalletTransactionVertScrollBox: TVertScrollBox;
    Button6: TButton;
    Panel10: TPanel;
    Label10: TLabel;
    ToolBar13: TToolBar;
    Label13: TLabel;
    Button7: TButton;
    historyTransactionConfirmation: TEdit;
    HistoryTransactionDate: TEdit;
    HistoryTransactionValue: TEdit;
    HistoryTransactionID: TEdit;
    ShowInAnim: TFloatAnimation;
    PrivateKeyManageButton: TButton;
    AddCoinFromPrivKeyTabItem: TTabItem;
    ToolBar14: TToolBar;
    Label14: TLabel;
    Button9: TButton;
    Layout31: TLayout;
    StaticLabelPriveteKetInfo: TLabel;
    Layout34: TLayout;
    HexPrivKeyDefaultRadioButton: TRadioButton;
    HexPrivKeyCompressedRadioButton: TRadioButton;
    HexPrivKeyNotCompressedRadioButton: TRadioButton;
    Layout51: TLayout;
    ImportPrivKeyLabel: TLabel;
    WIFEdit: TEdit;
    LoadingKeyDataAniIndicator: TAniIndicator;
    Panel21: TPanel;
    CoinPrivKeyDescriptionEdit: TEdit;
    Label16: TLabel;
    Panel22: TPanel;
    CoinPrivKeyPassEdit: TEdit;
    Label17: TLabel;
    NewCoinPrivKeyOKButton: TButton;
    PrivOptionsTabItem: TTabItem;
    ToolBar15: TToolBar;
    Label18: TLabel;
    Button10: TButton;
    ImportPrivateKeyInPrivButton: TButton;
    SweepButton: TButton;
    ExportPrivateKeyButton: TButton;
    ExportPrivCoinListTabItem: TTabItem;
    Panel23: TPanel;
    Label19: TLabel;
    ToolBar16: TToolBar;
    Label21: TLabel;
    EPCLTIBackButton: TButton;
    ExportPrivKeyListVertScrollBox: TVertScrollBox;
    WVTabItemLayout: TLayout;
    RefreshLayout: TLayout;
    ShortcutFiatLabel: TLabel;
    FiatShortcutLayout: TLayout;
    ShortcutFiatShortcutLabel: TLabel;
    NameShortcutLabel: TLabel;
    NameShortcutLayout: TLayout;
    BilanceStaticLabel: TLabel;
    GlobalRefreshLayout: TLayout;
    Layout25: TLayout;
    Layout12: TLayout;
    Layout40: TLayout;
    Layout43: TLayout;
    Layout45: TLayout;
    TopInfoConfirmedFiatLabel: TLabel;
    TopInfoUnconfirmedFiatLabel: TLabel;
    Image9: TImage;
    SendWalletFileButton: TButton;
    Image8: TImage;
    SeedMnemonicBackupButton: TButton;
    EQRView: TTabItem;
    EQRHeader: TToolBar;
    eqrHeaderLabel: TLabel;
    EQRBackBtn: TButton;
    EQRShareBtn: TButton;
    eqrVertScrollBox: TVertScrollBox;
    EQRPreview: TImage;
    EQRInstrction: TMemo;
    lblEQRDescription: TLabel;
    ToolBar17: TToolBar;
    SYWLHeaderLabel: TLabel;
    SYWLBackButton: TButton;
    BTCNoTransactionLayout: TLayout;
    motransactionStaticLabel: TLabel;
    BuyBTCOnLabel: TLabel;
    Layout26: TLayout;
    Image10: TImage;
    GridPanelLayout1: TGridPanelLayout;
    WTIChangeLanguageLabel: TLabel;
    WelcomeTabLanguageBox: TPopupBox;
    FiatStaticLabel: TLabel;
    WelcometabFiatPopupBox: TPopupBox;
    Layout27: TLayout;
    ContactAddressStaticLabel: TLabel;
    SuggestionsStaticLabel: TLabel;
    ThankStaticLabel: TLabel;
    coinbaseImage: TImage;
    emptyAddressesLayout: TLayout;
    NoPrivateKeyToExportLabel: TLabel;
    Layout58: TLayout;
    exportemptyAddressesLabel: TLabel;
    LoadAddressesToImortAniIndicator: TAniIndicator;
    PrivacyAndSecuritySettings: TTabItem;
    ToolBar18: TToolBar;
    SaPHeaderLabel: TLabel;
    SaPBackButton: TButton;
    Panel24: TPanel;
    SendErrorMsgLabel: TLabel;
    ReportIssues: TTabItem;
    ToolBar19: TToolBar;
    ReportIssueHeaderLabel: TLabel;
    ReportIssuesBackButton: TButton;
    UserReportMessageMemo: TMemo;
    SendReportIssuesButton: TButton;
    Label22: TLabel;
    Label24: TLabel;
    reportIssuesSettingsButton: TButton;
    PrivacyAndSecurityButton: TButton;
    GlobalStetingsStaticLabel: TLabel;
    LocalSettingsLayout: TLayout;
    GlobalSettingsLayout: TLayout;
    VertScrollBox3: TVertScrollBox;
    Panel25: TPanel;
    UserReportSendLogsLabel: TLabel;
    Panel26: TPanel;
    UserReportDeviceInfoLabel: TLabel;
    Label25: TLabel;
    PrivateKeyInfoPanel: TPanel;
    PrivateKeyAddressInfoLabel: TLabel;
    PrivateKeyBalanceInfoLabel: TLabel;
    FoundTokenTabItem: TTabItem;
    ToolBar21: TToolBar;
    FoundTokenHeaderLabel: TLabel;
    FoundTokenOKButton: TButton;
    FoundTokenVertScrollBox: TVertScrollBox;
    KeypoolSanitizer: TTimer;
    internalImage: TImage;
    SendAllFundsSwitch: TCheckBox;
    FeeFromAmountSwitch: TCheckBox;
    InstantSendSwitch: TCheckBox;
    DayNightModeSwitch: TCheckBox;
    SearchInDashBrdImage: TImage;
    SweepQRButton: TButton;
    CoinFromPrivKeyQRButton: TButton;
    exportemptyaddressesSwitch: TCheckBox;
    SendErrorMsgSwitch: TCheckBox;
    UserReportSendLogsSwitch: TCheckBox;
    UserReportDeviceInfoSwitch: TCheckBox;
    DebugQRImage: TImage;
    AddWalletButton: TButton;
    AddWalletList: TTabItem;
    ToolBar22: TToolBar;
    Label26: TLabel;
    Button12: TButton;
    VertScrollBox4: TVertScrollBox;
    CoinListLayout: TLayout;
    Label27: TLabel;
    TokenListLayout: TLayout;
    Label28: TLabel;
    NanoUnlocker: TButton;
    UnlockNanoImage: TImage;
    //Layout46: TLayout;
    //Layout48: TLayout;
    Panel27: TPanel;
    PasswordInfoStaticLabel: TLabel;
    Layout46: TLayout;
    Layout48: TLayout;
    btnAddManually: TButton;
    FindERC20autoButton: TButton;
    Label29: TLabel;
    Label30: TLabel;
    //Panel27: TPanel;
    //PasswordInfoStaticLabel: TLabel;

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
    procedure ShowFileManager(Sender: TObject); overload;
    procedure FileManagerSelectClick(Sender: TObject);
    procedure FileManagerPathUpButtonClick(Sender: TObject);
    procedure btnRFFBackClick(Sender: TObject);
    procedure RestoreFromFileButtonClick(Sender: TObject);
    procedure RestoreFromFileConfirmButtonClick(Sender: TObject);
    procedure RestoreFromEncryptedQR(Sender: TObject);
    procedure SendDecryptedSeedButtonClick(Sender: TObject);
    procedure LinkLayoutClick(Sender: TObject);
    procedure RestoreOtherOpiotnsButtonClick(Sender: TObject);
    procedure switchLegacyp2pkhButtonClick(Sender: TObject);
    procedure switchCompatiblep2shButtonClick(Sender: TObject);
    procedure SwitchSegwitp2wpkhButtonClick(Sender: TObject);
    procedure receiveAddressOldChange(Sender: TObject);
    procedure BCHLegacyButtonClick(Sender: TObject);
    procedure BCHCashAddrButtonClick(Sender: TObject);
    procedure IPKBackClick(Sender: TObject);
    procedure ImportPrivateKey(Sender: TObject);
    procedure ImportPrivateKeyButtonClick(Sender: TObject);
    procedure APICheckCompressed(Sender: TObject);
    procedure ConfirmNewAccountButtonClick(Sender: TObject);
    procedure AddNewAccountButtonClick(Sender: TObject);
    procedure WVsendTOExit(Sender: TObject);
    procedure IPKCLBackButtonClick(Sender: TObject);
    procedure RefreshAccountList(Sender: TObject);
    procedure HSBPasswordBackBtnClick(Sender: TObject);
    procedure SystemTimerTimer(Sender: TObject);
    procedure updateBtnClick(Sender: TObject);
    procedure BackupBackButtonClick(Sender: TObject);
    procedure FormActivate(Sender: TObject);
    procedure NoPrintScreenImageClick(Sender: TObject);
    procedure SearchTokenButtonClick(Sender: TObject);
    procedure FindERC20autoButtonClick(Sender: TObject);
    procedure CheckUpdateButtonClick(Sender: TObject);
    procedure SendTransactionButtonClick(Sender: TObject);
    procedure CSBackButtonClick(Sender: TObject);
    procedure IsPrivKeySwitchSwitch(Sender: TObject);
    procedure TransactionWaitForSendLinkLabelClick(Sender: TObject);
    procedure TransactionWaitForSendBackButtonClick(Sender: TObject);
    procedure DeleteAccountButtonClick(Sender: TObject);
    procedure closeOrganizeView(Sender: TObject);
    procedure CopyPrivateKeyButtonClick(Sender: TObject);
    procedure PopupBox1Change(Sender: TObject);
    procedure PerByteFeeEditChangeTracking(Sender: TObject);
    procedure PopupBox1Click(Sender: TObject);

    procedure OpenWalletViewFromYWalletList(Sender: TObject);
    procedure deleteYaddress(Sender: TObject);
    procedure generateNewAddressesClick(Sender: TObject);
    procedure QRCodeImageClick(Sender: TObject);
    procedure FindUnusedAddressButtonClick(Sender: TObject);
    procedure OwnXCheckBoxChange(Sender: TObject);
    procedure BigQRCodeImageClick(Sender: TObject);
    procedure changeYbuttonClick(Sender: TObject);
    procedure DayNightModeSwitchSwitch(Sender: TObject);
    procedure TrackBar1Change(Sender: TObject);
    procedure SpinBox1Change(Sender: TObject);
    procedure backBtnDecryptSeed(Sender: TObject);
    procedure HideZeroWalletsCheckBoxChange(Sender: TObject);
    procedure notPrivTCA2Change(Sender: TObject);
    procedure LoadMoreClick(Sender: TObject);
    procedure YAddressClick(Sender: TObject);
    procedure AccountsListPanelExit(Sender: TObject);
    procedure AccountsListPanelMouseLeave(Sender: TObject);
    procedure InstantSendSwitchClick(Sender: TObject);
    procedure FormFocusChanged(Sender: TObject);
    procedure CopyTextButtonClick(Sender: TObject);
    procedure PanelSelectGenerateCoinOnClick(Sender: TObject);
    procedure NextButtonSGCClick(Sender: TObject);
    procedure ClaimYourBCHSVButtonClick(Sender: TObject);
    procedure claimButtonClick(Sender: TObject);
    procedure ConfirmSendClaimCoinButtonClick(Sender: TObject);
    procedure MainScreenQRButtonClick(Sender: TObject);
    procedure PrivateKeyManageButtonClick(Sender: TObject);
    procedure Button10Click(Sender: TObject);
    procedure ImportPrivateKeyInPrivButtonClick(Sender: TObject);
    procedure SweepButtonClick(Sender: TObject);
    procedure ExportPrivateKeyButtonClick(Sender: TObject);
    procedure CTIHeaderBackButtonClick(Sender: TObject);
    procedure NewCoinPrivKeyOKButtonClick(Sender: TObject);
    procedure EQRShareBtnClick(Sender: TObject);
    procedure EQRPreviewClick(Sender: TObject);
    procedure EQRBackBtnClick(Sender: TObject);
    procedure AAccBackButtonClick(Sender: TObject);
    procedure EPCLTIBackButtonClick(Sender: TObject);
    procedure SYWLBackButtonClick(Sender: TObject);
    procedure coinbaseImageClick(Sender: TObject);
    procedure exportemptyaddressesSwitchSwitch(Sender: TObject);
    procedure Button5Click(Sender: TObject);
    procedure SendReportIssuesButtonClick(Sender: TObject);
    procedure reportIssuesSettingsButtonClick(Sender: TObject);
    procedure PrivacyAndSecurityButtonClick(Sender: TObject);
    procedure SendErrorMsgSwitchSwitch(Sender: TObject);
    procedure ReportIssuesBackButtonClick(Sender: TObject);
    procedure SaPBackButtonClick(Sender: TObject);
    procedure passwordForDecryptKeyUp(Sender: TObject; var Key: Word;
      var KeyChar: Char; Shift: TShiftState);
    procedure GenerateYAddressPasswordEditKeyUp(Sender: TObject; var Key: Word;
      var KeyChar: Char; Shift: TShiftState);
    procedure RFFPasswordKeyUp(Sender: TObject; var Key: Word;
      var KeyChar: Char; Shift: TShiftState);
    procedure AccountNameEditKeyUp(Sender: TObject; var Key: Word;
      var KeyChar: Char; Shift: TShiftState);
    procedure passKeyUp(Sender: TObject; var Key: Word; var KeyChar: Char;
      Shift: TShiftState);
    procedure retypePassKeyUp(Sender: TObject; var Key: Word; var KeyChar: Char;
      Shift: TShiftState);
    procedure RestoreFromFileAccountNameEditKeyUp(Sender: TObject;
      var Key: Word; var KeyChar: Char; Shift: TShiftState);
    procedure ContractAddressKeyUp(Sender: TObject; var Key: Word;
      var KeyChar: Char; Shift: TShiftState);
    procedure TokenNameFieldKeyUp(Sender: TObject; var Key: Word;
      var KeyChar: Char; Shift: TShiftState);
    procedure SymbolFieldKeyUp(Sender: TObject; var Key: Word;
      var KeyChar: Char; Shift: TShiftState);
    procedure DecimalsFieldKeyUp(Sender: TObject; var Key: Word;
      var KeyChar: Char; Shift: TShiftState);
    procedure ChangeDescryptionEditKeyUp(Sender: TObject; var Key: Word;
      var KeyChar: Char; Shift: TShiftState);
    procedure RestoreNameEditKeyUp(Sender: TObject; var Key: Word;
      var KeyChar: Char; Shift: TShiftState);
    procedure RestorePasswordEditKeyUp(Sender: TObject; var Key: Word;
      var KeyChar: Char; Shift: TShiftState);
    procedure WIFEditKeyUp(Sender: TObject; var Key: Word; var KeyChar: Char;
      Shift: TShiftState);
    procedure FoundTokenOKButtonClick(Sender: TObject);
    procedure KeypoolSanitizerTimer(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure WVsendTOChange(Sender: TObject);
    procedure wvFeeChange(Sender: TObject);
    procedure exportemptyaddressesSwitchClick(Sender: TObject);
    procedure CoinFromPrivKeyQRButtonClick(Sender: TObject);
    procedure SweepQRButtonClick(Sender: TObject);
    procedure btnChangeDescryptionBackClick(Sender: TObject);
    procedure SendErrorMsgSwitchClick(Sender: TObject);
    procedure AddWalletButtonClick(Sender: TObject);
    procedure NanoUnlockerClick(Sender: TObject);
    procedure UnlockPengingTransactionClick(Sender: TObject);
    //procedure UserReportSendLogsSwitchClick(Sender: TObject);

  private
    { Private declarations }

    procedure GetImage();
    procedure MineNano(Sender: TObject);
  public
    { Public declarations }

{$IF NOT DEFINED(LINUX)}
    MotionSensor: TMotionSensor;
    OrientationSensor: TOrientationSensor;
{$ENDIF}
    FScanManager: TScanManager;
    FScanInProgress: Boolean;
    FFrameTake: Integer;
{$IFDEF ANDROID}
    procedure RegisterDelphiNativeMethods();
{$ENDIF}
    procedure OpenWalletView(Sender: TObject; const Point: TPointF); overload;
    procedure OpenWalletView(Sender: TObject); overload;

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
    procedure removeAccount(Sender: TObject);
    procedure PopupBox1_popupMenuClose(Sender: TObject);

    procedure CoinListCreateFromSeed(Sender: TObject);
    procedure CoinListCreateFromQR(Sender: TObject);
    procedure ClaimCoinSelectInListClick(Sender: TObject);
    procedure TransactionWalletListClick(Sender: TObject);
    procedure CopyParentTagStringToClipboard(Sender: TObject);
    procedure CopyParentTextToClipboard(Sender: TObject);
    procedure ExportPrivKeyListButtonClick(Sender: TObject);
    procedure RefreshCurrentWallet(Sender: TObject);
    procedure onExecuteTest(Sender: TObject);

    procedure ExceptionHandler(Sender: TObject; E: Exception);
    procedure FoundTokenPanelOnClick(Sender: TObject);
    procedure GenerateETHAddressWithToken(Sender : TObject);
    procedure AddTokenFromWalletList(Sender : TObject );
    procedure AddNewTokenETHPanelClick(sender : Tobject );
    procedure UnlockPendingNano(sender : TObject);
    // procedure PrivateKeyPasswordCheck
  var
    refreshLocalImage: TRotateImage;
    refreshGlobalImage: TRotateImage;
    NotificationLayout : TNotificationLayout;

    wvAddress , receiveAddress : TCopyableAddressPanel;


  var
    HistoryMaxLength: Integer;
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
// procedure LoadCurrentAccount(name: AnsiString);
// procedure reloadWalletView;

const
  SYSTEM_APP: Boolean = {$IFDEF ANDROID}false{$ELSE}false{$ENDIF};
  // Load OS.xml as manifest and place app in /system/priv-app

var

  frmHome: TfrmHome;
  trngBuffer: AnsiString;
  trngBufferCounter: Integer;
  stylo: TStyleManager;
  QRCodeBitmap: TBitmap;

  // newcoinID: nativeint;
  // ImportCoinID: Integer;

  walletAddressForNewToken: AnsiString;
  tempMasterSeed: AnsiString;
  decryptSeedBackTabItem: TTabItem;
  cameraBackTabItem: TTabItem;
  dashboardDecimalsPrecision: Integer = 6;
  // dashBoardFontSize: Integer =
  // {$IF (DEFINED(MSWINDOWS) OR DEFINED(LINUX))}14{$ELSE}8{$ENDIF};
  flagWVPrecision: Boolean = true;
  CurrentCryptoCurrency: CryptoCurrency;
  CurrentCoin: TwalletInfo;
  duringSync: Boolean = false;
  duringHistorySync: Boolean = false;
  QRWidth: Integer = -1;
  QRHeight: Integer = -1;
  SyncBalanceThr: SynchronizeBalanceThread;
  // SyncHistoryThr: SynchronizeHistoryThread;

  QRFind: AnsiString;
  tempQRFindEncryptedSeed: AnsiString;
  lastClosedAccount: AnsiString;
  CurrentAccount: Account;
  CurrentStyle: AnsiString;
  BigQRCodeBackTab: TTabItem;

  ToClaimWD, FromClaimWD: TwalletInfo;

resourcestring
  QRSearchEncryted = 'QRSearchEncryted';
  QRSearchDecryted = 'QRSearchDecryted';

var
  LATEST_VERSION: AnsiString;

implementation

uses ECCObj, Bitcoin, Ethereum, secp256k1, uSeedCreation, coindata, base58,
  TokenData, AccountRelated, QRRelated, FileManagerRelated, WalletViewRelated,
  BackupRelated, debugAnalysis, KeypoolRelated,Nano
{$IFDEF ANDRIOD}
{$ENDIF}
{$IFDEF MSWINDOWS}
    , Winapi.ShellAPI
{$ENDIF};
{$R *.fmx}
{$R *.SmXhdpiPh.fmx ANDROID}
{$R *.iPhone55in.fmx IOS}
{$R *.LgXhdpiPh.fmx ANDROID}
{$R *.Windows.fmx MSWINDOWS}
{$R *.Surface.fmx MSWINDOWS}
{$IFNDEF MSWINDOWS}

function ShellExecute(a: Integer; b, c: String; d, E: PWideChar;
  f: Integer): Integer;
begin

end;

{$ENDIF}



procedure tfrmhome.UnlockPendingNano(sender : TObject);
var
  tced: AnsiString;
  MasterSeed: AnsiString;
  nano : NanoCoin;
begin

  //nano_DoMine(cryptoCurrency(NanoUnlocker.TagObject),passwordForDecrypt.Text);

  tced := TCA(passwordForDecrypt.Text);
  MasterSeed := SpeckDecrypt(tced, CurrentAccount.EncryptedMasterSeed);
    passwordForDecrypt.Text := '';
    if not isHex(masterseed) then
    begin
      popupWindow.create(dictionary('FailedToDecrypt'));
      exit;
    end;

  nano := NanoCoin(currentcryptoCurrency);

  nano.unlock( MasterSeed );

  wipeansistring(masterseed);

  PageControl.ActiveTab:=decryptSeedBackTabItem;


end;


procedure tfrmhome.GenerateETHAddressWithToken(Sender : TObject);
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
  LoadCurrentAccount(RestoreNameEdit.Text);
  frmHome.FormShow(nil);
  tced := '';
  startFullfillingKeypool(MasterSeed);
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

procedure TfrmHome.passKeyUp(Sender: TObject; var Key: Word; var KeyChar: Char;
Shift: TShiftState);
begin
  if Key = vkReturn then
  begin
    retypePass.SetFocus;
  end;
end;

procedure TfrmHome.passwordForDecryptKeyUp(Sender: TObject; var Key: Word;
var KeyChar: Char; Shift: TShiftState);
begin

  if Key = vkReturn then
  begin
    btnDecryptSeed.onclick(nil);
  end;

end;

procedure TfrmHome.LoadMoreClick(Sender: TObject);
var
  i: Integer;
begin
  createHistoryList(CurrentCryptoCurrency, txHistory.ComponentCount - 1,
    txHistory.ComponentCount + 9);
end;

procedure TfrmHome.MainScreenQRButtonClick(Sender: TObject);
begin
  QRRelated.scanQR(Sender);
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
  ImportCoinID := TfmxObject(Sender).Tag;

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
var
  found: Integer;
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

procedure TfrmHome.ExportPrivateKeyButtonClick(Sender: TObject);
begin
  WalletViewRelated.ExportPrivateKeyButtonClick(Sender);
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
  MovingPanel.Parent := OrganizeList;
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
  temp := 180 * (length(CurrentCoin.UTXO)) + 2 * 34 + 10 + 2;

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

procedure TfrmHome.PopupBox1_popupMenuClose(Sender: TObject);
begin

end;

procedure TfrmHome.PrivacyAndSecurityButtonClick(Sender: TObject);
begin
  switchTab(PageControl, PrivacyAndSecuritySettings);
end;

procedure TfrmHome.PrivateKeyManageButtonClick(Sender: TObject);
begin
  switchTab(PageControl, PrivOptionsTabItem);
end;

procedure TfrmHome.PopupBox1Click(Sender: TObject);
begin
  if PopupBox1.Items.Count = 4 then
    PopupBox1.Items.Delete(3);

  // popupBox1.PopupMenu. := PopupBox1_popupMenuClose;
end;

procedure TfrmHome.LanguageBoxChange(Sender: TObject);
begin
  WalletViewRelated.changeLanguage(Sender);
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

procedure TfrmHome.WIFEditKeyUp(Sender: TObject; var Key: Word;
var KeyChar: Char; Shift: TShiftState);
begin // NewCoinPrivKeyOKButtonClick
  if Key = vkReturn then
  begin
    NewCoinPrivKeyOKButtonClick(nil);
  end;
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
  backTabItem := frmHome.PageControl.ActiveTab;
  if not frmHome.shown then
  begin
    TabControl.ActiveTab := TabItem;
  end
  else
  begin
    frmHome.tabAnim.Tab := TabItem;

    frmHome.tabAnim.ExecuteTarget(TabControl);
  end;
  frmHome.passwordForDecrypt.Text := '';
  frmHome.DecryptSeedMessage.Text := '';

  if TabControl.ActiveTab = frmHome.ChangeDescryptionScreen then
    frmHome.NewCoinDescriptionPassEdit.SetFocus;
  if TabControl.ActiveTab = frmHome.descryptSeed then
    frmHome.passwordForDecrypt.SetFocus;
end;

procedure TfrmHome.WVRealCurrencyChange(Sender: TObject);
begin
  WVRealCurrency.Text := StringReplace(WVRealCurrency.Text, ',', '.',
    [rfReplaceAll]);

    if frmhome.WVTabControl.ActiveTab = frmhome.WVSend then
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
  createPasswordBackTabItem := PageControl.ActiveTab;
  switchTab(PageControl, createPassword);

end;

procedure TfrmHome.SelectFileInBackupFileList(Sender: TObject);
begin
  RFFPathEdit.Text := TfmxObject(Sender).TagString;
  RestoreFromFileAccountNameEdit.Text := getUnusedAccountName();
  switchTab(PageControl, HSBPassword);
end;

procedure TfrmHome.RestoreFromFileAccountNameEditKeyUp(Sender: TObject;
var Key: Word; var KeyChar: Char; Shift: TShiftState);
begin
  if Key = vkReturn then
  begin
    RFFPassword.SetFocus;
  end;
end;

procedure TfrmHome.RestoreFromFileButtonClick(Sender: TObject);
begin

  RestoreFromFile(Sender);

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

procedure TfrmHome.RestoreNameEditKeyUp(Sender: TObject; var Key: Word;
var KeyChar: Char; Shift: TShiftState);
begin
  if Key = vkReturn then
  begin
    RestorePasswordEdit.SetFocus;
  end;
end;

procedure TfrmHome.RestoreSeedEncryptedQRButtonClick(Sender: TObject);
begin
  QRFind := QRSearchEncryted;
  btnQRClick(nil);
end;

procedure TfrmHome.retypePassKeyUp(Sender: TObject; var Key: Word;
var KeyChar: Char; Shift: TShiftState);
begin
  if Key = vkReturn then
  begin
    btnCreateWalletClick(nil);
  end;
end;

procedure TfrmHome.RFFPasswordKeyUp(Sender: TObject; var Key: Word;
var KeyChar: Char; Shift: TShiftState);
begin
  if Key = vkReturn then
  begin
    btnDecryptSeed.onclick(nil);
  end;

end;

procedure TfrmHome.WVsendTOChange(Sender: TObject);
begin
  if frmhome.WVTabControl.ActiveTab = frmhome.WVSend then
  saveSendCacheToFile();
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

end;

{ procedure TfrmHome.WVTokenChoseInWallet(Sender: TObject);
  begin
  WVTokenChoseInWallet(Sender, TPointF.Zero);
  end; }

procedure TfrmHome.backBtnDecryptSeed(Sender: TObject);
begin
  switchTab(PageControl, decryptSeedBackTabItem);
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
    (TwalletInfo(CurrentCryptoCurrency).addr , false);
  receiveAddress.Text := receiveAddress.Text;
end;

procedure TfrmHome.BCHLegacyButtonClick(Sender: TObject);
begin
  receiveAddress.Text := TwalletInfo(CurrentCryptoCurrency).addr;
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

procedure TfrmHome.ChangeDescryptionEditKeyUp(Sender: TObject; var Key: Word;
var KeyChar: Char; Shift: TShiftState);
begin

  if Key = vkReturn then
  begin
    btnChangeDescryptionOKClick(nil);
  end;

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

procedure downloadLatest(ver: string);
var
  aURL: string;
var
  req: THTTPClient;
  LResponse: IHTTPResponse;
var
  FileStream: TFileStream;
  fPath: String;
begin
{$IFDEF MSWINDOWS}
  fPath := ExtractFileDir(ParamStr(0)) + '/update.bin';

  aURL := 'https://github.com/HODLERTECH/Putty-Updater/raw/master/binaries/' +
    trim(ver) + '.exe?xx=' + IntToStr(random($FFFFF));
  URLDownloadToFile(nil, PWideChar(aURL), PWideChar(fPath), 0, nil);
{$ELSE}
  Showmessage('notImplemented');
{$ENDIF}
end;

function GetFileSize(const FileName: string): int64;
var
  Reader: TFileStream;
begin
  Reader := TFile.OpenRead(FileName);
  try
    result := Reader.Size;
  finally
    Reader.free;
  end;
end;

procedure TfrmHome.CheckUpdateButtonClick(Sender: TObject);
var
  exePath, cmd: string;
var
  X: Integer;
begin
  frmHome.BeginUpdate;

  if (LATEST_VERSION <> '') and
    (compareVersion(LATEST_VERSION, CURRENT_VERSION) > 0) then
  begin
    frmHome.Caption := 'HODLER Open Source Multi-Asset Wallet v' +
      CURRENT_VERSION + ' (New version is available)';
    X := MessageDlg
      ('The new version is available.  Do you want to download it?',
      TMsgDlgType.mtConfirmation, mbYesNo, 0);
    if X = mrYes then
      TThread.Synchronize(nil,
        procedure
        begin
          exePath := ExtractFileDir(ParamStr(0));
          frmHome.Caption := 'Downloading new version...';
          downloadLatest(LATEST_VERSION);
          if GetFileSize(ExtractFileDir(ParamStr(0)) + '/update.bin') > 1024
          then
          begin
            cmd := ' /k "timeout 3 && cd "' + exePath + '" && del "' +
              extractfilename(ParamStr(0)) + '" && rename update.bin "' +
              extractfilename(ParamStr(0)) + '" && "' +
              extractfilename(ParamStr(0)) + '" "';
            ShellExecute(0, 'Open', 'cmd.exe', PWideChar(cmd),
              PWideChar(exePath), 0);
            halt(0);
          end;
        end);

  end
  else if (LATEST_VERSION <> '') and
    (compareVersion(LATEST_VERSION, CURRENT_VERSION) < 0) then
  begin
    frmHome.Caption := 'HODLER Open Source Multi-Asset Wallet v' +
      CURRENT_VERSION + ' ( Unofficial Version )';
    popupWindow.Create(' Unofficial Version ');
  end
  else
  begin
    popupWindow.Create(dictionary('LatestVersion'));
  end;
  Application.ProcessMessages  ;
  frmHome.EndUpdate;
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

procedure TfrmHome.claimButtonClick(Sender: TObject);
begin

  if CurrentAccount = nil then
  begin
    privTCAPanel2.Visible := false;
    notPrivTCA2.IsChecked := false;
    pass.Text := '';
    retypePass.Text := '';
    btnCreateWallet.Text := dictionary('OpenNewWallet');
    procCreateWallet := btnGenSeedClick;
    btnCreateWallet.TagString := 'claim';
    // generate list options - '' default ( user chose coin )
    createPasswordBackTabItem := PageControl.ActiveTab;
    switchTab(PageControl, createPassword);
    exit();
  end;

  createClaimCoinList(7);

  switchTab(PageControl, ClaimWalletListTabItem);
end;

procedure TfrmHome.ClaimYourBCHSVButtonClick(Sender: TObject);
begin

  try
    claim(newcoinID);
  except
    on E: Exception do
    begin
      popupWindow.Create(E.Message);
    end;
  end;

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

  btnDecryptSeed.onclick := decryptSeedForSeedRestore;

  decryptSeedBackTabItem := PageControl.ActiveTab;
  PageControl.ActiveTab := descryptSeed;
  btnDSBack.onclick := backBtnDecryptSeed;

end;

procedure TfrmHome.DecimalsFieldKeyUp(Sender: TObject; var Key: Word;
var KeyChar: Char; Shift: TShiftState);
begin
  if Key = vkReturn then
  begin
    btnAddContractClick(nil);
  end;
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

procedure TfrmHome.AAccBackButtonClick(Sender: TObject);
begin
  switchTab(PageControl, HOME_TABITEM);
end;

procedure TfrmHome.AccountNameEditKeyUp(Sender: TObject; var Key: Word;
var KeyChar: Char; Shift: TShiftState);
begin
  if Key = vkReturn then
  begin
    pass.SetFocus;
  end;

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
// var od:TOpenDialog;
begin
  { od:=TOpenDialog.Create(nil);
    if od.execute then
    stylo.SetStyleFromFile(od.FileName);
    od.Free; }

  switchTab(PageControl, AddAccount);
  // AccountsListPanel.Visible := false;
end;

procedure TfrmHome.addNewWalletPanelClick(Sender: TObject);
begin
  WalletViewRelated.addNewWalletPanelClick(Sender);
end;

procedure TfrmHome.TokenNameFieldKeyUp(Sender: TObject; var Key: Word;
var KeyChar: Char; Shift: TShiftState);
begin // SymbolField
  if Key = vkReturn then
  begin
    SymbolField.SetFocus;
  end;
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
{$ELSE}
  ShellExecute(0, 'OPEN', PWideChar(URL), '', '', { SW_SHOWNORMAL } 1);
{$ENDIF ANDROID}
end;

procedure TfrmHome.TrySendTX(Sender: TObject);
begin
  WalletViewRelated.TrySendTransaction(Sender);
end;

procedure TfrmHome.UnlockPengingTransactionClick(Sender: TObject);
var
  nano : NanoCoin;
begin
    if currentCryptocurrency is NanoCoin then
    begin

     if NanoCoin(currentCryptocurrency).isUnlocked then exit;
     frmhome.UnlockNanoImage.Hint:='When unlocked, receive blocks will be autopocketed';

     NotificationLayout.popupPasswordConfirm(procedure (pass : AnsiString)
     var
        tced , MasterSeed : AnsiString;
     begin

        tced := TCA( pass );
        MasterSeed := SpeckDecrypt(tced, CurrentAccount.EncryptedMasterSeed);
          passwordForDecrypt.Text := '';
          if not isHex(masterseed) then
          begin
            popupWindow.create(dictionary('FailedToDecrypt'));
            exit;
          end;

        nano := NanoCoin(currentcryptoCurrency);

        nano.unlock( MasterSeed );

        wipeansistring(masterseed);
        frmhome.UnlockNanoImage.Bitmap.LoadFromStream( resourceMenager.getAssets('OPENED') );

        //PageControl.ActiveTab:=decryptSeedBackTabItem;

     end, procedure ( pass : AnsiString )
     begin

     end
     , 'Enter the password to pocket the pending NANO' );



  //btnDecryptSeed.onclick := UnlockPendingNano;
  //decryptSeedBackTabItem := PageControl.ActiveTab;
  //PageControl.ActiveTab := descryptSeed;
  //btnDSBack.onclick := backBtnDecryptSeed;

    end
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
   if frmhome.WVTabControl.ActiveTab = frmhome.WVSend then
  saveSendCacheToFile();

  //wvAmount.TextSettings.Font.Size := i;
  //wvAmount.Text := StringReplace(wvAmount.Text, ',', '.', [rfReplaceAll]);
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
  if frmhome.WVTabControl.ActiveTab = frmhome.WVSend then
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

procedure TfrmHome.ConfirmNewAccountButtonClick(Sender: TObject);
var
  str: AnsiString;
  newAcc: Account;
begin

  pass.Text := '';
  retypePass.Text := '';
  btnCreateWallet.Text := dictionary('OpenNewWallet');
  procCreateWallet := btnGenSeedClick;
  createPasswordBackTabItem := PageControl.ActiveTab;
  switchTab(PageControl, createPassword);

end;

procedure TfrmHome.ConfirmSendClaimCoinButtonClick(Sender: TObject);
var
  temp: TwalletInfo;
begin
  temp := CurrentCoin;
  CurrentCoin := FromClaimWD;
  WalletViewRelated.PrepareSendTabAndSend(FromClaimWD, ToClaimWD.addr,
    FromClaimWD.confirmed - BigInteger(1700), BigInteger(1700), '',
    AvailableCoin[FromClaimWD.coin].name);
  // CurrentCoin := temp;
end;

procedure TfrmHome.ContractAddressKeyUp(Sender: TObject; var Key: Word;
var KeyChar: Char; Shift: TShiftState);
begin
  if Key = vkReturn then
  begin
    TokenNameField.SetFocus;
  end;
end;

procedure TfrmHome.CopyPrivateKeyButtonClick(Sender: TObject);
var
  svc: IFMXExtendedClipboardService;
begin
  { if TPlatformServices.Current.SupportsPlatformService(IFMXClipboardService, svc)
    then
    begin

    svc.setClipboard(removeSpace(lblPrivateKey.Text));
    popupWindow.Create(dictionary('CopiedToClipboard'));

    end; }
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

    if (Sender is TEdit) then
    begin

      if svc.GetClipboard().ToString() <> removeSpace(TEdit(Sender).Text) then
      begin
        svc.setClipboard(removeSpace(TEdit(Sender).Text));
        popupWindow.Create(dictionary('CopiedToClipboard'));
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

  //PopupWindowProtectYesNo.Create(
    NotificationLayout.popupProtectedConfirm(
    procedure()
    begin
      wipeWalletDat;
{$IF  (DEFINED(MSWINDOWS) OR DEFINED(LINUX) OR DEFINED(IOS))}
      frmHome.Close;
{$ENDIF}
{$IFDEF ANDROID}
      SharedActivity.finish;
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
   WalletViewRelated.btnAddContractClick(Sender);

end;

procedure TfrmHome.btnSBackClick(Sender: TObject);
begin
  switchTab(PageControl, SelectGenerateCoinViewBackTabItem);
end;

procedure TfrmHome.btnSCBackClick(Sender: TObject);
begin
  switchTab(PageControl, createPassword);
end;

procedure TfrmHome.btnANWBackClick(Sender: TObject);
begin
  switchTab(PageControl, AddCoinBackTabItem { walletView } );
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

procedure TfrmHome.RestorePasswordEditKeyUp(Sender: TObject; var Key: Word;
var KeyChar: Char; Shift: TShiftState);
begin // RestoreWalletOKButton
  if Key = vkReturn then
  begin
    RestoreWalletOKButton.onclick(nil);
  end;
end;

procedure TfrmHome.switchLegacyp2pkhButtonClick(Sender: TObject);
begin
  receiveAddress.Text := Bitcoin.generatep2pkh
    (TwalletInfo(CurrentCryptoCurrency).pub,
    AvailableCoin[TwalletInfo(CurrentCryptoCurrency).coin].p2pk);

  receiveAddress.Text := receiveAddress.Text;
end;

procedure TfrmHome.switchCompatiblep2shButtonClick(Sender: TObject);
begin
  receiveAddress.Text := Bitcoin.generatep2sh(TwalletInfo(CurrentCryptoCurrency)
    .pub, AvailableCoin[TwalletInfo(CurrentCryptoCurrency).coin].p2sh);

  receiveAddress.Text := receiveAddress.Text;
end;

procedure TfrmHome.SwitchSegwitp2wpkhButtonClick(Sender: TObject);
begin

  receiveAddress.setText( Bitcoin.generatep2wpkh
    (TwalletInfo(CurrentCryptoCurrency).pub,
    AvailableCoin[TwalletInfo(CurrentCryptoCurrency).coin].hrp) , 3 );

  receiveAddress.Text := receiveAddress.Text;
end;

procedure TfrmHome.LoadAccountPanelClick(Sender: TObject);
begin
  if OrganizeList.Visible = true then
    closeOrganizeView(nil);
  firstSync := true;

  LoadCurrentAccount(TfmxObject(Sender).TagString);
end;

procedure TfrmHome.notPrivTCA2Change(Sender: TObject);
begin
  notPrivTCA1.IsChecked := notPrivTCA2.IsChecked;
end;
procedure TfrmHome.MineNano(Sender: TObject);
begin
  nano_DoMine(cryptoCurrency(NanoUnlocker.TagObject),passwordForDecrypt.Text);
  passwordForDecrypt.Text:='';
  PageControl.ActiveTab:=walletView;
end;
procedure TfrmHome.NanoUnlockerClick(Sender: TObject);
begin
     btnDecryptSeed.onclick := MIneNano;
  decryptSeedBackTabItem := PageControl.ActiveTab;
  PageControl.ActiveTab := descryptSeed;
  btnDSBack.onclick := backBtnDecryptSeed;
end;

procedure TfrmHome.NewCoinPrivKeyOKButtonClick(Sender: TObject);
begin
  WalletViewRelated.newCoinFromPrivateKey(Sender);

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

procedure TfrmHome.NoPrintScreenImageClick(Sender: TObject);
begin
  NoPrintScreenImage.Visible := false;
end;

procedure TfrmHome.RefreshAccountList(Sender: TObject);
begin
  AccountRelated.changeAccount(Sender);
end;

procedure TfrmHome.HSBPasswordBackBtnClick(Sender: TObject);
begin
  switchTab(PageControl, RestoreFromFileTabitem);
end;

procedure TfrmHome.CSBackButtonClick(Sender: TObject);
begin

  switchTab(PageControl, walletView);
end;

procedure TfrmHome.CTIHeaderBackButtonClick(Sender: TObject);
begin
  switchTab(PageControl, ClaimWalletListTabItem);

end;

procedure TfrmHome.SendTransactionButtonClick(Sender: TObject);
begin

  TrySendTX(Sender);

end;

procedure TfrmHome.Button10Click(Sender: TObject);
begin
  switchTab(PageControl, Settings);
end;


procedure TfrmHome.CoinFromPrivKeyQRButtonClick(Sender: TObject);
begin
  QRRelated.scanQR(Sender);
end;

procedure TfrmHome.ReportIssuesBackButtonClick(Sender: TObject);
begin
  switchTab(PageControl, Settings);
end;

procedure TfrmHome.EPCLTIBackButtonClick(Sender: TObject);
begin
  switchTab(PageControl, AddNewCoin);
end;

procedure TfrmHome.EQRBackBtnClick(Sender: TObject);
begin
  switchTab(PageControl, HOME_TABITEM);
end;

procedure TfrmHome.EQRPreviewClick(Sender: TObject);
begin
  switchTab(PageControl, HOME_TABITEM);
end;

procedure TfrmHome.EQRShareBtnClick(Sender: TObject);
begin
  shareFile(System.IOUtils.TPath.Combine(HOME_PATH, CurrentAccount.name +
    '_EQR_BIG' + '.png'), false);
end;

procedure TfrmHome.exportemptyaddressesSwitchClick(Sender: TObject);
begin
  exportemptyaddressesSwitchSwitch(Sender);
end;

procedure TfrmHome.exportemptyaddressesSwitchSwitch(Sender: TObject);
begin
  createExportPrivateKeyList(newcoinID);
end;

procedure TfrmHome.onExecuteTest(Sender: TObject);
begin

  Showmessage(TfmxObject(Sender).name);

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

  actionListener: TActionList;

  temp : TAddressLabel;
begin

  label1.text := '';
  //cutAndDecorateLabel( label1 );

  temp := TAddressLabel.Create( Panel1 );
  temp.Parent := Panel1;
  temp.Align := TAlignLayout.Center;
  temp.Visible := true;
  temp.setText(  Edit4.Text + Edit1.Text , 4 ) ;

end;

procedure TfrmHome.Button5Click(Sender: TObject);
begin
  switchTab(PageControl, AddNewCoin);
end;

procedure TfrmHome.ImportPrivateKey(Sender: TObject);
begin
  BackupRelated.ImportPriv(Sender);
  switchTab(PageControl, walletView);
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

  WalletViewRelated.newCoin { FromPrivateKey } (Sender);

end;

procedure TfrmHome.btnChangeDescriptionClick(Sender: TObject);
begin
  WalletViewRelated.btnChangeDescriptionClick(Sender);
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

  WalletViewRelated.btnCreateNewWalletClick(Sender);
  { privTCAPanel2.Visible := false;
    notPrivTCA2.IsChecked := false;
    pass.Text := '';
    retypePass.Text := '';
    btnCreateWallet.Text := dictionary('OpenNewWallet');
    procCreateWallet := btnGenSeedClick;
    btnCreateWallet.TagString := '' ; // generate list options - '' default ( user chose coin )
    AccountNameEdit.Text := getUnusedAccountName();
    switchTab(PageControl, createPassword); }

end;

procedure TfrmHome.btnCreateWalletClick(Sender: TObject);
begin
  WalletViewRelated.CreateWallet(Sender, TfmxObject(Sender).TagString);
  // tagString - generate list oprions | '' - user choose coins | 'claim' - only BSV
end;

procedure TfrmHome.btnChangeDescryptionBackClick(Sender: TObject);
begin
  switchTab(PageControl , walletView );
end;

procedure TfrmHome.btnChangeDescryptionOKClick(Sender: TObject);
begin
  WalletViewRelated.btnChangeDescryptionOKClick(Sender);
  { CurrentCryptoCurrency.description := ChangeDescryptionEdit.Text;
    CurrentAccount.SaveFiles();
    misc.updateNameLabels();
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
  btnDSBack.onclick := backBtnDecryptSeed;
  btnDecryptSeed.onclick := privateKeyPasswordCheck;
  WDToExportPrivKey := CurrentCoin;

end;

procedure TfrmHome.btnANTBackClick(Sender: TObject);
begin
  switchTab(PageControl, chooseETHWalletBackTabItem );
end;

procedure TfrmHome.btnEKSBackClick(Sender: TObject);
begin

  lblPrivateKey.Text := '';

  WVTabControl.ActiveTab := WVBalance;
  switchTab(PageControl, walletView);
end;

procedure TfrmHome.btnAddManuallyClick(Sender: TObject);
begin
  switchTab(PageControl, ManuallyToken);
end;

procedure TfrmHome.btnMTBackClick(Sender: TObject);
begin
  switchTab(PageControl, AddWalletList );
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
  backTabItem := HOME_TABITEM;
  AddCoinBackTabItem := PageControl.ActiveTab;
  switchTab(PageControl, AddNewCoin);
end;

procedure TfrmHome.btnBackClick(Sender: TObject);
begin
  CurrentCryptoCurrency := nil;
  CurrentCoin := nil;
  switchTab(PageControl, walletView);
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

procedure TfrmHome.GenerateYAddressPasswordEditKeyUp(Sender: TObject;
var Key: Word; var KeyChar: Char; Shift: TShiftState);
begin
  if Key = vkReturn then
  begin

    generateNewAddressesClick(nil);

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

procedure TfrmHome.FormActivate(Sender: TObject);
begin
  NoPrintScreenImage.Visible := false;
end;

procedure TfrmHome.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  AccountRelated.CloseHodler();
end;

procedure TfrmHome.FormCloseQuery(Sender: TObject; var CanClose: Boolean);
begin
  //AccountRelated.CloseHodler();
{$IFDEF WIN32 or WIN64}
  stylo.Destroy;
  try
    //halt(0);
  except

  end;
{$ENDIF}
end;

procedure TfrmHome.FormCreate(Sender: TObject);
begin
{$IF NOT DEFINED(LINUX)}
  MotionSensor := TMotionSensor.Create(frmHome);
  OrientationSensor := TOrientationSensor.Create(frmHome);

{$ENDIF}
  AccountRelated.InitializeHodler;
  BackupInfoLabel.Position.Y := 100000;
end;

procedure TfrmHome.FormFocusChanged(Sender: TObject);
begin
  // SetCopyButtonPosition;
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
          Showmessage('OK');
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
      // (PageControl.ActiveTab = createPassword) or
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
      end
      else if PageControl.ActiveTab = RestoreOptions then
      begin
        switchTab(PageControl, WelcomeTabItem);
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
      + floattoStr(Y * random($FFFF)) + IntToStr(random($FFFFFFFF)) +
      ISecureRandomBuffer;
end;

procedure TfrmHome.FormResize(Sender: TObject);
begin
  (* {$IFDEF WIN32 or WIN64}
    // FIREMONKEY DOES NOT HAVE FORM CONSTRAITS
    if frmHome.ClientWidth <> 384 then
    frmHome.ClientWidth := 384;
    if frmHome.ClientHeight <> 567 then
    frmHome.ClientHeight := 567;
    {$ENDIF} *)
end;

procedure TfrmHome.FormShow(Sender: TObject);
  procedure LabelEditApplyStyleLookup(Sender: TObject);
  var
    Obj: TfmxObject;
  begin
    Obj := (Sender as TCustomEdit).FindStyleResource('background');
    if Obj is TControl then
      TControl(Obj).Opacity := 0;
  end;

  var q1:SYSTEM.uint64;
begin
{q1:=GetTickCount;
nano_pow('fdd79b6607f83a44c499ee5c173dd90ba757ae910deb687bf3844e93780ccfa1');
ShowMessage(IntToStr((GetTickCount-q1) div 1000));   }
  LabelEditApplyStyleLookup(HistoryTransactionValue);
  LabelEditApplyStyleLookup(HistoryTransactionDate);
  LabelEditApplyStyleLookup(historyTransactionConfirmation);
  NoPrintScreenImage.Visible := true;
  Application.ProcessMessages;
  AccountRelated.afterInitialize;
  NoPrintScreenImage.Visible := false;

end;

procedure TfrmHome.FormVirtualKeyboardHidden(Sender: TObject;
KeyboardVisible: Boolean; const Bounds: TRect);
var
  FService: IFMXVirtualKeyboardService;
  X: Integer;
begin
  if PageControl.ActiveTab = EQRView then
    exit;
{$IFDEF ANDROID}
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
{$ENDIF}
end;

procedure TfrmHome.FormVirtualKeyboardShown(Sender: TObject;
KeyboardVisible: Boolean; const Bounds: TRect);
var
  FService: IFMXVirtualKeyboardService;
  FToolbarService: IFMXVirtualKeyBoardToolbarService;
  X, Y: Integer;
  sameY: Integer;
begin
  if PageControl.ActiveTab = EQRView then
    exit;

{$IFDEF ANDROID}
  Y := 0;
  if focused is TEdit then
  begin
    if (TEdit(focused).name = 'wvAddress') or
      (TEdit(focused).name = 'receiveAddress') then
    begin

      exit;
    end;
    if (PageControl.ActiveTab = walletView) and (TEdit(focused).ReadOnly = false)
    then
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
      Application.ProcessMessages;
      if sameY = round(ScrollBox.ViewportPosition.Y) then
        break;

    until abs(Y - round(ScrollBox.ViewportPosition.Y)) < 15;
  end;
{$ENDIF}
end;

procedure TfrmHome.FoundTokenOKButtonClick(Sender: TObject);
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
  if PageControl.ActiveTab = walletDatCreation then
  begin
    GenerateSeedProgressBar.Value := trngBufferCounter div 2;
    if trngBufferCounter mod 20 = 0 then
    begin
      trngBuffer := GetSTrHashSHA256(trngBuffer);
      labelForGenerating.Text := trngBuffer;
    end;
    if trngBufferCounter mod 200 = 0 then
    begin
      // 10sec of gathering random data should be enough to get unique seed
      trngBuffer := GetSTrHashSHA256(trngBuffer + IntToStr(random($FFFFFFFF)) +
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

procedure TfrmHome.ImportPrivateKeyInPrivButtonClick(Sender: TObject);
begin
  WalletViewRelated.ImportPrivateKeyInPrivButtonClick(Sender);
end;

procedure TfrmHome.LinkLayoutClick(Sender: TObject);
var
  wd: TwalletInfo;
  tt: Token;
  myURI: AnsiString;
  URL: WideString;
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

{$ELSE}
  URL := myURI;
  ShellExecute(0, 'OPEN', PWideChar(URL), '', '', { SW_SHOWNORMAL } 1);
{$ENDIF}
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

procedure TfrmHome.SymbolFieldKeyUp(Sender: TObject; var Key: Word;
var KeyChar: Char; Shift: TShiftState);
begin // DecimalsField
  if Key = vkReturn then
  begin
    DecimalsField.SetFocus;
  end;
end;

procedure TfrmHome.syncTimerTimer(Sender: TObject);
begin
  try
    btnSync.onclick(self);
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

procedure TfrmHome.receiveAddressOldChange(Sender: TObject);
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

procedure TfrmHome.SaPBackButtonClick(Sender: TObject);
begin
  switchTab(PageControl, Settings);
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

procedure TfrmHome.SendDecryptedSeedButtonClick(Sender: TObject);
begin

  btnDecryptSeed.onclick := SendDecryptedSeed;

  decryptSeedBackTabItem := PageControl.ActiveTab;
  PageControl.ActiveTab := descryptSeed;
  btnDSBack.onclick := backBtnDecryptSeed;
end;

procedure TfrmHome.SendAllFundsOnSwitch(Sender: TObject);
begin
  WalletViewRelated.sendallfunds;
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
    popupWindow.Create(dictionary('FailedToDecrypt'));
    passwordForDecrypt.Text := '';
    exit;
  end;
  startFullfillingKeypool(MasterSeed);
  // tempMasterSeed
  img := StrToQRBitmap(MasterSeed);
  ImgPath := System.IOUtils.TPath.Combine
    (IncludeTrailingPathDelimiter(SysUtils.GetEnvironmentVariable('APPDATA')),
    'QRDecryptedSeed.png');
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
  passwordForDecrypt.Text := '';
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
  { if not isEQRGenerated then
    begin

    btnDecryptSeed.OnClick := SendEncryptedSeed;
    decryptSeedBackTabItem := PageControl.ActiveTab;
    PageControl.ActiveTab := descryptSeed;
    btnDSBack.OnClick := backBtnDecryptSeed;
    end
    else
    begin }
  // if EQRPreview.MultiResBitmap[0]=nil then EQRPreview.MultiResBitmap[0].CreateBitmap()

  {
    BackupRelated.SendEQR;
    pngname:=System.IOUtils.TPath.Combine(HOME_PATH,
    currentAccount.name + '_EQR_SMALL' + '.png');
    EQRPreview.Visible:=True;
    PageControl.ActiveTab := EQRView;
    EQRPreview.Bitmap.LoadFromFile(pngname);
    EQRPreview.Repaint;
    EQRPreview.Align:=TAlignLayout.Center;
    EQRPreview.Height:=294;
    EQRPreview.Width:=294; }
  // end;

end;

procedure TfrmHome.SendErrorMsgSwitchClick(Sender: TObject);
begin
  SendErrorMsgSwitchSwitch(Sender);
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
  BackupRelated.SendHSB;
end;

procedure TfrmHome.SendWalletFileButtonClick(Sender: TObject);
begin
  btnDecryptSeed.onclick := SendWalletFile;
  decryptSeedBackTabItem := PageControl.ActiveTab;
  PageControl.ActiveTab := descryptSeed;
  btnDSBack.onclick := backBtnDecryptSeed;
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
  SanitizePool;
end;

procedure TfrmHome.SearchInDashBrdButtonClick(Sender: TObject);
begin
  TLabel(frmHome.FindComponent('HeaderLabel')).Visible := false;
  SearchEdit.Visible := true;
  SetFocused(SearchEdit);
end;

procedure TfrmHome.SearchTokenButtonClick(Sender: TObject);
var
  found: Integer;
begin

  WalletViewRelated.SearchTokenButtonClick(Sender);
end;

procedure TfrmHome.SeedMnemonicBackupButtonClick(Sender: TObject);
begin
  btnDecryptSeed.onclick := decryptSeedForSeedRestore;
  decryptSeedBackTabItem := PageControl.ActiveTab;
  PageControl.ActiveTab := descryptSeed;
  btnDSBack.onclick := backBtnDecryptSeed;
end;

procedure TfrmHome.SwitchSavedSeedSwitch(Sender: TObject);
begin
  btnSkip.Enabled := frmHome.SwitchSavedSeed.IsChecked;
end;

// must be in the end        caused ide error
procedure TfrmHome.AddWalletButtonClick(Sender: TObject);
begin

  WalletViewRelated.AddWalletButtonClick(Sender);

end;


procedure tfrmhome.AddTokenFromWalletList(Sender : TObject );
begin

  walletviewRelated.AddTokenFromWalletList(Sender);

end;

procedure tfrmhome.AddNewTokenETHPanelClick(sender : Tobject );
var
  T : Token;
  holder: TfmxObject;
  found : integer;
begin

  walletViewRelated.AddNewTokenETHPanelClick(sender);

end;

procedure TfrmHome.APICheckCompressed(Sender: TObject);
begin
  WalletViewRelated.importCheck;
end;

end.
