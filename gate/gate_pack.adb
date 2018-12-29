with Ada.Text_IO;
use  Ada.Text_IO;
with Ada.Exceptions;
use Ada.Exceptions;
with Ada.Calendar;
use Ada.Calendar;
with GNAT.Sockets;
use GNAT.Sockets;

package body Gate_Pack is

  Paused_Counter : Integer := 10 with Atomic;

  task body Signal_Controller is
  Gate_State : State;
  begin
      loop
        select
          accept Remote_Signal;
          Gate.Get_State(Gate_State);
          Put_Line("Signal_Controller.Remote_Signal");
          case Gate_State is
            when Opened =>
              Put_Line("Opened state");
              Gate.Set_State(Closing); 
              Gate_Controller.Close_Gate;
            when Closed =>
              Put_Line("Closed state");
              Gate.Set_State(Opening);
              Gate_Controller.Open_Gate;
            when Closing =>
              Put_Line("Closing state");
              Gate.Set_State(Closing_Paused);
              Pause_Gate_Controller.Closing_Paused;
            when Opening =>
              Put_Line("Opening state");
              Gate.Set_State(Opening_Paused);
              Pause_Gate_Controller.Opening_Paused;
            when Opening_Paused =>
              Put_Line("Paused opening state");
              Gate.Set_State(Closing);
              Gate_Controller.Close_Gate;
            when Closing_Paused =>
              Put_Line("Paused closing state");
              Gate.Set_State(Opening);
              Gate_Controller.Open_Gate;
          end case;
        or
          accept Photocell_Signal;
          Gate.Get_State(Gate_State);
          if Gate_State = Closing then
            Gate.Set_State(Opening);
            Gate_Controller.Open_Gate;
          elsif Gate_State = Opened then
            Gate.Set_State(Opened);
            Paused_Counter := 10; -- TODO: change to a variable
          end if;
          Put_Line("Photocell");
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
    Gate.Get_State(Gate_State);
    Address.Addr := Inet_Addr("192.168.8.113");
    Address.Port := 5876;
    Put_Line("Host: "&Host_Name);
    Put_Line("Adres:port = ("&Image(Address)&")");
    Create_Socket (Server);
    Set_Socket_Option (Server, Socket_Level, (Reuse_Address, True));
    Bind_Socket (Server, Address);
    Listen_Socket (Server);
    Put_Line ( "Kontroler: czekam na Sensor ....");
    loop
      Accept_Socket (Server, Socket, Address);
      Channel := Stream (Socket);
      Dane := Integer'Input (Channel);
      Put_Line ("Kontroler: -> dane =" & Dane'Img);
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
      Put_Line(Gate_State'Img);
    end Set_State;

    procedure Get_State(S : out State) is
    begin
      S := Gate_State;
    end Get_State;

    procedure Change_Axis(Add : Boolean; Axis : Integer) is
    begin
      if Add then
        Left_Axis := Left_Axis + Axis;
      else
        Left_Axis := Left_Axis - Axis;
      end if;
    end Change_Axis;
  end Gate;

  task body Gate_Controller is
    Next : Ada.Calendar.Time;
    Shift : constant Duration := 0.5;
    Iter : Integer := 10; -- 5 seconds - TODO: set it to variable
    S : State;
    begin
      loop
        select
          accept Open_Gate;
          Next := Clock + Shift;
          loop
            delay until Next;
            -- Put_Line("I otwiera");
            Put_Line("iter " & Iter'Img);
            Gate.Get_State(S);
            Put_Line("state " & S'Img);
            Next := Next + Shift;
            Iter := Iter - 1;
            if Iter <= 0 then
              Gate.Set_State(Opened);
              Pause_Gate_Controller.Opened_Pause;
              exit;
            elsif S = Opening_Paused then
              exit;
            end if;
          end loop;
        or
         accept Close_Gate;
          Next := Clock + Shift;
          loop
            delay until Next;
            Put_Line("iter " & Iter'Img);
            Gate.Get_State(S);
            Put_Line("state " & S'Img);
            Next := Next + Shift;
            Iter := Iter + 1;
            if Iter >= 10 then -- gate closed
              Gate.Set_State(Closed);
              exit;
            elsif S = Closing_Paused or S = Opening then
              exit;
            end if;
          end loop;
        end select;
      end loop;
  end Gate_Controller;

  task body Pause_Gate_Controller is
  Next : Ada.Calendar.Time;
  Shift : constant Duration := 0.5;
  Duration_Of_Pause : Integer := 10; -- todo make this a parameter of the task
  S : State;
  begin
    loop
    select
      accept Opened_Pause;
      Put_Line("Opened Pause");
      Next := Clock + Shift;
      Paused_Counter := Duration_Of_Pause;
      loop
        delay until Next;
        Gate.Get_State(S);
        Put_Line("iter " & Paused_Counter'Img);
        Put_Line("state " & S'Img);
        Next := Next + Shift;
        Paused_Counter := Paused_Counter - 1;
        if Paused_Counter <= 0 then -- time's up time to close again
          Put_Line("set state Closing");
          Gate.Set_State(Closing);
          Gate_Controller.Close_Gate;
          exit;
        end if;
      end loop;
    or
      accept Closing_Paused;
          Put_Line("Closing Paused");
          Next := Clock + Shift;
          Paused_Counter := Duration_Of_Pause;
          loop
            delay until Next;
            Gate.Get_State(S);
            Put_Line("iter " & Paused_Counter'Img);
            Put_Line("state " & S'Img);
            Next := Next + Shift;
            Paused_Counter := Paused_Counter - 1;
            if Paused_Counter <= 0 then -- time's up time to close again
              Gate.Set_State(Closing);
              Gate_Controller.Close_Gate;
              exit;
            elsif S = Opening then
              exit;
            end if;
          end loop;
      or 
        accept Opening_Paused;
          Put_Line("Opening Paused");
          Next := Clock + Shift;
          Paused_Counter := Duration_Of_Pause;
          loop
            delay until Next;
            Gate.Get_State(S);
            Put_Line("iter " & Paused_Counter'Img);
            Put_Line("state " & S'Img);
            Next := Next + Shift;
            Paused_Counter := Paused_Counter - 1;
            if Paused_Counter <= 0 or S = Closing then -- time's up time to close again
              Put_Line("set state Closing");
              Gate.Set_State(Closing);
              Gate_Controller.Close_Gate;
              exit;
            end if;
          end loop;
        end select;
      end loop;
  end Pause_Gate_Controller;


end Gate_Pack;
