import Foundation

struct Timestamp: Decodable {
    let getStarTs: LeaderboardTimestamp
}

struct Member: Decodable {
    let completionDayLevel: [String: [String: Timestamp]]
    let id: String
    let lastStarTs: LeaderboardTimestamp
    let localScore: Int
    let globalScore: Int
    let stars: Int
    let name: String?
}

extension Member: CustomStringConvertible {
    var description: String {
        return "\(name ?? id): \(stars) - \(localScore)"
    }
}

struct Leaderboard: Decodable {
    let event: String
    let ownerId: String
    let members: [String: Member]

    var sortedMembers: [Member] {
        return members.values.sorted { lhs, rhs in
            lhs.localScore > rhs.localScore
        }
    }
}

enum LeaderboardTimestamp: Decodable {
    case string(String)
    case int(Int)

    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        do {
            let int = try container.decode(Int.self)
            self = .int(int)
        } catch {
            let string = try container.decode(String.self)
            self = .string(string)
        }
    }
}
