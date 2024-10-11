class Warehouse {
  String id;
  String name;
  String warehouseType;

  Warehouse({this.id, this.name, this.warehouseType});

  factory Warehouse.fromMap(var data) {
    return Warehouse(
        id: data['id'],
        name: data['name'],
        warehouseType: data['warehouseType']);
  }
}
