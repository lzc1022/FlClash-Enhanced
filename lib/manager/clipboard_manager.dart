import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fl_clash/common/platform_adapter.dart';
import 'package:fl_clash/state.dart';

/// 导入历史记录项
class ImportHistoryItem {
  final String content;
  final DateTime timestamp;
  final int linkCount;
  final bool wasImported;
  
  ImportHistoryItem({
    required this.content,
    required this.timestamp,
    required this.linkCount,
    required this.wasImported,
  });
  
  Map<String, dynamic> toJson() => {
    'content': content,
    'timestamp': timestamp.millisecondsSinceEpoch,
    'linkCount': linkCount,
    'wasImported': wasImported,
  };
  
  factory ImportHistoryItem.fromJson(Map<String, dynamic> json) => ImportHistoryItem(
    content: json['content'],
    timestamp: DateTime.fromMillisecondsSinceEpoch(json['timestamp']),
    linkCount: json['linkCount'],
    wasImported: json['wasImported'],
  );
}

class ClipboardManager {
  static ClipboardManager? _instance;
  static ClipboardManager get instance => _instance ??= ClipboardManager._();
  
  ClipboardManager._();
  
  Timer? _timer;
  String? _lastClipboardContent;
  bool _isListening = false;
  
  // 防重复导入：存储最近导入的内容和时间戳
  final Map<String, DateTime> _recentImports = {};
  
  // 导入历史记录
  final List<ImportHistoryItem> _importHistory = [];
  
  // 防重复时间窗口（5分钟）
  static const Duration _duplicatePreventionWindow = Duration(minutes: 5);
  
  // 最大历史记录数量
  static const int _maxHistoryCount = 100;
  
  /// 获取当前监听状态
  bool get isListening => _isListening;
  
  /// 获取导入历史记录
  List<ImportHistoryItem> get importHistory => List.unmodifiable(_importHistory);
  
  /// 清理过期的重复检查记录
  void _cleanupRecentImports() {
    final now = DateTime.now();
    _recentImports.removeWhere((content, timestamp) =>
        now.difference(timestamp) > _duplicatePreventionWindow);
  }
  
  /// 检查内容是否在防重复时间窗口内
  bool _isDuplicateContent(String content) {
    _cleanupRecentImports();
    
    final now = DateTime.now();
    final lastImportTime = _recentImports[content];
    
    if (lastImportTime != null) {
      final timeDiff = now.difference(lastImportTime);
      return timeDiff < _duplicatePreventionWindow;
    }
    
    return false;
  }
  
  /// 添加到防重复记录
  void _addToRecentImports(String content) {
    _recentImports[content] = DateTime.now();
  }
  
  /// 添加到导入历史
  void _addToHistory(String content, int linkCount, bool wasImported) {
    final historyItem = ImportHistoryItem(
      content: content,
      timestamp: DateTime.now(),
      linkCount: linkCount,
      wasImported: wasImported,
    );
    
    _importHistory.insert(0, historyItem);
    
    // 限制历史记录数量
    if (_importHistory.length > _maxHistoryCount) {
      _importHistory.removeRange(_maxHistoryCount, _importHistory.length);
    }
  }
  
  /// 公开的添加历史记录方法（用于手动导入）
  void addToHistory(String content, int linkCount, bool wasImported) {
    _addToHistory(content, linkCount, wasImported);
  }
  
  /// 解析多个代理链接
  List<String> parseProxyLinks(String content) {
    final links = <String>[];
    
    // 标准化内容，处理各种分隔符
    String normalizedContent = content
        .replaceAll('/n', '\n')  // 处理错误的分隔符
        .replaceAll('\\n', '\n') // 处理转义的换行符
        .replaceAll('\r\n', '\n') // 处理Windows换行符
        .replaceAll('\r', '\n'); // 处理Mac换行符
    
    // 使用多种分隔符分割
    final lines = normalizedContent.split('\n');
    
    for (String line in lines) {
      line = line.trim();
      
      // 清理链接：移除可能的无效字符
      line = _cleanProxyLink(line);
      
      if (line.isNotEmpty && _isProxyLink(line)) {
        links.add(line);
      }
    }
    
    return links;
  }
  
