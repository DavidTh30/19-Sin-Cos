unit Unit1;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls, Graphics, StdCtrls,
  ExtCtrls, EpikTimer, BGRABitmap,BGRABitmapTypes, Math, LCLIntf;

  type
  Inform = record
    Previous: Float;
    TimePerFrame: Float;
    LinePerFrame: Integer;
    FramePerSec: Integer;
    ActualElapsed: Float;
    LineLeftover: Integer;
    Speed_frame:Extended;
  end;

  type
  KeyB = record
    TotalKeyBCounter: Integer;
    LastKeyBCounter: Integer;
    KeyBCounterPerSec:integer;
    KeyboardUpCounter:integer;
    KeyboardDownCounter:integer;
    MouseUpCounter:integer;
    MouseDownCounter:integer;
    MouseCounterPerSec:integer;
    LastMouseCounter:integer

  end;

  type
  Pain_ = record
    Angle: Float;
    Radius: Float;
    Position:TPoint;
    Position2:TPoint;
    Vpts: array of TPointF;
    Hpts: array of TPointF;
    Value1: Float;
    bmp, SinBmp, CosBmp, TopBmp, TempBmp: TBGRABitmap;
    FPie:boolean;
    Offset:integer;
  end;

type

  { TForm1 }

  TForm1 = class(TForm)
    Button1: TButton;
    Button2: TButton;
    Label3: TLabel;
    PaintBox2: TPaintBox;
    procedure Button1Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure FormActivate(Sender: TObject);
    procedure FormClose(Sender: TObject; var CloseAction: TCloseAction);
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure FormKeyUp(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure PaintBox2MouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure PaintBox2MouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
  private
    { private declarations }
  public
    { public declarations }
    procedure Main_Loop();
    Function TransparentBMP_ToBuffer(filename: string): TBGRABitmap;
    Function ManualTransparentBMP_ToBuffer(filename: string; Transparent:TBGRAPixel): TBGRABitmap;
    procedure SetUpValue();
  end;

var
  Form1: TForm1;
  timer_: TEpikTimer;
  Run_:Boolean;
  Background_, bmp, bmp2: TBGRABitmap;
  Grid_:Tpoint;
  c: TBGRAPixel;
  Trect_:Trect;
  Positioning:integer;
  Information:Inform;
  KeyB_:KeyB;
  Tem:Pain_;
  DisableHCos:Boolean;
  DisableGuideTriangle:Boolean;

implementation

{$R *.lfm}

{ TForm1 }
Procedure TForm1.SetUpValue();
begin
  DisableGuideTriangle:=True;
  DisableHCos:=True;
  Tem.Offset:=10;
  Tem.Angle:=0;
  Tem.Radius:=40;
  Tem.Position:=Point(500,250);
  Tem.Position2:=Point(Tem.Position.x-round(Tem.Radius)-Tem.Offset,Tem.Position.y-round(Tem.Radius)-Tem.Offset);
  setlength(Tem.Hpts,2);
  setlength(Tem.Vpts,2);
  Tem.Hpts[0] := PointF(450,500);
  Tem.Hpts[1] := pointF(0,0);
  Tem.Vpts[0] := PointF(450,500);
  Tem.Vpts[1] := pointF(0,0);
  Tem.Value1:=0;
  Tem.bmp:=TBGRABitmap.Create(PaintBox2.Width,PaintBox2.Height,BGRAPixelTransparent);
  Tem.SinBmp:=TBGRABitmap.Create(PaintBox2.Width,PaintBox2.Height,BGRAPixelTransparent);
  Tem.CosBmp:=TBGRABitmap.Create(PaintBox2.Width,PaintBox2.Height,BGRAPixelTransparent);
  Tem.TopBmp:=TBGRABitmap.Create(PaintBox2.Width,PaintBox2.Height,BGRAPixelTransparent);
  Tem.TempBmp:=TBGRABitmap.Create(PaintBox2.Width,PaintBox2.Height,BGRAPixelTransparent);
  Tem.FPie:=False;

  KeyB_.TotalKeyBCounter:=0;
  KeyB_.LastKeyBCounter:=0;
  KeyB_.KeyBCounterPerSec:=0;
  KeyB_.KeyboardUpCounter:=0;
  KeyB_.KeyboardDownCounter:=0;
  KeyB_.MouseCounterPerSec:=0;
  KeyB_.MouseUpCounter:=0;
  KeyB_.MouseDownCounter:=0;
  KeyB_.LastMouseCounter:=0;

  Information.Speed_frame:=0.02;
  timer_ := TEpikTimer.Create(nil);
  //timer_.TimebaseSource:=timer_.TimebaseSource.HardwareTimebase;
  Run_:=False;

  c := ColorToBGRA(rgb(255,255,255));

  //Load your bitmap here

  Grid_.X:=26;
  Grid_.y:=15;

  if Grid_.X<0 then Grid_.X:=0;
  if Grid_.Y<0 then Grid_.Y:=0;

  Background_ := TBGRABitmap.Create(PaintBox2.Width,PaintBox2.Height, ColorToBGRA($00F0F0F0));//clForeground //clBtnFace  //clWindow //ColorToBGRA(rgb(255,255,255))
  bmp := TBGRABitmap.Create(PaintBox2.Width,PaintBox2.Height, ColorToBGRA($00F0F0F0));//clForeground //clBtnFace  //clWindow //ColorToBGRA(rgb(255,255,255))
  bmp2 := TBGRABitmap.Create(Round(PaintBox2.Width/(Grid_.X+1))+1,PaintBox2.Height, ColorToBGRA($00CCCCCC));//ColorToBGRA($00CCCCCC)//clForeground //clBtnFace  //clWindow //ColorToBGRA(rgb(255,255,255))
  bmp.FontName := 'Times New Roman';
  bmp.FontAntialias:= true;
  bmp.FontHeight:=12;
  bmp.FontStyle:=[fsBold];

end;

Function TForm1.ManualTransparentBMP_ToBuffer(filename: string; Transparent:TBGRAPixel): TBGRABitmap;
var
  OriginalBMP: TBGRABitmap;
begin
  OriginalBMP := TBGRABitmap.Create(filename);
  OriginalBMP.ReplaceColor(Transparent,BGRAPixelTransparent);
  ManualTransparentBMP_ToBuffer := TBGRABitmap.Create(OriginalBMP.Width,OriginalBMP.Height);       //result
  ManualTransparentBMP_ToBuffer.PutImage(0,0,OriginalBMP,dmSet,255);
  OriginalBMP.Free;
end;

Function TForm1.TransparentBMP_ToBuffer(filename: string): TBGRABitmap;
var
  OriginalBMP: TBGRABitmap;
  //Trect_:Trect;
begin
  OriginalBMP := TBGRABitmap.Create(filename);
  OriginalBMP.ReplaceColor(OriginalBMP.GetPixel(0,0),BGRAPixelTransparent);
  TransparentBMP_ToBuffer := TBGRABitmap.Create(OriginalBMP.Width,OriginalBMP.Height);       //result
  TransparentBMP_ToBuffer.PutImage(0,0,OriginalBMP,dmSet,255);
  //TransparentBMP_ToBuffer.Rectangle(OriginalBMP.Width,0,OriginalBMP.Width,OriginalBMP.Height,BGRABlack,BGRA(0,0,0,64),dmDrawWithTransparency);

  //Trect_.TopLeft.x:=0;
  //Trect_.TopLeft.y:=0;
  //Trect_.BottomRight.x:=round(OriginalBMP.Width/2);
  //Trect_.BottomRight.y:=round(OriginalBMP.Height/2);
  //TransparentBMP_ToBuffer.PutImagePart(0,0,OriginalBMP,IT,dmSet,255); //TransparentBMP_ToBuffer.PutImagePart(0,0,OriginalBMP,IT,dmDrawWithTransparency);
  OriginalBMP.Free;
end;

procedure TForm1.Main_Loop();
var
  Frame_, Line_, Line_Frame:integer;
  x_,y_,t:Float;

begin
  if Not Run_ then
  begin
    Run_:=True;
    Information.Previous:=0;
    Frame_:=0;
    Line_:=0;
    timer_.Clear;
    timer_.Start;

    while Run_ do
    begin
      Line_Frame:=0;
      application.ProcessMessages; //Work one program only   Case 1.

      //Run your program here  => Finish up your brackground

      bmp.PutImage(0,0,Background_,dmDrawWithTransparency);

      Trect_.TopLeft.x:=1;
      Trect_.TopLeft.y:=0;
      Trect_.BottomRight.x:=PaintBox2.Width;
      Trect_.BottomRight.y:=PaintBox2.Height;
      Background_.PutImagePart(0,0,Background_,Trect_,dmDrawWithTransparency);

      Positioning:=Positioning+1;
      if Positioning = (bmp2.Width) then Positioning :=0;

      Trect_.TopLeft.x:=Positioning;
      Trect_.TopLeft.y:=0;
      Trect_.BottomRight.x:=Positioning+1;
      Trect_.BottomRight.y:=bmp2.Height;
      c := ColorToBGRA(rgb(255,50,0));
      Background_.PutImagePart(PaintBox2.Width-1,0,bmp2,Trect_,dmDrawWithTransparency);

      //Any text information here  => Finish up your text status
      c := ColorToBGRA(rgb(0,105,208));

      t := (((2*pi)/360)*(Tem.Angle));
      x_ :=((Tem.Radius)*cos(t));
      y_ :=((Tem.Radius)*sin(t));
      x_ := x_+Tem.Position.x;
      y_ :=(-y_)+Tem.Position.y;
      Tem.Angle:=Tem.Angle+1;
      if Tem.Angle >= 360 then begin Tem.FPie:=not Tem.FPie;  Tem.Angle:=0; end;
      Tem.Hpts[0] := pointF(Tem.Position2.x,y_);
      Tem.Hpts[1] := pointF(x_,y_);
      Tem.Vpts[0] := pointF(x_,Tem.Position2.y);
      Tem.Vpts[1] := pointF(x_,y_);

      Tem.TempBmp.ApplyGlobalOpacity(0);
      Tem.TempBmp.PutImage(-1,0,Tem.SinBmp,dmDrawWithTransparency);
      Tem.SinBmp.ApplyGlobalOpacity(0);
      //Tem.SinBmp.DrawPixel(Tem.Position2.x,Tem.Position.y-round(Tem.Radius),c);
      Tem.SinBmp.DrawPolygonAntialias([pointF(0,Tem.Position.y-round(Tem.Radius)),pointF(Tem.Position2.x,Tem.Position.y-round(Tem.Radius))],BGRA(180,180,180,155),1);
      //Tem.SinBmp.DrawPixel(Tem.Position2.x,Tem.Position.y,c);
      Tem.SinBmp.DrawPolygonAntialias([pointF(0,Tem.Position.y),pointF(Tem.Position2.x,Tem.Position.y)],BGRA(180,180,180,155),1);
      //Tem.SinBmp.DrawPixel(Tem.Position2.x,Tem.Position.y+round(Tem.Radius),c);
      Tem.SinBmp.DrawPolygonAntialias([pointF(0,Tem.Position.y+round(Tem.Radius)),pointF(Tem.Position2.x,Tem.Position.y+round(Tem.Radius))],BGRA(180,180,180,155),1);
      Tem.SinBmp.PutImage(0,0,Tem.TempBmp,dmDrawWithTransparency);

      t := (((2*pi)/360)*(Tem.Angle));
      x_ :=450;
      y_ :=((Tem.Radius)*sin(t));
      x_ := x_+0;
      y_ :=(-y_)+Tem.Position.y;
      Tem.SinBmp.DrawPixel(round(x_),round(y_),c);

      Tem.TempBmp.ApplyGlobalOpacity(0);
      Tem.TempBmp.PutImage(-1,0,Tem.CosBmp,dmDrawWithTransparency);
      Tem.CosBmp.ApplyGlobalOpacity(0);
      //Tem.CosBmp.DrawPixel(Tem.Position2.x,Tem.Position2.y-round(Tem.Radius*2)-Tem.Offset,c);
      Tem.CosBmp.DrawPolygonAntialias([pointF(0,Tem.Position2.y-round(Tem.Radius*2)-Tem.Offset),pointF(Tem.Position2.x,Tem.Position2.y-round(Tem.Radius*2)-Tem.Offset)],BGRA(180,180,180,155),1);
      //Tem.CosBmp.DrawPixel(Tem.Position2.x,Tem.Position2.y-round(Tem.Radius)-Tem.Offset,c);
      Tem.CosBmp.DrawPolygonAntialias([pointF(0,Tem.Position2.y-round(Tem.Radius)-Tem.Offset),pointF(Tem.Position2.x,Tem.Position2.y-round(Tem.Radius)-Tem.Offset)],BGRA(180,180,180,155),1);
      //Tem.CosBmp.DrawPixel(Tem.Position2.x,Tem.Position2.y-Tem.Offset,c);
      Tem.CosBmp.DrawPolygonAntialias([pointF(0,Tem.Position2.y-Tem.Offset),pointF(Tem.Position2.x,Tem.Position2.y-Tem.Offset)],BGRA(180,180,180,155),1);
      Tem.CosBmp.PutImage(0,0,Tem.TempBmp,dmDrawWithTransparency);

      t := (((2*pi)/360)*(Tem.Angle));
      x_ :=Tem.Position2.x;
      y_ :=((Tem.Radius)*cos(t));
      x_ := x_+0;
      y_ :=(-y_)+Tem.Position2.y-(Tem.Radius)-Tem.Offset;

      Tem.CosBmp.DrawPixel(round(x_),round(y_),BGRA(255,50,50,255));
      //Tem.CosBmp.DrawPixel(round(x_-1),round(y_),BGRA(255,150,150,255));

      Tem.TempBmp.ApplyGlobalOpacity(0);
      Tem.TempBmp.PutImage(0,-1,Tem.TopBmp,dmDrawWithTransparency);
      Tem.TopBmp.ApplyGlobalOpacity(0);
      //Tem.TopBmp.DrawPixel(Tem.Position.x-round(Tem.Radius),Tem.Position2.y,c);
      Tem.TopBmp.DrawPolygonAntialias([pointF(Tem.Position.x-round(Tem.Radius),0),pointF(Tem.Position.x-round(Tem.Radius),Tem.Position2.y)],BGRA(180,180,180,155),1);
      //Tem.TopBmp.DrawPixel(Tem.Position.x,Tem.Position2.y,c);
      Tem.TopBmp.DrawPolygonAntialias([pointF(Tem.Position.x,0),pointF(Tem.Position.x,Tem.Position2.y)],BGRA(180,180,180,155),1);
      //Tem.TopBmp.DrawPixel(Tem.Position.x+round(Tem.Radius),Tem.Position2.y,c);
      Tem.TopBmp.DrawPolygonAntialias([pointF(Tem.Position.x+round(Tem.Radius),0),pointF(Tem.Position.x+round(Tem.Radius),Tem.Position2.y)],BGRA(180,180,180,155),1);
      Tem.TopBmp.PutImage(0,0,Tem.TempBmp,dmDrawWithTransparency);

      t := (((2*pi)/360)*(Tem.Angle));
      x_ :=((Tem.Radius)*cos(t));
      y_ :=Tem.Position2.y;
      x_ := (x_)+Tem.Position.x;
      y_ :=(y_);
      Tem.TopBmp.DrawPixel(round(x_),round(y_),BGRA(255,50,50,255));
      //Tem.TopBmp.DrawPixel(round(x_),round(y_-1),BGRA(255,150,150,255));

      Tem.Value1:=Tem.Value1+1;

      Tem.bmp.ApplyGlobalOpacity(0);
      Tem.bmp.PutImage(0,0,Tem.SinBmp,dmDrawWithTransparency);
      Tem.bmp.PutImage(0,0,Tem.CosBmp,dmDrawWithTransparency);
      if not DisableHCos then Tem.bmp.PutImage(0,0,Tem.TopBmp,dmDrawWithTransparency);

      Tem.bmp.DrawPolygonAntialias(Tem.Hpts,c,1);
      Tem.bmp.DrawPolygonAntialias(Tem.Vpts,c,1);
      Tem.bmp.EllipseAntialias(Tem.Hpts[0].x,Tem.Hpts[0].y,2,2,c,1);
      Tem.bmp.DrawPolygonAntialias([Tem.Hpts[1],pointF(Tem.Position.x,Tem.Position.y)],c,1);
      Tem.bmp.EllipseAntialias(Tem.Position.x,Tem.Position.y,2,2,c,1);
      Tem.bmp.EllipseAntialias(Tem.Hpts[1].x,Tem.Hpts[1].y,2,2,c,1);

      Tem.bmp.EllipseAntialias(Tem.Vpts[0].x,Tem.Vpts[0].y,2,2,c,1);
      //Tem.bmp.EllipseAntialias(Tem.Vpts[1].x,Tem.Vpts[1].y,2,2,BGRA(10,10,10,255),1);
      Tem.bmp.EllipseAntialias(Tem.Position.x,Tem.Position.y,Tem.Radius,Tem.Radius,c,1);

      Tem.Hpts[0] := pointF(Tem.Position2.x,Tem.Position2.y);
      Tem.Hpts[1] := pointF(Tem.Hpts[1].x,Tem.Position2.y);
      Tem.Vpts[0] := pointF(Tem.Position2.x,Tem.Position2.y);
      Tem.Vpts[1] := pointF(Tem.Position2.x,Tem.Vpts[1].y);
      If not DisableGuideTriangle then Tem.bmp.DrawPolygonAntialias(Tem.Hpts,c,1);
      If not DisableGuideTriangle then Tem.bmp.DrawPolygonAntialias(Tem.Vpts,c,1);
      Tem.Vpts[0] := pointF(Tem.Position2.x,Tem.Position2.y);
      Tem.Vpts[1] := pointF(Tem.Position2.x,Tem.Position2.y-(Tem.Hpts[1].x-Tem.Position2.x));
      If not DisableGuideTriangle then Tem.bmp.DrawPolygonAntialias(Tem.Vpts,c,1);
      If not DisableGuideTriangle then Tem.bmp.DrawPolygonAntialias([pointF(Tem.Vpts[1].x,Tem.Vpts[1].y),pointF(Tem.Hpts[1].x,Tem.Hpts[1].y)],c,1);
      Tem.bmp.Arc(Tem.Position2.x,Tem.Position2.y,(Tem.Radius*2)+Tem.Offset,(Tem.Radius*2)+Tem.Offset,0,90*(Pi/180),BGRA(180,180,180,255),1,False,BGRA(0,0,0,0));//ColorToBGRA(rgb(255,105,208)));
      Tem.bmp.Arc(Tem.Position2.x,Tem.Position2.y,(Tem.Radius*1)+Tem.Offset,(Tem.Radius*1)+Tem.Offset,0,90*(Pi/180),BGRA(180,180,180,255),1,False,BGRA(0,0,0,0));//ColorToBGRA(rgb(255,105,208)));
      Tem.bmp.Arc(Tem.Position2.x,Tem.Position2.y,0+Tem.Offset,0+Tem.Offset,0,90*(Pi/180),BGRA(180,180,180,255),1,False,BGRA(0,0,0,0));//ColorToBGRA(rgb(255,105,208)));
      Tem.bmp.Arc(Tem.Position2.x,Tem.Position2.y,Tem.Hpts[1].x-Tem.Position2.x,Tem.Hpts[1].x-Tem.Position2.x,0,90*(Pi/180),BGRA(255,150,150,255),1,False,BGRA(0,0,0,0));//ColorToBGRA(rgb(255,105,208)));

      if Tem.FPie then
      begin
        if T>0 then Tem.bmp.Arc(Tem.Position.x,Tem.Position.y,20,20,(2*pi),T,BGRA(190,35,18,255),1,False,BGRA(0,0,0,0));
        if T<=0 then Tem.bmp.Arc(Tem.Position.x,Tem.Position.y,20,20,(2*pi),T+(pi/181),BGRA(190,35,18,255),1,False,BGRA(0,0,0,0));
        if T>0 then Tem.bmp.FillPie(Tem.Position.x,Tem.Position.y,20,20,(2*pi),T,BGRA(190,5,18,100));
        if T<=0 then Tem.bmp.FillPie(Tem.Position.x,Tem.Position.y,20,20,(2*pi),T+(pi/181),BGRA(190,5,18,100));
      end
      else
      begin
        if T>0 then Tem.bmp.Arc(Tem.Position.x,Tem.Position.y,20,20,0,T,BGRA(190,5,18,155),1,False,BGRA(0,0,0,0));
        if T<=0 then Tem.bmp.Arc(Tem.Position.x,Tem.Position.y,20,20,0,0+(pi/181),BGRA(190,5,18,155),1,False,BGRA(0,0,0,0));
        if T>0 then Tem.bmp.FillPie(Tem.Position.x,Tem.Position.y,20,20,0,T,BGRA(190,5,18,100));
        if T<=0 then Tem.bmp.FillPie(Tem.Position.x,Tem.Position.y,20,20,0,0+(pi/181),BGRA(190,5,18,100));
      end;

      If not DisableGuideTriangle then Tem.bmp.EllipseAntialias(Tem.Position2.x,Tem.Position2.y,2,2,c,1);
      Tem.bmp.EllipseAntialias(Tem.Vpts[1].x,Tem.Vpts[1].y,2,2,c,1);

      bmp.PutImage(0,0,Tem.bmp,dmDrawWithTransparency);

      bmp.TextOut(10,(bmp.FontFullHeight*0)+5,'H ='+FloatToStr(Tem.Hpts[0].x)+','+FloatToStr(Tem.Hpts[0].y),c);
      bmp.TextOut(10,(bmp.FontFullHeight*1)+5,'V ='+FloatToStr(Tem.Vpts[0].x)+','+FloatToStr(Tem.Vpts[0].y),c);
      bmp.TextOut(10,(bmp.FontFullHeight*2)+5,'Angle ='+FloatToStr(Tem.Angle),c);
      if Tem.FPie then bmp.TextOut(10,(bmp.FontFullHeight*3)+5,'True',c);
      if not Tem.FPie then bmp.TextOut(10,(bmp.FontFullHeight*3)+5,'False',c);
      //Render here   => Finish up your rander
      bmp.Draw(PaintBox2.Canvas,0,0,True);

      //Clear your hardware here

      while (((timer_.Elapsed -Information.Previous) <= Information.Speed_frame) and
             (timer_.Elapsed < 1) and (Run_)) do //and (timer_.Elapsed < 1) do
      begin
        //application.ProcessMessages; //Share CUP  Case 2

        //Detect hardware here
        if KeyB_.KeyboardDownCounter>KeyB_.TotalKeyBCounter then
        begin
          KeyB_.TotalKeyBCounter:=KeyB_.TotalKeyBCounter+1;
        end;

        Line_:=Line_+1;
        Line_Frame:=Line_Frame+1;

        //Run_:=not Run_; //For run only 1 cycle
      end;

      //Other status here
      Information.TimePerFrame:=(timer_.Elapsed -Information.Previous)*1000;
      Information.Previous:=timer_.Elapsed;
      Frame_:=Frame_+1;

      if timer_.Elapsed >= 1 then
      begin
        KeyB_.KeyBCounterPerSec:=KeyB_.TotalKeyBCounter-KeyB_.LastKeyBCounter;
        KeyB_.LastKeyBCounter:=KeyB_.TotalKeyBCounter;
        KeyB_.MouseCounterPerSec:=KeyB_.MouseDownCounter-KeyB_.LastMouseCounter;
        KeyB_.LastMouseCounter:=KeyB_.MouseDownCounter;
        timer_.Stop;
        Information.ActualElapsed:=timer_.Elapsed*1000;
        Information.FramePerSec:=Frame_;
        Information.LineLeftover:=Line_;
        Information.LinePerFrame:=Line_Frame;

        Information.Previous:=0;
        Frame_:=0;
        Line_:=0;
        timer_.Clear;
        timer_.Start;
      end;

      //You can move your render to here. (!It is up to you)

    end;

    If not Run_ then  timer_.Stop;
  end;
end;

procedure TForm1.FormCreate(Sender: TObject);
var
  i, i2, i3 : Integer;

begin
  SetUpValue();

  c := ColorToBGRA(rgb(190,190,190));

  i2:=Round(PaintBox2.Width/(Grid_.X+1));
  i3:=0;
  for i := 0 to Grid_.X do
  begin
    i3:=i3+i2;
    Background_.DrawPolyLineAntialias([PointF(i3,0), PointF(i3,PaintBox2.Height)],BGRA(255,255,255,150),1);
    //Background_.DrawPolyLineAntialias([PointF(i3,Tem.Position2.y+tem.offset), PointF(i3,Tem.Position2.y+tem.offset+round(tem.Radius*2))],BGRA(190,5,18,100),1);
  end;

  i2:=Round(PaintBox2.Height/(Grid_.Y+1));
  i3:=0;
  for i := 0 to Grid_.Y do
  begin
    i3:=i3+i2;
    Background_.DrawPolyLineAntialias([PointF(0,i3), PointF(PaintBox2.Width,i3)],BGRA(255,255,255,150),1);
  end;

  c := ColorToBGRA(rgb(255,255,255));

  Trect_.TopLeft.x:=0;
  Trect_.TopLeft.y:=0;
  Trect_.BottomRight.x:=bmp2.Width;
  Trect_.BottomRight.y:=bmp2.Height;
  bmp2.PutImagePart(0,0,Background_,Trect_,dmDrawWithTransparency);
  //bmp2.DrawPolyLineAntialias([PointF(0,0), PointF(0,bmp2.Height)],c,1);

  Positioning:=(PaintBox2.Width mod (Trect_.BottomRight.x-1));

end;


procedure TForm1.FormActivate(Sender: TObject);
begin
  Main_Loop();
end;

procedure TForm1.Button1Click(Sender: TObject);
begin
  DisableHCos:= not DisableHCos;
  if DisableHCos then Button1.Caption:='Enable H.Cos';
  if not DisableHCos then Button1.Caption:='Disable H.Cos';
end;

procedure TForm1.Button2Click(Sender: TObject);
begin
  DisableGuideTriangle:= not DisableGuideTriangle;
  if DisableGuideTriangle then Button2.Caption:='Enable Triangle';
  if not DisableGuideTriangle then Button2.Caption:='Disable Triangle';
end;

procedure TForm1.FormClose(Sender: TObject; var CloseAction: TCloseAction);
begin
  Run_:=False;
end;

procedure TForm1.FormDestroy(Sender: TObject);
begin
  timer_.Free;
  Background_.Free;
  bmp.Free;
  bmp2.Free;
  Tem.bmp.Free;
  Tem.SinBmp.Free;
  Tem.CosBmp.Free;
  Tem.TopBmp.Free;
  Tem.TempBmp.Free;
  //FreeAndNil(Tem);
end;

procedure TForm1.FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
begin
  KeyB_.KeyboardDownCounter:=KeyB_.KeyboardDownCounter+1;
end;

procedure TForm1.FormKeyUp(Sender: TObject; var Key: Word; Shift: TShiftState);
begin
  KeyB_.KeyboardUpCounter:=KeyB_.KeyboardUpCounter+1;
end;

procedure TForm1.PaintBox2MouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
  KeyB_.MouseDownCounter:=KeyB_.MouseDownCounter+1;
end;

procedure TForm1.PaintBox2MouseUp(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
  KeyB_.MouseUpCounter:=KeyB_.MouseUpCounter+1;
end;

end.

