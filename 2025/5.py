#!/usr/bin/env python3

def parse_input(filename):
    """Parse the input file into ranges and ingredient IDs."""
    with open(filename, 'r') as f:
        content = f.read().strip()

    # Split by blank line
    sections = content.split('\n\n')
    ranges_section = sections[0]
    ids_section = sections[1]

    # Parse ranges
    ranges = []
    for line in ranges_section.split('\n'):
        start, end = line.split('-')
        ranges.append((int(start), int(end)))

    # Parse ingredient IDs
    ingredient_ids = [int(line) for line in ids_section.split('\n')]

    return ranges, ingredient_ids


def is_fresh(ingredient_id, ranges):
    """Check if an ingredient ID is fresh (falls into any range)."""
    for start, end in ranges:
        if start <= ingredient_id <= end:
            return True
    return False


def count_fresh_ingredients(ranges, ingredient_ids):
    """Count how many ingredient IDs are fresh."""
    count = 0
    for ingredient_id in ingredient_ids:
        if is_fresh(ingredient_id, ranges):
            count += 1
    return count


def part1(filename):
    """Solve part 1."""
    ranges, ingredient_ids = parse_input(filename)
    return count_fresh_ingredients(ranges, ingredient_ids)


def part2(filename):
    """Solve part 2."""
    ranges, _ = parse_input(filename)

    # Merge overlapping ranges to count unique IDs
    # First, sort ranges by start position
    sorted_ranges = sorted(ranges)

    # Merge overlapping or adjacent ranges
    merged = []
    for start, end in sorted_ranges:
        if merged and start <= merged[-1][1] + 1:
            # Overlapping or adjacent - merge with previous range
            merged[-1] = (merged[-1][0], max(merged[-1][1], end))
        else:
            # Non-overlapping - add as new range
            merged.append((start, end))

    # Count total IDs in all merged ranges
    total = 0
    for start, end in merged:
        total += end - start + 1

    return total


if __name__ == "__main__":
    filename = "5.txt"

    result1 = part1(filename)
    print(f"Part 1: {result1}")

    result2 = part2(filename)
    print(f"Part 2: {result2}")
