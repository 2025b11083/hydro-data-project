# hydro‑data‑project 运维文档
本项目用来实现水文数据采集、按月归档、过期文件清理功能。

## 1.定时归档配置
使用Linux crontab设置每天凌晨2点自动执行归档脚本
1.打开定时任务配置：
\`\`\`bash
crontab -e
00 02 \* \* \* $HOME/桌面/hydro-data-project/archive.sh
