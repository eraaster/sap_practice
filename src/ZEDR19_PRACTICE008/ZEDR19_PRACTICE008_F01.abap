*&---------------------------------------------------------------------*
*&  Include           ZEDR19_PRACTICE008_F01
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Form  SET_DATE
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM SET_DATE .
  IF S_ZJDATE[] IS INITIAL.
    S_ZJDATE-LOW = SY-DATUM(6) && '01'.
    S_ZJDATE-HIGH = SY-DATUM(6) && '01'.
    S_ZJDATE-SIGN = 'I'.
    S_ZJDATE-OPTION = 'BT'.

    CALL FUNCTION 'LAST_DAY_OF_MONTHS'
      EXPORTING
        DAY_IN            = S_ZJDATE-HIGH
      IMPORTING
        LAST_DAY_OF_MONTH = S_ZJDATE-HIGH.

    APPEND S_ZJDATE.
  ENDIF.

  IF S_ZDDATE[] IS INITIAL.
    S_ZDDATE-LOW = SY-DATUM(6) && '01'.
    S_ZDDATE-HIGH = SY-DATUM(6) && '01'.
    S_ZDDATE-SIGN = 'I'.
    S_ZDDATE-OPTION = 'BT'.

    CALL FUNCTION 'LAST_DAY_OF_MONTHS'
      EXPORTING
        DAY_IN            = S_ZDDATE-HIGH
      IMPORTING
        LAST_DAY_OF_MONTH = S_ZDDATE-HIGH.

    APPEND S_ZDDATE.
  ENDIF.
ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  SET_SCREEN
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM SET_SCREEN .
  LOOP AT SCREEN.
    IF SCREEN-GROUP1 = 'M2'.
      IF P_R1 = 'X'.
        SCREEN-ACTIVE = '0'.
      ELSEIF P_R2 = 'X'.
        SCREEN-ACTIVE = '1'.
      ENDIF.
    ELSEIF SCREEN-GROUP1 = 'M1'.
      IF P_R1 = 'X'.
        SCREEN-ACTIVE = '1'.
      ELSEIF P_R2 = 'X'.
        SCREEN-ACTIVE = '0'.
      ENDIF.
    ENDIF.
    MODIFY SCREEN.
  ENDLOOP.
ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  CHECK_DATA
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM CHECK_DATA .
  "조회조건 점검
  IF P_R1 = C_X.
    IF S_ZJDATE IS INITIAL.
      IF S_ZORDNO IS INITIAL.
        MESSAGE I000.
        STOP.
      ENDIF.
    ENDIF.
  ELSEIF P_R2 = C_X.
    IF S_ZDDATE IS INITIAL.
      IF S_ZORDNO IS INITIAL.
        MESSAGE I000.
        STOP.
      ENDIF.
    ENDIF.
  ENDIF.

  "체크박스 확인
  IF P_R1 = C_X.
    R_FG-SIGN = 'I'.
    R_FG-OPTION = 'EQ'.
    R_FG-LOW = '1'.
    APPEND R_FG.

    IF P_CH1 = C_X.
      R_FG-LOW = '2'.
      APPEND R_FG.
    ENDIF.
  ELSEIF P_R2 = C_X.
    R_ZG-SIGN = 'I'.
    R_ZG-OPTION = 'EQ'.
    R_ZG-LOW = ' '.
    APPEND R_ZG.

    IF P_CH1 = C_X.
      R_ZG-LOW = C_X.
      APPEND R_ZG.
    ENDIF.
  ENDIF.
ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  PROGRESS_DISPLAY
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_0029   text
*----------------------------------------------------------------------*
FORM PROGRESS_DISPLAY  USING P_TEXT.
  CHECK P_TEXT <> ''.

  CALL FUNCTION 'SAPGUI_PROGRESS_INDICATOR'
    EXPORTING
      TEXT = P_TEXT.
ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  SELECT_DATA_R1
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM SELECT_DATA_R1 .
  SELECT * FROM ZEDT00_100
    INTO CORRESPONDING FIELDS OF TABLE GT_ORDER
    WHERE ZORDNO IN S_ZORDNO
    AND ZIDCODE IN S_ZID
    AND ZMATNR IN S_ZMATNR
    AND ZJDATE IN S_ZJDATE
    AND ZSALE_FG IN R_FG.
ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  MODIFY_DATA_R1
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM MODIFY_DATA_R1 .
  CLEAR : GS_ORDER, GS_0100.

  LOOP AT GT_ORDER INTO GS_ORDER.
    MOVE-CORRESPONDING GS_ORDER TO GS_0100.

    PERFORM ZMTART_NAME USING GS_ORDER-ZMTART
                        CHANGING GS_0100-ZMAT_NAME.  "제품유형명

    PERFORM ZSALE_NAME USING GS_ORDER-ZSALE_FG
                       CHANGING GS_0100-ZSALE_NAME. "매출구분명

    IF P_CH1 = C_X.
      PERFORM ZRET_NAME USING GS_ORDER-ZRET_FG
                        CHANGING GS_0100-ZRET_NAME.  "반품구분명
    ENDIF.

    APPEND GS_0100 TO GT_0100.
    CLEAR : GS_ORDER, GS_0100.
  ENDLOOP.
ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  SELECT_DATA_R2
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM SELECT_DATA_R2 .
  SELECT * FROM ZEDT00_101
    INTO CORRESPONDING FIELDS OF TABLE GT_DELIVERY
    WHERE ZORDNO IN S_ZORDNO
    AND ZIDCODE IN S_ZID
    AND ZMATNR IN S_ZMATNR
    AND ZDDATE IN S_ZDDATE
    AND ZFLAG IN R_ZG.
ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  MODIFY_DATA_R2
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM MODIFY_DATA_R2 .
  CLEAR : GS_DELIVERY, GS_0200.

  LOOP AT GT_DELIVERY INTO GS_DELIVERY.
    MOVE-CORRESPONDING GS_DELIVERY TO GS_0200.

    PERFORM ZMTART_NAME USING GS_DELIVERY-ZMTART
                        CHANGING GS_0200-ZMAT_NAME.  "제품유형명

    PERFORM ZDFLAG_NAME USING GS_DELIVERY-ZDFLAG
                        CHANGING GS_0200-ZDFLAG_NAME.

    PERFORM ICON USING GS_DELIVERY-ZFLAG
                 CHANGING GS_0200-ICON.

    PERFORM ZDGUBUN_NAME USING GS_DELIVERY-ZDGUBUN
                        CHANGING GS_0200-ZDGUBUN_NAME.  "배송지역명

    APPEND GS_0200 TO GT_0200.
    CLEAR : GS_DELIVERY , GS_0200.
  ENDLOOP.
ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  CREATE_OBJECT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_GC_DOCKING  text
*      -->P_GC_GRID_100  text
*----------------------------------------------------------------------*
FORM CREATE_OBJECT  USING P_DOCKING TYPE REF TO CL_GUI_DOCKING_CONTAINER
                          P_GRID TYPE REF TO CL_GUI_ALV_GRID.
  CREATE OBJECT P_DOCKING
  EXPORTING
