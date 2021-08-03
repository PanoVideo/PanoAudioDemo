//
//  PanoMicCollectionCell.m
//  PanoAudioChatSDK
//
//  Created by pano on 2021/7/19.
//

#import "PanoMicCollectionCell.h"
#import "PanoMicButton.h"
#import <Masonry/Masonry.h>
#import "PanoClientService.h"
#import "UIImage+Extension.h"

@implementation PanoMicCollectionCell
{
    PanoMicButton *micButton;
    
    UILabel *nameLabel;
    
    UIImageView *audioImage;
    
    UIButton *moreButton;
    
    PanoMicInfo *micInfo;
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        nameLabel = [UILabel new];
        nameLabel.textColor = [UIColor whiteColor];
        nameLabel.textAlignment = NSTextAlignmentCenter;
        nameLabel.font = [UIFont systemFontOfSize:14];
        nameLabel.text = NSLocalizedString(@"申请上麦", nil);
        [self.contentView addSubview: nameLabel];
        
        micButton = [PanoMicButton buttonWithType:UIButtonTypeCustom];
        [micButton addTarget:self action:@selector(micClickAction) forControlEvents:UIControlEventTouchUpInside];
        [micButton setImage:[UIImage imageNamed:@"room_invite"] forState:UIControlStateNormal];
        [self.contentView  addSubview: micButton];
        
        audioImage = [UIImageView new];
        audioImage.image = [UIImage imageNamed:@"room_audio_mute"];
        audioImage.hidden = true;
        [self.contentView addSubview: audioImage];
        
        moreButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [moreButton addTarget:self action:@selector(moreButtonAction) forControlEvents:UIControlEventTouchUpInside];
        [moreButton setImage:[UIImage imageNamed:@"room_audio_mute"] forState:UIControlStateNormal];
        moreButton.hidden = true;
        [self.contentView  addSubview: moreButton];
        
        [micButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.centerX.mas_equalTo(0);
            make.size.mas_equalTo(CGSizeMake(60, 60));
            make.height.mas_equalTo(micButton.mas_width);
        }];
        
        [audioImage mas_makeConstraints:^(MASConstraintMaker *make) {
            make.size.mas_equalTo(CGSizeMake(20, 20));
            make.top.mas_equalTo(micButton.mas_bottom).offset(-10);
            make.centerX.mas_equalTo(micButton);
        }];
        
        [nameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.left.right.mas_equalTo(0);
            make.bottom.mas_equalTo(0).offset(-5);
        }];
        
        [moreButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.top.mas_equalTo(micButton).insets(UIEdgeInsetsMake(20 ,20, 0, 0));
            make.size.mas_equalTo(CGSizeMake(19, 19));
        }];
    }
    return self;
}
    
- (void)micClickAction {
    [_delegate onMicButtonPressed:micInfo];
}
    
- (void)moreButtonAction {
        
}

- (void)updateMicInfo:(PanoMicInfo *)info {
    micInfo = info;
    audioImage.hidden = true;
    moreButton.hidden = true;
    switch (micInfo.status) {
        case PanoMicNone:
            [micButton setImage:[UIImage imageNamed:@"room_invite"] forState:UIControlStateNormal];
            if (PanoClientService.service.userService.isHost) {
                nameLabel.text = NSLocalizedString(@"邀请上麦", nil);
            } else {
                nameLabel.text = NSLocalizedString(@"申请上麦", nil);
            }
            [micButton stopAnimating];
            break;
        case PanoMicConnecting:
        case PanoMicFinished:
        case PanoMicFinishedMuted: {
            if (micInfo.status == PanoMicConnecting) {
                nameLabel.text = NSLocalizedString(@"申请中...", nil);
                [micButton stopAnimating];
            }
            PanoUserInfo *user = info.user;
            if (user)  {
                [micButton setImage:[user avatorImage] forState:UIControlStateNormal];
                [micButton setImage:[user avatorImage] forState:UIControlStateHighlighted];
                if (micInfo.isOnline) {
                    audioImage.hidden = user.audioStatus == PanoUserAudio_Unmute;
                    nameLabel.text = user.userName;
                    if (micInfo.user.isActiving) {
                        [micButton startAnimating];
                    } else {
                        [micButton stopAnimating];
                    }
                }
            }  else {
                [micButton setImage:[UIImage imageNamed:@"room_invite"] forState:UIControlStateNormal];
            }
        }
            break;
    default:
        [micButton setImage:[UIImage imageNamed:@"room_invite"] forState:UIControlStateNormal];
            break;
    }
}

@end
