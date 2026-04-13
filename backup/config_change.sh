#!/system/bin/sh

# 加载配置文件
. "${0%/*}/config.conf"

# 执行增量备份
${0%/*}/backup.sh --type incremental --note "Configuration change"

echo "Incremental backup created for configuration change"
