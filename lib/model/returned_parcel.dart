class ReturnedParcel {
  late int id;
  String? ro_num;
  String? shpmt_num;
  String? logistics_company;
  String? status;
  int? operator_id;
  String? operator;
  String? created_at;
  String? updated_at;
  String? received_at;
  int? outbound_order_id;
  String? batch_num;
  String? order_num;
  int? account_id;
  String? account;
  String? depot_code;
  String? agent_depot;
  String? return_reason;
  String? handle_result;
  String? disposal;
  String? disposal_result;
  String? disposal_memo;

  ReturnedParcel(
    this.id, {
    this.ro_num,
    this.shpmt_num,
    this.logistics_company,
    this.status,
    this.operator_id,
    this.operator,
    this.created_at,
    this.updated_at,
    this.received_at,
    this.outbound_order_id,
    this.batch_num,
    this.order_num,
    this.account_id,
    this.account,
    this.depot_code,
    this.agent_depot,
    this.return_reason,
    this.handle_result,
    this.disposal,
    this.disposal_result,
    this.disposal_memo,
  });

  ReturnedParcel.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    ro_num = json['ro_num'];
    shpmt_num = json['shpmt_num'];
    logistics_company = json['logistics_company'];
    status = json['status'];
    operator_id = json['operator_id'];
    operator = json['operator'];
    created_at = json['created_at'];
    updated_at = json['updated_at'];
    received_at = json['received_at'];
    outbound_order_id = json['outbound_order_id'];
    batch_num = json['batch_num'];
    order_num = json['order_num'];
    account_id = json['account_id'];
    account = json['account'];
    depot_code = json['depot_code'];
    agent_depot = json['agent_depot'];
    return_reason = json['return_reason'];
    handle_result = json['handle_result'];
    disposal = json['disposal'];
    disposal_result = json['disposal_result'];
    disposal_memo = json['disposal_memo'];
  }
}
