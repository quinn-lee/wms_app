class ReturnedParcel {
  late int id;
  String? roNum;
  String? shpmtNum;
  String? logisticsCompany;
  String? status;
  int? operatorId;
  String? operator;
  int? outboundOrderId;
  String? batchNum;
  String? orderNum;
  int? accountId;
  String? account;
  String? depotCode;
  String? agentDepot;
  String? returnReason;
  String? handleResult;
  String? disposal;
  String? disposalResult;
  String? disposalMemo;
  String? photoMemo;

  ReturnedParcel(this.id,
      {this.roNum,
      this.shpmtNum,
      this.logisticsCompany,
      this.status,
      this.operatorId,
      this.operator,
      this.outboundOrderId,
      this.batchNum,
      this.orderNum,
      this.accountId,
      this.account,
      this.depotCode,
      this.agentDepot,
      this.returnReason,
      this.handleResult,
      this.disposal,
      this.disposalResult,
      this.disposalMemo,
      this.photoMemo});

  ReturnedParcel.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    roNum = json['ro_num'];
    shpmtNum = json['shpmt_num'];
    logisticsCompany = json['logistics_company'];
    status = json['status'];
    operatorId = json['operator_id'];
    operator = json['operator'];
    outboundOrderId = json['outbound_order_id'];
    batchNum = json['batch_num'];
    orderNum = json['order_num'];
    accountId = json['account_id'];
    account = json['account'];
    depotCode = json['depot_code'];
    agentDepot = json['agent_depot'];
    returnReason = json['return_reason'];
    handleResult = json['handle_result'];
    disposal = json['disposal'];
    disposalResult = json['disposal_result'];
    disposalMemo = json['disposal_memo'];
    photoMemo = json['photo_memo'];
  }
}
