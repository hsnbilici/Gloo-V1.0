import Foundation
import Security
import CommonCrypto

/// iOS native certificate pinning — Supabase + Google/Firebase domain'leri icin
/// SHA-256 SPKI pin dogrulamasi.
///
/// Dart katmanindaki `PinnedHttpOverrides` ile ayni pin degerlerini kullanir.
/// Bu eklenti URLSession seviyesinde MITM saldirilarini onler.
class CertificatePinningPlugin: NSObject, URLSessionDelegate {

    static let shared = CertificatePinningPlugin()

    /// SHA-256 SPKI pin'leri — Dart katmanindaki `kCertificatePins` ile senkron tutulmali.
    /// Pin expiry: 2027-06-01
    private let pins: [String: [String]] = [
        "kxrdblgdydixgeruejpc.supabase.co": [
            "GU2W4j1P24T3sqlI+o6YTnidzz0PI8fB/Gvd2ITfSZE=", // leaf
            "kIdp6NNEd8wsugYyyIYFsi1ylMCED3hZbSR8ZFsa/A4=", // intermediate CA
        ],
        "firestore.googleapis.com": [
            "UaKBWnoEx6t0je/kqEQQI8mTFKQx23cg3on7tECzBf4=", // leaf
            "vh78KSg1Ry4NaqGDV10w/cTb9VH3BQUZoCWNa93W/EY=", // intermediate CA
        ],
        "googleapis.com": [
            "UaKBWnoEx6t0je/kqEQQI8mTFKQx23cg3on7tECzBf4=", // leaf
            "vh78KSg1Ry4NaqGDV10w/cTb9VH3BQUZoCWNa93W/EY=", // intermediate CA
        ],
    ]

    /// Domain icin pin tanimli mi? Alt domain destegi var.
    private func pinsFor(host: String) -> [String]? {
        if let direct = pins[host] { return direct }
        for (domain, pinList) in pins {
            if host.hasSuffix(".\(domain)") { return pinList }
        }
        return nil
    }

    // MARK: - URLSessionDelegate

    func urlSession(
        _ session: URLSession,
        didReceive challenge: URLAuthenticationChallenge,
        completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void
    ) {
        guard challenge.protectionSpace.authenticationMethod == NSURLAuthenticationMethodServerTrust,
              let serverTrust = challenge.protectionSpace.serverTrust,
              let expectedPins = pinsFor(host: challenge.protectionSpace.host)
        else {
            completionHandler(.performDefaultHandling, nil)
            return
        }

        // Sertifika zincirini dogrula
        var error: CFError?
        let isValid = SecTrustEvaluateWithError(serverTrust, &error)
        guard isValid else {
            completionHandler(.cancelAuthenticationChallenge, nil)
            return
        }

        // Zincirdeki her sertifikanin SPKI pin'ini kontrol et
        let certCount = SecTrustGetCertificateCount(serverTrust)
        for i in 0..<certCount {
            guard let cert = SecTrustCopyCertificateChain(serverTrust)?
                .unsafelyUnwrapped as? [SecCertificate],
                  i < cert.count
            else { continue }

            let certData = SecCertificateCopyData(cert[i]) as Data
            let spkiHash = sha256SpkiHash(from: certData)

            if expectedPins.contains(spkiHash) {
                completionHandler(.useCredential, URLCredential(trust: serverTrust))
                return
            }
        }

        // Hicbir pin eslesmedi — baglanti reddedilir
        completionHandler(.cancelAuthenticationChallenge, nil)
    }

    // MARK: - SPKI Hash

    /// DER formatindaki sertifikadan SHA-256 SPKI hash hesaplar.
    private func sha256SpkiHash(from certData: Data) -> String {
        // ASN.1 DER'den SubjectPublicKeyInfo'yu cikar
        guard let spkiData = extractSPKI(from: certData) else { return "" }
        // SHA-256 hash
        var hash = [UInt8](repeating: 0, count: Int(CC_SHA256_DIGEST_LENGTH))
        spkiData.withUnsafeBytes { buffer in
            _ = CC_SHA256(buffer.baseAddress, CC_LONG(spkiData.count), &hash)
        }
        return Data(hash).base64EncodedString()
    }

    /// DER sertifikadan SubjectPublicKeyInfo bolumunu cikarir.
    private func extractSPKI(from certData: Data) -> Data? {
        // SecCertificateCopyKey ile public key'i al, sonra external representation
        guard let cert = SecCertificateCreateWithData(nil, certData as CFData),
              let publicKey = SecCertificateCopyKey(cert),
              let publicKeyData = SecKeyCopyExternalRepresentation(publicKey, nil) as Data?
        else { return nil }

        // RSA 2048 SPKI header (ASN.1 DER prefix for RSA-2048 public key)
        let rsaHeader: [UInt8] = [
            0x30, 0x82, 0x01, 0x22, 0x30, 0x0D, 0x06, 0x09,
            0x2A, 0x86, 0x48, 0x86, 0xF7, 0x0D, 0x01, 0x01,
            0x01, 0x05, 0x00, 0x03, 0x82, 0x01, 0x0F, 0x00,
        ]

        // EC P-256 SPKI header
        let ecHeader: [UInt8] = [
            0x30, 0x59, 0x30, 0x13, 0x06, 0x07, 0x2A, 0x86,
            0x48, 0xCE, 0x3D, 0x02, 0x01, 0x06, 0x08, 0x2A,
            0x86, 0x48, 0xCE, 0x3D, 0x03, 0x01, 0x07, 0x03,
            0x42, 0x00,
        ]

        // Anahtar boyutuna gore header sec
        let header: [UInt8]
        if publicKeyData.count > 256 {
            header = rsaHeader // RSA
        } else {
            header = ecHeader // EC
        }

        var spkiData = Data(header)
        spkiData.append(publicKeyData)
        return spkiData
    }
}
