*&---------------------------------------------------------------------*
*& Report ZEDR05_PRACTICE006
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT ZEDR19_PRACTICE006.

* TABLES 선언
TABLES: ZEDT19_102,
        ZEDT19_103,
        ZEDT19_104,
        ZEDT19_105,
        ZEDT19_106.

DATA : ls_105 TYPE ZEDT19_105,
       lv_db_amt TYPE p DECIMALS 2,
       lv_mon_i TYPE i.

* TYPES 선언
" 사원정보 출력용 구조체
TYPES: BEGIN OF TY_EMP_INFO,
         ZPERNR    TYPE ZEDT19_102-ZPERNR,    "사원번호
         ZPNAME    TYPE ZEDT19_103-ZPNAME,    "사원이름
         ZDEPCODE  TYPE ZEDT19_102-ZDEPCODE,  "부서코드
         ZDEPNAME  TYPE CHAR20,               "부서명
         ZDEPRANK  TYPE ZEDT19_102-ZDEPRANK,  "직급코드
         ZRANKNAME TYPE CHAR20,               "직급명
         ZEDATE    TYPE ZEDT19_102-ZEDATE,    "입사일
         ZQDATE    TYPE ZEDT19_102-ZQDATE,    "퇴사일
         ZQFLAG    TYPE ZEDT19_102-ZQFLAG,    "퇴사상태(재직/퇴직)
         ZQFLAG_T  TYPE CHAR4,              "퇴사상태(한글)
         ZGENDER   TYPE CHAR4,   "성별(한글)
         ZADDRESS  TYPE ZEDT19_103-ZADDRESS,   "주소
         ZBANKCODE TYPE ZEDT19_106-ZBANKCODE, "은행코드
         ZBANKNAME TYPE CHAR20,               "은행명
         ZACCOUNT TYPE ZEDT19_106-ZACCOUNT,   "계좌번호
       END OF TY_EMP_INFO.

* 평가확인 구조체 (월급지급은 alv로 출력 안하니까 평가확인만 alv 출력하는 이터널 테이블)
TYPES: BEGIN OF TY_SALARY,
         ZPERNR   TYPE ZEDT19_102-ZPERNR,    "사원번호
         ZPNAME   TYPE ZEDT19_103-ZPNAME,    "사원명
         ZDEPCODE TYPE ZEDT19_104-ZDEPCODE,
         ZDEPNAME TYPE CHAR20, "부서명
         ZRANKNAME TYPE CHAR20, "직급명
         ZQFLAG    TYPE ZEDT19_102-ZQFLAG,    "퇴사상태(재직/퇴직)
         ZQFLAG_K  TYPE CHAR2, "퇴사상태 -> 한글변환
         ZQDATE    TYPE ZEDT19_102-ZQDATE,    "퇴사일
         ZEDATE    TYPE ZEDT19_102-ZEDATE, "입사일
         ZSALARY  TYPE ZEDT19_106-ZSALARY,   "계약금액
         ZPAY_AMT TYPE ZEDT19_106-ZSALARY,    "지급액
         ZRANK    TYPE ZEDT19_104-ZRANK,     "평가등급
         ZPERNR_I TYPE I, "사번 숫자형 필드키
         ZMON01   TYPE ZEDT19_105-ZMON01,
         ZMON02   TYPE ZEDT19_105-ZMON02,
         ZMON03   TYPE ZEDT19_105-ZMON03,
         ZMON04   TYPE ZEDT19_105-ZMON04,
         ZMON05   TYPE ZEDT19_105-ZMON05,
         ZMON06   TYPE ZEDT19_105-ZMON06,
         ZMON07   TYPE ZEDT19_105-ZMON07,
         ZMON08   TYPE ZEDT19_105-ZMON08,
         ZMON09   TYPE ZEDT19_105-ZMON09,
         ZMON10   TYPE ZEDT19_105-ZMON10,
         ZMON11   TYPE ZEDT19_105-ZMON11,
         ZMON12   TYPE ZEDT19_105-ZMON12,
       END OF TY_SALARY.

