# 水文监测站基础环境搭建手册
## 系统环境
操作系统：Ubuntu 24.04 LTS
部署工具：default‑jdk、maven、ant、zip、git、vim、htop、tree、curl、wget、tmux、net‑tools。
目录结构：
/data/hydro/raw：原始采集数据
/data/hydro/processed：处理后的数据
/data/hydro/reports：统计报表
/data/hydro/backup：数据备份目录

## 前期完成工作
1. 使用mkdir‑p命令批量创建12个子目录；
2. 安装12款开发运维软件包；
3. Java程序完成水位统计，可判断25m警戒线告警；
## 用户权限配置
创建hydro用户组，operator操作员、analyst分析员；
/data/hydro目录权限775：属主和组可读可执行，其他用户仅可读执行。
