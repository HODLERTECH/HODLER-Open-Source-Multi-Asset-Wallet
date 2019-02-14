unit TAddressLabelData;

interface

uses
  System.SysUtils, System.UITypes , System.Classes, FMX.Types, FMX.Controls, FMX.Layouts,
  FMX.Edit, FMX.StdCtrls, FMX.Clipboard, FMX.Platform, FMX.Objects, FMX.Graphics ,
  System.Types, StrUtils, FMX.Dialogs , CrossPlatformHeaders;

type
  TAddressLabel = class(TLayout)

  private

  prefix , AddrPrefix ,address , AddrSuffix : Tlabel;
  ftext : AnsiString;

  function getText() : AnsiString;


  public

  TextSettings : TTextSettings;

  procedure SetText(const Value: Ansistring ; prefixLength : Integer ); overload;
  procedure setText( const Value: Ansistring ); overload;

  property Text: AnsiString read getText write SetText;

  constructor Create(AOwner: TComponent); override;
  destructor Destroy; override;


  end;

  procedure cutAndDecorateLabel( lbl : Tlabel );

procedure Register;

implementation

uses uhome;

procedure Register;
begin
  RegisterComponents('Samples', [TAddressLabel]);
end;

destructor TAddressLabel.Destroy;
begin
  inherited;
  TextSettings.Free;
end;

function TAddressLabel.getText() : AnsiString;
begin

  result := ftext;

end;

constructor TAddressLabel.Create(AOwner: TComponent);
begin

  textSettings := TTextSettings.Create( self );

  width := Tcontrol( AOwner ).Width;

  prefix := Tlabel.create( self );
  prefix.Parent := self;
  prefix.Align := TAlignLayout.Vertical;
  prefix.TextAlign := TTextAlign.Center;
  prefix.Visible := true;

  Addrprefix := Tlabel.create( self );
  Addrprefix.Parent := self;
  Addrprefix.Align := TAlignLayout.Vertical;
  Addrprefix.TextAlign := TTextAlign.Center;
  Addrprefix.Visible := true;

  Address := Tlabel.create( self );
  Address.Parent := self;
  Address.Align := TAlignLayout.Vertical;
  Address.TextAlign := TTextAlign.Center;
  Address.Visible := true;

  AddrSuffix := Tlabel.create( self );
  AddrSuffix.Parent := self;
  AddrSuffix.Align := TAlignLayout.Vertical;
  AddrSuffix.TextAlign := TTextAlign.Center;
  AddrSuffix.Visible := true;


  Addrprefix.TextSettings.Font.style := Addrprefix.TextSettings.Font.style + [TFontStyle.fsBold];
  Addrprefix.StyledSettings := Addrprefix.StyledSettings - [TStyledSetting.style] - [TStyledSetting.FontColor];
  Addrprefix.FontColor := TAlphaColorRec.Orangered;

  Addrsuffix.TextSettings.Font.style := Addrsuffix.TextSettings.Font.style  + [TFontStyle.fsBold];
  Addrsuffix.StyledSettings := Addrsuffix.StyledSettings - [TStyledSetting.style] - [TStyledSetting.FontColor];
  Addrsuffix.FontColor := TAlphaColorRec.Orangered;


end;
procedure TAddressLabel.setText( const Value: Ansistring );
begin
  setText( Value , 0 );
end;

procedure TAddressLabel.setText( const Value: Ansistring ; prefixLength : Integer ) ;
var
  strLength : Integer;
  outText : AnsiString;
  prefSufLength : Integer;
  source : AnsiString;
  startPosition : single;
  normalCanvas , BoltCanvas : TBitmap;
begin

  ftext := Value;


  normalCanvas := TBitmap.Create();
  BoltCanvas := Tbitmap.Create();


  normalCanvas.Canvas.Font.Assign( prefix.Font );

  BoltCanvas.Canvas.Font.Assign( AddrPrefix.Font );

  source := LeftStr( Value , length(Value) - 4 );
  source := RightStr( source , length(source) - ( 4 + prefixLength) );

  prefix.Text := leftstr( Value, prefixLength );
  AddrPrefix.Text := rightStr( leftstr( value , 4 + prefixLength ) , 4 );
  Addrsuffix.Text := RightStr(Value , 4);

  outText := leftStr( source , 4 ) + '...' + rightStr( source , 4 );

  prefSufLength := 5;

  while ( normalCanvas.Canvas.TextWidth(outtext) + normalCanvas.Canvas.TextWidth(prefix.Text)
    + BoltCanvas.Canvas.TextWidth(Addrprefix.Text) + BoltCanvas.Canvas.TextWidth(AddrSuffix.Text) )
     < Width * 0.9  do
  begin

    if length(source) <= prefSufLength *2  then
    begin
      outText := source;
      break;
    end
    else
      outText := leftStr( source , prefSufLength ) + '...' + rightStr( source , prefSufLength );
    prefSufLength := prefSufLength + 1;

  end;

  address.Text := outText;

  prefix.Width := normalCanvas.Canvas.TextWidth(prefix.Text)  ;
  AddrPrefix.Width := BoltCanvas.Canvas.TextWidth(Addrprefix.Text);
  address.Width := normalCanvas.Canvas.TextWidth(address.Text);
  addrsuffix.Width := BoltCanvas.Canvas.TextWidth(AddrSuffix.Text) ;

  //startPosition := ( Width - ( prefix.Width + AddrPrefix.Width + address.Width + addrsuffix.Width ) ) /2;
  if TextSettings.horzAlign = TtextAlign.center then
    startPosition := ( Width - ( prefix.Width + AddrPrefix.Width + address.Width + addrsuffix.Width ) ) /2
  else if TextSettings.horzAlign = TtextAlign.Trailing then
    startposition := ( Width - ( prefix.Width + AddrPrefix.Width + address.Width + addrsuffix.Width ) )
  else
    startposition := 0;


  prefix.Position.X := startPosition;
  AddrPrefix.position.X := prefix.Position.X + prefix.Width;
  address.position.X := startPosition + prefix.Width + AddrPrefix.Width;
  addrsuffix.position.X := startPosition + prefix.Width + AddrPrefix.Width + address.Width;

  Repaint;

  normalCanvas.Free;
  BoltCanvas.Free;

end;

procedure cutAndDecorateLabel( lbl : TLabel );
var
  strLength : Integer;
  outText : AnsiString;
  prefSufLength : Integer;
begin
  strLength := length(lbl.Text);

  outText := leftStr( lbl.Text , 4 ) + '...' + rightStr( lbl.Text , 4 );

  prefSufLength := 5;

  lbl.Canvas.Font.Assign(lbl.Font);

  while lbl.Canvas.TextWidth( outtext ) < lbl.Width * 0.9  do
  begin

    outText := leftStr( lbl.Text , prefSufLength ) + '...' + rightStr( lbl.Text , prefSufLength );
    prefSufLength := prefSufLength + 1;

  end;

  lbl.Text := outText ;

end;




end.
