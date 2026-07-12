#!/bin/bash
#水文数据质量校验脚本 qc_check.sh
#用法 ./qc_check.sh standard_out.csv

if [ $# -ne 1 ];then
    echo "用法：$0 standard_out.csv"
    exit 1
fi
IN="$1"

awk -F',' '
BEGIN{
    print "====================水文数据质量检查报告===================="
    total=0
    err_water_jump=0    #水位突变>3m
    err_rain_neg=0      #降雨负值
    err_time_same=0     #时间重复
    err_time_unorder=0  #时间乱序
    err_line=""
}
NR==1{next} #跳过表头
{
    total++
    station=$1
    dt=$2
    water=$3+0
    rain=$4+0
    line_no=NR

    #异常1：降雨量负值
    if(rain < 0){
        err_rain_neg++
        err_line=err_line sprintf("【行%d】降雨量异常，数据：%s\n",line_no,$0)
    }
    #异常2 水位突变、时间重复、时序乱序（对比上一条）
    if(total >=1){
        #相邻水位差>3
        if( sqrt((water-pre_water)^2) > 3 ){
            err_water_jump++
            err_line=err_line sprintf("【行%d】水位突变异常，差值超过3m，数据：%s\n",line_no,$0)
        }
        #时间完全相同
        if(dt == pre_dt){
            err_time_same++
            err_line=err_line sprintf("【行%d】相邻时间重复，数据：%s\n",line_no,$0)
        }
        #时间乱序（后一条更早）
        if(dt < pre_dt){
            err_time_unorder++
            err_line=err_line sprintf("【行%d】时间戳乱序，数据：%s\n",line_no,$0)
        }
    }
    pre_water=water
    pre_dt=dt
}
END{
    all_err=err_water_jump+err_rain_neg+err_time_same+err_time_unorder
    if(total>0){
        rate=all_err/total*100
    }else{
        rate=0
    }
    printf("总记录行数（不含表头）：%d\n",total)
    printf("水位突变异常数量：%d\n",err_water_jump)
    printf("降雨量负值异常数量：%d\n",err_rain_neg)
    printf("相邻时间重复异常数量：%d\n",err_time_same)
    printf("时间乱序异常数量：%d\n",err_time_unorder)
    printf("异常记录总数：%d\n",all_err)
    printf("异常率：%.2f %% \n",rate)
    print "---------------------------------------------------------"
    print "异常明细清单："
    print err_line
}
' "$IN"
