import 'dart:io';

class GridSolver {
  final List<List<int>> grid;
  GridSolver(this.grid);
  List<List<int>> solve() {
    final solution = SudokuSolver.solve(grid);
    return solution;
  }

}

class DancingNode {
  DancingNode? left;
  DancingNode? right;
  DancingNode? up;
  DancingNode? down;
  ColumnNode? column;
  dynamic rowId;

  DancingNode({
    this.left,
    this.right,
    this.up,
    this.down,
    this.column,
    this.rowId,
  }) {
    left ??= this;
    right ??= this;
    up ??= this;
    down ??= this;
  }
}

class ColumnNode extends DancingNode {
  int size;
  String name;

  ColumnNode({required this.name}) : size = 0 {
    column = this;
  }
}

class DLX {
  ColumnNode header;
  List<ColumnNode> columns;

  DLX(int numColumns)
      : header = _createDllHeader(),
        columns = [] {
    for (int i = 0; i < numColumns; i++) {
      final column = ColumnNode(name: i.toString());
      _insertRight(header.left!, column);
      columns.add(column);
    }
  }

  static ColumnNode _createDllHeader() {
    final header = ColumnNode(name: 'header');
    header.right = header;
    header.left = header;
    return header;
  }

  void _insertRight(DancingNode node, DancingNode newNode) {
    newNode.right = node.right;
    newNode.left = node;
    node.right!.left = newNode;
    node.right = newNode;
  }

  void _insertBelow(DancingNode node, DancingNode newNode) {
    newNode.down = node.down;
    newNode.up = node;
    node.down!.up = newNode;
    node.down = newNode;
  }

  void _coverColumn(ColumnNode col) {
    col.right!.left = col.left;
    col.left!.right = col.right;

    var currentRow = col.down;
    while (currentRow != col) {
      var currentRight = currentRow!.right;
      while (currentRight != currentRow) {
        currentRight!.up!.down = currentRight.down;
        currentRight.down!.up = currentRight.up;
        (currentRight.column as ColumnNode).size--;
        currentRight = currentRight.right;
      }
      currentRow = currentRow.down;
    }
  }

  void _uncoverColumn(ColumnNode col) {
    var currentRow = col.up;
    while (currentRow != col) {
      var currentLeft = currentRow!.left;
      while (currentLeft != currentRow) {
        (currentLeft!.column as ColumnNode).size++;
        currentLeft.up!.down = currentLeft;
        currentLeft.down!.up = currentLeft;
        currentLeft = currentLeft.left;
      }
      currentRow = currentRow.up;
    }

    col.right!.left = col;
    col.left!.right = col;
  }

  bool search(int k, List<dynamic> solution) {
    if (header.right == header) return true;

    ColumnNode? selectedColumn;
    var minSize = double.infinity;
    var current = header.right;
    while (current != header) {
      final colNode = current as ColumnNode;
      if (colNode.size < minSize) {
        minSize = colNode.size.toDouble();
        selectedColumn = colNode;
      }
      current = current.right!;
    }

    _coverColumn(selectedColumn!);

    var currentRow = selectedColumn.down;
    while (currentRow != selectedColumn) {
      solution.add(currentRow!.rowId);

      var currentRight = currentRow.right;
      while (currentRight != currentRow) {
        _coverColumn(currentRight!.column as ColumnNode);
        currentRight = currentRight.right;
      }

      if (search(k + 1, solution)) return true;

      solution.removeLast();

      var currentLeft = currentRow.left;
      while (currentLeft != currentRow) {
        _uncoverColumn(currentLeft!.column as ColumnNode);
        currentLeft = currentLeft.left;
      }

      currentRow = currentRow.down;
    }

    _uncoverColumn(selectedColumn);
    return false;
  }
}


class SudokuSolver {
  static List<List<int>> solve(List<List<int>> grid) {
    final rows = <dynamic>[];
    final matrix = <List<bool>>[];

    List<bool> appendRow(int row, int col, int num) {
      final box = (row ~/ 3) * 3 + col ~/ 3;
      final exactCoverRow = List.filled(324, false);

      // Position constraint
      exactCoverRow[row * 9 + col] = true;
      // Row-number constraint
      exactCoverRow[81 + row * 9 + (num - 1)] = true;
      // Column-number constraint
      exactCoverRow[162 + col * 9 + (num - 1)] = true;
      // Box-number constraint
      exactCoverRow[243 + box * 9 + (num - 1)] = true;

      return exactCoverRow;
    }

    // Create exact cover matrix
    for (int i = 0; i < 9; i++) {
      for (int j = 0; j < 9; j++) {
        if (grid[i][j] != 0) {
          matrix.add(appendRow(i, j, grid[i][j]));
          rows.add((i, j, grid[i][j]));
        } else {
          for (int num = 1; num <= 9; num++) {
            matrix.add(appendRow(i, j, num));
            rows.add((i, j, num));
          }
        }
      }
    }

    // Initialize DLX
    final dlx = DLX(324);

    // Add rows to DLX structure
    for (int rowIdx = 0; rowIdx < matrix.length; rowIdx++) {
      DancingNode? prevNode;
      for (int colIdx = 0; colIdx < matrix[rowIdx].length; colIdx++) {
        if (matrix[rowIdx][colIdx]) {
          final newNode = DancingNode(
            rowId: rows[rowIdx],
            column: dlx.columns[colIdx],
          );
          dlx.columns[colIdx].size++;

          if (prevNode != null) {
            dlx._insertRight(prevNode, newNode);
          }
          prevNode = newNode;

          dlx._insertBelow(dlx.columns[colIdx].up!, newNode);
        }
      }
    }

    // Solve using DLX
    final solution = <dynamic>[];
    dlx.search(0, solution);

    // Convert solution back to grid
    final result = List.generate(9, (_) => List.filled(9, 0));
    for (final (row, col, num) in solution) {
      result[row][col] = num;
    }

    return result;
  }

  // Helper method to print grid
  static void printGrid(List<List<int>> grid) {
    for (int i = 0; i < 9; i++) {
      if (i % 3 == 0 && i != 0) {
        print('-' * 21);
      }
      for (int j = 0; j < 9; j++) {
        if (j % 3 == 0 && j != 0) {
          stdout.write('| ');
        }
        stdout.write('${grid[i][j]} ');
      }
      print('');
    }
  }
}
