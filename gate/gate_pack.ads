with System;

package Gate_Pack is

  Axis_Max : constant Integer := 90;
  Opening_Duration_In_Sec : constant Positive := 8;

  Paused_Counter : Integer := 0 with Atomic;
  Duration_Of_Pause : Integer := 20;

  type State is (Closed, Opened, Closing, Opening, Closing_Paused, Opening_Paused);

  task Gate_Control is
   entry Gate_Control_Start(Pause_Duration : Integer);
  end Gate_Control;

  protected Gate is
    procedure Get_State(S : out State);
    procedure Set_State(S : in State);

    procedure Get_Axis_Right(Right : out Integer);
    procedure Get_Axis_Left(Left : out Integer);
    procedure Set_Axis_Left(Left : in Integer);
    procedure Set_Axis_Right(Right : in Integer);

    procedure Get_Light(L : out Boolean);
    procedure Set_Light(L : in Boolean);

    private
      Gate_State : State := Closed;
      Axis_Right : Integer := 0;
      Axis_Left : Integer := 0;
      Light : Boolean := False;
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
