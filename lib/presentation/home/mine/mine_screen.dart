import 'dart:convert';

import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_ui/application/mine/bloc/mine_bloc.dart';
import 'package:flutter_ui/injection.dart';
import 'package:flutter_ui/presentation/core/fintness_app_theme.dart';
import 'package:flutter_ui/presentation/home/ui_view/mine_about_us_view.dart';
import 'package:flutter_ui/presentation/home/ui_view/mine_achievement_view.dart';
import 'package:flutter_ui/presentation/home/ui_view/mine_aiCard_view.dart';
import 'package:flutter_ui/presentation/home/ui_view/mine_change_project_view.dart';
import 'package:flutter_ui/presentation/home/ui_view/mine_suggest_feedback_view.dart';
import 'package:flutter_ui/presentation/routes/router.gr.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:fluwx/fluwx.dart' as fluwx;

class MineScreen extends StatefulWidget {
  const MineScreen({Key key, this.animationController}) : super(key: key);
  final AnimationController animationController;

  @override
  _MineScreenState createState() => _MineScreenState();
}

const CACHED_SIGN_IN_USER = 'CACHED_SIGN_IN_USER';

class _MineScreenState extends State<MineScreen> with TickerProviderStateMixin {
  Animation<double> topBarAnimation;

  List<Widget> listViews = <Widget>[];
  final ScrollController scrollController = ScrollController();
  double topBarOpacity = 0.0;
  List _listHouse = [];
  List _listHouseId = [];
  List _listHouseShortCode = [];
  String _house = "";
  String _cachedSignInUser = "";

  @override
  void initState() {
    topBarAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(
            parent: widget.animationController,
            curve: Interval(0, 0.5, curve: Curves.fastOutSlowIn)));
    addAllListData();

