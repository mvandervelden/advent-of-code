//: [Previous](@previous)

import Foundation

struct IP {
    let sections: [Section]

    init(string: String) {
        let splitted = string.split(separator: "[").flatMap { $0.split(separator: "]") }
        var sections: [Section] = []
        for i in 0..<splitted.count {
            if i % 2 == 0 {
                sections.append(Section(string: String(splitted[i]), containsHypernetSequence: false))
            } else {
                sections.append(Section(string: String(splitted[i]), containsHypernetSequence: true))
            }
        }
        self.sections = sections
    }

    var supportsTLS: Bool {
        let containsAbbaInHNSeq = sections.filter {
            $0.containsHypernetSequence
        }.filter {
            $0.hasABBA
        }.count > 0
        if containsAbbaInHNSeq {
            return false
        }

        let containsAbba = sections.filter {
            !$0.containsHypernetSequence
            }.filter {
                $0.hasABBA
        }.count > 0
        if containsAbba {
            return true
        }
        return false
    }

    var supportsSSL: Bool {

    }
}

extension IP: CustomDebugStringConvertible {
    var debugDescription: String {
        return sections.reduce("") { $0 + " " + $1.debugDescription }
    }
}

struct Section {
    let string: String
    let containsHypernetSequence: Bool

    var hasABBA: Bool {
        for i in 0..<(string.count - 3) {
            let firstChar = string[string.index(string.startIndex, offsetBy: i)]
            let secChar = string[string.index(string.startIndex, offsetBy: i + 1)]
            if firstChar != secChar {
                let trdChar = string[string.index(string.startIndex, offsetBy: i + 2)]
                let frtChar = string[string.index(string.startIndex, offsetBy: i + 3)]
                if firstChar == frtChar && secChar == trdChar {
                    if containsHypernetSequence {
                        print("[\(firstChar)\(secChar)\(trdChar)\(frtChar)]")
                    } else {
                        print("\(firstChar)\(secChar)\(trdChar)\(frtChar)")
                    }
                    return true
                }
            }
        }
        return false
    }

    var abas: [String] {
        
    }
}

extension Section: CustomDebugStringConvertible {
    var debugDescription: String {
        if containsHypernetSequence {
            return "[\(string)]"
        }
        return string
    }
}

func read1(_ fileName: String = "input") -> [IP] {
    let fileURL = Bundle.main.url(forResource: fileName, withExtension: "txt")
    let content = try! String(contentsOf: fileURL!)
    return content
        .split(separator: "\n")//[0..<10]
        .map { IP(string: String($0)) }
}

func solve1() {
    let ips = read1()
    let tlsIPs = ips.filter {
        $0.supportsTLS
    }
    print(ips)
    print(tlsIPs.count)//115
}

func solve2() {
    let ips = read1()
    let sslIPs = ips.filter {
        $0.supportsSSL
    }
    print(ips)
    print(sslIPs.count)
}


solve2()
//: [Next](@next)
