#!/system/bin/sh

# 加载配置文件
. "${0%/*}/backup/config.conf"

# 实际模块路径
MODDIR=${0%/*}
BACKUP_DIR="${MODDIR}/backup"
DB_PATH="${MODDIR}/SmartP.db"

# 恢复原始 SmartP.db 文件
restore_original_db() {
    # 查找最早的备份（原始备份）
    ORIGINAL_BACKUP=$(ls -1 "$BACKUP_DIR"/*.db | sort | head -n 1)
    
    if [ -n "$ORIGINAL_BACKUP" ]; then
        echo "Restoring original SmartP.db from backup..."
        cp "$ORIGINAL_BACKUP" "$DB_PATH"
        echo "Original SmartP.db restored successfully"
    else
        echo "No backup found, skipping restoration"
    fi
}

# 清理备份文件
cleanup_backups() {
    echo "Cleaning up backup files..."
    rm -rf "$BACKUP_DIR"/*
    echo "Backup files cleaned up"
}

# 主卸载逻辑
echo "Starting KernelSU module uninstallation..."

# 恢复原始数据库
restore_original_db

# 清理备份文件
cleanup_backups

# 清理其他可能的临时文件
echo "Cleaning up temporary files..."
rm -f "$DB_PATH.bak"

# 清理模块目录（可选，根据需要）
# rm -rf "${0%/*}"

echo "KernelSU module uninstallation completed successfully"