    scrollController.addListener(() {
      if (scrollController.offset >= 24) {
        if (topBarOpacity != 1.0) {
          setState(() {
            topBarOpacity = 1.0;
          });
        }
      } else if (scrollController.offset <= 24 &&
          scrollController.offset >= 0) {
        if (topBarOpacity != scrollController.offset / 24) {
          setState(() {
            topBarOpacity = scrollController.offset / 24;
          });
        }
      } else if (scrollController.offset <= 0) {
        if (topBarOpacity != 0.0) {
          setState(() {
            topBarOpacity = 0.0;
          });
        }
      }
    });
    super.initState();
  }

  void addAllListData() {
    const int count = 5;

    listViews.add(BlocBuilder<MineBloc, MineState>(builder: (context, state) {
      return MineChangeProjectView(
        house: _house,
        listHouse: _listHouse,
        listHouseId: _listHouseId,
        listHouseShortCode: _listHouseShortCode,
        animation: Tween<double>(begin: 0.0, end: 1.0).animate(CurvedAnimation(
            parent: widget.animationController,
            curve:
                Interval((1 / count) * 1, 1.0, curve: Curves.fastOutSlowIn))),
        animationController: widget.animationController,
      );
    }));
    listViews.add(
      MineAiCardView(
        animation: Tween<double>(begin: 0.0, end: 1.0).animate(CurvedAnimation(
            parent: widget.animationController,
            curve:
                Interval((1 / count) * 2, 1.0, curve: Curves.fastOutSlowIn))),
        animationController: widget.animationController,
      ),
    );
    listViews.add(
      MineAchievementView(
        animation: Tween<double>(begin: 0.0, end: 1.0).animate(CurvedAnimation(
            parent: widget.animationController,
            curve:
                Interval((1 / count) * 3, 1.0, curve: Curves.fastOutSlowIn))),
        animationController: widget.animationController,
      ),
    );
    listViews.add(
      MineSuggestFeedbackView(
        animation: Tween<double>(begin: 0.0, end: 1.0).animate(CurvedAnimation(
            parent: widget.animationController,
            curve:
                Interval((1 / count) * 4, 1.0, curve: Curves.fastOutSlowIn))),
        animationController: widget.animationController,
      ),
    );
    listViews.add(
      MineAboutUsView(
        animation: Tween<double>(begin: 0.0, end: 1.0).animate(CurvedAnimation(
            parent: widget.animationController,
            curve:
                Interval((1 / count) * 5, 1.0, curve: Curves.fastOutSlowIn))),
        animationController: widget.animationController,
      ),
    );
  }

  Future<bool> getData() async {
    await Future<dynamic>.delayed(const Duration(milliseconds: 50));
    return true;
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
        create: (BuildContext context) => getIt<MineBloc>()
          ..add(const MineEvent.sendAuth())
          ..add(const MineEvent.weChatAuthResponse()),
        child:
            BlocConsumer<MineBloc, MineState>(listener: (context, state) async {
          SharedPreferences sharedPreferences =
              await SharedPreferences.getInstance();
          _cachedSignInUser = sharedPreferences.get('CACHED_SIGN_IN_USER');
          String affiliateds = sharedPreferences.get('AFFILIATEDS');
          List affidList = [];
          if (affiliateds != null) {
            affidList = jsonDecode(affiliateds);
          }
          for (int i = 0; i < affidList.length; i++) {
            _listHouse.add(affidList[i]["projectName"]);
            _listHouseId.add(affidList[i]["id"]);
            _listHouseShortCode.add(affidList[i]["affiliationCode"]);
          }
          String houseName = sharedPreferences.getString("HOUSESNAME");
          if (houseName == null) {
            sharedPreferences.setString(
                HOUSESNAME, affidList[0]["projectName"]);
            sharedPreferences.setString(HOUSEID, affidList[0]["id"]);
            sharedPreferences.setString(
                HOUSESHORTCODE, affidList[0]["affiliationCode"]);
            _house = affidList[0]["projectName"];
          } else {
            _house = houseName;
          }
          if (state.isAuthorization) {
            if (state.unsubscribe) {
              Navigator.push(context, DialogRouter(LoadingDialog(true)));
            }
          } else {
            authorization();
          }
        }, builder: (BuildContext context, state) {
          return Container(
            color: FitnessAppTheme.background,
            child: Scaffold(
              backgroundColor: Colors.transparent,
              body: Stack(
                children: <Widget>[
                  getMainListViewUI(),
                  getAppBarUI(state),
                  SizedBox(
                    height: MediaQuery.of(context).padding.bottom,
                  )
                ],
              ),
            ),
          );
        }));
  }

  Widget getMainListViewUI() {
    return FutureBuilder<bool>(
      future: getData(),
      builder: (BuildContext context, AsyncSnapshot<bool> snapshot) {
        if (!snapshot.hasData) {
          return const SizedBox();
        } else {
          return ListView.builder(
            controller: scrollController,
            padding: EdgeInsets.only(
              top: AppBar().preferredSize.height +
                  MediaQuery.of(context).padding.top +
                  24,
              bottom: 62 + MediaQuery.of(context).padding.bottom,
            ),
            itemCount: listViews.length,
            scrollDirection: Axis.vertical,
            itemBuilder: (BuildContext context, int index) {
              widget.animationController.forward();
              return listViews[index];
            },
          );
        }
      },
    );
  }

  Widget getAppBarUI(state) {
    return Column(
      children: <Widget>[
        AnimatedBuilder(
          animation: widget.animationController,
          builder: (BuildContext context, Widget child) {
            return FadeTransition(
              opacity: topBarAnimation,
              child: Transform(
                transform: Matrix4.translationValues(
                    0.0, 30 * (1.0 - topBarAnimation.value), 0.0),
                child: Container(
                  decoration: BoxDecoration(
                    color: FitnessAppTheme.white.withOpacity(topBarOpacity),
                    borderRadius: const BorderRadius.only(
                      bottomLeft: Radius.circular(32.0),
                    ),
                    boxShadow: <BoxShadow>[
                      BoxShadow(
                          color: FitnessAppTheme.grey
                              .withOpacity(0.4 * topBarOpacity),
                          offset: const Offset(1.1, 1.1),
                          blurRadius: 10.0),
                    ],
                  ),
                  child: Column(
                    children: <Widget>[
                      SizedBox(
                        height: MediaQuery.of(context).padding.top,
                      ),
                      Padding(
                        padding: EdgeInsets.only(
                            left: 16,
                            // right: 16,
                            top: 16 - 8.0 * topBarOpacity,
                            bottom: 12 - 8.0 * topBarOpacity),
                        child: Row(
                          // mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            if (_cachedSignInUser != "")
                              InkWell(
                                child: Container(
                                  width: 50,
                                  height: 50,
                                  margin: EdgeInsets.fromLTRB(0, 0, 8, 0),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(50.0),
                                    image: DecorationImage(
                                        image: NetworkImage(
                                          jsonDecode(
                                              _cachedSignInUser)['headimgUrl'],
                                        ),
                                        fit: BoxFit.cover),
                                  ),
                                  child: Text(""),
                                ),
                                onTap: () {
                                  ExtendedNavigator.of(context).push(
                                      Routes.uploadNetImgPreview,
                                      arguments: UploadNetImgPreviewArguments(
                                          img: jsonDecode(_cachedSignInUser)[
                                              'headimgUrl']));
                                },
                              ),
                            if (_cachedSignInUser != "")
                              Text(jsonDecode(_cachedSignInUser)['realName'],
                                  style: TextStyle(
                                      fontSize: 19.0,
                                      fontWeight: FontWeight.w500,
                                      color: Colors.grey[700])),
                            if (_cachedSignInUser != "")
                              Container(
                                margin: EdgeInsets.only(left: 8.0, top: 5.0),
                                padding: EdgeInsets.fromLTRB(2, 1, 2, 1),
                                decoration: BoxDecoration(
                                    border: Border.all(
                                        width: 0.8, color: Colors.blue),
                                    borderRadius: BorderRadius.circular(5.0)),
                                child: Text(
                                  _userRole(),
                                  style: TextStyle(
                                      color: Colors.blue, fontSize: 9),
                                ),
                              ),
                            Expanded(child: Text("")),
                            InkWell(
                                child: Container(
                                  width: 90,
                                  height: 60,
                                  child: Icon(
                                    Icons.settings,
                                    color: Colors.grey,
                                  ),
                                ),
                                onTap: () {
                                  ExtendedNavigator.of(context)
                                      .push(Routes.mineSettingPage);
                                }),
                          ],
                        ),
                      )
                    ],
                  ),
                ),
              ),
            );
          },
        )
      ],
    );
  }

  authorization() {
    return showDialog(
        barrierDismissible: true,
        context: context,
        builder: (context) {
          return AlertDialog(
            contentPadding: const EdgeInsets.fromLTRB(0, 0, 0, 0),
            title: Center(
                child: Text("微信授权",
                    style:
                        TextStyle(fontSize: 16, fontWeight: FontWeight.w500))),
            content: Container(
              height: 120,
              child: Column(
                children: [
                  Container(
                    margin: EdgeInsets.only(top: 10),
                    width: 35,
                    height: 35,
                    decoration: BoxDecoration(
                      image: DecorationImage(
                          image: AssetImage(
                            "assets/images/xkb.png",
                          ),
                          fit: BoxFit.cover),
                    ),
                    child: Text(""),
                  ),
                  Container(
                    margin: EdgeInsets.only(top: 10),
                    child: Text(
                      "新客邦申请获取以下权限:",
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                    ),
                  ),
                  Container(
                    margin: EdgeInsets.only(top: 10, bottom: 10),
                    child: bottomLine(),
                  ),
                  Container(
                      child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.circle,
                        color: Colors.grey,
                        size: 8,
                      ),
                      Text(
                        "获得你的公开信息（昵称，头像等）",
                        style: TextStyle(
                            color: Colors.grey,
                            fontSize: 12,
                            fontWeight: FontWeight.w400),
                      ),
                    ],
                  )),
                ],
              ),
            ),
            actions: <Widget>[
              FlatButton(
                child: Text("拒绝", style: TextStyle(color: Colors.grey[700])),
                onPressed: () {
                  Navigator.of(context).pop(false);
                },
              ),
              FlatButton(
                child: Text("允许"),
                onPressed: () {
                  Navigator.of(context).pop(true);
                },
              )
            ],
          );
        }).then((value) async {
      if (value != null && value) {
        fluwx
            .sendWeChatAuth(
                scope: "snsapi_userinfo", state: "wechat_sdk_demo_test")
            .then((data) {
          // print(data);
          if (data) {
            BlocProvider.of<MineBloc>(context)
              ..add(MineEvent.weChatAuthResponse());
          }
        });
      }
    });
  }

  centerLine() {
    return Container(
      height: 40.0,
      decoration: BoxDecoration(
        border: Border(left: BorderSide(width: 0.8, color: Colors.grey[300])),
      ),
      child: SizedBox(),
    );
  }

  bottomLine() {
    return Container(
      width: 200.0,
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(width: 0.8, color: Colors.grey[300])),
      ),
      child: SizedBox(),
    );
  }

  String _userRole() {
    String userRole = '';
    String userInfo = jsonDecode(_cachedSignInUser)['userRole'];
    switch (userInfo) {
      case 'salesman':
        userRole = '置业顾问';
        return userRole;
      case 'secretary':
        userRole = '销秘';
        return userRole;
      case 'manager':
        userRole = '经理';
        return userRole;
      case 'financial':
        userRole = '财务';
        return userRole;
      case 'director':
        userRole = '总监';
        return userRole;
    }
    return userRole;
  }
}

