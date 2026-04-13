#!/bin/sh

MODDIR=${0%/*}

# 加载配置文件
. "${MODDIR}/backup/config.conf"

# 显示帮助信息
show_help() {
    echo "KernelSU Module Log Viewer"
    echo ""
    echo "Usage: $0 [options]"
    echo ""
    echo "Options:"
    echo "  -h, --help          Show this help message"
    echo "  -l, --latest        Show latest log (default)"
    echo "  -t, --tail <lines>  Show last N lines of log"
    echo "  -a, --all           Show all logs including rotated ones"
    echo "  -f, --follow        Follow log output"
    echo "  -L, --level <level> Filter logs by level (DEBUG, INFO, WARNING, ERROR)"
    echo "  -d, --download      Download log file"
    echo "  -c, --clear         Clear current log"
    echo ""
    echo "Examples:"
    echo "  $0                  Show latest log"
    echo "  $0 -t 50            Show last 50 lines"
    echo "  $0 -a               Show all logs"
    echo "  $0 -L ERROR         Show only error logs"
    echo "  $0 -f               Follow log output"
}

# 检查日志目录是否存在
check_log_dir() {
    if [ ! -d "$LOG_DIR" ]; then
        echo "Log directory not found: $LOG_DIR"
        echo "Please run the module first to generate logs"
        exit 1
    fi
}

# 查看最新日志
view_latest_log() {
    local log_file="$LOG_DIR/$LOG_FILE"
    if [ -f "$log_file" ]; then
        cat "$log_file"
    else
        echo "Log file not found: $log_file"
    fi
}

# 查看最后N行日志
view_tail_log() {
    local lines=$1
    local log_file="$LOG_DIR/$LOG_FILE"
    if [ -f "$log_file" ]; then
        tail -n "$lines" "$log_file"
    else
        echo "Log file not found: $log_file"
    fi
}

# 查看所有日志（包括轮换的）
view_all_logs() {
    local main_log="$LOG_DIR/$LOG_FILE"
    local rotated_logs="$LOG_DIR/${LOG_FILE}.*"
    
    echo "=== Main Log ($LOG_FILE) ==="
    if [ -f "$main_log" ]; then
        cat "$main_log"
    else
        echo "Main log file not found"
    fi
    
    echo "\n=== Rotated Logs ==="
    for log in $rotated_logs; do
        if [ -f "$log" ]; then
            echo "\n--- $log ---"
            cat "$log"
        fi
    done
}

# 跟踪日志输出
follow_log() {
    local log_file="$LOG_DIR/$LOG_FILE"
    if [ -f "$log_file" ]; then
        tail -f "$log_file"
    else
        echo "Log file not found: $log_file"
    fi
}

# 按级别过滤日志
filter_log_by_level() {
    local level=$1
    local log_file="$LOG_DIR/$LOG_FILE"
    if [ -f "$log_file" ]; then
        grep "\[$level\]" "$log_file"
    else
        echo "Log file not found: $log_file"
    fi
}

# 下载日志文件
download_log() {
    local log_file="$LOG_DIR/$LOG_FILE"
    local dest_file="/data/local/tmp/kernelsu-module-log-$(date +%Y%m%d_%H%M%S).zip"
    
    if [ -f "$log_file" ]; then
        echo "Creating log archive..."
        cd "$LOG_DIR"
        zip -r "$dest_file" .
        cd -
        echo "Log archive created at: $dest_file"
        echo "You can pull it using: adb pull $dest_file"
    else
        echo "Log file not found: $log_file"
    fi
}

# 清除当前日志
clear_log() {
    local log_file="$LOG_DIR/$LOG_FILE"
    if [ -f "$log_file" ]; then
        echo "Clearing log file: $log_file"
        > "$log_file"
        echo "Log cleared"
    else
        echo "Log file not found: $log_file"
    fi
}

# 主函数
main() {
    # 默认操作
    local action="latest"
    local tail_lines=100
    local filter_level=""
    
    # 解析命令行参数
    while [ $# -gt 0 ]; do
        case "$1" in
            -h|--help)
                show_help
                exit 0
                ;;
            -l|--latest)
                action="latest"
                ;;
            -t|--tail)
                action="tail"
                tail_lines="$2"
                shift
                ;;
            -a|--all)
                action="all"
                ;;
            -f|--follow)
                action="follow"
                ;;
            -L|--level)
                action="filter"
                filter_level="$2"
                shift
                ;;
            -d|--download)
                action="download"
                ;;
            -c|--clear)
                action="clear"
                ;;
            *)
                echo "Unknown option: $1"
                show_help
                exit 1
                ;;
        esac
        shift
    done
    
    # 检查日志目录
    check_log_dir
    
    # 执行相应操作
    case "$action" in
        latest)
            view_latest_log
            ;;
        tail)
            view_tail_log "$tail_lines"
            ;;
        all)
            view_all_logs
            ;;
        follow)
            follow_log
            ;;
        filter)
            filter_log_by_level "$filter_level"
            ;;
        download)
            download_log
            ;;
        clear)
            clear_log
            ;;
    esac
}

# 执行主函数
main "$@"