import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

/// 平台适配器，处理不同平台的特殊需求
class PlatformAdapter {
  static PlatformAdapter? _instance;
  static PlatformAdapter get instance => _instance ??= PlatformAdapter._();
  
  PlatformAdapter._();
  
  /// 获取当前平台类型
  PlatformType get currentPlatform {
    if (Platform.isAndroid) return PlatformType.android;
    if (Platform.isWindows) return PlatformType.windows;
    if (Platform.isMacOS) return PlatformType.macos;
    if (Platform.isLinux) return PlatformType.linux;
    return PlatformType.unknown;
  }
  
  /// 检查是否为桌面平台
  bool get isDesktop {
    return Platform.isWindows || Platform.isMacOS || Platform.isLinux;
  }
  
  /// 检查是否为移动平台
  bool get isMobile {
    return Platform.isAndroid;
  }
  
  /// 检查剪贴板功能是否可用
  bool get isClipboardSupported {
    // 所有支持的平台都支持剪贴板
    return currentPlatform != PlatformType.unknown;
  }
  
  /// 获取剪贴板内容的安全方法
  Future<String?> getClipboardData() async {
    try {
      if (!isClipboardSupported) return null;
      
      final data = await Clipboard.getData('text/plain');
      return data?.text;
    } catch (e) {
      print('获取剪贴板数据失败: $e');
      return null;
    }
  }
  
  /// 设置剪贴板内容的安全方法
  Future<bool> setClipboardData(String text) async {
    try {
      if (!isClipboardSupported) return false;
      
      await Clipboard.setData(ClipboardData(text: text));
      return true;
    } catch (e) {
      print('设置剪贴板数据失败: $e');
      return false;
    }
  }
  
  /// 获取平台特定的剪贴板监听间隔
  Duration get clipboardCheckInterval {
    switch (currentPlatform) {
      case PlatformType.android:
        // 移动平台使用较长间隔以节省电量
        return const Duration(seconds: 2);
      case PlatformType.windows:
      case PlatformType.macos:
      case PlatformType.linux:
        // 桌面平台可以使用较短间隔
        return const Duration(seconds: 1);
      default:
        return const Duration(seconds: 1);
    }
  }
  
  /// 获取平台特定的自动测速默认间隔
  int get defaultAutoSwitchInterval {
    switch (currentPlatform) {
      case PlatformType.android:
        // 移动平台使用较长间隔
        return 600; // 10分钟
      case PlatformType.windows:
      case PlatformType.macos:
      case PlatformType.linux:
        // 桌面平台可以使用较短间隔
        return 300; // 5分钟
      default:
        return 300;
    }
  }
  
  /// 检查是否支持应用生命周期管理
  bool get supportsAppLifecycle {
    return isMobile || isDesktop;
  }
  
  /// 获取平台特定的网络测试超时时间
  int get networkTestTimeout {
    switch (currentPlatform) {
      case PlatformType.android:
        // 移动网络可能较慢
        return 8000; // 8秒
      case PlatformType.windows:
      case PlatformType.macos:
      case PlatformType.linux:
        // 桌面网络通常较快
        return 5000; // 5秒
      default:
        return 5000;
    }
  }
  
  /// 获取平台特定的UI缩放因子
  double get uiScaleFactor {
    switch (currentPlatform) {
      case PlatformType.android:
        return 1.0;
      case PlatformType.windows:
        return 1.0;
      case PlatformType.macos:
        return 1.0;
      case PlatformType.linux:
        return 1.0;
      default:
        return 1.0;
    }
  }
  
  /// 检查是否支持后台运行
  bool get supportsBackgroundExecution {
    switch (currentPlatform) {
      case PlatformType.android:
        // Android 需要前台服务权限
        return true;
      case PlatformType.windows:
      case PlatformType.macos:
      case PlatformType.linux:
        // 桌面平台通常支持后台运行
        return true;
      default:
        return false;
    }
  }
  
  /// 获取平台特定的通知配置
  NotificationConfig get notificationConfig {
    switch (currentPlatform) {
      case PlatformType.android:
        return NotificationConfig(
          supported: true,
          showProgress: true,
          persistent: true,
        );
      case PlatformType.windows:
        return NotificationConfig(
          supported: true,
          showProgress: false,
          persistent: false,
        );
      case PlatformType.macos:
        return NotificationConfig(
          supported: true,
          showProgress: false,
          persistent: false,
        );
      case PlatformType.linux:
        return NotificationConfig(
          supported: true,
          showProgress: false,
          persistent: false,
        );
      default:
        return NotificationConfig(
          supported: false,
          showProgress: false,
          persistent: false,
        );
    }
  }
  
  /// 获取平台特定的最大并发测速数量
  int get maxConcurrentSpeedTests {
    switch (currentPlatform) {
      case PlatformType.android:
        // Android平台适中的并发数，避免过度占用资源
        return 15;
      case PlatformType.windows:
      case PlatformType.macos:
      case PlatformType.linux:
        // 桌面平台可以支持更高的并发数
        return 30;
      default:
        return 15;
    }
  }
  
  /// 获取平台特定的测速批次大小
  int get speedTestBatchSize {
    switch (currentPlatform) {
      case PlatformType.android:
        // Android平台使用较小的批次大小，确保稳定性
        return 8;
      case PlatformType.windows:
      case PlatformType.macos:
      case PlatformType.linux:
        // 桌面平台可以使用较大的批次
        return 15;
      default:
        return 8;
    }
  }
  
  /// 获取平台特定的并发测速延迟间隔
  Duration get speedTestDelay {
    switch (currentPlatform) {
      case PlatformType.android:
        // Android平台在批次间稍微延迟，避免网络拥塞
        return const Duration(milliseconds: 100);
      case PlatformType.windows:
      case PlatformType.macos:
      case PlatformType.linux:
        // 桌面平台可以更快
        return const Duration(milliseconds: 50);
      default:
        return const Duration(milliseconds: 100);
    }
  }

  /// 获取平台名称
  String get platformName {
    switch (currentPlatform) {
      case PlatformType.android:
        return 'Android';
      case PlatformType.windows:
        return 'Windows';
      case PlatformType.macos:
        return 'macOS';
      case PlatformType.linux:
        return 'Linux';
      default:
        return 'Unknown';
    }
  }
}

/// 平台类型枚举
enum PlatformType {
  android,
  windows,
  macos,
  linux,
  unknown,
}

/// 通知配置
class NotificationConfig {
  final bool supported;
  final bool showProgress;
  final bool persistent;
  
  const NotificationConfig({
    required this.supported,
    required this.showProgress,
    required this.persistent,
  });
} 