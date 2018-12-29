with System;

package Gate_Pack is

  Axis_Max : Natural := 90;

  Paused_Counter : Integer := 10 with Atomic; -- TODO

  Opening_Duration_In_Sec : Natural := 8;

  type State is (Closed, Opened, Closing, Opening, Closing_Paused, Opening_Paused);

  task Gate_Control;

  protected Gate is
    procedure Get_State(S : out State);
    procedure Set_State(S : in State);

    procedure Get_Axis(A : out Integer);
    procedure Set_Axis(A : in Integer);

    private
      Gate_State : State := Closed;
      Axis : Natural := 0;
  end Gate;

  task Signal_Controller is
    entry Remote_Signal;
    entry Photocell_Signal;
  end Signal_Controller;

  task Gate_Controller is
    entry Open_Gate;
    entry Close_Gate;
  end Gate_Controller;

  task Pause_Gate_Controller is
    entry Opened_Pause;
    entry Closing_Paused;
    entry Opening_Paused;
  end Pause_Gate_Controller;

end Gate_Pack;
