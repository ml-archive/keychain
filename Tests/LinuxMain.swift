import XCTest
@testable import JWTKeychainTests

XCTMain([
     testCase(JWTKeychainTests.allTests),
     testCase(JWTAuthMiddlewareTests.allTests),
])
