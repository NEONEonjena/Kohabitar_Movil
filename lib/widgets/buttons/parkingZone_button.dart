import 'package:flutter/material.dart';

class ParkingZoneButton extends StatelessWidget {
  final String title;
  final VoidCallback? onTap;
  final Color? color;

  const ParkingZoneButton({
    Key? key,
    required this.title,
    this.onTap,
    this.color,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 100,
        decoration: BoxDecoration(
          color: color ?? Color(0xFF5A9B9B),
          borderRadius: BorderRadius.circular(15),
        ),
        child: Center(
          child: Text(
            title,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }
}
