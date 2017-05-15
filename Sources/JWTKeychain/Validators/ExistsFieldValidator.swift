import Vapor
//import VaporForms
import Fluent

/// Validates if the value exists on the database
public class ExistsFieldValidator<ModelType: Entity>: FieldValidator<String> {

    let column: String
    var additionalFilters: [(column:String, comparison:Filter.Comparison, value:String)] = []
    let message: String?

    public init(column: String, additionalFilters: [(column:String, comparison:Filter.Comparison, value:String)]=[], message: String?=nil) {

        self.column = column
        self.additionalFilters.append(contentsOf: additionalFilters)
        self.message = message

    }

    public convenience init(column: String, ignoreColumn: String, ignoreValue: String,
        additionalFilters: [(column:String, comparison:Filter.Comparison, value:String)]=[],
        message: String?=nil) {

        let ignoreFilter = (column: ignoreColumn, comparison: Filter.Comparison.notEquals, value: ignoreValue)

        var additionalFilters = additionalFilters
        additionalFilters.append(ignoreFilter)

        self.init(column: column, additionalFilters: additionalFilters, message: message)
    }

    public override func validate(input value: String) -> FieldValidationResult {

        // Let's create the main filter
        do {
            let query = try ModelType.query()

            try query.filter(self.column, value)

            // If we have addition filters, add them
            try self.additionalFilters.forEach({ filter in
                try query.filter(filter.column, filter.comparison, filter.value)
            })

            // Check if any record exists
            if(try query.count() < 1){
                return .failure([.validationFailed(message: message ?? "\(self.column) \(value) does not exist")])
            }

            // If not we have green light
            return .success(Node(value))


        } catch {
            return .failure([.validationFailed(message: message ?? "\(self.column) \(value) does not exist")])
        }
    }
}
