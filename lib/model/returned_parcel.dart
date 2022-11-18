class ReturnedParcel {
  late int id;
  String? roNum;
  String? shpmtNum;
  String? logisticsCompany;
  String? status;
  int? operatorId;
  String? operator;
  List? returnedSku;
  int? outboundOrderId;
  String? batchNum;
  String? orderNum;
  int? accountId;
  List? attachment;
  String? account;
  String? depotCode;
  String? agentDepot;
  String? returnReason;
  String? handleResult;
  String? disposal;
  String? disposalResult;
  String? disposalMemo;
  String? disposalInfo;
  String? photoMemo;
  bool? unpackPhoto;
  bool? isBroken;
  bool? isOpen;
  Map? disposalVas;

  ReturnedParcel(this.id,
      {this.roNum,
      this.shpmtNum,
      this.logisticsCompany,
      this.status,
      this.operatorId,
      this.operator,
      this.returnedSku,
      this.outboundOrderId,
      this.batchNum,
      this.orderNum,
      this.accountId,
      this.attachment,
      this.account,
      this.depotCode,
      this.agentDepot,
      this.returnReason,
      this.handleResult,
      this.disposal,
      this.disposalResult,
      this.disposalMemo,
      this.disposalInfo,
      this.photoMemo,
      this.unpackPhoto,
      this.isBroken,
      this.disposalVas,
      this.isOpen});

  ReturnedParcel.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    roNum = json['ro_num'];
    shpmtNum = json['shpmt_num'];
    logisticsCompany = json['logistics_company'];
    status = json['status'];
    operatorId = json['operator_id'];
    operator = json['operator'];
    returnedSku = json['returned_skus'];
    outboundOrderId = json['outbound_order_id'];
    batchNum = json['batch_num'];
    orderNum = json['order_num'];
    accountId = json['account_id'];
    attachment = json['attachment'];
    account = json['account'];
    depotCode = json['depot_code'];
    agentDepot = json['agent_depot'];
    returnReason = json['return_reason'];
    handleResult = json['handle_result'];
    disposal = json['disposal'];
    disposalResult = json['disposal_result'];
    disposalMemo = json['disposal_memo'];
    disposalInfo = json['disposal_info'];
    photoMemo = json['photo_memo'];
    unpackPhoto = json['unpack_photo'];
    isBroken = json['is_broken'];
    isOpen = json['is_open'];
    disposalVas = json['disposal_vas'];
  }
}
