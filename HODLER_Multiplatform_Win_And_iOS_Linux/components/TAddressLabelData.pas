unit TAddressLabelData;

interface

uses
  System.SysUtils, System.UITypes, System.Classes, FMX.Types, FMX.Controls,
  FMX.Layouts,
  FMX.Edit, FMX.StdCtrls, FMX.Clipboard, FMX.Platform, FMX.Objects,
  FMX.Graphics,
  System.Types, StrUtils, FMX.Dialogs, CrossPlatformHeaders;

type
  TAddressLabel = class(TLayout)

  private

    prefix, AddrPrefix, address, AddrSuffix: Tlabel;
    ftext: AnsiString;

    lastPrefixLength: Integer;
    FLastWidth: Single;

    function getText(): AnsiString;
  protected
    procedure DoRealign; override;
    procedure Resize; override;

  public

    TextSettings: TTextSettings;

    procedure SetText(const Value: AnsiString; prefixLength: Integer); overload;
    procedure SetText(const Value: AnsiString); overload;

    property Text: AnsiString read getText write SetText;

    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;

  end;

procedure cutAndDecorateLabel(lbl: Tlabel);

procedure Register;

implementation

uses uhome;

procedure Register;
begin
  RegisterComponents('Samples', [TAddressLabel]);
end;

procedure TAddressLabel.Resize;
var
  strLength: Integer;
  outText: AnsiString;
  prefSufLength: Integer;
  source: AnsiString;
  startPosition: Single;
  normalCanvas, BoltCanvas: TBitmap;
  DEBUGSTR: AnsiString;

  prefW, addrPrefW, AddrSufW: Single;
  avr: Single;
  propLen: Integer;

begin

  inherited Resize;
  if Self.Width = FLastWidth then
    Exit;
  FLastWidth := Self.Width;

  try
    // Realign;
    // RecalcSize;
    prefix.Width := 0;
    AddrPrefix.Width := 0;
    address.Width := 0;
    AddrSuffix.Width := 0;

    normalCanvas := TBitmap.Create(10, 10);
    BoltCanvas := TBitmap.Create(10, 10);

    normalCanvas.Canvas.Font.Assign(prefix.Font);
    BoltCanvas.Canvas.Font.Assign(AddrPrefix.Font);

    source := LeftStr(ftext, length(ftext) - 4);
    source := RightStr(source, length(source) - (4 + length(prefix.Text)));

    prefW := normalCanvas.Canvas.TextWidth(prefix.Text);
    addrPrefW := BoltCanvas.Canvas.TextWidth(AddrPrefix.Text);
    AddrSufW := BoltCanvas.Canvas.TextWidth(AddrSuffix.Text);

    avr := (prefW + addrPrefW + AddrSufW) / (8 + length(prefix.Text));
    if avr = 0 then
    begin

      normalCanvas.Free;
      BoltCanvas.Free;

      Exit;
    end;

    propLen := round((Width * 0.4) / avr) - (8 + length(prefix.Text));

    outText := LeftStr(source, propLen) + '...' + RightStr(source, propLen);
    prefSufLength := propLen + 1;
    if length(source) <= prefSufLength * 2 then
    begin
      outText := source;
    end else

      while (normalCanvas.Canvas.TextWidth(outText) + prefW + addrPrefW +
        AddrSufW) < Width * 0.85 do
      begin

        if length(source) <= prefSufLength * 2 then
        begin
          outText := source;
          break;
        end
        else
          outText := LeftStr(source, prefSufLength) + '...' +
            RightStr(source, prefSufLength);
        prefSufLength := prefSufLength + 1;

      end;

    address.Text := outText;

    if TextSettings.horzAlign = TTextAlign.Center then
      startPosition := (Width - (prefix.Width + AddrPrefix.Width + address.Width
        + AddrSuffix.Width)) / 2
    else if TextSettings.horzAlign = TTextAlign.Trailing then
      startPosition := (Width - (prefix.Width + AddrPrefix.Width + address.Width
        + AddrSuffix.Width))
    else
      startPosition := 0;

    prefix.RecalcSize;
    AddrPrefix.RecalcSize;
    address.RecalcSize;
    AddrSuffix.RecalcSize;
    prefix.Position.X := startPosition;
    AddrPrefix.Position.X := prefix.Position.X + prefix.Width;
    address.Position.X := startPosition + prefix.Width + AddrPrefix.Width;
    AddrSuffix.Position.X := startPosition + prefix.Width + AddrPrefix.Width +
      address.Width;

    // Repaint;

    normalCanvas.Free;
    BoltCanvas.Free;
  except
    on e: Exception do
    begin
      // showmessage(e.Message);
    end;

  end;
