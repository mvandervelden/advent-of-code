// protocol Edge: CustomStringConvertible & Codable {
//     /// The origin vertex of the edge
//     var u: Int {get set}  //made modifiable for changing when removing vertices
//     /// The destination vertex of the edge
//     var v: Int {get set}  //made modifiable for changing when removing vertices
// }

// struct UnweightedEdge: Edge, CustomStringConvertible, Equatable {
//     var u: Int
//     var v: Int

//     init(u: Int, v: Int) {
//         self.u = u
//         self.v = v
//     }

//     // Implement Printable protocol
//     var description: String {
//         return "\(u) -> \(v)"
//     }

//     // MARK: Operator Overloads
//     static func ==(lhs: UnweightedEdge, rhs: UnweightedEdge) -> Bool {
//         return lhs.u == rhs.u && lhs.v == rhs.v
//     }
// }

// protocol Graph: CustomStringConvertible, Collection, Codable {
//     associatedtype V: Equatable & Codable
//     associatedtype E: Edge & Equatable
//     var vertices: [V] { get set }
//     var edges: [[E]] { get set }

//     init(vertices: [V])
//     func addEdge(_ e: E)
// }

// extension Graph {
//     /// How many vertices are in the graph?
//     var vertexCount: Int {
//         return vertices.count
//     }

//     /// How many edges are in the graph?
//     var edgeCount: Int {
//         return edges.joined().count
//     }

//     /// Returns a list of all the edges, undirected edges are only appended once.
//     func edgeList() -> [E] {
//         let edges = self.edges
//         var edgeList = [E]()
//         for i in edges.indices {
//             let edgesForVertex = edges[i]
//             for j in edgesForVertex.indices {
//                 let edge = edgesForVertex[j]
//                 // We only want to append undirected edges once, so we do it when we find it on the
//                 // vertex with lowest index.
//                 if edge.v >= edge.u {
//                     edgeList.append(edge)
//                 }
//             }
//         }
//         return edgeList
//     }

//     /// Get a vertex by its index.
//     ///
//     /// - parameter index: The index of the vertex.
//     /// - returns: The vertex at i.
//     func vertexAtIndex(_ index: Int) -> V {
//         return vertices[index]
//     }

//     /// Find the first occurence of a vertex if it exists.
//     ///
//     /// - parameter vertex: The vertex you are looking for.
//     /// - returns: The index of the vertex. Return nil if it can't find it.

//     func indexOfVertex(_ vertex: V) -> Int? {
//         if let i = vertices.firstIndex(of: vertex) {
//             return i
//         }
//         return nil;
//     }

//     /// Find all of the neighbors of a vertex at a given index.
//     ///
//     /// - parameter index: The index for the vertex to find the neighbors of.
//     /// - returns: An array of the neighbor vertices.
//     func neighborsForIndex(_ index: Int) -> [V] {
//         return edges[index].map({self.vertices[$0.v]})
//     }

//     /// Find all of the neighbors of a given Vertex.
//     ///
//     /// - parameter vertex: The vertex to find the neighbors of.
//     /// - returns: An optional array of the neighbor vertices.
//     func neighborsForVertex(_ vertex: V) -> [V]? {
//         if let i = indexOfVertex(vertex) {
//             return neighborsForIndex(i)
//         }
//         return nil
//     }

//     /// Find all of the edges of a vertex at a given index.
//     ///
//     /// - parameter index: The index for the vertex to find the children of.
//     func edgesForIndex(_ index: Int) -> [E] {
//         return edges[index]
//     }

//     /// Find all of the edges of a given vertex.
//     ///
//     /// - parameter vertex: The vertex to find the edges of.
//     func edgesForVertex(_ vertex: V) -> [E]? {
//         if let i = indexOfVertex(vertex) {
//             return edgesForIndex(i)
//         }
//         return nil
//     }

//     /// Find the first occurence of a vertex.
//     ///
//     /// - parameter vertex: The vertex you are looking for.
//     func vertexInGraph(vertex: V) -> Bool {
//         if let _ = indexOfVertex(vertex) {
//             return true
//         }
//         return false
//     }

//     /// Add a vertex to the graph.
//     ///
//     /// - parameter v: The vertex to be added.
//     /// - returns: The index where the vertex was added.
//     mutating func addVertex(_ v: V) -> Int {
//         vertices.append(v)
//         edges.append([E]())
//         return vertices.count - 1
//     }

//     /// Add an edge to the graph.
//     ///
//     /// - parameter e: The edge to add.
//     /// - parameter directed: If false, undirected edges are created.
//     ///                       If true, a reversed edge is also created.
//     ///                       Default is false.
//     mutating func addEdge(_ e: E) {
//         edges[e.u].append(e)
//     }

