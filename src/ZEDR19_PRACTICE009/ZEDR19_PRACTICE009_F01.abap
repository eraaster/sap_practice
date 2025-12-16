*&---------------------------------------------------------------------*
*&  Include           ZEDR19_PRACTICE009_F01
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Form  SET_DATE
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM set_date .
  " 값 있으면 스킵
  CHECK p_date IS INITIAL.

  DATA lv_last TYPE d.  " DATS(YYYYMMDD)

  CALL FUNCTION 'RP_LAST_DAY_OF_MONTHS'
    EXPORTING
      day_in            = sy-datum
    IMPORTING
      last_day_of_month = lv_last
    EXCEPTIONS
      day_in_no_date    = 1
      OTHERS            = 2.

  IF sy-subrc = 0.
    P_date = lv_last.   " p_DATE가 진짜 DATS면 여기서 OK
  ELSE.
    MESSAGE '월말 계산 중 오류가 발생했습니다.' TYPE 'E'.
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

    " ALL 그룹: 항상 활성
    IF screen-group1 = 'ALL'.
      screen-active = 1.
      MODIFY SCREEN.
      CONTINUE.
    ENDIF.

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
  IF P_DATE IS INITIAL.
    MESSAGE '기준일자를 입력해주세요.' TYPE 'E'.
    STOP.
  ELSEIF ( S_PERNR[] IS INITIAL ) AND ( S_DEPT[] IS INITIAL ).
    MESSAGE '사원번호 혹은 부서코드 중 하나를 반드시 입력해주세요.' TYPE 'E'.
    STOP.
  ENDIF.
ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  GET_DATA
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM GET_DATA .
  SELECT
      A~ZPERNR,      B~ZPNAME,      A~ZDEPRANK,      A~ZDEPCODE,
      A~ZEDATE,      A~ZQDATE,      A~ZQFLAG,      B~ZGENDER,
      B~ZADDRESS,      C~ZBANKCODE,  C~ZACCOUNT, C~ZSALARY,
      D~ZRANK
    FROM ZEDT19_102 AS A
    LEFT OUTER JOIN ZEDT19_103 AS B
      ON A~ZPERNR = B~ZPERNR
    LEFT OUTER JOIN ZEDT19_106 AS C
      ON A~ZPERNR = C~ZPERNR
    LEFT OUTER JOIN ZEDT19_104 AS D
      ON A~ZPERNR = D~ZPERNR
    WHERE
      A~ZPERNR IN @S_PERNR
    INTO CORRESPONDING FIELDS OF TABLE @GT_EMP_INFO.

  IF p_chk1 IS INITIAL.
  DELETE gt_emp_info WHERE zqflag IS NOT INITIAL.  "퇴사자 제거
  ENDIF.

  PERFORM CONVERT_KOR.
  PERFORM SET_ICON.
  PERFORM SET_CURRENCY.
ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  CONVERT_KOR
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM CONVERT_KOR .
  DATA : lv_pernr TYPE zedt19_103-zpernr.

  LOOP AT GT_EMP_INFO INTO GS_EMP_INFO.

    lv_pernr = gs_emp_info-zpernr.
    CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
      EXPORTING  input  = lv_pernr
      IMPORTING  output = lv_pernr.
    GS_EMP_INFO-ZPERNR = lv_pernr.

    IF GS_EMP_INFO-ZGENDER = 'M'.
      GS_EMP_INFO-ZGENDER = C_MALE_T.
    ELSE.
      GS_EMP_INFO-ZGENDER = C_FEMALE_T.
    ENDIF.

    PERFORM FORMAT_DATES_DOT
    USING GS_EMP_INFO-ZEDATE
          GS_EMP_INFO-ZQDATE
    CHANGING GS_EMP_INFO-ZDATE_D
             GS_EMP_INFO-ZQDATE_D.

    IF GS_EMP_INFO-ZQFLAG IS NOT INITIAL.
      GS_EMP_INFO-ZQDATE_T = GS_EMP_INFO-ZQDATE_D.
    ELSE.
      GS_EMP_INFO-ZQDATE_T = ' '.
      GS_EMP_INFO-ZQDATE_D = '9999.12.31'.
    ENDIF.

    GS_EMP_INFO-ZYEAR = GS_EMP_INFO-ZEDATE(4).

    " 부서명 한글 변환
    CASE GS_EMP_INFO-ZDEPCODE.
      WHEN 'SS0001'. GS_EMP_INFO-ZDEPNAME = '회계팀'.
      WHEN 'SS0002'. GS_EMP_INFO-ZDEPNAME = '구매팀'.
      WHEN 'SS0003'. GS_EMP_INFO-ZDEPNAME = '인사팀'.
      WHEN 'SS0004'. GS_EMP_INFO-ZDEPNAME = '영업팀'.
      WHEN 'SS0005'. GS_EMP_INFO-ZDEPNAME = '생산팀'.
      WHEN 'SS0006'. GS_EMP_INFO-ZDEPNAME = '관리팀'.
    ENDCASE.

    " 직급명 한글 변환
    CASE GS_EMP_INFO-ZDEPRANK.
      WHEN 'A'. GS_EMP_INFO-ZRANKNAME = '인턴'.
      WHEN 'B'. GS_EMP_INFO-ZRANKNAME = '사원'.
      WHEN 'C'. GS_EMP_INFO-ZRANKNAME = '대리'.
      WHEN 'D'. GS_EMP_INFO-ZRANKNAME = '과장'.
      WHEN 'E'. GS_EMP_INFO-ZRANKNAME = '차장'.
      WHEN 'F'. GS_EMP_INFO-ZRANKNAME = '부장'.
      WHEN 'G'. GS_EMP_INFO-ZRANKNAME = '임원'.
    ENDCASE.

    " 은행명 한글 변환
    CASE GS_EMP_INFO-ZBANKCODE.
      WHEN '001'. GS_EMP_INFO-ZBANKNAME = '신한'.
      WHEN '002'. GS_EMP_INFO-ZBANKNAME = '우리'.
      WHEN '003'. GS_EMP_INFO-ZBANKNAME = '하나'.
      WHEN '004'. GS_EMP_INFO-ZBANKNAME = '국민'.
      WHEN '005'. GS_EMP_INFO-ZBANKNAME = '카카오'.
    ENDCASE.

    MODIFY GT_EMP_INFO FROM GS_EMP_INFO.
  ENDLOOP.
ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  CREATE_OBJECT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM CREATE_OBJECT .
  CREATE OBJECT GC_DOCKING
    EXPORTING
      REPID                       = SY-REPID
      DYNNR                       = SY-DYNNR
      EXTENSION                   = 2000.

  CREATE OBJECT GC_SPLITTER
    EXPORTING
      PARENT            = GC_DOCKING
      ROWS              = 2
      COLUMNS           = 1.

  CALL METHOD GC_SPLITTER->GET_CONTAINER
    EXPORTING
      ROW       = 1
      COLUMN    = 1
    RECEIVING
      CONTAINER = GC_CONTAINER1.

  CALL METHOD GC_SPLITTER->GET_CONTAINER
    EXPORTING
      ROW       = 2
      COLUMN    = 1
    RECEIVING
      CONTAINER = GC_CONTAINER2.

  CREATE OBJECT GC_SPLITTER2
    EXPORTING
      PARENT            = GC_CONTAINER1
      ROWS              = 1
      COLUMNS           = 2.

  CALL METHOD GC_SPLITTER2->GET_CONTAINER
    EXPORTING
      ROW       = 1
      COLUMN    = 1
    RECEIVING
      CONTAINER = GC_CONTAINER3.

  CALL METHOD GC_SPLITTER2->GET_CONTAINER
    EXPORTING
      ROW       = 1
      COLUMN    = 2
    RECEIVING
      CONTAINER = GC_CONTAINER4.

  CREATE OBJECT GC_GRID1
    EXPORTING
      I_PARENT          = GC_CONTAINER3. "상단 왼쪽

  CREATE OBJECT GC_GRID2
    EXPORTING
      I_PARENT          = GC_CONTAINER4. "상단 오른쪽

  CREATE OBJECT GC_GRID3
    EXPORTING
      I_PARENT          = GC_CONTAINER2. "하단 전체
ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  FIELD_CATALOG
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM FIELD_CATALOG .
  PERFORM CONTAINER1_FIELD.
  PERFORM CONTAINER2_FIELD.
  PERFORM CONTAINER3_FIELD.
ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  ALV_LAYOUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM ALV_LAYOUT .
  CLEAR GS_LAYOUT.
  GS_LAYOUT-ZEBRA = 'X'.
  GS_LAYOUT-TOTALS_BEF = 'X'.

  CLEAR GS_VARIANT.
  GS_VARIANT-REPORT = SY-REPID.
  GS_VARIANT-USERNAME = SY-UNAME.
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
  PERFORM CONTAINER1_SORT.
  PERFORM CONTAINER2_SORT.
  PERFORM CONTAINER3_SORT.
ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  CALL_ALV
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM CALL_ALV .
  PERFORM ALV_DISPLAY.
ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  ALV_DISPLAY
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM ALV_DISPLAY .
    CALL METHOD GC_GRID1->SET_TABLE_FOR_FIRST_DISPLAY
    EXPORTING
