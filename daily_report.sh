#!/bin/bash
#水文日统计报表脚本 daily_report.sh
#用法 ./daily_report.sh standard_out.csv report.csv

if [ $# -ne 2 ];then
    echo "用法 $0 输入.csv 输出报表.csv"
    exit 1
fi
IN="$1"
OUT="$2"

awk -F',' '
# 自定义去除字段首尾空白的函数
function trim(str){
    gsub(/^[ \t\r]+|[ \t\r]+$/,"",str)
    return str
}
BEGIN{
    OFS=","
    #输出表头
    print "站点编号,日期,平均水位,最高水位,最高水位时间,最低水位,最低水位时间,累计降雨量,数据完整率(%)"
}
NR==1{next}
{
    # 修正字段顺序：第2列站点，第1列时间
    station=trim($2)
    fulltime=trim($1)
    if(fulltime == "") next
    split(fulltime,arr," ")
    day=arr[1]
    key=station"|"day

    water=trim($3)+0
    rain=trim($4)+0

    #累加
    sum_water[key] += water
    sum_rain[key] += rain
    count[key]++

    #最大值最小值初始化与更新
    if(count[key]==1){
        max_w[key]=water
        max_t[key]=fulltime
        min_w[key]=water
        min_t[key]=fulltime
    }else{
        if( water > max_w[key] ){
            max_w[key]=water
            max_t[key]=fulltime
        }
        if( water < min_w[key] ){
            min_w[key]=water
            min_t[key]=fulltime
        }
    }
}
END{
    for(k in count){
        split(k,kk,"|")
        s=kk[1]
        d=kk[2]
        cnt=count[k]
        avg=sum_water[k]/cnt
        complete = cnt/24*100
        printf("%s,%s,%.2f,%.2f,%s,%.2f,%s,%.2f,%.1f\n",
        s,d,avg,max_w[k],max_t[k],min_w[k],min_t[k],sum_rain[k],complete)
    }
}' "$IN" | sort -t ',' -k1,1 -k2,2 > "$OUT"

echo "日报表生成完毕：$OUT"
