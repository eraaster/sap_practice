*&---------------------------------------------------------------------*
*&  Include           ZEDR19_PRACTICE008_PBO
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Module  STATUS_0100  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE STATUS_0100 OUTPUT.
  SET PF-STATUS 'STATUS_0100'.
  SET TITLEBAR 'T100'.
ENDMODULE.
*&---------------------------------------------------------------------*
*&      Module  ALV_0100  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE ALV_0100 OUTPUT.
  PERFORM CREATE_OBJECT USING GC_DOCKING GC_GRID_100.
  PERFORM FIELD_CATALOG_0100.
  PERFORM ALV_SORT.
  PERFORM LAYOUT_SET.
  PERFORM CALL_ALV USING GT_0100[]
          GC_GRID_100 GS_LAYOUT GS_VARIANT.
ENDMODULE.
*&---------------------------------------------------------------------*
*&      Module  STATUS_0200  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE STATUS_0200 OUTPUT.
  SET PF-STATUS 'STATUS_0200'.
  SET TITLEBAR 'T200'.
ENDMODULE.
*&---------------------------------------------------------------------*
*&      Module  ALV_0200  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE ALV_0200 OUTPUT.
  PERFORM CREATE_OBJECT USING GC_DOCKING GC_GRID_200.
  PERFORM FIELD_CATALOG_0200.
  PERFORM ALV_SORT.
  PERFORM LAYOUT_SET.
  PERFORM CALL_ALV USING GT_0200[]
                         GC_GRID_200
                         GS_LAYOUT
                         GS_VARIANT.
ENDMODULE.
