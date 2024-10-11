import 'package:flutter/material.dart';

class POSItemView<T> extends StatelessWidget {
  final T item;
  const POSItemView({Key key, this.item}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Container(),
    );
  }
}
