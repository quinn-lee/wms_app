class FbaDetachSku {
  late int id;
  int? accountId;
  String? account;
  String? skuCode;
  String? name;
  String? foreignName;
  String? length;
  String? width;
  String? height;
  String? weight;

  FbaDetachSku(this.id,
      {this.accountId,
      this.account,
      this.skuCode,
      this.name,
      this.foreignName,
      this.length,
      this.width,
      this.height,
      this.weight});

  FbaDetachSku.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    accountId = json['account_id'];
    account = json['account'];
    skuCode = json['sku_code'];
    name = json['name'];
    foreignName = json['foreign_name'];
    length = json['measured_length'];
    width = json['measured_width'];
    height = json['measured_height'];
    weight = json['measured_weight'];
  }
}
