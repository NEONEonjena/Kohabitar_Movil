import 'package:flutter/material.dart';
import '../../models/property.dart';

class PropertyItem extends StatelessWidget {
  final Property property;
  final VoidCallback? onTap;

  const PropertyItem({
    Key? key,
    required this.property,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: EdgeInsets.only(bottom: 15),
        child: Row(
          children: [
            // Icono de casa
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: Color(0xFF4A90A4),
                borderRadius: BorderRadius.circular(25),
              ),
              child: Icon(
                Icons.home,
                color: Colors.white,
                size: 25,
              ),
            ),
            SizedBox(width: 15),
            // Información de la propiedad
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    property.name,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Text(
                    'Propietario: ${property.owner}',
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
            // Estado
            Container(
              padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: property.status == "Ocupado"
                    ? Color(0xFF4A90A4)
                    : Color(0xFF7ED321),
                borderRadius: BorderRadius.circular(15),
              ),
              child: Text(
                property.status.toUpperCase(),
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
