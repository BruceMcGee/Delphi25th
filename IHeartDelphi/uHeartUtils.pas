unit uHeartUtils;

interface

uses
  System.SysUtils, System.Types, System.Math, System.UITypes,
  FMX.Types, FMX.Graphics, FMX.Forms, FMX.Utils;

procedure DrawBitmap(ASrcBitmap, ADstBitmap: TBitmap);
procedure DrawCardioid(ABitmap: TBitmap);
procedure DrawGraphHeart(ABitmap: TBitmap);
procedure DrawHeartCurve_4(ABitmap: TBitmap);
procedure DrawHeartCurve_5(ABitmap: TBitmap);
procedure DrawHeartCurve_Spiral(ABitmap: TBitmap);
procedure DrawMandelbrotHeart(ABitmap: TBitmap; AMaxIterations: Integer);
procedure DrawPixelatedHeart(ABitmap: TBitmap);
procedure DrawSineWaveHeart(ABitmap: TBitmap; AMinFreq, AMaxFreq: Single);
procedure DrawStringArtCardioid(ABitmap: TBitmap);
procedure DrawStringArtHeart(ABitmap: TBitmap);

function Map(AValue, AInputMin, AInputMax, AOutputMin, AOutputMax: Double): Double; forward;

const
  HEART_PIXELS: array of array of Integer = [
    [0, 1, 1, 0, 1, 1, 0],
    [1, 2, 2, 2, 2, 2, 1],
    [1, 2, 3, 3, 3, 2, 1],
    [0, 1, 2, 3, 2, 1, 0],
    [0, 0, 1, 2, 1, 0, 0],
    [0, 0, 0, 1, 0, 0, 0]
    ];


implementation

function GetStringArtPoint(ABitmap: TBitmap; APointNo, ATotalPoints: Single): TPointF; forward;
function GetStringArtScale(ABitmap: TBitmap): Single; forward;


// ----------------------------------------------------------------------------
procedure DrawBitmap(ASrcBitmap, ADstBitmap: TBitmap);
var
  LSrcRect, LDstRect: TRectF;
begin
  ADstBitmap.Clear(TAlphaColorRec.Black);
  ADstBitmap.Canvas.BeginScene;
  try
    LSrcRect := ASrcBitmap.BoundsF;
    LDstRect := ADstBitmap.BoundsF;

    if LSrcRect.Width > LSrcRect.Height then
    begin
      LDstRect.Height := LDstRect.Height * (LSrcRect.Height / LSrcRect.Width);
      LDstRect.Top := (ADstBitmap.BoundsF.Height - LDstRect.Height) / 2;
    end
    else
    begin
      LDstRect.Width := LDstRect.Width * (LSrcRect.Width / LSrcRect.Height);
      LDstRect.Left := (ADstBitmap.BoundsF.Width - LDstRect.Width) / 2;
    end;

    ADstBitmap.Canvas.DrawBitmap(ASrcBitmap, LSrcRect, LDstRect, 1);
  finally
    ADstBitmap.Canvas.EndScene;
    Application.ProcessMessages;
  end;
end;

// ----------------------------------------------------------------------------
procedure DrawCardioid(ABitmap: TBitmap);

  function GetPoint(ATheta: Single): TPointF;
  var
    LScale: Single;
    LRadius: Single;
  begin
    LScale := ABitmap.Height / 3;
    LRadius := LScale * (1 - Sin(ATheta));
    Result.X := LRadius * Cos(ATheta) + ABitmap.Width / 2;
    Result.Y := -1 * LRadius * Sin(ATheta) + ABitmap.Height / 4.5;
  end;

var
  LTheta: Single;
  LCurrentPoint, LPreviousPoint: TPointF;
begin
  ABitmap.Clear(TAlphaColorRec.Black);

  LTheta := Pi / 2; // start at the top centre
  LPreviousPoint := GetPoint(LTheta);
  while LTheta < 2.5 * Pi do
  begin
    LCurrentPoint := GetPoint(LTheta);
    ABitmap.Canvas.BeginScene;
    try
      ABitmap.Canvas.Stroke.Thickness := 3;
      ABitmap.Canvas.DrawLine(LPreviousPoint, LCurrentPoint, 1);
    finally
      ABitmap.Canvas.EndScene;
      Application.ProcessMessages;
      Sleep(25);
    end;
    LPreviousPoint := LCurrentPoint;
    LTheta := LTheta + 0.1;
  end;
