import 'package:flutter/material.dart';
import '../widgets/background_logo.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  SearchScreenState createState() => SearchScreenState();
}

class SearchScreenState extends State<SearchScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: BackgroundLogo(
        child: SafeArea(
          child: const Center(child: Text('Search', style: TextStyle(fontSize: 24))),
        ),
      ),
    );
  }
}
