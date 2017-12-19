
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

enum Direction {
    case n, e, s, w
}

let ignored: [Character] = Array("|-")

var maze: [[Character]] = []
var position: (x: Int, y: Int) = (0, 0)
var direction: Direction = .s
var lettersFound: [Character] = []
var reachedEnd = false
var noSteps = 0
func walkMaze() {
    while !reachedEnd {
        // print("\(position), \(direction): \(maze[position.x][position.y])")
        stepMaze()
        noSteps += 1
    }
}

func stepMaze() {
    if position.x < 0 || position.x >= maze.count || position.y < 0 || position.y >= maze[position.x].count {
        reachedEnd = true
        noSteps -= 1
        return
    }
    let l = maze[position.x][position.y]
    switch (l, direction) {
    case (" ", _):
        reachedEnd = true
        noSteps -= 1
    case ("-", .s), ("|", .s):
        position = (x: position.x + 1, y: position.y)
    case ("-", .n), ("|", .n):
        position = (x: position.x - 1, y: position.y)
    case ("-", .e), ("|", .e):
        position = (x: position.x, y: position.y + 1)
    case ("-", .w), ("|", .w):
        position = (x: position.x, y: position.y - 1)
    case ("+", .n), ("+", .s):
        let oldPos = position
        if position.y + 1 < maze[position.x].count {
            if maze[position.x][position.y + 1] != " " {
                // print("turn East")
                position = (x: position.x, y: position.y + 1)
                direction = .e
            }
        }
        if oldPos.y - 1 >= 0 {
            if maze[oldPos.x][oldPos.y - 1] != " " {
                // print("turn West")
                position = (x: oldPos.x, y: oldPos.y - 1)
                direction = .w
            }
        }
    case ("+", .e), ("+", .w):
        let oldPos = position
        if position.x + 1 < maze.count {
            if maze[position.x + 1][position.y] != " " {
                // print("turn South")
                position = (x: position.x + 1, y: position.y)
                direction = .s
            }
        }
        if oldPos.x - 1 >= 0 {
            if maze[oldPos.x - 1][oldPos.y] != " " {
                // print("turn North")
                position = (x: oldPos.x - 1, y: oldPos.y)
                direction = .n
            }
        }
    case (_, .n):
        lettersFound.append(l)
        position = (x: position.x - 1, y: position.y)
    case (_, .s):
        lettersFound.append(l)
        position = (x: position.x + 1, y: position.y)
    case (_, .e):
        lettersFound.append(l)
        position = (x: position.x, y: position.y + 1)
    case (_, .w):
        lettersFound.append(l)
        position = (x: position.x, y: position.y - 1)
    }
}

func solve1(fileName: String = "input.txt") {
    let input = readTerminal(fileName)
    maze = input.split(separator: "\n").map { Array($0) }
    position = (x: 0, y: maze.first!.index(of: "|")!)
    walkMaze()
    print(String(lettersFound))
    print(noSteps)
}

if CommandLine.arguments.count > 1 {
    let fileName = CommandLine.arguments[1]
    solve1(fileName: fileName)
} else {
    solve1()
}
