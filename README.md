# KernelSU SmartP 模块

## 模块简介

KernelSU SmartP 模块是一个基于 KernelSU 的智能性能优化模块，为设备提供内核级别的权限管理和性能优化功能。本模块通过精细化的配置和管理，帮助用户获得更好的设备性能和使用体验。

## 模块结构

```
kernelsu-module/
├── backup/                 # 备份和恢复功能
│   ├── backup.sh           # 备份脚本
│   ├── config.conf         # 备份配置
│   ├── config_change.sh    # 配置变更脚本
│   └── restore.sh          # 恢复脚本
├── webui/                  # Web 界面
│   ├── index.html          # 主页面
│   ├── script.js           # JavaScript 脚本
│   └── style.css           # 样式文件
├── SmartP.db               # 智能性能配置数据库
├── module.prop             # 模块属性文件
├── post-fs-data.sh         # 系统启动早期执行脚本
├── service.sh              # 服务启动脚本
└── uninstall.sh            # 卸载脚本
```

## 实现细节

### 1. 模块属性配置

模块通过 `module.prop` 文件定义基本信息：

- **id**: 模块唯一标识符 (`kernelsu-template-module`)
- **name**: 模块名称 (`KernelSU Template Module`)
- **author**: 模块作者
- **version**: 模块版本 (`1.0`)
- **versionCode**: 版本代码 (`1`)
- **description**: 模块描述
- **minKSUVersion**: 最低 KernelSU 版本要求 (`10600`)

### 2. 启动流程

1. **系统启动早期** (`post-fs-data.sh`):
   - 执行初始化操作
   - 确保必要目录存在
   - 复制 `SmartP.db` 数据库文件到模块目录
   - 自动创建备份

2. **服务启动** (`service.sh`):
   - 启动后台服务
   - 设置系统属性

### 3. 备份和恢复系统

模块集成了完整的备份和恢复功能：

- **备份功能** (`backup/backup.sh`):
  - 支持完整备份和增量备份
  - 自动管理备份数量（最多保留3个）
  - 为每个备份创建详细信息文件

- **恢复功能** (`backup/restore.sh`):
  - 列出所有可用备份
  - 支持通过索引选择要恢复的备份
  - 恢复前自动创建当前数据库的备份

- **配置** (`backup/config.conf`):
  - 备份目录路径: `/data/adb/modules/kernelsu-module/backup`
  - 保留备份数量: 3
  - 主数据库路径: `/data/adb/modules/kernelsu-module/SmartP.db`

### 4. Web 界面

模块提供了一个现代化的 Web 界面，用于管理和配置模块：

- **使用指南**：提供模块的基本使用方法和功能特点
- **配置**：允许用户自定义模块设置
- **历史记录**：显示模块的操作记录
- **应用管理**：管理应用的 root 权限

## 使用指南

### 安装步骤

1. 确保设备已安装 KernelSU
2. 将模块 zip 文件通过 KernelSU 应用安装
3. 重启设备
4. 模块将自动初始化并创建初始备份

### 基本使用

1. **访问 Web 界面**：
   - 打开浏览器，输入模块提供的 Web 界面地址
   - 或者通过 KernelSU 应用中的模块管理进入

2. **配置模块**：
   - 在 "配置" 标签页中调整模块设置
   - 保存配置后，设置将立即生效

3. **管理应用权限**：
   - 在 "应用管理" 标签页中查看和管理应用的 root 权限
   - 可以根据需要授予或撤销权限

## 备份和恢复流程

### 自动备份

模块在以下情况下会自动创建备份：
- 模块安装时
- 模块更新时
- 配置变更时

### 手动备份

可以通过执行以下命令手动创建备份：

```bash
# 完整备份
/data/adb/modules/kernelsu-module/backup/backup.sh --type full --note "手动备份"

# 增量备份
/data/adb/modules/kernelsu-module/backup/backup.sh --type incremental --note "增量备份"
```

### 恢复备份

1. 执行恢复脚本：
   ```bash
   /data/adb/modules/kernelsu-module/backup/restore.sh
   ```

2. 选择要恢复的备份索引：
   ```
   Available backups:
   ------------------
   [1] 20260413_103045 - full backup
       Note: Module installation
   [2] 20260412_152010 - incremental backup
       Note: Configuration change
   ------------------
   Enter the backup index to restore: 1
   ```

3. 恢复完成后，系统会提示恢复成功，并告知当前数据库的备份位置

## 故障排除

### 常见问题

1. **模块安装失败**
   - 检查 KernelSU 版本是否满足最低要求（10600+）
   - 确保设备已正确安装 KernelSU
   - 检查存储空间是否充足

2. **备份失败**
   - 检查备份目录权限
   - 确保存储空间充足
   - 检查数据库文件是否存在且可访问

3. **Web 界面无法访问**
   - 检查网络连接
   - 确认模块服务是否正常运行
   - 重启设备后再次尝试

4. **应用权限管理不生效**
   - 确认 KernelSU 服务正常运行
   - 尝试重启设备
   - 检查应用是否正确安装

### 日志查看

模块的操作日志可以通过以下方式查看：

```bash
# 查看模块启动日志
logcat | grep KernelSU-module

# 查看备份操作日志
cat /data/adb/modules/kernelsu-module/backup/backup.log
```

### 重置模块

如果遇到严重问题，可以通过以下步骤重置模块：

1. 卸载模块
2. 重启设备
3. 重新安装模块
4. 恢复最近的备份（如果有）

## 技术支持

如果遇到无法解决的问题，可以通过以下方式获取支持：

- KernelSU 官方论坛
- 模块 GitHub 仓库 Issues 页面
- 相关社区和讨论组

## 版本历史

- **v1.0** (2026-04-13): 初始版本
  - 基本功能实现
  - 备份和恢复系统
  - Web 界面管理

## 许可协议

本模块采用 MIT 许可证，详见 LICENSE 文件。
