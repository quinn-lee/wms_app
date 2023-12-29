class ReturnedSku {
  String? skuCode;
  String? barcode;
  String? name;
  String? foreignName;
  int? quantity;
  String? defaultPackingMaterial;
  String? shortCode;
  int? inventoryQuantity;
  String? currentShelf;

  ReturnedSku(
      {this.skuCode,
      this.barcode,
      this.name,
      this.foreignName,
      this.quantity,
      this.shortCode,
      this.inventoryQuantity,
      this.currentShelf,
      this.defaultPackingMaterial});

  ReturnedSku.fromJson(Map<String, dynamic> json) {
    skuCode = json['sku_code'];
    barcode = json['barcode'];
    name = json['name'];
    foreignName = json['foreign_name'];
    quantity = json['quantity'];
    defaultPackingMaterial = json['default_packing_material'];
    shortCode = json['short_code'];
    inventoryQuantity = json['inventory_quantity'];
    currentShelf = json['current_shelf'];
  }
}
