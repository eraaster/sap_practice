*&---------------------------------------------------------------------*
*& Report ZEDR19_PRACTICE002
*&---------------------------------------------------------------------*
*&  ZEDT19_0001 / 0002 / 0004 를 이용해서
*&  전과대상 / 학사경고 / 남·여 합계를 출력
*&---------------------------------------------------------------------*
REPORT ZEDR19_PRACTICE002.

CONSTANTS: c_rate TYPE i VALUE 100.   "금액 배율

"--------------------------------------------------------------------"
" 출력용 결과 구조
"--------------------------------------------------------------------"
TYPES: BEGIN OF ty_result,
         zcode   TYPE zedt19_0001-zcode,
         zname   TYPE zedt19_0001-zkname,
         lv_stop TYPE c LENGTH 10,    "학사경고 여부
         lv_major TYPE c LENGTH 10,   "전과대상 여부
         lv_tel  TYPE c LENGTH 20,    "전화번호
       END OF ty_result.

" 성별별 합계 구조
TYPES: BEGIN OF ty_sum,
         zgender TYPE zedt19_0001-zgender,
         amount  TYPE zedt19_004-zsum,
       END OF ty_sum.

" 성별 합계 테이블 / 워크에리어
DATA: gt_sum TYPE SORTED TABLE OF ty_sum WITH UNIQUE KEY zgender,
      gs_sum TYPE ty_sum.

" 학생별 출력 결과 테이블
DATA: gt_result TYPE STANDARD TABLE OF ty_result WITH DEFAULT KEY,
      gs_result TYPE ty_result.

" 합계 출력용 변수
DATA: lv_tel    TYPE c LENGTH 20,
      lv_female TYPE zedt19_004-zsum,
      lv_major  TYPE c LENGTH 20,
      lv_stop   TYPE c LENGTH 20,
      lv_male   TYPE zedt19_004-zsum.

" 원본 테이블 전체를 읽어올 인터널 테이블
DATA: gt_zedt001 TYPE STANDARD TABLE OF zedt19_0001 WITH DEFAULT KEY,
      gt_zedt002 TYPE STANDARD TABLE OF zedt19_002  WITH DEFAULT KEY,
      gt_zedt004 TYPE STANDARD TABLE OF zedt19_004  WITH DEFAULT KEY.

DATA: gs_zedt001 TYPE zedt19_0001,
      gs_zedt002 TYPE zedt19_002,
      gs_zedt004 TYPE zedt19_004.

"--------------------------------------------------------------------"
" 1. 데이터 읽기
"--------------------------------------------------------------------"
" 학생 기본정보
SELECT * FROM zedt19_0001 INTO CORRESPONDING FIELDS OF TABLE gt_zedt001.
" 전과 정보
SELECT * FROM zedt19_002  INTO CORRESPONDING FIELDS OF TABLE gt_zedt002.
" 성적/평점 정보
SELECT * FROM zedt19_004  INTO CORRESPONDING FIELDS OF TABLE gt_zedt004.

"--------------------------------------------------------------------"
" 2. 데이터 정렬 및 대표 성적만 남기기
"--------------------------------------------------------------------"
SORT gt_zedt001 BY zcode.
SORT gt_zedt002 BY zcode.
SORT gt_zedt004 BY zcode zgrade DESCENDING.

" 같은 학생코드 중 가장 높은 학년(또는 대표 성적)만 남김
DELETE ADJACENT DUPLICATES FROM gt_zedt004 COMPARING zcode.

CLEAR: gs_zedt001, gs_result.

"--------------------------------------------------------------------"
" 3. 학생별 전과/학사경고/전화번호/성별합계 가공
"--------------------------------------------------------------------"
LOOP AT gt_zedt004 INTO gs_zedt004.

  CLEAR: gs_zedt001, gs_zedt002, lv_major, lv_tel, lv_stop.

  " 공백 성적은 제외
  IF gs_zedt004-zgrade IS INITIAL.
    CONTINUE.
  ENDIF.

  " 학생 기본정보 / 전과정보 읽기
  READ TABLE gt_zedt001 INTO gs_zedt001
       WITH KEY zcode = gs_zedt004-zcode.
  READ TABLE gt_zedt002 INTO gs_zedt002
       WITH KEY zcode = gs_zedt004-zcode.

  " 전과대상 여부 (입학 당시 학과와 대표성적 학과가 다를 경우)
  IF sy-subrc = 0 AND
     gs_zedt002-zmajor IS NOT INITIAL AND
     gs_zedt002-zmajor <> gs_zedt004-zmajor.
    lv_major = '전과대상'.
  ENDIF.

  " D 또는 F 이면 학사경고 + 전화번호 표시
  IF gs_zedt004-zgrade = 'D' OR gs_zedt004-zgrade = 'F'.
    lv_stop = '학사경고'.
    lv_tel  = gs_zedt001-ztel.
  ELSE.
    lv_stop = ' '.
    lv_tel  = ' '.
  ENDIF.

  " 결과 구조 세팅
  CLEAR gs_result.
  gs_result-zcode   = gs_zedt001-zcode.
  gs_result-zname   = gs_zedt001-zkname.
  gs_result-lv_stop = lv_stop.
  gs_result-lv_major = lv_major.
  gs_result-lv_tel  = lv_tel.
  APPEND gs_result TO gt_result.

  " 성별별 합계 집계
  CLEAR gs_sum.
  gs_sum-zgender = gs_zedt001-zgender.
  gs_sum-amount  = gs_zedt004-zsum.
  COLLECT gs_sum INTO gt_sum.

ENDLOOP.

"--------------------------------------------------------------------"
" 4. 남/여 합계 계산
"--------------------------------------------------------------------"
CLEAR: lv_male, lv_female, gs_sum.

READ TABLE gt_sum INTO gs_sum WITH KEY zgender = 'M'.
IF sy-subrc = 0.
  lv_male = gs_sum-amount * c_rate.
ENDIF.

CLEAR gs_sum.
READ TABLE gt_sum INTO gs_sum WITH KEY zgender = 'F'.
IF sy-subrc = 0.
  lv_female = gs_sum-amount * c_rate.
ENDIF.

"--------------------------------------------------------------------"
" 5. 출력
"--------------------------------------------------------------------"
LOOP AT gt_result INTO gs_result.

  AT FIRST.
    WRITE: / '---------------------------------------------------------------------------------------'.
    WRITE: / '|  학생코드  |         이름         |   전과대상  |     전화번호         |    적요    |'.
    WRITE: / '---------------------------------------------------------------------------------------'.
  ENDAT.

  WRITE: / '|', gs_result-zcode,
         '|', gs_result-zname,
         '|', gs_result-lv_major,
         ' |', gs_result-lv_tel,
         '|', gs_result-lv_stop,
         '|'.
  WRITE: / '---------------------------------------------------------------------------------------'.

ENDLOOP.

WRITE: / '남학생 합계 :', lv_male   DECIMALS 0.
WRITE: / '여학생 합계 :', lv_female DECIMALS 0.