end;

// ----------------------------------------------------------------------------
procedure DrawGraphHeart(ABitmap: TBitmap);

  function ScalePoint(APoint: TPointF): TPointF;
  begin
    Result := APoint;
    Result.X := Result.X + 7;
    Result.X := Map(Result.X, 0, 14, 0, ABitmap.Width - 20) + 10;
    Result.Y := -1 * Result.Y + 7;
    Result.Y := Map(Result.Y, 0, 14, 0, ABitmap.Height - 20) + 10;
  end;

var
  i: Integer;
  LPoint: TPointF;
  LRect: TRectF;
  LPoints1: TArray<TPointF>;
  LPoints2: TArray<TPointF>;
  LPoints3: TArray<TPointF>;
begin
  LPoints1 := [
    TPointF.Create(-2, 2),
    TPointF.Create(-2, 4),
    TPointF.Create(1, 6),
    TPointF.Create(4, 4),
    TPointF.Create(5, 0),
    TPointF.Create(5, -5),
    TPointF.Create(0, -5),
    TPointF.Create(-4, -4),
    TPointF.Create(-6, -1),
    TPointF.Create(-4, 2),
    TPointF.Create(-2, 2)
    ];
  LPoints2 := [
    TPointF.Create(5, 5),
    TPointF.Create(7, 6),
    TPointF.Create(6, 7),
    TPointF.Create(5, 5),
    TPointF.Create(2, 2)
    ];
  LPoints3 := [
    TPointF.Create(-2, -2),
    TPointF.Create(-6, -6),
    TPointF.Create(-6, -5),
    TPointF.Create(-7, -7),
    TPointF.Create(-5, -6),
    TPointF.Create(-6, -6)
    ];

  ABitmap.Clear(TAlphaColorRec.Black);

  // Draw heart points
  for i := 0 to Length(LPoints1) - 1 do
  begin
    ABitmap.Canvas.BeginScene;
    try
      ABitmap.Canvas.Stroke.Thickness := 3;
      LPoint := ScalePoint(LPoints1[i]);
      LRect := TRectF.Create(LPoint);
      InflateRect(LRect, 5, 5);
      ABitmap.Canvas.FillEllipse(LRect, 1);
    finally
      ABitmap.Canvas.EndScene;
      Application.ProcessMessages;
      Sleep(50);
    end;
  end;

  Sleep(100);

  // Connect points with Lines
  for i := 0 to Length(LPoints1) - 2 do
  begin
    ABitmap.Canvas.BeginScene;
    try
      ABitmap.Canvas.Stroke.Thickness := 3;
      ABitmap.Canvas.DrawLine(ScalePoint(LPoints1[i]), ScalePoint(LPoints1[i + 1]), 1);
    finally
      ABitmap.Canvas.EndScene;
      Application.ProcessMessages;
      Sleep(50);
    end;
  end;

  Sleep(250);

  // Draw arrow all at once
  ABitmap.Canvas.BeginScene;
  try
    ABitmap.Canvas.Stroke.Thickness := 3;
    for i := 0 to Length(LPoints2) - 1 do
    begin
      LPoint := ScalePoint(LPoints2[i]);
      LRect := TRectF.Create(LPoint);
      InflateRect(LRect, 5, 5);
      ABitmap.Canvas.FillEllipse(LRect, 1);
    end;
    for i := 0 to Length(LPoints3) - 1 do
    begin
      LPoint := ScalePoint(LPoints3[i]);
      LRect := TRectF.Create(LPoint);
      InflateRect(LRect, 5, 5);
      ABitmap.Canvas.FillEllipse(LRect, 1);
    end;

    for i := 0 to Length(LPoints2) - 2 do
      ABitmap.Canvas.DrawLine(ScalePoint(LPoints2[i]), ScalePoint(LPoints2[i + 1]), 1);
    for i := 0 to Length(LPoints3) - 2 do
      ABitmap.Canvas.DrawLine(ScalePoint(LPoints3[i]), ScalePoint(LPoints3[i + 1]), 1);
  finally
    ABitmap.Canvas.EndScene;
    Application.ProcessMessages;
  end;
