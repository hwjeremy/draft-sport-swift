//
//  Player.swift
//  
//
//  Created by Hugh Jeremy on 10/3/20.
//

import Foundation


public final class Player: Decodable, ApiDecodable, Identifiable {
    
    public typealias ID = String
    
    private static let path = "/fantasy/player"
    private static let listPath = "/fantasy/player/list"
    
    public let profile: Profile
    public let limit: UInt16
    public let offset: UInt16
    public let queryCount: UInt32
    public let sequence: UInt32
    public let requestingAgentId: String?
    public let points: Points
    public let queryTime: UInt16
    
    public var id: String { return self.profile.publicId }

    public init(
        profile: Profile,
        limit: UInt16,
        offset: UInt16,
        queryCount: UInt32,
        sequence: UInt32,
        requestingAgentId: String?,
        points: Points,
        queryTime: UInt16
    ) {
        
        self.profile = profile
        self.limit = limit
        self.offset = offset
        self.queryCount = queryCount
        self.sequence = sequence
        self.requestingAgentId = requestingAgentId
        self.points = points
        self.queryTime = queryTime

        return
    }
    
    required public init(from decoder: Decoder) throws {
        let data = try decoder.container(keyedBy: Keys.self)
        self.profile = try data.decode(Profile.self, forKey: .profile)
        self.limit = try data.decode(UInt16.self, forKey: .limit)
        self.offset = try data.decode(UInt16.self, forKey: .offset)
        self.queryCount = try data.decode(UInt32.self, forKey: .queryCount)
        self.sequence = try data.decode(UInt32.self, forKey: .sequence)
        self.requestingAgentId = try data.decodeIfPresent(
            String.self,
            forKey: .requestingAgentId
        )
        self.points = try data.decode(Points.self, forKey: .points)
        guard let intermediateQueryTime = UInt16(
            try data.decode(String.self, forKey: .queryTime)
        ) else {
            throw DraftSportError(.jsonParseFailed)
        }
        self.queryTime = intermediateQueryTime
        return
    }
    
    public static func retrieve(
        publicId: String,
        session: Session,
        callback: @escaping (Error?, Player?) -> Void
    ) {
        
        ApiRequest.make(
            path: Self.path,
            method: .GET,
            session: session,
            parameters: UrlParameters(
                singleKey: "public_id",
                singleValue: publicId
            ),
            body: nil
        ) { (error, data) in
            Self.decode(error: error, data: data, callback: callback)
            return
        }

        return
        
    }
    
    public static func retrieveMany(
        season: Season,
        session: Session? = nil,
        offset: Int = 0,
        limit: Int = 20,
        orderBy: OrderBy = .totalSeasonPoints,
        order: Order = .descending,
        nameFragment: String? = nil,
        callback: @escaping (Error?, Array<Player>?) -> Void
    ) {
        
        let parameters = UrlParameters([
            UrlParameter(season.publicId, withKey: "season"),
            UrlParameter(offset, withKey: "offset"),
            UrlParameter(limit, withKey: "limit"),
            UrlParameter(orderBy.rawValue, withKey: "order_by"),
            UrlParameter(order.rawValue, withKey: "order")
        ])
        
        ApiRequest.make(
            path: Self.listPath,
            method: .GET,
            session: session,
            parameters: parameters,
            body: nil
        ) { (error, data) in
            Self.decodeMany(error: error, data: data, callback: callback)
        }
        
        return
        
    }
    
    private enum Keys: String, CodingKey {
        case profile = "player"
        case limit = "limit"
        case offset = "offset"
        case queryCount = "query_count"
        case sequence = "sequence"
        case requestingAgentId = "requesting_agent_id"
        case points = "points"
        case queryTime = "query_time"
    }
    
    public enum OrderBy: String {
        case playerName = "player_name"
        case averagePoints = "average_points"
        case pointsLastRound = "points_last_round"
        case totalSeasonPoints = "total_season_points"
    }

}
