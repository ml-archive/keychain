import Vapor
import HTTP
import VaporForms

/// Defines basic authorization functionality.
public protocol UserControllerType {
    /// Initializes the UsersController with a JWT configuration.
    ///
    /// - Parameters:
    /// configuration : the JWT configuration to be used to generate user tokens.
    init(configuration: ConfigurationType)

    /// Registers a user on the DB.
    ///
    /// - Parameter request: current request.
    /// - Returns: JSON response with User data.
    /// - Throws: on invalid data or if unable to store data on the DB.
    func register(request: Request) throws -> ResponseRepresentable

    /// Logins the user on the system, giving the token back.
    ///
    /// - Parameter request: current request.
    /// - Returns: JSON response with User data.
    /// - Throws: on invalid data or wrong credentials.
    func login(request: Request) throws -> ResponseRepresentable

    /// Logs the user out of the system.
    ///
    /// - Parameter request: current request.
    /// - Returns: JSON success response.
    /// - Throws: if not able to find token.
    func logout(request: Request) throws -> ResponseRepresentable

    /// Generates a new token for the user.
    ///
    /// - Parameter request: current request.
    /// - Returns: JSON with token.
    /// - Throws: if not able to generate token.
    func regenerate(request: Request) throws -> ResponseRepresentable

    /// Returns the authenticated user data.
    ///
    /// - Parameter request: current request.
    /// - Returns: JSON response with User data.
    /// - Throws: on no user found.
    func me(request: Request) throws -> ResponseRepresentable
	var configuration: ConfigurationType { get set }
}

extension UserControllerType {
	
	public func register(request: Request) throws -> ResponseRepresentable {
		do {
			// Validate request
			let requestData = try StoreRequest(validating: request.data)
			
			var user = User(
				name: requestData.name,
				email: requestData.email,
				password: requestData.password
			)
			
			try user.save()
			let token = try self.configuration.generateToken(userId: user.id!)
			return try user.makeJSON(token: token)
			
		} catch FormError.validationFailed(let fieldset) {
			throw Abort.custom(status: Status.preconditionFailed, message: "Invalid data: \(fieldset.errors)")
		} catch {
			throw Abort.custom(status: Status.unprocessableEntity, message: "Could not create user")
		}
	}
	
	public func login(request: Request) throws -> ResponseRepresentable {
		// Get our credentials
		guard let email = request.data["email"]?.string, let password = request.data["password"]?.string else {
			throw Abort.custom(status: Status.preconditionFailed, message: "Missing email or password")
		}
		
		let credentials = EmailPassword(email: email, password: password)
		
		do {
			
			try request.auth.login(credentials)
			let user = try request.user()
			let token = try configuration.generateToken(userId: user.id!)
			return try user.makeJSON(token: token)
			
		} catch _ {
			throw Abort.custom(status: Status.badRequest, message: "Invalid email or password")
		}
	}
	
	public func logout(request: Request) throws -> ResponseRepresentable {
		// Clear the session
		request.subject.logout()
		
		return try JSON(node: ["success": true])
	}
	
	public func regenerate(request: Request) throws -> ResponseRepresentable {
		let user = try request.user()
		let token = try self.configuration.generateToken(userId: user.id!)
		return try JSON(node: ["token": token])
	}
	
	public func me(request: Request) throws -> ResponseRepresentable {
		let user = try request.user()
		let token = try self.configuration.generateToken(userId: user.id!)
		return try user.makeJSON(token: token)
	}
}
