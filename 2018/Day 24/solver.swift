import Foundation

// Running:
// $ swift solver.swift [inputfilename]
// If no argument provided, it takes "input.txt"

extension String {
    /// An `NSRange` that represents the full range of the string.
    var nsrange: NSRange {
        return NSRange(location: 0, length: utf16.count)
    }

    /// Returns a substring with the given `NSRange`,
    /// or `nil` if the range can't be converted.
    func substring(with nsrange: NSRange) -> String? {
        guard let range = Range(nsrange) else { return nil }
        
        let startIndex = self.index(self.startIndex, offsetBy: range.startIndex)
        let stopIndex = self.index(self.startIndex, offsetBy: range.startIndex + range.count)
        return String(self[startIndex..<stopIndex])
    }

    /// Returns a range equivalent to the given `NSRange`,
    /// or `nil` if the range can't be converted.
    func range(from nsrange: NSRange) -> Range<Index>? {
        guard let range = Range(nsrange) else { return nil }
        
        let startIndex = self.index(self.startIndex, offsetBy: range.startIndex)
        let stopIndex = self.index(self.startIndex, offsetBy: range.startIndex + range.count)

        return startIndex..<stopIndex
    }
}

let unitsRx = try! NSRegularExpression(pattern: "([0-9]+) units each with ([0-9]+) hit points", options: [])
let immuneRx = try! NSRegularExpression(pattern: "immune to ([a-z, ]+)[\\);]", options: [])
let weaknessRx = try! NSRegularExpression(pattern: "weak to ([a-z, ]+)[\\);]", options: [])
let attackRx = try! NSRegularExpression(pattern: "with an attack that does ([0-9]+) ([a-z]+) damage at initiative ([0-9]+)", options: [])

class Solver {

    enum Team: Hashable {
        case immune, infect
    }

    class Group: CustomStringConvertible, Hashable {
        let team: Team
        let id: Int
        var units: Int
        let hp: Int
        let weakness: [String]
        let immune: [String]
        let attack: String
        let damage: Int
        let initiative: Int

        var power: Int {
            return damage * units
        }

        init(string: String, team: Team, id: Int) {
            self.id = id
            // print(string)
            guard let unitsMatch = unitsRx.matches(in: string, options: [] as NSRegularExpression.MatchingOptions, range: string.nsrange).first else {
                fatalError("No unit match found")
            }
            self.team = team
            units = Int(string.substring(with: unitsMatch.range(at: 1))!)!
            hp = Int(string.substring(with: unitsMatch.range(at: 2))!)!
            // print(string.substring(with: unitsMatch.range(at: 2)))
            
            if let immuneMatch = immuneRx.matches(in: string, options: [] as NSRegularExpression.MatchingOptions, range: string.nsrange).first {
                // print(string.substring(with: immuneMatch.range(at: 1)))
                let immuneString = string.substring(with: immuneMatch.range(at: 1))!
                immune = immuneString.components(separatedBy: ", ")
            } else {
                immune = []
            }

            if let weaknessMatch = weaknessRx.matches(in: string, options: [] as NSRegularExpression.MatchingOptions, range: string.nsrange).first {
                // print(string.substring(with: weaknessMatch.range(at: 0)))
                // print(string.substring(with: weaknessMatch.range(at: 1)))
                let weaknessString = string.substring(with: weaknessMatch.range(at: 1))!
                weakness = weaknessString.components(separatedBy: ", ")
                // print(weakness)
            } else {
                weakness = []
            }

            guard let attackMatch = attackRx.matches(in: string, options: [] as NSRegularExpression.MatchingOptions, range: string.nsrange).first else {
                fatalError("No attack match found")
            }

            // print(string.substring(with: attackMatch.range(at: 0)))
            // print(string.substring(with: attackMatch.range(at: 1)))
            // print(string.substring(with: attackMatch.range(at: 2)))
            // print(string.substring(with: attackMatch.range(at: 3)))
            damage = Int(string.substring(with: attackMatch.range(at: 1))!)!
            // print(damage)
            attack = String(string.substring(with: attackMatch.range(at: 2))!)
            // print(attack)
            initiative = Int(string.substring(with: attackMatch.range(at: 3))!)!
        }

        func damageTo(_ other: Group) -> Int {
            if other.immune.contains(attack) { return 0 }

            if other.weakness.contains(attack) { return power * 2 }

            return power
        }

        func attack(_ other: Group) {
            let damage = damageTo(other)
            print("\(self) -> \(other) -\(damage / other.hp)")
            other.units -= damage / other.hp
        }

        var description: String {
            return "\(team) \(id): \(units) units"
        }