//     /// Check whether an edge is in the graph or not.
//     ///
//     /// - parameter edge: The edge to find in the graph.
//     /// - returns: True if the edge exists, and false otherwise.
//     func edgeExists(_ edge: E) -> Bool {
//         return edges[edge.u].contains(edge)
//     }

//     // MARK: Implement Printable protocol
//     var description: String {
//         var d: String = ""
//         for i in 0..<vertices.count {
//             d += "\(vertices[i]) -> \(neighborsForIndex(i))\n"
//         }
//         return d
//     }

//     // MARK: Implement CollectionType

//     var startIndex: Int {
//         return 0
//     }

//     var endIndex: Int {
//         return vertexCount
//     }

//     func index(after i: Int) -> Int {
//         return i + 1
//     }

//     /// The same as vertexAtIndex() - returns the vertex at index
//     ///
//     ///
//     /// - Parameter index: The index of vertex to return.
//     /// - returns: The vertex at index.
//     subscript(i: Int) -> V {
//         return vertexAtIndex(i)
//     }
// }

// class UnweightedGraph<V: Equatable & Codable>: Graph {
//     var vertices: [V] = [V]()
//     var edges: [[UnweightedEdge]] = [[UnweightedEdge]]() //adjacency lists

//     init() {
//     }

//     required init(vertices: [V]) {
//         for vertex in vertices {
//             _ = self.addVertex(vertex)
//         }
//     }

//     /// Add an edge to the graph.
//     ///
//     /// - parameter e: The edge to add.
//     /// - parameter directed: If false, undirected edges are created.
//     ///                       If true, a reversed edge is also created.
//     ///                       Default is false.
//     func addEdge(_ e: UnweightedEdge) {
//         edges[e.u].append(e)
//     }

//     /// Add a vertex to the graph.
//     ///
//     /// - parameter v: The vertex to be added.
//     /// - returns: The index where the vertex was added.
//     func addVertex(_ v: V) -> Int {
//         vertices.append(v)
//         edges.append([E]())
//         return vertices.count - 1
//     }
// }

// extension Graph where E == UnweightedEdge {
//     /// This is a convenience method that adds an unweighted edge.
//     ///
//     /// - parameter from: The starting vertex's index.
//     /// - parameter to: The ending vertex's index.
//     /// - parameter directed: Is the edge directed? (default `false`)
//     func addEdge(fromIndex: Int, toIndex: Int) {
//         addEdge(UnweightedEdge(u: fromIndex, v: toIndex))
//     }
// }

// extension Graph {
//   func bfs(fromIndex: Int, goalTest: (V) -> Bool) -> [E] {
//     // pretty standard bfs that doesn't visit anywhere twice; pathDict tracks route
//     var visited: [Bool] = [Bool](repeating: false, count: vertexCount)
//     let queue: Queue<Int> = Queue<Int>()
//     var pathDict: [Int: Edge] = [Int: Edge]()
//     queue.push(fromIndex)
//     while !queue.isEmpty {
//       let v: Int = queue.pop()
//       if goalTest(vertexAtIndex(v)) {
//         // figure out route of edges based on pathDict
//         return pathDictToPath(from: fromIndex, to: v, pathDict: pathDict) as! [Self.E]
//       }

//       for e in edgesForIndex(v) {
//         if !visited[e.v] {
//           visited[e.v] = true
//           queue.push(e.v)
//           pathDict[e.v] = e
//         }
//      }
//     }
//     return [] // no path found
//   }

//   func pathDictToPath(from: Int, to: Int, pathDict:[Int:Edge]) -> [Edge] {
//     if pathDict.count == 0 {
//       return []
//     }
//     var edgePath: [Edge] = [Edge]()
//     var e: Edge = pathDict[to]!
//     edgePath.append(e)
//     while (e.u != from) {
//       e = pathDict[e.u]!
//       edgePath.append(e)
//     }
//     return Array(edgePath.reversed())
//   }
// }

// class Queue<T> {
//     private var container = [T]()
//     private var head = 0

//     init() {}

//     var isEmpty: Bool {
//         return count == 0
//     }

//     func push(_ element: T) {
//         container.append(element)
//     }

//     func pop() -> T {
//         let element = container[head]
//         head += 1

//         // If queue has more than 50 elements and more than 50% of allocated elements are popped.
//         // Don't calculate the percentage with floating point, it decreases the performance considerably.
//         if container.count > 50 && head * 2 > container.count {
//             container.removeFirst(head)
//             head = 0
//         }

//         return element
//     }

//     var front: T {
//         return container[head]
//     }

//     var count: Int {
//         return container.count - head
//     }
// }

// extension Queue where T: Equatable {
//     func contains(_ thing: T) -> Bool {
//         let content = container.dropFirst(head)
//         if content.firstIndex(of: thing) != nil {
//             return true
//         }
//         return false
//     }
// }