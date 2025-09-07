import 'package:flutter/material.dart';

class AddCardScreen extends StatefulWidget {
  const AddCardScreen({super.key});

  @override
  AddCardScreenState createState() => AddCardScreenState();
}

class AddCardScreenState extends State<AddCardScreen> {
  @override
  Widget build(BuildContext context) {
    return Center(child: Text('Add Card', style: TextStyle(fontSize: 24)));
  }
}