//: [Previous](@previous)

import Foundation

var str = "Hello, playground"
str.trimmingCharacters(in: .whitespacesAndNewlines)
var ints = [1,2,3,4,5]
let range = 0..<3
let part = ints[range]
let rev: [Int] = part.reversed()
ints.replaceSubrange(range, with: rev)

str.suffix(16)
str.dropFirst()
var arr = Array(str)
String(arr.dropFirst(arr.count - 5) + arr.dropLast(5))
arr.swapAt(1, 5)
arr.index(of: "e")

ints.insert(5, at: ints.count)
3 % 2

ints.filter { int in
    ints.filter { $0 == int }.count == 1
}

struct V {
    let x: Int
    let y: Int
}

extension V: CustomStringConvertible {
    var description: String {
        return "\(x), \(y)"
    }
}

extension V {
    static func +(lhs: V, rhs: V) -> V {
        return V(x: lhs.x + rhs.x, y: lhs.y + rhs.y)
    }
}

let v1 = V(x: 0,y: 1)
let v2 = V(x: 3, y: -9)

v1 + v2

var x: [Character] = ["a", "b"]
let xx: String = x.reduce("") { (res: String, ch: Character) -> String in
    var res = res
    res.append(ch)
    return res
}
print(xx)
var yy = ["ab", "cd"]
yy.joined(separator: "/")

x.max { (lhs, rhs) -> Bool in
    lhs.hashValue > rhs.hashValue
}
yy.remove(at: yy.index(of: "ab")!)
var b: [Int: Int] = [9: 99]
b.removeValue(forKey: 9)
x.insert("x", at: 0)
b.keys.contains(9)