*     PARENT    =
      REPID     = SY-REPID
      DYNNR     = SY-DYNNR
*     SIDE      = DOCK_AT_LEFT
      EXTENSION = 2000
*     STYLE     =
*     LIFETIME  = lifetime_default
*     CAPTION   =
*     METRIC    = 0
*     RATIO     =
*     NO_AUTODEF_PROGID_DYNNR     =
*     NAME      =
*   EXCEPTIONS
*     CNTL_ERROR                  = 1
*     CNTL_SYSTEM_ERROR           = 2
*     CREATE_ERROR                = 3
*     LIFETIME_ERROR              = 4
*     LIFETIME_DYNPRO_DYNPRO_LINK = 5
*     OTHERS    = 6
    .

  CREATE OBJECT P_GRID
    EXPORTING
*     I_SHELLSTYLE      = 0
*     I_LIFETIME        =
      I_PARENT = P_DOCKING
*     I_APPL_EVENTS     = space
*     I_PARENTDBG       =
*     I_APPLOGPARENT    =
*     I_GRAPHICSPARENT  =
*     I_NAME   =
*     I_FCAT_COMPLETE   = SPACE
*    EXCEPTIONS
*     ERROR_CNTL_CREATE = 1
*     ERROR_CNTL_INIT   = 2
*     ERROR_CNTL_LINK   = 3
*     ERROR_DP_CREATE   = 4
*     OTHERS   = 5.
    .

ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  FIELD_CATALOG_0100
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM FIELD_CATALOG_0100 .
  CLEAR : GS_FIELDCAT, GT_FIELDCAT.
  GS_FIELDCAT-COL_POS = 1.
  GS_FIELDCAT-FIELDNAME = 'ICON'.
  GS_FIELDCAT-COLTEXT = '구분'.
  GS_FIELDCAT-ICON = 'X'.
  APPEND GS_FIELDCAT TO GT_FIELDCAT.

  CLEAR : GS_FIELDCAT.
  GS_FIELDCAT-COL_POS = 2.
  GS_FIELDCAT-FIELDNAME = 'ZORDNO'.
  GS_FIELDCAT-SCRTEXT_M = '주문번호'.
  APPEND GS_FIELDCAT TO GT_FIELDCAT.

  CLEAR : GS_FIELDCAT.
  GS_FIELDCAT-COL_POS = 3.
  GS_FIELDCAT-FIELDNAME = 'ZIDCODE'.
  GS_FIELDCAT-SCRTEXT_M = '회원ID'.
  APPEND GS_FIELDCAT TO GT_FIELDCAT.

  CLEAR : GS_FIELDCAT.
  GS_FIELDCAT-COL_POS = 4.
  GS_FIELDCAT-FIELDNAME = 'ZMATNR'.
  GS_FIELDCAT-SCRTEXT_M = '제품번호'.
  APPEND GS_FIELDCAT TO GT_FIELDCAT.

  CLEAR : GS_FIELDCAT.
  GS_FIELDCAT-COL_POS = 5.
  GS_FIELDCAT-FIELDNAME = 'ZMATNAME'.
  GS_FIELDCAT-SCRTEXT_M = '제품명'.
  APPEND GS_FIELDCAT TO GT_FIELDCAT.

  CLEAR : GS_FIELDCAT.
  GS_FIELDCAT-COL_POS = 6.
  GS_FIELDCAT-FIELDNAME = 'ZMAT_NAME'.
  GS_FIELDCAT-SCRTEXT_M = '제품우형'.
  APPEND GS_FIELDCAT TO GT_FIELDCAT.

  CLEAR : GS_FIELDCAT.
  GS_FIELDCAT-COL_POS = 7.
  GS_FIELDCAT-FIELDNAME = 'ZVOLUM'.
  GS_FIELDCAT-SCRTEXT_M = '수량'.
  GS_FIELDCAT-QFIELDNAME = 'VRKME'.
  APPEND GS_FIELDCAT TO GT_FIELDCAT.

  CLEAR : GS_FIELDCAT.
  GS_FIELDCAT-COL_POS = 8.
  GS_FIELDCAT-FIELDNAME = 'VRKME'.
  GS_FIELDCAT-SCRTEXT_M = '단위'.
  APPEND GS_FIELDCAT TO GT_FIELDCAT.

  CLEAR : GS_FIELDCAT.
  GS_FIELDCAT-COL_POS = 9.
  GS_FIELDCAT-FIELDNAME = 'ZNSAMT'.
  GS_FIELDCAT-SCRTEXT_M = '판매금액'.
  GS_FIELDCAT-CFIELDNAME = 'ZWAERS'.
  GS_FIELDCAT-DO_SUM = 'X'.
  APPEND GS_FIELDCAT TO GT_FIELDCAT.

  CLEAR : GS_FIELDCAT.
  GS_FIELDCAT-COL_POS = 10.
  GS_FIELDCAT-FIELDNAME = 'ZSLAMT'.
  GS_FIELDCAT-SCRTEXT_M = '매출금액'.
  GS_FIELDCAT-CFIELDNAME = 'ZWAERS'.
  GS_FIELDCAT-DO_SUM = 'X'.
  APPEND GS_FIELDCAT TO GT_FIELDCAT.

  CLEAR : GS_FIELDCAT.
  GS_FIELDCAT-COL_POS = 11.
  GS_FIELDCAT-FIELDNAME = 'ZDCAMT'.
  GS_FIELDCAT-SCRTEXT_M = '할인금액'.
  GS_FIELDCAT-CFIELDNAME = 'ZWAERS'.
  GS_FIELDCAT-DO_SUM = 'X'.
  APPEND GS_FIELDCAT TO GT_FIELDCAT.

  CLEAR : GS_FIELDCAT.
  GS_FIELDCAT-COL_POS = 12.
  GS_FIELDCAT-FIELDNAME = 'ZWAERS'.
  GS_FIELDCAT-SCRTEXT_M = '통화'.
  GS_FIELDCAT-EMPHASIZE = 'X'.
  APPEND GS_FIELDCAT TO GT_FIELDCAT.

  CLEAR : GS_FIELDCAT.
  GS_FIELDCAT-COL_POS = 13.
  GS_FIELDCAT-FIELDNAME = 'ZSALE_NAME'.
  GS_FIELDCAT-SCRTEXT_M = '매출구분'.
  APPEND GS_FIELDCAT TO GT_FIELDCAT.

  CLEAR : GS_FIELDCAT.
  GS_FIELDCAT-COL_POS = 14.
  GS_FIELDCAT-FIELDNAME = 'ZJDATE'.
  GS_FIELDCAT-SCRTEXT_M = '판매일자'.
  GS_FIELDCAT-OUTPUTLEN = '10'.
  APPEND GS_FIELDCAT TO GT_FIELDCAT.

  IF P_CH1 = C_X.
    CLEAR : GS_FIELDCAT.
    GS_FIELDCAT-COL_POS = 15.
    GS_FIELDCAT-FIELDNAME = 'ZRET_NAME'.
    GS_FIELDCAT-SCRTEXT_M = '반품구분'.
    APPEND GS_FIELDCAT TO GT_FIELDCAT.

    CLEAR : GS_FIELDCAT.
    GS_FIELDCAT-COL_POS = 16.
    GS_FIELDCAT-FIELDNAME = 'ZRDATE'.
    GS_FIELDCAT-SCRTEXT_M = '반품일자'.
    GS_FIELDCAT-OUTPUTLEN = '10'.
    APPEND GS_FIELDCAT TO GT_FIELDCAT.
  ENDIF.
ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  ALV_SORT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM ALV_SORT .
  CLEAR : GS_SORT, GT_SORT.
  GS_SORT-SPOS = 1.
  GS_SORT-FIELDNAME = 'ZIDCODE'.
  GS_SORT-UP = 'X'.
  GS_SORT-SUBTOT = 'X'.
  APPEND GS_SORT TO GT_SORT.
ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  LAYOUT_SET
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM LAYOUT_SET .
  CLEAR GS_LAYOUT.
  GS_LAYOUT-ZEBRA = 'X'.

  CLEAR GS_VARIANT.
  GS_VARIANT-REPORT = SY-REPID.
  GS_VARIANT-USERNAME = SY-UNAME.
ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  CALL_ALV
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_GT_0100[]  text
*      -->P_GC_GRID_100  text
*      -->P_GS_LAYOUT  text
*      -->P_GS_VARIANT  text
*----------------------------------------------------------------------*
FORM CALL_ALV  USING PT_ITAB TYPE STANDARD TABLE
                     P_GRID  TYPE REF TO CL_GUI_ALV_GRID
                     PS_LAYOUT TYPE LVC_S_LAYO
                     PS_VARIANT LIKE DISVARIANT.

  CALL METHOD P_GRID->SET_TABLE_FOR_FIRST_DISPLAY
    EXPORTING
