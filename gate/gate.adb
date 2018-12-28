with System;
with Gate_Pack; pragma Unreferenced(Gate_Pack);
with Ada.Text_IO;
use  Ada.Text_IO;

procedure Gate is
  pragma Priority (System.Priority'First);
begin
  Put_Line("Brama: początek");
  loop
    null;
  end loop;
end Gate;