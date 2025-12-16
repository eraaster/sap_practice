*&---------------------------------------------------------------------*
*&  Include           ZEDR19_PRACTICE009_PAI
*&---------------------------------------------------------------------*
MODULE EXIT_COMMAND INPUT.
  CALL METHOD CL_GUI_CFW=>dispatch.
  CASE OK_CODE.
    WHEN 'BACK' OR 'CANC'.
      LEAVE TO SCREEN 0.
    WHEN 'EXIT'.
      LEAVE PROGRAM.
    ENDCASE.
ENDMODULE.
