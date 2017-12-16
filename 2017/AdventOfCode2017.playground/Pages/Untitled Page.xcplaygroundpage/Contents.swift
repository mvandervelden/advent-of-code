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

//: [Next](@next)
