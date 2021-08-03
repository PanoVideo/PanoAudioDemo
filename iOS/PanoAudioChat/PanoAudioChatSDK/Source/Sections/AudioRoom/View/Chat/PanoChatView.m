//
//  PanoChatView.m
//  PanoAudioChatSDK
//
//  Created by pano on 2021/7/19.
//

#import "PanoChatView.h"
#import "PanoMessage.h"
#import "PanoChatTextCell.h"
#import "PanoClientService.h"

@interface PanoChatView () <UITableViewDataSource, UITableViewDelegate, PanoChatDelegate>

@end

@implementation PanoChatView {
    
    UITableView *tableView;

    NSMutableArray <PanoMessage *>* dataSource;

    NSMutableArray <PanoMessage *>* pendingMessages;

    void *specificKey;
    
    dispatch_queue_t receiveMessageQueue;
}


- (void)initViews {
    tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
    [tableView registerClass:[PanoChatTextCell class] forCellReuseIdentifier:@"cellID"];
    tableView.tableFooterView = [UIView new];
    tableView.tableHeaderView = [UIView new];
    tableView.dataSource = self;
    tableView.delegate = self;
    tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    tableView.backgroundColor = [UIColor clearColor];
    tableView.showsVerticalScrollIndicator = false;
    tableView.allowsSelection = false;
    [self addSubview: tableView];
    
}

- (void)initConstraints {
    [tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(0);
    }];
}

- (void)start {
    dataSource = [NSMutableArray array];
    pendingMessages = [NSMutableArray array];
    receiveMessageQueue = dispatch_queue_create("com.pvc.receiveMessageQueue", NULL);
    [PanoClientService.service.chatService start];
    PanoClientService.service.chatService.delegate = self;
}

#pragma mark -- PanoChatDelegate
- (void)onReceiveMessage:(PanoMessage *)msg {
    dispatch_async(receiveMessageQueue, ^{
        NSUInteger count = self->pendingMessages.count;
        [self->pendingMessages addObject:msg];
        if (count == 0) {
            [self processPendingMessages];
        }
    });
}

- (void)processPendingMessages {
    NSUInteger count = pendingMessages.count;
    if (count == 0) {
        return;
    }
    __block CGFloat width = 0.0;
    pano_main_sync_safe(^{
        if (self->tableView.isDecelerating || self->tableView.isDragging) {
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), self->receiveMessageQueue, ^{
                [self processPendingMessages];
            });
            return;
        }
        width = self->tableView.bounds.size.width - 50;
    });
    for (NSInteger index=0; index<pendingMessages.count; index++) {
        [pendingMessages[index] caculateWidth:width];
    }
    NSArray *result = [[NSArray alloc] initWithArray:pendingMessages copyItems:true];
    [pendingMessages removeAllObjects];
    dispatch_async(dispatch_get_main_queue(), ^{
        [self addMessages:result];
    });
}

- (void)addMessages:(NSArray<PanoMessage *> *)messages {
    NSUInteger count = dataSource.count;
    [dataSource addObjectsFromArray:messages];
    NSMutableArray *inserts = [NSMutableArray array];
    
    for (NSInteger i=count; i<count+messages.count; i++) {
        [inserts addObject:[NSIndexPath indexPathForRow:i inSection:0]];
    }
    [tableView beginUpdates];
    [tableView insertRowsAtIndexPaths:inserts withRowAnimation:UITableViewRowAnimationFade];
    [tableView endUpdates];
    [tableView layoutIfNeeded];
    [tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:dataSource.count - 1 inSection:0] atScrollPosition:UITableViewScrollPositionBottom animated:true];
}


#pragma mark -- UITableViewDataSource, UITableViewDelegate
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return dataSource.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    PanoChatTextCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cellID" forIndexPath:indexPath];
    PanoMessage *message = dataSource[indexPath.row];
    cell->contentLabel.text = message.content;
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    PanoMessage * message = dataSource[indexPath.row];
    CGFloat height = message.size.height + 20;
    return height;
}

@end
