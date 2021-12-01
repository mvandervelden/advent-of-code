class Solution07: Solving {
  let file: File

  required init(file: File) {
    self.file = file
  }

  typealias Rules = [String: [(name: String, count: Int)]]

  func solve1() -> String {
    let ruleDict = parseRules()

    var containers: Set<String> = []
    var openSearchTerms: Set<String> = ["shiny gold bag"]
    var searchedTerms: Set<String> = []
    while !openSearchTerms.isEmpty {
      let searchTerm = openSearchTerms.popFirst()!
      for rule in ruleDict {
        for ruled in rule.value {
          if ruled.name == searchTerm {
            containers.insert(rule.key)
            if !searchedTerms.contains(rule.key) {
              openSearchTerms.insert(rule.key)
            }
          }
        }
      }
      searchedTerms.insert(searchTerm)
    }

    return "\(containers.count.description): \(containers.description)"
  }

  func solve2() -> String {
    let ruleDict = parseRules()

    var totalCount = 0
    var openSearchTerms: [String: Int] = ["shiny gold bag": 1]
    while !openSearchTerms.isEmpty {
      let searchTerm = openSearchTerms.first!
      openSearchTerms[searchTerm.key] = nil
      for rule in ruleDict {
        if rule.key == searchTerm.key {
          for ruled in rule.value {
            let bagsToAdd = ruled.count * searchTerm.value
            totalCount += bagsToAdd
            openSearchTerms[ruled.name, default: 0] += bagsToAdd
          }
        }
      }
    }

    return "\(totalCount)"
  }

  func parseRules() -> Rules {
    var ruleDict: Rules = [:]

    let lines = file.lines
    for line in lines {
      let parts = line.components(separatedBy: "s contain ")
      let ruleBagName = parts[0]
      let ruledBags = parts[1].components(separatedBy: ", ")
      var dictValues: [(name: String, count: Int)] = []

      for ruled in ruledBags {
        if ruled == "no other bags." { break }

        var ruled = ruled
        ruled.removeAll { $0 == "." }
        let words = ruled.split(separator: " ")
        let count = Int(words[0])!

        var bagName = words.dropFirst().joined(separator: " ")
        if count > 1 {
          bagName = String(bagName.dropLast())
        }
        dictValues.append((name: bagName, count: count))
      }

      ruleDict[ruleBagName] = dictValues
    }
    return ruleDict
  }
}
