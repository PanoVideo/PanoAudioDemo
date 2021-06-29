package video.pano.audiochat.rtc;

import com.pano.rtc.api.Constants;

public interface PanoEvent {

    void onChannelJoinConfirm(Constants.QResult result);

    void onUserJoinIndication(long userId, String userName);

    void onUserLeaveIndication(long userId, Constants.UserLeaveReason reason);

    void onUserAudioMute(long userId);

    void onUserAudioUnmute(long userId);
}
