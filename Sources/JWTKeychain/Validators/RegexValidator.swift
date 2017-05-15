import Vapor
//import VaporForms
import Fluent


/// Validates a string against the given regex
public class RegexValidator: FieldValidator<String> {
    
    let regex: String?
    let message: String?
    
    
    public init(regex: String?=nil, message: String?=nil) {
        self.regex = regex
        self.message = message
    }
    
    public override func validate(input value: String) -> FieldValidationResult {
        
        if let regex = self.regex {
            
            let range = value.range(of: regex, options: .regularExpression)
            guard let _ = range else {
                return .failure([.validationFailed(message: message ?? "String did not match regular expression.")])
            }
            
        }
        
        return .success(Node(value))
    }
}