end;

procedure TAddressLabel.DoRealign;
var
  startPosition: Single;
begin

  inherited;

  { if TextSettings.horzAlign = TTextAlign.Center then
    startPosition := (width - (prefix.width + AddrPrefix.width + address.width +
    AddrSuffix.width)) / 2
    else if TextSettings.horzAlign = TTextAlign.Trailing then
    startPosition := (width - (prefix.width + AddrPrefix.width + address.width +
    AddrSuffix.width))
    else
    startPosition := 0;

    prefix.Position.X := startPosition;
    AddrPrefix.Position.X := prefix.Position.X + prefix.width;
    address.Position.X := startPosition + prefix.width + AddrPrefix.width;
    AddrSuffix.Position.X := startPosition + prefix.width + AddrPrefix.width +
    address.width;

    Repaint; }

end;

destructor TAddressLabel.Destroy;
begin
  inherited;
  TextSettings.Free;
end;

function TAddressLabel.getText(): AnsiString;
begin

  result := ftext;

end;

constructor TAddressLabel.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  FLastWidth := Self.Width;
  TextSettings := TTextSettings.Create(Self);
  lastPrefixLength := 0;
  // width := Tcontrol(AOwner).width;

  prefix := Tlabel.Create(Self);
  prefix.Parent := Self;
  prefix.Align := TAlignLayout.Vertical;
  prefix.TextAlign := TTextAlign.Center;
  prefix.Visible := true;
  prefix.AutoSize := true;
  prefix.WordWrap := false;

  AddrPrefix := Tlabel.Create(Self);
  AddrPrefix.Parent := Self;
  AddrPrefix.Align := TAlignLayout.Vertical;
  AddrPrefix.TextAlign := TTextAlign.Center;
  AddrPrefix.Visible := true;
  AddrPrefix.AutoSize := true;
  AddrPrefix.WordWrap := false;

  address := Tlabel.Create(Self);
  address.Parent := Self;
  address.Align := TAlignLayout.Vertical;
  address.TextAlign := TTextAlign.Center;
  address.Visible := true;
  address.AutoSize := true;
  address.WordWrap := false;

  AddrSuffix := Tlabel.Create(Self);
  AddrSuffix.Parent := Self;
  AddrSuffix.Align := TAlignLayout.Vertical;
  AddrSuffix.TextAlign := TTextAlign.Center;
  AddrSuffix.Visible := true;
  AddrSuffix.AutoSize := true;
  AddrSuffix.WordWrap := false;

  AddrPrefix.TextSettings.Font.style := AddrPrefix.TextSettings.Font.style +
    [TFontStyle.fsBold];
  AddrPrefix.StyledSettings := AddrPrefix.StyledSettings -
    [TStyledSetting.style] - [TStyledSetting.FontColor];
  AddrPrefix.FontColor := TAlphaColorRec.Orangered;

  AddrSuffix.TextSettings.Font.style := AddrSuffix.TextSettings.Font.style +
    [TFontStyle.fsBold];
  AddrSuffix.StyledSettings := AddrSuffix.StyledSettings -
    [TStyledSetting.style] - [TStyledSetting.FontColor];
  AddrSuffix.FontColor := TAlphaColorRec.Orangered;

end;

procedure TAddressLabel.SetText(const Value: AnsiString);
begin
  SetText(Value, 0);
end;

procedure TAddressLabel.SetText(const Value: AnsiString; prefixLength: Integer);
var
  strLength: Integer;
  outText: AnsiString;
  prefSufLength: Integer;
  source: AnsiString;
  startPosition: Single;
  normalCanvas, BoltCanvas: TBitmap;
  DEBUGSTR: AnsiString;

  prefW, addrPrefW, AddrSufW: Single;
  avr: Single;
  propLen: Integer;
