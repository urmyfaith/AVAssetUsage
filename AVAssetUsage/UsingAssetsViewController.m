//
//  UsingAssetsViewController.m
//  AVAssetUsage
//
//  Created by zx on 10/20/16.
//  Copyright © 2016 z2xy. All rights reserved.
//

#import "UsingAssetsViewController.h"

@import AVFoundation;
@import Photos;

@interface UsingAssetsViewController ()
@property(nonatomic, strong) AVAsset *asset;
@end

@implementation UsingAssetsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    
    [self Creating_an_Asset_Object];

    [self Options_for_Initializing_an_Asset];

    [self Accessing_the_Users_Assets];

    [self Preparing_an_Asset_for_Use];

    [self Getting_Still_Images_From_a_Video];

    [self Generating_a_Single_Image];
}

-(void)Creating_an_Asset_Object
{
    NSString *mediaPath = [[NSBundle mainBundle] pathForResource:@"Sketch" ofType:@"mp4"];

    NSURL *mediaURL = [NSURL fileURLWithPath:mediaPath];

    AVURLAsset *anAsset = [[AVURLAsset alloc] initWithURL:mediaURL options:nil];

    ZXLog(@"anAsset=%@",anAsset);
}

-(void)Options_for_Initializing_an_Asset
{
    NSString *mediaPath = [[NSBundle mainBundle] pathForResource:@"Sketch" ofType:@"mp4"];

    NSURL *mediaURL = [NSURL fileURLWithPath:mediaPath];

    NSDictionary *options = @{ AVURLAssetPreferPreciseDurationAndTimingKey : @YES };
    AVURLAsset *anAssetToUseInAComposition = [[AVURLAsset alloc] initWithURL:mediaURL options:options];

    ZXLog(@"anAssetToUseInAComposition=%@",anAssetToUseInAComposition);
}

-(void)Accessing_the_Users_Assets
{

}

-(void)Preparing_an_Asset_for_Use
{
    NSString *mediaPath = [[NSBundle mainBundle] pathForResource:@"Sketch" ofType:@"mp4"];

    NSURL *mediaURL = [NSURL fileURLWithPath:mediaPath];

    AVURLAsset *anAsset = [[AVURLAsset alloc] initWithURL:mediaURL options:nil];
    NSArray *keys = @[@"duration"];

    [anAsset loadValuesAsynchronouslyForKeys:keys completionHandler:^() {

        NSError *error = nil;

        AVKeyValueStatus tracksStatus = [anAsset statusOfValueForKey:@"duration" error:&error];
        ZXLog(@"tracksStatus = %zd",tracksStatus);
        switch (tracksStatus) {
            case AVKeyValueStatusUnknown:
                break;
            case AVKeyValueStatusLoading:
                break;
            case AVKeyValueStatusLoaded:
                self.asset = anAsset;
                break;
            case AVKeyValueStatusFailed:
                break;
            case AVKeyValueStatusCancelled:
                break;
        }
    }];
}

-(void)Getting_Still_Images_From_a_Video
{
    if ([[self.asset tracksWithMediaType:AVMediaTypeVideo] count] > 0) {
        AVAssetImageGenerator *imageGenerator =  [AVAssetImageGenerator assetImageGeneratorWithAsset:self.asset];

         imageGenerator = imageGenerator;
        //从 Generator 可以生成单张和多张图片.
    }
}

-(void)Generating_a_Single_Image
{
    NSString *mediaPath = [[NSBundle mainBundle] pathForResource:@"Sketch" ofType:@"mp4"];

    NSURL *mediaURL = [NSURL fileURLWithPath:mediaPath];

    AVURLAsset *anAsset = [[AVURLAsset alloc] initWithURL:mediaURL options:nil];
    NSArray *keys = @[@"duration"];

    [anAsset loadValuesAsynchronouslyForKeys:keys completionHandler:^() {

        NSError *error = nil;

        AVKeyValueStatus tracksStatus = [anAsset statusOfValueForKey:@"duration" error:&error];
        ZXLog(@"tracksStatus = %zd",tracksStatus);
        switch (tracksStatus) {
            case AVKeyValueStatusUnknown:
                break;
            case AVKeyValueStatusLoading:
                break;
            case AVKeyValueStatusLoaded:
                self.asset = anAsset;
                break;
            case AVKeyValueStatusFailed:
                break;
            case AVKeyValueStatusCancelled:
                break;
        }


        AVAssetImageGenerator *imageGenerator = [[AVAssetImageGenerator alloc] initWithAsset:anAsset];

        CMTime duration = [anAsset duration];
        
        CMTime midpoint = CMTimeMake(duration.value/2.0, duration.timescale);
        NSError *error2;
        CMTime actualTime;

        CGImageRef halfWayImage = [imageGenerator copyCGImageAtTime:midpoint actualTime:&actualTime error:&error2];

        if (halfWayImage != NULL) {

            NSString *actualTimeString = (NSString *)CFBridgingRelease(CMTimeCopyDescription(NULL, actualTime));
            NSString *requestedTimeString = (NSString *)CFBridgingRelease(CMTimeCopyDescription(NULL, midpoint));
            ZXLog(@"Got halfWayImage: Asked for %@, got %@", requestedTimeString, actualTimeString);

            UIImage *image = [UIImage imageWithCGImage:halfWayImage];

            ZXLog(@"image = %@",image);
            // Do something interesting with the image.
            CGImageRelease(halfWayImage);
        }

    }];
}
@end
