import 'package:flutter/material.dart';
import '/models/property.dart';
import '/widgets/base_screen.dart';
import '/widgets/items/property_item.dart';

class PropertiesScreen extends StatefulWidget {
  @override
  _PropertiesScreenState createState() => _PropertiesScreenState();
}

class _PropertiesScreenState extends State<PropertiesScreen> {
  final List<Property> properties = [
    Property(name: "Casa 101", owner: "Luisa", status: "Ocupado"),
    Property(name: "Casa 102", owner: "Luisa", status: "Libre"),
    Property(name: "Casa 103", owner: "Luisa", status: "Ocupado"),
    Property(name: "Casa 104", owner: "Luisa", status: "Ocupado"),
    Property(name: "Casa 105", owner: "Luisa", status: "Ocupado"),
    Property(name: "Casa 101", owner: "Luisa", status: "Ocupado"),
    Property(name: "Casa 106", owner: "Luisa", status: "Libre"),
    Property(name: "Casa 107", owner: "Luisa", status: "Libre"),
  ];

  void _onMenuPressed() {
    print("Menú presionado en Propiedades");
  }

  void _onNotificationPressed() {
    print("Notificaciones presionadas en Propiedades");
  }

  void _onPropertyPressed(Property property) {
    print("Propiedad seleccionada: ${property.name}");
  }

  @override
  Widget build(BuildContext context) {
    return BaseScreen(
      title: 'PROPIEDADES',
      onMenuPressed: _onMenuPressed,
      onNotificationPressed: _onNotificationPressed,
      child: ListView.builder(
        padding: EdgeInsets.all(20),
        itemCount: properties.length,
        itemBuilder: (context, index) {
          final property = properties[index];
          return PropertyItem(
            property: property,
            onTap: () => _onPropertyPressed(property),
          );
        },
      ),
    );
  }
}
