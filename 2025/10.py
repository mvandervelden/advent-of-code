import re
from itertools import combinations
import numpy as np
from scipy.optimize import milp, LinearConstraint, Bounds


def parse_line(line):
    """Parse a line into target pattern, buttons, and joltages."""
    # Extract indicator pattern [...]
    indicator_match = re.search(r'\[([.#]+)\]', line)
    indicator = indicator_match.group(1)

    # Extract button schematics (...) - all parentheses groups before the curly braces
    buttons = []
    button_pattern = re.findall(r'\(([^)]+)\)', line.split('{')[0])
    for btn in button_pattern:
        # Each button is a comma-separated list of indices
        indices = tuple(int(x) for x in btn.split(','))
        buttons.append(indices)

    # Extract joltage requirements {...}
    joltage_match = re.search(r'\{([^}]+)\}', line)
    joltages = tuple(int(x) for x in joltage_match.group(1).split(','))

    return indicator, buttons, joltages


def solve_machine(indicator, buttons):
    """
    Find the minimum number of button presses to reach the target state.

    This is essentially finding the minimum weight solution to a system of
    linear equations over GF(2).

    Since each button can only meaningfully be pressed 0 or 1 times (mod 2),
    we need to find a subset of buttons whose combined effect matches the target.
    """
    n_lights = len(indicator)
    n_buttons = len(buttons)

    # Target state: which lights need to be ON
    target = [1 if c == '#' else 0 for c in indicator]

    # Try all possible combinations of buttons, starting from smallest
    for num_presses in range(n_buttons + 1):
        for combo in combinations(range(n_buttons), num_presses):
            # Calculate the resulting state
            state = [0] * n_lights
            for btn_idx in combo:
                for light_idx in buttons[btn_idx]:
                    state[light_idx] ^= 1  # Toggle

            if state == target:
                return num_presses

    # Should not happen if puzzle input is valid
    return float('inf')


def solve_machine_optimized(indicator, buttons):
    """
    Optimized solver using Gaussian elimination over GF(2).
    This finds a solution and then tries to minimize the number of presses.
    """
    n_lights = len(indicator)
    n_buttons = len(buttons)

    if n_buttons == 0:
        # No buttons, check if target is all off
        return 0 if all(c == '.' for c in indicator) else float('inf')

    # Target state
    target = [1 if c == '#' else 0 for c in indicator]

    # Create augmented matrix for GF(2) system
    # Rows = lights, Cols = buttons + target
    matrix = []
    for light in range(n_lights):
        row = []
        for btn_idx in range(n_buttons):
            row.append(1 if light in buttons[btn_idx] else 0)
        row.append(target[light])
        matrix.append(row)

    # Gaussian elimination over GF(2)
    pivot_cols = []
    pivot_row = 0

    for col in range(n_buttons):
        # Find a pivot
        found = False
        for row in range(pivot_row, n_lights):
            if matrix[row][col] == 1:
                # Swap rows
                matrix[pivot_row], matrix[row] = matrix[row], matrix[pivot_row]
                found = True
                break

        if not found:
            continue

        pivot_cols.append(col)

        # Eliminate other rows
        for row in range(n_lights):
            if row != pivot_row and matrix[row][col] == 1:
                for c in range(n_buttons + 1):
                    matrix[row][c] ^= matrix[pivot_row][c]

        pivot_row += 1

    # Check for inconsistency (row with all zeros except last column = 1)
    for row in range(pivot_row, n_lights):
        if matrix[row][n_buttons] == 1:
            # Check if all button columns are 0
            if all(matrix[row][c] == 0 for c in range(n_buttons)):
                return float('inf')  # No solution

    # Find free variables (columns not in pivot_cols)
    free_cols = [c for c in range(n_buttons) if c not in pivot_cols]

    # Try all combinations of free variable assignments to minimize presses
    min_presses = float('inf')

    for free_assignment in range(1 << len(free_cols)):
        # Build solution
        solution = [0] * n_buttons

        # Assign free variables
        for i, col in enumerate(free_cols):
            solution[col] = (free_assignment >> i) & 1

        # Back-substitute to find pivot variable values
        valid = True
        for i in range(len(pivot_cols) - 1, -1, -1):
            pivot_col = pivot_cols[i]
            # Find the row where this column is the pivot
            row = i

            # Calculate the value
            val = matrix[row][n_buttons]
            for c in range(pivot_col + 1, n_buttons):
                val ^= matrix[row][c] * solution[c]
            solution[pivot_col] = val

        # Verify solution
        state = [0] * n_lights
        for btn_idx in range(n_buttons):
            if solution[btn_idx]:
                for light_idx in buttons[btn_idx]:
                    state[light_idx] ^= 1

        if state == target:
            presses = sum(solution)
            min_presses = min(min_presses, presses)

    return min_presses


def solve_joltage(buttons, joltages):
    """
    Find minimum button presses to reach target joltage values.

    This is an Integer Linear Programming problem:
    - Variables: x_i = number of times button i is pressed (non-negative integer)
    - Constraints: For each counter j, sum of x_i for buttons affecting j = joltage[j]
    - Objective: Minimize sum of all x_i

    We use scipy's MILP solver.
    """
    n_counters = len(joltages)
    n_buttons = len(buttons)

    if n_buttons == 0:
        return 0 if all(j == 0 for j in joltages) else float('inf')

    # Build constraint matrix A where A[j][i] = 1 if button i affects counter j
    A = np.zeros((n_counters, n_buttons))
    for btn_idx, btn in enumerate(buttons):
        for counter in btn:
            if counter < n_counters:
                A[counter][btn_idx] = 1

    b = np.array(joltages, dtype=float)

    # Objective: minimize sum of all button presses (coefficient 1 for each)
    c = np.ones(n_buttons)

    # Constraints: A @ x == b (equality constraints)
    constraints = LinearConstraint(A, b, b)

    # Bounds: x >= 0, and we set an upper bound to help the solver
    max_val = max(joltages) + 1 if joltages else 1
    bounds = Bounds(lb=0, ub=max_val * 2)

    # All variables are integers
    integrality = np.ones(n_buttons)

    # Solve
    result = milp(c, constraints=constraints, bounds=bounds, integrality=integrality)

    if result.success:
        return int(round(result.fun))
    else:
        return float('inf')


def part1(data):
    total = 0
    for line in data:
        if not line.strip():
            continue
        indicator, buttons, _ = parse_line(line)

        # Use brute force for small number of buttons, optimized for larger
        if len(buttons) <= 20:
            presses = solve_machine(indicator, buttons)
        else:
            presses = solve_machine_optimized(indicator, buttons)

        total += presses
    return total


def part2(data):
    total = 0
    for line in data:
        if not line.strip():
            continue
        _, buttons, joltages = parse_line(line)
        presses = solve_joltage(buttons, joltages)
        total += presses
    return total


if __name__ == "__main__":
    with open("10.txt") as f:
        data = f.readlines()

    print(f"Part 1: {part1(data)}")
    print(f"Part 2: {part2(data)}")
