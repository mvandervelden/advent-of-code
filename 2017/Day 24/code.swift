
// to run: `swift code.swift [input_filename]`
import Foundation

func readTerminal(_ fileName: String) -> String {
    let currentDirectoryURL = URL(fileURLWithPath: FileManager.default.currentDirectoryPath)
    guard let fileURL = URL(string: fileName, relativeTo: currentDirectoryURL) else {
        print("file not found: \(currentDirectoryURL.path)/\(fileName)")
        return ""
    }
    let content = try! String(contentsOf: fileURL)
    return content
}

struct Section {
    let ends: (Int, Int)
    let id: Int
    var strength: Int {
        return ends.0 + ends.1
    }

    init(string: String, id: Int) {
        let vals = string.split(separator: "/")
        ends = (Int(String(vals.first!))!, Int(String(vals.last!))!)
        self.id = id
    }
}

extension Section: CustomStringConvertible {
    var description: String {
        return "\(ends)"
    }
}

extension Section: Equatable {
    static func == (lhs: Section, rhs: Section) -> Bool {
        return lhs.id == rhs.id
    }
}

extension Section: Comparable {
    static func <(lhs: Section, rhs: Section) -> Bool {
        return lhs.strength < rhs.strength
    }
}

extension Section: Hashable {
    var hashValue: Int {
        return id
    }
}

func neighbors(_ current: Section, _ currentEnd: Int, _ sections: [Section]) -> [Section] {
    var result: [Section] = []
    for section in sections {
        if section != current && section.ends.0 == currentEnd || section.ends.1 == currentEnd {
            result.append(section)
        }
    }
    return result
}

var paths: [[Section]] = []

func myStart(sections: [Section], start: Section) { 
    myStar(sections: sections, current: start, currentEnd: 0, currentPath: [start]) 
    
    let maxPath = findMaxPath()
    let longestPath = findLongestPath()
    print("strongest: \(maxPath.1)")
    print("longest: \(longestPath.1)")
    print("longestStrength: \(longestPath.2)")

}

func findMaxPath() -> ([Section], Int) {
    var maxP: [Section] = []
    var max: Int = 0
    for p in paths {
        let sum = p.reduce(0) { $0 + $1.strength }
        if sum > max {
            max = sum
            maxP = p
        }
    }
    return (maxP, max)
}

func findLongestPath() -> ([Section], Int, Int) {
    var longestP: [Section] = []
    var longest: Int = 0
    var val: Int = 0
    for p in paths {
        let l = p.count
        let sum = p.reduce(0) { $0 + $1.strength }
        if l > longest {
            longestP = p
            longest = l
            val = sum
        } else if l == longest && sum > val {
            longestP = p
            longest = l
            val = sum
        }
    }
    return (longestP, longest, val)
}

func myStar(sections: [Section], current: Section, currentEnd: Int, currentPath: [Section]) { 

    let nbs = neighbors(current, currentEnd, sections).filter { !currentPath.contains($0) }
    if nbs.isEmpty {
        paths.append(currentPath)
        return
    }
    for neighbor in nbs {
        let end = neighbor.ends.0 == currentEnd ? neighbor.ends.1 : neighbor.ends.0
        let newPath: [Section] = currentPath + [neighbor]
        myStar(sections: sections, current: neighbor, currentEnd: end, currentPath: newPath)
    }
}

func solve1(fileName: String = "input.txt") {
    let input = readTerminal(fileName)
    
    let sections = input
        .split(separator: "\n")
        .enumerated()
        .map { Section(string: String($0.element), id: $0.offset) }
    
    let start = Section(string: "0/0", id: -1)
    
    print(sections)
    myStart(sections: sections, start: start)
}

if CommandLine.arguments.count > 1 {
    let fileName = CommandLine.arguments[1]
    solve1(fileName: fileName)
} else {
    solve1()
}
