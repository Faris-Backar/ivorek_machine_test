import 'package:flutter/material.dart';
import 'package:ivorek_machine_test/app/presentation/home/home_screen.dart';

class IvorekMachineTest extends StatelessWidget {
  const IvorekMachineTest({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: HomeScreen(),
    );
  }
}
