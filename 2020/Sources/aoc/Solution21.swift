class Solution21: Solving {
  struct Recipe: CustomStringConvertible {
    let ingrs: [String]
    let allergens: [String]

    var description: String {
      return ingrs.joined(separator: " ") + " | " + allergens.joined(separator: " ")
    }
  }
  let file: File
  let recipes: [Recipe]

  required init(file: File) {
    self.file = file

    recipes = file.lines.map { line in
      let lineParts = line.components(separatedBy: " (contains ")
      let ingrs = lineParts[0].components(separatedBy: " ")
      let allergens = lineParts[1].dropLast().components(separatedBy: ", ")
      return Recipe(ingrs: ingrs, allergens: allergens)
    }
  }

  func solve1() -> String {
    var allIngrs: Set<String> = []
    var allergenShortList: [String: Set<String>] = [:]
    for recipe in recipes {
      // print(allergenShortList)
      // print(recipe.allergens)
      for allergen in recipe.allergens {

        allergenShortList[allergen, default: Set(recipe.ingrs)].formIntersection(recipe.ingrs)
      }
      allIngrs.formUnion(recipe.ingrs)
    }
    let ingrsWithAllergens = allergenShortList.values.reduce([]) { (res: Set<String>, next: Set<String>) -> Set<String> in res.union(next) }
    let ingrsWithoutAllergens = allIngrs.subtracting(ingrsWithAllergens)
    // print(allIngrs)
    // print(allergenShortList)
    print(ingrsWithAllergens)
    print(ingrsWithoutAllergens)
    var count = 0
    for recipe in recipes {
      for ingr in ingrsWithoutAllergens {
        if recipe.ingrs.contains(ingr) { count += 1 }
      }
    }
    return count.description
  }

  func solve2() -> String {
var allIngrs: Set<String> = []
    var allergenShortList: [String: Set<String>] = [:]
    for recipe in recipes {
      // print(allergenShortList)
      // print(recipe.allergens)
      for allergen in recipe.allergens {

        allergenShortList[allergen, default: Set(recipe.ingrs)].formIntersection(recipe.ingrs)
      }
      allIngrs.formUnion(recipe.ingrs)
    }
    print(allergenShortList)
    var kvPairs = allergenShortList.sorted { $0.value.count < $1.value.count }
    for i in 0..<kvPairs.count {
      for j in (i+1)..<kvPairs.count {
        kvPairs[j].value = kvPairs[j].value.subtracting(kvPairs[i].value)
      }
      kvPairs = kvPairs.sorted { $0.value.count < $1.value.count }
    }
    print(kvPairs)
    return kvPairs.sorted { $0.key < $1.key }.map(\.value.first!).joined(separator: ",")
  }
}
