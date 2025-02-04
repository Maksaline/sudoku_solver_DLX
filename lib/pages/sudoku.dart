import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sudoku_solver/algorithm/dlx_solver.dart';
import 'package:sudoku_solver/responsive/responsive_layout.dart';

class Sudoku extends StatefulWidget {
  const Sudoku({super.key});

  @override
  State<Sudoku> createState() => _SudokuState();
}

class _SudokuState extends State<Sudoku> {
  final Map<String, TextEditingController> textControllers = {};
  final List<List<int>> grid = List.generate(9, (_) => List.generate(9, (_) => 0));
  bool isEnabled = true;

  Future<String> getScriptPath(String scriptName) async {
    try {
      final appDir = await getApplicationSupportDirectory();
      final file = File('${appDir.path}/$scriptName');

      if (!await file.exists()) {
        try {
          final scriptBytes = await rootBundle.load('assets/python/$scriptName');
          await file.create(recursive: true);
          await file.writeAsBytes(
              scriptBytes.buffer.asUint8List(
                  scriptBytes.offsetInBytes,
                  scriptBytes.lengthInBytes
              )
          );
        } catch (e) {
          print('Error loading script from assets: $e');
          throw Exception('Script not found in assets');
        }
      }

      return file.path;
    } catch (e) {
      print('Error resolving script path: $e');
      rethrow;
    }
  }

  void solveSudoku() async {
    final scriptPath = await getScriptPath('test.py');

    setState(() {
      isEnabled = false;
    });

    if(Platform.isAndroid) {
      final gridSolver = GridSolver(grid);
      final solution = gridSolver.solve();
      for (int i = 0; i < 9; i++) {
        for (int j = 0; j < 9; j++) {
          if(solution[i][j] == 0) {
            invalidInput();
            return;
          }
          textControllers['$i$j']!.text = solution[i][j].toString();
          grid[i][j] = solution[i][j];
        }
      }
    } else {
      final inputJson = jsonEncode(grid);
      final result = await Process.run('python', [
        scriptPath,
        inputJson
      ]);
      if(result.exitCode == 0) {
        final output = jsonDecode(result.stdout as String);
        for (int i = 0; i < 9; i++) {
          for (int j = 0; j < 9; j++) {
            if(output[i][j] == 0) {
              invalidInput();
              return;
            }
            textControllers['$i$j']!.text = output[i][j].toString();
            grid[i][j] = output[i][j];

          }
        }
      } else {
        print('Error: ${result.stderr}');
      }
    }
  }

