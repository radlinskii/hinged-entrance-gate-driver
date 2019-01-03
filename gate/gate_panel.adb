with System;
with Gate_Pack; pragma Unreferenced(Gate_Pack);
use Gate_Pack;
with Ada.Text_IO;
use  Ada.Text_IO;

with Ada.Strings;
use Ada.Strings;
with Ada.Strings.Fixed;
use Ada.Strings.Fixed;

with Ada.Calendar;
use Ada.Calendar;

with Ada.Text_IO, Ada.Integer_Text_IO;

procedure Gate_Panel is

  type Attributes is (Clean, Bright, Underlined, Negative);

  protected Screen  is
    procedure Print_XY(X,Y: Positive; S: String; Attribute : Attributes := Clean);
    procedure Clear;
    procedure Background;
    procedure Configuration;
  end Screen;

  protected body Screen is
    function Attribute_Fun(Attribute : Attributes) return String is
      (case Attribute is when Bright => "1m", when Underlined => "4m", when Negative => "7m", when Clean => "0m");

    function Esc_XY(X,Y : Positive) return String is
      ( (ASCII.ESC & "[" & Trim(Y'Img,Both) & ";" & Trim(X'Img,Both) & "H") );

    procedure Print_XY(X,Y: Positive; S: String; Attribute : Attributes := Clean) is
      Before : String := ASCII.ESC & "[" & Attribute_Fun(Attribute);
    begin
      Put( Before);
      Put( Esc_XY(X,Y) & S);
      Put( ASCII.ESC & "[0m");
    end Print_XY;

    procedure Clear is
    begin
      Put(ASCII.ESC & "[2J");
    end Clear;

    procedure Background is
    begin
      Screen.Clear;
      Screen.Print_XY(1,1,"+=========== The Gate ===========+");
      Screen.Print_XY(10, 3, "State: ");
      Screen.Print_XY(1, 5, "Left Axis: ");
      Screen.Print_XY(16, 5, "Right Axis: ");
      Screen.Print_XY(10, 7, "Light: ");
      Screen.Print_XY(10, 9, "Timeout: ");
    end Background;

    procedure Configuration is
    begin
      Screen.Clear;
      Screen.Print_XY(1,1,"+=========== Configure your gate ===========+");
      Screen.Print_XY(3, 3, "How much time for pause (seconds): ");
    end Configuration;

  end Screen;

  pragma Priority (System.Priority'First);
  S : State;
  Next : Ada.Calendar.Time;
  Shift : constant Duration := 0.25;
  Pause_Time : Integer;
  Axis_Right : Integer;
  Axis_Left : Integer;
  Is_Light_On : Boolean := False;
begin
  Screen.Configuration;
  Ada.Integer_Text_IO.Get(Pause_Time);
  Gate_Control.Gate_Control_Start(Pause_Time);
  loop
    Screen.Background;
    Gate.Get_State(S);
    Gate.Get_Axis_Right(Axis_Right);
    Gate.Get_Axis_Left(Axis_Left);
    Gate.Get_Light(Is_Light_On);
    Screen.Print_XY(17, 3, S'Img, Attribute=>Negative);
    Screen.Print_XY(11, 5, Axis_Left'Img, Attribute=>Bright);
    Screen.Print_XY(27, 5, Axis_Right'Img, Attribute=>Bright);
    if Is_Light_On then
      Screen.Print_XY(17, 7, "On", Attribute=>Bright);
    else
      Screen.Print_XY(17, 7, "Off", Attribute=>Bright);
    end if;
    Screen.Print_XY(20, 9, Gate_Pack.Paused_Counter'Img, Attribute=>Underlined);
    Next := Clock + Shift;
    delay until Next;
  end loop;
end Gate_Panel;
