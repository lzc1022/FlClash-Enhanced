import 'package:fl_clash/clash/clash.dart';
import 'package:fl_clash/common/common.dart';
import 'package:fl_clash/common/platform_adapter.dart';
import 'package:fl_clash/common/platform_permissions.dart';
import 'package:fl_clash/manager/auto_switch_manager.dart';
import 'package:fl_clash/manager/clipboard_manager.dart';
import 'package:fl_clash/models/models.dart';
import 'package:fl_clash/providers/providers.dart';
import 'package:fl_clash/state.dart';
import 'package:fl_clash/widgets/widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:async';
import 'package:intl/intl.dart';

/// 增强功能页面
class EnhancedFeaturesFragment extends ConsumerStatefulWidget {
  const EnhancedFeaturesFragment({super.key});

  @override
  ConsumerState<EnhancedFeaturesFragment> createState() => _EnhancedFeaturesFragmentState();
}

class _EnhancedFeaturesFragmentState extends ConsumerState<EnhancedFeaturesFragment> {
  final _intervalController = TextEditingController();
  final _testUrlController = TextEditingController();
  Timer? _uiUpdateTimer;

  @override
  void initState() {
    super.initState();
    // 延迟初始化，避免在initState中使用ref
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final settings = ref.read(appSettingProvider);
      _intervalController.text = settings.autoSwitchInterval.toString();
      // 只有当用户设置了自定义测试URL时才显示，否则保持空白（使用默认）
      if (settings.autoSwitchTestUrl.isNotEmpty && 
          settings.autoSwitchTestUrl != 'https://www.gstatic.com/generate_204') {
        _testUrlController.text = settings.autoSwitchTestUrl;
      } else {
        _testUrlController.text = '';
      }
    });
    
    // 启动UI更新定时器
    _uiUpdateTimer = Timer.periodic(const Duration(milliseconds: 500), (_) {
      if (mounted) {
        setState(() {});
      }
    });
  }

  @override
  void dispose() {
    _intervalController.dispose();
    _testUrlController.dispose();
    _uiUpdateTimer?.cancel();
    super.dispose();
  }
  
  /// 保存测试URL设置
  void _saveTestUrl(String value) {
    final trimmedValue = value.trim();
    // 如果输入框为空，则使用默认URL
    final urlToSave = trimmedValue.isEmpty ? 
                    'https://www.gstatic.com/generate_204' : trimmedValue;
    ref.read(appSettingProvider.notifier).updateState(
          (state) => state.copyWith(autoSwitchTestUrl: urlToSave),
        );
    AutoSwitchManager.instance.setTestUrl(urlToSave);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('增强功能'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildPlatformInfo(),
          const SizedBox(height: 24),
          _buildClipboardSection(),
          const SizedBox(height: 24),
          _buildAutoSwitchSection(),
          const SizedBox(height: 24),
          _buildManualTestSection(),
        ],
      ),
    );
  }

  Widget _buildPlatformInfo() {
    final adapter = PlatformAdapter.instance;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  adapter.isDesktop ? Icons.desktop_windows : Icons.phone_android,
                  color: Colors.blue,
                ),
                const SizedBox(width: 8),
                Text(
                  '平台信息 (${adapter.platformName})',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildPlatformFeature('剪贴板支持', adapter.isClipboardSupported),
            _buildPlatformFeature('后台运行', adapter.supportsBackgroundExecution),
            _buildPlatformFeature('应用生命周期', adapter.supportsAppLifecycle),
            const SizedBox(height: 8),
            Text(
              '检查间隔: ${adapter.clipboardCheckInterval.inSeconds}秒 | '
              '默认测速间隔: ${adapter.defaultAutoSwitchInterval}秒 | '
              '网络超时: ${adapter.networkTestTimeout}ms',
              style: const TextStyle(
                fontSize: 12,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlatformFeature(String name, bool supported) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(
            supported ? Icons.check_circle : Icons.cancel,
            color: supported ? Colors.green : Colors.red,
            size: 16,
          ),
          const SizedBox(width: 8),
          Text(name),
          const Spacer(),
          Text(
            supported ? '支持' : '不支持',
            style: TextStyle(
              color: supported ? Colors.green : Colors.red,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildClipboardSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '剪贴板监听',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              '自动监听剪贴板中的代理链接（ss://, vless://, vmess://, ssr://, trojan://）并提示导入',
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 16),
            Consumer(
              builder: (context, ref, child) {
                final enabled = ref.watch(appSettingProvider.select((state) => state.enableClipboardMonitor));
                final isSupported = PlatformAdapter.instance.isClipboardSupported;
                
                return Column(
                  children: [
                    SwitchListTile(
                      title: const Text('启用剪贴板监听'),
                      subtitle: Text(
                        enabled ? '已启用' : 
                        !isSupported ? '当前平台不支持' : '已禁用'
                      ),
                      value: enabled && isSupported,
                      onChanged: isSupported ? (value) {
                        ref.read(appSettingProvider.notifier).updateState(
                              (state) => state.copyWith(enableClipboardMonitor: value),
                            );
                        
                        if (value) {
                          ClipboardManager.instance.startListening();
                        } else {
                          ClipboardManager.instance.stopListening();
                        }
                      } : null,
                    ),
                    
                    // 导入历史管理
                    if (isSupported) ...[
                      const Divider(),
                      ListTile(
                        leading: const Icon(Icons.history),
                        title: const Text('导入历史'),
                        subtitle: Text('查看和管理剪贴板导入记录'),
                        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                        onTap: () => _showImportHistory(context),
                      ),
                      ListTile(
                        leading: const Icon(Icons.block),
                        title: const Text('防重复导入'),
                        subtitle: const Text('5分钟内相同链接不再弹窗'),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            TextButton(
                              onPressed: () {
                                ClipboardManager.instance.clearRecentImports();
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('已清空防重复记录')),
                                );
                              },
                              child: const Text('清空'),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAutoSwitchSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '自动测速切换',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              '定期测试所有节点延迟并自动切换到最快的节点',
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 16),
            Consumer(
              builder: (context, ref, child) {
                final enabled = ref.watch(appSettingProvider.select((state) => state.enableAutoSwitch));
                final supportsBackground = PlatformAdapter.instance.supportsBackgroundExecution;
                
                return SwitchListTile(
                  title: const Text('启用自动测速切换'),
                  subtitle: Text(
                    enabled ? '已启用' : 
                    !supportsBackground ? '当前平台后台限制' : '已禁用'
                  ),
                  value: enabled,
                  onChanged: (value) {
                    if (!supportsBackground && value) {
                      // 显示警告
                      globalState.showMessage(
                        title: "警告",
                        message: const TextSpan(text: "当前平台对后台运行有限制，自动测速功能可能不稳定"),
                      );
                    }
                    
                    ref.read(appSettingProvider.notifier).updateState(
                          (state) => state.copyWith(enableAutoSwitch: value),
                        );
                    
                    if (value) {
                      final settings = ref.read(appSettingProvider);
                      AutoSwitchManager.instance.enable(
                        testInterval: settings.autoSwitchInterval,
                        testUrl: settings.autoSwitchTestUrl,
                      );
                    } else {
                      AutoSwitchManager.instance.disable();
                    }
                  },
                );
              },
            ),
            const SizedBox(height: 16),
            ListTile(
              title: const Text('测试间隔'),
              subtitle: const Text('每隔多少秒进行一次自动测速'),
              trailing: SizedBox(
                width: 80,
                child: TextField(
                  controller: _intervalController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    suffixText: '秒',
                    border: OutlineInputBorder(),
                    contentPadding: EdgeInsets.symmetric(horizontal: 8),
                  ),
                  onSubmitted: (value) {
                    final interval = int.tryParse(value) ?? 300;
                    ref.read(appSettingProvider.notifier).updateState(
                          (state) => state.copyWith(autoSwitchInterval: interval),
                        );
                    AutoSwitchManager.instance.setTestInterval(interval);
                  },
                ),
              ),
            ),
            const SizedBox(height: 16),
            Column(
              children: [
                ListTile(
                  title: const Text('测试URL'),
                  subtitle: const Text('用于测试节点延迟的URL'),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Column(
                    children: [
                      // 默认选项（不可编辑，不显示具体URL）
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: _testUrlController.text.trim().isEmpty ? 
                                   Theme.of(context).primaryColor : 
                                   Theme.of(context).dividerColor,
                            width: _testUrlController.text.trim().isEmpty ? 2 : 1,
                          ),
                          borderRadius: BorderRadius.circular(4),
                          color: _testUrlController.text.trim().isEmpty ? 
                                 Theme.of(context).primaryColor.withOpacity(0.1) : 
                                 Theme.of(context).cardColor,
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.radio_button_checked, 
                                 color: _testUrlController.text.trim().isEmpty ? 
                                        Theme.of(context).primaryColor : 
                                        Theme.of(context).unselectedWidgetColor,
                                 size: 18),
                            const SizedBox(width: 8),
                            Text(
                              '默认选项',
                              style: TextStyle(
                                color: _testUrlController.text.trim().isEmpty ? 
                                       Theme.of(context).primaryColor : 
                                       Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.6),
                                fontWeight: _testUrlController.text.trim().isEmpty ? 
                                           FontWeight.w600 : FontWeight.normal,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 8),
                      // 自定义URL输入框
                      TextField(
                        controller: _testUrlController,
                        decoration: InputDecoration(
                          border: OutlineInputBorder(
                            borderSide: BorderSide(
                              color: _testUrlController.text.trim().isNotEmpty ? 
                                     Theme.of(context).primaryColor : 
                                     Theme.of(context).dividerColor,
                              width: _testUrlController.text.trim().isNotEmpty ? 2 : 1,
                            ),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                              color: _testUrlController.text.trim().isNotEmpty ? 
                                     Theme.of(context).primaryColor : 
                                     Theme.of(context).dividerColor,
                              width: _testUrlController.text.trim().isNotEmpty ? 2 : 1,
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                              color: Theme.of(context).primaryColor,
                              width: 2,
                            ),
                          ),
                          fillColor: _testUrlController.text.trim().isNotEmpty ? 
                                    Theme.of(context).primaryColor.withOpacity(0.05) : null,
                          filled: _testUrlController.text.trim().isNotEmpty,
                          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          hintText: '输入自定义测试URL（留空使用默认）',
                          hintStyle: TextStyle(
                            color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.5),
                          ),
                          prefixIcon: Icon(
                            _testUrlController.text.trim().isNotEmpty ? 
                                Icons.radio_button_checked : Icons.radio_button_unchecked, 
                            color: _testUrlController.text.trim().isNotEmpty ? 
                                   Theme.of(context).primaryColor : 
                                   Theme.of(context).unselectedWidgetColor,
                            size: 18,
                          ),
                        ),
                        onChanged: (value) {
                          setState(() {}); // 更新UI状态
                        },
                        onSubmitted: (value) {
                          _saveTestUrl(value);
                        },
                        onTapOutside: (event) {
                          _saveTestUrl(_testUrlController.text);
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildManualTestSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '手动操作',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            ListTile(
              leading: const Icon(Icons.speed),
              title: const Text('立即测速'),
              subtitle: Text(
                AutoSwitchManager.instance.isTesting 
                  ? '正在测试中...' 
                  : '测试所有节点延迟并切换到最快节点'
              ),
              trailing: AutoSwitchManager.instance.isTesting 
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : null,
              enabled: !AutoSwitchManager.instance.isTesting,
              onTap: AutoSwitchManager.instance.isTesting 
                ? null 
                : () {
                    AutoSwitchManager.instance.testAllProxiesManually();
                  },
            ),
            ListTile(
              leading: const Icon(Icons.paste),
              title: const Text('从剪贴板导入'),
              subtitle: const Text('手动从剪贴板导入代理链接'),
              trailing: IconButton(
                icon: Icon(
                  Icons.info_outline,
                  color: Theme.of(context).colorScheme.primary,
                  size: 20,
                ),
                onPressed: () => _showMultiLinkImportInfo(context),
                tooltip: '多链接导入说明',
              ),
              onTap: () {
                globalState.appController.addProfileFromClipboard();
              },
            ),
            ListTile(
              leading: const Icon(Icons.security),
              title: const Text('检查权限'),
              subtitle: const Text('检查当前平台的功能权限状态'),
              onTap: () {
                _checkPermissions();
              },
            ),
          ],
        ),
      ),
    );
  }

  /// 检查权限状态
  void _checkPermissions() async {
    try {
      final result = await PlatformPermissions.instance.requestPermissions();
      final descriptions = PlatformPermissions.instance.getPermissionDescriptions();
      
      if (mounted) {
        showDialog(
          context: context,
          builder: (context) => PermissionStatusDialog(
            result: result,
            descriptions: descriptions,
          ),
        );
      }
    } catch (e) {
      globalState.showMessage(
        title: "错误",
        message: TextSpan(text: "权限检查失败: $e"),
      );
    }
  }

  void _showImportHistory(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const ImportHistoryPage(),
      ),
    );
  }

  /// 显示多链接导入说明
  void _showMultiLinkImportInfo(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(
              Icons.info_outline,
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(width: 8),
            const Text('多链接导入说明'),
          ],
        ),
        content: const SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '支持多种方式导入多个代理链接：',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 12),
              
              Text('📋 分隔符支持', style: TextStyle(fontWeight: FontWeight.w600)),
              SizedBox(height: 4),
              Text('• 标准换行符：\\n'),
              Text('• Windows换行符：\\r\\n'),
              Text('• Mac换行符：\\r'),
              Text('• 错误格式自动修正：/n → \\n'),
              SizedBox(height: 12),
              
              Text('🔗 支持的协议', style: TextStyle(fontWeight: FontWeight.w600)),
              SizedBox(height: 4),
              Text('• VMess: vmess://...'),
              Text('• VLESS: vless://...'),
              Text('• Shadowsocks: ss://...'),
              Text('• ShadowsocksR: ssr://...'),
              Text('• Trojan: trojan://...'),
              SizedBox(height: 12),
              
              Text('💡 使用方法', style: TextStyle(fontWeight: FontWeight.w600)),
              SizedBox(height: 4),
              Text('1. 复制多个代理链接到剪贴板'),
              Text('2. 每行一个链接，或用分隔符分开'),
              Text('3. 点击"从剪贴板导入"按钮'),
              Text('4. 系统会自动识别和解析所有链接'),
              SizedBox(height: 12),
              
              Text('🎯 智能特性', style: TextStyle(fontWeight: FontWeight.w600)),
              SizedBox(height: 4),
              Text('• 自动修复常见格式错误'),
              Text('• 重复节点名称自动编号'),
              Text('• 导入历史自动记录'),
              Text('• 支持各种分隔符混用'),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('明白了'),
          ),
        ],
      ),
    );
  }
}

