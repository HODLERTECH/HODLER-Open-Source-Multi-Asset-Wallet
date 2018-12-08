unit FileManagerRelated;

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

procedure DrawFM(InputPath: AnsiString);

implementation

uses uHome, misc, AccountData, base58, bech32, CurrencyConverter, SyncThr, WIF,
  Bitcoin, coinData, cryptoCurrencyData, Ethereum, secp256k1, tokenData,
  transactions, WalletStructureData, AccountRelated;

procedure DrawFM(InputPath: AnsiString);
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

  frmHome.FileManagerPathLabel.Text := InputPath;

  if InputPath <> '' then
  begin
    Dir := TDirectory.GetDirectories(InputPath);
    Files := TDirectory.GetFiles(InputPath);
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

{$IF DEFINED(ANDROID) OR DEFINED(IOS)}
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

{$IF DEFINED(ANDROID) OR DEFINED(IOS)}
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

end.