        var longDescription: String {
            return "\(team) \(id): \(units) units each with \(hp) hp (weak: \(weakness), immune: \(immune)), \(attack) attack \(damage) damage, initiative \(initiative)"
        }

        static func ==(lhs: Group, rhs: Group) -> Bool {
            return lhs.team == rhs.team &&
                lhs.id == rhs.id
        }

        func hash(into hasher: inout Hasher) {
            hasher.combine(team)
            hasher.combine(id)
        }
    }

    func solve(_ fileName: String = "input.txt") -> String {
        let input = readFile(fileName)
        let result1 = solve1(input: input)
        let result2 = solve2(input: input)
        return "r1: \(result1)\nr2: \(result2)"
    }

    var immune: [Group] = []
    var infect: [Group] = []

    private func solve1(input: String) -> String {
        let lines = input.split(separator: "\n")

        var i = 0
        if lines.count == 6 {
            immune = lines[1..<3].map {
                i+=1
                return Group(string: String($0), team: .immune, id: i)
            }
            i = 0
            infect = lines[4...].map {
                i+=1
                return Group(string: String($0), team: .infect, id: i)
            }
        } else {
            immune = lines[1..<11].map {
                i+=1
                return Group(string: String($0), team: .immune, id: i)
            }
            i = 1
            infect = lines[12...].map {
                i+=1
                return Group(string: String($0), team: .infect, id: i)
            }
        }

        immune.forEach { print($0.longDescription) }
        infect.forEach { print($0.longDescription) }
        // fatalError()

        while immune.count > 0 && infect.count > 0 {
            round()
            immune = immune.filter { $0.units > 0 }
            infect = infect.filter { $0.units > 0 }
            print()
        }

        immune.forEach { print($0) }
        infect.forEach { print($0) }
        let sumImm = immune.reduce(0) { $0 + $1.units }
        let sumInf = infect.reduce(0) { $0 + $1.units }
        return "\(sumImm + sumInf)"
    }

    private func solve2(input: String) -> String {
        // let lines = input.split(separator: "\n")

        return ""
    }

    func round() {
        // immune.forEach { print($0) }
        // infect.forEach { print($0) }

        //target selection
        let sorted = (immune + infect).sorted {
            if $0.power == $1.power {
                print("equal power: which will be first?")
                print("lhs: \($0.longDescription)")
                print("rhs: \($1.longDescription)")
                print($0.initiative > $1.initiative)
            }
            return $0.power > $1.power || ($0.power == $1.power && $0.initiative > $1.initiative)
        }
        var attacked: [Group: Group] = [:]
        for group in sorted {
            var targets: [Group]
            switch group.team {
            case .infect:
                targets = immune
            case .immune:
                targets = infect
            }

            targets = targets.filter { !attacked.values.contains($0) }
            if targets.isEmpty {
                // print("no targets")
                continue
            }
            if let target = targets.max(by: {
                let lhsDamage = group.damageTo($0)
                let rhsDamage = group.damageTo($1)
                if lhsDamage == rhsDamage && lhsDamage > 0 {
                    print("equal damage (\(lhsDamage)): which will be max?")
                    print("attacker", group.longDescription)
                    print("lhs: \($0.longDescription)")
                    print("rhs: \($1.longDescription)")
                    print($0.power < $1.power || ($0.power == $1.power && $0.initiative < $1.initiative))
                }
                return lhsDamage < rhsDamage || (lhsDamage == rhsDamage && $0.power < $1.power) || (lhsDamage == rhsDamage && $0.power == $1.power && $0.initiative < $1.initiative)
            }), group.damageTo(target) > 0 {
                attacked[group] = target
                // print(group, ":", target, ":", group.damageTo(target))
            }
            
            // print(targets)
        }
        // print(attacked)

        // Attack
        let sortedAttacks = attacked.sorted { $0.key.initiative > $1.key.initiative }
        // print(sortedAttacks)

        var killedGroups: [Group] = []
        for attack in sortedAttacks {
            if killedGroups.contains(attack.key) { continue }
            attack.key.attack(attack.value)
            if attack.value.units <= 0 {
                print("Removing killed group")
                killedGroups.append(attack.value)
            }
        }
    }

    private func readFile(_ fileName: String) -> String {
        let currentDirectoryURL = URL(fileURLWithPath: FileManager.default.currentDirectoryPath)
        guard let fileURL = URL(string: fileName, relativeTo: currentDirectoryURL) else {
            print("file not found: \(currentDirectoryURL.path)/\(fileName)")
            return ""
        }
        let content = try! String(contentsOf: fileURL)
        return content
    }
}

let solver = Solver()
let result: String

if CommandLine.arguments.count > 1 {
    result = solver.solve(CommandLine.arguments[1])
} else {
    result = solver.solve()
}

print(result)