* CONSTANTS 선언
CONSTANTS: C_X           TYPE C VALUE 'X',
           C_MALE        TYPE C VALUE 'M',           "남성
           C_FEMALE      TYPE C VALUE 'F',           "여성
           C_MALE_T      TYPE CHAR8 VALUE '남자',
           C_FEMALE_T    TYPE CHAR8 VALUE '여자',
           C_RANK_A      TYPE C VALUE 'A',           "평가등급 A
           C_BONUS       TYPE P DECIMALS 2 VALUE '50000.00',  "보너스 5만원
           C_QUIT        TYPE C VALUE 'Y',           "퇴사
           C_ACTIVE      TYPE CHAR10 VALUE '재직',
           C_QUIT_T      TYPE CHAR10 VALUE '퇴직',
           C_ZERO        TYPE P DECIMALS 2 VALUE 0,
           C_TWELVE      TYPE I VALUE 12.            "12개월

* ALV 출력용 Internal Tables
DATA: GT_EMP_INFO TYPE TABLE OF TY_EMP_INFO,  "사원정보 출력용
      GS_EMP_INFO TYPE TY_EMP_INFO.

DATA: GT_SALARY TYPE TABLE OF TY_SALARY,      "월급지급 처리용
      GS_SALARY TYPE TY_SALARY.


* ALV 관련 변수

DATA: GT_FCAT   TYPE SLIS_T_FIELDCAT_ALV,     "Field Catalog
      GS_FCAT   TYPE SLIS_FIELDCAT_ALV,
      GT_SORT   TYPE SLIS_T_SORTINFO_ALV,     "Sort
      GS_SORT   TYPE SLIS_SORTINFO_ALV,
      GS_LAYOUT TYPE SLIS_LAYOUT_ALV. "Layout

* RANGES 선언
*5. 레인지변수 1번이상 사용
RANGES: R_DATE   FOR ZEDT19_102-DATAB,        "유효기간 범위
        R_PERNR  FOR ZEDT19_102-ZPERNR,       "사원번호 범위
        R_YEAR   FOR ZEDT19_104-ZYEAR.        "연도 범위

* SELECTION SCREEN
SELECTION-SCREEN BEGIN OF BLOCK B1 WITH FRAME.

  " 공통 조회조건 - 사원번호
  SELECT-OPTIONS: S_PERNR FOR ZEDT19_102-ZPERNR MODIF ID ALL.

  " 사원정보용 조회조건
  SELECT-OPTIONS: S_DATE FOR ZEDT19_102-DATAB MODIF ID M1.
  SELECT-OPTIONS: S_DEPT FOR ZEDT19_102-ZDEPCODE NO INTERVALS NO-EXTENSION MODIF ID M1.

  " 월급지급/평가확인용 조회조건
  PARAMETERS: P_YEAR  TYPE ZEDT19_104-ZYEAR MODIF ID M2,
              P_MONTH TYPE NUMC2 MODIF ID M2.

SELECTION-SCREEN END OF BLOCK B1.


SELECTION-SCREEN BEGIN OF BLOCK B2 WITH FRAME.
  " 라디오버튼 - 3가지 기능
  PARAMETERS: P_RAD1 RADIOBUTTON GROUP RB1 DEFAULT 'X' USER-COMMAND UC1,
              P_RAD2 RADIOBUTTON GROUP RB1,
              P_RAD3 RADIOBUTTON GROUP RB1.

SELECTION-SCREEN END OF BLOCK B2.



SELECTION-SCREEN BEGIN OF BLOCK B3 WITH FRAME.

  PARAMETERS: P_CHK1 AS CHECKBOX DEFAULT 'X' MODIF ID M1. "재직여부

SELECTION-SCREEN END OF BLOCK B3.

* 기본값 세팅 : 날짜 기간 세팅
INITIALIZATION.

  PERFORM GET_LAST_OF_DAY.

*
AT SELECTION-SCREEN OUTPUT.
  PERFORM SET_SCREEN_CONTROL.

* 사용자 입력값 검증 (유효한 날짜인지, 타입이 맞는지 등)
AT SELECTION-SCREEN.
  PERFORM CHECK_INPUT_VALUE.

* 메인 프로세스 실행
START-OF-SELECTION.
  PERFORM MAIN_PROCESS.

END-OF-SELECTION.

