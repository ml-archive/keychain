import JWT

class TestSigner: Signer {
    func sign(message: Bytes) throws -> Bytes {
        return (message.makeString() + ".signed").makeBytes()
    }

    func verify(signature: Bytes, message: Bytes) throws {}
}
