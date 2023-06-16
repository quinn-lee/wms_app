import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:wms_app/core/hi_state.dart';
import 'package:wms_app/http/dao/check_dao.dart';
import 'package:wms_app/util/string_util.dart';
import 'package:wms_app/util/toast.dart';
import 'package:wms_app/widget/loading_container.dart';
import 'package:wms_app/widget/login_button.dart';
import 'package:wms_app/widget/scan_input.dart';

class InventoryCheckOperatePage extends StatefulWidget {
  final String shelfNum;
  final List skus;
  const InventoryCheckOperatePage(this.shelfNum, this.skus, {Key? key})
      : super(key: key);

  @override
  State<InventoryCheckOperatePage> createState() =>
      _InventoryCheckOperatePageState();
}

class _InventoryCheckOperatePageState
    extends HiState<InventoryCheckOperatePage> {
  String? num;
  int quantity = 0;
  String? currentAmount;
  final TextEditingController textEditingController = TextEditingController();
  FocusNode focusNode = FocusNode();
  final TextEditingController textEditingController1 = TextEditingController();
  FocusNode focusNode1 = FocusNode();
  bool submitEnable = false;
  List<Map> resultShow = [];
  List? skus;
  AudioCache player = AudioCache();
  bool _isLoading = false;
  List<DataRow> dataRows = [];

  @override
  void initState() {
    super.initState();
    setState(() {
      skus = widget.skus;
      currentAmount = "";
      setDataRow(skus!);
    });

    textEditingController1.text = "";
  }

  @override
  void dispose() {
    focusNode.dispose();
    textEditingController.dispose();
    focusNode1.dispose();
    textEditingController1.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('Sku Scan(${widget.shelfNum})'),
          leading: GestureDetector(
            onTap: () {
              Navigator.pop(context);
            },
            child: const Icon(Icons.arrow_back),
          ),
        ),
        body: LoadingContainer(
          cover: true,
          isLoading: _isLoading,
          child: ListView(
            children: _buildWidget(),
          ),
        ));
  }

  List<Widget> _buildWidget() {
    List<Widget> widgets = [];
    widgets.add(ScanInput(
      "Sku",
      "Scan Sku Number",
      focusNode,
      textEditingController,
      onChanged: (text) {
        num = text;
      },
      onSubmitted: (text) {
        _assignData();
        checkInput();
      },
    ));
    widgets.add(const Divider(
      thickness: 32,
      color: Color(0XFFEEEEEE),
      height: 30,
    ));
    widgets.add(ListTile(title: Text("Current Amount: ${currentAmount!}")));
    widgets.add(ScanInput(
      "Total Amount",
      "",
      focusNode1,
      textEditingController1,
      onChanged: (text) {
        try {
          if (isNotEmpty(text) && text != "") {
            quantity = int.parse(text);
          } else {
            quantity = 0;
          }
        } catch (e) {
          quantity = 0;
        }
        checkInput();
      },
    ));

    widgets.add(Padding(
      padding: const EdgeInsets.only(left: 20, right: 20, top: 20),
      child: LoginButton(
        'Submit',
        1,
        enable: submitEnable,
        onPressed: operate,
      ),
    ));

    for (var element in resultShow.reversed) {
      widgets.add(ListTile(
        title: Text(
          element['show'],
          style: const TextStyle(color: Colors.white),
        ),
        tileColor: element['status']
            ? const Color(0xFF4e72b8)
            : const Color(0xFFf15b6c),
      ));
      widgets.add(const Divider(
        height: 1,
        color: Colors.white,
      ));
    }
    widgets.add(DataTable(columns: const [
      DataColumn(label: Text('Sku Code')),
      DataColumn(
        label: Text('Name'),
      ),
      DataColumn(
        label: Text('Quantity'),
      ),
    ], rows: dataRows));
    return widgets;
  }

  // 扫码后赋值给不同的变量
  void _assignData() {
    setState(() {
      currentAmount = "0";
    });
    for (var sku in skus!) {
      if (sku['sku_code'] == num!) {
        setState(() {
          currentAmount = sku['quantity'].toString();
        });
      }
    }
    if (mounted) {
      textEditingController1.text = "";
      FocusScope.of(context).requestFocus(focusNode1);
    }
  }

  // 构建表格数据
  void setDataRow(List<dynamic> data) {
    dataRows.clear();
    for (int i = 0; i < data.length; i++) {
      dataRows.add(DataRow(
        cells: [
          DataCell(Text('${data[i]['sku_code']}')),
          DataCell(Text('${data[i]['name_en']}')),
          DataCell(Text('${data[i]['quantity']}')),
        ],
      ));
    }
  }

  // 验证输入是否可以提交
  void checkInput() {
    bool enable;
    if (isNotEmpty(num) && quantity > 0) {
      enable = true;
    } else {
      enable = false;
    }
    setState(() {
      submitEnable = enable;
    });
  }

  // 提交
  void operate() async {
    dynamic result;
    setState(() {
      submitEnable = false; // 防止重复提交
      _isLoading = true;
    });
    try {
      if (num != null && num != "") {
        List newSkus = [
          {"sku_code": num, "quantity": quantity}
        ];
        var result = await CheckDao.operate(widget.shelfNum, newSkus);
        // print('loadData():$result');
        if (result['status'] == "succ") {
          setState(() {
            _isLoading = false;
            skus = result['data']['skus'];
            setDataRow(skus!);
            resultShow.add({
              "status": true,
              "show":
                  "Submit Success ! Sku Num : ${num ?? ''} , quantity : $quantity"
            });
          });
          player.play('sounds/success01.mp3');
        } else {
          // print(result['reason']);
          showWarnToast(result['reason'].join(","));
          setState(() {
            _isLoading = false;
            resultShow
                .add({"status": false, "show": result['reason'].join(",")});
          });
          player.play('sounds/alert.mp3');
        }
      } else {
        setState(() {
          _isLoading = false;
        });
      }
    } catch (e) {
      showWarnToast(e.toString());
      setState(() {
        _isLoading = false;
        resultShow.add({"status": false, "show": e.toString()});
      });
      player.play('sounds/alert.mp3');
    }
    if (mounted) {
      textEditingController.clear();
      textEditingController1.text = "";
      FocusScope.of(context).requestFocus(focusNode);
    }
    setState(() {
      quantity = 0;
      currentAmount = "";
    });
  }
}
