*&---------------------------------------------------------------------*
*& Report ZEDR19_038
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT ZEDR19_PRACTICE003 LINE-SIZE 200 LINE-COUNT 65(3) NO STANDARD PAGE HEADING.

*전역 선언
TABLES : ZEDT19_100, ZEDT19_101.

CONSTANTS : C_X TYPE CHAR1 VALUE 'X'.

"Range 선언
RANGES : R_FG FOR ZEDT19_100-ZSALE_FG. "매출구분
RANGES : R_ZG FOR ZEDT19_101-ZFLAG.

"시스템 날짜 설정
DATA : FIRST_DAY TYPE D,
       LAST_DAY TYPE D.

"통화 문자열 출력용
DATA : LV_AMT1 TYPE CHAR15,
       LV_AMT2 TYPE CHAR15,
       LV_AMT3 TYPE CHAR15,
       LV_AMT21 TYPE CHAR15.

"주문번호, 제품번호 0 제거하기 위한 데이터
DATA lv TYPE string.

"인터널 테이블 4개
DATA : BEGIN OF GS_ZUMUN, "주문내역 데이터
         ZORDNO  LIKE ZEDT19_100-ZORDNO, "주문번호
         ZIDCODE LIKE ZEDT19_100-ZIDCODE, "회원번호
         ZMATNR LIKE ZEDT19_100-ZMATNR, "제품번호
         ZMTART LIKE ZEDT19_100-ZMTART, "제품유형
         ZMATNAME LIKE ZEDT19_100-ZMATNAME, "제품명
         ZVOLUM LIKE ZEDT19_100-ZVOLUM, "수량
         VRKME LIKE ZEDT19_101-VRKME, "판매단위
         ZNSAMT LIKE ZEDT19_100-ZNSAMT, "판매금액
         ZSLAMT LIKE ZEDT19_100-ZSLAMT, "매출금액
         ZDCAMT LIKE ZEDT19_100-ZDCAMT, "할인금액
         ZDC_FG LIKE ZEDT19_100-ZDC_FG, "할인구분
         ZSALE_FG LIKE ZEDT19_100-ZSALE_FG, "매출구분
         ZRET_FG LIKE ZEDT19_100-ZRET_FG, "반품구분
         ZJDATE LIKE ZEDT19_100-ZJDATE, "판매일자
         ZRDATE LIKE ZEDT19_100-ZRDATE, "반품일자
       END OF GS_ZUMUN.
DATA: GT_ZUMUN LIKE TABLE OF GS_ZUMUN.

DATA : BEGIN OF GS_DELIVERY, "배송내역 데이터
  ZORDNO LIKE ZEDT19_101-ZORDNO, "주문번호
  ZIDCODE LIKE ZEDT19_101-ZIDCODE, "회원ID
  ZMATNR LIKE ZEDT19_101-ZMATNR, "제품코드
  ZMTART LIKE ZEDT19_101-ZMTART, "제품유형
  ZMATNAME LIKE ZEDT19_101-ZMATNAME, "제품명
  ZVOLUM LIKE ZEDT19_101-ZVOLUM, "수량
  VRKME LIKE ZEDT19_101-VRKME, "판매단위
  ZSLAMT LIKE ZEDT19_101-ZSLAMT, "매출금액
  ZDFLAG LIKE ZEDT19_101-ZDFLAG, "배송현황
  ZDGUBUN LIKE ZEDT19_101-ZDGUBUN, "배송지역
  ZDDATE LIKE ZEDT19_101-ZDDATE, "배송일자
  ZRDATE LIKE ZEDT19_101-ZRDATE, "반품일자
  ZFLAG LIKE ZEDT19_101-ZFLAG, "반품일자
  END OF GS_DELIVERY.
DATA : GT_DELIVERY LIKE TABLE OF GS_DELIVERY.

