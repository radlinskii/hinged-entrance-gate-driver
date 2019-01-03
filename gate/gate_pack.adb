with Ada.Text_IO;
use  Ada.Text_IO;
with Ada.Exceptions;
use Ada.Exceptions;
with Ada.Calendar;
use Ada.Calendar;
with GNAT.Sockets;
use GNAT.Sockets;
with Ada.Environment_Variables;
use Ada.Environment_Variables;

package body Gate_Pack is
  task body Signal_Controller is
  Gate_State : State;
  begin
    loop
      select
        accept Remote_Signal;
        -- Put_Line("Signal_Controller.Remote_Signal");
        Gate.Get_State(Gate_State);
        case Gate_State is
          when Opened =>
            -- Put_Line("Opened state");
            Gate.Set_State(Closing);
            Gate_Controller.Close_Gate;
          when Closed =>
            -- Put_Line("Closed state");
            Gate.Set_State(Opening);
            Gate_Controller.Open_Gate;
          when Closing =>
            -- Put_Line("Closing state");
            Gate.Set_State(Closing_Paused);
            Pause_Gate_Controller.Closing_Paused;
          when Opening =>
            -- Put_Line("Opening state");
            Gate.Set_State(Opening_Paused);
            Pause_Gate_Controller.Opening_Paused;
          when Opening_Paused =>
            -- Put_Line("Paused opening state");
            Gate.Set_State(Closing);
            Gate_Controller.Close_Gate;
          when Closing_Paused =>
            -- Put_Line("Paused closing state");
            Gate.Set_State(Opening);
            Gate_Controller.Open_Gate;
        end case;
      or
        accept Photocell_Signal;
        -- Put_Line("Signal_Controller.Photocell_Signal");
        Gate.Get_State(Gate_State);
        if Gate_State = Closing then
          Gate.Set_State(Opening);
          Gate_Controller.Open_Gate;
        elsif Gate_State = Opened then
          Gate.Set_State(Opened);
          Paused_Counter := Duration_Of_Pause;
        end if;
      end select;
    end loop;
  end Signal_Controller;

  task body Gate_Control is
    Address  : Sock_Addr_Type;
    Server   : Socket_Type;
    Socket   : Socket_Type;
    Channel  : Stream_Access;
    Dane     : Integer := 0;
    Gate_State : State;
  begin
    accept Gate_Control_Start(Pause_Duration : Integer) do
        Duration_Of_Pause := Pause_Duration;
        Paused_Counter := Pause_Duration;
    end Gate_Control_Start;
    -- Put_Line(Duration_Of_Pause'Img);
    Gate.Get_State(Gate_State);
    Address.Addr := Inet_Addr(Value("GATE_IP_ADDRESS"));
    Address.Port := 5876;
    -- Put_Line("Host: "&Host_Name);
    -- Put_Line("Adres:port = ("&Image(Address)&")");
    Create_Socket (Server);
    Set_Socket_Option (Server, Socket_Level, (Reuse_Address, True));
    Bind_Socket (Server, Address);
    Listen_Socket (Server);
    -- Put_Line ( "Kontroler: czekam na Sensor ....");
    loop
      Accept_Socket (Server, Socket, Address);
      Channel := Stream (Socket);
      Dane := Integer'Input (Channel);
      -- Put_Line ("Kontroler: -> dane =" & Dane'Img);
      if Dane = 1 then
        Signal_Controller.Remote_Signal;
      elsif Dane = 0 then
        Signal_Controller.Photocell_Signal;
      end if;
      Close_Socket(Socket);
    end loop;
  exception
    when E:others => Put_Line("Error: Zadanie Gate_Control");
      Put_Line(Exception_Name (E) & ": " & Exception_Message (E));
  end Gate_Control;

  protected body Gate is
    procedure Set_State(S : in State) is
    begin
      Gate_State := S;
      -- Put_Line("new state: " & Gate_State'Img);
    end Set_State;

    procedure Get_State(S : out State) is
    begin
      S := Gate_State;
    end Get_State;

    procedure Get_Axis_Right(Right : out Integer) is
    begin
      Right := Axis_Right;
    end Get_Axis_Right;

    procedure Get_Axis_Left(Left : out Integer) is
    begin
      Left := Axis_Left;
    end Get_Axis_Left;

    procedure Set_Axis_Left(Left : in Integer) is
    begin
     Axis_Left := Left;
    end Set_Axis_Left;

    procedure Set_Axis_Right(Right : in Integer) is
    begin
     Axis_Right := Right;
    end Set_Axis_Right;

    procedure Get_Light(L : out Boolean) is
    begin
      L := Light;
    end Get_Light;

    procedure Set_Light(L : in Boolean) is
    begin
      Light := L;
    end Set_Light;
  end Gate;

  task body Gate_Controller is
    Next : Ada.Calendar.Time;
    Shift : constant Duration := Duration ( Float (Opening_Duration_In_Sec) / Float (Axis_Max)); -- TODO
    Axis_Right : Integer;
    Axis_Left : Integer;
    S : State;
  begin
    loop
      select
        accept Open_Gate;
        Next := Clock + Shift;
        loop
          delay until Next;

          Gate.Get_State(S);
          if S /= Opening then
            Gate.Set_Light(False);
            exit;
          end if;

          Gate.Set_Light(True);
          Gate.Get_Axis_Right(Axis_Right);

          if Axis_Right >= 20 then
            Gate.Get_Axis_Left(Axis_Left);
            if Axis_Left >= Axis_Max then
              Gate.Set_State(Opened);
              Pause_Gate_Controller.Opened_Pause;
              Gate.Set_Light(False);
              exit;
            end if;
            Gate.Set_Axis_Left(Axis_Left + 1);
          end if;
          
          if Axis_Right < Axis_Max then
            Gate.Set_Axis_Right(Axis_Right + 1);
          end if;
          
          Next := Next + Shift;
        end loop;
      or
        accept Close_Gate;
        Next := Clock + Shift;
        loop
          delay until Next;
          
          Gate.Get_State(S);
          if S /= Closing then
            Gate.Set_Light(False);
            exit;
          end if;

          Gate.Set_Light(True);
          Gate.Get_Axis_Left(Axis_Left);
          
          if Axis_Left <= 70 then 
            Gate.Get_Axis_Right(Axis_Right);
            if Axis_Right <= 0 then
              Gate.Set_State(Closed);
              Gate.Set_Light(False);
              exit;
            end if;
            Gate.Set_Axis_Right(Axis_Right - 1);
          end if;
          
          
          if Axis_Left > 0 then
            Gate.Set_Axis_Left(Axis_Left - 1);
          end if;
          Next := Next + Shift;
        end loop;
      end select;
    end loop;
  end Gate_Controller;

  task body Pause_Gate_Controller is
    Next : Ada.Calendar.Time;
    Shift : constant Duration := 1.0; -- TODO
    S : State;
  begin
    loop
      select
        accept Opened_Pause;
        Next := Clock + Shift;
        Paused_Counter := Duration_Of_Pause;
        loop
          delay until Next;
          Gate.Get_State(S);
          -- Put_Line("iter " & Paused_Counter'Img);
          -- Put_Line("state " & S'Img);
          Next := Next + Shift;
          Paused_Counter := Paused_Counter - 1;
          if Paused_Counter <= 0 then
            Gate.Set_State(Closing);
            Gate_Controller.Close_Gate;
            exit;
          elsif S /= Opened then
            exit;
          end if;

        end loop;
      or
        accept Closing_Paused;
        Next := Clock + Shift;
        Paused_Counter := Duration_Of_Pause;
        loop
          delay until Next;
          Gate.Get_State(S);
          -- Put_Line("iter " & Paused_Counter'Img);
          -- Put_Line("state " & S'Img);
          Next := Next + Shift;
          Paused_Counter := Paused_Counter - 1;
          if Paused_Counter <= 0 then
            Gate.Set_State(Closing);
            Gate_Controller.Close_Gate;
            exit;
          elsif S /= Closing_Paused then
            exit;
          end if;
        end loop;
      or
        accept Opening_Paused;
        Next := Clock + Shift;
        Paused_Counter := Duration_Of_Pause;
        loop
          delay until Next;
          Gate.Get_State(S);
          -- Put_Line("iter " & Paused_Counter'Img);
          -- Put_Line("state " & S'Img);
          Next := Next + Shift;
          Paused_Counter := Paused_Counter - 1;
          if Paused_Counter <= 0 then
            Gate.Set_State(Closing);
            Gate_Controller.Close_Gate;
            exit;
          elsif S /= Opening_Paused then
            exit;
          end if;
        end loop;
      end select;
    end loop;
  end Pause_Gate_Controller;

end Gate_Pack;
