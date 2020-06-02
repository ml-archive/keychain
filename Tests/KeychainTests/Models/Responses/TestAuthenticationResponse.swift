struct TestAuthenticationResponse: Decodable, Equatable {
    let user: UserResponse
    let accessToken: String
    let refreshToken: String
}
