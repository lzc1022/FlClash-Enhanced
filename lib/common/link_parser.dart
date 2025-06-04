import 'dart:convert';
import 'dart:typed_data';
import 'package:crypto/crypto.dart';

import 'package:fl_clash/common/common.dart';

class LinkParser {
  static const String v2rayDefaultGroup = "v2ray";
  static const String ssrDefaultGroup = "ssr";
  static const String trojanDefaultGroup = "trojan";

  /// 解析代理链接列表
  static List<Map<String, dynamic>> parseProxyLinks(String content) {
    final lines = content.split('\n');
    final proxies = <Map<String, dynamic>>[];
    final existingNames = <String>{};
    
    for (final line in lines) {
      final trimmedLine = line.trim();
      if (trimmedLine.isEmpty) continue;
      
      try {
        final proxy = parseProxyLink(trimmedLine);
        if (proxy != null) {
          // 确保节点名称唯一
          final originalName = proxy['name'] as String;
          final uniqueName = generateUniqueName(originalName, existingNames);
          proxy['name'] = uniqueName;
          existingNames.add(uniqueName);
          
          proxies.add(proxy);
        }
      } catch (e) {
        print('解析代理链接失败: $trimmedLine, 错误: $e');
      }
    }
    
    return proxies;
  }
  
  /// 解析单个代理链接
  static Map<String, dynamic>? parseProxyLink(String link) {
    if (link.startsWith('ss://')) {
      return _parseShadowsocks(link);
    } else if (link.startsWith('vless://')) {
      return _parseVLESS(link);
    } else if (link.startsWith('vmess://')) {
      return _parseVMess(link);
    } else if (link.startsWith('ssr://')) {
      return _parseShadowsocksR(link);
    } else if (link.startsWith('trojan://')) {
      return _parseTrojan(link);
    }
    return null;
  }
  
  /// 解析Shadowsocks链接
  static Map<String, dynamic>? _parseShadowsocks(String link) {
    try {
      final uri = Uri.parse(link);
      final userInfo = uri.userInfo;
      final fragment = Uri.decodeComponent(uri.fragment);
      
      String method, password;
      
      if (userInfo.contains(':')) {
        // 格式: method:password@host:port
        final parts = userInfo.split(':');
        method = parts[0];
        password = parts.sublist(1).join(':');
      } else {
        // Base64编码格式
        final decoded = utf8.decode(base64.decode(userInfo));
        final parts = decoded.split(':');
        if (parts.length != 2) return null;
        method = parts[0];
        password = parts[1];
      }
      
      return {
        'name': fragment.isNotEmpty ? fragment : '${uri.host}:${uri.port}',
        'type': 'ss',
        'server': uri.host,
        'port': uri.port,
        'cipher': method,
        'password': password,
        'udp': true,
      };
    } catch (e) {
      print('解析SS链接失败: $e');
      return null;
    }
  }
  
  /// 解析VLESS链接
  static Map<String, dynamic>? _parseVLESS(String link) {
    try {
      final uri = Uri.parse(link);
      final query = uri.queryParameters;
      final fragment = Uri.decodeComponent(uri.fragment);
      
      final proxy = <String, dynamic>{
        'name': fragment.isNotEmpty ? fragment : '${uri.host}:${uri.port}',
        'type': 'vless',
        'server': uri.host,
        'port': uri.port,
        'uuid': uri.userInfo,
        'udp': true,
      };
      
      // 处理TLS
      final security = query['security'];
      if (security == 'tls' || security == 'xtls') {
        proxy['tls'] = true;
        if (query['sni'] != null) {
          proxy['servername'] = query['sni'];
        }
        if (query['alpn'] != null) {
          proxy['alpn'] = query['alpn']!.split(',');
        }
        if (query['fp'] != null) {
          proxy['client-fingerprint'] = query['fp'];
        }
      }
      
      // 处理传输协议
      final type = query['type'] ?? 'tcp';
      proxy['network'] = type;
      
      switch (type) {
        case 'ws':
          proxy['ws-opts'] = {
            'path': query['path'] ?? '/',
            'headers': query['host'] != null ? {'Host': query['host']} : {},
          };
          break;
        case 'grpc':
          proxy['grpc-opts'] = {
            'grpc-service-name': query['serviceName'] ?? '',
          };
          break;
        case 'h2':
          proxy['h2-opts'] = {
            'host': query['host'] != null ? [query['host']] : [],
            'path': query['path'] ?? '/',
          };
          break;
      }
      
      // 处理流控
      if (query['flow'] != null) {
        proxy['flow'] = query['flow'];
      }
      
      return proxy;
    } catch (e) {
      print('解析VLESS链接失败: $e');
      return null;
    }
  }
  
