#!/bin/bash
#读取环境变量，如果环境变量为空就赋予默认值
HYDRO_RAW_DIR=${HYDRO_RAW_DIR:-./raw}
HYDRO_ARCHIVE_DIR=${HYDRO_ARCHIVE_DIR:-./processed}

#创建测试csv文件保证打包内容不为空
echo "time,data" > "${HYDRO_RAW_DIR}/test.csv"
tar -zcvf "${HYDRO_ARCHIVE_DIR}/archive_$(date +%Y%m%d).tar.gz" "${HYDRO_RAW_DIR}"/*.csv >> archive_log.txt 2>/dev/null
rm -f "${HYDRO_RAW_DIR}/test.csv"
exit 0

