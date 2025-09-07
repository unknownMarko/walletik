import 'package:flutter/material.dart';

class CardsScreen extends StatefulWidget {
  const CardsScreen({super.key});

  @override
  CardsScreenState createState() => CardsScreenState();
}

class CardsScreenState extends State<CardsScreen> {
  @override
  Widget build(BuildContext context) {
    return Center(child: Text('Cards', style: TextStyle(fontSize: 24)));
  }
}