*      I_BUFFER_ACTIVE               =
*      I_BYPASSING_BUFFER            =
*      I_CONSISTENCY_CHECK           =
*      I_STRUCTURE_NAME              =
      IS_VARIANT                    = GS_VARIANT
      I_SAVE                        = 'A'
*      I_DEFAULT                     = 'X'
      IS_LAYOUT                     = GS_LAYOUT
*      IS_PRINT                      =
*      IT_SPECIAL_GROUPS             =
*      IT_TOOLBAR_EXCLUDING          =
*      IT_HYPERLINK                  =
*      IT_ALV_GRAPHICS               =
*      IT_EXCEPT_QINFO               =
*      IR_SALV_ADAPTER               =
    CHANGING
      IT_OUTTAB                     = GT_EMP_INFO
      IT_FIELDCATALOG               = GT_FIELDCAT1
      IT_SORT                       = GT_SORT1
*      IT_FILTER                     =
*    EXCEPTIONS
*      INVALID_PARAMETER_COMBINATION = 1
*      PROGRAM_ERROR                 = 2
*      TOO_MANY_LINES                = 3
*      others                        = 4
          .
  IF SY-SUBRC <> 0.
*   Implement suitable error handling here
  ENDIF.

    CALL METHOD GC_GRID2->SET_TABLE_FOR_FIRST_DISPLAY
    EXPORTING