end;

// ----------------------------------------------------------------------------
procedure DrawHeartCurve_4(ABitmap: TBitmap);

  function GetPoint(ATheta: Single): TPointF;
  var
    LScale: Single;
    LRadius: Single;
  begin
    LScale := ABitmap.Height / 5;
    LRadius := LScale * (2 - 2 * Sin(ATheta) + Sin(ATheta) * ((Sqrt(Abs(Cos(ATheta)))) / (Sin(ATheta) + 1.4)));
    Result.X := LRadius * Cos(ATheta) + ABitmap.Width / 2;
    Result.Y := -1 * LRadius * Sin(ATheta) + ABitmap.Height / 4.5;
  end;

var
  LTheta: Single;
  LCurrentPoint, LPreviousPoint: TPointF;
begin
  ABitmap.Clear(TAlphaColorRec.Black);

  LTheta := Pi / 2; // start at the top centre
  LPreviousPoint := GetPoint(LTheta);
  while LTheta < 2.5 * Pi do
  begin
    LCurrentPoint := GetPoint(LTheta);
    ABitmap.Canvas.BeginScene;
    try
      ABitmap.Canvas.Stroke.Thickness := 3;
      ABitmap.Canvas.DrawLine(LPreviousPoint, LCurrentPoint, 1);
    finally
      ABitmap.Canvas.EndScene;
      Application.ProcessMessages;
      Sleep(1);
    end;
    LPreviousPoint := LCurrentPoint;
    LTheta := LTheta + 0.02;
  end;
end;

// ----------------------------------------------------------------------------
procedure DrawHeartCurve_5(ABitmap: TBitmap);

  function GetPoint(ATheta: Single): TPointF;
  var
    LScale: Single;
  begin
    LScale := 12;
    Result.X := LScale * (16 * Power(Sin(ATheta), 3)) + ABitmap.Width / 2;
    Result.Y := -1 * LScale * (13 * Cos(ATheta) - 5 * Cos(2 * ATheta) - 2 * Cos(3 * ATheta) - Cos(4 * ATheta)) + ABitmap.Height / 2.5;
  end;

var
  LTheta: Single;
  LCurrentPoint, LPreviousPoint: TPointF;
begin
  ABitmap.Clear(TAlphaColorRec.Black);

  LTheta := 0;
  LPreviousPoint := GetPoint(LTheta);
  while LTheta < 2 * Pi + 0.1 do
  begin
    LCurrentPoint := GetPoint(LTheta);
    ABitmap.Canvas.BeginScene;
    try
      ABitmap.Canvas.Stroke.Thickness := 3;
      ABitmap.Canvas.DrawLine(LPreviousPoint, LCurrentPoint, 1);
    finally
      ABitmap.Canvas.EndScene;
      Application.ProcessMessages;
      Sleep(25);
    end;
    LPreviousPoint := LCurrentPoint;
    LTheta := LTheta + 0.1;
  end;
end;

// ----------------------------------------------------------------------------
procedure DrawHeartCurve_Spiral(ABitmap: TBitmap);

  function GetPoint(ATheta: Single): TPointF;
  var
    LScale: Single;
    LRadius: Single;
  begin
    LScale := ABitmap.Height / 35;
    LRadius := LScale * (ATheta / (16 * Pi));
    Result.X := LRadius * (16 * Power(Sin(ATheta), 3)) + ABitmap.Width / 2;
    Result.Y := -1 * LRadius * (12 * Cos(ATheta) - 5 * Cos(2 * ATheta) - 2 * Cos(3 * ATheta) - Cos(4 * ATheta)) + ABitmap.Height / 2.5;
  end;

var
  LTheta: Single;
  LCurrentPoint, LPreviousPoint: TPointF;
begin
  ABitmap.Clear(TAlphaColorRec.Black);

  LTheta := Pi;
  LPreviousPoint := GetPoint(LTheta);
  while LTheta < 16 * Pi do
  begin
    LCurrentPoint := GetPoint(LTheta);
    ABitmap.Canvas.BeginScene;
    try
      ABitmap.Canvas.Stroke.Thickness := 3;
      ABitmap.Canvas.DrawLine(LPreviousPoint, LCurrentPoint, 1);
    finally
      ABitmap.Canvas.EndScene;
      Application.ProcessMessages;
      Sleep(1);
    end;
    LPreviousPoint := LCurrentPoint;
    LTheta := LTheta + 0.1;
  end;
