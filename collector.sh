#!/bin/bash
last_data=""

#捕获Ctrl‑C退出信号，保存最后一条采集数据
exit_func(){
    echo "${last_data}" >> ./last_record.txt
    echo "程序收到终止信号，已保存最后一条采集数据，程序退出"
    exit 0
}
trap exit_func SIGINT

#模拟持续采集
while true
do
    last_data="$(date '+%Y-%m-%d %H:%M:%S'),S001,$(echo "20+$RANDOM%5"|bc)"
    sleep 1
done

