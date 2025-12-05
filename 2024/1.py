#!/usr/bin/env python3

def parse_input(filename):
    """Parse the input file into two lists of numbers."""
    left_list = []
    right_list = []

    with open(filename, 'r') as f:
        for line in f:
            left, right = line.strip().split()
            left_list.append(int(left))
            right_list.append(int(right))

    return left_list, right_list

def part1(left_list, right_list):
    """Calculate the total distance between the two lists."""
    # Sort both lists
    left_sorted = sorted(left_list)
    right_sorted = sorted(right_list)

    # Calculate distances and sum them
    total_distance = sum(abs(l - r) for l, r in zip(left_sorted, right_sorted))

    return total_distance

def part2(left_list, right_list):
    """Calculate the similarity score between the two lists."""
    # Count occurrences of each number in the right list
    from collections import Counter
    right_counts = Counter(right_list)

    # Calculate similarity score
    similarity_score = sum(num * right_counts[num] for num in left_list)

    return similarity_score

def main():
    left_list, right_list = parse_input('1.txt')

    result1 = part1(left_list, right_list)
    print(f"Part 1: {result1}")

    result2 = part2(left_list, right_list)
    print(f"Part 2: {result2}")

if __name__ == "__main__":
    main()