* GET_LAST_OF_DAY
* 시스템 날짜를 기준으로 P_YEAR을 설정하고 S_DATE 설정
form GET_LAST_OF_DAY.

  P_YEAR  = SY-DATUM(4).      "현재연도
  P_MONTH = SY-DATUM+4(2).    "현재월

  " 사원정보 기본값 설정
  S_DATE-SIGN   = 'I'.
  S_DATE-OPTION = 'BT'.
  S_DATE-LOW    = SY-DATUM(4) && '0101'.  "올해 1월 1일

  CALL FUNCTION 'RP_LAST_DAY_OF_MONTHS'
    exporting
      DAY_IN            =  SY-DATUM
    importing
      LAST_DAY_OF_MONTH =   S_DATE-HIGH
    exceptions
      DAY_IN_NO_DATE    = 1
      OTHERS            = 2
    .
  if sy-subrc <> 0.
  endif.
  APPEND S_DATE.
endform.

* SET_SCREEN_CONTROL.
* 라디오 버튼 선택값에 따라 화면 그룹 설정
FORM set_screen_control .

  LOOP AT SCREEN.

    " ALL 그룹: 항상 활성
    IF screen-group1 = 'ALL'.
      screen-active = 1.
      MODIFY SCREEN.
      CONTINUE.
    ENDIF.

    " M1 그룹: 사원정보 라디오(P_RAD1) 선택 시만 활성
    IF screen-group1 = 'M1'.
      IF p_rad1 = c_x.
        screen-active = 1.
      ELSE.
        screen-active = 0.
      ENDIF.
      MODIFY SCREEN.
      CONTINUE.
    ENDIF.

    IF screen-group1 = 'M2'.
      IF p_rad2 = c_x OR p_rad3 = c_x.
        screen-active = 1.
      ELSE.
        screen-active = 0.
      ENDIF.
      MODIFY SCREEN.
      CONTINUE.
    ENDIF.

  ENDLOOP.

ENDFORM.


* CHECK_INPUT_VALUE
* 라디오버튼 선택값에 따라 필수 입력값을 검증하고 잘못된 경우 오류 메시지 출력 -> STOP
form CHECK_INPUT_VALUE .

  IF P_RAD1 = C_X.  " 사원정보 조회
    IF S_DATE[] IS INITIAL.
      MESSAGE '조회기간을 입력해주세요.' TYPE 'E'.
      STOP.
    ENDIF.
  ELSEIF P_RAD2 = C_X.  " 월급지급
      IF P_YEAR IS INITIAL.
        MESSAGE '지급연도를 입력해주세요.' TYPE 'E'.
        STOP.
      ENDIF.

      IF P_MONTH IS INITIAL.
        MESSAGE '지급월을 입력해주세요.' TYPE 'E'.
        STOP.
      ENDIF.

      " 월 유효성 검증 (1~12)
      IF P_MONTH < 1 OR P_MONTH > 12.
        MESSAGE '월은 1~12 사이의 값이어야 합니다.' TYPE 'E'.
        STOP.
      ENDIF.
    ELSEIF P_RAD3 = C_X.  " 평가확인
      IF P_YEAR IS INITIAL.
        MESSAGE '조회연도를 입력해주세요.' TYPE 'E'.
        STOP.
      ENDIF.
    ENDIF.
ENDFORM.

* MAIN_PROCESS
* 라디오버튼 선택값에 따라 각각의 로직을 분기해 처리
FORM MAIN_PROCESS.
  " 라디오 버튼에 따른 분기 처리
  IF P_RAD1 = C_X.  " 사원정보 조회
    PERFORM GET_EMPLOYEE_INFO. " 사원 정보 select문
    PERFORM DISPLAY_ALV_EMP_INFO. "사원 정보 ALV 출력문
  ELSEIF P_RAD2 = C_X.  " 월급지급
    PERFORM GET_PAYMENT_INFO. " 대상 조회
    PERFORM PROCESS_PAYMENT. " 데이터 가공
  ELSEIF P_RAD3 = C_X.  " 평가확인
    PERFORM GET_PAYMENT_INFO.
    PERFORM DISPLAY_ALV_SALARY.
  ENDIF.
ENDFORM.

