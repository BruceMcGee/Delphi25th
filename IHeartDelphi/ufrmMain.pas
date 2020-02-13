unit ufrmMain;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs,
  System.Math.Vectors, FMX.Objects3D, FMX.Controls3D, FMX.Viewport3D,
  FMX.Types3D, FMX.Controls.Presentation, FMX.StdCtrls,
  System.Math, FMX.Objects, FMX.Utils, FMX.Ani, FMX.MaterialSources;

type
  TfrmMain = class(TForm)
    Viewport3D1: TViewport3D;
    Dummy1: TDummy;
    Text3D1: TText3D;
    Grid3D1: TGrid3D;
    Camera1: TCamera;
    Rectangle3D1: TRectangle3D;
    LightMaterialSource1: TLightMaterialSource;
    LightMaterialSource2: TLightMaterialSource;
    Light1: TLight;
    Image1: TImage;
    btnCardioid: TButton;
    btnGraph: TButton;
    btnMandelbrot: TButton;
    btnPixelated: TButton;
    btnAll: TButton;
    btn3DScene: TButton;
    btnSineWave: TButton;
    btnDelphiHeart: TButton;
    btnMapleLeaf: TButton;
    btnStringArtCardoid: TButton;
    btnStringArtHeart: TButton;
    btnHeartCurve4: TButton;
    btnHeartCurve5: TButton;
    btnHeartCurveSpiral: TButton;
    lblBrand: TLabel;
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure btnCardioidClick(Sender: TObject);
    procedure btnPixelatedClick(Sender: TObject);
    procedure btnGraphClick(Sender: TObject);
    procedure btnMandelbrotClick(Sender: TObject);
    procedure btnAllClick(Sender: TObject);
    procedure btn3DSceneClick(Sender: TObject);
    procedure btnSineWaveClick(Sender: TObject);
    procedure btnDelphiHeartClick(Sender: TObject);
    procedure btnMapleLeafClick(Sender: TObject);
    procedure btnStringArtCardoidClick(Sender: TObject);
    procedure btnStringArtHeartClick(Sender: TObject);
    procedure btnHeartCurve4Click(Sender: TObject);
    procedure btnHeartCurve5Click(Sender: TObject);
    procedure btnHeartCurveSpiralClick(Sender: TObject);
  private
    FbmpDelphiHeart: TBitmap;
    FbmpMapleLeaf: TBitmap;
    F3DHeartPixels: TArray<TArray<TRoundCube>>;
    procedure DrawPixelatedHeart3D;
    procedure Animate3DScene;
    procedure Reset3DScene;
    procedure Setup3DScene;
  public
  end;

var
  frmMain: TfrmMain;

implementation

uses
  uHeartUtils;

{$R *.fmx}


// ============================================================================
procedure TfrmMain.FormCreate(Sender: TObject);
begin
  FbmpDelphiHeart := TBitmap.Create;
  FbmpDelphiHeart.LoadFromFile('DelphiHeart.png');
  FbmpMapleLeaf := TBitmap.Create;
  FbmpMapleLeaf.LoadFromFile('MapleLeaf.png');

  Image1.Bitmap := TBitmap.Create(Trunc(Image1.Width), Trunc(Image1.Height));
  Image1.Bitmap.Canvas.Stroke.Kind := TBrushKind.Solid;
  Image1.Bitmap.Canvas.Stroke.Color := TAlphaColorRec.Red;
  Image1.Bitmap.Canvas.Fill.Color := TAlphaColorRec.Red;

  Setup3DScene;
  Reset3DScene;
end;

// ----------------------------------------------------------------------------
procedure TfrmMain.FormDestroy(Sender: TObject);
begin
  FbmpDelphiHeart.Free;
  FbmpMapleLeaf.Free;
end;

// ----------------------------------------------------------------------------
procedure TfrmMain.btnAllClick(Sender: TObject);
var
  i: Integer;
