part of 'mine_bloc.dart';

@freezed
abstract class MineEvent with _$MineEvent {
  const factory MineEvent.handleProcess() = _HandleProcess;
  const factory MineEvent.getErWeiCode() = GetErWeiCode;
  const factory MineEvent.shareCode() = ShareCode;
  const factory MineEvent.submitInfo(String image, String nickName) =
      SubmitInfo;
  const factory MineEvent.testVersion(String vInfo) = TestVersion;
  const factory MineEvent.sendAuth() = SendAuth;
  const factory MineEvent.submitOpenid(String openid, String unionid) =
      SubmitOpenid;
  const factory MineEvent.sendWeChatAuth() = SendWeChatAuth;
  const factory MineEvent.weChatAuthResponse() = WeChatAuthResponse;
}
