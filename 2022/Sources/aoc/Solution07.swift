enum Output: CustomStringConvertible {
  case dir(name: String)
  case file(name: String, size: Int)

  var isFile: Bool {
    switch self {
    case .dir: return false
    case .file: return true
    }
  }

  var size: Int {
    switch self {
      case .dir: return 0
      case .file(_, let size): return size
    }
  }

  // var node: Node {
  //   switch self {
  //   case .file(let name, let size):
  //     return .file(name: name, size: size)
  //   case .folder(let name):
  //     return .folder([], name: name)
  //   }
  // }

  init(_ elems: [String]) {
    if elems[0] == "dir" {
      self = .dir(name: elems[1])
    } else {
      self = .file(name: elems[1], size: Int(elems[0])!)
    }
  }

  var description: String {
    switch self {
    case .dir(let name): return "dir \(name)"
    case .file(let name, let size): return "\(size) \(name)"
    }
  }
}

enum Command: CustomStringConvertible {
  case cd(folder: String)
  case ls(path: [String], output: [Output])

  var description: String {
    switch self {
    case .cd(let folder): return "$ cd \(folder)"
    case .ls(_, let output): return "$ ls\n\(output.map(\.description).joined(separator: "\n"))"
    }
  }

  var fileSize: Int {
    if case .ls(_, let output) = self {
      return output.map(\.size).sum()
    }
    fatalError()
  }

  var hasFolders: Bool {
    if case .ls(_, let output) = self {
      return !output.allSatisfy(\.isFile)
    }
    fatalError()
  }
}

// enum Node: CustomStringConvertible {
//   case folder([Node], name: String)
//   case file(name: String, size: Int)

//   var size: Int {
//     case file(_, let size): return size
//     case folder(let nodes): return nodes.map(\.size).sum()
//   }

//   var description: String {
//     switch self {
//     case .file(let name, let size):
//       return "- \(name) (file, size=\(size))"
//     case .folder(let nodes, let name):
//       return "- \(name) (dir)\n" + nodes.map(\.description).map { "  " + $0 }.joined(separator: "\n")
//     }
//   }
// }

class Solution07: Solving {
  let file: File

  required init(file: File) {
    self.file = file
  }

  func solve1() -> String {
    let output = file.words
    let commands = parseOutput(output)
    let sizes = getSizes(commands)

    let max = 100000

    let sum = sizes.values.filter { $0 <= max }.sum()

    return sum.description
  }

  func solve2() -> String {
    let output = file.words
    let commands = parseOutput(output)
    let sizes = getSizes(commands)

    let totalSpace = 70000000
    let minFree = 30000000
    let freeSpace = totalSpace - sizes["/"]!
    let target = minFree - freeSpace

    let result = sizes.values.filter { $0 >= target }.min()

    return result!.description
  }

  private func parseOutput(_ output: [[String]]) -> [Command] {
    var commands: [Command] = []
    var thisLS: [Output]? = nil

    var currentFolder: [String] = []

    for line in output {
      if line[0] == "$" {
        if let ls = thisLS {
          commands.append(.ls(path: currentFolder, output: ls))
          thisLS = nil
        }

        if line[1] == "cd" {
          commands.append(.cd(folder: line[2]))
          if line[2] == ".." {
            _ = currentFolder.popLast()
          } else {
            currentFolder.append(line[2])
          }
        } else { // ls
          thisLS = []
        }
      } else {
        thisLS?.append(Output(line))
      }
    }

    if let ls = thisLS {
      commands.append(.ls(path: currentFolder, output: ls))
    }

    return commands
  }

  private func getSizes(_ commands: [Command]) -> [String: Int] {
    var sizes: [String: Int] = [:]

    for command in commands {
      if case .ls(let path, _) = command {
        for i in 0..<path.count {
          let subPath = path[0...i]
          sizes[subPath.joined(separator:"/"), default: 0] += command.fileSize
        }
      }
    }

    return sizes
  }
}

