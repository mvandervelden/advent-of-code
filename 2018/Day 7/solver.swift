import Foundation

// Running:
// $ swift solver.swift [inputfilename]
// If no argument provided, it takes "input.txt"

extension Character {
    var value: UInt32 {
        return unicodeScalars.first!.value
    }
}

extension StringProtocol {
   subscript(offset: Int) -> Element {
        return self[index(startIndex, offsetBy: offset)]
    }
}

class Solver {

    func solve(_ fileName: String = "input.txt") -> String {
        let input = readFile(fileName)
        let result1 = solve1(input: input)
        let result2 = solve2(input: input)
        return "r1: \(result1)\nr2: \(result2)"
    }

    private func solve1(input: String) -> String {
        var graph: [Character: [Character]] = [:]
        input.split(separator: "\n").forEach { line in
            let subject = line[36]
            let required = line[5]
            if graph[required] == nil {
                graph[required] = []
            }
            graph[subject, default: []].append(required)
        }

        var gList = graph.sorted { lhs, rhs in lhs.key < rhs.key }

        var sequence = "" 
        while !gList.isEmpty {
            let next = gList.first { $0.value.isEmpty }!
            sequence.append(next.key)
            gList.removeAll { $0.key == next.key }
            gList = gList.map { item in
                let newValues = item.value.filter { $0 != next.key }
                return (key: item.key, value: newValues)
            }
        }
        
        
        return "\(sequence)"
    }

    private func solve2(input: String) -> String {
        let aVal = Int(Character("A").value - 1)
        let workers = input == "input.txt" ? 5 : 2
        let minDuration = input == "input.txt" ? 60 : 0
        var graph: [Character: [Character]] = [:]
        input.split(separator: "\n").forEach { line in
            let subject = line[36]
            let required = line[5]
            if graph[required] == nil {
                graph[required] = []
            }
            graph[subject, default: []].append(required)
        }

        var gList = graph.sorted { lhs, rhs in lhs.key < rhs.key }

        var sequence = "" 
        var threads: [(Int, [Character?])] =  [(0, []), (1, []), (2, []), (3, []), (4, [])]
        // var threads: [(Int, [Character?])] =  [(0, []), (1, [])]
        var currentTime = 0
        // Check available threads
        // Check available next work
        // Zip together, add work to the threads
        // set nextEventTime to min(duration of first work, currentNextEventTime), set finishingThread(s)
        // advance time
        // For finished threads: remove work from gList
        var nextEvent: (time: Int, threads: [Int]) = (time: Int.max, threads: [])

        while !gList.isEmpty {
            print("###################################")
            print("currentTime", currentTime)
            print("nextEvent", nextEvent)
            threads.forEach {
                let array: [String] = $0.1.map { char in
                    guard let char = char else { return "." }
                    return String(char)
                }
                print("T\($0.0): \(array.joined(separator: ""))")
            }

            nextEvent.threads.forEach { thread in
                let lastWork = threads[thread].1.last!
                sequence.append(lastWork ?? " ")
                // gList.removeAll { $0.key == lastWork }
                gList = gList.map { item in
                    let newValues = item.value.filter { $0 != lastWork }
                    return (key: item.key, value: newValues)
                }
            }

            let availableThreads = threads.filter { $0.1.count <= currentTime }
            let nextItems = gList.filter { $0.value.isEmpty }

            guard !availableThreads.isEmpty, !nextItems.isEmpty else {
                let nextTime = threads.filter { $0.1.count > currentTime }.min { lhs, rhs in lhs.1.count < rhs.1.count }!.1.count
                let nextThreads = threads.filter { $0.1.count == nextTime }.map { $0.0 }
                nextEvent = (time: nextTime, threads: nextThreads)
                currentTime = nextTime
                print("nextThreads", nextThreads)
                print("nextTime", nextTime)
                continue 
            }
            
            zip(availableThreads, nextItems).forEach { zippy in
                let duration = Int(zippy.1.key.value) - aVal + 60

                let work: [Character?] = Array(repeating: zippy.1.key, count: duration)

                var previousWork: [Character?] = zippy.0.1
                if previousWork.count < currentTime {
                    previousWork.append(contentsOf: Array(repeating: nil, count: currentTime - previousWork.count))
                }  
                let newWorkList: [Character?] = previousWork + work
                threads[zippy.0.0] = (zippy.0.0, newWorkList)
                gList.removeAll { return $0.key == zippy.1.key }
            }

            let nextTime = threads.filter { $0.1.count > currentTime }.min { lhs, rhs in lhs.1.count < rhs.1.count }!.1.count
            let nextThreads = threads.filter { $0.1.count == nextTime }.map { $0.0 }
            nextEvent = (time: nextTime, threads: nextThreads)
            currentTime = nextTime
            print("nextThreads", nextThreads)
            print("nextTime", nextTime)
        }
        
        print("###################################")
        print("            FINAL                  ")
        print("###################################")
        print("sequence", sequence)
        print("currentTime", currentTime)
        print("nextEvent", nextEvent)
        threads.forEach {
            let array: [String] = $0.1.map { char in
                guard let char = char else { return "." }
                return String(char)
            }
            print("T\($0.0): \(array.joined(separator: ""))")
        }
        print("")

        return "\(currentTime)"
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