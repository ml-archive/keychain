import Vapor
import JWTKeychain
import HTTP

internal class ResponderMock: Responder {
    
    func respond(to request: Request) throws -> Response {
        return Response(status: .accepted)
    }
}
