# hydro‑data‑project 运维文档
## 1.定时归档配置
使用Linux crontab设置每天凌晨2点执行归档脚本
执行命令：
\`\`\`bash
crontab -e
#填入下面一行
00 02 \* \* \* /home/13032/hydro-data-project/archive.sh# what
