## FlClash Enhanced

<div align="center">
  
**语言选择 | Language Selection**

[🇨🇳 中文](README.md) | [🇺🇸 English](README-EN.md)

</div>

[![Original Project](https://img.shields.io/badge/Based_on-FlClash_v0.8.84+-blue?style=flat-square&logo=github)](https://github.com/chen08209/FlClash)
[![GPL-3.0 License](https://img.shields.io/badge/License-GPL--3.0-red?style=flat-square)](LICENSE)
[![Enhanced Features](https://img.shields.io/badge/Enhanced-2025-green?style=flat-square)](FEATURES_AND_ENHANCEMENTS.md)

An enhanced version based on [FlClash](https://github.com/chen08209/FlClash), featuring intelligent clipboard monitoring, multi-protocol link parsing, smart auto speed testing, and more new capabilities.

## 🆕 Enhanced Features

### Core New Features
- 🔄 **Intelligent Clipboard Monitoring** - Automatically detect and import proxy links
- 🔗 **Multi-protocol Link Parsing** - Support for ss://, vless://, vmess://, ssr://, trojan://
- ⚡ **Smart Auto Speed Testing** - Test only user nodes, automatically switch to fastest node
- 📋 **Multi-link Batch Import** - Support batch import with various delimiter formats
- ⚙️ **Optimized Test URL Settings** - Theme-adaptive intelligent interface
- 📊 **Complete Import History** - Record all clipboard import operations

### Platform Support
| Platform | Multi-protocol | Clipboard Monitor | Batch Import | Smart Speed Test | Pre-built |
|----------|---------------|------------------|-------------|------------------|-----------|
| Windows | ✅ | ✅ | ✅ | ✅ | ✅ Available |
| Android | ✅ | ✅ | ✅ | ✅ | ✅ Available |
| macOS | ✅ | ✅ | ✅ | ✅ | ⚠️ Build Required |
| Linux | ✅ | ✅ | ✅ | ✅ | ⚠️ Build Required |

## 📦 Download and Usage

### Pre-built Versions ✅
Enhanced version provides pre-built versions for multiple platforms:
- 📁 **Unified Download**: [GitHub Releases](https://github.com/sadhjkawh/FlClash-Enhanced/releases)

#### Windows x64
- 🚀 Direct Run: `FlClash.exe`
- 📦 Format: Portable version

#### Android
- 📱 Supported Architectures: arm64-v8a / armeabi-v7a / x86_64
- 📦 Format: APK installer
- ⚠️ Requires allowing installation from unknown sources

### Other Platform Users 🔧
macOS and Linux users need to build themselves, see [Build Guide](FEATURES_AND_ENHANCEMENTS.md#build-requirements)

## ⚠️ Important Notice

**This is a development version** that hasn't undergone extensive testing and may contain unknown bugs.
- 🧑‍💻 **Recommended Users**: Developers or experienced users
- 💾 **Data Safety**: Please backup your configurations before use
- 📱 **Android Note**: APK is unsigned version, requires allowing installation from unknown sources
- 🐛 **Bug Reports**: Welcome to report bugs in [Issues](https://github.com/sadhjkawh/FlClash-Enhanced/issues)

## 📖 Detailed Documentation

For complete feature introduction, usage methods, and technical implementation, please check:
- 📘 [**Complete Enhanced Features Guide**](FEATURES_AND_ENHANCEMENTS.md)
- 👥 [Contributors Information](CONTRIBUTORS.md)
- ⚖️ [Copyright Information](COPYRIGHT)

## 🏗️ Quick Build

```bash
# 1. Clone repository
git clone https://github.com/sadhjkawh/FlClash-Enhanced.git
cd FlClash-Enhanced

# 2. Update submodules
git submodule update --init --recursive

# 3. Install dependencies
flutter pub get

# 4. Build (choose target platform)
dart run setup.dart windows --arch amd64 --env stable  # Windows
dart run setup.dart android --arch arm64 --env stable  # Android
dart run setup.dart macos --arch arm64 --env stable    # macOS
dart run setup.dart linux --arch amd64 --env stable   # Linux
```

## 🙏 Acknowledgments

- **Original Author**: [chen08209](https://github.com/chen08209) - Thanks for creating the excellent [FlClash](https://github.com/chen08209/FlClash) project
- **Enhanced Development**: [sadhjkawh](https://github.com/sadhjkawh) - 2025 enhanced features development

## 📄 License

This project follows the [GPL-3.0 License](LICENSE) open source license.

---

<div align="center">

### 🌟 If this project helps you, please give it a Star!

[⭐ Give a Star](https://github.com/sadhjkawh/FlClash-Enhanced/stargazers) | [📝 View Detailed Features](FEATURES_AND_ENHANCEMENTS.md) | [🐛 Report Issues](https://github.com/sadhjkawh/FlClash-Enhanced/issues)

</div> 