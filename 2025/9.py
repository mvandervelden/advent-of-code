#!/usr/bin/env python3
"""Advent of Code 2025 - Day 9: Movie Theater"""

def parse_input(filename):
    """Parse the input file and return list of red tile coordinates."""
    tiles = []
    with open(filename, 'r') as f:
        for line in f:
            line = line.strip()
            if line:
                x, y = map(int, line.split(','))
                tiles.append((x, y))
    return tiles


def largest_rectangle_area(tiles):
    """
    Find the largest rectangle that can be formed using any two red tiles
    as opposite corners.
    """
    max_area = 0
    n = len(tiles)

    for i in range(n):
        for j in range(i + 1, n):
            x1, y1 = tiles[i]
            x2, y2 = tiles[j]

            width = abs(x2 - x1) + 1
            height = abs(y2 - y1) + 1
            area = width * height

            max_area = max(max_area, area)

    return max_area


def build_boundary_segments(tiles):
    """
    Build lists of horizontal and vertical boundary segments.
    """
    horizontal = []  # segments where y is constant: (x1, x2, y)
    vertical = []    # segments where x is constant: (y1, y2, x)

    n = len(tiles)
    for i in range(n):
        x1, y1 = tiles[i]
        x2, y2 = tiles[(i + 1) % n]

        if y1 == y2:
            horizontal.append((min(x1, x2), max(x1, x2), y1))
        else:
            vertical.append((min(y1, y2), max(y1, y2), x1))

    return horizontal, vertical


def is_inside_or_boundary(x, y, horizontal, vertical):
    """
    Check if point (x, y) is inside or on the boundary of the polygon.
    """
    # Check if on horizontal boundary
    for x1, x2, by in horizontal:
        if y == by and x1 <= x <= x2:
            return True

    # Check if on vertical boundary
    for y1, y2, bx in vertical:
        if x == bx and y1 <= y <= y2:
            return True

    # Ray casting: count crossings to the right
    crossings = 0
    for y1, y2, bx in vertical:
        if bx > x and y1 <= y < y2:
            crossings += 1

    return crossings % 2 == 1


def rectangle_fully_inside(min_x, min_y, max_x, max_y, horizontal, vertical):
    """
    Check if the entire rectangle is inside or on the polygon boundary.

    A rectangle is fully inside if:
    1. All four corners are inside or on boundary
    2. No boundary segment cuts through the rectangle creating an outside region

    For this rectilinear polygon, we need to check that there's no boundary
    segment that would create a "notch" cutting into our rectangle.
    """
    # Check all four corners
    corners = [(min_x, min_y), (min_x, max_y), (max_x, min_y), (max_x, max_y)]
    for cx, cy in corners:
        if not is_inside_or_boundary(cx, cy, horizontal, vertical):
            return False

    # For each vertical boundary segment strictly inside the x-range,
    # check if any point along it (within the rectangle's y-range) is outside
    for y1, y2, bx in vertical:
        if min_x < bx < max_x:
            # Segment at x=bx from y1 to y2
            # Check overlap with rectangle's y-range
            overlap_y1 = max(y1, min_y)
            overlap_y2 = min(y2, max_y)
            if overlap_y1 <= overlap_y2:
                # There's overlap - check a point just to the left and right
                # If crossing this segment changes inside/outside status, there's a problem
                # Check the midpoint of the overlap
                test_y = (overlap_y1 + overlap_y2) // 2
                left_inside = is_inside_or_boundary(bx - 1, test_y, horizontal, vertical)
                right_inside = is_inside_or_boundary(bx + 1, test_y, horizontal, vertical)
                if not left_inside or not right_inside:
                    return False

    # For each horizontal boundary segment strictly inside the y-range
    for x1, x2, by in horizontal:
        if min_y < by < max_y:
            overlap_x1 = max(x1, min_x)
            overlap_x2 = min(x2, max_x)
            if overlap_x1 <= overlap_x2:
                test_x = (overlap_x1 + overlap_x2) // 2
                above_inside = is_inside_or_boundary(test_x, by + 1, horizontal, vertical)
                below_inside = is_inside_or_boundary(test_x, by - 1, horizontal, vertical)
                if not above_inside or not below_inside:
                    return False

    return True


def largest_rectangle_with_colors(tiles):
    """
    Find the largest rectangle where:
    - Opposite corners are red tiles
    - All tiles in the rectangle are red or green (inside the polygon)
    """
    horizontal, vertical = build_boundary_segments(tiles)

    max_area = 0
    n = len(tiles)

    # Sort pairs by potential area (largest first) for early termination
    pairs = []
    for i in range(n):
        for j in range(i + 1, n):
            x1, y1 = tiles[i]
            x2, y2 = tiles[j]
            width = abs(x2 - x1) + 1
            height = abs(y2 - y1) + 1
            area = width * height
            pairs.append((area, i, j))

    pairs.sort(reverse=True)

    for area, i, j in pairs:
        if area <= max_area:
            break

        x1, y1 = tiles[i]
        x2, y2 = tiles[j]

        min_x, max_x = min(x1, x2), max(x1, x2)
        min_y, max_y = min(y1, y2), max(y1, y2)

        if rectangle_fully_inside(min_x, min_y, max_x, max_y, horizontal, vertical):
            max_area = area

    return max_area


def part1(tiles):
    """Solve part 1: Find the largest rectangle area."""
    return largest_rectangle_area(tiles)


def part2(tiles):
    """Solve part 2: Find largest rectangle using only red/green tiles."""
    return largest_rectangle_with_colors(tiles)


def main():
    tiles = parse_input("9.txt")

    result1 = part1(tiles)
    print(f"Part 1: {result1}")

    result2 = part2(tiles)
    print(f"Part 2: {result2}")


if __name__ == "__main__":
    main()