end;

// ----------------------------------------------------------------------------
procedure DrawMandelbrotHeart(ABitmap: TBitmap; AMaxIterations: Integer);
const
  MAX_ITERATIONS = 100;
var
  X, Y: Integer; // Bitmap coordinates
  a, b: Double; // Bitmap coordinates mapped to Mandelbrot set
  n: Integer; // Number of iterations

  aa: Double; // A squared
  bb: Double; // B squared
  ca, cb: Double; // Placeholder for original values of c

  LBitmapWidth, LBitmapHeight: Integer;
  LBitmapRatio: Single;
  LPixelColor: TAlphaColor;
  LBright: Single;
  LBitmapData: TBitmapData;
  LScanline: PAlphaColorArray;
begin
  LBitmapWidth := ABitmap.Width;
  LBitmapHeight := ABitmap.Height;
  LBitmapRatio := LBitmapHeight / LBitmapWidth;

  ABitmap.Clear(TAlphaColorRec.White);
  ABitmap.Map(TMapAccess.ReadWrite, LBitmapData);
  try
    for Y := 0 to LBitmapWidth - 1 do
    begin
      LScanline := PAlphaColorArray(LBitmapData.GetScanline(Y));
      for X := 0 to LBitmapHeight - 1 do
      begin
        // The Mandelbrot set falls between -2 and 2 on the imaginary plane
        // Tweaked the ranges to adjust position and zoom
        a := Map(Y, LBitmapWidth, 0, -2.25, 0.75);
        b := Map(X, 0, LBitmapHeight, -1.5 * LBitmapRatio, 1.5 * LBitmapRatio);

        // Retain original values of c
        ca := a;
        cb := b;

        // Mandelbrot formula:  z squared + c
        // Which translates to: a squared - b squared + 2ab - then add c
        // Exercise for the reader to use Delphi's complex numbers instead
        n := 0;
        while (n < AMaxIterations) do
        begin
          // Z Squared
          aa := (a * a) - (b * b); // Real component
          bb := 2 * a * b; // Imaginary component

          // + c
          a := aa + ca;
          b := bb + cb;

          if (a * a + b * b) > 4 then
            Break;

          Inc(n);
        end;

        // Make everything in the set red. It's supposed to be a heart, after all.
        // Add white halo for contrast
        if n >= AMaxIterations then
          LPixelColor := TAlphaColorRec.Red
        else
        begin
          LBright := Map(n, 0, AMaxIterations / 2, 0, 1); // /2 to exagerate halo
          LPixelColor := TAlphaColorF.Create(LBright, LBright, LBright).ToAlphaColor;
        end;

        LScanline[X] := LPixelColor;
      end;
    end;
  finally
    ABitmap.Unmap(LBitmapData);
  end;
end;

// ----------------------------------------------------------------------------
procedure DrawPixelatedHeart(ABitmap: TBitmap);
var
  i, j: Integer;
  LRatio: Double;
  LXOffset, LYOffset: Double;
  LRect: TRectF;
begin
  ABitmap.Clear(TAlphaColorRec.Black);

  LRatio := 0.95 * ABitmap.Width / Length(HEART_PIXELS[0]);
  LXOffset := (ABitmap.Width - (LRatio * Length(HEART_PIXELS[0]))) / 2;
  LYOffset := (ABitmap.Height - (LRatio * Length(HEART_PIXELS))) / 2;
  for i := 0 to Length(HEART_PIXELS) - 1 do
  begin
    for j := 0 to Length(HEART_PIXELS[0]) - 1 do
    begin
      if HEART_PIXELS[i, j] > 0 then
      begin
        ABitmap.Canvas.BeginScene;
        try
          LRect.Top := LRatio * i + LYOffset;
          LRect.Left := LRatio * j + LXOffset;
          LRect.Width := LRatio;
          LRect.Height := LRatio;
          InflateRect(LRect, -8, -8);
          ABitmap.Canvas.Stroke.Thickness := 5;
          ABitmap.Canvas.FillRect(LRect, 0, 0, AllCorners, 0.6);
          ABitmap.Canvas.DrawRect(LRect, 3, 3, AllCorners, 1);
        finally
          ABitmap.Canvas.EndScene;
          Application.ProcessMessages;
          Sleep(35);
        end;
      end;
    end;
  end;
