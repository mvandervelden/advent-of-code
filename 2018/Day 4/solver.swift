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

class Solver {
    enum Action: CustomStringConvertible {
        case beginShift(guard: Int)
        case fallAsleep
        case wakeUp

        var description: String {
            switch self {
                case .fallAsleep: return "Fall Asleep"
                case .wakeUp: return "Wake Up"
                case .beginShift(let guardID): return "#\(guardID) begins shift"
            }
        }
    }

    struct Timestamp: CustomStringConvertible {
        let date: Date
        let action: Action

        init(line: String) {
            guard let match = Solver.regex.matches(in: line, options: [] as NSRegularExpression.MatchingOptions, range:line.nsrange).first else {
                fatalError("No match found")
            }

            date = Solver.dateFormatter.date(from: line.substring(with: match.range(at: 1))!)!
            let entry = String(line.substring(with: match.range(at: 2))!)
            
            if entry.contains("wakes up") {
                action = .wakeUp
            } else if entry.contains("falls asleep") {
                action = .fallAsleep
            } else {
                guard let actionMatch = Solver.actionRegex.matches(in: entry, options: [] as NSRegularExpression.MatchingOptions, range: entry.nsrange).first else {
                    fatalError("No match found")
                }

                let guardID = Int(entry.substring(with: actionMatch.range(at: 1))!)!

                action = .beginShift(guard: guardID)
            }
        }

        var description: String {
            return "\(Solver.dateFormatter.string(from: date)): \(action)"
        }
    }

    struct Night: CustomStringConvertible {
        let guardID: Int
        
        var timestamps: [Timestamp] = []
        var sleepDuration = 0
        var sleepRanges: [Range<Int>] = []

        var description: String {
            return "G:\(guardID), sleep:\(sleepDuration)"
        }

        init(guardID: Int) {
            self.guardID = guardID
        }
    }

    struct Guard {
        let id: Int
        var sleepDuration = 0
        var sleepRanges: [Range<Int>] = []

        init(id: Int) {
            self.id = id
        }
    }

    let calendar = Calendar.current
    static let regex = try! NSRegularExpression(pattern: "\\[(.+)\\] (.*)", options: [])
    static let actionRegex = try! NSRegularExpression(pattern: "Guard #([0-9]+) begins shift", options: [])
    
