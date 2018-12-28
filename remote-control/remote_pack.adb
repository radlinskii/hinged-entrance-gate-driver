with Ada.Text_IO;
use  Ada.Text_IO;
with Ada.Numerics.Float_Random;
use Ada.Numerics.Float_Random;
with Ada.Exceptions;
use Ada.Exceptions;
with GNAT.Sockets; use GNAT.Sockets;
with Ada.Calendar;
use Ada.Calendar;

package body Remote_Pack is

  task body Remote is
    Nastepny : Time;
    Okres   : constant Duration := 1.2;
    G       : Generator;
    Address : Sock_Addr_Type;
    Socket  : Socket_Type;
    Channel : Stream_Access;
  begin
    Reset(G);
    Nastepny := Clock;
    Address.Addr := Inet_Addr("192.168.8.113");
    Address.Port := 5876;
    Put_Line("Host: "&Host_Name);
    Put_Line("Adres:port => ("&Image(Address)&")");
    Create_Socket (Socket);
    Set_Socket_Option (Socket, Socket_Level, (Reuse_Address, True));
    Connect_Socket (Socket, Address);
    loop
      Put_Line("Sensor: czekam okres ...");
      delay until Nastepny;
      Channel := Stream (Socket);
      Put_Line("Sensor: -> wysyłam dane ...");
      Float'Output (Channel, Random(G) );
      Put_Line ("Sensor: <-" & String'Input (Channel));
      Nastepny := Nastepny + Okres;
    end loop;
  exception
    when E:others =>
      Close_Socket (Socket);
      Put_Line("Error: Zadanie Sensor");
      Put_Line(Exception_Name (E) & ": " & Exception_Message (E));
  end Remote;

end Remote_Pack;
