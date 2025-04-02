import Foundation

/// A protocol that defines requirements for converting between Codable types and JSON data.
///
/// Usage Example:
/// ```
/// struct User: JSONConvertible {
///     let id: Int
///     let name: String
/// }
///
/// let user = User(id: 1, name: "John")
/// let jsonData = try user.toJsonData()
/// let decodedUser = try User(jsonData: jsonData)
/// ```
protocol JSONConvertible {
    init(jsonData: Data) throws
    func toJsonData() throws -> Data
}

private let defaultDecoder = JSONDecoder()
private let defaultEncoder = JSONEncoder()

extension JSONConvertible where Self: Codable {

    init(jsonData: Data) throws {
        self = try defaultDecoder.decode(Self.self, from: jsonData)
    }

    func toJsonData() throws -> Data {
        try defaultEncoder.encode(self)
    }
}

/// A protocol that defines requirements for loading resources from a specified bundle.
///
/// Usage Example:
/// ```
/// struct Config: BundleLoadable, JSONConvertible {
///     let apiUrl: String
///     let maxRetries: Int
/// }
///
/// // Loading from the main app bundle
/// let config = try Config(bundleResource: "config.json")
///
/// // Loading from the test bundle
/// let testBundle = Bundle(for: TestClass.self)
/// let testConfig = try Config(bundleResource: "test_config.json", bundle: testBundle)
/// ```
protocol BundleLoadable {
    init(bundleResource: String, bundle: Bundle) throws
}

extension BundleLoadable where Self: JSONConvertible {
    init(bundleResource: String, bundle: Bundle = .main) throws {
        guard let url = bundle.url(forResource: bundleResource, withExtension: nil) else {
            throw NSError(
                domain: "BundleLoadable",
                code: 404,
                userInfo: [NSLocalizedDescriptionKey: "Resource \(bundleResource) not found in bundle"]
            )
        }

        let data = try Data(contentsOf: url)
        try self.init(jsonData: data)
    }
}

/// This initializer is designed to be used with string literals that are known at compile-time
/// to be valid URLs. It will trigger a precondition failure if the string cannot be converted
/// to a valid URL, making it safer to use for hard-coded URLs that should never fail.
///
/// - Example:
///   ```
///   let url = URL(staticString: "https://example.com/api")
///   ```
extension URL {
    init(staticString string: StaticString) {
        guard let url = URL(string: "\(string)") else {
            preconditionFailure("Invalid static URL string: \(string)")
        }
        self = url
    }
}