FORM process_payment .

  DATA: lv_pay_date TYPE d,
        lv_dayin    TYPE d,
        lv_amt      TYPE zedt19_106-zsalary,
        lv_db_amt   TYPE p DECIMALS 2,
        lv_updated  TYPE i,
        lv_mon_i    TYPE i.

  DATA: lv_pernr TYPE zedt19_105-zpernr,   "키 타입과 동일
        lv_year  TYPE zedt19_105-zyear,
        ls_105   TYPE zedt19_105,
        ls_exist TYPE zedt19_105.


  " 말일 계산
  lv_dayin = |{ p_year }{ p_month }01|.
  CALL FUNCTION 'RP_LAST_DAY_OF_MONTHS'
    EXPORTING  day_in = lv_dayin
    IMPORTING  last_day_of_month = lv_pay_date.

  lv_mon_i = p_month.    " '03' -> 3 (암묵변환으로 충분)

  LOOP AT gt_salary INTO gs_salary.

    "---- ① 키값 정규화: 무조건 루프 첫 줄에 ----
    lv_pernr = gs_salary-zpernr.
    CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
      EXPORTING  input  = lv_pernr
      IMPORTING  output = lv_pernr.
    lv_year  = p_year.

*    CLEAR ls_exist.
*    SELECT SINGLE zpernr, zyear
*      FROM zedt19_105
*      INTO CORRESPONDING FIELDS OF @ls_exist
*      WHERE zpernr = @lv_pernr
*        AND zyear  = @lv_year.

    " ③ 퇴사/평가 제외
    IF gs_salary-zqflag IS NOT INITIAL AND gs_salary-zqdate <= lv_pay_date.
      CONTINUE.
    ENDIF.
    IF gs_salary-zrank IS INITIAL.
      CONTINUE.
    ENDIF.

    " ⑤ 지급액 계산
    lv_amt = gs_salary-zsalary / c_twelve.
    IF gs_salary-zrank = c_rank_a.
      lv_amt = lv_amt + c_bonus.
    ENDIF.
    IF lv_amt = c_zero.
      CONTINUE.
    ENDIF.

    " ⑥ 스케일 변환 (예: 1000원 -> 10.00)
    lv_db_amt = lv_amt / 100.

    IF sy-subrc <> 0.
      CLEAR ls_105.
      ls_105-zpernr = lv_pernr.
      ls_105-zyear  = lv_year.
      INSERT zedt19_105 FROM @ls_105.
      IF sy-subrc <> 0.
        ROLLBACK WORK. MESSAGE '월급지급 실패' TYPE 'E'. STOP.
      ENDIF.
    ENDIF.

    "---- ④ 월별 CASE로 UPDATE (항상 lv_pernr/lv_year 사용!) ----
    CASE lv_mon_i.
      WHEN 1.
        UPDATE zedt19_105
           SET zmon01 = @lv_db_amt,
               aename = @sy-uname,
               aedate = @sy-datum,
               aezeit = @sy-uzeit
         WHERE zpernr = @lv_pernr
           AND zyear  = @lv_year.
           gs_salary-zpay_amt = lv_db_amt.

      WHEN 2.
        UPDATE zedt19_105
           SET zmon02 = @lv_db_amt,
               aename = @sy-uname,
               aedate = @sy-datum,
               aezeit = @sy-uzeit
         WHERE zpernr = @lv_pernr
           AND zyear  = @lv_year.
           gs_salary-zpay_amt = lv_db_amt.

      WHEN 3.
        UPDATE zedt19_105
           SET zmon03 = @lv_db_amt,
               aename = @sy-uname,
               aedate = @sy-datum,
               aezeit = @sy-uzeit
         WHERE zpernr = @lv_pernr
           AND zyear  = @lv_year.
           gs_salary-zpay_amt = lv_db_amt.

      WHEN 4.
        UPDATE zedt19_105
           SET zmon04 = @lv_db_amt,
               aename = @sy-uname,
               aedate = @sy-datum,
               aezeit = @sy-uzeit
         WHERE zpernr = @lv_pernr
           AND zyear  = @lv_year.
           gs_salary-zpay_amt = lv_db_amt.

      WHEN 5.
        UPDATE zedt19_105
           SET zmon05 = @lv_db_amt,
               aename = @sy-uname,
               aedate = @sy-datum,
               aezeit = @sy-uzeit
         WHERE zpernr = @lv_pernr
           AND zyear  = @lv_year.
           gs_salary-zpay_amt = lv_db_amt.

      WHEN 6.
        UPDATE zedt19_105
           SET zmon06 = @lv_db_amt,
               aename = @sy-uname,
               aedate = @sy-datum,
               aezeit = @sy-uzeit
         WHERE zpernr = @lv_pernr
           AND zyear  = @lv_year.
           gs_salary-zpay_amt = lv_db_amt.

      WHEN 7.
        UPDATE zedt19_105
           SET zmon07 = @lv_db_amt,
               aename = @sy-uname,
               aedate = @sy-datum,
               aezeit = @sy-uzeit
         WHERE zpernr = @lv_pernr
           AND zyear  = @lv_year.
           gs_salary-zpay_amt = lv_db_amt.

      WHEN 8.
        UPDATE zedt19_105
           SET zmon08 = @lv_db_amt,
               aename = @sy-uname,
               aedate = @sy-datum,
               aezeit = @sy-uzeit
         WHERE zpernr = @lv_pernr
           AND zyear  = @lv_year.
           gs_salary-zpay_amt = lv_db_amt.

      WHEN 9.
        UPDATE zedt19_105
           SET zmon09 = @lv_db_amt,
               aename = @sy-uname,
               aedate = @sy-datum,
               aezeit = @sy-uzeit
         WHERE zpernr = @lv_pernr
           AND zyear  = @lv_year.
           gs_salary-zpay_amt = lv_db_amt.

      WHEN 10.
        UPDATE zedt19_105
           SET zmon10 = @lv_db_amt,
               aename = @sy-uname,
               aedate = @sy-datum,
               aezeit = @sy-uzeit
         WHERE zpernr = @lv_pernr
           AND zyear  = @lv_year.
           gs_salary-zpay_amt = lv_db_amt.

      WHEN 11.
        UPDATE zedt19_105
           SET zmon11 = @lv_db_amt,
               aename = @sy-uname,
               aedate = @sy-datum,
               aezeit = @sy-uzeit
         WHERE zpernr = @lv_pernr
           AND zyear  = @lv_year.
           gs_salary-zpay_amt = lv_db_amt.

      WHEN 12.
        UPDATE zedt19_105
           SET zmon12 = @lv_db_amt,
               aename = @sy-uname,
               aedate = @sy-datum,
               aezeit = @sy-uzeit
         WHERE zpernr = @lv_pernr
           AND zyear  = @lv_year.
           gs_salary-zpay_amt = lv_db_amt.

      WHEN OTHERS.
        ROLLBACK WORK. MESSAGE '유효하지 않은 월입니다.' TYPE 'E'. STOP.
    ENDCASE.

    IF sy-subrc <> 0 OR sy-dbcnt = 0.
      ROLLBACK WORK. MESSAGE '월급지급 실패' TYPE 'E'. STOP.
    ENDIF.

    lv_updated = lv_updated + sy-dbcnt.

    MODIFY gt_salary FROM gs_salary.

  ENDLOOP.

  IF lv_updated > 0.
    COMMIT WORK.
    MESSAGE '월급이 지급되었습니다.' TYPE 'S'.
  ELSE.
    MESSAGE '지급 대상이 없습니다.' TYPE 'I'.
  ENDIF.