end;

// ----------------------------------------------------------------------------
procedure DrawSineWaveHeart(ABitmap: TBitmap; AMinFreq, AMaxFreq: Single);

  function GetPoint(AX, AFreq: Single): TPointF;
  var
    LXRatio, LYRatio: Double;
    LXOffset, LYOffset: Double;
    LY: Double;
  begin
    LXRatio := ABitmap.Width / 4.5;
    LYRatio := ABitmap.Height / 4.5;
    LXOffset := ABitmap.Width / 2;
    LYOffset := 6 * (ABitmap.Height / 10);

    LY := Power(Abs(AX), 2 / 3) + 0.9 * Power(3.3 - Abs(AX) * Abs(AX), 0.5) * Sin(AFreq * Pi * Abs(AX));

    Result := TPointF.Create(LXRatio * AX + LXOffset, LYRatio * -LY + LYOffset);
  end;

const
  START_POINT = -2;
  END_POINT = 2;
  INCREMENT = 0.01;
var
  X: Single;
  LFreq: Single;
  LCurrentPoint, LPreviousPoint: TPointF;
begin
  LFreq := AMinFreq;
  while LFreq <= AMaxFreq do
  begin
    ABitmap.Clear(TAlphaColorRec.Black);

    ABitmap.Canvas.BeginScene;
    try
      X := START_POINT;
      LPreviousPoint := GetPoint(X, LFreq);
      while X <= END_POINT do
      begin
        LCurrentPoint := GetPoint(X, LFreq);
        ABitmap.Canvas.DrawLine(LPreviousPoint, LCurrentPoint, 1);
        LPreviousPoint := LCurrentPoint;
        X := X + INCREMENT;
      end;
    finally
      ABitmap.Canvas.EndScene;
      Application.ProcessMessages;
    end;
    LFreq := LFreq + 0.1;
  end;
end;

// ----------------------------------------------------------------------------
function GetStringArtPoint(ABitmap: TBitmap; APointNo, ATotalPoints: Single): TPointF;
var
  LScale: Single;
  LRadius: Single;
  LAngle: Single;
begin
  LScale := GetStringArtScale(ABitmap);
  LRadius := 1;

  LAngle := Map(APointNo, 0, ATotalPoints, -0.5 * Pi, 1.5 * Pi);
  Result.X := LScale * LRadius * Cos(LAngle) + ABitmap.Width / 2;
  Result.Y := -1 * LScale * LRadius * Sin(LAngle) + ABitmap.Height / 2;
end;

// ----------------------------------------------------------------------------
function GetStringArtScale(ABitmap: TBitmap): Single;
begin
  Result := (ABitmap.Height / 2) * 0.95;
end;

// ----------------------------------------------------------------------------
procedure DrawStringArtCardioid(ABitmap: TBitmap);
var
  i: Integer;
  LTotalPoints: Integer;
  LScale: Single;
  LRect: TRectF;
  LPoint0, LPoint1: TPointF;
begin
  ABitmap.Clear(TAlphaColorRec.Black);

  for LTotalPoints := 1 to 100 do
  begin
    ABitmap.Clear(TAlphaColorRec.Black);
    ABitmap.Canvas.BeginScene;
    try
      LRect := TRectF.Create(TPointF.Create(ABitmap.Width / 2, ABitmap.Height / 2));
      LScale := GetStringArtScale(ABitmap);
      InflateRect(LRect, LScale, LScale);
      ABitmap.Canvas.DrawEllipse(LRect, 1);

      for i := 0 to LTotalPoints do
      begin
        LPoint0 := GetStringArtPoint(ABitmap, i, LTotalPoints);
        LRect := TRectF.Create(LPoint0);
        InflateRect(LRect, 3, 3);
        ABitmap.Canvas.FillEllipse(LRect, 1);
        LPoint1 := GetStringArtPoint(ABitmap, (i * 2) mod LTotalPoints, LTotalPoints);
        ABitmap.Canvas.DrawLine(LPoint0, LPoint1, 1);
      end;
    finally
      ABitmap.Canvas.EndScene;
      Application.ProcessMessages;
      Sleep(15);
    end;
  end;