*      I_BUFFER_ACTIVE               =
*      I_BYPASSING_BUFFER            =
*      I_CONSISTENCY_CHECK           =
*      I_STRUCTURE_NAME              =
      IS_VARIANT                    = GS_VARIANT
      I_SAVE                        = 'A'
*      I_DEFAULT                     = 'X'
      IS_LAYOUT                     = GS_LAYOUT
*      IS_PRINT                      =
*      IT_SPECIAL_GROUPS             =
*      IT_TOOLBAR_EXCLUDING          =
*      IT_HYPERLINK                  =
*      IT_ALV_GRAPHICS               =
*      IT_EXCEPT_QINFO               =
*      IR_SALV_ADAPTER               =
    CHANGING
      IT_OUTTAB                     = GT_EMP_INFO
      IT_FIELDCATALOG               = GT_FIELDCAT2
      IT_SORT                       = GT_SORT2
*      IT_FILTER                     =
*    EXCEPTIONS
*      INVALID_PARAMETER_COMBINATION = 1
*      PROGRAM_ERROR                 = 2
*      TOO_MANY_LINES                = 3
*      others                        = 4
          .
  IF SY-SUBRC <> 0.
*   Implement suitable error handling here
  ENDIF.

    CALL METHOD GC_GRID3->SET_TABLE_FOR_FIRST_DISPLAY
    EXPORTING
*      I_BUFFER_ACTIVE               =
*      I_BYPASSING_BUFFER            =
*      I_CONSISTENCY_CHECK           =
*      I_STRUCTURE_NAME              =
      IS_VARIANT                    = GS_VARIANT
      I_SAVE                        = 'A'
*      I_DEFAULT                     = 'X'
      IS_LAYOUT                     = GS_LAYOUT
*      IS_PRINT                      =
*      IT_SPECIAL_GROUPS             =
*      IT_TOOLBAR_EXCLUDING          =
*      IT_HYPERLINK                  =
*      IT_ALV_GRAPHICS               =
*      IT_EXCEPT_QINFO               =
*      IR_SALV_ADAPTER               =
    CHANGING
      IT_OUTTAB                     = GT_EMP_INFO
      IT_FIELDCATALOG               = GT_FIELDCAT3
      IT_SORT                       = GT_SORT3
