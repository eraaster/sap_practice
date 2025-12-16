*&---------------------------------------------------------------------*
*& Report  ZEDR00_PRACTICE004_VIEW
*&  - SSU-90~SSU-99 조회만 하고, ZPERNR 10자리(0패딩)로 목록 출력(WRITE)
*&---------------------------------------------------------------------*
REPORT zedr19_practice004.

PARAMETERS : P_LOW TYPE ZEDT19_0001-ZCODE DEFAULT 'SSU-90',
             P_HIGH TYPE ZEDT19_0001-ZCODE DEFAULT 'SSU-99',
             P_COMMIT TYPE c AS CHECKBOX DEFAULT 'X'.

DATA : LV_SEL TYPE I,
       LV_UPD TYPE I,
       LV_MSG TYPE STRING,
       LV_COMMIT TYPE ABAP_BOOL.

DATA : LT_TGT TYPE STANDARD TABLE OF ZEDT19_0001,
       LS_TGT TYPE ZEDT19_0001.

lv_commit = COND abap_bool( WHEN p_commit = 'X' THEN abap_true ELSE abap_false ).

CALL FUNCTION 'ZED19_ZPERNR'
  EXPORTING
   I_LOW_CODE          = 'SSU-90'
   I_HIGH_CODE         = 'SSU-99'
   I_COMMIT            = LV_COMMIT
 IMPORTING
   E_CNT_SEL           = LV_SEL
   E_CNT_UPD           = LV_UPD
   E_MESSAGE           = LV_MSG

 TABLES T_ZEDT19_0001 = LT_TGT
 CHANGING P_ZEDT19_0001 = LS_TGT.

WRITE :/ |Selected={ LV_SEL } Updated={ LV_UPD }|.
IF LV_MSG IS NOT INITIAL.
  WRITE :/ LV_MSG.
ENDIF.
