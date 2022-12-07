struct LSFile: CustomStringConvertible {
  let name: String
  let size: Int

  init(_ elems: [String]) {
    name = elems[1]
    size = Int(elems[0])!
  }

  var description: String {
    "\(size) \(name)"
  }
}

struct Folder: CustomStringConvertible {
  let path: [String]
  let files: [LSFile]

  var description: String {
    "\(path.joined(separator: "/"))\n\(files.map(\.description).joined(separator: "\n"))"
  }

  var fileSize: Int {
    files.map(\.size).sum()
  }
}

class Solution07: Solving {
  let file: File

  required init(file: File) {
    self.file = file
  }

  func solve1() -> String {
    let output = file.words
    let folders = parseOutput(output)
    let sizes = getSizes(folders)

    let max = 100000

    let sum = sizes.values.filter { $0 <= max }.sum()

    return sum.description
  }

  func solve2() -> String {
    let output = file.words
    let folders = parseOutput(output)
    let sizes = getSizes(folders)

    let totalSpace = 70000000
    let minFree = 30000000
    let freeSpace = totalSpace - sizes["/"]!
    let target = minFree - freeSpace

    let result = sizes.values.filter { $0 >= target }.min()

    return result!.description
  }

  private func parseOutput(_ output: [[String]]) -> [Folder] {
    var folders: [Folder] = []
    var thisLS: [LSFile]? = nil

    var currentFolder: [String] = []

    for line in output {
      if line[0] == "$" {
        if let ls = thisLS {
          folders.append(Folder(path: currentFolder, files: ls))
          thisLS = nil
        }

        if line[1] == "cd" {
          if line[2] == ".." {
            _ = currentFolder.popLast()
          } else {
            currentFolder.append(line[2])
          }
        } else { // ls
          thisLS = []
        }
      } else if line[0] != "dir" {
        thisLS?.append(LSFile(line))
      }
    }

    if let ls = thisLS {
      folders.append(Folder(path: currentFolder, files: ls))
    }

    return folders
  }

  private func getSizes(_ folders: [Folder]) -> [String: Int] {
    var sizes: [String: Int] = [:]

    for folder in folders {
      for i in 0..<folder.path.count {
        let subPath = folder.path[0...i]
        sizes[subPath.joined(separator:"/"), default: 0] += folder.fileSize
      }
    }

    return sizes
  }
}

