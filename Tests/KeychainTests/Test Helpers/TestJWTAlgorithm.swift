import JWT

struct TestJWTAlgorithm: JWTAlgorithm {
    let name: String
    func sign<Plaintext: DataProtocol>(_ plaintext: Plaintext) -> [UInt8] {
        "signed by \(name): ".compactMap { $0.asciiValue } + plaintext.map { $0 }
    }

    func verify<Signature: DataProtocol, Plaintext: DataProtocol>(
        _ signature: Signature,
        signs plaintext: Plaintext
    ) -> Bool {
        signature.map { $0 } == ("signed by \(name): ".compactMap { $0.asciiValue } + plaintext)
    }
}
