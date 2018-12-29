with System;

package Gate_Pack is

  type State is (Closed, Opened, Closing, Opening, Closing_Paused, Opening_Paused);

  task Gate_Control;

  protected Gate is
    procedure Remote_Signal;
    procedure Photocell_Signal;
    procedure Get_State(S : out State);
    procedure Change_Axis(Add : Boolean; Axis : Integer);
    private
      Gate_State : State := Closed;
      Left_Axis : Integer;
      Right_Axis : Integer;
  end Gate;

  task Signal_Controller is
    entry Remote_Signal;
    entry Photocell_Signal;
  end Signal_Controller;

  task Gate_Controller is
    entry Open_Gate;
    entry Close_Gate;
  end Gate_Controller;

end Gate_Pack;
