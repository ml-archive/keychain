import HTTP

public enum Middlewares {
    /// Any routes grouped with these middleware will need to be authenticated
    /// with a valid API Access JWT
    public static var secured: [Middleware] = []
}
