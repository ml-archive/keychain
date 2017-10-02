import HTTP

public protocol RequestUpdateable {
    func update(request: Request) throws
}
