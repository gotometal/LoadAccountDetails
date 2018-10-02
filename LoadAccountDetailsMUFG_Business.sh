#!/bin/sh
# 三菱UFJ銀行 事業性口座の取引明細をDBにロードする。

# DB USER/PASSWORD
USER="root"
PSW="thinkpad"
# MySQLコマンド
MYSQL_ARG="--local_infile=1"
CMD_MYSQL="mysql -u${USER} -p${PSW} ${MYSQL_ARG}"
# コントロールファイル
CTRL="./LoadAccountDetailsMUFG.ctl"
# データファイルDIR
DATADIR="/Users/tgotoh/Documents/MUFGエコ通帳/事業性口座"
# 口座番号
ACCNO="0656802"

# TRUNCATE TABLE
${CMD_MYSQL} -e "TRUNCATE ZAIMU.ACCOUNT_DETAILS_MUFG;" > /dev/null 2>&1

# データファイルDIR下の全CSVをロード
for filename in `ls ${DATADIR}/*.csv`
do
  ${CMD_MYSQL} << EOF > /dev/null 2>&1

SET @BK_CS=@@character_set_database;
SET @@character_set_database=binary;

LOAD DATA LOCAL
INFILE "${filename}"
INTO TABLE ZAIMU.ACCOUNT_DETAILS_MUFG
CHARACTER SET sjis
FIELDS
  TERMINATED BY ','
  ENCLOSED BY '"'
LINES
  TERMINATED BY '\r\n'
  IGNORE 1 LINES
(
  @YMD
, KIND
, REMARK
, @PAYMENTAMOUNT
, @DEPOSITAMOUNT
, @BALANCE
, MEMO
, UNCLEAREDFUNDS
, BANKSTATEMENT
, @ACCOUNTNO
)
SET
  YMD=DATE_FORMAT(@YMD, '%Y%m%d')
, PAYMENTAMOUNT=CASE WHEN @PAYMENTAMOUNT='' THEN 0 ELSE REPLACE(@PAYMENTAMOUNT,',','') END
, DEPOSITAMOUNT=CASE WHEN @DEPOSITAMOUNT='' THEN 0 ELSE REPLACE(@DEPOSITAMOUNT,',','') END
, BALANCE=CASE WHEN @BALANCE='' THEN 0 ELSE REPLACE(@BALANCE,',','') END
, ACCOUNTNO="${ACCNO}"
;

SET @@character_set_database=@BK_CS;

EOF
done

exit 0