ENDFORM.


* 월급 alv display
FORM DISPLAY_ALV_SALARY.
  PERFORM SET_FIELDCAT_SALARY.
  PERFORM SET_SORT_SALARY.

  GS_LAYOUT-ZEBRA = 'X'.
  GS_LAYOUT-COLWIDTH_OPTIMIZE = 'X'.

  CALL FUNCTION 'REUSE_ALV_GRID_DISPLAY'
    EXPORTING
      I_CALLBACK_PROGRAM = SY-REPID
      IS_LAYOUT          = GS_LAYOUT
      IT_FIELDCAT        = GT_FCAT
      IT_SORT            = GT_SORT
    TABLES
      T_OUTTAB           = GT_SALARY
    EXCEPTIONS
      PROGRAM_ERROR      = 1
      OTHERS             = 2.

    IF SY-SUBRC <> 0.
      MESSAGE 'ALV 출력 중 오류가 발생했습니다.' TYPE 'E'.
    ENDIF.

ENDFORM.

FORM SET_FIELDCAT_SALARY.

  DATA : lv_pay_coltext TYPE CHAR50.

  lv_pay_coltext = |{ p_month }월 지급액|.

  CLEAR GT_FCAT.

  PERFORM ADD_FIELDCAT USING 'ZPERNR' '사원번호' '10'.

  PERFORM ADD_FIELDCAT USING 'ZPNAME' '사원이름' '15'.

  PERFORM ADD_FIELDCAT USING 'ZDEPCODE' '부서코드' '10'.

  PERFORM ADD_FIELDCAT USING 'ZDEPNAME' '부서명' '20'.

  PERFORM ADD_FIELDCAT USING 'ZRANKNAME' '직급명' '15'.

  PERFORM ADD_FIELDCAT USING 'ZEDATE' '입사일' '10'.

  "계약금액
  PERFORM ADD_FIELDCAT USING 'ZSALARY' '계약금액' '30'.

  "평가등급
  PERFORM ADD_FIELDCAT USING 'ZRANK' '평가등급' '4'.

  "n월 지급액
  PERFORM ADD_FIELDCAT USING 'ZPAY_AMT' lv_pay_coltext '10'.

