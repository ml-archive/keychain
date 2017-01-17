import Vapor
import Auth
import Foundation
import HTTP
import Turnstile
import TurnstileCrypto
import TurnstileWeb
import VaporForms

/// Basic controller functionality for a user than can be authorized.
open class UserController: UserControllerType {
    public var configuration: ConfigurationType

    required public init(configuration: ConfigurationType) {
        self.configuration = configuration
    }

}
