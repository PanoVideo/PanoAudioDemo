//
//  PanoAudioRoomPresenter.m
//  PanoAudioChatSDK
//
//  Created by pano on 2021/7/19.
//

#import "PanoAudioRoomPresenter.h"
#import "PanoClientService.h"
#import "PanoMicQueueView.h"
#import "PanoMessageDefine.h"
#import "PanoClientService+OpenApi.h"
#import "PanoClientService+App.h"

@interface PanoAudioRoomPresenter ()
<PanoMicCollectionCellDelegate,
PanoUserDelegate,
PanoClientDelegate>

@end

@implementation PanoAudioRoomPresenter {
    BOOL isFirstReceiveMicInfo;
}

- (instancetype)initWithUserMode:(PanoUserMode)userMode {
    self = [super init];
    if (self) {
        isFirstReceiveMicInfo = true;
        dataSource = [[PanoAudioRoomDataSource alloc] init];
        dataSource.userMode = userMode;
        __weak typeof(self) weakSelf = self;
        dataSource.applyBlock = ^(NSArray<PanoMicInfo *> * _Nonnull micInfos, PanoCmdReason reason) {
            [weakSelf reloadApplyView];
            for (id item in micInfos) {
                [weakSelf rejectChat:item reason:reason];
            }
        };
        [PanoClientService.service addDelegate:self];
        [PanoClientService.service.userService addDelegate:self];
    }
    return self;
}

#pragma mark -- PanoMicCollectionCellDelegate

- (void)onMicButtonPressed:(PanoMicInfo *)micInfo {
    __weak typeof(self) weakSelf = self;
    if (dataSource.userMode == PanoAnchor) {
        if (micInfo.status == PanoMicNone) {
            [_delegate showInvitePage:micInfo];
        } else if (micInfo.isOnline) {
            BOOL muteFlag = true;
            PanoUserInfo *user = micInfo.user;
            if (user) {
                muteFlag = user.audioStatus == PanoUserAudio_Unmute;
            }
            [_delegate showkickMicActionSheet:muteFlag handler:^(PanoActionSheetType type) {
                if (type == PanoActionKillUser) {
                    [weakSelf killUser:micInfo];
                } else if (type == PanoActionMuteUser) {
                    [weakSelf muteUser:micInfo];
                } else if (type == PanoActionUnmuteUser) {
                    [weakSelf unmuteUser:micInfo];
                }
            }];
        }
    } else {
        if (dataSource->myMicInfo.status == PanoMicConnecting) {
            // ???????????????????????????????????????
            return;
        }
        
        // ?????????????????????????????????????????????????????????
        if ((micInfo.isOnline || micInfo.status == PanoMicConnecting) &&
            micInfo.userId != dataSource->myMicInfo.userId ){
            return;
        }
        if (dataSource->myMicInfo.status == PanoMicNone) {
            __block PanoMicInfo *myMicInfo = dataSource->myMicInfo;
            [_delegate showApplyAlert:^(BOOL success) {
                myMicInfo.status = PanoMicConnecting;
                myMicInfo.order = micInfo.order;
                if (myMicInfo != nil) {
                    [self applyChat:myMicInfo];
                }
                // ??????????????????????????????...
            }];
        } else if (micInfo.status == PanoMicConnecting) {
            NSLog(@"%@ ?????????????????????", micInfo.user.userName);
        } else if  (micInfo.isOnline) {
            //????????????
            [_delegate exitChat];
        }
    }
}



- (void)onUserAdded:(PanoUserInfo *)user {
    [_delegate updateNaviTitleView];
}

- (void)onUserRemoved:(PanoUserInfo *)user {
    [self remove:user];
    [_delegate updateNaviTitleView];
    [_delegate reloadMicQueueView];
}

- (void)onUserPropertyChanged:(PanoUserInfo *)user {
    [self reloadView];
    PanoUserInfo *host = PanoClientService.service.userService.host;
    if (host) {
        [_delegate updateHeaderView:host];
    }
}