ENDFORM.

* 정렬 문자형 데이터를 숫자형 데이터로
* SET_SORT_SALARY
FORM set_sort_salary.

  " 숫자 정렬키 채우기 (선행 0이 있어도 CONV i(...)가 알아서 처리)
  LOOP AT gt_salary INTO gs_salary.
    gs_salary-zpernr_i = CONV i( gs_salary-zpernr ).
    MODIFY gt_salary FROM gs_salary TRANSPORTING zpernr_i.
  ENDLOOP.

  " 숫자형 키로 정렬
  SORT gt_salary BY zpernr_i ASCENDING.

ENDFORM.

* GET_EMPLOYEE_INFO
* 사원정보 조회
form GET_EMPLOYEE_INFO .
  SELECT
      A~ZPERNR,      B~ZPNAME,      A~ZDEPRANK,      A~ZDEPCODE,
      A~ZEDATE,      A~ZQDATE,      A~ZQFLAG,      B~ZGENDER,
      B~ZADDRESS,      C~ZBANKCODE,      C~ZACCOUNT
    FROM ZEDT19_102 AS A
    LEFT OUTER JOIN ZEDT19_103 AS B
      ON A~ZPERNR = B~ZPERNR
    LEFT OUTER JOIN ZEDT19_106 AS C
      ON A~ZPERNR = C~ZPERNR
    WHERE
      A~ZPERNR IN @S_PERNR
    AND
      A~ZEDATE IN @S_DATE
    INTO CORRESPONDING FIELDS OF TABLE @GT_EMP_INFO.


  IF P_CHK1 = C_X.
    DELETE
      GT_EMP_INFO
    WHERE
      ZQDATE IS NOT INITIAL
    AND
      ZQDATE <= S_DATE-HIGH.
  ENDIF.

  PERFORM CONVERT_KOR. "코드값을 구체적인 값으로 변환
endform.

* CONVERT_KOR
* 코드값(성별,퇴직상태,부서,직급,은행)을 명칭으로 변환하여 데이터 표시
form CONVERT_KOR .

  DATA : lv_pernr TYPE zedt19_103-zpernr.

  LOOP AT GT_EMP_INFO INTO GS_EMP_INFO.

    lv_pernr = gs_emp_info-zpernr.
    CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
      EXPORTING  input  = lv_pernr
      IMPORTING  output = lv_pernr.

    IF GS_EMP_INFO-ZGENDER = 'M'.
      GS_EMP_INFO-ZGENDER = C_MALE_T.
    ELSE.
      GS_EMP_INFO-ZGENDER = C_FEMALE_T.
    ENDIF.

    IF GS_EMP_INFO-ZQFLAG IS NOT INITIAL.
      GS_EMP_INFO-ZQFLAG_T = C_QUIT_T.
    ELSE.
      GS_EMP_INFO-ZQFLAG_T = C_ACTIVE.
    ENDIF.

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
endform.

* 데이터 준비 -> 메타데이터 준비
* 메타데이터 : 필드카탈로그(어떤 칼럼을 어떤 제목/길이/형식으로 보여줄지 정의), 레이아웃(지브라/자동폭/그리드 옵션 등), 정렬/소계
* 메타데이터 준비 -> 호출 (REUSE_ALV_GRID_DISPLAY)

