package video.pano.audiochat.rtc;

import android.util.LongSparseArray;

import java.util.ArrayList;
import java.util.List;

import video.pano.audiochat.PACApplication;
import video.pano.audiochat.R;
import video.pano.audiochat.rtc.data.PanoCmdUser;
import video.pano.audiochat.rtc.data.PanoUser;
import video.pano.audiochat.utils.Utils;

import static video.pano.audiochat.rtc.PanoTypeConstant.DEFAULT_MIC_SIZE;
import static video.pano.audiochat.rtc.PanoTypeConstant.MUTE;
import static video.pano.audiochat.rtc.PanoTypeConstant.NONE;

public class PanoUserMgr {
    // All User List
    private LongSparseArray<PanoUser> mUserList = new LongSparseArray<>();
    //HostUser Use
    private List<PanoCmdUser> mMicUserList = new ArrayList<>(8);
    //Apply User List
    private List<PanoCmdUser> mMicApplyUserList = new ArrayList<>();

    private LongSparseArray<PanoUser> mMuteUserList = new LongSparseArray<>();

    private static PanoUserMgr ins;

    private PanoUserMgr() {
    }

    public static PanoUserMgr getIns() {

        if (ins == null) {
            synchronized (PanoUserMgr.class) {
                ins = new PanoUserMgr();
            }
        }
        return ins;
    }

    public synchronized void addUser(long userId, PanoUser user) {
        mUserList.put(userId, user);
    }

    public synchronized PanoUser removeUser(long userId) {
        PanoUser user = mUserList.get(userId);
        mUserList.remove(userId);
        return user;
    }

    public synchronized void updateAllUserStatus(long userId, int micStatus) {
        PanoUser user = mUserList.get(userId);
        if (user == null) return;
        user.status = micStatus;
    }

    public synchronized int getUserStatus(long userId){
        PanoUser user = mUserList.get(userId);
        if (user == null) return NONE ;
        return user.status ;
    }

    public LongSparseArray<PanoUser> getUserList() {
        return mUserList;
    }

    public int getUserSize() {
        return mUserList.size();
    }

    public String getUserNameById(long userId) {
        PanoUser user = mUserList.get(userId);
        if (user == null) {
            return Utils.getApp().getString(R.string.room_user_unknown);
        }
        return user.userName;
    }

    public List<PanoCmdUser> getMicApplyList() {
        return mMicApplyUserList;
    }

    public synchronized void addMicApplyUser(PanoCmdUser user) {
        mMicApplyUserList.add(user);
    }

    public synchronized void removeMicApplyUser(long userId) {
        PanoCmdUser cmdUser = getMicApplyUser(userId);
        if (cmdUser == null) return;
        mMicApplyUserList.remove(cmdUser);
    }

    public synchronized PanoCmdUser getMicApplyUser(long userId) {
        for (PanoCmdUser user : mMicApplyUserList) {
            if (user.userId == userId) {
                return user;
            }
        }
        return null;
    }

    public int getMicApplyCount() {
        return mMicApplyUserList.size();
    }

    public void initMicList() {
        for (int i = 0; i < DEFAULT_MIC_SIZE; i++) {
            mMicUserList.add(new PanoCmdUser(i));
        }
    }

    public List<PanoCmdUser> getMicList() {
        return mMicUserList;
    }

    public synchronized PanoCmdUser getMicUser(long userId) {
        for (PanoCmdUser user : mMicUserList) {
            if (user.userId == userId) {
                return user;
            }
        }
        return null;
    }

    public synchronized int getMicUserStatus(long userId){
        PanoCmdUser cmdUser = getMicUser(userId);
        if(cmdUser != null){
            return cmdUser.status;
        }
        return -1 ;
    }

    public synchronized boolean hasUserAtPos(int order) {
        PanoCmdUser user = mMicUserList.get(order);
        return user != null && user.userId > 0;
    }

    public synchronized void addMicUser(PanoCmdUser user, int micStatus) {
        if (user == null) return;
        user.status = micStatus;
        mMicUserList.set(user.order, user);
    }

    public synchronized void updateMicUserStatus(long userId, int micStatus) {
        PanoCmdUser user = getMicUser(userId);
        if (user == null) return;
        switch (micStatus) {
            case PanoTypeConstant.NONE:
                user.recycle();
                break;
            default:
                user.status = micStatus;
                break;
        }
    }

    public void addMuteUser(long userId){
        PanoUser muteUser = mUserList.get(userId);
        addMuteUser(muteUser);
    }

    public void addMuteUser(PanoUser muteUser){
        if(muteUser == null ) return;
        mMuteUserList.put(muteUser.userId,muteUser);
    }

    public void removeMuteUser(long userId){
        mMuteUserList.remove(userId);
    }

    public PanoUser getMuteUser(long userId){
        return mMuteUserList.get(userId);
    }

    public boolean isMuteUser(long userId){
        return getMuteUser(userId) != null;
    }

    public void clear() {
        mUserList.clear();
        mMicApplyUserList.clear();
        mMicUserList.clear();
        mMuteUserList.clear();
    }
}
