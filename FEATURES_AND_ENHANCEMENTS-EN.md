# FlClash Enhanced Features Complete Guide

<div align="center">
  
**语言选择 | Language Selection**

[🇨🇳 中文](FEATURES_AND_ENHANCEMENTS.md) | [🇺🇸 English](FEATURES_AND_ENHANCEMENTS-EN.md)

</div>

This document provides detailed information about all new features and enhancements in FlClash, including cross-platform support, usage methods, and technical implementation details.

## 📋 Project Information

- **Original Project**: [FlClash](https://github.com/chen08209/FlClash) by [chen08209](https://github.com/chen08209)
- **Enhanced Version**: [FlClash-Enhanced](https://github.com/sadhjkawh/FlClash-Enhanced) by [sadhjkawh](https://github.com/sadhjkawh)
- **License**: [GPL-3.0 License](LICENSE)
- **Based on Version**: FlClash v0.8.84+
- **Pre-built Platforms**: Windows x64 ✅ | Android ✅ | macOS/Linux Build Required 🔧

> This enhanced version adds intelligent clipboard monitoring, multi-protocol link parsing, smart auto speed testing, and other new features to the original project, fully complying with the GPL-3.0 open source license.
> 
> **📦 Build Notes**: The enhanced version provides Windows x64 and Android pre-built versions. macOS/Linux users need to build according to the developer guide.
> 
> ⚠️ **Important Notice**: This enhanced version is a development version that hasn't undergone extensive testing and may contain unknown bugs. It's recommended for developers or experienced users. Regular users should use with caution and backup their data.

## 🎯 Feature Overview

FlClash has successfully added the following new features:

### 🆕 New Features
1. **Multi-protocol Clipboard Link Parsing** - Intelligent parsing support for ss://, vless://, vmess://, ssr://, trojan:// and other protocols
2. **Intelligent Clipboard Monitoring** - Automatic detection and import of proxy links with real-time background monitoring
3. **Smart Auto Speed Testing** - Only tests user-added nodes, automatically switches to fastest node, excludes built-in nodes
4. **Multi-link Batch Import** - Support for various delimiter formats batch import with intelligent format repair
5. **Optimized Test URL Settings** - Smart default options and custom URL support with theme-adaptive interface
6. **Complete Import History** - History records for both automatic clipboard and manual imports with export and management support

### ✅ Core Feature Enhancements
- **User Experience Optimization**: Added detailed multi-link import instructions with exclamation mark hint icons
- **Platform Compatibility**: Support for Windows, macOS, Linux, Android four major platforms
- **Theme Adaptation**: All new interfaces adapt to dark and light themes
- **Performance Optimization**: Smart node identification, reduced unnecessary network testing
- **Privacy Protection**: Local processing, minimum permissions principle, automatic stop when app is paused

## 📱 Platform Support Status

| Platform | Multi-protocol | Clipboard Monitor | Batch Import | Smart Speed Test | Background | Check Interval | Speed Test Interval |
|----------|---------------|------------------|-------------|------------------|------------|----------------|-------------------|
| Android | ✅ | ✅ | ✅ | ✅ | ✅ | 2s | 10min |
| Windows | ✅ | ✅ | ✅ | ✅ | ✅ | 1s | 5min |
| macOS | ✅ | ✅ | ✅ | ✅ | ✅ | 1s | 5min |
| Linux | ✅ | ✅ | ✅ | ✅ | ✅ | 1s | 5min |

## 🚀 Detailed New Features Introduction

### 1. Multi-protocol Clipboard Link Parsing

#### Supported Protocols
- **VMess** (`vmess://`) - V2Ray mainstream protocol
- **VLESS** (`vless://`) - Next-generation lightweight protocol, supports ws, grpc, h2 transport
- **Shadowsocks** (`ss://`) - Classic proxy protocol, supports various encryption methods
- **ShadowsocksR** (`ssr://`) - Complete SSR protocol support
- **Trojan** (`trojan://`) - Proxy protocol that disguises HTTPS traffic

#### Advanced Features
- **Transport Protocol Support**: WebSocket, gRPC, HTTP/2, TCP, KCP, QUIC
- **Secure Transport**: TLS, Reality, XTLS
- **Smart Parsing**: Automatic handling of base64 and URL encoding
- **Error Tolerance**: Smart repair of common link format errors
- **Node Deduplication**: Automatically generates unique identifiers for duplicate node names

### 2. Intelligent Clipboard Monitoring

#### Core Features
- **Auto Detection**: Real-time monitoring of clipboard changes, intelligent recognition of proxy links
- **Multi-protocol Support**: Support for ss://, vless://, vmess://, ssr://, trojan:// protocols
- **Batch Import**: Support for various delimiter formats (`\n`, `/n`, `\r\n`, `\r`)
- **Anti-duplicate Mechanism**: Same link won't trigger popup within 5 minutes
- **Privacy Protection**: Only processes proxy links, doesn't save other clipboard content

#### Usage
1. Go to `Tools` → `Enhanced Features`
2. Enable `Clipboard Monitoring`
3. Copy proxy links to clipboard
4. System automatically pops up import confirmation dialog

### 3. Smart Auto Speed Testing

#### Core Optimizations
- **User Node Priority**: Only tests user-added configurations, excludes built-in nodes
- **Smart Filtering**: Automatically identifies and excludes DIRECT, REJECT, AUTO and other system nodes
- **Node Recognition**: Identifies built-in nodes through name and emoji identifiers (🎯, 🛑, country flags, etc.)
- **Performance Optimization**: Reduces unnecessary testing, improves overall performance

#### Filtering Logic
```dart
// Auto-excluded node types
- Built-in system: DIRECT, REJECT, AUTO, GLOBAL
- Emoji identifiers: 🎯, 🛑, 🚀, ⚡ etc.
- Flag identifiers: 🇺🇸, 🇭🇰, 🇯🇵, 🇸🇬 etc.
- Region identifiers: USA, Hong Kong, Japan, Singapore etc.
```

#### Configuration Options
- **Test Interval**: 60 seconds - 24 hours (mobile default 10 minutes, desktop 5 minutes)
- **Test URL**: Smart default options + custom URL support
- **Auto Switch**: Only effective for Select type proxy groups

### 4. Multi-link Batch Import

#### Smart Link Processing
```bash
# Supported delimiter formats
vmess://xxx
vless://xxx        # Standard newline

vmess://xxx/nvless://xxx  # Auto-correct wrong delimiters

vmess://xxx\r\nvless://xxx  # Windows newline

vmess://xxx\rvless://xxx    # Mac newline
```

#### Core Features
- **Multiple Delimiter Support**: Support for `\n`, `/n`, `\r\n`, `\r` and other delimiter formats
- **Smart Format Repair**: Auto-correct common delimiter errors (e.g., `/n` to `\n`)
- **Batch Import**: Process multiple proxy links at once
- **Node Name Deduplication**: Auto-generate unique identifiers for duplicate node names
- **Error Tolerance**: Smart skip invalid links, continue processing valid parts

#### Usage
1. Copy multiple proxy links to clipboard (using any delimiter)
2. Click "Import from Clipboard" or enable auto monitoring
3. System automatically identifies and separates multiple links
4. Parse and import into configuration one by one

### 5. Optimized Test URL Settings

#### Interface Improvements
- **Default Options**: Don't display specific URLs, keep interface clean
- **Smart Selection**: Use default URL when input box is empty, use custom URL when has content
- **Visual Feedback**: Clear color and border differences for selected state

#### Interaction Optimization
```
[🔘] Default Option                    ← Highlighted when input box is empty
[⚪] [Enter custom test URL (leave blank to use default)] ← Highlighted when has content
```

### 6. Complete Import History Records

#### Feature Characteristics
- **Unified Recording**: Record history for both auto clipboard import and manual import
- **Detailed Information**: Record import time, link count, import status
- **History Management**: Support viewing, exporting, clearing history records
- **JSON Format**: Support import/export of history record data

#### History Record Format
```json
{
  "content": "Original clipboard content",
  "timestamp": "2024-01-05T12:00:00Z",
  "linkCount": 3,
  "wasImported": true
}
```

## 🔧 Technical Implementation

### Code Architecture
```
lib/
├── common/
│   ├── link_parser.dart          # Multi-protocol link parser
│   ├── platform_adapter.dart     # Platform adapter
│   └── platform_permissions.dart # Permission management
├── manager/
│   ├── clipboard_manager.dart    # Smart clipboard monitoring
│   ├── auto_switch_manager.dart  # Auto speed test switching
│   └── enhanced_manager.dart     # Unified feature management
└── fragments/
    └── enhanced_features.dart    # Settings interface
```

### Core Algorithms

#### Link Parsing Algorithm
```dart
// Smart link cleaning
String _cleanProxyLink(String link) {
  return link
    .replaceAll('/n', '\n')        // Fix wrong delimiters
    .replaceAll(RegExp(r'/n$'), '') // Remove trailing junk
    .trim();
}

// Node name deduplication
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

#### User Node Recognition Algorithm
```dart
bool _isUserAddedProxy(String proxyName) {
  // Exclude built-in system nodes
  final builtInNames = ['DIRECT', 'REJECT', 'AUTO', 'GLOBAL'];
  if (builtInNames.contains(proxyName.toUpperCase())) return false;
  
  // Exclude emoji-identified built-in nodes
  final builtInEmojis = ['🎯', '🛑', '🚀', '⚡'];
  if (builtInEmojis.any((emoji) => proxyName.contains(emoji))) return false;
  
  // Exclude flag-identified nodes
  final flagPattern = RegExp(r'[\u{1F1E6}-\u{1F1FF}]', unicode: true);
  if (flagPattern.hasMatch(proxyName)) return false;
  
  return true;
}
```

### Platform Adaptation

#### Android Platform
- **Permission Management**: INTERNET, FOREGROUND_SERVICE, ACCESS_NETWORK_STATE
- **Battery Optimization**: 2-second check interval, 10-minute speed test interval
- **Background Keep Alive**: Foreground service ensures continuous functionality

#### Windows Platform
- **Theme Adaptation**: Perfect support for dark and light themes
- **Firewall Handling**: Smart handling of firewall permission requests
- **High Performance**: 1-second check interval, 5-minute speed test interval

#### macOS/Linux Platform
- **Permission Handling**: Accessibility permissions, clipboard access permissions
- **Desktop Environment**: Support for X11, Wayland display servers
- **Native Performance**: Deep integration with system

## 🎨 User Experience

### Smart Features
- **Auto Adaptation**: Automatically adjust check intervals and timeout based on platform
- **Error Handling**: Smart identification and repair of common link format errors
- **Status Indication**: Real-time display of feature status and platform support
- **Theme Adaptation**: All interfaces perfectly adapt to system themes

### Privacy Protection
- **Minimum Permissions**: Only access clipboard and network when necessary
- **Local Processing**: All data processing completed locally
- **No Data Upload**: No user data uploaded
- **Auto Stop on App Pause**: Save resources and protect privacy

## 🛠️ Developer Information

### 📦 Pre-built Versions

#### Windows Version ✅
Enhanced version provides Windows x64 pre-built version:
- **Location**: [GitHub Releases](https://github.com/sadhjkawh/FlClash-Enhanced/releases)
- **File**: `FlClash.exe` + related dependency files
- **Environment**: Production environment (APP_ENV=stable)
- **Architecture**: x64 (amd64)

#### Android Version ✅
Enhanced version provides Android pre-built version:
- **Location**: [GitHub Releases](https://github.com/sadhjkawh/FlClash-Enhanced/releases)
- **File**: `FlClash-Enhanced.apk`
- **Environment**: Production environment (APP_ENV=stable)
- **Architecture**: arm64-v8a / armeabi-v7a / x86_64

#### Other Platform Build 🔧
**macOS, Linux** need to build themselves:

> ⚠️ **Note**: Enhanced version provides Windows x64 and Android build versions. For macOS or Linux versions, please build according to the following instructions.

### Build Requirements
```bash
# Code generation (if data models are modified)
flutter packages pub run build_runner build --delete-conflicting-outputs

# Production environment build commands
dart run setup.dart windows --arch amd64 --out app --env stable  # Windows ✅ Built
dart run setup.dart android --arch arm64 --out app --env stable  # Android ✅ Built
dart run setup.dart macos --arch arm64 --out app --env stable    # macOS ⚠️ Build Required  
dart run setup.dart linux --arch amd64 --out app --env stable   # Linux ⚠️ Build Required
```

### Self-build Guide

#### Environment Preparation
1. **Flutter SDK** (>=3.0)
2. **Dart SDK** (>=3.0) 
3. **Golang** (>=1.19)
4. **Git** (for submodule updates)

#### Build Steps
```bash
# 1. Update submodules
git submodule update --init --recursive

# 2. Install dependencies
flutter pub get

# 3. Code generation (if needed)
flutter packages pub run build_runner build --delete-conflicting-outputs

# 4. Choose target platform build
dart run setup.dart <platform> --arch <architecture> --out app --env stable
```

#### Platform-specific Requirements

**Android**
- Android SDK
- Android NDK  
- Set `ANDROID_NDK` environment variable

**macOS** 
- Xcode command line tools
- macOS development environment

**Linux**
- GCC compiler
- Related system dependency libraries

### Configuration Items
New configuration items stored in `AppSettingProps`:
```dart
// Clipboard monitoring
bool enableClipboardMonitor;

// Auto speed test switching
bool enableAutoSwitch;
int autoSwitchInterval;      // Speed test interval (seconds)
String autoSwitchTestUrl;    // Test URL
```

### Core Class Description
- **ClipboardManager**: Clipboard monitoring singleton, supports multi-link parsing
- **AutoSwitchManager**: Auto speed test manager, optimized user node recognition
- **LinkParser**: Multi-protocol link parser, supports 6 mainstream protocols
- **PlatformAdapter**: Platform adapter, handles cross-platform differences

## 📋 Usage Guide

### Quick Start
1. **Enable Features**: `Tools` → `Enhanced Features` → Enable corresponding features as needed
2. **Clipboard Import**: Copy proxy links, system automatically prompts for import
3. **Manual Import**: Click `Import from Clipboard` to manually trigger
4. **Auto Speed Test**: After enabling, system periodically tests and switches to fastest node

### Advanced Configuration
1. **Test Interval**: Recommend 5 minutes for desktop platforms, 10 minutes for mobile platforms
2. **Test URL**: Default uses Google connectivity detection, can customize
3. **Batch Import**: Support various delimiters, system auto-identifies and repairs
4. **History Management**: View and manage import history in enhanced features page

### Troubleshooting

#### Common Issues
1. **Clipboard Monitoring Invalid**
   - Check permission settings
   - Restart clipboard monitoring feature
   - Confirm platform support status

2. **Link Parsing Failed**
   - Confirm link format is correct
   - Check for special characters
   - View application logs

3. **Auto Speed Test Abnormal**
   - Check network connection
   - Confirm test URL is accessible
   - Adjust test interval

#### Platform-specific Configuration
- **Android**: Add to battery optimization whitelist
- **Windows**: Allow firewall access
- **macOS**: May need accessibility permissions
- **Linux**: Ensure clipboard tools are installed

---

## 📄 Copyright Information

This enhanced version is developed based on the [FlClash](https://github.com/chen08209/FlClash) project and follows the GPL-3.0 open source license.

### Copyright Statement

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

### Modification Description

This enhanced version adds the following features to the original project:
- Multi-protocol clipboard link parsing
- Intelligent clipboard monitoring  
- Smart auto speed testing
- Multi-link batch import
- Optimized test URL settings
- Complete import history records
- User interface optimization and theme adaptation

All modifications were completed in 2025 and fully comply with the requirements of the GPL-3.0 license. 