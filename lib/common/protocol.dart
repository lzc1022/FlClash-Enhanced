import 'dart:io';

import 'package:win32_registry/win32_registry.dart';

class Protocol {
  static Protocol? _instance;

  Protocol._internal();

  factory Protocol() {
    _instance ??= Protocol._internal();
    return _instance!;
  }

  void register(String scheme) {
    String protocolRegKey = 'Software\\Classes\\$scheme';
    String protocolCmdRegKey = 'shell\\open\\command';
    
    final regKey = Registry.currentUser.createKey(protocolRegKey);
    regKey.createValue(RegistryValue(
      'URL Protocol',
      RegistryValueType.string,
      '',
    ));
    regKey.createKey(protocolCmdRegKey).createValue(RegistryValue(
      '',
      RegistryValueType.string,
      '"${Platform.resolvedExecutable}" "%1"',
    ));
  }
}

final protocol = Protocol();
