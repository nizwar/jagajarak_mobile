import 'package:flutter/material.dart';

class ColumnDivider extends StatelessWidget {
  final double space;

  const ColumnDivider({Key key, this.space}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Container(
      height: space ?? 10,
    );
  }
}

class RowDivider extends StatelessWidget {
  final double space;

  const RowDivider({Key key, this.space}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Container(
      width: space ?? 10,
    );
  }
}
