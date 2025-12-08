import math
from collections import defaultdict

def parse_input(filename):
    """Parse the input file and return list of (x, y, z) coordinates."""
    with open(filename, 'r') as f:
        coords = []
        for line in f:
            line = line.strip()
            if line:
                x, y, z = map(int, line.split(','))
                coords.append((x, y, z))
    return coords

def euclidean_distance(p1, p2):
    """Calculate Euclidean distance between two 3D points."""
    return math.sqrt((p1[0] - p2[0])**2 + (p1[1] - p2[1])**2 + (p1[2] - p2[2])**2)

class UnionFind:
    """Union-Find data structure for tracking connected components."""
    def __init__(self, n):
        self.parent = list(range(n))
        self.rank = [0] * n
        self.size = [1] * n

    def find(self, x):
        if self.parent[x] != x:
            self.parent[x] = self.find(self.parent[x])  # Path compression
        return self.parent[x]

    def union(self, x, y):
        """Unite two sets. Returns True if they were in different sets."""
        px, py = self.find(x), self.find(y)
        if px == py:
            return False  # Already in the same set

        # Union by rank
        if self.rank[px] < self.rank[py]:
            px, py = py, px
        self.parent[py] = px
        self.size[px] += self.size[py]
        if self.rank[px] == self.rank[py]:
            self.rank[px] += 1
        return True

    def get_circuit_sizes(self):
        """Return list of all circuit sizes."""
        sizes = defaultdict(int)
        for i in range(len(self.parent)):
            root = self.find(i)
            sizes[root] = self.size[root]
        return list(sizes.values())

def solve_part1(coords):
    """Solve part 1: Connect 1000 closest pairs and find product of 3 largest circuits."""
    n = len(coords)

    # Calculate all pairwise distances
    distances = []
    for i in range(n):
        for j in range(i + 1, n):
            dist = euclidean_distance(coords[i], coords[j])
            distances.append((dist, i, j))

    # Sort by distance
    distances.sort()

    # Use Union-Find to track circuits
    uf = UnionFind(n)

    # Connect the 1000 closest pairs
    connections_made = 0
    for dist, i, j in distances:
        if connections_made >= 1000:
            break
        uf.union(i, j)
        connections_made += 1

    # Get circuit sizes and find 3 largest
    sizes = uf.get_circuit_sizes()
    sizes.sort(reverse=True)

    # Multiply the 3 largest
    result = sizes[0] * sizes[1] * sizes[2]
    return result

def solve_part2(coords):
    """Solve part 2: Connect until all in one circuit, return product of X coords of last pair."""
    n = len(coords)

    # Calculate all pairwise distances
    distances = []
    for i in range(n):
        for j in range(i + 1, n):
            dist = euclidean_distance(coords[i], coords[j])
            distances.append((dist, i, j))

    # Sort by distance
    distances.sort()

    # Use Union-Find to track circuits
    uf = UnionFind(n)

    # Keep connecting until all are in one circuit
    last_i, last_j = None, None
    for dist, i, j in distances:
        if uf.union(i, j):  # Only count if they were in different circuits
            last_i, last_j = i, j
            # Check if we have one circuit (all connected)
            if uf.size[uf.find(i)] == n:
                break

    # Multiply the X coordinates of the last two junction boxes
    result = coords[last_i][0] * coords[last_j][0]
    return result

def main():
    coords = parse_input("8.txt")

    result1 = solve_part1(coords)
    print(f"Part 1: {result1}")

    result2 = solve_part2(coords)
    print(f"Part 2: {result2}")

if __name__ == "__main__":
    main()