DATA : BEGIN OF GS_0100, "출력용 주문
  ZORDNO LIKE ZEDT19_100-ZORDNO, "주문번호
  ZIDCODE LIKE ZEDT19_100-ZIDCODE, "회원ID
  ZMATNR LIKE ZEDT19_100-ZMATNR, "제품코드
  ZMATNAME LIKE ZEDT19_100-ZMATNAME, "제품코드명
  ZMAT_NAME TYPE C LENGTH 8, "제품유형명
  ZVOLUM LIKE ZEDT19_100-ZVOLUM, "수량
  VRKME LIKE ZEDT19_100-VRKME, "단위
  AMT1 TYPE I, "판매금액
  AMT2 TYPE I, "매출금액
  AMT3 TYPE I, "할인금액
  ZSALE_NAME TYPE C LENGTH 4, "매출구분
  ZJDATE(10),
  ZRET_NAME TYPE C LENGTH 10, "반품구분
  ZDATE(10), "반품일자
  END OF GS_0100.
DATA : GT_0100 LIKE TABLE OF GS_0100.

DATA : BEGIN OF GS_0200, "출력용
  ZORDNO LIKE ZEDT19_101-ZORDNO, "주문번호
  ZIDCODE LIKE ZEDT19_101-ZIDCODE, "회원ID
  ZMATNR LIKE ZEDT19_101-ZMATNR, "제품코드
  ZMATNAME LIKE ZEDT19_101-ZMATNAME, "제품명
  ZMAT_NAME TYPE C LENGTH 8, "제품유형명
  ZVOLUM LIKE ZEDT19_101-ZVOLUM, "수량
  VRKME LIKE ZEDT19_101-VRKME, "판매단위
  AMT2 TYPE I, "매출금액
  ZDFLAG_NAME TYPE C LENGTH 8, "배송현황
  ZDGUBUN_NAME TYPE C LENGTH 6, "배송지역
  ZDDATE(10),
  ZDATE(10), "반품일자
  ZFLAG LIKE ZEDT19_101-ZFLAG, "FLAG
  END OF GS_0200.
DATA : GT_0200 LIKE TABLE OF GS_0200.

*화면 정의

"주문내역 화면 -> block 1
SELECTION-SCREEN BEGIN OF BLOCK B1 WITH FRAME.
  SELECT-OPTIONS : S_ZORDNO FOR ZEDT19_100-ZORDNO MODIF ID M1.
  SELECT-OPTIONS : S_ZID FOR ZEDT19_100-ZIDCODE NO INTERVALS NO-EXTENSION MODIF ID M1.
  SELECT-OPTIONS : S_ZMATNR FOR ZEDT19_100-ZMATNR MODIF ID M1.
  SELECT-OPTIONS : S_ZJDATE FOR ZEDT19_100-ZJDATE MODIF ID M1.
SELECTION-SCREEN END OF BLOCK B1.

*배송내역 화면 -> block 3
SELECTION-SCREEN BEGIN OF BLOCK B3 WITH FRAME.
  SELECT-OPTIONS : S_ZORDN FOR ZEDT19_100-ZORDNO MODIF ID M2.
  SELECT-OPTIONS : S_ZI  FOR ZEDT19_101-ZIDCODE NO INTERVALS NO-EXTENSION MODIF ID M2.
  SELECT-OPTIONS : S_ZMATN FOR ZEDT19_100-ZMATNR MODIF ID M2.
  SELECT-OPTIONS : S_ZDDATE FOR ZEDT19_101-ZDDATE MODIF ID M2.
SELECTION-SCREEN END OF BLOCK B3.

SELECTION-SCREEN BEGIN OF BLOCK B2 WITH FRAME.
  PARAMETERS : P_R1 RADIOBUTTON GROUP R1 DEFAULT 'X' USER-COMMAND UC1.
  PARAMETERS : P_R2 RADIOBUTTON GROUP R1.
SELECTION-SCREEN END OF BLOCK B2.

