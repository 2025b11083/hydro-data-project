#!/bin/bash
BASE\_DIR="$HOME/桌面/hydro-data-project"
DATA\_FILE="${BASE\_DIR}/hydro-data/collect\_data.txt"

exit\_save(){
    last\_data="\[$(date +'%Y-%m-%d %H:%M:%S')\] 程序终止，保存最后一条水文采集数据：水位=$(RANDOM%100)m"
    echo ${last\_data} >> ${DATA\_FILE}
    echo ${last\_data}
    exit 0
}
trap exit\_save SIGINT SIGTERM

mkdir -p ${BASE\_DIR}/hydro-data
echo "启动水文后台持续采集进程" >> ${DATA\_FILE}
while true
do
    water\_level=$((RANDOM%100))
    echo "\[$(date +'%Y-%m-%d %H:%M:%S')\] 实时水位：${water\_level} m" >> ${DATA\_FILE}
    sleep 2
done
