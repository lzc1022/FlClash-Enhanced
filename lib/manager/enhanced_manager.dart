import 'package:fl_clash/manager/auto_switch_manager.dart';
import 'package:fl_clash/manager/clipboard_manager.dart';
import 'package:fl_clash/state.dart';
import 'package:fl_clash/providers/providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class EnhancedManager extends StatefulWidget {
  final Widget child;

  const EnhancedManager({
    super.key,
    required this.child,
  });

  @override
  State<EnhancedManager> createState() => _EnhancedManagerState();
}

class _EnhancedManagerState extends State<EnhancedManager> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _disposeFeatures();
    super.dispose();
  }

  void _disposeFeatures() {
    // 停止所有功能
    ClipboardManager.instance.stopListening();
    AutoSwitchManager.instance.disable();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    
    // 根据应用状态管理功能
    switch (state) {
      case AppLifecycleState.resumed:
        // 应用恢复时，根据设置重新启动剪切板监听
        WidgetsBinding.instance.addPostFrameCallback((_) {
          final settings = globalState.config.appSetting;
          if (settings.enableClipboardMonitor) {
            ClipboardManager.instance.startListening();
          }
          if (settings.enableAutoSwitch) {
            AutoSwitchManager.instance.enable(
              testInterval: settings.autoSwitchInterval,
              testUrl: settings.autoSwitchTestUrl,
            );
          }
        });
        break;
      case AppLifecycleState.paused:
      case AppLifecycleState.inactive:
        // 应用暂停时停止剪贴板监听以节省资源，但不停止自动切换
        ClipboardManager.instance.stopListening();
        break;
      case AppLifecycleState.detached:
        _disposeFeatures();
        break;
      case AppLifecycleState.hidden:
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer(
      builder: (context, ref, child) {
        // 设置AutoSwitchManager的ref引用
        AutoSwitchManager.instance.setRef(ref);
        
        // 监听设置变化
        ref.listen(appSettingProvider, (previous, next) {
          if (previous == null) return;
          
          // 剪贴板监听开关变化
          if (previous.enableClipboardMonitor != next.enableClipboardMonitor) {
            if (next.enableClipboardMonitor) {
              ClipboardManager.instance.startListening();
            } else {
              ClipboardManager.instance.stopListening();
            }
          }
          
          // 自动切换开关变化
          if (previous.enableAutoSwitch != next.enableAutoSwitch) {
            if (next.enableAutoSwitch) {
              AutoSwitchManager.instance.enable(
                testInterval: next.autoSwitchInterval,
                testUrl: next.autoSwitchTestUrl,
              );
            } else {
              AutoSwitchManager.instance.disable();
            }
          }
          
          // 自动切换间隔变化
          if (previous.autoSwitchInterval != next.autoSwitchInterval) {
            AutoSwitchManager.instance.setTestInterval(next.autoSwitchInterval);
          }
          
          // 测试URL变化
          if (previous.autoSwitchTestUrl != next.autoSwitchTestUrl) {
            AutoSwitchManager.instance.setTestUrl(next.autoSwitchTestUrl);
          }
        });
        
        // 初始化功能状态
        WidgetsBinding.instance.addPostFrameCallback((_) {
          final settings = ref.read(appSettingProvider);
          if (settings.enableClipboardMonitor && !ClipboardManager.instance.isListening) {
            ClipboardManager.instance.startListening();
          }
          if (settings.enableAutoSwitch && !AutoSwitchManager.instance.isEnabled) {
            AutoSwitchManager.instance.enable(
              testInterval: settings.autoSwitchInterval,
              testUrl: settings.autoSwitchTestUrl,
            );
          }
        });
        
        return widget.child;
      },
    );
  }
} 