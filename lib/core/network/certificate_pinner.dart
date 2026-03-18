/// Certificate pin sabitleri.
/// Pin degerleri SHA-256 SPKI hash'leridir.
/// Her domain icin leaf + backup (intermediate CA) pin bulunmalidir.
const kCertificatePins = <String, List<String>>{
  'kxrdblgdydixgeruejpc.supabase.co': [
    'GU2W4j1P24T3sqlI+o6YTnidzz0PI8fB/Gvd2ITfSZE=', // leaf
    'kIdp6NNEd8wsugYyyIYFsi1ylMCED3hZbSR8ZFsa/A4=', // intermediate CA
  ],
  'firestore.googleapis.com': [
    'UaKBWnoEx6t0je/kqEQQI8mTFKQx23cg3on7tECzBf4=', // leaf
    'vh78KSg1Ry4NaqGDV10w/cTb9VH3BQUZoCWNa93W/EY=', // intermediate CA
  ],
  'googleapis.com': [
    'UaKBWnoEx6t0je/kqEQQI8mTFKQx23cg3on7tECzBf4=', // leaf
    'vh78KSg1Ry4NaqGDV10w/cTb9VH3BQUZoCWNa93W/EY=', // intermediate CA
  ],
};

/// Domain bazli certificate pin dogrulamasi.
class CertificatePinner {
  const CertificatePinner({required this.pins});

  final Map<String, List<String>> pins;

  /// Bu domain icin pin tanimli mi?
  bool hasPinsFor(String host) {
    if (pins.containsKey(host)) return true;
    // Alt domain destegi: x.supabase.co -> supabase.co
    for (final domain in pins.keys) {
      if (host.endsWith('.$domain')) return true;
    }
    return false;
  }

  /// Domain icin tanimli pin listesini dondurur.
  List<String>? getPinsFor(String host) {
    if (pins.containsKey(host)) return pins[host];
    for (final entry in pins.entries) {
      if (host.endsWith('.${entry.key}')) return entry.value;
    }
    return null;
  }
}