/// 权限状态对话框
class PermissionStatusDialog extends StatelessWidget {
  final PermissionResult result;
  final Map<String, String> descriptions;
  
  const PermissionStatusDialog({
    super.key,
    required this.result,
    required this.descriptions,
  });
  
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Row(
        children: [
          Icon(
            result.basicGranted ? Icons.check_circle : Icons.warning,
            color: result.basicGranted ? Colors.green : Colors.orange,
          ),
          const SizedBox(width: 8),
          Text('权限状态 (${PlatformAdapter.instance.platformName})'),
        ],
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildPermissionItem('剪贴板', result.clipboard),
            _buildPermissionItem('网络访问', result.network),
            _buildPermissionItem('后台运行', result.background),
            
            if (result.missingPermissions.isNotEmpty) ...[
              const SizedBox(height: 16),
              Text(
                '缺失权限: ${result.missingPermissions.join(', ')}',
                style: const TextStyle(
                  color: Colors.red,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
            
            const SizedBox(height: 16),
            const Text(
              '权限说明:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            ...descriptions.entries.map((entry) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 2),
              child: Text(
                '• ${entry.key}: ${entry.value}',
                style: const TextStyle(fontSize: 12),
              ),
            )),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('确定'),
        ),
      ],
    );
  }
  
  Widget _buildPermissionItem(String name, bool granted) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(
            granted ? Icons.check_circle : Icons.cancel,
            color: granted ? Colors.green : Colors.red,
            size: 20,
          ),
          const SizedBox(width: 8),
          Text(name),
          const Spacer(),
          Text(
            granted ? '已授权' : '未授权',
            style: TextStyle(
              color: granted ? Colors.green : Colors.red,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}

/// 导入历史页面
class ImportHistoryPage extends StatefulWidget {
  const ImportHistoryPage({super.key});

  @override
  State<ImportHistoryPage> createState() => _ImportHistoryPageState();
}

class _ImportHistoryPageState extends State<ImportHistoryPage> {
  final DateFormat _dateFormat = DateFormat('yyyy-MM-dd HH:mm:ss');

  @override
  Widget build(BuildContext context) {
    final history = ClipboardManager.instance.importHistory;

    return Scaffold(
      appBar: AppBar(
        title: const Text('导入历史'),
        actions: [
          if (history.isNotEmpty) ...[
            IconButton(
              icon: const Icon(Icons.file_download),
              tooltip: '导出历史',
              onPressed: _exportHistory,
            ),
            IconButton(
              icon: const Icon(Icons.file_upload),
              tooltip: '导入历史',
              onPressed: _importHistory,
            ),
            IconButton(
              icon: const Icon(Icons.delete_sweep),
              tooltip: '清空历史',
              onPressed: _clearHistory,
            ),
          ],
        ],
      ),
      body: history.isEmpty
          ? _buildEmptyState()
          : _buildHistoryList(history),
    );
  }

  Widget _buildEmptyState() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.history,
            size: 64,
            color: Colors.grey,
          ),
          SizedBox(height: 16),
          Text(
            '暂无导入历史',
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey,
            ),
          ),
          SizedBox(height: 8),
          Text(
            '当检测到剪贴板中的代理链接时\n历史记录将显示在这里',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHistoryList(List<ImportHistoryItem> history) {
    return ListView.builder(
      padding: const EdgeInsets.all(8),
      itemCount: history.length,
      itemBuilder: (context, index) {
        final item = history[index];
        return _buildHistoryItem(item, index);
      },
    );
  }

  Widget _buildHistoryItem(ImportHistoryItem item, int index) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4),
      child: ExpansionTile(
        leading: CircleAvatar(
          backgroundColor: item.wasImported ? Colors.green : Colors.orange,
          child: Icon(
            item.wasImported ? Icons.check : Icons.block,
            color: Colors.white,
            size: 20,
          ),
        ),
        title: Text(
          '${item.linkCount} 个代理链接',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              _dateFormat.format(item.timestamp),
              style: const TextStyle(fontSize: 12),
            ),
            const SizedBox(height: 2),
            Text(
              item.wasImported ? '已导入' : '已跳过',
              style: TextStyle(
                fontSize: 12,
                color: item.wasImported ? Colors.green : Colors.orange,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Text(
                      '原始内容：',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const Spacer(),
                    TextButton.icon(
                      onPressed: () => _copyToClipboard(item.content),
                      icon: const Icon(Icons.copy, size: 16),
                      label: const Text('复制'),
                    ),
                    if (!item.wasImported)
                      TextButton.icon(
                        onPressed: () => _retryImport(item.content),
                        icon: const Icon(Icons.refresh, size: 16),
                        label: const Text('重试导入'),
                      ),
                  ],
                ),
                const SizedBox(height: 8),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.grey[300]!),
                  ),
                  child: Text(
                    item.content,
                    style: const TextStyle(
                      fontSize: 12,
                      fontFamily: 'monospace',
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Chip(
                      label: Text('${item.linkCount} 个链接'),
                      backgroundColor: Colors.blue[100],
                    ),
                    const SizedBox(width: 8),
                    Chip(
                      label: Text(_getTimeAgo(item.timestamp)),
                      backgroundColor: Colors.grey[200],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _getTimeAgo(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inDays > 0) {
      return '${difference.inDays}天前';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}小时前';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}分钟前';
    } else {
      return '刚刚';
    }
  }

  void _copyToClipboard(String content) {
    Clipboard.setData(ClipboardData(text: content));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('已复制到剪贴板')),
    );
  }

  void _retryImport(String content) async {
    try {
      // 临时设置剪贴板内容并触发导入
      await Clipboard.setData(ClipboardData(text: content));
      await globalState.appController.addProfileFromClipboard();
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('导入成功')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('导入失败: $e')),
        );
      }
    }
  }

  void _exportHistory() async {
    try {
      final jsonData = ClipboardManager.instance.exportHistory();
      await Clipboard.setData(ClipboardData(text: jsonData));
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('历史记录已导出到剪贴板')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('导出失败: $e')),
        );
      }
    }
  }

  void _importHistory() async {
    try {
      final data = await Clipboard.getData('text/plain');
      final jsonData = data?.text;
      
      if (jsonData == null || jsonData.isEmpty) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('剪贴板为空')),
          );
        }
        return;
      }
      
      ClipboardManager.instance.importHistoryFromJson(jsonData);
      
      if (mounted) {
        setState(() {}); // 刷新界面
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('历史记录导入成功')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('导入失败: $e')),
        );
      }
    }
  }

  void _clearHistory() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('确认清空'),
        content: const Text('确定要清空所有导入历史记录吗？此操作不可撤销。'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('取消'),
          ),
          ElevatedButton(
            onPressed: () {
              ClipboardManager.instance.clearHistory();
              Navigator.of(context).pop();
              setState(() {}); // 刷新界面
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('历史记录已清空')),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('清空'),
          ),
        ],
      ),
    );
  }
} 