end;

// ----------------------------------------------------------------------------
procedure DrawStringArtHeart(ABitmap: TBitmap);
var
  i: Integer;
  LIncrement: Integer;
  LTotalPoints: Integer;
  LScale: Single;
  LRect: TRectF;
  LPoint0, LPoint1: TPointF;
begin
  ABitmap.Clear(TAlphaColorRec.Black);

  LTotalPoints := 100;
  ABitmap.Canvas.BeginScene;
  try
    LRect := TRectF.Create(TPointF.Create(ABitmap.Width / 2, ABitmap.Height / 2));
    LScale := GetStringArtScale(ABitmap);
    InflateRect(LRect, LScale, LScale);
    ABitmap.Canvas.DrawEllipse(LRect, 1);

    for i := 0 to LTotalPoints do
    begin
      LPoint0 := GetStringArtPoint(ABitmap, i, LTotalPoints);
      LRect := TRectF.Create(LPoint0);
      InflateRect(LRect, 3, 3);
      ABitmap.Canvas.FillEllipse(LRect, 1);
    end;
  finally
    ABitmap.Canvas.EndScene;
    Application.ProcessMessages;
  end;

  for i := 0 to (LTotalPoints div 4) do
  begin
    ABitmap.Canvas.BeginScene;
    try
      LPoint0 := GetStringArtPoint(ABitmap, i, LTotalPoints);
      LPoint1 := GetStringArtPoint(ABitmap, i + (LTotalPoints div 4), LTotalPoints);
      ABitmap.Canvas.DrawLine(LPoint0, LPoint1, 1);
    finally
      ABitmap.Canvas.EndScene;
      Application.ProcessMessages;
      Sleep(20);
    end;
  end;

  Sleep(200);

  for i := (LTotalPoints div 2) to 3 * (LTotalPoints div 4) do
  begin
    ABitmap.Canvas.BeginScene;
    try
      LPoint0 := GetStringArtPoint(ABitmap, i, LTotalPoints);
      LPoint1 := GetStringArtPoint(ABitmap, i + (LTotalPoints div 4), LTotalPoints);
      ABitmap.Canvas.DrawLine(LPoint0, LPoint1, 1);
    finally
      ABitmap.Canvas.EndScene;
      Application.ProcessMessages;
      Sleep(20);
    end;
  end;

  Sleep(200);

  LIncrement := 0;
  for i := (LTotalPoints div 4) to (LTotalPoints div 2) do
  begin
    ABitmap.Canvas.BeginScene;
    try
      LPoint0 := GetStringArtPoint(ABitmap, i, LTotalPoints);
      LPoint1 := GetStringArtPoint(ABitmap, i + (LTotalPoints div 4) + LIncrement, LTotalPoints);
      LIncrement := LIncrement + 1;

      ABitmap.Canvas.DrawLine(LPoint0, LPoint1, 1);
    finally
      ABitmap.Canvas.EndScene;
      Application.ProcessMessages;
      Sleep(25);
    end;
  end;

  for i := (LTotalPoints div 2) to 3 * (LTotalPoints div 4) do
  begin
    ABitmap.Canvas.BeginScene;
    try
      LPoint0 := GetStringArtPoint(ABitmap, i, LTotalPoints);
      LPoint1 := GetStringArtPoint(ABitmap, i + (LTotalPoints div 4) + LIncrement, LTotalPoints);
      LIncrement := LIncrement + 1;

      ABitmap.Canvas.DrawLine(LPoint0, LPoint1, 1);
    finally
      ABitmap.Canvas.EndScene;
      Application.ProcessMessages;
      Sleep(25);
    end;
  end;
end;


// ----------------------------------------------------------------------------
// Delphi implementation of Processing's Map() function
// https://processing.org/reference/map_.html
function Map(AValue, AInputMin, AInputMax, AOutputMin, AOutputMax: Double): Double;
begin
  Result := AOutputMin + (AOutputMax - AOutputMin) * ((AValue - AInputMin) / (AInputMax - AInputMin));
end;

end.
