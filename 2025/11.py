from collections import defaultdict


def parse_input(path: str) -> dict[str, list[str]]:
    """Parse the wiring diagram into an adjacency list."""
    graph: dict[str, list[str]] = defaultdict(list)
    with open(path, "r") as f:
        for raw in f:
            line = raw.strip()
            if not line:
                continue
            name, targets = line.split(":", 1)
            graph[name.strip()] = [t for t in targets.strip().split() if t]
    return graph


def count_paths(graph: dict[str, list[str]], start: str, end: str = "out") -> int:
    """Count distinct directed paths from start to end using memoized DFS.

    Assumes the graph is acyclic (as implied by the puzzle). If a cycle is
    encountered, a ValueError is raised to avoid infinite recursion.
    """

    memo: dict[str, int] = {}
    visiting: set[str] = set()

    def dfs(node: str) -> int:
        if node == end:
            return 1
        if node in memo:
            return memo[node]
        if node in visiting:
            raise ValueError(f"Cycle detected involving {node}")

        visiting.add(node)
        total = 0
        for nxt in graph.get(node, []):
            total += dfs(nxt)
        visiting.remove(node)

        memo[node] = total
        return total

    return dfs(start)


def part1(graph: dict[str, list[str]]) -> int:
    return count_paths(graph, "you", "out")


def part2(graph: dict[str, list[str]]) -> int:
    """Count paths from svr to out that visit both dac and fft (any order)."""

    start, end = "svr", "out"
    a, b = "dac", "fft"

    # Count ordered paths: start->a->b->end and start->b->a->end
    sab = count_paths(graph, start, a)
    sba = count_paths(graph, start, b)

    ab = count_paths(graph, a, b)
    ba = count_paths(graph, b, a)

    ae = count_paths(graph, a, end)
    be = count_paths(graph, b, end)

    return sab * ab * be + sba * ba * ae


def main():
    graph = parse_input("11.txt")
    print(f"Part 1: {part1(graph)}")
    print(f"Part 2: {part2(graph)}")


if __name__ == "__main__":
    main()
