//
// Copyright © 2020 Stream.io Inc. All rights reserved.
//

import Foundation

struct ChannelListPayload<ExtraData: ExtraDataTypes>: Decodable {
    /// A list of channels response (see `ChannelQuery`).
    let channels: [ChannelPayload<ExtraData>]
}

struct ChannelPayload<ExtraData: ExtraDataTypes>: Decodable {
    let channel: ChannelDetailPayload<ExtraData>
    
    let watcherCount: Int?
    
    let members: [MemberPayload<ExtraData.User>]
    
    let messages: [MessagePayload<ExtraData>]
    
    // TODO:
    /*
     message reads
     
     */
    private enum CodingKeys: String, CodingKey {
        case channel
        case messages
//    case messageReads = "read"
        case members
//    case watchers
        case watcherCount = "watcher_count"
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        channel = try container.decode(ChannelDetailPayload<ExtraData>.self, forKey: .channel)
        watcherCount = try container.decodeIfPresent(Int.self, forKey: .watcherCount)
        members = try container.decode([MemberPayload<ExtraData.User>].self, forKey: .members)
        messages = try container.decode([MessagePayload<ExtraData>].self, forKey: .messages)
    }
    
    // MARK: - For testing
    
    init(
        channel: ChannelDetailPayload<ExtraData>,
        watcherCount: Int,
        members: [MemberPayload<ExtraData.User>],
        messages: [MessagePayload<ExtraData>]
    ) {
        self.channel = channel
        self.watcherCount = watcherCount
        self.members = members
        self.messages = messages
    }
}

struct ChannelDetailPayload<ExtraData: ExtraDataTypes>: Decodable {
    let cid: ChannelId
    
    let extraData: ExtraData.Channel
    
    /// A channel type.
    public let typeRawValue: String
    
    /// The last message date.
    public let lastMessageAt: Date?
    /// A channel created date.
    public let createdAt: Date
    /// A channel deleted date.
    public let deletedAt: Date?
    /// A channel updated date.
    public let updatedAt: Date
    
    /// A creator of the channel.
    public let createdBy: UserPayload<ExtraData.User>?
    /// A config.
    public let config: ChannelConfig
    /// Checks if the channel is frozen.
    public let isFrozen: Bool
    
    let members: [MemberPayload<ExtraData.User>]?
    
    let memberCount: Int
    
    /// A list of users to invite in the channel.
    let invitedMembers: [MemberPayload<ExtraData.User>] = [] // TODO?
    
    /// The team the channel belongs to. You need to enable multi-tenancy if you want to use this, else it'll be nil.
    /// Refer to [docs](https://getstream.io/chat/docs/multi_tenant_chat/?language=swift) for more info.
    public let team: String
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: ChannelCodingKeys.self)
        typeRawValue = try container.decode(String.self, forKey: .typeRawValue)
        cid = try container.decode(ChannelId.self, forKey: .cid)
        let config = try container.decode(ChannelConfig.self, forKey: .config)
        self.config = config
        createdAt = try container.decodeIfPresent(Date.self, forKey: .createdAt) ?? config.createdAt
        updatedAt = try container.decode(Date.self, forKey: .updatedAt)
        deletedAt = try container.decodeIfPresent(Date.self, forKey: .deletedAt)
        createdBy = try container.decodeIfPresent(UserPayload<ExtraData.User>.self, forKey: .createdBy)
        lastMessageAt = try container.decodeIfPresent(Date.self, forKey: .lastMessageAt)
        isFrozen = try container.decode(Bool.self, forKey: .frozen)
        team = try container.decodeIfPresent(String.self, forKey: .team) ?? ""
        memberCount = try container.decode(Int.self, forKey: .memberCount)
        
        members = try container.decodeIfPresent([MemberPayload<ExtraData.User>].self, forKey: .members)
        
        extraData = try ExtraData.Channel(from: decoder)
    }
    
    // MARK: - For testing
    
    internal init(
        cid: ChannelId,
        extraData: ExtraData.Channel,
        typeRawValue: String,
        lastMessageAt: Date?,
        createdAt: Date,
        deletedAt: Date?,
        updatedAt: Date,
        createdBy: UserPayload<ExtraData.User>?,
        config: ChannelConfig,
        isFrozen: Bool,
        memberCount: Int,
        team: String,
        members: [MemberPayload<ExtraData.User>]?
    ) {
        self.cid = cid
        self.extraData = extraData
        self.typeRawValue = typeRawValue
        self.lastMessageAt = lastMessageAt
        self.createdAt = createdAt
        self.deletedAt = deletedAt
        self.updatedAt = updatedAt
        self.createdBy = createdBy
        self.config = config
        self.isFrozen = isFrozen
        self.memberCount = memberCount
        self.team = team
        self.members = members
    }
}

