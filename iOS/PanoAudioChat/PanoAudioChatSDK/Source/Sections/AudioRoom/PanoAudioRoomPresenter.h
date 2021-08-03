//
//  PanoAudioRoomPresenter.h
//  PanoAudioChatSDK
//
//  Created by pano on 2021/7/19.
//

#import <Foundation/Foundation.h>
#import "PanoMicInfo.h"
#import "PanoClientConfig.h"
#import "PanoAudioRoomDataSource.h"
#import "PanoAudioPlayerView.h"

@protocol PanoMicCollectionCellDelegate;

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSInteger, PanoActionSheetType) {
    PanoActionMuteUser = 0,
    PanoActionUnmuteUser = 1,
    PanoActionKillUser = 2
};

@protocol PanoAudioRoomInterface <NSObject>
    
- (void)showInvitePage:(PanoMicInfo *)micInfo;

- (void)showApplyAlert:(void(^)(BOOL success))handler;

- (void)cancelApplyAlert;

- (void)showExitAlert:(NSString *_Nullable)message handler:(void(^)(BOOL success))handler;

- (void)showkickMicActionSheet:(BOOL)mute handler:(void(^)(PanoActionSheetType type))handler;

- (void)updateNaviTitleView;

- (void)updateHeaderView:(PanoUserInfo *)host;

- (void)showInvitedToast;

- (void)showToast:(NSString * _Nullable)message;

- (void)showInvitedAlert:(NSString * _Nullable)message handler:(void(^)(BOOL success, PanoCmdReason reason))handler;

- (void)showRejectedToast:(NSString * _Nullable)message;

- (void)updateApplyChatView:(NSArray<PanoMicInfo *> *)applyUsers;

- (void)reloadMicQueueView;

- (void)showAudioPanelView;

- (void)reloadControlView;

- (void)exitChat;

@end


@interface PanoAudioRoomPresenter : NSObject <PanoMicCollectionCellDelegate, PanoAudioPlayerDelegate>
{
    @package
    PanoAudioRoomDataSource *dataSource;
}

@property (nonatomic, weak) id <PanoAudioRoomInterface> delegate;

- (instancetype)initWithUserMode:(PanoUserMode)userMode;

- (void)stopMyChat;

- (void)accpetChat:(PanoMicInfo *)info;

- (void)rejectChat:(PanoMicInfo *)info reason:(PanoCmdReason)reason;

- (void)closeRoomMsg;

- (void)applyChat:(PanoMicInfo *)info;

- (void)cancelChat;

- (void)leaveRoom;

- (void)killUser:(PanoMicInfo *)info;

- (void)acceptInvite:(PanoMicInfo *)info;

- (void)rejectInvite:(PanoMicInfo *)info reason:(PanoCmdReason)reason;
@end

NS_ASSUME_NONNULL_END
