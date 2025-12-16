*&---------------------------------------------------------------------*
*& Report ZEDR00_PRACTICE008
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT ZEDR19_PRACTICE008 MESSAGE-ID ZMED19.

INCLUDE ZEDR19_PRACTICE008_TOP.
INCLUDE ZEDR19_PRACTICE008_SCR.
INCLUDE ZEDR19_PRACTICE008_F01.
INCLUDE ZEDR19_PRACTICE008_PBO.
INCLUDE ZEDR19_PRACTICE008_PAI.

INITIALIZATION.
  PERFORM SET_DATE.

AT SELECTION-SCREEN OUTPUT.
  PERFORM SET_SCREEN.

START-OF-SELECTION.
  PERFORM CHECK_DATA.
  PERFORM PROGRESS_DISPLAY USING 'Data 조회 중...'. "조회중 메세지 출력

  CASE C_X.
    WHEN P_R1. "주문내역
      PERFORM SELECT_DATA_R1.
      PERFORM MODIFY_DATA_R1.

      IF GT_ORDER[] IS NOT INITIAL.
        CALL SCREEN 100.
      ELSE.
        MESSAGE I001.
        EXIT.
      ENDIF.
    WHEN P_R2. "배송내역
      PERFORM SELECT_DATA_R2.
      PERFORM MODIFY_DATA_R2.
      IF GT_DELIVERY[] IS NOT INITIAL.
        CALL SCREEN 200.
      ELSE.
        MESSAGE I001.
        EXIT.
      ENDIF.
  ENDCASE.