* DISPLAY_ALV_EMP_INFO
* 그리드 표시하고 사원정보 ALV 출력
form DISPLAY_ALV_EMP_INFO .
  PERFORM SET_FIELDCAT_EMP_INFO.
  PERFORM SET_SORT_EMP_INFO.

  GS_LAYOUT-ZEBRA = 'X'.
  GS_LAYOUT-COLWIDTH_OPTIMIZE = 'X'.

  CALL FUNCTION 'REUSE_ALV_GRID_DISPLAY'
    EXPORTING
      I_CALLBACK_PROGRAM = SY-REPID
      IS_LAYOUT          = GS_LAYOUT
      IT_FIELDCAT        = GT_FCAT
      IT_SORT            = GT_SORT
    TABLES
      T_OUTTAB           = GT_EMP_INFO
    EXCEPTIONS
      PROGRAM_ERROR      = 1
      OTHERS             = 2.

    IF SY-SUBRC <> 0.
      MESSAGE 'ALV 출력 중 오류가 발생했습니다.' TYPE 'E'.
    ENDIF.
endform.

* SET_FIELDCAT_EMP_INFO
* 사원정보 ALV용 필드카탈로그 구성
form SET_FIELDCAT_EMP_INFO .
  CLEAR GT_FCAT.

    " 사원번호
  PERFORM ADD_FIELDCAT USING 'ZPERNR' '사원번호' '10'.

  " 사원이름
  PERFORM ADD_FIELDCAT USING 'ZPNAME' '사원이름' '20'.

  " 부서코드
  PERFORM ADD_FIELDCAT USING 'ZDEPCODE' '부서코드' '10'.

  " 부서명
  PERFORM ADD_FIELDCAT USING 'ZDEPNAME' '부서명' '20'.

  " 직급명
  PERFORM ADD_FIELDCAT USING 'ZRANKNAME' '직급명' '15'.

  " 입사일
  PERFORM ADD_FIELDCAT USING 'ZEDATE' '입사일' '10'.

  " 퇴사상태
  PERFORM ADD_FIELDCAT USING 'ZQFLAG_T' '퇴사상태' '10'.

  " 성별
  PERFORM ADD_FIELDCAT USING 'ZGENDER' '성별' '10'.

  " 주소
  PERFORM ADD_FIELDCAT USING 'ZADDRESS' '주소' '30'.

  " 은행코드
  PERFORM ADD_FIELDCAT USING 'ZBANKCODE' '은행코드' '10'.

  " 은행명
  PERFORM ADD_FIELDCAT USING 'ZBANKNAME' '은행명' '20'.

  " 계좌번호
  PERFORM ADD_FIELDCAT USING 'ZACCOUNT' '계좌번호' '20'.

ENDFORM.


FORM ADD_FIELDCAT USING P_FIELDNAME TYPE CHAR30
                        P_TEXT TYPE CHAR50
                        P_OUTPUTLEN TYPE CHAR10.

  CLEAR : GS_FCAT.

  GS_FCAT-FIELDNAME = P_FIELDNAME.
  GS_FCAT-SELTEXT_M = P_TEXT.
  GS_FCAT-OUTPUTLEN = P_OUTPUTLEN.
  GS_FCAT-DO_SUM = 'X'.

  IF p_fieldname = 'ZPERNR' OR p_fieldname = 'ZPNAME'. "원하는 키 필드 추가 가능
    GS_FCAT-KEY        = 'X'.
    GS_FCAT-EMPHASIZE  = 'C500'.  "보통 파랑
  ENDIF.

  APPEND GS_FCAT TO GT_FCAT.
ENDFORM.

* SET_SORT_EMP_INFO
* ALV 정렬 설정 : 사번 -> 부서코드 오름차순으로 정렬 구성
FORM SET_SORT_EMP_INFO.
  CLEAR GT_SORT.

  " 사원번호로 정렬
  CLEAR GS_SORT.
  GS_SORT-FIELDNAME = 'ZPERNR'.
  GS_SORT-UP = 'X'.
  APPEND GS_SORT TO GT_SORT.

  " 부서코드로 정렬
  CLEAR GS_SORT.
  GS_SORT-FIELDNAME = 'ZDEPCODE'.
  GS_SORT-UP = 'X'.
  APPEND GS_SORT TO GT_SORT.
ENDFORM.