begin
  Reset3DScene;

  DrawPixelatedHeart(Image1.Bitmap);
  Sleep(500);

  DrawGraphHeart(Image1.Bitmap);
  Sleep(500);

  DrawCardioid(Image1.Bitmap);
  Sleep(500);

  DrawHeartCurve_4(Image1.Bitmap);
  Sleep(500);
  DrawHeartCurve_Spiral(Image1.Bitmap);
  Sleep(500);
  DrawHeartCurve_5(Image1.Bitmap);
  Sleep(500);

  DrawSineWaveHeart(Image1.Bitmap, 0, 50);
  Sleep(750);

  DrawStringArtCardioid(Image1.Bitmap);
  Sleep(750);

  DrawStringArtHeart(Image1.Bitmap);
  Sleep(750);

  for i := 2 to 100 do
  begin
    DrawMandelbrotHeart(Image1.Bitmap, i);
    Application.ProcessMessages;
  end;
  Sleep(500);

  DrawBitmap(FbmpDelphiHeart, Image1.Bitmap);
  Sleep(1500);

  DrawBitmap(FbmpMapleLeaf, Image1.Bitmap);
  Sleep(1500);

  Viewport3D1.Visible := True;
  DrawPixelatedHeart3D;

  Animate3DScene;
end;

// ----------------------------------------------------------------------------
procedure TfrmMain.btnCardioidClick(Sender: TObject);
begin
  Reset3DScene;
  DrawCardioid(Image1.Bitmap);
end;

// ----------------------------------------------------------------------------
procedure TfrmMain.btnDelphiHeartClick(Sender: TObject);
begin
  Reset3DScene;
  DrawBitmap(FbmpDelphiHeart, Image1.Bitmap);
end;

// ----------------------------------------------------------------------------
procedure TfrmMain.btnGraphClick(Sender: TObject);
begin
  Reset3DScene;
  DrawGraphHeart(Image1.Bitmap);
end;

// ----------------------------------------------------------------------------
procedure TfrmMain.btnHeartCurve4Click(Sender: TObject);
begin
  Reset3DScene;
  DrawHeartCurve_4(Image1.Bitmap);
end;

// ----------------------------------------------------------------------------
procedure TfrmMain.btnHeartCurve5Click(Sender: TObject);
begin
  Reset3DScene;
  DrawHeartCurve_5(Image1.Bitmap);
end;

// ----------------------------------------------------------------------------
procedure TfrmMain.btnHeartCurveSpiralClick(Sender: TObject);
begin
  Reset3DScene;
  DrawHeartCurve_Spiral(Image1.Bitmap);
end;

// ----------------------------------------------------------------------------
procedure TfrmMain.btnMandelbrotClick(Sender: TObject);
var
  i: Integer;
begin
  for i := 2 to 100 do
  begin
    DrawMandelbrotHeart(Image1.Bitmap, i);
    Application.ProcessMessages;
  end;
end;

// ----------------------------------------------------------------------------
procedure TfrmMain.btnMapleLeafClick(Sender: TObject);
begin
  Reset3DScene;
  DrawBitmap(FbmpMapleLeaf, Image1.Bitmap);
end;

// ----------------------------------------------------------------------------
procedure TfrmMain.btnPixelatedClick(Sender: TObject);
begin
  Reset3DScene;
  DrawPixelatedHeart(Image1.Bitmap);
end;

// ----------------------------------------------------------------------------
procedure TfrmMain.btn3DSceneClick(Sender: TObject);
begin
  Reset3DScene;
  DrawPixelatedHeart3D;
  Animate3DScene;
end;

// ----------------------------------------------------------------------------
procedure TfrmMain.btnSineWaveClick(Sender: TObject);
begin
  Reset3DScene;
  DrawSineWaveHeart(Image1.Bitmap, 0, 50);
end;

// ----------------------------------------------------------------------------
procedure TfrmMain.btnStringArtHeartClick(Sender: TObject);
begin
  Reset3DScene;
  DrawStringArtHeart(Image1.Bitmap);
end;

// ----------------------------------------------------------------------------
procedure TfrmMain.btnStringArtCardoidClick(Sender: TObject);
begin
  Reset3DScene;
  DrawStringArtCardioid(Image1.Bitmap);
end;

// ----------------------------------------------------------------------------
procedure TfrmMain.DrawPixelatedHeart3D;
var
  i, j: Integer;
