*&---------------------------------------------------------------------*
*& Report ZEDR19_024
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT ZEDR19_024.

"인터널 테이블 선언 (헤더라인 없는 테이블)
DATA GT_GRADE TYPE STANDARD TABLE OF ZEDT19_004 WITH DEFAULT KEY.

"Work Area 선언
DATA GS_GRADE TYPE ZEDT19_004.

"인터널 테이블(GT_GRADE)에 데이터를 다 담는 명령
SELECT * FROM ZEDT19_004 INTO CORRESPONDING FIELDS OF TABLE GT_GRADE.

"루프안에서 값을 담아놓기 위한 임시 전역변수(?)
DATA : lv_all_a TYPE abap_bool, "해당 학생 전 과목 A 여부 플래그 (장학조건)
       lv_base_amt TYPE I, "학생의 등록금 대푯값 (학생코드별로 최댓값으로 설정)
       lv_pay_amt TYPE I, "최종 납부금(할인 반영)
       lv_rep_idx TYPE SY-TABIX, "대표행(=그룹 첫 행) 인덱스 저장
       lv_zflag TYPE C LENGTH 4, "장학표시('X' 또는 공백)
       lv_total TYPE I. "전체 합계

"정렬
SORT GT_GRADE BY ZCODE.

LOOP AT GT_GRADE INTO GS_GRADE.

  AT NEW ZCODE. "ZCODE별로 첫번째 레코드
    lv_zflag = ' '. "초기화하지 않으면 이전값 잔류
    lv_all_a = abap_true. "초기엔 전과목 A라고 가정
    lv_base_amt = GS_GRADE-ZSUM.
    lv_rep_idx = SY-TABIX. "대표행 = 첫 행
    "SY-TABIX = 지금 루프를 돌고 있는 현재 행의 인덱스 번호
    lv_pay_amt = 0.
  ENDAT.

  "한 과목이라도 A가 아니면 false.
  IF GS_GRADE-ZGRADE <> 'A'.
    lv_all_a = abap_false.
  ENDIF.

  lv_base_amt = GS_GRADE-ZSUM. "하나만 남겨야 하기 떄문

"IF 를 END OF 밖으로 빼니까 되네...?
  IF lv_all_a = abap_true.
      lv_zflag = 'X'.
      "여기 문제가 생김, 정렬 문제 때문에 GS_GRADE-ZSCHOOL을 쓰면 안 됨 -> 해결 loop문 안에 안 쓰니까 되던데..?
      IF GS_GRADE-ZSCHOOL = 'A'.
        lv_pay_amt = lv_base_amt * 80 / 100. "학부 20% 할인
      ELSE.
        lv_pay_amt = lv_base_amt * 90 / 100. "대학원생 10% 할인
      ENDIF.
    ELSE.
      lv_pay_amt = lv_base_amt. "장학 아닌 사람
      lv_zflag = ' '.
    ENDIF.

  AT END OF ZCODE.

    "내부테이블 GT_GRADE에서 그 인덱스 위치의 행을 읽어 lv_rep_idx에 복사
    "lv_rep_idx : AT NEW ZCODE.에서 저장한 대표행의 인덱스
    READ TABLE GT_GRADE INTO DATA(ls_rep) INDEX lv_rep_idx.
    IF SY-SUBRC = 0."이전에 실행된 명령의 성공
      ls_rep-ZFLAG = lv_zflag.
      ls_rep-ZAMOUNT = lv_pay_amt * 100. "납부액
      ls_rep-ZSUM = lv_base_amt * 100.
      "여기까지는 전역변수(?)에 값 할당하는 것
      MODIFY GT_GRADE FROM ls_rep INDEX lv_rep_idx.
      "방금 할당한 전역변수의 값 들을 GT_GRADE에 되쓰기
    ENDIF.

    lv_total = lv_total + lv_pay_amt.

  ENDAT.

ENDLOOP.

lv_total = lv_total * 100.

"인터널 테이블 GT_GRADE에서 ZCODE가 연속으로 오면 삭제하라는 뜻
DELETE ADJACENT DUPLICATES FROM GT_GRADE COMPARING ZCODE.

"출력용 정렬(ZCODE에서 오름차순대로)
SORT GT_GRADE BY ZCODE.

LOOP AT GT_GRADE INTO GS_GRADE.
  AT FIRST.
    WRITE :/ '----------------------------------------------------------------------------'.
    WRITE :/ '|   학생코드   |          전공명          |장학구분|           납부금액    |'.
    WRITE :/ '--- ------------------------------------------------------------------------'.
  ENDAT.

  WRITE :/ '|  ', GS_GRADE-ZCODE, '|    ',GS_GRADE-ZMNAME,'|',GS_GRADE-ZFLAG,'     |',GS_GRADE-ZAMOUNT, ' |'.
  WRITE :/ '----------------------------------------------------------------------------'.

  AT LAST.
    WRITE :/ '|' ,'               ','합      계','                     ','|'   ,'',  lv_total,'        |'  .
    WRITE :/ '----------------------------------------------------------------------------'.
  ENDAT.

ENDLOOP.
