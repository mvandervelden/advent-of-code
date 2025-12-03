def solve_part1(data):
    """
    For each bank (line), find the maximum two-digit number that can be formed
    by selecting exactly two batteries (digits) in order.
    """
    total = 0

    for line in data:
        line = line.strip()
        if not line:
            continue

        # Find the maximum two-digit number by checking all pairs
        max_joltage = 0
        for i in range(len(line)):
            for j in range(i + 1, len(line)):
                # Form a two-digit number from positions i and j
                two_digit = int(line[i] + line[j])
                max_joltage = max(max_joltage, two_digit)

        total += max_joltage

    return total


def solve_part2(data):
    """
    For each bank (line), find the maximum 12-digit number that can be formed
    by selecting exactly 12 batteries (digits) in order.

    Strategy: Greedily select digits to maximize the resulting number.
    At each position, choose the largest available digit that still leaves
    enough digits for the remaining positions.
    """
    total = 0

    for line in data:
        line = line.strip()
        if not line:
            continue

        n = len(line)
        k = 12  # number of digits to select

        # Greedy selection: for each position in result, pick the largest digit
        # from the remaining candidates that leaves enough digits for the rest
        result = []
        start = 0

        for pos in range(k):
            # We need (k - pos) more digits total
            # We can look at indices from start to n - (k - pos) inclusive
            remaining = k - pos
            max_digit = '0'
            max_idx = start

            # Find the largest digit in the valid range
            for i in range(start, n - remaining + 1):
                if line[i] > max_digit:
                    max_digit = line[i]
                    max_idx = i

            result.append(max_digit)
            start = max_idx + 1

        joltage = int(''.join(result))
        total += joltage

    return total


def main():
    # Read input
    with open('3.txt', 'r') as f:
        data = f.readlines()

    # Part 1
    result1 = solve_part1(data)
    print(f"Part 1: {result1}")

    # Part 2
    result2 = solve_part2(data)
    print(f"Part 2: {result2}")


if __name__ == "__main__":
    main()
