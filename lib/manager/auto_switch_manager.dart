import 'dart:async';

import 'package:fl_clash/clash/clash.dart';
import 'package:fl_clash/common/platform_adapter.dart';
import 'package:fl_clash/common/iterable.dart';
import 'package:fl_clash/state.dart';
import 'package:fl_clash/models/models.dart';
import 'package:fl_clash/providers/providers.dart';
import 'package:fl_clash/enum/enum.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class AutoSwitchManager {
  static AutoSwitchManager? _instance;
  static AutoSwitchManager get instance => _instance ??= AutoSwitchManager._();
  
  AutoSwitchManager._();
  
  Timer? _testTimer;
  bool _isEnabled = false;
  bool _isTesting = false; // 添加测试状态标记
  int _testInterval = PlatformAdapter.instance.defaultAutoSwitchInterval; // 测试间隔，秒
  String _testUrl = 'http://www.gstatic.com/generate_204';
  int _concurrentTestCount = PlatformAdapter.instance.maxConcurrentSpeedTests; // 使用平台特定的并发数量
  WidgetRef? _ref; // 保存当前的WidgetRef
  
  /// 设置WidgetRef引用
  void setRef(WidgetRef ref) {
    _ref = ref;
  }
  
  /// 启用自动测速和切换
  void enable({
    int? testInterval,
    String? testUrl,
  }) {
    if (_isEnabled) return;
    
    _isEnabled = true;
    _testInterval = testInterval ?? _testInterval;
    _testUrl = testUrl ?? _testUrl;
    
    // 立即测试一次
    _testAllProxies();
    
    // 开始定时测试
    _testTimer = Timer.periodic(Duration(seconds: _testInterval), (timer) {
      _testAllProxies();
    });
  }
  
  /// 禁用自动测速和切换
  void disable() {
    _isEnabled = false;
    _isTesting = false;
    _testTimer?.cancel();
    _testTimer = null;
  }
  
  /// 是否已启用
  bool get isEnabled => _isEnabled;
  
  /// 是否正在测试
  bool get isTesting => _isTesting;
  
  /// 设置测试间隔
  void setTestInterval(int seconds) {
    _testInterval = seconds;
    if (_isEnabled) {
      disable();
      enable();
    }
  }
  
  /// 设置测试URL
  void setTestUrl(String url) {
    _testUrl = url;
  }
  
  /// 设置并发测试数量
  void setConcurrentTestCount(int count) {
    final maxConcurrent = PlatformAdapter.instance.maxConcurrentSpeedTests;
    _concurrentTestCount = count.clamp(1, maxConcurrent); // 使用平台特定的最大值
  }
  
  /// 获取当前并发测试数量
  int get concurrentTestCount => _concurrentTestCount;
  
  /// 测试所有代理
  Future<void> _testAllProxies() async {
    if (_isTesting) return; // 防止重复测试
    
    try {
      _isTesting = true;
      
      if (_ref == null) {
        print('AutoSwitchManager: WidgetRef not set');
        return;
      }
      
      final groups = _ref!.read(groupsProvider);
      final currentProfile = _ref!.read(currentProfileProvider);
      
      if (currentProfile == null || groups.isEmpty) return;
      
      // 找到选择器类型的组
      final selectGroups = groups.where((group) => group.type == GroupType.Selector).toList();
      
      // 收集所有切换结果
      final switchResults = <String>[];
      
      for (final group in selectGroups) {
        final result = await _testAndSwitchGroup(group);
        if (result != null) {
          switchResults.add(result);
        }
      }
      
      // 显示汇总通知
      if (switchResults.isNotEmpty) {
        final platform = PlatformAdapter.instance.platformName;
        final message = switchResults.length == 1 
          ? "自动切换 ($platform): ${switchResults.first}"
          : "自动切换 ($platform): 已优化 ${switchResults.length} 个组\n${switchResults.join('\n')}";
        globalState.showNotifier(message);
      }
    } catch (e) {
      print('自动测速失败: $e');
    } finally {
      _isTesting = false;
    }
  }
  
  /// 测试并切换组中最快的节点，返回切换结果描述
  Future<String?> _testAndSwitchGroup(Group group) async {
    try {
      final proxies = group.all;
      if (proxies.isEmpty) return null;
      
      // 过滤出用户添加的代理节点，排除内置节点
      final userProxies = proxies.where((proxy) => _isUserAddedProxy(proxy)).toList();
      if (userProxies.isEmpty) {
        print('组 ${group.name} 中没有用户添加的节点，跳过测试');
        return null;
      }
      
      print('正在测试组 ${group.name}，共 ${userProxies.length} 个用户节点 (并发数: $_concurrentTestCount)');
      
      // 测试延迟 - 使用优化的并发测速
      final delayResults = <String, int>{};
      
      // 使用平台特定的批次大小进行分批测速
      final platformBatchSize = PlatformAdapter.instance.speedTestBatchSize;
      final batchDelay = PlatformAdapter.instance.speedTestDelay;
      
      // 将代理分批进行测试
      final proxyBatches = userProxies.batch(platformBatchSize);
      
      for (int batchIndex = 0; batchIndex < proxyBatches.length; batchIndex++) {
        final batch = proxyBatches[batchIndex];
        print('测试第 ${batchIndex + 1}/${proxyBatches.length} 批，共 ${batch.length} 个节点');
        
        // 为当前批次创建并发测速任务
        final batchDelayFutures = batch.map((proxy) async {
          try {
            final delayResult = await clashCore.getDelay(_testUrl, proxy.name);
            
            if (delayResult.value != null && delayResult.value! > 0) {
              print('节点 ${proxy.name} 延迟: ${delayResult.value}ms');
              return MapEntry(proxy.name, delayResult.value!);
            }
          } catch (e) {
            // 测试失败，跳过该节点
            print('测试节点 ${proxy.name} 失败: $e');
          }
          return null;
        }).toList();
        
        // 等待当前批次完成
        final batchResults = await Future.wait(batchDelayFutures);
        
        // 收集结果
        for (final result in batchResults) {
          if (result != null) {
            delayResults[result.key] = result.value;
          }
        }
        
        // 在批次间稍作延迟，避免网络拥塞
        if (batchIndex < proxyBatches.length - 1) {
          await Future.delayed(batchDelay);
        }
      }
      
      if (delayResults.isEmpty) {
        print('组 ${group.name} 中没有可用的节点');
        return null;
      }
      
      // 找到延迟最小的节点
      final fastestEntry = delayResults.entries
          .reduce((a, b) => a.value < b.value ? a : b);
      final fastestProxy = fastestEntry.key;
      final fastestDelay = fastestEntry.value;
      
      // 检查当前选中的节点
      final currentSelected = group.now;
      print('组 ${group.name} 当前选中: $currentSelected, 最快节点: $fastestProxy (${fastestDelay}ms)');
      
      // 如果最快的节点不是当前选中的节点则切换
      if (currentSelected != fastestProxy) {
        print('切换组 ${group.name} 从 $currentSelected 到 $fastestProxy');
        
        try {
          await globalState.appController.changeProxy(
            groupName: group.name,
            proxyName: fastestProxy,
          );
          
          // 更新本地状态
          globalState.appController.updateCurrentSelectedMap(group.name, fastestProxy);
          
          // 更新组状态以刷新UI - 使用直接的updateGroups而不是debounced版本
          await globalState.appController.updateGroups();
          
          // 等待一小段时间让状态更新完成
          await Future.delayed(const Duration(milliseconds: 500));
          
          // 验证切换是否成功
          final updatedGroups = _ref!.read(groupsProvider);
          final updatedGroup = updatedGroups.firstWhere((g) => g.name == group.name, orElse: () => group);
          final actualSelected = updatedGroup.now;
          
          if (actualSelected == fastestProxy) {
            print('切换成功并验证: ${group.name} -> $fastestProxy');
            // 返回切换结果描述
            return "${group.name}: $fastestProxy (${fastestDelay}ms)";
          } else {
            print('切换验证失败: 期望 $fastestProxy, 实际 $actualSelected');
            return null;
          }
        } catch (e) {
          print('切换失败: ${group.name} -> $fastestProxy, 错误: $e');
          return null;
        }
      } else {
        print('组 ${group.name} 当前节点已是最快节点，无需切换');
        return null;
      }
    } catch (e) {
      print('测试组 ${group.name} 失败: $e');
      return null;
    }
  }
  
  /// 判断是否为用户添加的代理节点
  bool _isUserAddedProxy(Proxy proxy) {
    final name = proxy.name.toLowerCase();
    
    // 排除常见的内置节点名称
    final builtInNames = [
      'direct',
      'reject', 
      'reject-drop',
      'pass',
      'compatible',
      'auto',
      '自动选择',
      '故障转移',
      '负载均衡',
      '节点选择',
      '手动切换',
      '全球直连',
      '全球拦截',
      '漏网之鱼',
    ];
    
    // 检查是否为内置节点
    for (final builtInName in builtInNames) {
      if (name == builtInName.toLowerCase() || name.contains(builtInName.toLowerCase())) {
        return false;
      }
    }
    
    // 排除包含特殊标识的内置节点
    if (name.contains('🎯') || name.contains('🛑') || name.contains('♻️') || 
        name.contains('🔰') || name.contains('🐟') || name.contains('⚡') ||
        name.startsWith('🇨🇳') || name.startsWith('🇭🇰') || name.startsWith('🇺🇸') ||
        name.startsWith('🇯🇵') || name.startsWith('🇸🇬') || name.startsWith('🇹🇼')) {
      return false;
    }
    
    return true;
  }
  
  /// 手动测试所有节点
  Future<void> testAllProxiesManually() async {
    if (!_isEnabled) {
      globalState.showMessage(
        title: "提示",
        message: const TextSpan(text: "请先启用自动测速功能"),
      );
      return;
    }
    
    if (_isTesting) {
      globalState.showMessage(
        title: "提示", 
        message: const TextSpan(text: "正在测试中，请稍候..."),
      );
      return;
    }
    
    // 使用通知方式而不是阻塞式弹窗
    globalState.showNotifier("开始测试所有节点延迟...");
    
    try {
      await _testAllProxies();
      
      // 等待测试完成
      while (_isTesting) {
        await Future.delayed(const Duration(milliseconds: 100));
      }
      
      globalState.showNotifier("延迟测试完成，已切换到最快节点");
    } catch (e) {
      globalState.showNotifier("测速失败: $e");
    }
  }
  
  /// 获取配置信息
  Map<String, dynamic> getConfig() {
    return {
      'enabled': _isEnabled,
      'testInterval': _testInterval,
      'testUrl': _testUrl,
      'concurrentTestCount': _concurrentTestCount,
    };
  }
  
  /// 从配置恢复状态
  void restoreFromConfig(Map<String, dynamic> config) {
    final enabled = config['enabled'] as bool? ?? false;
    _testInterval = config['testInterval'] as int? ?? PlatformAdapter.instance.defaultAutoSwitchInterval;
    _testUrl = config['testUrl'] as String? ?? 'http://www.gstatic.com/generate_204';
    _concurrentTestCount = config['concurrentTestCount'] as int? ?? PlatformAdapter.instance.maxConcurrentSpeedTests;
    
    if (enabled && PlatformAdapter.instance.supportsBackgroundExecution) {
      enable();
    }
  }
} 