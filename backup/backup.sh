#!/system/bin/sh

# 加载配置文件
. "${0%/*}/config.conf"

# 日志函数
log() {
    local level=$1
    local message=$2
    local timestamp=$(date +"%Y-%m-%d %H:%M:%S")
    local log_entry="[$timestamp] [KernelSU-Module] [$level] $message"
    
    # 确保日志目录存在
    mkdir -p "$LOG_DIR"
    
    # 写入日志文件
    echo "$log_entry" >> "$LOG_DIR/$LOG_FILE"
    
    # 输出到控制台
    echo "$log_entry"
}

# 检查日志级别
should_log() {
    local level=$1
    local levels=("DEBUG" "INFO" "WARNING" "ERROR")
    local current_level_index=-1
    local target_level_index=-1
    
    # 查找当前日志级别的索引
    for i in "${!levels[@]}"; do
        if [ "${levels[$i]}" = "$LOG_LEVEL" ]; then
            current_level_index=$i
        fi
        if [ "${levels[$i]}" = "$level" ]; then
            target_level_index=$i
        fi
    done
    
    # 如果目标级别大于等于当前级别，则记录日志
    if [ "$target_level_index" -ge "$current_level_index" ]; then
        return 0
    else
        return 1
    fi
}

# 日志级别函数
debug() {
    if should_log "DEBUG"; then
        log "DEBUG" "$1"
    fi
}

info() {
    if should_log "INFO"; then
        log "INFO" "$1"
    fi
}

warning() {
    if should_log "WARNING"; then
        log "WARNING" "$1"
    fi
}

error() {
    if should_log "ERROR"; then
        log "ERROR" "$1"
    fi
}

# 主脚本开始
info "Starting backup.sh script"
debug "Backup directory: $BACKUP_DIR"
debug "Database path: $DB_PATH"

# 确保备份目录存在
debug "Creating backup directory if not exists"
mkdir -p "$BACKUP_DIR"
info "Backup directory ready"

# 获取当前时间戳
TIMESTAMP=$(date +"%Y%m%d_%H%M%S")
debug "Timestamp: $TIMESTAMP"

# 备份类型（full或incremental）
BACkUP_TYPE="full"
# 备份备注
BACKUP_NOTE=""

# 解析参数
debug "Parsing arguments"
while [ $# -gt 0 ]; do
    case "$1" in
        --type)
            BACKUP_TYPE="$2"
            debug "Backup type: $BACKUP_TYPE"
            shift 2
            ;;
        --note)
            BACKUP_NOTE="$2"
            debug "Backup note: $BACKUP_NOTE"
            shift 2
            ;;
        *)
            debug "Unknown argument: $1"
            shift
            ;;
    esac
done

# 备份文件名
BACKUP_FILE="${BACKUP_TYPE}_${TIMESTAMP}.db"
BACkUP_PATH="$BACKUP_DIR/$BACKUP_FILE"
debug "Backup file: $BACKUP_FILE"
debug "Backup path: $BACKUP_PATH"

# 检查数据库文件是否存在
if [ ! -f "$DB_PATH" ]; then
    error "Database file not found: $DB_PATH"
    exit 1
fi

# 执行备份
info "Performing $BACKUP_TYPE backup"
debug "Copying database file"
if [ "$BACKUP_TYPE" = "full" ]; then
    # 完整备份
    cp "$DB_PATH" "$BACKUP_PATH"
else
    # 增量备份（简化版，实际应用中可能需要更复杂的逻辑）
    cp "$DB_PATH" "$BACKUP_PATH"
fi

if [ $? -eq 0 ]; then
    info "Backup file created successfully"
    # 创建备份信息文件
    BACKUP_INFO="$BACKUP_DIR/${BACKUP_TYPE}_${TIMESTAMP}.info"
    debug "Creating backup info file: $BACKUP_INFO"
    echo "timestamp=$TIMESTAMP" > "$BACKUP_INFO"
    echo "type=$BACKUP_TYPE" >> "$BACKUP_INFO"
    echo "note=$BACKUP_NOTE" >> "$BACKUP_INFO"
    info "Backup info file created"
else
    error "Failed to create backup file"
    exit 1
fi

# 管理备份数量
info "Managing backup count"
BACKUPS=$(ls -1 "$BACKUP_DIR"/*.db 2>/dev/null | sort -r)
BACkUP_COUNT_ACTUAL=$(echo "$BACKUPS" | wc -l 2>/dev/null || echo 0)
debug "Current backup count: $BACKUP_COUNT_ACTUAL"
debug "Max backup count: $BACKUP_COUNT"

if [ "$BACKUP_COUNT_ACTUAL" -gt "$BACKUP_COUNT" ]; then
    # 删除最旧的备份
    info "Removing old backups"
    OLD_BACKUPS=$(echo "$BACKUPS" | tail -n $((BACKUP_COUNT_ACTUAL - BACKUP_COUNT)))
    for OLD_BACKUP in $OLD_BACKUPS; do
        debug "Removing old backup: $OLD_BACKUP"
        rm -f "$OLD_BACKUP"
        rm -f "${OLD_BACKUP%.db}.info"
    done
    info "Old backups removed"
fi

info "Backup completed: $BACKUP_PATH"
info "Backup script finished"