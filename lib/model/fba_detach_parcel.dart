class FbaDetachParcel {
  late int id;
  String? createdAt;
  String? updatedAt;
  String? category;
  String? status;
  String? identifier;
  int? accountId;
  String? account;

  FbaDetachParcel(this.id,
      {this.createdAt,
      this.updatedAt,
      this.category,
      this.status,
      this.identifier,
      this.accountId,
      this.account});

  FbaDetachParcel.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
    category = json['category'];
    status = json['status'];
    identifier = json['identifier'];
    accountId = json['account_id'];
    account = json['account'];
  }
}
