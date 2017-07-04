import JWT

class TestSigner: Signer {
    func sign(message: Bytes) throws -> Bytes {
        return "testSignature".makeBytes()
    }

    func verify(signature: Bytes, message: Bytes) throws {}
}