FORM get_payment_info .

  DATA: lv_last_day TYPE d,
        lv_pay_date TYPE d,
        lv_dayin    TYPE d.

  CLEAR gt_salary.

  SELECT
    a~zpernr,
    b~zpname,
    a~zdepcode,
    a~zedate,
    a~zqflag,
    a~zqdate,
    c~zsalary,
    d~zrank,
    e~zmon01, e~zmon02, e~zmon03, e~zmon04,
    e~zmon05, e~zmon06, e~zmon07, e~zmon08,
    e~zmon09, e~zmon10, e~zmon11, e~zmon12
  FROM  zedt19_102 AS a
  LEFT OUTER JOIN zedt19_103 AS b
    ON a~zpernr = b~zpernr
  LEFT OUTER JOIN zedt19_104 AS d
    ON a~zpernr = d~zpernr
   AND d~zyear  = @p_year
  LEFT OUTER JOIN zedt19_106 AS c
    ON a~zpernr = c~zpernr
  LEFT OUTER JOIN ZEDT19_105 AS e
    ON a~zpernr = e~zpernr
    AND e~zyear = @p_year
  WHERE a~zpernr IN @s_pernr
  INTO CORRESPONDING FIELDS OF TABLE @gt_salary.

  " 월 마지막 날 계산
  lv_dayin = |{ p_year }{ p_month }01|.
  CALL FUNCTION 'RP_LAST_DAY_OF_MONTHS'
    EXPORTING  day_in = lv_dayin
    IMPORTING  last_day_of_month = lv_last_day.

  lv_pay_date = lv_last_day.

  " 불필요한 행 제거 (퇴사자/평가X/급여X)
  DELETE gt_salary
    WHERE ( zqflag IS NOT INITIAL AND zqdate <= lv_pay_date )
       OR zsalary = c_zero
       OR zrank   IS INITIAL.

  " 부서명/직급명 치환
  LOOP AT gt_salary INTO gs_salary.

    IF gs_salary-zqflag = 'X'.
      DELETE gt_salary INDEX sy-tabix.
      CONTINUE.
    ENDIF.

    " 2️⃣ 재직자면 ZQFLAG_X = '재직' 세팅
    IF gs_salary-zqflag IS INITIAL.
      gs_salary-zqflag_k = '재직'.
    ENDIF.

    CASE gs_salary-zdepcode.
      WHEN 'SS0001'. gs_salary-zdepname = '회계팀'.
      WHEN 'SS0002'. gs_salary-zdepname = '구매팀'.
      WHEN 'SS0003'. gs_salary-zdepname = '인사팀'.
      WHEN 'SS0004'. gs_salary-zdepname = '영업팀'.
      WHEN 'SS0005'. gs_salary-zdepname = '생산팀'.
      WHEN 'SS0006'. gs_salary-zdepname = '관리팀'.
    ENDCASE.

    CASE gs_salary-zrank.
      WHEN 'A'. gs_salary-zrankname = '인턴'.
      WHEN 'B'. gs_salary-zrankname = '사원'.
      WHEN 'C'. gs_salary-zrankname = '대리'.
      WHEN 'D'. gs_salary-zrankname = '과장'.
      WHEN 'E'. gs_salary-zrankname = '차장'.
      WHEN 'F'. gs_salary-zrankname = '부장'.
      WHEN 'G'. gs_salary-zrankname = '임원'.
    ENDCASE.

    IF sy-subrc = 0.
      CASE p_month.
        WHEN 1.  gs_salary-zpay_amt = gs_salary-zmon01.
        WHEN 2.  gs_salary-zpay_amt = gs_salary-zmon02.
        WHEN 3.  gs_salary-zpay_amt = gs_salary-zmon03.
        WHEN 4.  gs_salary-zpay_amt = gs_salary-zmon04.
        WHEN 5.  gs_salary-zpay_amt = gs_salary-zmon05.
        WHEN 6.  gs_salary-zpay_amt = gs_salary-zmon06.
        WHEN 7.  gs_salary-zpay_amt = gs_salary-zmon07.
        WHEN 8.  gs_salary-zpay_amt = gs_salary-zmon08.
        WHEN 9.  gs_salary-zpay_amt = gs_salary-zmon09.
        WHEN 10. gs_salary-zpay_amt = gs_salary-zmon10.
        WHEN 11. gs_salary-zpay_amt = gs_salary-zmon11.
        WHEN 12. gs_salary-zpay_amt = gs_salary-zmon12.
      ENDCASE.
    ENDIF.

    MODIFY gt_salary FROM gs_salary.
  ENDLOOP.

ENDFORM.
