with System;
with Photocell_Pack; pragma Unreferenced(Photocell_Pack);
use Photocell_Pack;
with Ada.Text_IO;
use  Ada.Text_IO;

with Ada.Strings;
use Ada.Strings;
with Ada.Strings.Fixed;
use Ada.Strings.Fixed;

procedure Photocell_Panel is

  type Attributes is (Clean);

  protected Screen  is
    procedure Print_XY(X,Y: Positive; S: String; Attribute : Attributes := Clean);
    procedure Clear;
    procedure Background;
  end Screen;

  protected body Screen is
    function Attribute_Fun(Attribute : Attributes) return String is
      (case Attribute is when Clean => "0m");

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
      Screen.Print_XY(1,1,"+=========== Photocell Control ===========+");
      Screen.Print_XY(8,3,"+= Q-quit, S-send signal =+");
    end Background;

  end Screen;


  pragma Priority (System.Priority'First);
  Char : Character;
begin
  Screen.Background;
  loop
    Get_Immediate(Char);
    if Char in 's'|'S' then
      Photocell_Task.Send_Signal;
    elsif Char in 'q'|'Q' then
      exit;
    end if;
  end loop;

  Photocell_Task.Quit;
end Photocell_Panel;
