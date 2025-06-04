# FlClash 增强功能完整指南

<div align="center">
  
**语言选择 | Language Selection**

[🇨🇳 中文](FEATURES_AND_ENHANCEMENTS.md) | [🇺🇸 English](FEATURES_AND_ENHANCEMENTS-EN.md)

</div>

本文档详细介绍了 FlClash 的所有新增功能和增强特性，包括跨平台支持、使用方法和技术实现细节。

## 📋 项目信息

- **原项目地址**：[FlClash](https://github.com/chen08209/FlClash) by [chen08209](https://github.com/chen08209)
- **增强版本地址**：[FlClash-Enhanced](https://github.com/sadhjkawh/FlClash-Enhanced) by [sadhjkawh](https://github.com/sadhjkawh)
- **许可证**：[GPL-3.0 License](LICENSE)
- **基于版本**：FlClash v0.8.84+
- **预构建平台**：Windows x64 ✅ | Android ✅ | macOS/Linux 需自行构建 🔧

> 本增强版本在原项目基础上添加了智能剪切板监听、多协议链接解析、智能自动测速等全新功能，完全遵循 GPL-3.0 开源许可证。
> 
> **📦 构建说明**：增强版本提供 Windows x64 和 Android 预构建版本，macOS/Linux 用户需要根据开发者信息中的指南自行构建。
> 
> ⚠️ **重要提示**：此增强版本为开发版本，尚未进行大量测试，可能存在未知Bug。建议开发者或熟练用户使用，普通用户请谨慎使用并做好数据备份。

## 🎯 功能概览

FlClash 已成功添加了以下全新功能：

### 🆕 新增功能
1. **剪切板多协议链接解析** - 支持 ss://、vless://、vmess://、ssr://、trojan:// 等多种协议的智能解析
2. **智能剪切板监听** - 自动检测和导入代理链接，支持后台实时监听
3. **智能自动测速** - 仅测试用户添加的节点，自动切换最快节点，排除内置节点
4. **多链接批量导入** - 支持多种分隔符格式的批量导入，智能修复格式错误
5. **优化的测试URL设置** - 智能默认选项和自定义URL支持，主题适配界面
6. **完整的导入历史** - 剪切板自动和手动导入都有历史记录，支持导出和管理

### ✅ 核心功能加强
- **用户体验优化**：添加详细的多链接导入说明，感叹号提示图标
- **平台兼容性**：支持 Windows、macOS、Linux、Android 四大平台
- **主题适配**：所有新增界面适配深色和浅色主题
- **性能优化**：智能节点识别，减少不必要的网络测试
- **隐私保护**：本地处理，最小权限原则，应用暂停自动停止

## 📱 平台支持情况

| 平台 | 多协议解析 | 剪切板监听 | 批量导入 | 智能测速 | 后台运行 | 检查间隔 | 测速间隔 |
|------|-----------|-----------|---------|----------|----------|----------|---------|
| Android | ✅ | ✅ | ✅ | ✅ | ✅ | 2秒 | 10分钟 |
| Windows | ✅ | ✅ | ✅ | ✅ | ✅ | 1秒 | 5分钟 |
| macOS | ✅ | ✅ | ✅ | ✅ | ✅ | 1秒 | 5分钟 |
| Linux | ✅ | ✅ | ✅ | ✅ | ✅ | 1秒 | 5分钟 |

## 🚀 新增功能详细介绍

### 1. 剪切板多协议链接解析

#### 支持的协议
- **VMess** (`vmess://`) - V2Ray 主流协议
- **VLESS** (`vless://`) - 新一代轻量协议，支持 ws、grpc、h2 传输
- **Shadowsocks** (`ss://`) - 经典代理协议，支持各种加密方式
- **ShadowsocksR** (`ssr://`) - SSR 协议完整支持
- **Trojan** (`trojan://`) - 伪装HTTPS流量的代理协议

#### 高级特性
- **传输协议支持**：WebSocket、gRPC、HTTP/2、TCP、KCP、QUIC
- **安全传输**：TLS、Reality、XTLS
- **智能解析**：自动处理 base64 编码和 URL 编码
- **容错处理**：智能修复常见链接格式错误
- **节点去重**：自动为重复名称的节点生成唯一标识

### 2. 智能剪切板监听

#### 核心特性
- **自动检测**：实时监听剪切板变化，智能识别代理链接
- **多协议支持**：支持 ss://、vless://、vmess://、ssr://、trojan:// 协议
- **批量导入**：支持多种分隔符格式（`\n`、`/n`、`\r\n`、`\r`）
- **防重复机制**：5分钟内相同链接不重复弹窗
- **隐私保护**：仅处理代理链接，不保存其他剪切板内容

#### 使用方法
1. 进入 `工具` → `增强功能`
2. 启用 `剪贴板监听`
3. 复制代理链接到剪贴板
4. 系统自动弹出导入确认对话框

### 3. 智能自动测速

#### 核心优化
- **用户节点优先**：仅测试用户添加的配置，排除内置节点
- **智能过滤**：自动识别并排除 DIRECT、REJECT、AUTO 等系统节点
- **节点识别**：通过名称和emoji标识（🎯、🛑、国旗等）识别内置节点
- **性能优化**：减少不必要的测试，提升整体性能

#### 过滤逻辑
```dart
// 自动排除的节点类型
- 系统内置：DIRECT、REJECT、AUTO、GLOBAL
- Emoji标识：🎯、🛑、🚀、⚡ 等
- 国旗标识：🇺🇸、🇭🇰、🇯🇵、🇸🇬 等
- 地区标识：美国、香港、日本、新加坡 等
```

#### 配置选项
- **测试间隔**：60秒 - 24小时（移动平台默认10分钟，桌面平台5分钟）
- **测试URL**：智能默认选项 + 自定义URL支持
- **自动切换**：仅对 Select 类型的代理组生效

### 4. 多链接批量导入

#### 智能链接处理
```bash
# 支持的分隔符格式
vmess://xxx
vless://xxx        # 标准换行符

vmess://xxx/nvless://xxx  # 错误分隔符自动修正

vmess://xxx\r\nvless://xxx  # Windows换行符

vmess://xxx\rvless://xxx    # Mac换行符
```

#### 核心特性
- **多种分隔符支持**：支持 `\n`、`/n`、`\r\n`、`\r` 等分隔符格式
- **智能格式修复**：自动修正常见的分隔符错误（如 `/n` 修正为 `\n`）
- **批量导入**：一次性处理多个代理链接
- **节点名称去重**：自动为重复名称的节点生成唯一标识
- **错误容错**：智能跳过无效链接，继续处理有效部分

#### 使用方法
1. 复制多个代理链接到剪贴板（使用任意分隔符）
2. 点击"从剪贴板导入"或启用自动监听
3. 系统自动识别和分离多个链接
4. 逐个解析并导入到配置中

### 5. 优化的测试URL设置

#### 界面改进
- **默认选项**：不显示具体URL，保持界面简洁
- **智能选择**：输入框为空时使用默认URL，有内容时使用自定义URL
- **视觉反馈**：选中状态有明显的颜色和边框区别


#### 交互优化
```
[🔘] 默认选项                    ← 输入框为空时高亮
[⚪] [输入自定义测试URL（留空使用默认）] ← 有内容时高亮
```

### 6. 完整的导入历史记录

#### 功能特性
- **统一记录**：自动剪切板导入和手动导入都记录历史
- **详细信息**：记录导入时间、链接数量、导入状态
- **历史管理**：支持查看、导出、清空历史记录
- **JSON格式**：支持导入导出历史记录数据

#### 历史记录格式
```json
{
  "content": "原始剪切板内容",
  "timestamp": "2024-01-05T12:00:00Z",
  "linkCount": 3,
  "wasImported": true
}
```

## 🔧 技术实现

### 代码架构
```
lib/
├── common/
│   ├── link_parser.dart          # 多协议链接解析器
│   ├── platform_adapter.dart     # 平台适配器
│   └── platform_permissions.dart # 权限管理
├── manager/
│   ├── clipboard_manager.dart    # 剪切板智能监听
│   ├── auto_switch_manager.dart  # 自动测速切换
│   └── enhanced_manager.dart     # 统一功能管理
└── fragments/
    └── enhanced_features.dart    # 设置界面
```

### 核心算法

#### 链接解析算法
```dart
// 智能链接清理
String _cleanProxyLink(String link) {
  return link
    .replaceAll('/n', '\n')        // 修正错误分隔符
    .replaceAll(RegExp(r'/n$'), '') // 移除末尾杂项
    .trim();
}

// 节点名称去重
String generateUniqueName(String baseName, Set<String> existingNames) {
  if (!existingNames.contains(baseName)) return baseName;
  
  int counter = 1;
  String uniqueName;
  do {
    uniqueName = '$baseName-$counter';
    counter++;
  } while (existingNames.contains(uniqueName));
  
  return uniqueName;
}
```

#### 用户节点识别算法
```dart
bool _isUserAddedProxy(String proxyName) {
  // 排除系统内置节点
  final builtInNames = ['DIRECT', 'REJECT', 'AUTO', 'GLOBAL'];
  if (builtInNames.contains(proxyName.toUpperCase())) return false;
  
  // 排除emoji标识的内置节点
  final builtInEmojis = ['🎯', '🛑', '🚀', '⚡'];
  if (builtInEmojis.any((emoji) => proxyName.contains(emoji))) return false;
  
  // 排除国旗标识的节点
  final flagPattern = RegExp(r'[\u{1F1E6}-\u{1F1FF}]', unicode: true);
  if (flagPattern.hasMatch(proxyName)) return false;
  
  return true;
}
```

### 平台适配

#### Android 平台
- **权限管理**：INTERNET、FOREGROUND_SERVICE、ACCESS_NETWORK_STATE
- **电池优化**：2秒检查间隔，10分钟测速间隔
- **后台保活**：前台服务确保功能持续运行

#### Windows 平台
- **主题适配**：完美支持深色和浅色主题
- **防火墙处理**：智能处理防火墙权限申请
- **高性能**：1秒检查间隔，5分钟测速间隔

#### macOS/Linux 平台
- **权限处理**：辅助功能权限、剪切板访问权限
- **桌面环境**：支持 X11、Wayland 显示服务器
- **原生性能**：与系统深度整合



## 🎨 用户体验

### 智能化特性
- **自动适配**：根据平台自动调整检查间隔和超时时间
- **错误处理**：智能识别并修复常见链接格式错误
- **状态提示**：实时显示功能状态和平台支持情况
- **主题适配**：所有界面完美适配系统主题

### 隐私保护
- **最小权限**：仅在必要时访问剪切板和网络
- **本地处理**：所有数据处理在本地完成
- **无数据上传**：不会上传任何用户数据
- **应用暂停自动停止**：节省资源并保护隐私

## 🛠️ 开发者信息

### 📦 预构建版本

#### Windows 版本 ✅
增强版本已提供 Windows x64 预构建版本：
- **位置**：[GitHub Releases](https://github.com/sadhjkawh/FlClash-Enhanced/releases)
- **文件**：`FlClash.exe` + 相关依赖文件
- **环境**：生产环境（APP_ENV=stable）
- **架构**：x64 (amd64)

#### Android 版本 ✅
增强版本已提供 Android 预构建版本：
- **位置**：[GitHub Releases](https://github.com/sadhjkawh/FlClash-Enhanced/releases)
- **文件**：`FlClash-Enhanced.apk`
- **环境**：生产环境（APP_ENV=stable）
- **架构**：arm64-v8a / armeabi-v7a / x86_64

#### 其他平台构建 🔧
**macOS、Linux** 需要自行构建：

> ⚠️ **注意**：增强版本已提供 Windows x64 和 Android 构建版本。如需使用 macOS 或 Linux 版本，请按照以下说明自行构建。

### 构建要求
```bash
# 代码生成（如果修改了数据模型）
flutter packages pub run build_runner build --delete-conflicting-outputs

# 生产环境构建命令
dart run setup.dart windows --arch amd64 --out app --env stable  # Windows ✅ 已构建
dart run setup.dart android --arch arm64 --out app --env stable  # Android ✅ 已构建
dart run setup.dart macos --arch arm64 --out app --env stable    # macOS ⚠️ 需自行构建  
dart run setup.dart linux --arch amd64 --out app --env stable   # Linux ⚠️ 需自行构建
```

### 自行构建指南

#### 环境准备
1. **Flutter SDK** (>=3.0)
2. **Dart SDK** (>=3.0) 
3. **Golang** (>=1.19)
4. **Git** (用于子模块更新)

#### 构建步骤
```bash
# 1. 更新子模块
git submodule update --init --recursive

# 2. 安装依赖
flutter pub get

# 3. 代码生成（如有需要）
flutter packages pub run build_runner build --delete-conflicting-outputs

# 4. 选择目标平台构建
dart run setup.dart <platform> --arch <architecture> --out app --env stable
```

#### 平台特定要求

**Android**
- Android SDK
- Android NDK  
- 设置 `ANDROID_NDK` 环境变量

**macOS** 
- Xcode 命令行工具
- macOS 开发环境

**Linux**
- GCC 编译器
- 相关系统依赖库

### 配置项
新增的配置项存储在 `AppSettingProps` 中：
```dart
// 剪切板监听
bool enableClipboardMonitor;

// 自动测速切换
bool enableAutoSwitch;
int autoSwitchInterval;      // 测速间隔（秒）
String autoSwitchTestUrl;    // 测试URL
```

### 核心类说明
- **ClipboardManager**：剪切板监听单例，支持多链接解析
- **AutoSwitchManager**：自动测速管理器，优化用户节点识别
- **LinkParser**：多协议链接解析器，支持6种主流协议
- **PlatformAdapter**：平台适配器，处理跨平台差异

## 📋 使用指南

### 快速开始
1. **启用功能**：`工具` → `增强功能` → 根据需要开启相应功能
2. **剪切板导入**：复制代理链接，系统自动提示导入
3. **手动导入**：点击 `从剪贴板导入` 手动触发
4. **自动测速**：启用后系统定期测试并切换最快节点

### 高级配置
1. **测试间隔**：建议桌面平台5分钟，移动平台10分钟
2. **测试URL**：默认使用 Google 连通性检测，可自定义
3. **批量导入**：支持多种分隔符，系统自动识别和修复
4. **历史管理**：在增强功能页面查看和管理导入历史

### 故障排除

#### 常见问题
1. **剪切板监听无效**
   - 检查权限设置
   - 重启剪切板监听功能
   - 确认平台支持情况

2. **链接解析失败**
   - 确认链接格式正确
   - 检查是否包含特殊字符
   - 查看应用日志

3. **自动测速异常**
   - 检查网络连接
   - 确认测试URL可访问
   - 调整测试间隔

#### 平台特殊配置
- **Android**：加入电池优化白名单
- **Windows**：允许防火墙访问
- **macOS**：可能需要辅助功能权限
- **Linux**：确保安装剪切板工具

---

## 📄 版权信息

本增强版本基于 [FlClash](https://github.com/chen08209/FlClash) 项目开发，遵循 GPL-3.0 开源许可证。

### 版权声明

```
FlClash Enhanced Features
Copyright (C) 2025 sadhjkawh
Based on FlClash by chen08209

This program is free software: you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program. If not, see <https://www.gnu.org/licenses/>.
```

### 修改说明

本增强版本在原项目基础上新增了以下功能：
- 剪切板多协议链接解析
- 智能剪切板监听  
- 智能自动测速
- 多链接批量导入
- 优化的测试URL设置
- 完整的导入历史记录
- 用户界面优化和主题适配

所有修改均在 2025 年完成，完全遵循 GPL-3.0 许可证的要求。