  /// 解析VMess链接
  static Map<String, dynamic>? _parseVMess(String link) {
    try {
      final base64Data = link.substring(8); // 移除 "vmess://"
      final jsonData = utf8.decode(base64.decode(base64Data));
      final data = json.decode(jsonData) as Map<String, dynamic>;
      
      final proxy = <String, dynamic>{
        'name': data['ps'] ?? '${data['add']}:${data['port']}',
        'type': 'vmess',
        'server': data['add'],
        'port': int.parse(data['port'].toString()),
        'uuid': data['id'],
        'alterId': int.parse((data['aid'] ?? '0').toString()),
        'cipher': data['scy'] ?? 'auto',
        'udp': true,
      };
      
      // 处理TLS
      if (data['tls'] == 'tls') {
        proxy['tls'] = true;
        if (data['sni'] != null && data['sni'].isNotEmpty) {
          proxy['servername'] = data['sni'];
        }
      }
      
      // 处理传输协议
      final net = data['net'] ?? 'tcp';
      proxy['network'] = net;
      
      switch (net) {
        case 'ws':
          proxy['ws-opts'] = {
            'path': data['path'] ?? '/',
            'headers': data['host'] != null && data['host'].isNotEmpty 
                ? {'Host': data['host']} : {},
          };
          break;
        case 'h2':
          proxy['h2-opts'] = {
            'host': data['host'] != null && data['host'].isNotEmpty 
                ? [data['host']] : [],
            'path': data['path'] ?? '/',
          };
          break;
        case 'grpc':
          proxy['grpc-opts'] = {
            'grpc-service-name': data['path'] ?? '',
          };
          break;
      }
      
      return proxy;
    } catch (e) {
      print('解析VMess链接失败: $e');
      return null;
    }
  }
  
  /// 解析ShadowsocksR链接
  static Map<String, dynamic>? _parseShadowsocksR(String link) {
    try {
      final base64Data = link.substring(6); // 移除 "ssr://"
      final decoded = utf8.decode(base64.decode(base64Data));
      
      final parts = decoded.split('/?');
      if (parts.length != 2) return null;
      
      final serverParts = parts[0].split(':');
      if (serverParts.length != 6) return null;
      
      final queryString = parts[1];
      final query = Uri.splitQueryString(queryString);
      
      return {
        'name': query['remarks'] != null 
            ? utf8.decode(base64.decode(query['remarks']!))
            : '${serverParts[0]}:${serverParts[1]}',
        'type': 'ssr',
        'server': serverParts[0],
        'port': int.parse(serverParts[1]),
        'protocol': serverParts[2],
        'cipher': serverParts[3],
        'obfs': serverParts[4],
        'password': utf8.decode(base64.decode(serverParts[5])),
        'udp': true,
        'protocol-param': query['protoparam'] ?? '',
        'obfs-param': query['obfsparam'] != null 
            ? utf8.decode(base64.decode(query['obfsparam']!))
            : '',
      };
    } catch (e) {
      print('解析SSR链接失败: $e');
      return null;
    }
  }
  
  /// 解析Trojan链接
  static Map<String, dynamic>? _parseTrojan(String link) {
    try {
      final uri = Uri.parse(link);
      final query = uri.queryParameters;
      final fragment = Uri.decodeComponent(uri.fragment);
      
      final proxy = <String, dynamic>{
        'name': fragment.isNotEmpty ? fragment : '${uri.host}:${uri.port}',
        'type': 'trojan',
        'server': uri.host,
        'port': uri.port,
        'password': uri.userInfo,
        'udp': true,
        'skip-cert-verify': query['allowInsecure'] == '1',
      };
      
      if (query['sni'] != null) {
        proxy['sni'] = query['sni'];
      }
      
      if (query['alpn'] != null) {
        proxy['alpn'] = query['alpn']!.split(',');
      }
      
      // 处理传输协议
      final type = query['type'];
      if (type != null) {
        proxy['network'] = type;
        
        switch (type) {
          case 'ws':
            proxy['ws-opts'] = {
              'path': query['path'] ?? '/',
              'headers': {},
            };
            break;
          case 'grpc':
            proxy['grpc-opts'] = {
              'grpc-service-name': query['serviceName'] ?? '',
            };
            break;
        }
      }
      
      if (query['fp'] != null) {
        proxy['client-fingerprint'] = query['fp'];
      }
      
      return proxy;
    } catch (e) {
      print('解析Trojan链接失败: $e');
      return null;
    }
  }
  
  /// 生成Clash配置
  static Map<String, dynamic> generateClashConfig(List<Map<String, dynamic>> proxies) {
    final config = <String, dynamic>{
      'port': 7890,
      'socks-port': 7891,
      'allow-lan': false,
      'mode': 'rule',
      'log-level': 'info',
      'external-controller': '127.0.0.1:9090',
      'proxies': proxies,
      'proxy-groups': [
        {
          'name': '节点选择',
          'type': 'select',
          'proxies': ['自动选择', 'DIRECT'] + proxies.map((p) => p['name'] as String).toList(),
        },
        {
          'name': '自动选择',
          'type': 'url-test',
          'proxies': proxies.map((p) => p['name'] as String).toList(),
          'url': 'http://www.gstatic.com/generate_204',
          'interval': 300,
        },
      ],
      'rules': [
        'DOMAIN-SUFFIX,local,DIRECT',
        'IP-CIDR,127.0.0.0/8,DIRECT',
        'IP-CIDR,172.16.0.0/12,DIRECT',
        'IP-CIDR,192.168.0.0/16,DIRECT',
        'IP-CIDR,10.0.0.0/8,DIRECT',
        'IP-CIDR,17.0.0.0/8,DIRECT',
        'IP-CIDR,100.64.0.0/10,DIRECT',
        'IP-CIDR,224.0.0.0/4,DIRECT',
        'IP-CIDR6,fe80::/10,DIRECT',
        'GEOIP,CN,DIRECT',
        'MATCH,节点选择',
      ],
    };
    
    return config;
  }
  
  /// 生成唯一名称
  static String generateUniqueName(String baseName, Set<String> existingNames) {
    if (!existingNames.contains(baseName)) {
      return baseName;
    }
    
    int counter = 1;
    String uniqueName;
    do {
      uniqueName = '$baseName-$counter';
      counter++;
    } while (existingNames.contains(uniqueName));
    
    return uniqueName;
  }
} 