*반품체크 -> block 4
SELECTION-SCREEN BEGIN OF BLOCK B4 WITH FRAME.
  PARAMETERS : P_CH1 AS CHECKBOX DEFAULT 'X'.
SELECTION-SCREEN END OF BLOCK B4.

*기간 기본값 : 이번 달 1일~말일
INITIALIZATION.
"이번 달의 1일
FIRST_DAY = SY-DATUM(6) && '01'.

"이번 달의 마지막 날
CALL FUNCTION 'RP_LAST_DAY_OF_MONTHS'
  EXPORTING
   day_in = SY-DATUM
  IMPORTING
   last_day_of_month = LAST_DAY.

S_ZJDATE-LOW = FIRST_DAY.
S_ZJDATE-HIGH = LAST_DAY.
S_ZDDATE-LOW = FIRST_DAY.
S_ZDDATE-HIGH = LAST_DAY.
APPEND S_ZJDATE.
APPEND S_ZDDATE.

*화면 동적 제어
"라디오 버튼 선택 값에 따라 주문/배송 화면 제어
AT SELECTION-SCREEN OUTPUT.
  LOOP AT SCREEN.
    IF SCREEN-GROUP1 = 'M1'.
      IF P_R1 = C_X. "주문 버튼 활성화
        SCREEN-ACTIVE = 1.
      ELSE.
        SCREEN-ACTIVE = 0.
      ENDIF.
      MODIFY SCREEN.
    ENDIF.

    IF SCREEN-GROUP1 = 'M2'.
      IF P_R2 = C_X. "배송 버튼 활성화
        SCREEN-ACTIVE = 1.
      ELSE.
        SCREEN-ACTIVE = 0.
      ENDIF.
    ENDIF.
    MODIFY SCREEN.
ENDLOOP.

*메인 흐름
START-OF-SELECTION.
  PERFORM SELECT_DATA. "데이터 조회
  PERFORM WRITE_OUTPUT. "가공 (출력용 인터널 테이블에 적재)
  PERFORM WRITE_DATA. "출력

*인터널 테이블 적재 (출력용은 아님)
"테이블에서 조건에 맞는 데이터를 조회
FORM SELECT_DATA .
  CLEAR GT_ZUMUN[]. "비우기
  CLEAR GT_DELIVERY[]. "비우기

  IF P_R1 = C_X. "주문
    SELECT * FROM ZEDT19_100
    INTO CORRESPONDING FIELDS OF TABLE GT_ZUMUN
    WHERE ZORDNO IN S_ZORDNO
    AND ZIDCODE IN S_ZID
    AND ZMATNR IN S_ZMATNR
    AND ZJDATE IN S_ZJDATE
    AND ZSALE_FG IN R_FG. "주문내역
  ELSEIF P_R2 = C_X. "배송
    SELECT * FROM ZEDT19_101
    INTO CORRESPONDING FIELDS OF TABLE GT_DELIVERY
    WHERE ZORDNO IN S_ZORDN
    AND ZIDCODE IN S_ZI
    AND ZMATNR IN S_ZMATN
    AND ZDDATE IN S_ZDDATE
    AND ZFLAG IN R_ZG. "배송내역
  ENDIF.
ENDFORM.

"날짜 D형식에서 문자형으로 변환해주는 FORM
"DATS(2025-10-01) > CHAR(2025.10.01)로 변경"
FORM FMT_DATE_10 USING P_DATE TYPE D
                 CHANGING P_TEXT TYPE CHAR10.

  IF P_DATE IS INITIAL. "변수가 비어있는 상태인지
    CLEAR P_TEXT.
  ELSE.
    P_TEXT = P_DATE+0(4) && '.' && P_DATE+4(2) && '.' && P_DATE+6(2).
  ENDIF.
ENDFORM.

*fixed value 값들 원래 명칭대로 써주기