*      IT_FILTER                     =
*    EXCEPTIONS
*      INVALID_PARAMETER_COMBINATION = 1
*      PROGRAM_ERROR                 = 2
*      TOO_MANY_LINES                = 3
*      others                        = 4
          .
  IF SY-SUBRC <> 0.
*   Implement suitable error handling here
  ENDIF.
ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  CONTAINER1_SORT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM CONTAINER1_SORT .
  CLEAR : GS_SORT, GT_SORT1.
  GS_SORT-SPOS = 1.
  GS_SORT-FIELDNAME = 'ZPERNR'.
  GS_SORT-UP = 'X'.
  GS_SORT-SUBTOT = 'X'.
  APPEND GS_SORT TO GT_SORT1.
ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  CONTAINER2_SORT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM CONTAINER2_SORT .
  CLEAR : GS_SORT, GT_SORT2.
  GS_SORT-SPOS = 1.
  GS_SORT-FIELDNAME = 'ZPERNR'.
  GS_SORT-UP = 'X'.
  APPEND GS_SORT TO GT_SORT2.
ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  CONTAINER3_SORT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM CONTAINER3_SORT .
  CLEAR : GS_SORT, GT_SORT3.
  GS_SORT-SPOS = 1.
  GS_SORT-FIELDNAME = 'ZPERNR'.
  GS_SORT-UP = 'X'.
  GS_SORT-SUBTOT = 'X'.
  APPEND GS_SORT TO GT_SORT3.
ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  CONTAINER1_FIELD
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM CONTAINER1_FIELD .
  CLEAR : GS_FIELDCAT.
  GS_FIELDCAT-COL_POS = 1.
  GS_FIELDCAT-FIELDNAME = 'ZPERNR'.
  GS_FIELDCAT-COLTEXT = '사원번호'.
  GS_FIELDCAT-KEY = 'X'.
  GS_FIELDCAT-EMPHASIZE = 'C500'.
  APPEND GS_FIELDCAT TO GT_FIELDCAT1.

  CLEAR : GS_FIELDCAT.
  GS_FIELDCAT-COL_POS = 2.
  GS_FIELDCAT-FIELDNAME = 'ZDEPNAME'.
  GS_FIELDCAT-SCRTEXT_M = '부서명'.
  APPEND GS_FIELDCAT TO GT_FIELDCAT1.

  CLEAR : GS_FIELDCAT.
  GS_FIELDCAT-COL_POS = 3.
  GS_FIELDCAT-FIELDNAME = 'ZYEAR'.
  GS_FIELDCAT-SCRTEXT_M = '연도'.
  APPEND GS_FIELDCAT TO GT_FIELDCAT1.

  CLEAR : GS_FIELDCAT.
  GS_FIELDCAT-COL_POS = 4.
  GS_FIELDCAT-FIELDNAME = 'ZDATE_D'.
  GS_FIELDCAT-SCRTEXT_M = '시작일자'.
  APPEND GS_FIELDCAT TO GT_FIELDCAT1.

  CLEAR : GS_FIELDCAT.
  GS_FIELDCAT-COL_POS = 5.
  GS_FIELDCAT-FIELDNAME = 'ZQDATE_D'.
  GS_FIELDCAT-SCRTEXT_M = '종료일자'.
  APPEND GS_FIELDCAT TO GT_FIELDCAT1.

  CLEAR : GS_FIELDCAT.
  GS_FIELDCAT-COL_POS = 6.
  GS_FIELDCAT-FIELDNAME = 'ZRANK'.
  GS_FIELDCAT-SCRTEXT_M = '평가'.
  APPEND GS_FIELDCAT TO GT_FIELDCAT1.
ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  CONTAINER2_FIELD
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM CONTAINER2_FIELD .
  CLEAR : GS_FIELDCAT.
  GS_FIELDCAT-COL_POS = 1.
  GS_FIELDCAT-FIELDNAME = 'ZPERNR'.
  GS_FIELDCAT-COLTEXT = '사원번호'.
  GS_FIELDCAT-KEY = 'X'.
  GS_FIELDCAT-EMPHASIZE = 'C500'.
  APPEND GS_FIELDCAT TO GT_FIELDCAT2.

  CLEAR : GS_FIELDCAT.
  GS_FIELDCAT-COL_POS = 2.
  GS_FIELDCAT-FIELDNAME = 'ZYEAR'.
  GS_FIELDCAT-SCRTEXT_M = '연도'.
  APPEND GS_FIELDCAT TO GT_FIELDCAT2.

  CLEAR : GS_FIELDCAT.
  GS_FIELDCAT-COL_POS = 3.
  GS_FIELDCAT-FIELDNAME = 'ZDATE_D'.
  GS_FIELDCAT-SCRTEXT_M = '시작일자'.
  APPEND GS_FIELDCAT TO GT_FIELDCAT2.

  CLEAR : GS_FIELDCAT.
  GS_FIELDCAT-COL_POS = 4.
  GS_FIELDCAT-FIELDNAME = 'ZQDATE_D'.
  GS_FIELDCAT-SCRTEXT_M = '종료일자'.
  APPEND GS_FIELDCAT TO GT_FIELDCAT2.

  CLEAR : GS_FIELDCAT.
  GS_FIELDCAT-COL_POS = 5.
  GS_FIELDCAT-FIELDNAME = 'ZSALARY'.
  GS_FIELDCAT-SCRTEXT_M = '계약금액'.
  GS_FIELDCAT-DO_SUM = 'X'.
  GS_FIELDCAT-CFIELDNAME = 'WAERS'.
  APPEND GS_FIELDCAT TO GT_FIELDCAT2.

  CLEAR : GS_FIELDCAT.
  GS_FIELDCAT-COL_POS = 6.
  GS_FIELDCAT-FIELDNAME = 'ZBANKNAME'.
  GS_FIELDCAT-SCRTEXT_M = '은행명'.
  APPEND GS_FIELDCAT TO GT_FIELDCAT2.

  CLEAR : GS_FIELDCAT.
  GS_FIELDCAT-COL_POS = 7.
  GS_FIELDCAT-FIELDNAME = 'ZACCOUNT'.
  GS_FIELDCAT-SCRTEXT_M = '계좌번호'.
  APPEND GS_FIELDCAT TO GT_FIELDCAT2.
ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  CONTAINER3_FIELD
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM CONTAINER3_FIELD .
  CLEAR : GS_FIELDCAT, GT_FIELDCAT3.
  GS_FIELDCAT-COL_POS = 1.
  GS_FIELDCAT-FIELDNAME = 'ICON'.
  GS_FIELDCAT-COLTEXT = '구분'.
  GS_FIELDCAT-ICON = 'X'.
  APPEND GS_FIELDCAT TO GT_FIELDCAT3.

  CLEAR : GS_FIELDCAT.
  GS_FIELDCAT-COL_POS = 2.
  GS_FIELDCAT-FIELDNAME = 'ZPERNR'.
  GS_FIELDCAT-COLTEXT = '사원번호'.
  GS_FIELDCAT-KEY = 'X'.
  GS_FIELDCAT-EMPHASIZE = 'C500'.
  APPEND GS_FIELDCAT TO GT_FIELDCAT3.

  CLEAR : GS_FIELDCAT.
  GS_FIELDCAT-COL_POS = 3.
  GS_FIELDCAT-FIELDNAME = 'ZPNAME'.
  GS_FIELDCAT-SCRTEXT_M = '이름'.
  APPEND GS_FIELDCAT TO GT_FIELDCAT3.

  CLEAR : GS_FIELDCAT.
  GS_FIELDCAT-COL_POS = 4.
  GS_FIELDCAT-FIELDNAME = 'ZDEPNAME'.
  GS_FIELDCAT-SCRTEXT_M = '부서명'.
  APPEND GS_FIELDCAT TO GT_FIELDCAT3.

  CLEAR : GS_FIELDCAT.
  GS_FIELDCAT-COL_POS = 5.
  GS_FIELDCAT-FIELDNAME = 'ZDATE_D'.
  GS_FIELDCAT-SCRTEXT_M = '시작날짜'.
  APPEND GS_FIELDCAT TO GT_FIELDCAT3.

  CLEAR : GS_FIELDCAT.
  GS_FIELDCAT-COL_POS = 6.
  GS_FIELDCAT-FIELDNAME = 'ZQDATE_D'.
  GS_FIELDCAT-SCRTEXT_M = '종료날짜'.
  APPEND GS_FIELDCAT TO GT_FIELDCAT3.

  CLEAR : GS_FIELDCAT.
  GS_FIELDCAT-COL_POS = 7.
  GS_FIELDCAT-FIELDNAME = 'ZRANKNAME'.
  GS_FIELDCAT-SCRTEXT_M = '직급'.
  APPEND GS_FIELDCAT TO GT_FIELDCAT3.

  CLEAR : GS_FIELDCAT.
  GS_FIELDCAT-COL_POS = 8.
  GS_FIELDCAT-FIELDNAME = 'ZGENDER'.
  GS_FIELDCAT-SCRTEXT_M = '성별'.
  APPEND GS_FIELDCAT TO GT_FIELDCAT3.

  CLEAR : GS_FIELDCAT.
  GS_FIELDCAT-COL_POS = 9.
  GS_FIELDCAT-FIELDNAME = 'ZDATE_D'.
  GS_FIELDCAT-SCRTEXT_M = '입사일자'.
  APPEND GS_FIELDCAT TO GT_FIELDCAT3.

  CLEAR : GS_FIELDCAT.
  GS_FIELDCAT-COL_POS = 10.
  GS_FIELDCAT-FIELDNAME = 'ZADDRESS'.
  GS_FIELDCAT-SCRTEXT_M = '주소'.
  APPEND GS_FIELDCAT TO GT_FIELDCAT3.

  CLEAR : GS_FIELDCAT.
  GS_FIELDCAT-COL_POS = 11.
  GS_FIELDCAT-FIELDNAME = 'ZQDATE_T'.
  GS_FIELDCAT-SCRTEXT_M = '퇴사일자'.
  APPEND GS_FIELDCAT TO GT_FIELDCAT3.

  CLEAR : GS_FIELDCAT.
  GS_FIELDCAT-COL_POS = 12.
  GS_FIELDCAT-FIELDNAME = 'ZQFLAG'.
  GS_FIELDCAT-SCRTEXT_M = '퇴사구분'.
  APPEND GS_FIELDCAT TO GT_FIELDCAT3.
ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  FORMAT_DATES_DOT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_GS_EMP_INFO_ZEDATE  text
*      -->P_GS_EMP_INFO_ZQDATE  text
*      <--P_GS_EMP_INFO_ZDATE_D  text
*      <--P_GS_EMP_INFO_ZQDATE_D  text
*----------------------------------------------------------------------*
FORM FORMAT_DATES_DOT  USING    P_GS_EMP_INFO_ZEDATE
                                P_GS_EMP_INFO_ZQDATE
                       CHANGING P_GS_EMP_INFO_ZDATE_D
                                P_GS_EMP_INFO_ZQDATE_D.

  CLEAR P_GS_EMP_INFO_ZDATE_D.
  IF P_GS_EMP_INFO_ZEDATE IS NOT INITIAL.
    WRITE P_GS_EMP_INFO_ZEDATE TO P_GS_EMP_INFO_ZDATE_D USING EDIT MASK '____.__.__'.
  ENDIF.

  CLEAR P_GS_EMP_INFO_ZQDATE_D.
  IF P_GS_EMP_INFO_ZQDATE IS NOT INITIAL.
    WRITE P_GS_EMP_INFO_ZQDATE TO P_GS_EMP_INFO_ZQDATE_D USING EDIT MASK '____.__.__'.
  ENDIF.
ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  SET_ICON
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM SET_ICON .
  LOOP AT GT_EMP_INFO INTO GS_EMP_INFO.

    IF GS_EMP_INFO-ZQFLAG IS NOT INITIAL.
      GS_EMP_INFO-ICON = '@0A@'. "빨강
    ELSEIF GS_EMP_INFO-ZRANKNAME = '인턴'.
      GS_EMP_INFO-ICON = '@09@'. "노랑
    ELSE.
      GS_EMP_INFO-ICON = '@08@'. "초록
    ENDIF.

    MODIFY GT_EMP_INFO FROM GS_EMP_INFO.

  ENDLOOP.
ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  SET_CURRENCY
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM SET_CURRENCY .
  LOOP AT GT_EMP_INFO INTO GS_EMP_INFO.

  GS_EMP_INFO-WAERS = 'KRW'. "우선 기본 세팅

  IF GS_EMP_INFO-ZBANKCODE BETWEEN '001' AND '010'.
    GS_EMP_INFO-WAERS = 'KRW'.
  ENDIF.

  MODIFY GT_EMP_INFO FROM GS_EMP_INFO.
ENDLOOP.
ENDFORM.
