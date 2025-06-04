import 'package:fl_clash/common/common.dart';
import 'package:fl_clash/pages/scan.dart';
import 'package:fl_clash/state.dart';
import 'package:fl_clash/widgets/widgets.dart';
import 'package:flutter/material.dart';

class AddProfile extends StatelessWidget {
  final BuildContext context;

  const AddProfile({
    super.key,
    required this.context,
  });

  _handleAddProfileFormFile() async {
    globalState.appController.addProfileFormFile();
  }

  _handleAddProfileFormURL(String url) async {
    globalState.appController.addProfileFormURL(url);
  }

  _toScan() async {
    if (system.isDesktop) {
      globalState.appController.addProfileFormQrCode();
      return;
    }
    final url = await BaseNavigator.push(
      context,
      const ScanPage(),
    );
    if (url != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _handleAddProfileFormURL(url);
      });
    }
  }

  _toAdd() async {
    final url = await globalState.showCommonDialog<String>(
      child: const URLFormDialog(),
    );
    if (url != null) {
      _handleAddProfileFormURL(url);
    }
  }

  _handleAddProfileFromClipboard() async {
    globalState.appController.addProfileFromClipboard();
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
              Text('3. 点击"剪贴板导入"按钮'),
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

  @override
  Widget build(context) {
    return ListView(
      children: [
        ListItem(
          leading: const Icon(Icons.qr_code_sharp),
          title: Text(appLocalizations.qrcode),
          subtitle: Text(appLocalizations.qrcodeDesc),
          onTap: _toScan,
        ),
        ListItem(
          leading: const Icon(Icons.upload_file_sharp),
          title: Text(appLocalizations.file),
          subtitle: Text(appLocalizations.fileDesc),
          onTap: _handleAddProfileFormFile,
        ),
        ListItem(
          leading: const Icon(Icons.cloud_download_sharp),
          title: Text(appLocalizations.url),
          subtitle: Text(appLocalizations.urlDesc),
          onTap: _toAdd,
        ),
        ListItem(
          leading: const Icon(Icons.paste),
          title: Text(appLocalizations.clipboardImport),
          subtitle: const Text("从剪贴板导入订阅链接或代理链接"),
          trailing: IconButton(
            icon: Icon(
              Icons.info_outline,
              color: Theme.of(context).colorScheme.primary,
              size: 20,
            ),
            onPressed: () => _showMultiLinkImportInfo(context),
            tooltip: '多链接导入说明',
          ),
          onTap: _handleAddProfileFromClipboard,
        )
      ],
    );
  }
}

class URLFormDialog extends StatefulWidget {
  const URLFormDialog({super.key});

  @override
  State<URLFormDialog> createState() => _URLFormDialogState();
}

class _URLFormDialogState extends State<URLFormDialog> {
  final urlController = TextEditingController();

  _handleAddProfileFormURL() async {
    final url = urlController.value.text;
    if (url.isEmpty) return;
    Navigator.of(context).pop<String>(url);
  }

  @override
  Widget build(BuildContext context) {
    return CommonDialog(
      title: appLocalizations.importFromURL,
      actions: [
        TextButton(
          onPressed: _handleAddProfileFormURL,
          child: Text(appLocalizations.submit),
        )
      ],
      child: SizedBox(
        width: 300,
        child: Wrap(
          runSpacing: 16,
          children: [
            TextField(
              keyboardType: TextInputType.url,
              minLines: 1,
              maxLines: 5,
              onSubmitted: (_) {
                _handleAddProfileFormURL();
              },
              onEditingComplete: _handleAddProfileFormURL,
              controller: urlController,
              decoration: InputDecoration(
                border: const OutlineInputBorder(),
                labelText: appLocalizations.url,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
