class Solution19: Solving {
  class Rule: CustomStringConvertible {
    let index: String
    var options: Set<[String]>

    init(_ line: String) {
      let splitIndex = line.components(separatedBy: ": ")
      index = splitIndex[0]
      let optionsArray = splitIndex[1]
        .components(separatedBy: " | ")
        .map { (optionString: String) -> [String] in
          let option = optionString.components(separatedBy: " ")
          return option.map { $0.replacingOccurrences(of: "\"", with: "") }
        }
      options = Set(optionsArray)
    }

    var description: String {
      let optionsString = options.map { $0.map { String($0) }.joined(separator: " ") }.joined(separator: " | ")
      return "\(index): \(optionsString)"
    }

    var isDetermined: Bool {
      options.reduce(true) {
        $0 && $1.reduce(true) {
          $0 && Int($1) == nil
        }
      }
    }

    func replace(_ rule: Rule) {
      guard options.contains(where: { $0.contains(rule.index) } ) else { return }

      var newOptions: Set<[String]> = []

      for option in options {
        guard option.contains(rule.index) else { newOptions.insert(option); continue }

        for ruleOption in rule.options {
          var newOption: [String] = []

          for idx in option.indices {
            if option[idx] == rule.index {
              newOption.append(contentsOf: ruleOption)
            } else {
              newOption.append(option[idx])
            }
          }
          newOptions.insert(newOption)
        }
      }

      options = newOptions
    }

    lazy var stringed: Set<String> = { Set(options.map { $0.joined() }) }()

    func matches(_ input: String) -> Bool {
      stringed.contains(input)
    }
  }

  let file: File
  let input: Lines
  let rules: [Rule]

  var rulesDescription: String { rules.map { $0.description }.joined(separator: "\n") }

  required init(file: File) {
    self.file = file
    let sections = file.linesSplitByEmptyLine
    rules = sections[0].map(Rule.init).sorted { $0.index < $1.index }
    input = sections[1]
  }

  func solve1() -> String {
    var determineds: Set<String> = []
    var i = 0
    while !rules[0].isDetermined {
      // print(rulesDescription)
      // print()
      let ruleToEval = rules.first { !determineds.contains($0.index) && $0.isDetermined }!
      print(i, "rule:", ruleToEval.description)
      i += 1

      for rule in rules where !rule.isDetermined {
        if i > 130 { print("evaling rule: ", rule)}
        rule.replace(ruleToEval)
      }
      determineds.insert(ruleToEval.index)
    }

    // print(rulesDescription)
    // print()
    print("Getting result")
    let finalRule = rules[0]
    return input.reduce(0) {
      $0 + (finalRule.matches($1) ? 1 : 0)
    }.description
  }

  func solve2() -> String {

    return file.lines.joined(separator: "\n")
  }

}