*제품유형 코드 -> 명칭
FORM GET_MAT_NAME USING P_ZMTART
                  CHANGING P_NAME.

  CASE P_ZMTART.
    WHEN '001'. P_NAME = '식품'.
    WHEN '002'. P_NAME = '상품'.
    WHEN '003'. P_NAME = '제품'.
    WHEN '004'. P_NAME = '의류'.
    WHEN '005'. P_NAME = '도서'.
    WHEN '006'. P_NAME = '서비스'.
  ENDCASE.
ENDFORM.

*매출유형 코드 -> 명칭
FORM GET_SALE_NAME USING P_SALE_FG
                   CHANGING P_NAME.

  CASE P_SALE_FG.
    WHEN '1'. P_NAME = '매출'.
    WHEN '2'. P_NAME = '반품'.
  ENDCASE.
ENDFORM.

*반품유형 -> 명칭
FORM GET_RET_NAME USING P_RET_FG
                  CHANGING P_NAME.

  CASE P_RET_FG.
    WHEN '1'. P_NAME = '단순변심'.
    WHEN '2'. P_NAME = '제품하자'.
    WHEN '3'. P_NAME = '배송문제'.
  ENDCASE.
ENDFORM.

*배송현황 -> 명칭
FORM GET_DFLAG_NAME USING P_DFLAG
                    CHANGING P_NAME.

  CASE P_DFLAG.
    WHEN '1'. P_NAME = '배송시작'.
    WHEN '2'. P_NAME = '배송중'.
    WHEN '3'. P_NAME = '배송완료'.
  ENDCASE.
ENDFORM.

*배송지역 -> 명칭
FORM GET_DGUBUN_NAME USING P_GUBUN
                     CHANGING P_NAME.

  CASE P_GUBUN.
    WHEN '1'. P_NAME = '서울시'.
    WHEN '2'. P_NAME = '경기도'.
    WHEN '3'. P_NAME = '충청도'.
    WHEN '4'. P_NAME = '경상도'.
    WHEN '5'. P_NAME = '강원도'.
    WHEN '6'. P_NAME = '전라도'.
    WHEN '7'. P_NAME = '제주도'.
  ENDCASE.
ENDFORM.

*통화 변환
FORM FMT_AMT USING P_VAL TYPE I
             CHANGING P_TEXT TYPE CHAR15.

P_VAL = P_VAL * 100.
WRITE P_VAL TO P_TEXT CURRENCY 'KRW' DECIMALS 0.

ENDFORM.

*문자열 앞자리 0 제거
FORM DELETE_ZERO USING p_in TYPE C
                 CHANGING p_out TYPE C.

  lv = p_in.
  SHIFT lv LEFT DELETING LEADING '0'. "문자열 왼쪽의 0을 없앤다.

  IF lv IS INITIAL.
    lv = '0'.
  ENDIF.
  p_out = lv.
ENDFORM.