*      I_BUFFER_ACTIVE               =
*      I_BYPASSING_BUFFER            =
*      I_CONSISTENCY_CHECK           =
*      I_STRUCTURE_NAME              =
      IS_VARIANT                    = PS_VARIANT
      I_SAVE                        = C_A
*      I_DEFAULT                     = 'X'
      IS_LAYOUT                     = PS_LAYOUT
*      IS_PRINT                      =
*      IT_SPECIAL_GROUPS             =
*      IT_TOOLBAR_EXCLUDING          =
*      IT_HYPERLINK                  =
*      IT_ALV_GRAPHICS               =
*      IT_EXCEPT_QINFO               =
*      IR_SALV_ADAPTER               =
    CHANGING
      IT_OUTTAB                     = PT_ITAB
      IT_FIELDCATALOG               = GT_FIELDCAT
      IT_SORT                       = GT_SORT
*      IT_FILTER                     =
*    EXCEPTIONS
*      INVALID_PARAMETER_COMBINATION = 1
*      PROGRAM_ERROR                 = 2
*      TOO_MANY_LINES                = 3
*      OTHERS                        = 4
        .

ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  FIELD_CATALOG_0200
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM FIELD_CATALOG_0200 .
  CLEAR : GS_FIELDCAT, GT_FIELDCAT.
  GS_FIELDCAT-COL_POS = 1.
  GS_FIELDCAT-FIELDNAME = 'ICON'.
  GS_FIELDCAT-COLTEXT = '구분'.
  GS_FIELDCAT-ICON = 'X'.
  APPEND GS_FIELDCAT TO GT_FIELDCAT.

  CLEAR : GS_FIELDCAT.
  GS_FIELDCAT-COL_POS = 2.
  GS_FIELDCAT-FIELDNAME = 'ZORDNO'.
  GS_FIELDCAT-SCRTEXT_M = '주문번호'.
  APPEND GS_FIELDCAT TO GT_FIELDCAT.

  CLEAR : GS_FIELDCAT.
  GS_FIELDCAT-COL_POS = 3.
  GS_FIELDCAT-FIELDNAME = 'ZIDCODE'.
  GS_FIELDCAT-SCRTEXT_M = '회원ID'.
  APPEND GS_FIELDCAT TO GT_FIELDCAT.

  CLEAR : GS_FIELDCAT.
  GS_FIELDCAT-COL_POS = 4.
  GS_FIELDCAT-FIELDNAME = 'ZMATNR'.
  GS_FIELDCAT-SCRTEXT_M = '제품번호'.
  APPEND GS_FIELDCAT TO GT_FIELDCAT.

  CLEAR : GS_FIELDCAT.
  GS_FIELDCAT-COL_POS = 5.
  GS_FIELDCAT-FIELDNAME = 'ZMATNAME'.
  GS_FIELDCAT-SCRTEXT_M = '제품명'.
  APPEND GS_FIELDCAT TO GT_FIELDCAT.

  CLEAR : GS_FIELDCAT.
  GS_FIELDCAT-COL_POS = 6.
  GS_FIELDCAT-FIELDNAME = 'ZMAT_NAME'.
  GS_FIELDCAT-SCRTEXT_M = '제품유형'.
  APPEND GS_FIELDCAT TO GT_FIELDCAT.

  CLEAR : GS_FIELDCAT.
  GS_FIELDCAT-COL_POS = 7.
  GS_FIELDCAT-FIELDNAME = 'ZVOLUM'.
  GS_FIELDCAT-SCRTEXT_M = '수량'.
  GS_FIELDCAT-QFIELDNAME = 'VRKME'.
  APPEND GS_FIELDCAT TO GT_FIELDCAT.

  CLEAR : GS_FIELDCAT.
  GS_FIELDCAT-COL_POS = 8.
  GS_FIELDCAT-FIELDNAME = 'VRKME'.
  GS_FIELDCAT-SCRTEXT_M = '단위'.
  APPEND GS_FIELDCAT TO GT_FIELDCAT.

  CLEAR : GS_FIELDCAT.
  GS_FIELDCAT-COL_POS = 10.
  GS_FIELDCAT-FIELDNAME = 'ZSLAMT'.
  GS_FIELDCAT-SCRTEXT_M = '매출금액'.
  GS_FIELDCAT-CFIELDNAME = 'ZWAERS'.
  GS_FIELDCAT-DO_SUM = 'X'.
  APPEND GS_FIELDCAT TO GT_FIELDCAT.

  CLEAR : GS_FIELDCAT.
  GS_FIELDCAT-COL_POS = 11.
  GS_FIELDCAT-FIELDNAME = 'ZWAERS'.
  GS_FIELDCAT-SCRTEXT_M = '통화'.
  GS_FIELDCAT-EMPHASIZE = 'X'.
  APPEND GS_FIELDCAT TO GT_FIELDCAT.

  CLEAR : GS_FIELDCAT.
  GS_FIELDCAT-COL_POS = 12.
  GS_FIELDCAT-FIELDNAME = 'ZDFLAG_NAME'.
  GS_FIELDCAT-SCRTEXT_M = '배송현황'.
  GS_FIELDCAT-CURRENCY = 'KRW'.
  APPEND GS_FIELDCAT TO GT_FIELDCAT.

  CLEAR : GS_FIELDCAT.
  GS_FIELDCAT-COL_POS = 13.
  GS_FIELDCAT-FIELDNAME = 'ZDGUBUN_NAME'.
  GS_FIELDCAT-SCRTEXT_M = '배송지역'.
  GS_FIELDCAT-EMPHASIZE = 'X'.
  APPEND GS_FIELDCAT TO GT_FIELDCAT.

  CLEAR : GS_FIELDCAT.
  GS_FIELDCAT-COL_POS = 14.
  GS_FIELDCAT-FIELDNAME = 'ZDDATE'.
  GS_FIELDCAT-SCRTEXT_M = '배송일자'.
  GS_FIELDCAT-OUTPUTLEN = '10'.
  APPEND GS_FIELDCAT TO GT_FIELDCAT.

  IF P_CH1 = C_X.
    CLEAR : GS_FIELDCAT.
    GS_FIELDCAT-COL_POS = 15.
    GS_FIELDCAT-FIELDNAME = 'ZRDATE'.
    GS_FIELDCAT-SCRTEXT_M = '반품일자'.
    GS_FIELDCAT-OUTPUTLEN = '10'.
    APPEND GS_FIELDCAT TO GT_FIELDCAT.

    CLEAR : GS_FIELDCAT.
    GS_FIELDCAT-COL_POS = 16.
    GS_FIELDCAT-FIELDNAME = 'ZFLAG'.
    GS_FIELDCAT-SCRTEXT_M = '반품체크'.
    GS_FIELDCAT-OUTPUTLEN = '8'.
    GS_FIELDCAT-JUST = 'C'.
    GS_FIELDCAT-EMPHASIZE = 'X'.
    APPEND GS_FIELDCAT TO GT_FIELDCAT.
  ENDIF.
ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  ZMTART_NAME
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_GS_ORDER_ZMTART  text
*      <--P_GS_0100_ZMAT_NAME  text
*----------------------------------------------------------------------*
FORM ZMTART_NAME  USING P_ZMTART
                  CHANGING P_NAME.
  CASE P_ZMTART.
    WHEN '001'.
      P_NAME = '식품'.
    WHEN '002'.
      P_NAME = '상품'.
    WHEN '003'.
      P_NAME = '제품'.
    WHEN '004'.
      P_NAME = '의류'.
    WHEN '005'.
      P_NAME = '도서'.
    WHEN '006'.
      P_NAME = '서비스'.
  ENDCASE.
ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  ZRET_NAME
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_GS_ORDER_ZRET_FG  text
*      <--P_GS_0100_ZRET_NAME  text
*----------------------------------------------------------------------*
FORM ZRET_NAME  USING P_FG
                CHANGING P_NAME.
  CASE P_FG.
    WHEN '1'.
      P_NAME = '단순변심'.
    WHEN '2'.
      P_NAME = '제품하자'.
    WHEN '3'.
      P_NAME = '배송문제'.
  ENDCASE.
ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  ZDGUBUN_NAME
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_GS_DELIVERY_ZDGUBUN  text
*      <--P_GS_0200_ZDGUBUN_NAME  text
*----------------------------------------------------------------------*
FORM ZDGUBUN_NAME  USING P_ZDGUBUN
                   CHANGING P_NAME.
  CASE P_ZDGUBUN.
    WHEN '1'.
      P_NAME = '서울'.
    WHEN '2'.
      P_NAME = '경기도'.
    WHEN '3'.
      P_NAME = '충청도'.
    WHEN '4'.
      P_NAME = '경상도'.
    WHEN '5'.
      P_NAME = '강원도'.
    WHEN '6'.
      P_NAME = '전라도'.
    WHEN '7'.
      P_NAME = '제주도'.
  ENDCASE.
ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  ZSALE_NAME
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_GS_ORDER_ZSALE_FG  text
*      <--P_GS_0100_ZSALE_NAME  text
*----------------------------------------------------------------------*
FORM ZSALE_NAME  USING    P_GS_ORDER_ZSALE_FG
                 CHANGING P_GS_0100_ZSALE_NAME.

  CASE GS_ORDER-ZSALE_FG.
    WHEN '1'.
      GS_0100-ZSALE_NAME = '매출'.
      GS_0100-ICON = '@08@'.
    WHEN '2'.
      GS_0100-ZSALE_NAME = '반품'.
      GS_0100-ICON = '@0A@'.
    ENDCASE.
ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  ZDFLAG_NAME
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_GS_DELIVERY_ZDFLAG  text
*      <--P_GS_0200_ZDFLAG_NAME  text
*----------------------------------------------------------------------*
FORM ZDFLAG_NAME  USING    P_GS_DELIVERY_ZDFLAG
                  CHANGING P_GS_0200_ZDFLAG_NAME.

  CASE GS_DELIVERY-ZDFLAG.
      WHEN '1'.
        GS_0200-ZDFLAG_NAME = '배송시작'.
      WHEN '2'.
        GS_0200-ZDFLAG_NAME = '배송완료'.
    ENDCASE.
ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  ICON
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_GS_DELIVERY_ZFLAG  text
*      <--P_GS_0200_ICON  text
*----------------------------------------------------------------------*
FORM ICON  USING    P_GS_DELIVERY_ZFLAG
           CHANGING P_GS_0200_ICON.

    CASE GS_DELIVERY-ZFLAG.
      WHEN 'X'.
        GS_0200-ICON = '@0A@'. "빨강
      WHEN OTHERS.
        GS_0200-ICON = '@08A'. "초록
    ENDCASE.
ENDFORM.
