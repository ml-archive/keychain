import Vapor

final class PayloadCache<P: JWTKeychainPayload>: Service {
    var payload: P? = nil
}
