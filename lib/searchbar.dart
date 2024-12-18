import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class SearchBar extends StatelessWidget {
  final String hintText;
  final ValueChanged<String> onSubmitted;

  const SearchBar({required this.hintText, required this.onSubmitted, Key? key})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TextField(
      decoration: InputDecoration(
        hintText: hintText,
        border: OutlineInputBorder(),
        suffixIcon: Icon(Icons.search),
      ),
      onSubmitted: onSubmitted,
    );
  }
}
