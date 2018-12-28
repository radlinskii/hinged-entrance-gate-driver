with Ada.Text_IO;
use  Ada.Text_IO;
with Ada.Exceptions;
use Ada.Exceptions;
with GNAT.Sockets; use GNAT.Sockets;

package body Gate_Pack is

  task body Signal_Controller is
  begin
      loop
        select
          accept Remote_Signal;
          Put_Line("Remote");
        or 
          accept Photocell_Signal;
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
    --Address.Addr := Addresses (Get_Host_By_Name (Host_Name), 1);
    --Address.Addr := Addresses (Get_Host_By_Address(Inet_Addr("10.0.0.1")),1);
    Address.Addr := Inet_Addr("192.168.8.113");
    --Address.Addr := Addresses (Get_Host_By_Name ("imac.local"), 1);
    --Address.Addr := Addresses (Get_Host_By_Name ("localhost"), 1);
    Address.Port := 5876;
    Put_Line("Host: "&Host_Name);
    Put_Line("Adres:port = ("&Image(Address)&")");
    Create_Socket (Server);
    Set_Socket_Option (Server, Socket_Level, (Reuse_Address, True));
    Bind_Socket (Server, Address);
    Listen_Socket (Server);  -- czekamy na sockecie
    Put_Line ( "Kontroler: czekam na Sensor ....");
    loop
      Accept_Socket (Server, Socket, Address);
      Channel := Stream (Socket); -- uchwyt do kanalu 
      Dane := Integer'Input (Channel);
      Put_Line ("Kontroler: -> dane =" & Dane'Img);
      --  Komunikat do: Sensor
      String'Output (Channel, "OK: " & Dane'Img);
      if Dane = 1 then
        Signal_Controller.Remote_Signal;
      end if;
      Close_Socket(Socket);
    end loop;
  exception
    when E:others => Put_Line("Error: Zadanie Gate_Control");
      Put_Line(Exception_Name (E) & ": " & Exception_Message (E));
  end Gate_Control;

  protected body Gate is
    procedure Remote_Signal is 
    begin
      Put_Line("Remote");
    end Remote_Signal;

    procedure Photocell_Signal is
    begin
      Put_Line("Photocell");
    end Photocell_Signal;

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
end Gate_Pack;
