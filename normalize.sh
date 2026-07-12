#!/bin/bash
#水文数据标准化脚本 normalize.sh
#用法 ./normalize.sh 输入文件.csv 输出文件.csv

#参数校验
if [ $# -ne 2 ];then
    echo "使用方法：$0 input.csv output.csv"
    exit 1
fi
IN="$1"
OUT="$2"

# 校验输入文件存在性
if [ ! -f "$IN" ];then
    echo "错误：输入文件${IN}不存在"
    exit 1
fi

#1.移除UTF-8 BOM头
sed '1s/^\xEF\xBB\xBF//' "$IN" > tmp.tmp

#2.分隔符统一：分号、制表符 → 逗号
sed -i 's/;/,/g;s/\t/,/g' tmp.tmp

#3.日期转换 yyyy/MM/dd → yyyy-MM-dd
sed -i -E 's|([0-9]{4})/([0-9]{2})/([0-9]{2}) |\1-\2-\3 |g' tmp.tmp
#日期转换 dd/MM/yyyy → yyyy-MM-dd
awk -F',' '
BEGIN{OFS=","}
{
    # 将原来违规的continue改为next
    if(NR==1){
        print $0;
        next
    }
    split($2,dt," ");
    if(dt[1] ~ /^[0-9]{2}\/[0-9]{2}\/[0-9]{4}/){
        split(dt[1],d,"/");
        $2=d[3]"-"d[2]"-"d[1]" "dt[2];
    }
    print $0
}' tmp.tmp > "$OUT"

#4.去除末尾空白行
sed -i ':a;N;$!ba;s/\n*$//' "$OUT"

rm -f tmp.tmp
echo "标准化完成！输出文件：$OUT"
