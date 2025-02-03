#!/usr/bin/env python3
import sys
import json
import traceback

class DancingNode:
    def __init__(self, left=None, right=None, up=None, down=None, column=None, row_id=None):
        self.left = left or self
        self.right = right or self
        self.up = up or self
        self.down = down or self
        self.column = column
        self.row_id = row_id

class ColumnNode(DancingNode):
    def __init__(self, name):
        super().__init__()
        self.size = 0
        self.name = name
        self.column = self

def create_dll_header():
    """Create and return the header node for the doubly-linked list."""
    header = ColumnNode("header")
    header.right = header
    header.left = header
    return header

def insert_right(node, new_node):
    """Insert new_node to the right of node."""
    new_node.right = node.right
    new_node.left = node
    node.right.left = new_node
    node.right = new_node

def insert_below(node, new_node):
    """Insert new_node below node."""
    new_node.down = node.down
    new_node.up = node
    node.down.up = new_node
    node.down = new_node

class DLX:
    def __init__(self, num_columns):
        self.header = create_dll_header()
        self.columns = []
        
        # Create column headers
        for i in range(num_columns):
            column = ColumnNode(str(i))
            insert_right(self.header.left, column)
            self.columns.append(column)
    
    def cover_column(self, col):
        """Remove column from header list and cover all rows in column."""
        col.right.left = col.left
        col.left.right = col.right
        
        current_row = col.down
        while current_row != col:
            current_right = current_row.right
            while current_right != current_row:
                current_right.up.down = current_right.down
                current_right.down.up = current_right.up
                current_right.column.size -= 1
                current_right = current_right.right
            current_row = current_row.down
    
    def uncover_column(self, col):
        """Restore column to header list and uncover all rows in column."""
        current_row = col.up
        while current_row != col:
            current_left = current_row.left
            while current_left != current_row:
                current_left.column.size += 1
                current_left.up.down = current_left
                current_left.down.up = current_left
                current_left = current_left.left
            current_row = current_row.up
        
        col.right.left = col
        col.left.right = col
    
    def search(self, k, solution):
        """Recursively search for solutions using Algorithm X."""
        if self.header.right == self.header:
            return True
        
        # Choose column with minimum size
        selected_column = None
        min_size = float('inf')
        current = self.header.right
        while current != self.header:
            if current.size < min_size:
                min_size = current.size
                selected_column = current
            current = current.right
        
        self.cover_column(selected_column)
        
        current_row = selected_column.down
        while current_row != selected_column:
            solution.append(current_row.row_id)
            
            current_right = current_row.right
            while current_right != current_row:
                self.cover_column(current_right.column)
                current_right = current_right.right
            
            if self.search(k + 1, solution):
                return True
            
            solution.pop()
            
            current_left = current_row.left
            while current_left != current_row:
                self.uncover_column(current_left.column)
                current_left = current_left.left
            
            current_row = current_row.down
        
        self.uncover_column(selected_column)
        return False

def solve_sudoku(grid):
    """Solve Sudoku using Dancing Links."""
    # Convert grid constraints to exact cover problem
    rows = []
    
    # Helper to convert row, col, num to exact cover row format
    def append_row(row, col, num):
        # Calculate box number (0-8)
        box = (row // 3) * 3 + col // 3
        
        # Initialize exact cover row
        exact_cover_row = [False] * 324  # 9x9x4 constraints
        
        # Set constraints:
        # 1. Position constraint
        exact_cover_row[row * 9 + col] = True
        # 2. Row-number constraint
        exact_cover_row[81 + row * 9 + (num-1)] = True
        # 3. Column-number constraint
        exact_cover_row[162 + col * 9 + (num-1)] = True
        # 4. Box-number constraint
        exact_cover_row[243 + box * 9 + (num-1)] = True
        
        return exact_cover_row
    
    # Create exact cover matrix
    matrix = []
    for i in range(9):
        for j in range(9):
            if grid[i][j] != 0:
                # Add constraint for given numbers
                matrix.append(append_row(i, j, grid[i][j]))
                rows.append((i, j, grid[i][j]))
            else:
                # Add constraints for possible numbers
                for num in range(1, 10):
                    matrix.append(append_row(i, j, num))
                    rows.append((i, j, num))
    
    # Initialize DLX object
    dlx = DLX(324)
    
    # Add rows to DLX structure
    for row_idx, row in enumerate(matrix):
        prev_node = None
        for col_idx, value in enumerate(row):
            if value:
                new_node = DancingNode()
                new_node.row_id = rows[row_idx]
                new_node.column = dlx.columns[col_idx]
                dlx.columns[col_idx].size += 1
                
                if prev_node:
                    insert_right(prev_node, new_node)
                prev_node = new_node
                
                insert_below(dlx.columns[col_idx].up, new_node)
    
    # Solve using DLX
    solution = []
    dlx.search(0, solution)
    
    # Convert solution back to grid
    result = [[0] * 9 for _ in range(9)]
    for row, col, num in solution:
        result[row][col] = num
    
    return result



if __name__ == "__main__":
    input_json = sys.argv[1]
    grid = json.loads(input_json)

    solution = solve_sudoku(grid)

    print(json.dumps(solution))