- (void)onUserAudioLevelChanged {
    [self onUserPropertyChanged:nil];
}

#pragma mark --PanoClientDelegate

- (void)showExitRoomAlert:(NSString *)message {
    NSString *msg = message != nil ?  message : NSLocalizedString(@"??????????????????", nil);
    [_delegate showExitAlert:msg handler:^(BOOL success) {
    }];
}

- (void)onPropertyChanged:(NSDictionary *)value forKey:(NSString *)key {
    if (![key isEqualToString:PanoAllMicKey]) {
        return;
    }
    PanoMicMessage *cmd = [[PanoMicMessage alloc] initWithDict:value];
    if (cmd == nil) {
        return;
    }
    
    if (PanoClientService.service.userService.isHost) {
        if (isFirstReceiveMicInfo) {
            isFirstReceiveMicInfo = false;
            [dataSource updateMicArrayWithMicInfos:cmd.data];
        }
        return;
    }
    BOOL found = false;
    for (PanoMicInfo *item in cmd.data) {
        if (item.userId == dataSource->myMicInfo.userId) {
            found = true;
        }
    }
    if (!found && dataSource->myMicInfo.isOnline ) {
        [PanoClientService.service.audioService muteAudio];
        [dataSource resetMyMic];
    }
    [dataSource updateMicArrayWithMicInfos:cmd.data];
    [self reloadView];
    
    switch (dataSource->myMicInfo.status) {
        case PanoMicFinished:
            [PanoClientService.service.audioService unmuteAudio];
            break;
        default:
            [PanoClientService.service.audioService muteAudio];
            break;
    }
}

- (void)reloadView {
    [_delegate reloadControlView];
    [_delegate reloadMicQueueView];
}

- (void)reloadApplyView {
    [_delegate updateApplyChatView:dataSource.allApplicants];
}

/// ???????????????????????????
- (void)updateAllMicStatus {
    NSDictionary *value = [[[PanoMicMessage alloc] initWithCmd:allMic data:dataSource.allMics reason:ok] toDictionary];
    [PanoClientService.service setProperty:value forKey:PanoAllMicKey];
}

