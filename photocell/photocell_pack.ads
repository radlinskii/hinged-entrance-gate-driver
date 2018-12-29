with System;

package Photocell_Pack is

  task Photocell_Task is
    pragma Priority(System.Default_Priority);
    entry  Send_Signal;
    entry Quit;
  end Photocell_Task;

end Photocell_Pack;
