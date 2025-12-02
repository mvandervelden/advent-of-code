#!/usr/bin/env python3

def is_invalid_id(num):
    """
    Check if a number is invalid (a sequence of digits repeated at least twice).
    e.g., 11 (1 twice), 6464 (64 twice), 123123123 (123 three times)
    No leading zeros allowed.
    """
    s = str(num)
    length = len(s)
    
    # Try all possible pattern lengths (from 1 to length//2)
    # The pattern must repeat at least twice
    for pattern_len in range(1, length // 2 + 1):
        # Check if the string length is divisible by pattern length
        if length % pattern_len == 0:
            pattern = s[:pattern_len]
            
            # Check if pattern has leading zeros
            if pattern[0] == '0':
                continue
            
            # Check if the entire string is this pattern repeated
            repetitions = length // pattern_len
            if pattern * repetitions == s and repetitions >= 2:
                return True
    
    return False
def solve_part1(input_file):
    """
    Find all invalid product IDs in the given ranges and sum them.
    """
    with open(input_file, 'r') as f:
        content = f.read().strip()

    # Parse ranges (format: "start-end,start-end,...")
    ranges = []
    for range_str in content.split(','):
        range_str = range_str.strip()
        if '-' in range_str:
            parts = range_str.split('-')
            # Handle negative numbers by finding the last '-' that splits the range
            # Actually, IDs are positive, so we can just split on '-'
            # But we need to be careful with ranges like "11-22"
            if len(parts) == 2:
                start, end = int(parts[0]), int(parts[1])
                ranges.append((start, end))

    total = 0
    for start, end in ranges:
        for num in range(start, end + 1):
            if is_invalid_id(num):
                total += num

    return total


def main():
    import os

    possible_inputs = ['2.txt', '2_input.txt', 'input.txt']
    input_file = None

    for filename in possible_inputs:
        if os.path.exists(filename):
            input_file = filename
            break

    if input_file is None:
        print("Please create an input file (2.txt or 2_input.txt) with your puzzle input.")
        return

    result1 = solve_part1(input_file)
    print(f"Part 1 & 2 - Sum of invalid IDs: {result1}")


if __name__ == "__main__":
    main()
