with System;

package Gate_Pack is

  Axis_Max : constant Integer := 90;
  Opening_Duration_In_Sec : constant Positive := 8;

  Timeout : Integer := 0 with Atomic;
  Timeout_Duration : Integer := 20;

  type State is (Closed, Opened, Closing, Opening, Closing_Paused, Opening_Paused);

  task Gate_Controller is
   entry Start(Timeout_Duration_Input : Integer);
  end Gate_Controller;

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

  task Signal_Handler is
    entry Remote;
    entry Photocell;
  end Signal_Handler;

  task Axis_Handler is
    entry Open_Gate;
    entry Close_Gate;
  end Axis_Handler;

  task Timeout_Handler is
    entry Wait_On_Opened;
    entry Wait_On_Closing_Paused;
    entry Wait_On_Opening_Paused;
  end Timeout_Handler;

end Gate_Pack;