begin
  for i := 0 to Length(HEART_PIXELS) - 1 do
  begin
    for j := 0 to Length(HEART_PIXELS[0]) - 1 do
    begin
      if HEART_PIXELS[i, j] > 0 then
        TAnimator.AnimateFloat(F3DHeartPixels[i, j], 'Opacity', 0.8, 3, TAnimationType.Out, TInterpolationType.Sinusoidal);
    end;
  end;
end;

// ----------------------------------------------------------------------------
procedure TfrmMain.Animate3DScene;
begin
  Image1.Visible := False;
  Text3D1.Opacity := 0;
  Grid3D1.Opacity := 0;
  Viewport3D1.Visible := True;

  TAnimator.AnimateFloat(Text3D1, 'Opacity', 1, 2, TAnimationType.InOut, TInterpolationType.Quadratic);
  TAnimator.AnimateFloat(Grid3D1, 'Opacity', 1, 2, TAnimationType.InOut, TInterpolationType.Quadratic);

  TAnimator.AnimateFloat(Camera1, 'Position.X', 0, 2, TAnimationType.InOut, TInterpolationType.Quadratic);
  TAnimator.AnimateFloat(Camera1, 'Position.Y', -5, 2, TAnimationType.InOut, TInterpolationType.Quadratic);
  TAnimator.AnimateFloat(Camera1, 'Position.Z', -13.5, 2, TAnimationType.InOut, TInterpolationType.Quadratic);
  TAnimator.AnimateFloat(Camera1, 'RotationAngle.X', -20, 2, TAnimationType.InOut, TInterpolationType.Quadratic);
end;

// ----------------------------------------------------------------------------
procedure TfrmMain.Reset3DScene;
var
  i, j: Integer;
begin
  Camera1.RotationAngle.X := 0;
  Camera1.Position.X := -6.5;
  Camera1.Position.Y := 0;
  Camera1.Position.Z := -4.5;

  for i := 0 to Length(HEART_PIXELS) - 1 do
  begin
    for j := 0 to Length(HEART_PIXELS[0]) - 1 do
    begin
      if HEART_PIXELS[i, j] > 0 then
        F3DHeartPixels[i, j].Opacity := 0;
    end;
  end;

  Text3D1.Opacity := 0;
  Grid3D1.Opacity := 0;
  Viewport3D1.Visible := False;
  Image1.Bitmap.Clear(TAlphaColorRec.Black);
  Image1.Visible := True;
end;

// ----------------------------------------------------------------------------
procedure TfrmMain.Setup3DScene;
var
  i, j: Integer;
  LRoundCube: TRoundCube;
  LTop, LLeft, LWidth, LHeight: Double;
  LCubeOffset: Double;
  LCubeSize: Double;
begin
  SetLength(F3DHeartPixels, Length(HEART_PIXELS), Length(HEART_PIXELS[0]));

  LWidth := Rectangle3D1.Width * Rectangle3D1.Scale.X;
  LHeight := Rectangle3D1.Height * Rectangle3D1.Scale.Y;
  LTop := Rectangle3D1.Position.Y - LHeight / 2;
  LLeft := Rectangle3D1.Position.X - LWidth / 2;

  LCubeOffset := LWidth / Length(HEART_PIXELS[0]);
  LCubeSize := LCubeOffset * 0.75;
  LTop := LTop + LCubeSize;
  LLeft := LLeft + LCubeSize / 2;

  for i := 0 to Length(HEART_PIXELS) - 1 do
  begin
    for j := 0 to Length(HEART_PIXELS[0]) - 1 do
    begin
      if HEART_PIXELS[i, j] > 0 then
      begin
        LRoundCube := TRoundCube.Create(Self);
        LRoundCube.Parent := Dummy1;
        LRoundCube.Position.X := LLeft + j * LCubeOffset;
        LRoundCube.Position.Y := LTop + i * LCubeOffset;
        LRoundCube.Width := LCubeSize;
        LRoundCube.Height := LCubeSize;
        LRoundCube.Depth := 0.1 + (HEART_PIXELS[i, j] - 1) / 3;

        LRoundCube.MaterialSource := LightMaterialSource1;
        LRoundCube.Opacity := 0;

        F3DHeartPixels[i, j] := LRoundCube;
      end;
    end;
  end;
end;

end.
