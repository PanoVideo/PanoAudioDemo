//
//  PanoClientService+App.h
//  PanoAudioChatSDK
//
//  Created by pano on 2021/7/15.
//

#import "PanoClientService.h"

NS_ASSUME_NONNULL_BEGIN

@interface PanoClientService (App)

- (void)loadPreferences;

- (void)savePreferences;

- (void)uploadlogsAutomatically;

- (void)sendFeedback:(PanoFeedbackType)type
              detail:(NSString *)detail
          uploadLogs:(BOOL)uploadLogs
             contact:(NSString *)contact;

- (void)notifyOthersUploadLogs:(PanoFeedbackType)type
                       message:(NSString *)message;

+ (NSString *)productVersion;

- (void)fetchTokenWithCompletionHandler:(void (^)(NSString *token, UInt64 hostUserId, NSError * error))completionHandler;

@end

NS_ASSUME_NONNULL_END
