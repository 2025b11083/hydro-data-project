#!/bin/bash
used=$(df -P /mnt/storage | awk 'NR==2{print $5}' | sed 's/%//')
if [ $used -ge 80 ];then
    echo "磁盘使用率过高警告，当前使用率：${used}%"
fi
