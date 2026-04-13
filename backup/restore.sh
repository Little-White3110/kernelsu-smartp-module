#!/system/bin/sh

# 加载配置文件
. "${0%/*}/config.conf"

# 确保备份目录存在
mkdir -p "$BACKUP_DIR"

# 显示可用的备份
list_backups() {
    echo "Available backups:"
    echo "------------------"
    BACKUPS=$(ls -1 "$BACKUP_DIR"/*.db | sort -r)
    if [ -z "$BACKUPS" ]; then
        echo "No backups found"
        return 1
    fi
    
    index=1
    for BACKUP in $BACKUPS; do
        BACKUP_INFO="${BACKUP%.db}.info"
        TIMESTAMP=$(grep "timestamp=" "$BACKUP_INFO" | cut -d'=' -f2)
        TYPE=$(grep "type=" "$BACKUP_INFO" | cut -d'=' -f2)
        NOTE=$(grep "note=" "$BACKUP_INFO" | cut -d'=' -f2)
        echo "[$index] $TIMESTAMP - $TYPE backup"
        if [ -n "$NOTE" ]; then
            echo "    Note: $NOTE"
        fi
        index=$((index + 1))
    done
    echo "------------------"
}

# 恢复指定的备份
restore_backup() {
    local backup_index=$1
    local index=1
    local target_backup
    
    BACKUPS=$(ls -1 "$BACKUP_DIR"/*.db | sort -r)
    for BACKUP in $BACKUPS; do
        if [ "$index" -eq "$backup_index" ]; then
            target_backup=$BACKUP
            break
        fi
        index=$((index + 1))
    done
    
    if [ -z "$target_backup" ]; then
        echo "Invalid backup index"
        return 1
    fi
    
    # 先创建当前数据库的备份，以防恢复失败
    cp "$DB_PATH" "$DB_PATH.bak"
    
    # 恢复备份
    cp "$target_backup" "$DB_PATH"
    
    echo "Restored from backup: $target_backup"
    echo "A backup of the current database has been saved to: $DB_PATH.bak"
}

# 主逻辑
if [ $# -eq 0 ]; then
    list_backups
    read -p "Enter the backup index to restore: " backup_index
    restore_backup "$backup_index"
elif [ "$1" = "--list" ]; then
    list_backups
else
    restore_backup "$1"
fi