*GT_ZUMUN/GT_DELIVERY -> 출력용 테이블(GT_0100/GT_0200) 변환
FORM WRITE_OUTPUT.
  CLEAR GT_0100[].
  CLEAR GT_0200[].

  IF P_R1 = C_X. "주문액
    LOOP AT GT_ZUMUN INTO GS_ZUMUN.
      CLEAR GS_0100.
      MOVE-CORRESPONDING GS_ZUMUN TO GS_0100.

      GS_0100-AMT1 = GS_ZUMUN-ZNSAMT. "판매금
      GS_0100-AMT2 = GS_ZUMUN-ZSLAMT. "매출금액
      GS_0100-AMT3 = GS_ZUMUN-ZDCAMT. "할인금액

      "FIXED_VALUE -> 명칭
      PERFORM GET_MAT_NAME USING GS_ZUMUN-ZMTART CHANGING GS_0100-ZMAT_NAME. "제품유형
      PERFORM GET_SALE_NAME USING GS_ZUMUN-ZSALE_FG CHANGING GS_0100-ZSALE_NAME. "매출구분
      PERFORM GET_RET_NAME USING GS_ZUMUN-ZRET_FG CHANGING GS_0100-ZRET_NAME. "반품구분

      "0제거
      PERFORM DELETE_ZERO USING GS_ZUMUN-ZORDNO CHANGING GS_0100-ZORDNO.
      PERFORM DELETE_ZERO USING GS_ZUMUN-ZMATNR CHANGING GS_0100-ZMATNR.

      PERFORM FMT_DATE_10 USING GS_ZUMUN-ZJDATE CHANGING GS_0100-ZJDATE.

      "반품 체크박스가 꺼져 있으면 반품 관련 컬럼 비워야 함
      IF GS_ZUMUN-ZRDATE IS NOT INITIAL.
        PERFORM FMT_DATE_10 USING GS_ZUMUN-ZRDATE CHANGING GS_0100-ZDATE.
      ELSE.
        CLEAR GS_0100-ZDATE.
      ENDIF.

      APPEND GS_0100 TO GT_0100.
    ENDLOOP.

  ELSEIF P_R2 = C_X. "배송 화면
    LOOP AT GT_DELIVERY INTO GS_DELIVERY.
      CLEAR GS_0200.
      MOVE-CORRESPONDING GS_DELIVERY TO GS_0200.

      GS_0200-AMT2 = GS_DELIVERY-ZSLAMT.

      PERFORM GET_MAT_NAME USING GS_DELIVERY-ZMTART CHANGING GS_0200-ZMAT_NAME.
      PERFORM GET_DFLAG_NAME USING GS_DELIVERY-ZDFLAG CHANGING GS_0200-ZDFLAG_NAME.
      PERFORM GET_DGUBUN_NAME USING GS_DELIVERY-ZDGUBUN CHANGING GS_0200-ZDGUBUN_NAME.

      "0제거
      PERFORM DELETE_ZERO USING GS_DELIVERY-ZORDNO CHANGING GS_0200-ZORDNO.
      PERFORM DELETE_ZERO USING GS_DELIVERY-ZMATNR CHANGING GS_0200-ZMATNR.

      PERFORM FMT_DATE_10 USING GS_DELIVERY-ZDDATE CHANGING GS_0200-ZDDATE.

      IF GS_DELIVERY-ZRDATE IS NOT INITIAL.
        PERFORM FMT_DATE_10 USING GS_DELIVERY-ZRDATE CHANGING GS_0200-ZDATE.
      ELSE.
        CLEAR GS_0200-ZDATE.
      ENDIF.

      APPEND GS_0200 TO GT_0200.
    ENDLOOP.
  ENDIF.
ENDFORM.

