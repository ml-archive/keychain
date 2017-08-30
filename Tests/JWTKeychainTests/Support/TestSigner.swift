import JWT

// TODO: remove or create tests that use this
class TestSigner: Signer {
    func sign(message: Bytes) throws -> Bytes {
        return "testSignature".makeBytes()
    }

    func verify(signature: Bytes, message: Bytes) throws {}
}