begin
  // Realign;
  // RecalcSize;

  ftext := Value;
  {TThread.CreateAnonymousThread(
    procedure
    begin
      TThread.Synchronize(nil,
        procedure
        begin }

          lastPrefixLength := prefixLength;
          prefix.Width := 0;
          AddrPrefix.Width := 0;
          address.Width := 0;
          AddrSuffix.Width := 0;
          normalCanvas := TBitmap.Create(10, 10);
          BoltCanvas := TBitmap.Create(10, 10);

          normalCanvas.Canvas.Font.Assign(prefix.Font);
          BoltCanvas.Canvas.Font.Assign(AddrPrefix.Font);

          source := LeftStr(Value, length(Value) - 4);
          source := RightStr(source, length(source) - (4 + prefixLength));

          prefix.Text := LeftStr(Value, prefixLength);
          AddrPrefix.Text := RightStr(LeftStr(Value, 4 + prefixLength), 4);
          AddrSuffix.Text := RightStr(Value, 4);

          prefW := normalCanvas.Canvas.TextWidth(prefix.Text);
          addrPrefW := BoltCanvas.Canvas.TextWidth(AddrPrefix.Text);
          AddrSufW := BoltCanvas.Canvas.TextWidth(AddrSuffix.Text);

          avr := (prefW + addrPrefW + AddrSufW) / (8 + prefixLength);
          if avr = 0 then
          begin

            normalCanvas.Free;
            BoltCanvas.Free;
            Exit;
          end;

          propLen := round((Width * 0.4) / avr) - (8 + prefixLength);

          outText := LeftStr(source, propLen) + '...' +
            RightStr(source, propLen);
          prefSufLength := propLen + 1;
          if length(source) <= prefSufLength * 2 then
          begin
            outText := source;
          end
          else
            while (normalCanvas.Canvas.TextWidth(outText) + prefW + addrPrefW +
              AddrSufW) < Width * 0.85 do
            begin

              if length(source) <= prefSufLength * 2 then
              begin
                outText := source;
                break;
              end
              else
                outText := LeftStr(source, prefSufLength) + '...' +
                  RightStr(source, prefSufLength);
              prefSufLength := prefSufLength + 1;

            end;

          address.Text := outText;

          // prefix.width := normalCanvas.Canvas.TextWidth(prefix.Text);
          // AddrPrefix.width := BoltCanvas.Canvas.TextWidth(AddrPrefix.Text);
          // address.width := normalCanvas.Canvas.TextWidth(address.Text);
          // AddrSuffix.width := BoltCanvas.Canvas.TextWidth(AddrSuffix.Text);

          // startPosition := ( Width - ( prefix.Width + AddrPrefix.Width + address.Width + addrsuffix.Width ) ) /2;
          if TextSettings.horzAlign = TTextAlign.Center then
            startPosition := (Width - (prefix.Width + AddrPrefix.Width +
              address.Width + AddrSuffix.Width)) / 2
          else if TextSettings.horzAlign = TTextAlign.Trailing then
            startPosition := (Width - (prefix.Width + AddrPrefix.Width +
              address.Width + AddrSuffix.Width))
          else
            startPosition := 0;
          prefix.RecalcSize;
          AddrPrefix.RecalcSize;
          address.RecalcSize;
          AddrSuffix.RecalcSize;
          prefix.Position.X := startPosition;
          AddrPrefix.Position.X := prefix.Position.X + prefix.Width;
          address.Position.X := startPosition + prefix.Width + AddrPrefix.Width;
          AddrSuffix.Position.X := startPosition + prefix.Width +
            AddrPrefix.Width + address.Width;

          // Repaint;

          normalCanvas.Free;
          BoltCanvas.Free;
   //     end)
   // end).Start;
end;

procedure cutAndDecorateLabel(lbl: Tlabel);
var
  strLength: Integer;
  outText: AnsiString;
  prefSufLength: Integer;
begin
  strLength := length(lbl.Text);

  outText := LeftStr(lbl.Text, 4) + '...' + RightStr(lbl.Text, 4);

  prefSufLength := 5;

  lbl.Canvas.Font.Assign(lbl.Font);

  while lbl.Canvas.TextWidth(outText) < lbl.Width * 0.9 do
  begin

    outText := LeftStr(lbl.Text, prefSufLength) + '...' +
      RightStr(lbl.Text, prefSufLength);
    prefSufLength := prefSufLength + 1;

  end;

  lbl.Text := outText;

end;

end.