- (void)onReceivedMessage:(NSDictionary<NSString *,id> *)message fromUser:(UInt64)userId {
    __weak typeof(self) weakSelf = self;
    PanoCmdMessage *cmdMsg = [[PanoCmdMessage alloc] initWithDict:message];
    if (cmdMsg && cmdMsg.cmd == closeRoom) {
        [PanoClientService.service uploadlogsAutomatically];
        [_delegate showExitAlert:nil handler:^(BOOL success) { }];
        [self leaveRoom];
    }
    PanoMicMessage *micMsg = [[PanoMicMessage alloc] initWithDict:message];
    if (!micMsg) {
        return;
    }
    PanoMicInfo *micInfo = [micMsg.data firstObject];
    if (!micInfo) {
        return;
    }
    PanoMicInfo *curMic = [dataSource micInfo:micInfo.order];
    if (!curMic) {
        return;
    }
    void(^rejectBlock)(PanoCmdReason reason) = ^(PanoCmdReason reason){
        PanoMicInfo *tempMicInfo = [[PanoMicInfo alloc] initWithMicInfo:micInfo];
        tempMicInfo.userId = userId;
        [self rejectChat:tempMicInfo reason:reason];
    };
    PanoUserInfo *fromUser = [PanoClientService.service.userService findUserWithId:userId];
    switch (micMsg.cmd) {
            // ?????????????????????????????????
        case applyChat:
        {
            if (![PanoClientService.service.userService isHost]) {
                return;
            }
            if (curMic.isOnline) {
                rejectBlock(occupied);
                return;
            }
            micInfo.status = PanoMicConnecting;
            [dataSource appendApplyUser:micInfo];
            [self reloadApplyView];
        }
            break;
            // ?????????????????????????????????
        case acceptChat:
        {
            if (dataSource->myMicInfo.userId == micInfo.userId) {
                [_delegate cancelApplyAlert];
                [self reloadView];
                [PanoClientService.service.audioService unmuteAudio];
            }
        }
            break;
            // ?????????????????????????????????
        case rejectChat:
        {
            if (dataSource->myMicInfo.userId == micInfo.userId) {
                [_delegate cancelApplyAlert];
                NSString *msg = nil;
                switch (micMsg.reason) {
                    case timeout:
                        msg = @"??????????????????????????????????????????";
                        break;
                    case occupied:
                        msg = @"?????????????????????";
                        break;
                    default:
                        msg = @"?????????????????????????????????";
                        break;
                }
                [_delegate showRejectedToast:[NSString stringWithFormat:NSLocalizedString(@"%@", nil), msg]];
                [dataSource resetMyMic];
            }
        }
            break;
            // ????????????????????????????????????
        case rejectInvite: {
            NSString *msg = [NSString stringWithFormat:@"'%@'%@", fromUser.userName, micMsg.reason == timeout ? NSLocalizedString(@"??????????????????????????????", nil) :
                             NSLocalizedString(@"?????????????????????", nil)];
            [_delegate showToast:msg];
        }
            break;
        case cancelChat: {
            if (fromUser != nil) {
                [self remove:fromUser];
            }
        }
            
            break;
        case stopChat: {
            [dataSource updateMicArrayWithMicInfo:[[PanoMicInfo alloc] initWithStatus:PanoMicNone userId:0 order:micInfo.order]];
            [self updateAllMicStatus];
            [self reloadView];
        }
            break;
        case killUser: {
            if (dataSource->myMicInfo.userId == micInfo.userId) {
                [PanoClientService.service.audioService muteAudio];
                [dataSource resetMyMic];
                NSString *msg = [NSString stringWithFormat:@"'%@'%@", fromUser.userName, NSLocalizedString(@"???????????????????????????", nil)];
                [_delegate showToast:msg];
            }
        }
            break;
            // ????????????????????????????????????
        case acceptInvite: {
            if (curMic.isOnline) {
                rejectBlock(occupied);
                return;
            }
            micInfo.status = PanoMicFinished;
            [dataSource updateMicArrayWithMicInfo:micInfo];
            [dataSource removeApplyUser:micInfo deleteAll:true];
            [self updateAllMicStatus];
            [self reloadView];
        }
            break;
        case inviteUser: {
            [_delegate showInvitedAlert:NSLocalizedString(@"?????????????????????", nil) handler:^(BOOL success, PanoCmdReason reason) {
                if (success) {
                    [weakSelf acceptInvite:micInfo];
                } else {
                    [weakSelf rejectInvite:micInfo reason:reason];
                }
            }];
        }
            break;
        default:
            break;
    }
}

- (void)remove:(PanoUserInfo *)user {
    if (PanoClientService.service.userService.isHost) {
        BOOL contain = [dataSource containUser:user];
        [dataSource removeApplyUser:user];
        [dataSource removeMicUser:user];
        [self reloadApplyView];
        if (contain) {
            [self updateAllMicStatus];
            [self reloadView];
        }
    }
}

#pragma mark -- Public Methods

- (void)stopMyChat {
    [self stopChat:dataSource->myMicInfo];
    [dataSource resetMyMic];
}

- (void)stopChat:(PanoMicInfo *)info {
    [PanoClientService.service.signalService sendStopChatMsg:info];
}

- (void)accpetChat:(PanoMicInfo *)info {
    [dataSource removeApplyUser:info deleteAll:true];
    PanoMicInfo *tempInfo = [[PanoMicInfo alloc] initWithMicInfo:info];
    tempInfo.status = PanoMicFinished;
    [dataSource updateMicArrayWithMicInfo:tempInfo];
    [self updateAllMicStatus];
    [self reloadView];
    [self reloadApplyView];
    [PanoClientService.service.signalService sendAcceptChatMsg:info];
}

