//
//  PanoVoiceTableController.m
//  PanoAudioChat
//
//  Created by pano on 2021/7/22.
//

#import "PanoVoiceTableController.h"
#import "PanoClientService.h"

@interface PanoVoiceTableController ()

@end

@implementation PanoVoiceTableController {
    PanoAudioVoiceChangerOption selectedIndex;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    selectedIndex = PanoClientService.service.audioVoiceChanger;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    cell.accessoryType = indexPath.row == selectedIndex ? UITableViewCellAccessoryCheckmark : UITableViewCellAccessoryNone;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:true];
    selectedIndex = indexPath.row;
    [tableView reloadData];
}
- (IBAction)finish:(id)sender{
    PanoClientService.service.audioVoiceChanger = selectedIndex;
    [self pop:nil];
}

- (IBAction)pop:(id)sender {
    [self dismissViewControllerAnimated:true completion:nil];
}
@end