*출력
FORM WRITE_DATA.

  IF P_R1 = C_X. "주문내역
    LOOP AT GT_0100 INTO GS_0100.

    PERFORM fmt_amt USING gs_0100-amt1 CHANGING lv_amt1.
    PERFORM fmt_amt USING gs_0100-amt2 CHANGING lv_amt2.
    PERFORM fmt_amt USING gs_0100-amt3 CHANGING lv_amt3.

      AT FIRST.
        IF P_CH1 = C_X. "주문내역
          WRITE :/ '------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------'.
          WRITE :/ '|  주문번호  |     ID     |  제품번호  |        제품명        | 제품유형 |수량 |단위 |     판매금액    |     매출금액    |    할인금액     | 내역 |  판매일자  |  반품구분  |  반품일자  | '.
          WRITE :/ '------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------'.
        ELSE.
          WRITE :/ '----------------------------------------------------------------------------------------------------------------------------------------------------------------'.
          WRITE :/ '|  주문번호  |     ID     |  제품번호  |        제품명        | 제품유형 |수량 |단위 |     판매금액    |     매출금액    |     할인금액    | 내역 |  판매일자  | '.
          WRITE :/ '----------------------------------------------------------------------------------------------------------------------------------------------------------------'.
        ENDIF.
      ENDAT.

      IF P_CH1 = C_X.
      WRITE :/ '|',GS_0100-ZORDNO,'|',GS_0100-ZIDCODE,'|',GS_0100-ZMATNR,'|',GS_0100-ZMATNAME,'|',GS_0100-ZMAT_NAME,'|'
      ,GS_0100-ZVOLUM,'|',GS_0100-VRKME,'|',LV_AMT1,'|',LV_AMT2,'|'
      ,LV_AMT3,'|',GS_0100-ZSALE_NAME,'|',GS_0100-ZJDATE,'|',GS_0100-ZRET_NAME,'|',GS_0100-ZDATE,'|'.
      WRITE :/ '------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------'.
      ELSE.
      WRITE :/ '|',GS_0100-ZORDNO,'|',GS_0100-ZIDCODE,'|',GS_0100-ZMATNR,'|',GS_0100-ZMATNAME,'|',GS_0100-ZMAT_NAME,'|'
      ,GS_0100-ZVOLUM,'|',GS_0100-VRKME,'|',LV_AMT1,'|',LV_AMT2,'|'
      ,LV_AMT3,'|',GS_0100-ZSALE_NAME,'|',GS_0100-ZJDATE,'|'.
      WRITE :/ '----------------------------------------------------------------------------------------------------------------------------------------------------------------'.
      ENDIF.
    ENDLOOP.
  ELSEIF P_R2 = C_X.
    LOOP AT GT_0200 INTO GS_0200.
      PERFORM FMT_AMT USING GS_0200-AMT2 CHANGING LV_AMT21. "매출금액
      AT FIRST.
        IF P_CH1 = C_X.
          WRITE :/ '------------------------------------------------------------------------------------------------------------------------------------------------------'.
          WRITE :/ '|  주문번호  |     ID     |  제품번호  |        제품명        | 제품유형 |수량 |단위 |     매출금액    | 배송현황 |  지역  |  배송일자  |  반품일자  |'.
          WRITE :/ '------------------------------------------------------------------------------------------------------------------------------------------------------'.
        ELSE.
          WRITE :/ '-----------------------------------------------------------------------------------------------------------------------------------------'.
          WRITE :/ '|  주문번호  |     ID     |  제품번호  |        제품명        | 제품유형 |수량 |단위 |     매출금액    | 배송현황 |  지역  |  배송일자  | '.
          WRITE :/ '-----------------------------------------------------------------------------------------------------------------------------------------'.
        ENDIF.
      ENDAT.

      IF P_CH1 = C_X.
      WRITE :/ '|',GS_0200-ZORDNO,'|',GS_0200-ZIDCODE,'|',GS_0200-ZMATNR,'|',GS_0200-ZMATNAME,'|',GS_0200-ZMAT_NAME,'|'
      ,GS_0200-ZVOLUM,'|',GS_0200-VRKME,'|',LV_AMT21,'|',GS_0200-ZDFLAG_NAME,'|'
      ,GS_0200-ZDGUBUN_NAME,'|',GS_0200-ZDDATE,'|',GS_0200-ZDATE,'|'.
      WRITE :/ '------------------------------------------------------------------------------------------------------------------------------------------------------'.
      ELSE.
      WRITE :/ '|',GS_0200-ZORDNO,'|',GS_0200-ZIDCODE,'|',GS_0200-ZMATNR,'|',GS_0200-ZMATNAME,'|',GS_0200-ZMAT_NAME,'|'
      ,GS_0200-ZVOLUM,'|',GS_0200-VRKME,'|',LV_AMT21,'|',GS_0200-ZDFLAG_NAME,'|'
      ,GS_0200-ZDGUBUN_NAME,'|',GS_0200-ZDDATE,'|'.
      WRITE :/ '-----------------------------------------------------------------------------------------------------------------------------------------'.
      ENDIF.
    ENDLOOP.
  ENDIF.

ENDFORM.
