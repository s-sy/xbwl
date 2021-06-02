import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';

class Agreement extends StatefulWidget {
  final String agreementKey;

  const Agreement({Key key, this.agreementKey}) : super(key: key);
  @override
  _AgreementState createState() => _AgreementState();
}

class _AgreementState extends State<Agreement> {
  String title = "";
  String agreementDetails = "";
  @override
  void initState() {
    super.initState();
    if (widget.agreementKey == "用户协议") {
      title = "用户协议";
      agreementDetails = "";
    } else if (widget.agreementKey == "隐私政策") {
      title = "隐私政策";
      agreementDetails = "";
    }
  }

  // htmlValue(String value) {
  //   Widget html = Html(
  //     data: "" + '' + "",
  //   );
  //   return html;
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: Text(title, style: TextStyle(color: Colors.grey[700])),
          elevation: 0.0,
          brightness: Brightness.light,
          backgroundColor: Colors.white,
          iconTheme: IconThemeData(color: Colors.grey[700])),
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(15.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("data"),
            ],
          ),
        ),
      ),
    );
  }
}
