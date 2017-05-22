import Vapor

class TestHasher: HashProtocol {
    func make(_ message: Bytes) throws -> Bytes {
        return message
    }

    func check(_ message: Bytes, matchesHash digest: Bytes) throws -> Bool {
        return true
    }
}
