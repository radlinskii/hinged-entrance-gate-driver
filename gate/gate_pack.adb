-- kontroler_pak.adb
-- materiały dydaktyczne
-- 2016
-- (c) Jacek Piwowarczyk

with Ada.Text_IO;
use  Ada.Text_IO;
with Ada.Exceptions;
use Ada.Exceptions;
with GNAT.Sockets; use GNAT.Sockets;

package body Gate_Pack is

  task body Gate_Control is
    Address  : Sock_Addr_Type;
    Server   : Socket_Type;
    Socket   : Socket_Type;
    Channel  : Stream_Access;
    Dane     : Float := 0.0;
  begin
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
      Dane := Float'Input (Channel);
      Put_Line ("Kontroler: -> dane =" & Dane'Img);
      --  Komunikat do: Sensor
      String'Output (Channel, "OK: " & Dane'Img);
      -- wywolac entry ????
      Close_Socket(Socket);
    end loop;
  exception
    when E:others => Put_Line("Error: Zadanie Gate_Control");
      Put_Line(Exception_Name (E) & ": " & Exception_Message (E));
  end Gate_Control;

end Gate_Pack;