- (void)rejectChat:(PanoMicInfo *)info reason:(PanoCmdReason)reason {
    [dataSource removeApplyUser:info deleteAll:false];
    [self reloadApplyView];
    [PanoClientService.service.signalService sendRejectChatMsg:info reason:reason];
}

- (void)closeRoomMsg {
    [PanoClientService.service.signalService sendCloseRoomMsg];
}

- (void)applyChat:(PanoMicInfo *)info {
    [PanoClientService.service.signalService sendApplyChatMsg:info];
    [self performSelector:@selector(checkMyApplyStatus) withObject:nil afterDelay:PanoMsgExpireInterval];
}

- (void)checkMyApplyStatus {
    if (dataSource->myMicInfo.status == PanoMicConnecting) {
        [_delegate cancelApplyAlert];
        [_delegate showRejectedToast:NSLocalizedString(@"??????????????????????????????????????????", nil)];
        [dataSource resetMyMic];
    }
}

- (void)cancelChat {
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(checkMyApplyStatus) object:nil];
    [PanoClientService.service.signalService sendCancelChatMsg:dataSource->myMicInfo];
    PanoMicInfo *tempInfo = [[PanoMicInfo alloc] init];
    tempInfo.userId = PanoClientService.service.userId;
    dataSource->myMicInfo = tempInfo;
}

- (void)muteUser:(PanoMicInfo *)info  {
    PanoMicInfo *temp = [[PanoMicInfo alloc] initWithMicInfo:info];
    temp.status = PanoMicFinishedMuted;
    [dataSource updateMicArrayWithMicInfo:temp];
    [self updateAllMicStatus];
}

- (void)unmuteUser:(PanoMicInfo *)info  {
    PanoMicInfo *tempInfo = [[PanoMicInfo alloc] initWithMicInfo:info];
    tempInfo.status = PanoMicFinished;
    [dataSource updateMicArrayWithMicInfo:tempInfo];
    [self updateAllMicStatus];
}

- (void)joinAudioRoom:(void(^)(bool))completion {
    //    clientService = PanoClientService.service()
    //    clientService.joinAudioRoom(config: clientService.config) { [weak self] (flag) in
    //        guard self = self else { return completion(false) }
    //        if (clientService.config.userMode == PanoUserMode.anchor {
    //            user = PanoUserInfo(userId: clientService.config.userId, userName: clientService.config.userName)
    //            self. _delegate updateHeaderView(host: user)
    //        }
    //        completion(flag)
    //        print("joinAudioRoom")
    //    }
}

- (void)leaveRoom {
    [_delegate cancelApplyAlert];
    _delegate = nil;
    [PanoClientService.service leaveAudioRoom];
}
/// ?????????????????????????????????
- (void)killUser:(PanoMicInfo *)info {
    [dataSource removeMicArray:info];
    [self updateAllMicStatus];
    [PanoClientService.service.signalService sendkillMsg:info];
    [self reloadView];
}

/// ??????????????????
- (void)acceptInvite:(PanoMicInfo *)info {
    [PanoClientService.service.signalService sendAcceptInviteMsg:info];
}

/// ??????????????????
- (void)rejectInvite:(PanoMicInfo *)info reason:(PanoCmdReason)reason {
    [PanoClientService.service.signalService sendRejectInviteMsg:info reason:reason];
}

#pragma mark -- PanoAudioPlayerDelegate

- (void)didChooseNextAction {
    [PanoClientService.service.playerService chooseNextAction];
}

- (void)didStartPlayAction:(BOOL)pause {
    [PanoClientService.service.playerService startPlayAction:pause];
}

- (void)didShowMoreAction {
    [_delegate showAudioPanelView];
}

@end


