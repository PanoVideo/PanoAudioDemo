//
//  PanoClientInterface.h
//  PanoAudioChatSDK
//
//  Created by pano on 2021/7/15.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>


@protocol PanoSignalInterface <NSObject>

@required
/// 发送消息给房间中某个用户
- (BOOL)sendMessage:(NSDictionary<NSString *, id>*)msg toUser:(UInt64)userId;

/// 广播消息给房间中所有用户
- (BOOL)broadcastMessage:(NSDictionary<NSString *, id>*)msg;

/**
 * ## 根据Key设置属性
 -  important 后续加入房间的用户可以收到属性改变的回调通知
 */
- (BOOL)setProperty:(id)value forKey:(NSString *)key;

@end

