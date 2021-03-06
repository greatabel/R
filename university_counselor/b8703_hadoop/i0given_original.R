library(rhdfs)
hdfs.init()
library(rmr2)

# HDFS 상의 taxi 자료 파일 확인
hdfs.ls("/data/taxi/combined")
# 폴더에 포함된 파일 목록 files에 할당
files <- hdfs.ls("/data/taxi/combined")$file; files

# info.csv에 포함된 변수 이름과 클래스 정보 읽기
mr <- mapreduce(input = files[1], 
                input.format = make.input.format(
                  format = "csv", sep=",", stringsAsFactors=F)
                )
res <- from.dfs(mr) 
ress <- values(res)
colnames.tmp <- as.character(ress[,1]); colnames.tmp
class.tmp <- as.character(ress[,2]); class.tmp 
# 변수 이름
colnames <- colnames.tmp[-1]; colnames
# 변수 클래스 
class <- class.tmp[-1]; class 
class[c(6,8,9,10)] <- "numeric"

cbind(colnames, class)

# 자료의 input format 지정
input.format <- make.input.format( 
  format = "csv", sep = ",", 
  stringsAsFactors = F, 
  col.names = colnames, colClasses = class)
files <- files[-1]
files

# payment_type를 key로 fare_amount를 value로 반환
map.fun <- function(k, v){
  # v[,4]: payment_type
  # v[,6]: fare_amount 
  keyval(v[,4], v[,6])  
}

# payment_type을 key로 fare_amount의 합을 value로 반환
reduce.fun <- function(k, v){
  keyval(k,sum(v))
}

# mapreduce 프레임워크 실행
# 파일 하나만 입력 자료로 사용
mr <- mapreduce( input = files[1], 
                 input.format = input.format, 
                 map = map.fun, 
                 reduce = reduce.fun )
from.dfs(mr)

# 모든 파일을 입력 자료로 사용
mr <- mapreduce( input = files, 
                 input.format = input.format, 
                 map = map.fun, 
                 reduce = reduce.fun )
from.dfs(mr)