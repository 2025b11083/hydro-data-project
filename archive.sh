#!/bin/bash
# 规范：通过环境变量读取目录，禁止硬编码
raw_dir=${HYDRO_RAW_DIR:-/data/hydro/raw}
archive_dir=${HYDRO_ARCHIVE_DIR:-$raw_dir}
log_file="${archive_dir}/archive_log.txt"

# 源目录不存在，非0退出
if [ ! -d "${raw_dir}" ];then
    echo "错误：源目录${raw_dir}不存在" >&2
    exit 1
fi

mkdir -p "${archive_dir}"

# 获取目录下所有csv文件
csv_files=(${raw_dir}/*.csv 2>/dev/null)
if [ ${#csv_files[@]} -eq 0 ];then
    echo "无待归档csv文件，正常退出"
    exit 0
fi

# 按 站点_年月 分组
declare -A group_map
for f in "${csv_files[@]}";do
    fname=$(basename "$f")
    site=${fname%%_*}
    date_str=${fname#*_}
    ym=$(echo "$date_str" | cut -d'_' -f2 | cut -d'-' -f1-2)
    key="${site}_${ym}"
    group_map[$key]="${group_map[$key]} $f"
done

# 分组打包压缩
for k in "${!group_map[@]}";do
    tar_pkg="${archive_dir}/${k}.tar.gz"
    tar -zcf "${tar_pkg}" ${group_map[$k]}
    if [ $? -eq 0 ];then
        now=$(date "+%Y-%m-%d %H:%M:%S")
        fcnt=$(echo ${group_map[$k]} | wc -w)
        echo "${now},压缩包:${k}.tar.gz,文件数量:${fcnt}" >> "${log_file}"
    fi
done

# 查找90天以上过期csv文件
old_files=$(find "${raw_dir}" -maxdepth 1 -type f -name "*.csv" -mtime +90)
if [ -n "${old_files}" ];then
    echo "发现超过90天的旧文件："
    echo "${old_files}"
    read -p "确认删除上述文件(y/n)：" opt
    if [[ "${opt}" == "y" || "${opt}" == "Y" ]];then
        for file in ${old_files};do
            rm -f "${file}"
            del_time=$(date "+%Y-%m-%d %H:%M:%S")
            echo "${del_time} 删除过期文件：${file}" >> "${log_file}"
        done
        echo "过期文件删除完成"
    else
        echo "取消删除操作"
    fi
fi

# 正常执行返回0
exit 0

