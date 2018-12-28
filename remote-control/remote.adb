with System;
with Remote_Pack; pragma Unreferenced(Remote_Pack);
with Ada.Text_IO;
use  Ada.Text_IO;

procedure Remote is
  pragma Priority (System.Priority'First);
begin
  Put_Line("Remote: początek");
  loop
    null;
  end loop;
end Remote;
