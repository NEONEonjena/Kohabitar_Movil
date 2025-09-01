import 'package:flutter/material.dart';
import '../../models/user.dart';

class UserItem extends StatelessWidget {
  final User user;
  final VoidCallback? onMorePressed;

  const UserItem({Key? key, required this.user, this.onMorePressed})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: Colors.grey[300]!, width: 1)),
      ),
      child: ListTile(
        contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        leading: CircleAvatar(
          radius: 25,
          backgroundColor: Color(0xFF5A9B9B),
          child: Icon(Icons.person, color: Colors.white, size: 25),
        ),
        title: Text(
          user.name,
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              user.role,
              style: TextStyle(fontSize: 13, color: Colors.grey[600]),
            ),
            SizedBox(height: 2),
            Text(
              user.status,
              style: TextStyle(
                fontSize: 12,
                color: user.status == "Activo" ? Colors.green : Colors.red,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        trailing: GestureDetector(
          onTap: onMorePressed,
          child: Icon(Icons.more_vert, color: Colors.grey[600]),
        ),
      ),
    );
  }
}
