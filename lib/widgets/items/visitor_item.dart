import 'package:flutter/material.dart';
import '../../models/visitor.dart';

class VisitorItem extends StatelessWidget {
  final Visitor visitor;
  final VoidCallback? onMorePressed;

  const VisitorItem({Key? key, required this.visitor, this.onMorePressed})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 15),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  visitor.name,
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                ),
                Text(
                  visitor.type,
                  style: TextStyle(fontSize: 13, color: Colors.grey[600]),
                ),
                Text(
                  visitor.homeNumber,
                  style: TextStyle(fontSize: 12, color: Colors.grey[500]),
                ),
                Text(
                  'Entrada: ${visitor.startingHour}',
                  style: TextStyle(fontSize: 12, color: Colors.grey[500]),
                ),
              ],
            ),
          ),
          Row(
            children: [
              Container(
                padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: visitor.status == "ACTIVO"
                      ? Color(0xFF4A90A4)
                      : Colors.grey[400],
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Text(
                  visitor.status,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              SizedBox(width: 10),
              GestureDetector(
                onTap: onMorePressed,
                child: Icon(Icons.more_vert, color: Colors.grey[600]),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
