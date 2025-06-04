import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:fl_clash/common/platform_adapter.dart';

/// 平台权限管理器
class PlatformPermissions {
  static PlatformPermissions? _instance;
  static PlatformPermissions get instance => _instance ??= PlatformPermissions._();
  
  PlatformPermissions._();
  
  /// 检查剪贴板权限
  Future<bool> checkClipboardPermission() async {
    try {
      final adapter = PlatformAdapter.instance;
      
      switch (adapter.currentPlatform) {
        case PlatformType.android:
          // Android 6.0+ 需要检查权限
          return await _checkAndroidClipboardPermission();
        case PlatformType.windows:
        case PlatformType.macos:
        case PlatformType.linux:
          // 桌面平台通常有完整剪贴板权限
          return true;
        default:
          return false;
      }
    } catch (e) {
      print('检查剪贴板权限失败: $e');
      return false;
    }
  }
  
  /// 检查网络权限
  Future<bool> checkNetworkPermission() async {
    try {
      final adapter = PlatformAdapter.instance;
      
      switch (adapter.currentPlatform) {
        case PlatformType.android:
          // Android 需要 INTERNET 权限（在 manifest 中声明）
          return true; // 假设已在 manifest 中添加
        case PlatformType.windows:
        case PlatformType.macos:
        case PlatformType.linux:
          // 桌面平台通常有网络权限
          return true;
        default:
          return false;
      }
    } catch (e) {
      print('检查网络权限失败: $e');
      return false;
    }
  }
  
  /// 检查后台运行权限
  Future<bool> checkBackgroundPermission() async {
    try {
      final adapter = PlatformAdapter.instance;
      
      switch (adapter.currentPlatform) {
        case PlatformType.android:
          // Android 需要前台服务权限和电池优化白名单
          return await _checkAndroidBackgroundPermission();
        case PlatformType.windows:
        case PlatformType.macos:
        case PlatformType.linux:
          // 桌面平台通常支持后台运行
          return true;
        default:
          return false;
      }
    } catch (e) {
      print('检查后台权限失败: $e');
      return false;
    }
  }
  
  /// 请求必要权限
  Future<PermissionResult> requestPermissions() async {
    final results = PermissionResult();
    
    results.clipboard = await checkClipboardPermission();
    results.network = await checkNetworkPermission();
    results.background = await checkBackgroundPermission();
    
    return results;
  }
  
  /// 获取权限状态说明
  Map<String, String> getPermissionDescriptions() {
    final adapter = PlatformAdapter.instance;
    
    switch (adapter.currentPlatform) {
      case PlatformType.android:
        return {
          'clipboard': '需要访问剪贴板以检测代理链接',
          'network': '需要网络权限进行延迟测试',
          'background': '需要后台运行权限以保持自动测速功能',
          'battery': '建议将应用加入电池优化白名单以确保后台功能正常',
        };
      case PlatformType.windows:
        return {
          'clipboard': '需要访问剪贴板以检测代理链接',
          'network': '需要网络权限进行延迟测试',
          'firewall': '可能需要在防火墙中允许应用访问网络',
        };
      case PlatformType.macos:
        return {
          'clipboard': '需要访问剪贴板以检测代理链接',
          'network': '需要网络权限进行延迟测试',
          'accessibility': '某些功能可能需要辅助功能权限',
        };
      case PlatformType.linux:
        return {
          'clipboard': '需要访问剪贴板以检测代理链接',
          'network': '需要网络权限进行延迟测试',
          'display': '需要访问显示服务器以监听剪贴板',
        };
      default:
        return {
          'general': '当前平台可能不完全支持所有功能',
        };
    }
  }
  
  /// Android 特定的剪贴板权限检查
  Future<bool> _checkAndroidClipboardPermission() async {
    // Android 10+ 对剪贴板访问有限制
    // 但我们使用的是标准 Flutter API，通常可以工作
    return true;
  }
  
  /// Android 特定的后台权限检查
  Future<bool> _checkAndroidBackgroundPermission() async {
    // 检查是否有前台服务权限
    // 实际实现需要使用 permission_handler 插件
    return true; // 假设已配置
  }
}

/// 权限检查结果
class PermissionResult {
  bool clipboard = false;
  bool network = false;
  bool background = false;
  
  bool get allGranted => clipboard && network && background;
  bool get basicGranted => clipboard && network;
  
  List<String> get missingPermissions {
    final missing = <String>[];
    if (!clipboard) missing.add('剪贴板');
    if (!network) missing.add('网络');
    if (!background) missing.add('后台运行');
    return missing;
  }
} 