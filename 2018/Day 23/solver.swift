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

let regex = try! NSRegularExpression(pattern: "pos=<(-?[0-9]+),(-?[0-9]+),(-?[0-9]+)>, r=([0-9]+)", options: [])

class Solver {

    struct Bot: CustomStringConvertible, Hashable {
        let x,y,z, r: Int

        init(string: String) {
            guard let match = regex.matches(in: string, options: [] as NSRegularExpression.MatchingOptions, range: string.nsrange).first else {
                fatalError("No match found")
            }
            x = Int(string.substring(with: match.range(at: 1))!)!
            y = Int(string.substring(with: match.range(at: 2))!)!
            z = Int(string.substring(with: match.range(at: 3))!)!
            r = Int(string.substring(with: match.range(at: 4))!)!
        }

        init(x: Int, y: Int, z: Int, r: Int) {
            self.x = x
            self.y = y
            self.z = z
            self.r = r 
        }

        func dist(to bot: Bot) -> Int {
            let xd = abs(x - bot.x)
            let yd = abs(y - bot.y)
            let zd = abs(z - bot.z)
            return xd + yd + zd
        }

        func neighbors(r: Int) -> [(x: Int, y: Int, z: Int)] {
            return (-1...1).flatMap { (xd: Int) -> [(x: Int, y: Int, z: Int)] in 
                return (-1...1).flatMap { (yd: Int) -> [(x: Int, y: Int, z: Int)] in 
                    return (-1...1).map { (zd: Int) -> (x: Int, y: Int, z: Int) in 
                        return (x: x + xd*r, y: y + yd*r, z: z + zd*r)
                    }
                }
            }
        }

        func intersects(with bot: Bot) -> Bool {
            return dist(to:bot) <= r + bot.r
        }

        var description: String {
            return "pos=<\(x),\(y),\(z)>, r=\(r)"
        }
    }
    func solve(_ fileName: String = "input.txt") -> String {
        let input = readFile(fileName)
        let bots = input.split(separator: "\n").map { Bot(string: String($0)) }
        let result1 = solve1(bots: bots)
        let result2 = solve2(bots: bots)
        return "r1: \(result1)\nr2: \(result2)"
    }

    private func solve1(bots: [Bot]) -> String {
        let largest = bots.max { $0.r < $1.r }!
        let inRange: [Bot] = bots.filter { largest.dist(to: $0) <= largest.r }
        return "\(inRange.count)"
    }

    private func solve2(bots: [Bot]) -> String {
        let xmin = bots.min { $0.x < $1.x }!.x
        let xmax = bots.max { $0.x < $1.x }!.x
        let ymin = bots.min { $0.y < $1.y }!.y
        let ymax = bots.max { $0.y < $1.y }!.y
        let zmin = bots.min { $0.z < $1.z }!.z
        let zmax = bots.max { $0.z < $1.z }!.z

        var curRadius = [xmax-xmin, ymax-ymin, zmax-zmin].max()!
        let startBot = Bot(x: 0, y: 0, z: 0, r: curRadius)
        var currentBots: Set<Bot> = [startBot]
        print(curRadius)
        print(currentBots)
        while curRadius > 0 {
            curRadius = (curRadius / 2) + (curRadius > 2 ? 1 : 0)
            print(curRadius)
            let newGen: [(bot: Bot, count: Int)] = currentBots.flatMap {  bot in
                return bot.neighbors(r: curRadius).map { c in 
                    let b = Bot(x: c.x, y: c.y, z: c.z, r: curRadius)
                    // print(b)
                    let cnt = bots.filter {
                        b.intersects(with: $0)
                    }.count
                    // print(cnt)
                    return (bot: b, count: cnt)
                }
            }
            //print(newGen)
            let maxDist = newGen.max { $0.count < $1.count }?.count ?? 0
            print(maxDist)
            currentBots = Set(newGen.filter { $0.count  == maxDist }.map { $0.bot })
            print(currentBots)
        }
        print(currentBots)
        let minDist = currentBots.min { startBot.dist(to: $0) < startBot.dist(to: $1) }!.dist(to: startBot)

        return "\(minDist)"
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