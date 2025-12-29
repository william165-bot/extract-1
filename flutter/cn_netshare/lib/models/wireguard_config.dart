class WireGuardConfig {
  final String address;
  final String privateKey;
  final String dns;
  final String publicKey;
  final String endpoint;
  final String allowedIps;

  WireGuardConfig({
    required this.address,
    required this.privateKey,
    required this.dns,
    required this.publicKey,
    required this.endpoint,
    required this.allowedIps,
  });

  factory WireGuardConfig.fromString(String configString) {
    final lines = configString.split('\n');
    String address = '';
    String privateKey = '';
    String dns = '';
    String publicKey = '';
    String endpoint = '';
    String allowedIps = '';

    for (final line in lines) {
      final trimmed = line.trim();
      if (trimmed.startsWith('Address')) {
        address = trimmed.split('=')[1].trim();
      } else if (trimmed.startsWith('PrivateKey')) {
        privateKey = trimmed.split('=')[1].trim();
      } else if (trimmed.startsWith('DNS')) {
        dns = trimmed.split('=')[1].trim();
      } else if (trimmed.startsWith('PublicKey')) {
        publicKey = trimmed.split('=')[1].trim();
      } else if (trimmed.startsWith('Endpoint')) {
        endpoint = trimmed.split('=')[1].trim();
      } else if (trimmed.startsWith('AllowedIPs')) {
        allowedIps = trimmed.split('=')[1].trim();
      }
    }

    return WireGuardConfig(
      address: address,
      privateKey: privateKey,
      dns: dns,
      publicKey: publicKey,
      endpoint: endpoint,
      allowedIps: allowedIps,
    );
  }

  String toConfigString() {
    return '''[Interface]
Address = $address
PrivateKey = $privateKey
DNS = $dns

[Peer]
PublicKey = $publicKey
Endpoint = $endpoint
AllowedIPs = $allowedIps
PersistentKeepalive = 25''';
  }

  Map<String, dynamic> toJson() {
    return {
      'address': address,
      'private_key': privateKey,
      'dns': dns,
      'public_key': publicKey,
      'endpoint': endpoint,
      'allowed_ips': allowedIps,
    };
  }
}
