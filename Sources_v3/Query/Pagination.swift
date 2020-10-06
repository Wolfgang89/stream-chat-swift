//
// Copyright © 2020 Stream.io Inc. All rights reserved.
//

import Foundation

public typealias Pagination = Set<PaginationOption>

public extension Pagination {
    var limit: Int? {
        first(where: { $0.limit != nil })?.limit
    }
    
    var offset: Int? {
        first(where: { $0.offset != nil })?.offset
    }
    
    func encode(to encoder: Encoder) throws {
        try forEach { try $0.encode(to: encoder) }
    }
}

public extension KeyedEncodingContainer {
    mutating func encode(_ value: Pagination, forKey key: Self.Key) throws {
        let encoder = superEncoder(forKey: key)
        try value.forEach { try $0.encode(to: encoder) }
    }
}

/// Pagination options.
///
/// For example:
/// ```
/// // Limit by 20.
/// var pagination = Pagination.limit(20)
/// // add the offset to the limit:
/// pagination += .offset(40)
///
/// // Another pagination:
/// let pagination = Pagination.limit(50) + .lessThan("some_id")
/// ```
public enum PaginationOption: Encodable, Hashable {
    /// A default channels page size.
    public static let channelsPageSize: Self = .limit(20)
    /// A default channels page sizefor the next page.
    public static let channelsNextPageSize: Self = .limit(30)
    /// A default messages page size.
    public static let messagesPageSize: Self = .limit(25)
    /// A default messages page size for the next page.
    public static let messagesNextPageSize: Self = .limit(50)
    /// A default users page size.
    public static let usersPageSize: Self = .limit(30)
    
    private enum CodingKeys: String, CodingKey {
        case limit
        case offset
        case greaterThan = "id_gt"
        case greaterThanOrEqual = "id_gte"
        case lessThan = "id_lt"
        case lessThanOrEqual = "id_lte"
    }
    
    /// The amount of items requested from the APIs.
    case limit(_ limit: Int)
    
    /// The offset of requesting items.
    /// - Note: Using `lessThan` or `lessThanOrEqual` for pagination is preferable to using `offset`.
    case offset(_ offset: Int)
    
    /// Filter on ids greater than the given value.
    case greaterThan(_ id: String)
    
    /// Filter on ids greater than or equal to the given value.
    case greaterThanOrEqual(_ id: String)
    
    /// Filter on ids smaller than the given value.
    case lessThan(_ id: String)
    
    /// Filter on ids smaller than or equal to the given value.
    case lessThanOrEqual(_ id: String)
    
    /// A limit value, if the pagination has it or nil.
    public var limit: Int? {
        if case let .limit(limit) = self {
            return limit
        }
        
        return nil
    }
    
    /// An offset value, if the pagination has it or nil.
    public var offset: Int? {
        if case let .offset(offset) = self {
            return offset
        }
        
        return nil
    }
    
    /// Parameters for a request.
    var parameters: [String: Any] {
        switch self {
        case let .limit(limit):
            return ["limit": limit]
        case let .offset(offset):
            return ["offset": offset]
        case let .greaterThan(id):
            return ["id_gt": id]
        case let .greaterThanOrEqual(id):
            return ["id_gte": id]
        case let .lessThan(id):
            return ["id_lt": id]
        case let .lessThanOrEqual(id):
            return ["id_lte": id]
        }
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        switch self {
        case let .limit(limit):
            try container.encode(limit, forKey: .limit)
        case let .offset(offset):
            try container.encode(offset, forKey: .offset)
        case let .greaterThan(id):
            try container.encode(id, forKey: .greaterThan)
        case let .greaterThanOrEqual(id):
            try container.encode(id, forKey: .greaterThanOrEqual)
        case let .lessThan(id):
            try container.encode(id, forKey: .lessThan)
        case let .lessThanOrEqual(id):
            try container.encode(id, forKey: .lessThanOrEqual)
        }
    }
    
    public static func == (lhs: Self, rhs: Self) -> Bool {
        switch (lhs, rhs) {
        case let (.limit(value1), .limit(value2)),
             let (.offset(value1), .offset(value2)):
            return value1 == value2
        case let (.greaterThan(value1), .greaterThan(value2)),
             let (.greaterThanOrEqual(value1), .greaterThanOrEqual(value2)),
             let (.lessThan(value1), .lessThan(value2)),
             let (.lessThanOrEqual(value1), .lessThanOrEqual(value2)):
            return value1 == value2
        default:
            return false
        }
    }
}