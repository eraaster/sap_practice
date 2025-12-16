*&---------------------------------------------------------------------*
*& Report ZEDR19_PRACTICE005
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT ZEDR19_PRACTICE005.

PARAMETERS : P_GJAHR TYPE BKPF-GJAHR DEFAULT SY-DATUM+0(4) OBLIGATORY,
             P_MONAT TYPE BKPF-MONAT DEFAULT SY-DATUM+4(2) OBLIGATORY.

DATA : LV_LAST TYPE DATS,
       LV_MSG TYPE CHAR50.

CALL FUNCTION 'ZED19_LASTDAY'
  EXPORTING
    I_GJAHR         = P_GJAHR
    I_MONAT         = P_MONAT

  IMPORTING
    E_LASTDAY = LV_LAST
    E_MESSAGE = LV_MSG.

WRITE :/ LV_MSG.
