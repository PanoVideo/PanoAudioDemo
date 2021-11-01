package video.pano.audiochat.rtc.data;

import com.google.gson.Gson;

import video.pano.audiochat.rtc.PanoTypeConstant;
import video.pano.audiochat.rtc.PanoUserMgr;

public class PanoMsgFactory {

    private static final Gson sGson = new Gson();

    public static byte[] killUserMsg(PanoCmdUser user){
        return baseMicMgrMsg(PanoTypeConstant.KillUser,user);
    }

    public static byte[] sendApplyMsg(PanoCmdUser user) {
        return baseMicMgrMsg(PanoTypeConstant.ApplyChat,user);
    }

    public static byte[] acceptApplyMsg(PanoCmdUser user) {
        return baseMicMgrMsg(PanoTypeConstant.AcceptChat,user);
    }

    public static byte[] declineApplyMsg(PanoCmdUser user) {
        return baseMicMgrMsg(PanoTypeConstant.RejectChat,user);
    }

    public static byte[] declineApplyMsg(int reason , PanoCmdUser user) {
        return baseMicMgrMsg(PanoTypeConstant.RejectChat,reason,user);
    }

    public static byte[] inviteMsg(PanoCmdUser user){
        return baseMicMgrMsg(PanoTypeConstant.InviteUser,user);
    }

    public static byte[] rejectInviteMsg(PanoCmdUser user) {
        return baseMicMgrMsg(PanoTypeConstant.RejectInvite,user);
    }

    public static byte[] rejectInviteMsg(int reason , PanoCmdUser user) {
        return baseMicMgrMsg(PanoTypeConstant.RejectInvite,reason,user);
    }

    public static byte[] acceptInviteMsg(PanoCmdUser user) {
        return baseMicMgrMsg(PanoTypeConstant.AcceptInvite,user);
    }

    public static byte[] cancelApplyMsg(PanoCmdUser user) {
        return baseMicMgrMsg(PanoTypeConstant.CancelChat,user);
    }

    public static byte[] leaveMicMsg(PanoCmdUser user) {
        return baseMicMgrMsg(PanoTypeConstant.StopChat,user);
    }

    private static byte[] baseMicMgrMsg(int msgType , PanoCmdUser user){
        try{
            return sGson.toJson(new PanoCmdMessage(msgType,user)).getBytes();
        }catch (Exception e){
            return null;
        }
    }

    private static byte[] baseMicMgrMsg(int msgType , int reason , PanoCmdUser user){
        try{
            return sGson.toJson(new PanoCmdMessage(msgType,reason,user)).getBytes();
        }catch (Exception e){
            return null;
        }
    }


    public static byte[] sendTextMsg(long userId, String content) {
        try {
            return sGson.toJson(new PanoNormalMessage(PanoTypeConstant.NormalChat,content,userId))
                    .getBytes();
        } catch (Exception e) {
            return null;
        }
    }

    public static byte[] closeRoomMsg() {
        try {
            return sGson.toJson(new PanoNormalMessage(PanoTypeConstant.CloseRoom))
                    .getBytes();
        } catch (Exception e) {
            return null;
        }
    }

    public static byte[] uploadAudioLogMsg() {
        try {
            return sGson.toJson(new PanoNormalMessage(PanoTypeConstant.UploadAudioLog))
                    .getBytes();
        } catch (Exception e) {
            return null;
        }
    }

    public static byte[] updateAllMic(){
        try{
            return sGson.toJson(new PanoCmdMessage(PanoTypeConstant.AllMic,PanoUserMgr.getIns().getMicList())).getBytes();
        }catch (Exception e){
            return null;
        }
    }
}
