import 'package:flutter/material.dart';

class Sudoku extends StatefulWidget {
  const Sudoku({super.key});

  @override
  State<Sudoku> createState() => _SudokuState();
}

class _SudokuState extends State<Sudoku> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sudoku'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: MediaQuery.of(context).size.width * 0.95,
              height: MediaQuery.of(context).size.width * 0.95,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.black),
              ),
              child: Column(
                children: [
                  Flexible(
                    flex: 1,
                    child: Row(
                      children: [
                        Flexible(
                          flex: 1,
                          child: Container(
                          ),
                        ),
                        Flexible(
                          flex: 1,
                          child: Container(
                            decoration: const BoxDecoration(
                              border: Border(
                                right: BorderSide(color: Colors.black),
                                left: BorderSide(color: Colors.black),
                              ),
                            ),
                          ),
                        ),
                        Flexible(
                          flex: 1,
                          child: Container(
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
                          top: BorderSide(color: Colors.black),
                          bottom: BorderSide(color: Colors.black),
                        ),
                      ),
                      child: Row(
                        children: [
                          Flexible(
                            flex: 1,
                            child: Container(
                            ),
                          ),
                          Flexible(
                            flex: 1,
                            child: Container(
                              decoration: const BoxDecoration(
                                border: Border(
                                  right: BorderSide(color: Colors.black),
                                  left: BorderSide(color: Colors.black),
                                ),
                              ),
                            ),
                          ),
                          Flexible(
                            flex: 1,
                            child: Container(
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
                            ),
                          ),
                          Flexible(
                            flex: 1,
                            child: Container(
                              decoration: const BoxDecoration(
                                border: Border(
                                  right: BorderSide(color: Colors.black),
                                  left: BorderSide(color: Colors.black),
                                ),
                              ),
                            ),
                          ),
                          Flexible(
                            flex: 1,
                            child: Container(
                            ),
                          ),
                        ],
                      )
                  ),
                ],
              )
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {},
              child: const Text('Solve'),
            ),
          ],
        ),
      ),
    );
  }
}