class LoadingDialog extends Dialog {
  LoadingDialog(this.canceledOnTouchOutside) : super();

  ///点击背景是否能够退出
  final bool canceledOnTouchOutside;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: new Material(

          ///背景透明
          color: Colors.transparent,

          ///保证控件居中效果
          child: Stack(
            children: <Widget>[
              GestureDetector(
                ///点击事件
                onTap: () {
                  if (canceledOnTouchOutside) {
                    Navigator.pop(context);
                  }
                },
              ),
              _dialog(context)
            ],
          )),
    );
  }

  Widget _dialog(context) {
    return Center(
      child: Container(
        width: 250.0,
        height: 200.0,
        decoration: ShapeDecoration(
          color: Color(0xffffffff),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(
              Radius.circular(8.0),
            ),
          ),
        ),
        child: Column(
          children: <Widget>[
            Container(
              margin: EdgeInsets.only(top: 10, right: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  InkWell(
                    child: Icon(Icons.cancel, color: Colors.blue, size: 22),
                    onTap: () {
                      Navigator.pop(context);
                    },
                  )
                ],
              ),
            ),
            Container(
              width: 130,
              height: 130,
              decoration: BoxDecoration(
                image: DecorationImage(
                    image: AssetImage(
                      "assets/images/erCode.png",
                    ),
                    fit: BoxFit.contain),
              ),
              child: Text(""),
            ),
            Container(
              margin: EdgeInsets.only(top: 2.0),
              child: Text(
                "关注公众号，获取流程通知",
                style: TextStyle(
                    color: Colors.blue,
                    fontSize: 15,
                    fontWeight: FontWeight.w500),
              ),
            )
          ],
        ),
      ),
    );
  }
}

class DialogRouter extends PageRouteBuilder {
  final Widget page;

  DialogRouter(this.page)
      : super(
          opaque: false,
          barrierColor: Colors.black54,
          pageBuilder: (context, animation, secondaryAnimation) => page,
          transitionsBuilder: (context, animation, secondaryAnimation, child) =>
              child,
        );
}
