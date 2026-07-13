#!/bin/bash
BASE_DIR="/data/hydro"
SRC_DIR="${BASE_DIR}/raw"
LOG_FILE="${BASE_DIR}/archive_log.txt"

# ========== 1.异常判断 ==========
# 判断源目录是否存在
if [ ! -d "${SRC_DIR}" ];then
    echo "错误：目录${SRC_DIR}不存在，退出"
    exit 1
fi

# 判断是否存在csv文件
file_list=$(ls ${SRC_DIR}/*.csv 2>/dev/null)
if [ -z "${file_list}" ];then
    echo "目录下没有csv文件，无需归档，退出"
    exit 0
fi

# 磁盘剩余空间校验（剩余小于100M则退出）
free_space=$(df -P ${SRC_DIR} | awk 'NR==2 {print $4}')
if [ ${free_space} -lt 102400 ];then
    echo "磁盘空间不足，归档终止"
    exit 1
fi

# ========== 2.按站点+月份打包文件 ==========
declare -A file_group
#遍历csv文件，文件名格式：站点_日期.csv（示例 S001_2025‑07‑10.csv）
for file in ${SRC_DIR}/*.csv
do
    filename=$(basename "$file")
    site=${filename%%_*}
    date_part=${filename#*_}
    month=$(echo ${date_part} | cut -d'-' -f1-2)
    key="${site}_${month}"
    file_group[${key}]="${file_group[${key}]} $file"
done

#清空本次临时日志
> tmp_log.txt

#分组打包
for key in "${!file_group[@]}"
do
    tar_name="${key}.tar.gz"
    tar -zcf /data/hydro/${tar_name} ${file_group[$key]}
    if [ $? -eq 0 ];then
        file_cnt=$(echo ${file_group[$key]} | wc -w)
        size=$(du -h /data/hydro/${tar_name} | awk '{print $1}')
        now_time=$(date "+%Y-%m-%d %H:%M:%S")
        echo "${now_time},${tar_name},文件数:${file_cnt},压缩包大小:${size}" >> tmp_log.txt
    else
        echo "${key}打包失败"
    fi
done

#追加到归档总日志
cat tmp_log.txt >> ${LOG_FILE}
rm -f tmp_log.txt
echo "归档完成，归档记录写入${LOG_FILE}"

# ========== 3.查找90天以上过期文件，用户确认后删除 ==========
old_files=$(find ${SRC_DIR} -type f -name "*.csv" -mtime +90)
if [ -n "${old_files}" ];then
    echo -e "\n====发现修改时间超过90天的文件===="
    echo "${old_files}"
    read -p "确认删除以上文件(y/n):" answer
    if [ "${answer}" == "y" ];then
    for file in ${old_files}
    do
        rm -f "${file}"
        echo "$(date "+%Y-%m-%d %H:%M:%S") 删除过期文件：${file}" >> "${LOG_FILE}"
    done
    echo "过期文件删除完毕"
else
    echo "取消删除，跳过清理步骤"
fi

    else
        echo "取消删除，跳过清理步骤"
    fi
else
    echo "不存在超过90天的旧文件"
fi

