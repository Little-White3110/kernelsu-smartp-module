#!/system/bin/sh

# 加载配置文件
. "${0%/*}/config.conf"

# 确保备份目录存在
mkdir -p "$BACKUP_DIR"

# 获取当前时间戳
TIMESTAMP=$(date +"%Y%m%d_%H%M%S")

# 备份类型（full或incremental）
BACKUP_TYPE="full"
# 备份备注
BACKUP_NOTE=""

# 解析参数
while [ $# -gt 0 ]; do
    case "$1" in
        --type)
            BACKUP_TYPE="$2"
            shift 2
            ;;
        --note)
            BACKUP_NOTE="$2"
            shift 2
            ;;
        *)
            shift
            ;;
    esac
done

# 备份文件名
BACKUP_FILE="${BACKUP_TYPE}_${TIMESTAMP}.db"
BACKUP_PATH="$BACKUP_DIR/$BACKUP_FILE"

# 执行备份
if [ "$BACKUP_TYPE" = "full" ]; then
    # 完整备份
    cp "$DB_PATH" "$BACKUP_PATH"
else
    # 增量备份（简化版，实际应用中可能需要更复杂的逻辑）
    cp "$DB_PATH" "$BACKUP_PATH"
fi

# 创建备份信息文件
BACKUP_INFO="$BACKUP_DIR/${BACKUP_TYPE}_${TIMESTAMP}.info"
echo "timestamp=$TIMESTAMP" > "$BACKUP_INFO"
echo "type=$BACKUP_TYPE" >> "$BACKUP_INFO"
echo "note=$BACKUP_NOTE" >> "$BACKUP_INFO"

# 管理备份数量
BACKUPS=$(ls -1 "$BACKUP_DIR"/*.db | sort -r)
BACKUP_COUNT_ACTUAL=$(echo "$BACKUPS" | wc -l)

if [ "$BACKUP_COUNT_ACTUAL" -gt "$BACKUP_COUNT" ]; then
    # 删除最旧的备份
    OLD_BACKUPS=$(echo "$BACKUPS" | tail -n $((BACKUP_COUNT_ACTUAL - BACKUP_COUNT)))
    for OLD_BACKUP in $OLD_BACKUPS; do
        rm -f "$OLD_BACKUP"
        rm -f "${OLD_BACKUP%.db}.info"
    done
fi

echo "Backup completed: $BACKUP_PATH"
