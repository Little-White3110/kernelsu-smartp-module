#!/system/bin/sh

MODDIR=${0%/*}

# 在这里添加你的初始化代码
# 例如：设置权限、创建目录、修改系统设置等

# 示例：创建一个测试目录
mkdir -p /data/local/tmp/kernelsu-module-test
chmod 755 /data/local/tmp/kernelsu-module-test

# 示例：设置文件权限
# chmod 644 ${MODDIR}/system/lib/libexample.so

# 复制SmartP.db到模块目录
if [ -f "${MODDIR}/SmartP.db" ]; then
    # 确保目标目录存在
    mkdir -p /data/adb/modules/kernelsu-module
    # 复制数据库文件
    cp "${MODDIR}/SmartP.db" /data/adb/modules/kernelsu-module/
    # 模块安装时自动创建备份
    ${MODDIR}/backup/backup.sh --type full --note "Module installation"
fi