  /// 清理代理链接格式
  String _cleanProxyLink(String link) {
    // 移除常见的无效字符和前缀
    link = link.trim();
    
    // 移除末尾的无效字符
    link = link.replaceAll(RegExp(r'/n$'), '');
    link = link.replaceAll(RegExp(r'/+$'), '');
    
    // 确保链接格式正确
    if (link.contains('://')) {
      final protocolEnd = link.indexOf('://') + 3;
      final protocol = link.substring(0, protocolEnd);
      final rest = link.substring(protocolEnd);
      
      // 重新组合，确保格式正确
      link = protocol + rest.replaceAll(RegExp(r'^/+'), '');
    }
    
    return link;
  }
  
  /// 开始监听剪贴板
  void startListening() {
    if (_isListening) return;
    
    // 检查平台是否支持剪贴板
    if (!PlatformAdapter.instance.isClipboardSupported) {
      print('当前平台不支持剪贴板监听');
      return;
    }
    
    _isListening = true;
    _timer = Timer.periodic(PlatformAdapter.instance.clipboardCheckInterval, (timer) {
      _checkClipboard();
    });
  }
  
  /// 停止监听剪贴板
  void stopListening() {
    _isListening = false;
    _timer?.cancel();
    _timer = null;
  }
  
  /// 检查剪贴板内容
  Future<void> _checkClipboard() async {
    try {
      final content = await PlatformAdapter.instance.getClipboardData();
      
      // 如果内容没有变化，则跳过
      if (content == null || content.trim() == _lastClipboardContent) {
        return;
      }
      
      _lastClipboardContent = content.trim();
      
      // 解析代理链接
      final proxyLinks = parseProxyLinks(_lastClipboardContent!);
      
      if (proxyLinks.isNotEmpty) {
        // 检查是否为重复内容
        if (_isDuplicateContent(_lastClipboardContent!)) {
          print('检测到重复的剪贴板内容，跳过弹窗');
          return;
        }
        
        await _handleProxyLinks(_lastClipboardContent!, proxyLinks);
      }
    } catch (e) {
      // 忽略剪贴板访问错误
      print('剪贴板检查失败 (${PlatformAdapter.instance.platformName}): $e');
    }
  }
  
  /// 检查是否为代理链接
  bool _isProxyLink(String text) {
    text = text.trim();
    return text.startsWith('vmess://') ||
           text.startsWith('v2ray://') ||
           text.startsWith('v2://') ||
           text.startsWith('ssr://') ||
           text.startsWith('ss://') ||
           text.startsWith('vless://') ||
           text.startsWith('trojan://') ||
           text.startsWith('hysteria://') ||
           text.startsWith('hysteria2://') ||
           text.startsWith('tuic://');
  }
  
  /// 处理代理链接
  Future<void> _handleProxyLinks(String content, List<String> proxyLinks) async {
    // 显示导入确认对话框
    final shouldImport = await _showImportDialog(content, proxyLinks);
    
    // 记录到历史（无论是否导入）
    _addToHistory(content, proxyLinks.length, shouldImport);
    
    if (shouldImport) {
      // 添加到防重复记录
      _addToRecentImports(content);
      
      try {
        // 直接传递解析好的代理链接
        await globalState.appController.addProfileFromProxyLinks(proxyLinks);
        _showSuccessMessage(proxyLinks.length);
      } catch (e) {
        _showErrorMessage(e.toString());
      }
    }
  }
  
  /// 显示导入确认对话框
  Future<bool> _showImportDialog(String content, List<String> proxyLinks) async {
    final result = await globalState.showCommonDialog<bool>(
      child: ImportConfirmDialog(
        proxyCount: proxyLinks.length,
        content: content,
        proxyLinks: proxyLinks,
      ),
    );
    
    return result ?? false;
  }
  
  /// 显示成功消息
  void _showSuccessMessage(int count) {
    globalState.showMessage(
      title: "成功",
      message: TextSpan(text: "已成功导入 $count 个代理节点"),
    );
  }
  
  /// 显示错误消息
  void _showErrorMessage(String error) {
    globalState.showMessage(
      title: "导入失败",
      message: TextSpan(text: error),
    );
  }
  
