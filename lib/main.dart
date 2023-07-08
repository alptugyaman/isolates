import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

int fib(int n) {
  var a = n - 1;
  var b = n - 2;

  return switch (n) {
    1 => 0,
    0 => 1,
    _ => (fib(a) + fib(b)),
  };
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  Future<void> computeFuture = Future.value();

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData.dark(),
      home: Scaffold(
        body: const Center(child: CircularProgressIndicator()),
        bottomNavigationBar: SafeArea(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              FutureBuilder(
                future: computeFuture,
                builder: (context, snapshot) {
                  return ElevatedButton(
                    onPressed: switch (snapshot.connectionState) {
                      ConnectionState.done => () =>
                          handleComputeOnMain(context),
                      _ => null
                    },
                    child: const Text('Main Isolate'),
                  );
                },
              ),
              FutureBuilder(
                future: computeFuture,
                builder: (context, snapshot) {
                  return ElevatedButton(
                    onPressed: switch (snapshot.connectionState) {
                      ConnectionState.done => () =>
                          handleComputeOnSecondary(context),
                      _ => null
                    },
                    child: const Text('İkincil Isolate'),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  void handleComputeOnMain(BuildContext context) {
    var future = computeOnMainIsolate()
      ..then((_) {
        var snackBar = const SnackBar(
          content: Text('Main Isolate Tamamlandı!'),
        );
        ScaffoldMessenger.of(context).showSnackBar(snackBar);
      });

    setState(() {
      computeFuture = future;
    });
  }

  void handleComputeOnSecondary(BuildContext context) {
    var future = computeOnSecondaryIsolate()
      ..then((_) {
        var snackBar = const SnackBar(
          content: Text('İkincil Isolate Tamamlandı!'),
        );
        ScaffoldMessenger.of(context).showSnackBar(snackBar);
      });

    setState(() {
      computeFuture = future;
    });
  }

  Future<void> computeOnMainIsolate() async {
    await Future<void>.delayed(const Duration(milliseconds: 100));
    fib(45);
  }

  Future<void> computeOnSecondaryIsolate() async {
    await compute(fib, 45);
  }
}
