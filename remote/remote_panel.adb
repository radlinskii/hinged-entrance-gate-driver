with System;
with Remote_Pack; pragma Unreferenced(Remote_Pack);
use Remote_Pack;
with Ada.Text_IO;
use  Ada.Text_IO;

with Ada.Strings;
use Ada.Strings;
with Ada.Strings.Fixed;
use Ada.Strings.Fixed;

procedure Remote_Panel is

  type Atrybuty is (Czysty, Jasny, Podkreslony, Negatyw, Migajacy, Szary);

  protected Screen  is
    procedure Print_XY(X,Y: Positive; S: String; Atryb : Atrybuty := Czysty);
    procedure Clear;
    procedure Background;
  end Screen;

  protected body Screen is
    -- implementacja dla Linuxa i macOSX
    function Atryb_Fun(Atryb : Atrybuty) return String is
      (case Atryb is
       when Jasny => "1m", when Podkreslony => "4m", when Negatyw => "7m",
       when Migajacy => "5m", when Szary => "2m", when Czysty => "0m");

    function Esc_XY(X,Y : Positive) return String is
      ( (ASCII.ESC & "[" & Trim(Y'Img,Both) & ";" & Trim(X'Img,Both) & "H") );

    procedure Print_XY(X,Y: Positive; S: String; Atryb : Atrybuty := Czysty) is
      Before : String := ASCII.ESC & "[" & Atryb_Fun(Atryb);
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
      Screen.Print_XY(1,1,"+=========== Remote Control ===========+");
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
      Remote_Task.Send_Signal;
    elsif Char in 'q'|'Q' then
      exit;
    end if;
  end loop;

  Remote_Task.Quit;
end Remote_Panel;
