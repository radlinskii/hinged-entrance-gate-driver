with Ada.Text_IO;
use  Ada.Text_IO;
with Ada.Exceptions;
use Ada.Exceptions;
with GNAT.Sockets;
use GNAT.Sockets;
with Ada.Calendar;
use Ada.Calendar;
with Ada.Environment_Variables;
use Ada.Environment_Variables;

package body Photocell_Pack is

  task body Photocell_Task is
    Address : Sock_Addr_Type;
    Socket  : Socket_Type;
    Channel : Stream_Access;
  begin
    Address.Addr := Inet_Addr(Value("GATE_IP_ADDRESS"));
    Address.Port := 5876;
    loop
      select
        accept Send_Signal;
        Create_Socket (Socket);
        Set_Socket_Option (Socket, Socket_Level, (Reuse_Address, True));
        Connect_Socket (Socket, Address);
        Channel := Stream (Socket);
        Integer'Output (Channel, 0);
        Close_Socket(Socket);
      or
        accept Quit;
        exit;
      end select;
    end loop;
  exception
    when E:others =>
      Close_Socket (Socket);
      Put_Line("Error: Task Photocell");
      Put_Line(Exception_Name (E) & ": " & Exception_Message (E));
  end Photocell_Task;

end Photocell_Pack;
