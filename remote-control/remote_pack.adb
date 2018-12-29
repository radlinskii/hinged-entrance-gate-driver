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

  task body Remote_Task is
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
    loop
      select 
        accept Send_Signal;
        Create_Socket (Socket);
        Set_Socket_Option (Socket, Socket_Level, (Reuse_Address, True));
        Connect_Socket (Socket, Address);
        Channel := Stream (Socket);
        Integer'Output (Channel, 1 );
        Close_Socket(Socket);
      or 
        accept Quit;
        exit;
      end select;
    end loop;
  exception
    when E:others =>
      Close_Socket (Socket);
      Put_Line("Error: Zadanie Sensor");
      Put_Line(Exception_Name (E) & ": " & Exception_Message (E));
  end Remote_Task;

end Remote_Pack;
