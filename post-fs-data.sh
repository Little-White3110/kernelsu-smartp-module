#!/system/bin/sh

MODDIR=${0%/*}

# 加载配置文件
. "${MODDIR}/backup/config.conf"

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
    
    # 检查日志文件大小并进行轮换
    log_rotate
}

# 日志轮换函数
log_rotate() {
    if [ -f "$LOG_DIR/$LOG_FILE" ]; then
        local log_size=$(stat -c %s "$LOG_DIR/$LOG_FILE" 2>/dev/null || echo 0)
        local max_size=$((LOG_MAX_SIZE * 1024))
        
        if [ "$log_size" -ge "$max_size" ]; then
            # 轮换日志文件
            for i in $(seq $((LOG_MAX_FILES - 1)) -1 1); do
                if [ -f "$LOG_DIR/${LOG_FILE}.${i}" ]; then
                    mv "$LOG_DIR/${LOG_FILE}.${i}" "$LOG_DIR/${LOG_FILE}.$((i + 1))" 2>/dev/null
                fi
            done
            
            # 重命名当前日志文件
            mv "$LOG_DIR/$LOG_FILE" "$LOG_DIR/${LOG_FILE}.1" 2>/dev/null
            
            # 创建新的空日志文件
            touch "$LOG_DIR/$LOG_FILE"
            chmod 644 "$LOG_DIR/$LOG_FILE"
        fi
    fi
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
info "Starting post-fs-data.sh script"
debug "Module directory: $MODDIR"

# 创建测试目录
debug "Creating test directory"
mkdir -p /data/local/tmp/kernelsu-module-test
chmod 755 /data/local/tmp/kernelsu-module-test
info "Test directory created"

# 复制SmartP.db到模块目录
if [ -f "${MODDIR}/SmartP.db" ]; then
    info "Found SmartP.db file"
    # 确保目标目录存在
    debug "Creating module directory"
    mkdir -p /data/adb/modules/kernelsu-module
    # 复制数据库文件
    debug "Copying SmartP.db to module directory"
    cp "${MODDIR}/SmartP.db" /data/adb/modules/kernelsu-module/
    if [ $? -eq 0 ]; then
        info "SmartP.db copied successfully"
        # 模块安装时自动创建备份
        info "Creating initial backup"
        ${MODDIR}/backup/backup.sh --type full --note "Module installation"
        if [ $? -eq 0 ]; then
            info "Initial backup created"
        else
            error "Failed to create initial backup"
        fi
    else
        error "Failed to copy SmartP.db"
    fi
else
    warning "SmartP.db not found"
fi

info "post-fs-data.sh script completed"