#!/bin/bash
log_path="./collector.log"
last_data=""

# 捕获Ctrl+C中断信号，保存最后一条采集数据
exit_func(){
    echo "${last_data}" >> "${log_path}"
    echo "$(date '+%Y-%m-%d %H:%M:%S') 程序中断，已保存最后采集数据" >> "${log_path}"
    exit 0
}
trap exit_func SIGINT

# 强制包含nice关键字，调整进程优先级
nice -n 10 bash -c '
while true;do
    ts=$(date "+%Y-%m-%d %H:%M:%S")
    water=$(echo "scale=2; 10 + $RANDOM % 60 / 10" | bc)
    line="${ts} water_level=${water}"
    echo "${line}" >> "'"${log_path}'"
    sleep 3
done
' &

echo "采集程序后台启动，日志输出至${log_path}"
exit 0

