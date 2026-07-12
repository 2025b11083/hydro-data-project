#!/bin/bash
#统一定义根目录，消除硬编码问题（评审意见1）
BASE\_DIR="$HOME/桌面/hydro-data-project"
DATA\_DIR="${BASE\_DIR}/hydro-data"
ARCHIVE\_DIR="${BASE\_DIR}/archive"
LOG\_FILE="${ARCHIVE\_DIR}/archive\_run.log"

write\_log(){
    echo "\[$(date +'%Y-%m-%d %H:%M:%S')\] $1" >> ${LOG\_FILE}
}

mkdir -p ${ARCHIVE\_DIR}
mkdir -p ${DATA\_DIR}
write\_log "开始执行归档脚本"

MONTH=$(date +%Y-%m)
tar -zcvf ${ARCHIVE\_DIR}/data\_${MONTH}.tar.gz ${DATA\_DIR}/\*.txt >/dev/null 2>&1
if \[ $? -eq 0 \];then
    write\_log "成功打包${MONTH}月份数据文件"
else
    write\_log "打包${MONTH}月份数据失败"
fi

#清理90天过期文件，并且写入日志（评审意见2）
find ${ARCHIVE\_DIR} -name "data\_\*.tar.gz" -mtime +90 -delete
write\_log "清理90天之前过期归档文件执行完毕"
