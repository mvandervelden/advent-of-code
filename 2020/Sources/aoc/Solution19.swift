class Solution19: Solving {
  var rules: [String: [[String]]] = [:]
  let file: File
  let input: [String]
  var cache: [String: [String]] = [:]

  var rulesDescription: String { rules.map { "\($0.key): \($0.value)" }.joined(separator: "\n") }

  required init(file: File) {
    self.file = file
    let sections = file.linesSplitByEmptyLine
    for line in sections[0] {
      let splitIndex = line.components(separatedBy: ": ")
      if splitIndex[1] == "\"a\"" || splitIndex[1] == "\"b\"" {
        cache[splitIndex[0]] = [String(splitIndex[1].dropFirst().dropLast())]
        continue
      }
      let rawRule = splitIndex[1].components(separatedBy: " | ")

      rules[splitIndex[0]] = rawRule.map { $0.components(separatedBy: " ") }
    }

    input = sections[1]
  }

  func solve1() -> String {
    var valids = 0
    // print(rulesDescription)
    let allOptions = generateOptions(id: "0")
    // print(allOptions)
    for line in input {
      var isValid = false
      for option in allOptions {
        if line == option { isValid = true; break }
      }

      print(isValid, line)
      valids += isValid ? 1 : 0
    }
    return valids.description
  }

  var checked: [[String]: Bool] = [["0"]: true]

  func generateOptions(id: String = "0", depth: Int = 1) -> [String] {
    var depth = depth
    // print(id, cache)
    if let c = cache[id] { return c }

    let subRules = rules[id]!
    cache[id] = []

    for r in subRules {
      if r.contains(id) {
        depth += 1
        if depth == 10 {
          return []
        }
      }
      // print("checking sub:", r)
      var concat: [[String]] = []
      for sub in r {
        concat.append(generateOptions(id: sub, depth: depth))
      }
      // print("concating: ", concat)
      cache[id] = cache[id]! + concatenateOptions(res: "", optList: concat)
    }
    return cache[id]!
  }

  func concatenateOptions(res: String, optList: [[String]]) -> [String] {
    if optList.isEmpty { return [res]}
    let first = optList.first!

    var opts: [String] = []
    for str in first {
      opts.append(contentsOf: concatenateOptions(res: res + str, optList: Array(optList.dropFirst())))
    }
    return opts
  }

  func solve2() -> String {
    var valids = 0

    rules["8"] = [["42"], ["42", "8"]]
    rules["11"] = [["42", "31"], ["42", "11", "31"]]

    let allOptions = generateOptions(id: "0")

    for line in input {
      var isValid = false
      for option in allOptions {
        if line == option { isValid = true; break }
      }

      print(isValid, line)
      valids += isValid ? 1 : 0
    }
    return valids.description
  }
}
