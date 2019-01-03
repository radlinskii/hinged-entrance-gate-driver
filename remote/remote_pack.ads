with System;

package Remote_Pack is

  task Remote_Task is
    pragma Priority(System.Default_Priority);
    entry  Send_Signal;
    entry Quit;
  end Remote_Task;

end Remote_Pack;