  void invalidInput() {
    setState(() {
      isEnabled = true;
    });
    for(int i = 0; i < 9; i++) {
      for(int j = 0; j < 9; j++) {
        textControllers['$i$j']!.clear();
        grid[i][j] = 0;
      }
    }
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Invalid Input'),
          content: const Text('Please enter a valid sudoku puzzle'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  @override
  void initState() {
    super.initState();
    for (int i = 0; i < 9; i++) {
      for (int j = 0; j < 9; j++) {
        textControllers['$i$j'] = TextEditingController();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: (Responsive.isMobile(context)) ? MediaQuery.of(context).size.width * 0.95 : MediaQuery.of(context).size.height * 0.7,
              height: (Responsive.isMobile(context)) ? MediaQuery.of(context).size.width * 0.95 : MediaQuery.of(context).size.height * 0.7,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.black, width: 2),
              ),
              child: Column(
                children: [
                  Flexible(
                    flex: 1,
                    child: Row(
                      children: [
                        Flexible(
                          flex: 1,
                          child: buildSmallestColumn(0, 0),
                        ),
                        Flexible(
                          flex: 1,
                          child: Container(
                            decoration: const BoxDecoration(
                              border: Border(
                                right: BorderSide(color: Colors.black, width: 2),
                                left: BorderSide(color: Colors.black, width: 2),
                              ),
                            ),
                            child: buildSmallestColumn(0, 3),
                          ),
                        ),
                        Flexible(
                          flex: 1,
                          child: Container(
                            child: buildSmallestColumn(0, 6),
                          ),
                        ),
                      ],
                    )
                  ),
                  Flexible(
                    flex: 1,
                    child: Container(
                      decoration: const BoxDecoration(
                        border: Border(
                          top: BorderSide(color: Colors.black, width: 2),
                          bottom: BorderSide(color: Colors.black, width: 2),
                        ),
                      ),
                      child: Row(
                        children: [
                          Flexible(
                            flex: 1,
                            child: Container(
                              child: buildSmallestColumn(3, 0),
                            ),
                          ),
                          Flexible(
                            flex: 1,
                            child: Container(
                              decoration: const BoxDecoration(
                                border: Border(
                                  right: BorderSide(color: Colors.black, width: 2),
                                  left: BorderSide(color: Colors.black, width: 2),
                                ),
                              ),
                              child: buildSmallestColumn(3, 3),
                            ),
                          ),
                          Flexible(
                            flex: 1,
                            child: Container(
                              child: buildSmallestColumn(3, 6),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Flexible(
                      flex: 1,
                      child: Row(
                        children: [
                          Flexible(
                            flex: 1,
                            child: Container(
                              child: buildSmallestColumn(6, 0),
                            ),
                          ),
                          Flexible(
                            flex: 1,
                            child: Container(
                              decoration: const BoxDecoration(
                                border: Border(
                                  right: BorderSide(color: Colors.black, width: 2),
                                  left: BorderSide(color: Colors.black, width: 2),
                                ),
                              ),
                              child: buildSmallestColumn(6, 3),
                            ),
                          ),
                          Flexible(
                            flex: 1,
                            child: Container(
                              child: buildSmallestColumn(6, 6),
                            ),
                          ),
                        ],
                      )
                  ),
                ],
              )
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (context) {
                        return AlertDialog(
                          title: Text('Reset ?', style: GoogleFonts.lato()),
                          content: Text('Are you sure you want to reset the puzzle?', style: GoogleFonts.lato()),
                          actions: [
                            TextButton(
                              onPressed: () {
                                Navigator.of(context).pop();
                              },
                              child: Text('Cancel', style: GoogleFonts.lato(color: Colors.black)),
                            ),
                            TextButton(
                              onPressed: () {
                                for (int i = 0; i < 9; i++) {
                                  for (int j = 0; j < 9; j++) {
                                    textControllers['$i$j']!.clear();
                                    grid[i][j] = 0;
                                  }
                                }
                                setState(() {
                                  isEnabled = true;
                                });
                                Navigator.of(context).pop();
                              },
                              child: Text('OK', style: GoogleFonts.lato(color: Colors.red)),
                            ),
                          ],
                        );
                      },
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: Colors.black,
                    // minimumSize: const Size(200, 50),
                    maximumSize: const Size(150, 50),
                    side: const BorderSide(
                        color: Colors.black,
                        width: 2
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.restart_alt),
                      const SizedBox(width: 10),
                      Text('Reset', style: GoogleFonts.lato(),),
                    ],
                  ),
                ),
                const SizedBox(width: 20),
                ElevatedButton(
                  onPressed: () {
                    for (int i = 0; i < 9; i++) {
                      for (int j = 0; j < 9; j++) {
                        grid[i][j] = (textControllers['$i$j']!.text) == '' ? 0 : int.parse(textControllers['$i$j']!.text);
                      }
                    }
                    solveSudoku();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black,
                    foregroundColor: Colors.white,
                    // minimumSize: const Size(200, 50),
                    maximumSize: const Size(150, 50),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.calculate),
                      const SizedBox(width: 10),
                      Text('Solve', style: GoogleFonts.lato(),),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Column buildSmallestColumn(int xOffset, int yOffset) {
    return Column(
                          children: [
                            Flexible(
                              flex: 1,
                              child: buildSmallestRow(xOffset, yOffset),
                            ),
                            Flexible(
                              flex: 1,
                              child: Container(
                                decoration: const BoxDecoration(
                                  border: Border(
                                    top: BorderSide(color: Colors.black26),
                                    bottom: BorderSide(color: Colors.black26),
                                  )
                                ),
                                child: buildSmallestRow(xOffset + 1, yOffset),
                              ),
                            ),
                            Flexible(
                              flex: 1,
                              child: Container(
                                child: buildSmallestRow(xOffset + 2, yOffset),
                              ),
                            ),
                          ],
                        );
  }

  Row buildSmallestRow(int xOffset, int yOffset) {
    return Row(
                                children: [
                                  Flexible(
                                    flex: 1,
                                    child: buildTextField(xOffset, yOffset),
                                  ),
                                  Flexible(
                                    flex: 1,
                                    child: Container(
                                      decoration: const BoxDecoration(
                                        border: Border(
                                          right: BorderSide(color: Colors.black26),
                                          left: BorderSide(color: Colors.black26),
                                        ),
                                      ),
                                      child: buildTextField(xOffset, yOffset + 1),
                                    ),
                                  ),
                                  Flexible(
                                    flex: 1,
                                    child: Container(
                                      child: buildTextField(xOffset, yOffset + 2)
                                    ),
                                  ),
                                ],
                              );
  }

  Center buildTextField(int i, int j) {
    return Center(
                                    child: Padding(
                                      padding: (Responsive.isMobile(context)) ? const EdgeInsets.only(bottom: 5.0) : EdgeInsets.zero,
                                      child: TextFormField(
                                        cursorHeight: 20,
                                        controller: textControllers['$i$j'],
                                        enabled: isEnabled,
                                        keyboardType: TextInputType.number,
                                        inputFormatters: [
                                          FilteringTextInputFormatter.allow(RegExp(r'[1-9]')),
                                          LengthLimitingTextInputFormatter(1),
                                        ],
                                        textAlign: TextAlign.center,
                                        decoration: const InputDecoration(
                                          border: InputBorder.none,
                                        ),
                                        style: isEnabled ? GoogleFonts.lato(
                                          fontSize: 20,
                                          fontWeight: FontWeight.bold,
                                        ) : GoogleFonts.lato(
                                          fontSize: 20,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.black,
                                        ),
                                        onFieldSubmitted: (value) {
                                          grid[i][j] = int.parse(value);
                                        },
                                      ),
                                    ),
                                  );
  }
}
