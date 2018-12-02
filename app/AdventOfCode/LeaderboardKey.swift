import Foundation

class LeaderboardKey {
    private let keyKey = "com.mmvdv.adventofcode.leaderboardkey"
    var userDefaults = UserDefaults.standard

    var hasKey: Bool {
        return key != nil 
    }

    var key: String? {
        get {
            return userDefaults.string(forKey: keyKey)
        }

        set {
            userDefaults.set(newValue, forKey: keyKey)
        }
    }
}
