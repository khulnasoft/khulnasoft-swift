import struct Foundation.URL

/// A Khulnasoft account.
public struct Account: Hashable {
    /// The acount type.
    public enum AccountType: String, CaseIterable, Hashable, Codable {
        /// A user.
        case user
        
        /// An organization.
        case organization
    }

    /// The type of account.
    var type: AccountType

    /// The username of the account.
    var username: String

    /// The name of the account.
    var name: String

    /// The GitHub URL of the account.
    var githubURL: URL?
}

// MARK: - Identifiable

extension Account: Identifiable {
    public typealias ID = String

    public var id: ID {
        return self.username
    }
}

// MARK: - CustomStringConvertible

extension Account: CustomStringConvertible {
    public var description: String {
        return self.username
    }
}

// MARK: - Codable

extension Account: Codable {
    public enum CodingKeys: String, CodingKey {
        case type
        case username
        case name
        case githubURL = "github_url"
    }
}

extension Account.AccountType: CustomStringConvertible {
    public var description: String {
        return self.rawValue
    }
}
