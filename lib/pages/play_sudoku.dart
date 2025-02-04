import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sudoku_solver/algorithm/dlx_solver.dart';

import '../responsive/responsive_layout.dart';

class PlaySudoku extends StatefulWidget {
  const PlaySudoku({super.key});

  @override
  State<PlaySudoku> createState() => _PlaySudokuState();
}

class _PlaySudokuState extends State<PlaySudoku> {
  final Map<String, TextEditingController> textControllers = {};
  final List<List<int>> grid = List.generate(9, (_) => List.generate(9, (_) => 0));
  late List<List<int>> solution;
  final Set<String> wrongCells = {};
  final Map<String, bool> isEnabled = {};
  late final Timer timer;
  Duration time = const Duration();
  int mistakes = 0;
  bool timerRunning = false;

  void initSudoku() {
    for(int i=0; i<9; i++) {
      for(int j=0; j<9; j++) {
        grid[i][j] = 0;
        textControllers['$i$j']!.text = '';
        isEnabled['$i$j'] = true;
      }
    }
    setState(() {
      timerRunning = true;
      mistakes = 0;
      time = Duration.zero;
    });
    wrongCells.clear();
    Random rand = Random();
    int x = rand.nextInt(9);
    int y = rand.nextInt(9);
    int value = rand.nextInt(9) + 1;
    grid[x][y] = value;
    GridSolver solver = GridSolver(grid);
    solution = solver.solve();

    for(int i=0; i<9; i++) {
      int t1 = rand.nextInt(9);
      int t2 = rand.nextInt(9);
      grid[i][t1] = solution[i][t1];
      grid[i][t2] = solution[i][t2];
      textControllers['$i$t1']!.text = solution[i][t1].toString();
      textControllers['$i$t2']!.text = solution[i][t2].toString();
      isEnabled['$i$t1'] = false;
      isEnabled['$i$t2'] = false;
    }
  }

  void checkSudoku() {
    bool solved = true;
    for(int i=0; i<9; i++) {
      for(int j=0; j<9; j++) {
        if(grid[i][j] != solution[i][j]) {
          solved = false;
          break;
        }
      }
      if(!solved) {
        break;
      }
    }

    if(solved) {
      setState(() {
        timerRunning = false;
      });
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text('Congratulations', style: GoogleFonts.lato(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.green.shade600),),
            content: Text('You have solved the sudoku puzzle in ${time.inMinutes.remainder(60).toString().padLeft(2, '0')}:${time.inSeconds.remainder(60).toString().padLeft(2, '0')}.', style: GoogleFonts.lato()),
            actions: [
              TextButton(
                onPressed: () {
                  timer.cancel();
                  Navigator.pop(context);
                  Navigator.pop(context);
                },
                child: Text('Exit', style: GoogleFonts.lato()),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  setState(() {
                    initSudoku();
                  });
                },
                child: Text('Play Again', style: GoogleFonts.lato()),
              )
            ],
          );
        },
      );
    }

    if(mistakes == 5) {
      setState(() {
        timerRunning = false;
      });
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text('Game Over', style: GoogleFonts.lato(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.red.shade600),),
            content: Text('You have made 5 mistakes. Your time is ${time.inMinutes.remainder(60).toString().padLeft(2, '0')}:${time.inSeconds.remainder(60).toString().padLeft(2, '0')}.', style: GoogleFonts.lato()),
            actions: [
              TextButton(
                onPressed: () {
                  timer.cancel();
                  Navigator.pop(context);
                  Navigator.pop(context);
                },
                child: Text('Exit', style: GoogleFonts.lato()),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  setState(() {
                    initSudoku();
                  });
                },
                child: Text('Play Again', style: GoogleFonts.lato()),
              )
            ],
          );
        },
      );
    }
  }

  @override
  void dispose() {
    super.dispose();
    timer.cancel();
  }

  @override
  void initState() {
    super.initState();
    for (int i = 0; i < 9; i++) {
      for (int j = 0; j < 9; j++) {
        textControllers['$i$j'] = TextEditingController();
        isEnabled['$i$j'] = true;
      }
    }
    time = Duration.zero;
    timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        if(timerRunning) time += const Duration(seconds: 1);
      });
    });

    initSudoku();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              IconButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                icon: const Icon(Icons.arrow_back_ios, color: Colors.black),
              ),
              const SizedBox(width: 10),
              Text('sudokuDLX', style: GoogleFonts.lato(fontSize: 24, fontWeight: FontWeight.bold)),
            ],
          ),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: (Responsive.isMobile(context)) ? MediaQuery.of(context).size.width * 0.95 : MediaQuery.of(context).size.height * 0.7,
                  padding: const EdgeInsets.all(10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Mistakes: $mistakes/5', style: GoogleFonts.lato(fontSize: 20, fontWeight: FontWeight.bold)),
                      Text('Time: ${time.inMinutes.remainder(60).toString().padLeft(2, '0')}:${time.inSeconds.remainder(60).toString().padLeft(2, '0')}', style: GoogleFonts.lato(fontSize: 20, fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
                const SizedBox(height: 10,),
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
                const SizedBox(height: 10,),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    IconButton(
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder: (context) {
                            return AlertDialog(
                              title: Text('Reset?', style: GoogleFonts.lato(fontSize: 24, fontWeight: FontWeight.bold),),
                              content: Text('Do you want to reset the game?', style: GoogleFonts.lato()),
                              actions: [
                                TextButton(
                                  onPressed: () {
                                    Navigator.pop(context);
                                  },
                                  child: const Text('No'),
                                ),
                                TextButton(
                                  onPressed: () {
                                    Navigator.pop(context);
                                    initSudoku();
                                  },
                                  child: const Text('Yes'),
                                )
                              ],
                            );
                          },
                        );
                      },
                      icon: const Icon(Icons.refresh_rounded, color: Colors.black),
                    )
                  ],
                )
              ],
            ),
          ),
        ],
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
          enabled: isEnabled['$i$j'],
          keyboardType: TextInputType.number,
          inputFormatters: [
            FilteringTextInputFormatter.allow(RegExp(r'[1-9]')),
            LengthLimitingTextInputFormatter(1),
          ],
          textAlign: TextAlign.center,
          decoration: const InputDecoration(
            border: InputBorder.none,
          ),
          style: GoogleFonts.lato(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: (isEnabled['$i$j']!) ? ((wrongCells.contains('$i$j')) ? Colors.red : Colors.black) : Colors.blue.shade900,
          ),
          onFieldSubmitted: (value) {
            grid[i][j] = int.parse(value);
          },
          onChanged: (value) {
            if(value.isNotEmpty) {
              if(value != solution[i][j].toString()) {
                setState(() {
                  wrongCells.add('$i$j');
                  mistakes++;
                });
              } else {
                setState(() {
                  wrongCells.remove('$i$j');
                });
              }
              checkSudoku();
            }
          },
        ),
      ),
    );
  }
}
