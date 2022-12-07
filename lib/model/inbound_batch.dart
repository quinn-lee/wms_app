class InboundBatch {
  late int id;
  String? inboundNum;
  String? abbrCode;
  String? inboundType;
  int? priority;
  String? priorityMemo;
  String? batchNum;
  String? status;
  List? operatorIds;
  List? operators;
  String? referNum;
  String? registrarEmail;
  String? registrarId;
  String? createdAt;
  String? updatedAt;
  bool? canDelete;
  bool? onlyProblemSku;
  List? inboundBatchSkus;

  InboundBatch(this.id,
      {this.inboundNum,
      this.abbrCode,
      this.inboundType,
      this.priority,
      this.priorityMemo,
      this.batchNum,
      this.status,
      this.operatorIds,
      this.operators,
      this.referNum,
      this.registrarEmail,
      this.registrarId,
      this.createdAt,
      this.updatedAt,
      this.canDelete,
      this.onlyProblemSku,
      this.inboundBatchSkus});

  InboundBatch.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    inboundNum = json['inbound_num'];
    abbrCode = json['abbr_code'];
    inboundType = json['inbound_type'];
    priority = json['priority'];
    priorityMemo = json['priority_memo'];
    batchNum = json['batch_num'];
    status = json['status'];
    operatorIds = json['operator_ids'];
    operators = json['operators'];
    referNum = json['refer_num'];
    registrarEmail = json['registrar_email'];
    registrarId = json['registrar_id'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
    canDelete = json['can_delete'];
    onlyProblemSku = json['only_problem_sku'];
    inboundBatchSkus = json['inbound_batch_skus'];
  }
}
