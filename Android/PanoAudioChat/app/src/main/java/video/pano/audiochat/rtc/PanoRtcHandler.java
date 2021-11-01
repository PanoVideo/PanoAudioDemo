package video.pano.audiochat.rtc;

import android.util.Log;

import com.pano.rtc.api.Constants;
import com.pano.rtc.api.RtcEngineCallback;

import java.util.ArrayList;
import java.util.List;

public class PanoRtcHandler implements RtcEngineCallback {

    private static final String TAG = "PanoRtcHandler";

    private final List<PanoEvent> mPanoEventList = new ArrayList<>();

    public void addListener(PanoEvent panoEvent) {
        mPanoEventList.add(panoEvent);
    }

    public void removeListener(PanoEvent panoEvent) {
        mPanoEventList.remove(panoEvent);
    }

    @Override
    public void onChannelJoinConfirm(Constants.QResult qResult) {
        Log.i(TAG, "onChannelJoinConfirm = " + qResult);

        for (PanoEvent event : mPanoEventList) {
            event.onChannelJoinConfirm(qResult);
        }
    }


    @Override
    public void onChannelLeaveIndication(Constants.QResult qResult) {
        Log.i(TAG, "onChannelLeaveIndication = " + qResult);

        for (PanoEvent event : mPanoEventList) {
            event.onChannelLeaveIndication(qResult);
        }
    }

    @Override
    public void onChannelCountDown(long l) {
        Log.i(TAG, "onChannelCountDown l = " + l);
    }

    @Override
    public void onUserJoinIndication(long l, String s) {
        Log.i(TAG, "onUserJoinIndication l = " + l + " s = " + s);
        for (PanoEvent event : mPanoEventList) {
            event.onUserJoinIndication(l, s);
        }
    }

    @Override
    public void onUserLeaveIndication(long l, Constants.UserLeaveReason userLeaveReason) {
        Log.i(TAG, "onUserLeaveIndication l = " + l + " userLeaveReason = " + userLeaveReason);
        for (PanoEvent event : mPanoEventList) {
            event.onUserLeaveIndication(l, userLeaveReason);
        }
    }

    @Override
    public void onUserAudioStart(long l) {
        Log.i(TAG, "onUserAudioStart l = " + l);
    }

    @Override
    public void onUserAudioStop(long l) {
        Log.i(TAG, "onUserAudioStop l = " + l);
    }

    @Override
    public void onUserAudioSubscribe(long l, Constants.MediaSubscribeResult mediaSubscribeResult) {
        Log.i(TAG, "onUserAudioSubscribe l = " + l);
    }

    @Override
    public void onUserAudioMute(long l) {
        Log.i(TAG, "onUserAudioMute l = " + l);
        for (PanoEvent event : mPanoEventList) {
            event.onUserAudioMute(l);
        }
    }

    @Override
    public void onUserAudioUnmute(long l) {
        Log.i(TAG, "onUserAudioUnmute l = " + l);
        for (PanoEvent event : mPanoEventList) {
            event.onUserAudioUnmute(l);
        }
    }

    @Override
    public void onUserVideoStart(long l, Constants.VideoProfileType videoProfileType) {
        Log.i(TAG, "onUserVideoStart l = " + l);
    }

    @Override
    public void onUserVideoStop(long l) {
        Log.i(TAG, "onUserVideoStop l = " + l);
    }

    @Override
    public void onUserVideoSubscribe(long l, Constants.MediaSubscribeResult mediaSubscribeResult) {
        Log.i(TAG, "onUserVideoSubscribe l = " + l);
    }

    @Override
    public void onUserVideoMute(long l) {
        Log.i(TAG, "onUserVideoMute l = " + l);
    }

    @Override
    public void onUserVideoUnmute(long l) {
        Log.i(TAG, "onUserVideoUnmute l = " + l);
    }

    @Override
    public void onUserScreenStart(long l) {
        Log.i(TAG, "onUserScreenStart l = " + l);
    }

    @Override
    public void onUserScreenStop(long l) {
        Log.i(TAG, "onUserScreenStop l = " + l);
    }

    @Override
    public void onUserScreenSubscribe(long l, Constants.MediaSubscribeResult mediaSubscribeResult) {
        Log.i(TAG, "onUserScreenSubscribe l = " + l);
    }

    @Override
    public void onUserScreenMute(long l) {
        Log.i(TAG, "onUserScreenMute l = " + l);
    }

    @Override
    public void onUserScreenUnmute(long l) {
        Log.i(TAG, "onUserScreenUnmute l = " + l);
    }

    @Override
    public void onWhiteboardAvailable() {
        Log.i(TAG, "onWhiteboardAvailable");
    }

    @Override
    public void onWhiteboardUnavailable() {
        Log.i(TAG, "onWhiteboardUnavailable");
    }

    @Override
    public void onWhiteboardStart() {
        Log.i(TAG, "onWhiteboardStart");
    }

    @Override
    public void onWhiteboardStop() {
        Log.i(TAG, "onWhiteboardStop");
    }

    @Override
    public void onFirstAudioDataReceived(long l) {
        Log.i(TAG, "onFirstAudioDataReceived l = " + l);
    }

    @Override
    public void onFirstVideoDataReceived(long l) {
        Log.i(TAG, "onFirstVideoDataReceived l = " + l);
    }

    @Override
    public void onFirstScreenDataReceived(long l) {
        Log.i(TAG, "onFirstScreenDataReceived l = " + l);
    }

    @Override
    public void onAudioDeviceStateChanged(String s, Constants.AudioDeviceType audioDeviceType, Constants.AudioDeviceState audioDeviceState) {
        Log.i(TAG, "onAudioDeviceStateChanged s = " + s);
    }

    @Override
    public void onVideoDeviceStateChanged(String s, Constants.VideoDeviceType videoDeviceType, Constants.VideoDeviceState videoDeviceState) {
        Log.i(TAG, "onVideoDeviceStateChanged s = " + s);
    }

    @Override
    public void onChannelFailover(Constants.FailoverState failoverState) {
        Log.i(TAG, "onChannelFailover failoverState = " + failoverState);
        for (PanoEvent event : mPanoEventList) {
            event.onChannelFailover(failoverState);
        }
    }
}
