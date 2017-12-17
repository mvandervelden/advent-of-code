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
//: [Next](@next)
