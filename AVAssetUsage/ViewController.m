//
//  ViewController.m
//  AVAssetUsage
//
//  Created by zx on 10/20/16.
//  Copyright © 2016 z2xy. All rights reserved.
//

#import "ViewController.h"
#import "AVAssetViewController.h"
#import "UsingAssetsViewController.h"
#import "EditingViewController.h"

typedef void (^BlockAction)(void);

@interface ViewController ()
@property (nonatomic,strong) NSArray *dataArray;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    __weak typeof(self) weakSelf = self;
    self.dataArray = @[
                       @{
                           @"title":@"AVAsset AVMetadataItem AVAssetTrack",
                           @"action":^(void ){
                               AVAssetViewController *vc = [[AVAssetViewController alloc]init];
                               [weakSelf.navigationController pushViewController:vc animated:YES];
                           }
                        },
                       @{
                           @"title":@"UsingAssets",
                           @"action":^(void ){
                               UsingAssetsViewController *vc = [[UsingAssetsViewController alloc]init];
                               [weakSelf.navigationController pushViewController:vc animated:YES];
                           }
                        },
                       @{
                           @"title":@"Editing",
                           @"action":^(void ){
                               EditingViewController *vc = [[EditingViewController alloc]init];
                               [weakSelf.navigationController pushViewController:vc animated:YES];
                           }
                           },
                       ];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
}
- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.tableView reloadData];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.dataArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *SettingsCellIdentifier = @"testingCell";
    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:SettingsCellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:SettingsCellIdentifier];
    }
    cell.textLabel.text = [self.dataArray[indexPath.row] objectForKey:@"title"];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    BlockAction action = self.dataArray[indexPath.row][@"action"];
    if (action) {
        action();
    }
}
@end