  /// 清空导入历史
  void clearHistory() {
    _importHistory.clear();
  }
  
  /// 清空防重复记录
  void clearRecentImports() {
    _recentImports.clear();
  }
  
  /// 导出历史记录
  String exportHistory() {
    final data = _importHistory.map((item) => item.toJson()).toList();
    return json.encode(data);
  }
  
  /// 导入历史记录
  void importHistoryFromJson(String jsonData) {
    try {
      final List<dynamic> data = json.decode(jsonData);
      _importHistory.clear();
      
      for (final item in data) {
        _importHistory.add(ImportHistoryItem.fromJson(item));
      }
    } catch (e) {
      print('导入历史记录失败: $e');
    }
  }
}

/// 导入确认对话框
class ImportConfirmDialog extends StatefulWidget {
  final int proxyCount;
  final String content;
  final List<String> proxyLinks;
  
  const ImportConfirmDialog({
    super.key,
    required this.proxyCount,
    required this.content,
    required this.proxyLinks,
  });
  
  @override
  State<ImportConfirmDialog> createState() => _ImportConfirmDialogState();
}

class _ImportConfirmDialogState extends State<ImportConfirmDialog> {
  bool _showDetails = false;
  
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('检测到代理链接'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('在剪贴板中检测到 ${widget.proxyCount} 个代理节点'),
          const SizedBox(height: 16),
          
          // 显示链接类型统计
          if (widget.proxyLinks.isNotEmpty) ...[
            Text('链接类型分布：'),
            const SizedBox(height: 8),
            ...(_getLinkTypeStats().entries.map((entry) => 
              Padding(
                padding: const EdgeInsets.only(left: 8),
                child: Text('• ${entry.key}: ${entry.value} 个', 
                  style: const TextStyle(fontSize: 12)),
              )
            )),
            const SizedBox(height: 16),
          ],
          
          const Text('是否要导入这些节点？'),
          const SizedBox(height: 16),
          
          // 详情切换按钮
          TextButton.icon(
            onPressed: () => setState(() => _showDetails = !_showDetails),
            icon: Icon(_showDetails ? Icons.expand_less : Icons.expand_more),
            label: Text(_showDetails ? '收起详情' : '查看详情'),
          ),
          
          // 详情显示
          if (_showDetails) ...[
            const SizedBox(height: 8),
            Container(
              height: 200,
              width: double.infinity,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey),
                borderRadius: BorderRadius.circular(4),
              ),
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('解析到的链接：', 
                      style: TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    ...widget.proxyLinks.map((link) => 
                      Padding(
                        padding: const EdgeInsets.only(bottom: 4),
                        child: Text(
                          '${_getLinkType(link)}: ${_truncateLink(link)}',
                          style: const TextStyle(
                            fontSize: 11,
                            fontFamily: 'monospace',
                          ),
                        ),
                      )
                    ),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: const Text('取消'),
        ),
        ElevatedButton(
          onPressed: () => Navigator.of(context).pop(true),
          child: const Text('导入'),
        ),
      ],
    );
  }
  
  /// 获取链接类型统计
  Map<String, int> _getLinkTypeStats() {
    final stats = <String, int>{};
    
    for (final link in widget.proxyLinks) {
      final type = _getLinkType(link);
      stats[type] = (stats[type] ?? 0) + 1;
    }
    
    return stats;
  }
  
  /// 获取链接类型
  String _getLinkType(String link) {
    if (link.startsWith('vmess://')) return 'VMess';
    if (link.startsWith('vless://')) return 'VLESS';
    if (link.startsWith('ss://')) return 'Shadowsocks';
    if (link.startsWith('ssr://')) return 'ShadowsocksR';
    if (link.startsWith('trojan://')) return 'Trojan';
    if (link.startsWith('hysteria://')) return 'Hysteria';
    if (link.startsWith('hysteria2://')) return 'Hysteria2';
    if (link.startsWith('tuic://')) return 'TUIC';
    return '未知';
  }
  
  /// 截断链接显示
  String _truncateLink(String link) {
    if (link.length <= 50) return link;
    return '${link.substring(0, 25)}...${link.substring(link.length - 20)}';
  }
} 