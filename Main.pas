unit Main;

interface //#################################################################### ■

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs,
  System.Threading,
  FMX.Objects,
  LUX, LUX.D2, LUX.Lattice.T2.D1, LUX.FMX, FMX.StdCtrls,
  FMX.Controls.Presentation;

type
  TForm1 = class(TForm)
    Image1: TImage;
    Panel1: TPanel;
      Button1: TButton;
      GroupBox1: TGroupBox;
        Timer1: TTimer;
        Button2: TButton;
        Button3: TButton;
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure Image1Paint(Sender: TObject; Canvas: TCanvas; const ARect: TRectF);
    procedure Image1MouseDown(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Single);
    procedure Image1MouseMove(Sender: TObject; Shift: TShiftState; X, Y: Single);
    procedure Image1MouseUp(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Single);
    procedure Button1Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure Button3Click(Sender: TObject);
    procedure Timer1Timer(Sender: TObject);
  private
    { private 宣言 }
    _MouseS :TShiftState;
    _MouseP :TPointF;
    _Poins  :TArray2<TSingle2D>;
    ///// メソッド
    function ScrToTex( const S_:TPointF ) :TSingle2D;
    function TexToScr( const T_:TSingle2D ) :TPointF;
  public
    { public 宣言 }
    _Potent :TSingleGridMap2T;
    _DivX   :Integer;
    _DivY   :Integer;
    ///// メソッド
    procedure DrawPotent;
    procedure DrawVector( const Canvas_:TCanvas; const T_:TSingle2D; const Scale_:Single = 1 );
    procedure DrawVectors( const Canvas_:TCanvas );
    procedure MakePoins;
    procedure MakePotent;
  end;

var
  Form1: TForm1;

implementation //############################################################### ■

{$R *.fmx}

//&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&& private

/////////////////////////////////////////////////////////////////////// メソッド

function TForm1.ScrToTex( const S_:TPointF ) :TSingle2D;
begin
     Result.X := S_.X / Image1.Width  * _Potent.BricX;
     Result.Y := S_.Y / Image1.Height * _Potent.BricY;
end;

function TForm1.TexToScr( const T_:TSingle2D ) :TPointF;
begin
     Result.X := T_.X / _Potent.BricX * Image1.Width ;
     Result.Y := T_.Y / _Potent.BricY * Image1.Height;
end;

//&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&& public

/////////////////////////////////////////////////////////////////////// メソッド

procedure TForm1.DrawPotent;
var
   B :TBitmapData;
begin
     Image1.Bitmap.Map( TMapAccess.Write, B );

     TParallel.For( 0, B.Height-1, procedure( Y:Integer )
     var
        P :TSingle2D;
        X :Integer;
        C :PAlphaColor;
     begin
          C := B.GetScanline( Y );

          P.Y := ( Y + 0.5 ) / B.Height * _Potent.BricY;

          for X := 0 to B.Width-1 do
          begin
               P.X := ( X + 0.5 ) / B.Width * _Potent.BricX;

               C^ := $FF000000 + $00010101 * Round( Clamp( _Potent.Interp( P ), 0, 1 ) * 255 );

               Inc( C );
          end;
     end,
     _ThreadPool_ );

     Image1.Bitmap.Unmap( B );
end;

procedure TForm1.DrawVector( const Canvas_:TCanvas; const T_:TSingle2D; const Scale_:Single = 1 );
var
   S0, S1 :TPointF;
begin
     S0 := TexToScr( T_                                );
     S1 := TexToScr( T_ + Scale_ * _Potent.Nabla( T_ ) );

     with Canvas_ do
     begin
          with Fill do
          begin
               Kind      := TBrushKind.Solid;
               Color     := TAlphaColors.Red;
          end;

          FillCircle( S0, Scale_ * 2, 1 );

          with Stroke do
          begin
               Kind      := TBrushKind.Solid;
               Cap       := TStrokeCap.Round;
               Thickness := Scale_;
               Color     := TAlphaColors.Yellow;
          end;

          DrawLine( S0, S1, 1 );
     end;
end;

procedure TForm1.DrawVectors( const Canvas_:TCanvas );
var
   X, Y :Integer;
begin
     for Y := 0 to _DivY-1 do
     begin
          for X := 0 to _DivX-1 do DrawVector( Canvas_, _Poins[ Y, X ] );
     end;
end;

//------------------------------------------------------------------------------

procedure TForm1.MakePoins;
var
   X, Y :Integer;
   T :TSingle2D;
begin
     SetLength( _Poins, _DivY, _DivX );

     for Y := 0 to _DivY-1 do
     begin
          T.Y := ( Y + 0.5 ) / _DivY * _Potent.BricY;

          for X := 0 to _DivX-1 do
          begin
               T.X := ( X + 0.5 ) / _DivX * _Potent.BricX;

               _Poins[ Y, X ] := T;
          end;
     end;
end;

procedure TForm1.MakePotent;
var
   X, Y :Integer;
begin
     with _Potent do
     begin
          for Y := 0 to BricY do
          begin
               for X := 0 to BricX do
               begin
                    Grid[ X, Y ] := Random;
               end;
          end;
     end;
end;

//&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&

procedure TForm1.FormCreate(Sender: TObject);
begin
     _MouseS := [];

     _Potent := TSingleGridMap2T.Create( 20, 15 );

     Image1.Bitmap.SetSize( 800, 600 );

     _DivX := 40;
     _DivY := 30;

     Button1Click( Sender );
end;

procedure TForm1.FormDestroy(Sender: TObject);
begin
     _Potent.Free;
end;

////////////////////////////////////////////////////////////////////////////////

procedure TForm1.Image1Paint(Sender: TObject; Canvas: TCanvas; const ARect: TRectF);
begin
     DrawVectors( Canvas );

     if ssLeft in _MouseS then DrawVector( Canvas, ScrToTex( _MouseP ), 5 );
end;

//------------------------------------------------------------------------------

procedure TForm1.Image1MouseDown(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Single);
begin
     _MouseS := Shift;
     _MouseP := TPointF.Create( X, Y );

     Image1.Repaint;
end;

procedure TForm1.Image1MouseMove(Sender: TObject; Shift: TShiftState; X, Y: Single);
begin
     if ssLeft in _MouseS then
     begin
          _MouseP := TPointF.Create( X, Y );

          Image1.Repaint;
     end;
end;

procedure TForm1.Image1MouseUp(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Single);
begin
     Image1MouseMove( Sender, Shift, X, Y );

     _MouseS := [];
end;

//------------------------------------------------------------------------------

procedure TForm1.Button1Click(Sender: TObject);
begin
     MakePotent;

     MakePoins;

     DrawPotent;

     Image1.Repaint;
end;

//------------------------------------------------------------------------------

procedure TForm1.Timer1Timer(Sender: TObject);
begin
     TParallel.For( 0, _DivY-1, procedure( Y:Integer )
     var
        X :Integer;
     begin
          for X := 0 to _DivX-1 do _Poins[ Y, X ] := _Poins[ Y, X ] + 0.1 * _Potent.Nabla( _Poins[ Y, X ] );
     end,
     _ThreadPool_ );

     Image1.Repaint;
end;

procedure TForm1.Button2Click(Sender: TObject);
begin
     Button2.Enabled := False;
     Button3.Enabled := True ;

     Timer1.Enabled := True ;
end;

procedure TForm1.Button3Click(Sender: TObject);
begin
     Timer1.Enabled := False;

     Button2.Enabled := True ;
     Button3.Enabled := False;
end;

end. //######################################################################### ■
