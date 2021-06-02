import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_ui/application/coustomer/coustomer_bloc.dart';
import 'package:flutter_ui/presentation/routes/router.gr.dart';

class FollowUpRecord extends StatefulWidget {
  //  Map<String, dynamic> listData;
  // FollowUpRecord({Key key, this.listData}) : super(key: key);

  @override
  _FollowUpRecordState createState() => _FollowUpRecordState();
}

class _FollowUpRecordState extends State<FollowUpRecord> {
  int _currentStep = 0;
  int count = 0;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocConsumer<CoustomerBloc, CoustomerState>(
        listener: (context, state) {},
        builder: (context, state) {
          if (this.count == 0 && state.history.length > 0) {
            count++;
            this._currentStep =
                state.history.length > 0 ? state.history.length - 1 : 0;
          }

          return Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              //头部，记录/来电/来访
              step_head(state.history),
              //主体内容
              Expanded(
                child: Container(
                  // decoration: BoxDecoration(color: Colors.green[100]),
                  child: Theme(
                    data: Theme.of(context)
                        .copyWith(primaryColor: Colors.blue[400]),
                    child: Stepper(
                        key: Key("01"),
                        currentStep: _currentStep,
                        onStepTapped: (int value) {
                          // 点击步骤的序号触发的方法
                          setState(() {
                            _currentStep = value;
                          });
                        },
                        // onStepContinue: () {
                        //   // 点击继续触发的方法
                        //   setState(() {
                        //     _currentStep < 2 ? _currentStep += 1 : _currentStep = 0;
                        //   });
                        // },
                        // onStepCancel: () {
                        //   // 点击取消触发的方法
                        //   setState(() {
                        //     _currentStep > 0 ? _currentStep -= 1 : _currentStep = 0;
                        //   });
                        // },
                        //修改确认和取消的按钮
                        controlsBuilder: (BuildContext context,
                            {VoidCallback onStepContinue,
                            VoidCallback onStepCancel}) {
                          return Row(
                            children: <Widget>[
                              // FlatButton(
                              //   child: Text('下一步'),
                              //   onPressed: onStepContinue,
                              // ),
                              // FlatButton(
                              //   child: Text('上一步'),
                              //   onPressed: onStepCancel,
                              // ),
                            ],
                          );
                        },
                        // steps: state.history.map((item) {
                        //   return Step();
                        // }).toList()

                        // _stepList(
                        //     state.history,
                        //     state.historyVariable,
                        //     state.salesman,
                        //     state.coustomDataItem,
                        //     state.userInfo,
                        //     context)
                        steps: state.history.map((item) {
                          return Step(
                            title: step_title(getTime(item['startTime']), "",
                                '0', item["name"]),
                            subtitle: Text('跟进人 :' +
                                getsalseman(item["assignee"], state.salesman)),
                            content: Container(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: getcontent(
                                    item,
                                    state.historyVariable,
                                    state.coustomDataItem,
                                    state.history.length - 1 ==
                                            state.history.indexOf(item)
                                        ? true
                                        : false,
                                    state.userInfo,
                                    context),
                              ),
                            ),
                            isActive:
                                _currentStep == state.history.indexOf(item),
                          );
                        }).toList()),
                  ),
                ),
              ),

              //底部按钮部分
              // BottomButton(),
            ],
          );
        },
      ),
    );
  }

  String getsalseman(id, list) {
    String name = "";
    for (var j = 0; j < list.length; j++) {
      if (list[j]["id"] == id) {
        name = list[j]["realName"];
      }
    }
    if (name == "") {
      name = "楼盘经理";
    }

    return name;
  }

  String getTime(dataTime) {
    var nowTime = DateTime.parse(dataTime).toLocal().toString();
    print(nowTime);
    return nowTime.substring(0, 19);
  }

  List<Widget> getcontent(
      listdata, variable, currentlist, boolshow, userInfo, context) {
    List<Widget> res = [];

    for (var j = 0; j < variable.length; j++) {
      String keyss = listdata["taskDefinitionKey"];
      String id = listdata["id"];
      variable[j].forEach((key, value) {
        // print(key);
        // String defKey = "";
        // if (key.length > 16) defKey = (key ?? "").substring(0, 16);
        // print(defKey);
        if (key == id + "_imgData") {
          //variable[j]
          res.add(SingleChildScrollView(
              physics: BouncingScrollPhysics(),
              scrollDirection: Axis.horizontal,
              // controller: ScrollController(),
              child: Row(
                children: value.map<Widget>((item) {
                  return Image.network(
                    item,
                    height: 150,
                  );
                }).toList(),
              )));
        }
        if (key == id + "_requestData") {
          res.add(Container(
            child: Text(value + " "),
          ));
        }
        if (key == id + "_managerDeration") {
          res.add(Container(
            child: Text(value),
          ));
        }
      });

      // if (variable[j]["executionId"] == listdata["executionId"]) {
      //   res.add(variable[j]);
      // }
    }
    // if (currentlist["workflowStatus"] == "0" &&
    //     boolshow &&
    //     (listdata["name"] == currentlist["currentHandler"]) &&
    //     (listdata["taskDefinitionKey"] == "CategoryManagent" ||
    //         listdata["taskDefinitionKey"] == "Activity_0vv7s63" ||
    //         listdata["taskDefinitionKey"] == "Activity_0qvod3g") &&
    //     currentlist["freeze"] == "0") {
    //   res.add(Container(
    //     child: RaisedButton(
    //       child: Text('冻结'),
    //       onPressed: () {
    //         showDialog(
    //             context: context,
    //             builder: (BuildContext context) {
    //               return new AlertDialog(
    //                 title: Center(child: Text("温馨提示")),
    //                 content: new SingleChildScrollView(
    //                   child: new ListBody(
    //                     children: <Widget>[
    //                       new Text("您正在对该客户审请冻结"),
    //                     ],
    //                   ),
    //                 ),
    //                 actions: <Widget>[
    //                   FlatButton(
    //                     child: new Text("取消"),
    //                     onPressed: () {
    //                       Navigator.of(context).pop(false);
    //                     },
    //                   ),
    //                   FlatButton(
    //                     child: new Text("确定"),
    //                     onPressed: () {
    //                       // BlocProvider.of<ProcessedBloc>(context)
    //                       //     .add(ProcessedEvent.pushProcessed());
    //                       Navigator.of(context).pop(true);
    //                       // _editParentText();
    //                     },
    //                   ),
    //                 ],
    //               );
    //             }).then((value) {
    //           print(value);
    //           if (value) {
    //             print(currentlist);
    //             BlocProvider.of<CoustomerBloc>(context)
    //               ..add(CoustomerEvent.frezzeCoumer(currentlist["instanceId"]));

    //             BotToast.showText(text: "已申请。");
    //           }
    //         });
    //       },
    //     ),
    //   ));
    // }
    if (boolshow &&
        currentlist["workflowStatus"] == "0" &&
        currentlist["salesmanId"] == userInfo["id"] &&
        listdata["assignee"] == userInfo["id"]) {
      res.add(Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Container(
            child: OutlineButton(
              onPressed: () {
                ExtendedNavigator.of(context).replace(Routes.needToDeal,
                    arguments: NeedToDealArguments(jumpProcessed: listdata));
              },
              child: Text("立即跟进"),
            ),
          ),
        ],
      ));
    }
    // variable.map((item) {
    //   if (item["executionId"] == listdata["executionId"]) {
    //     res.add(item);
    //   }
    // });

    return res;
  }

  List<Step> _stepList(
      list, variable, salesman, currentlist, userInfo, context) {
    List<Step> lis = [];
    // state.history,
    //                         state.historyVariable,
    //                         state.salesman,
    //                         state.coustomDataItem,
    //                         state.userInfo,
    //                         context
    // List list =  state.history
    for (var i = 0; i < list.length; i++) {
      // print(variable);

      lis.add(Step(
          title: step_title(
              getTime(list[i]['startTime']), "", '0', list[i]["name"]),
          subtitle: Text('跟进人 :' + getsalseman(list[i]["assignee"], salesman)),
          content: BlocBuilder<CoustomerBloc, CoustomerState>(
            builder: (context, state) {
              return Container(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: getcontent(state.history[i], variable, currentlist,
                      list.length - 1 == i ? true : false, userInfo, context),
                ),
              );
            },
          ),
          isActive: list.length - 1 == i));
    }

    if (lis.length == 0) {
      lis.add(Step(
          title: step_title('2020-09-07 10:35', '去电', '0', "wu"),
          subtitle: Text('跟进人 刘聪'),
          content: Container(
            child: SizedBox(),
          ),
          isActive: this._currentStep == 0));
    }
    return lis;
  }

  //头部（跟进记录页面），记录/来电/来访
  step_head(list) {
    return Container(
      height: 30.0,
      margin: EdgeInsets.fromLTRB(10, 10, 10, 0),
      padding: EdgeInsets.fromLTRB(0, 0, 0, 0),
      decoration: BoxDecoration(
        // color: Colors.grey[300],
        border: Border(bottom: BorderSide(width: 1, color: Color(0xffe5e5e5))),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Container(
              margin: EdgeInsets.fromLTRB(20, 0, 0, 0),
              child: Text('记录(' + list.length.toString() + ')',
                  style:
                      TextStyle(fontSize: 15.0, fontWeight: FontWeight.w500))),
          // Container(
          //   margin: EdgeInsets.fromLTRB(0, 0, 20, 0),
          //   child: Row(
          //     children: <Widget>[
          //       Container(
          //           child: Text('来电:0', style: TextStyle(fontSize: 13.0))),
          //       SizedBox(width: 5.0),
          //       Container(
          //           child: Text('来访:0', style: TextStyle(fontSize: 13.0))),
          //     ],
          //   ),
          // )
        ],
      ),
    );
  }

  //进度的标题栏
  step_title(String time, String state, String remarks_num, String result) {
    return Container(
      // decoration:
      //     BoxDecoration(border: Border.all(width: 1.0)),
      //获取屏幕宽度
      width: MediaQuery.of(context).size.width - 90,
      padding: EdgeInsets.fromLTRB(0, 15.0, 0, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Container(
              // decoration: BoxDecoration(
              //     border: Border.all(width: 1.0)),
              child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Container(
                  // padding: EdgeInsets.fromLTRB(20, 0, 0, 0),
                  child: Row(
                children: <Widget>[
                  Text(time),
                  SizedBox(width: 5),
                  Text(state),
                ],
              )),
              // Container(
              //     // padding: EdgeInsets.fromLTRB(20, 0, 0, 0),
              //     child: Row(
              //   children: <Widget>[
              //     Icon(
              //       Icons.comment,
              //       color: Colors.blue[200],
              //       size: 17.0,
              //     ),
              //     SizedBox(width: 5.0),
              //     Text(
              //       remarks_num,
              //       style: TextStyle(color: Colors.grey[400]),
              //     )
              //   ],
              // )),
            ],
          )),
          Container(
            padding: EdgeInsets.only(top: 0),
            child: Text(result,
                style: TextStyle(
                    fontSize: 12.0,
                    color: Colors.grey,
                    fontWeight: FontWeight.w400)),
          )
        ],
      ),
    );
  }

  //进度的内容
//   step_content(List<Widget> content) {
//     // print("+++++++++++++++++++++++++++++");
//     // print(content);
//     // print("+++++++++++++++++++++++++++++");
//     return Container(
//       padding: EdgeInsets.fromLTRB(0, 10, 0, 0),
//       width: MediaQuery.of(context).size.width,
//       // decoration:
//       //     BoxDecoration(border: Border.all(width: 1.0)),
//       child: Column(children: content),
//     );
//   }
}
