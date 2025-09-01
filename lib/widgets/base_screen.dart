import 'package:flutter/material.dart';
import 'headers/custom_header.dart';

class BaseScreen extends StatelessWidget {
  final String title;
  final Widget child;
  final VoidCallback? onMenuPressed;
  final VoidCallback? onNotificationPressed;

  const BaseScreen({
    Key? key,
    required this.title,
    required this.child,
    this.onMenuPressed,
    this.onNotificationPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF2C3E50),
      body: SafeArea(
        child: Container(
          margin: EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            children: [
              CustomHeader(
                title: title,
                onMenuPressed: onMenuPressed,
                onNotificationPressed: onNotificationPressed,
              ),
              Expanded(child: child),
            ],
          ),
        ),
      ),
    );
  }
}
