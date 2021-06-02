import 'dart:async';
import 'dart:convert';

import 'package:bloc/bloc.dart';
import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:flutter_ui/domain/core/failures.dart';
import 'package:flutter_ui/domain/mine/i_mine_service.dart';
import 'package:flutter_ui/domain/process/i_process_service.dart';
import 'package:flutter_ui/domain/web_scoket/web_scoket_failure.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:injectable/injectable.dart';
import 'package:fluwx/fluwx.dart' as fluwx;

part 'mine_event.dart';
part 'mine_state.dart';
part 'mine_bloc.freezed.dart';

@injectable
class MineBloc extends Bloc<MineEvent, MineState> {
  final IMineService _iMineService;
  final IProcessService _iProcessService;
  MineBloc(this._iMineService, this._iProcessService)
      : super(MineState.initial());

  @override
  Stream<MineState> mapEventToState(
    MineEvent event,
  ) async* {
    yield* event.map(
      handleProcess: (e) async* {
        // yield* _handleProcess(_iMineService.handleProcess());
        // _iMineService.handleProcess();
        yield state.copyWith(isAffId: true);
      },
      getErWeiCode: (e) async* {
        yield* _getErWeiCode(_iMineService.getErWeiCode());
      },
      shareCode: (e) async* {
        yield* _shareCode(_iProcessService.shareCode());
      },
      submitInfo: (e) async* {
        yield* _submitInfo(_iMineService.submitInfo(e.image, e.nickName));
      },
      testVersion: (e) async* {
        yield* _testVersion(_iMineService.testVersion(e.vInfo));
      },
      sendAuth: (e) async* {
        yield* _sendAuth(_iMineService.sendAuth());
      },
      submitOpenid: (e) async* {
        yield* _submitOpenid(_iMineService.submitOpenid(e.openid, e.unionid));
      },
      sendWeChatAuth: (e) async* {
        print("dd");
        yield state.copyWith(
          isSend: true,
        );
      },
      weChatAuthResponse: (e) async* {
        fluwx.weChatResponseEventHandler
            .distinct((a, b) => a == b)
            .listen((res) async {
          if (res is fluwx.WeChatAuthResponse) {
            // setState(() {
            //   _result = "state :${res.state} \n code:${res.code}";
            // });
            print(res.code);
            if (res.code != null) {
              String http =
                  "https://api.weixin.qq.com/sns/oauth2/access_token?appid=wx900cb74137db2ad5&secret=fd85a75a6feb7e5e8718399ca3631954&code=" +
                      res.code +
                      "&grant_type=authorization_code";
              try {
                var response = await Dio().get(http);
                // print(response.data);
                var res = jsonDecode(response.data);
                if (res.containsKey("openid") && res.containsKey("unionid")) {
                  _submitOpenid(_iMineService.submitOpenid(
                      res["openid"], res["unionid"]));

                  // BlocProvider.of<MineBloc>(context)
                  //   ..add(
                  //       MineEvent.submitOpenid(res["openid"], res["unionid"]));
                }
              } catch (e) {
                print(e);
              }
            }
          }
        });
        yield state.copyWith();
      },
    );
  }

  Stream<MineState> _handleProcess(
    Future<Either<ValueFailure, Unit>> forwardedCall,
  ) async* {
    Either<ValueFailure, Unit> failureOrSuccess;
    state.copyWith(
      processFailureOrSuccessOption: optionOf(failureOrSuccess),
    );
  }

  Stream<MineState> _getErWeiCode(
    Future<Either<WebScoketFailure, String>> forwardedCall,
  ) async* {
    String getErWeiCode = "";
    await forwardedCall.then((value) {
      value.fold((l) {}, (r) {
        getErWeiCode = r;
      });
    });
    yield state.copyWith(
      getErWeiCode: getErWeiCode,
    );
  }

  Stream<MineState> _shareCode(
    Future<Either<ValueFailure, List<dynamic>>> forwardedCall,
  ) async* {
    List<dynamic> list = [];
    await forwardedCall.then((value) {
      value.fold((l) {}, (r) {
        list = r;
      });
    });
    yield state.copyWith(
      shareCode: list,
    );
  }

  Stream<MineState> _submitInfo(
    Future<Either<WebScoketFailure, String>> forwardedCall,
  ) async* {
    String submitInfo = "";
    await forwardedCall.then((value) {
      value.fold((l) {}, (r) {
        submitInfo = r;
      });
    });
    yield state.copyWith(
      submitInfo: submitInfo,
    );
  }

  Stream<MineState> _testVersion(
    Future<Either<WebScoketFailure, Map<String, dynamic>>> forwardedCall,
  ) async* {
    Map<String, dynamic> testVersion = {};
    await forwardedCall.then((value) {
      value.fold((l) {}, (r) {
        testVersion = r;
      });
    });
    yield state.copyWith(
      testVersion: testVersion,
    );
  }

  Stream<MineState> _sendAuth(
    Future<Either<WebScoketFailure, Map<String, dynamic>>> forwardedCall,
  ) async* {
    Map<String, dynamic> sendAuth = {};
    await forwardedCall.then((value) {
      value.fold((l) {}, (r) {
        sendAuth = r;
      });
    });
    bool unsubscribe = false;
    bool isAuthorization = false;
    if (sendAuth["msg"] == "unsubscribe") {
      unsubscribe = true;
    }
    if (sendAuth["data"] == true) {
      isAuthorization = true;
    }
    yield state.copyWith(
      unsubscribe: unsubscribe,
      isAuthorization: isAuthorization,
    );
  }

  Stream<MineState> _submitOpenid(
    Future<Either<WebScoketFailure, String>> forwardedCall,
  ) async* {
    String submitInfo = "";
    await forwardedCall.then((value) {
      value.fold((l) {}, (r) {
        submitInfo = r;
      });
    });
    yield state.copyWith(
      submitInfo: submitInfo,
    );
  }

  // Stream<MineState> _getAccessToken(
  //   Future<Either<WebScoketFailure, Map<String, dynamic>>> forwardedCall,
  // ) async* {
  //   Map<String, dynamic> accessToken = {};
  //   await forwardedCall.then((value) {
  //     value.fold((l) {}, (r) {
  //       accessToken = r;
  //     });
  //   });
  //   yield state.copyWith(
  //     accessToken: accessToken,
  //   );
  // }
}