/// A channel config.
public struct ChannelConfig: Codable {
    // swiftlint:disable:next nesting
    private enum CodingKeys: String, CodingKey {
        case reactionsEnabled = "reactions"
        case typingEventsEnabled = "typing_events"
        case readEventsEnabled = "read_events"
        case connectEventsEnabled = "connect_events"
        case uploadsEnabled = "uploads"
        case repliesEnabled = "replies"
        case searchEnabled = "search"
        case mutesEnabled = "mutes"
        case urlEnrichmentEnabled = "url_enrichment"
        case messageRetention = "message_retention"
        case maxMessageLength = "max_message_length"
        case commands
        case createdAt = "created_at"
        case updatedAt = "updated_at"
    }
    
    /// If users are allowed to add reactions to messages. Enabled by default.
    public let reactionsEnabled: Bool
    /// Controls if typing indicators are shown. Enabled by default.
    public let typingEventsEnabled: Bool
    /// Controls whether the chat shows how far you’ve read. Enabled by default.
    public let readEventsEnabled: Bool
    /// Determines if events are fired for connecting and disconnecting to a chat. Enabled by default.
    public let connectEventsEnabled: Bool
    /// Enables uploads.
    public let uploadsEnabled: Bool
    /// Enables message threads and replies. Enabled by default.
    public let repliesEnabled: Bool
    /// Controls if messages should be searchable (this is a premium feature). Disabled by default.
    public let searchEnabled: Bool
    /// Determines if users are able to mute other users. Enabled by default.
    public let mutesEnabled: Bool
    /// Determines if URL enrichment enabled to show they as attachments. Enabled by default.
    public let urlEnrichmentEnabled: Bool
    /// A number of days or infinite. Infinite by default.
    public let messageRetention: String
    /// The max message length. 5000 by default.
    public let maxMessageLength: Int
    /// An array of commands, e.g. /giphy.
    public let commands: [Command]?
    /// A channel created date.
    public let createdAt: Date
    /// A channel updated date.
    public let updatedAt: Date
    
    /// Determines if users are able to flag messages. Enabled by default.
    public var flagsEnabled: Bool { commands?.map { $0.name }.contains("flag") ?? false }
    
    // TODO: Do we need custom decoding here?
    
//    public init(from decoder: Decoder) throws {
//      let container = try decoder.container(keyedBy: CodingKeys.self)
//      reactionsEnabled = try container.decode(Bool.self, forKey: .reactionsEnabled)
//      typingEventsEnabled = try container.decode(Bool.self, forKey: .typingEventsEnabled)
//      readEventsEnabled = try container.decode(Bool.self, forKey: .readEventsEnabled)
//      connectEventsEnabled = try container.decode(Bool.self, forKey: .connectEventsEnabled)
//      uploadsEnabled = try container.decodeIfPresent(Bool.self, forKey: .uploadsEnabled) ?? false
//      self.repliesEnabled = try container.decode(Bool.self, forKey: .repliesEnabled)
//      self.searchEnabled = try container.decode(Bool.self, forKey: .searchEnabled)
//      self.mutesEnabled = try container.decode(Bool.self, forKey: .mutesEnabled)
//      self.urlEnrichmentEnabled = try container.decode(Bool.self, forKey: .urlEnrichmentEnabled)
//      self.messageRetention = try container.decode(String.self, forKey: .messageRetention)
//      self.maxMessageLength = try container.decode(Int.self, forKey: .maxMessageLength)
//      self.commands = try container.decodeIfPresent([Command].self, forKey: .commands) ?? []
//      self.created = try container.decode(Date.self, forKey: .created)
//      self.updated = try container.decode(Date.self, forKey: .updated)
//    }
    
    internal init(
        reactionsEnabled: Bool = false,
        typingEventsEnabled: Bool = false,
        readEventsEnabled: Bool = false,
        connectEventsEnabled: Bool = false,
        uploadsEnabled: Bool = false,
        repliesEnabled: Bool = false,
        searchEnabled: Bool = false,
        mutesEnabled: Bool = false,
        urlEnrichmentEnabled: Bool = false,
        messageRetention: String = "",
        maxMessageLength: Int = 0,
        commands: [Command] = [],
        createdAt: Date = .init(),
        updatedAt: Date = .init()
    ) {
        self.reactionsEnabled = reactionsEnabled
        self.typingEventsEnabled = typingEventsEnabled
        self.readEventsEnabled = readEventsEnabled
        self.connectEventsEnabled = connectEventsEnabled
        self.uploadsEnabled = uploadsEnabled
        self.repliesEnabled = repliesEnabled
        self.searchEnabled = searchEnabled
        self.mutesEnabled = mutesEnabled
        self.urlEnrichmentEnabled = urlEnrichmentEnabled
        self.messageRetention = messageRetention
        self.maxMessageLength = maxMessageLength
        self.commands = commands
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }
}
