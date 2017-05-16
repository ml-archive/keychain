import Vapor
import HTTP

/// Defines basic authorization functionality.
public protocol FrontendResetPasswordControllerType {

    /// Initializes the FrontendResetPasswordController with the JWT 
    /// configuration.
    ///
    /// - Parameters:
    /// configuration : the JWT configuration to be used to generate user tokens.
    /// drop : the Droplet instance
//    init(drop: Droplet, configuration: ConfigurationType)

    /// Shows the form where the user can reset the password
    ///
    /// - Parameter request: current request
    /// - Returns: view
    func resetPasswordForm(request: Request, token: String) throws -> View

    /// Validates the reset request and actually changes the password
    ///
    /// - Parameter request: current request
    /// - Returns: success or error response
    /// - Throws: if something goes wrong
    func resetPasswordChange(request: Request) throws -> Response
    
}