    static let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.timeZone = TimeZone(secondsFromGMT: 0)
        formatter.dateFormat = "yyyy-MM-dd HH:mm"
        return formatter
    }()

    func solve(_ fileName: String = "input.txt") -> String {
        let input = readFile(fileName)
        let result1 = solve1(input: input)
        let result2 = solve2(input: input)
        return "r1: \(result1)\nr2: \(result2)"
    }

    private func solve1(input: String) -> String {
        let calendar = Calendar.current

        let lines = input.split(separator: "\n")
        let timestamps = lines.map { Timestamp(line: String($0)) }
            
        let sortedStamps = timestamps.sorted { lhs, rhs in
            lhs.date < rhs.date
        }
        
        // var nights: [[Timestamp]] = []
        // var sleeps: [Int] = []
        // var ranges: [[Range<Int>]] = []
        // var nextRange: [Range<Int>] = []
        // var guards: [Int] = [-1]
        // var nextNight: [Timestamp] = []
        // var sleep = 0
        var sleepTime: Date = Date()

        var nights: [Night] = []
        var nextNight: Night! = nil 
        sortedStamps.forEach { stamp in
            switch stamp.action {
            case .beginShift(let guardID):
                if let next = nextNight {
                    //TODO?
                    nights.append(next)
                }
                // nights.append(nextNight)
                // ranges.append(nextRange)
                // sleeps.append(sleep)

                nextNight = Night(guardID: guardID)
                nextNight.timestamps.append(stamp)
            case .fallAsleep:
                nextNight.timestamps.append(stamp)
                sleepTime = stamp.date
            case .wakeUp:
                nextNight.sleepRanges.append(calendar.component(.minute, from: sleepTime)..<calendar.component(.minute, from: stamp.date))
                nextNight.sleepDuration += Int(stamp.date.timeIntervalSinceReferenceDate - sleepTime.timeIntervalSinceReferenceDate) / 60
                nextNight.timestamps.append(stamp)
            }
        }

        nights.append(nextNight!)

        let guards: [Int: Guard] = nights.reduce(into: [:]) { gs, night in 
            gs[night.guardID, default: Guard(id: night.guardID)].sleepDuration += night.sleepDuration
            gs[night.guardID]!.sleepRanges.append(contentsOf: night.sleepRanges)
        }
        // let guardSleeps: [Int: Int] = zip(guards, sleeps).reduce(into: [:]) { counts, entry in
        //    counts[entry.0, default: 0] += entry.1
        // }

        // let guardSleepRanges: [Int: [Range<Int>]] = zip(guards, ranges).reduce(into: [:]) { dayRanges, entry in
        //     dayRanges[entry.0, default: []].append(contentsOf: entry.1)
        // }

        let max = guards.max { lhs, rhs in lhs.value.sleepDuration < rhs.value.sleepDuration }!.value
        // let max = guardSleeps.max { lhs, rhs in lhs.value < rhs.value }!
        
        let maxRanges = max.sleepRanges
        let hist = maxRanges.reduce(into: [:]) { histogram, range in
            range.forEach {
                histogram[$0, default: 0] += 1
            }
        }
        let maxMinutes = hist.max { lhs, rhs in lhs.value < rhs.value }!

        return "\(max.id * maxMinutes.0)"
    }

    private func solve2(input: String) -> String {
let calendar = Calendar.current

        let lines = input.split(separator: "\n")
        
        let timestamps = lines.map { line in
            return Timestamp(line: String(line))
        }

        let sortedStamps = timestamps.sorted { lhs, rhs in
            lhs.date < rhs.date
        }
        
        var nights: [[Timestamp]] = []
        var sleeps: [Int] = []
        var ranges: [[Range<Int>]] = []
        var nextRange: [Range<Int>] = []
        var guards: [Int] = [-1]
        var nextNight: [Timestamp] = []
        var sleep = 0
        var sleepTime: Date = Date()
        sortedStamps.forEach { stamp in
            switch stamp.action {
            case .beginShift(let guardID):
                nights.append(nextNight)
                ranges.append(nextRange)
                nextNight = [stamp]
                guards.append(guardID)
                sleeps.append(sleep)
                sleep = 0
                nextRange = []
                sleepTime = Date()
            case .fallAsleep:
                sleepTime = stamp.date
                nextNight.append(stamp)
            case .wakeUp:
                nextRange.append(calendar.component(.minute, from: sleepTime)..<calendar.component(.minute, from: stamp.date))
                sleep += Int(stamp.date.timeIntervalSinceReferenceDate - sleepTime.timeIntervalSinceReferenceDate) / 60
                nextNight.append(stamp)
            }
        }

        let guardSleepRanges: [Int: [Range<Int>]] = zip(guards, ranges).reduce(into: [:]) { dayRanges, entry in
            if !entry.1.isEmpty {
                dayRanges[entry.0, default: []].append(contentsOf: entry.1)
            }
        }

        let guardMaxMinutes: [(Int, (Int, Int))] = guardSleepRanges.map { guardSleep in
            let hist = guardSleep.value.reduce(into: [:]) { histogram, range in
                range.forEach {
                    histogram[$0, default: 0] += 1
                }
            }
            let maxMinute = hist.max { lhs, rhs in lhs.value < rhs.value }!
            return (guardSleep.key, maxMinute)
        }

        let maxGuard = guardMaxMinutes.max { lhs, rhs in
            lhs.1.1 < rhs.1.1
        }!

        return "\(maxGuard.0 * maxGuard.1.0)"    
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