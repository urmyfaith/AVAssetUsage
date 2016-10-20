//
//  UsingAssetsViewController.m
//  AVAssetUsage
//
//  Created by zx on 10/20/16.
//  Copyright © 2016 z2xy. All rights reserved.
//

#import "UsingAssetsViewController.h"
#import <MobileCoreServices/UTType.h>

@import AVFoundation;
@import Photos;

@interface UsingAssetsViewController ()
@property(nonatomic, strong) AVAsset *asset;

@property(nonatomic, strong) AVAssetImageGenerator *imageGenerator;

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

    [self Generating_a_Sequence_of_Images];

    [self Trimming_and_Transcoding_a_Movie];
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

        if (tracksStatus != AVKeyValueStatusLoaded) {
            return ;
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

-(void)Generating_a_Sequence_of_Images
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

        if (tracksStatus != AVKeyValueStatusLoaded) {
            return ;
        }

        self.imageGenerator = [AVAssetImageGenerator assetImageGeneratorWithAsset:anAsset];

        CMTime duration = [anAsset duration];

        Float64 durationSeconds = CMTimeGetSeconds(duration);

        CMTime firstThird = CMTimeMakeWithSeconds(durationSeconds/3.0, duration.timescale);
        CMTime secondThird = CMTimeMakeWithSeconds(durationSeconds*2.0/3.0, duration.timescale);
        CMTime end = CMTimeMakeWithSeconds(durationSeconds, duration.timescale);

        NSArray *times = @[
                           [NSValue valueWithCMTime:kCMTimeZero],
                           [NSValue valueWithCMTime:firstThird],
                           [NSValue valueWithCMTime:secondThird],
                           [NSValue valueWithCMTime:end]];

        [self.imageGenerator generateCGImagesAsynchronouslyForTimes:times completionHandler:^(CMTime requestedTime, CGImageRef  image, CMTime actualTime, AVAssetImageGeneratorResult result, NSError * error) {

            NSString *requestTimeString = (NSString *)CFBridgingRelease(CMTimeCopyDescription(NULL, requestedTime));
            NSString *actualTimeString = (NSString *)CFBridgingRelease(CMTimeCopyDescription(NULL, actualTime));
            ZXLog(@"RequestedTime:%@ actualTime:%@",requestTimeString,actualTimeString);

            switch (result) {
                case AVAssetImageGeneratorSucceeded:
                {
                    UIImage *imageFromCGImage = [UIImage imageWithCGImage:image];
                    ZXLog(@"image = %@",imageFromCGImage);
                    // Do something interesting with the image.
                    break;
                }
                case AVAssetImageGeneratorCancelled:
                {
                    break;
                }
                case AVAssetImageGeneratorFailed:
                {
                    break;
                }
            }

        }];

    }];
}

+ (NSString *)getDocumentPath{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    return documentsDirectory;
}

+ (NSString *)exportFilePath {

    NSString *filePath = [[self getDocumentPath] stringByAppendingPathComponent:@"exportFilePath.mp4"];
    return filePath;
}

+ (BOOL)deleteFileAtPath:(NSString *)itemPath error:(NSError **)error {

    BOOL status = YES;

    NSFileManager *fm = [NSFileManager defaultManager];

    if ([fm fileExistsAtPath:itemPath]) {
        status =  [fm removeItemAtPath:itemPath error:error];
    }
    return status;
}

-(NSString *)exportFullFilePath
{
    NSString *filePath = [UsingAssetsViewController exportFilePath];
    if ([UsingAssetsViewController deleteFileAtPath:filePath error:nil]) {
        return filePath;
    }
    return filePath;
}

-(void)Trimming_and_Transcoding_a_Movie
{
    NSString *mediaPath = [[NSBundle mainBundle] pathForResource:@"Sketch" ofType:@"mp4"];

    NSURL *mediaURL = [NSURL fileURLWithPath:mediaPath];

    AVURLAsset *anAsset = [[AVURLAsset alloc] initWithURL:mediaURL options:nil];
    NSArray *keys = @[@"exportable",@"duration"];

    [anAsset loadValuesAsynchronouslyForKeys:keys completionHandler:^() {

        NSError *error = nil;

        AVKeyValueStatus tracksStatus = [anAsset statusOfValueForKey:@"exportable" error:&error];
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

        if (tracksStatus != AVKeyValueStatusLoaded) {
            return ;
        }
        
        NSArray<NSString *> *compatiblePresets = [AVAssetExportSession exportPresetsCompatibleWithAsset:anAsset];
        ZXLog(@"compatiblePresets = %@",compatiblePresets);

        if ([compatiblePresets containsObject:AVAssetExportPreset960x540]) {
            AVAssetExportSession *exportSession = [[AVAssetExportSession alloc]
                                                   initWithAsset:anAsset presetName:AVAssetExportPreset960x540];

            //必须设置目标路径
            NSURL *targetURL = [NSURL fileURLWithPath:[self exportFullFilePath]];
            exportSession.outputURL = targetURL;

            //可选配置,可以从targetURL的后缀中推断出来
            exportSession.outputFileType = AVFileTypeQuickTimeMovie;

            //可选配置,默认值 kCMTimeZero..kCMTimePositiveInfinity,代表全部导出.
            CMTime videoDuration = [anAsset duration];
            CMTime start = CMTimeMakeWithSeconds(1.0, videoDuration.timescale);
            CMTime duration = CMTimeMakeWithSeconds(3.0, videoDuration.timescale);
            CMTimeRange range = CMTimeRangeMake(start, duration);
            exportSession.timeRange = range;

            [exportSession exportAsynchronouslyWithCompletionHandler:^{
                AVAssetExportSessionStatus status = [exportSession status];
                switch (status) {
                    case AVAssetExportSessionStatusFailed:

                        break;
                    case AVAssetExportSessionStatusCancelled:
                        NSLog(@"Export canceled");
                        break;
                    default:
                        break;
                }

                switch (status) {
                    case AVAssetExportSessionStatusUnknown: {
                        ZXLog(@"AVAssetExportSessionStatusUnknown")
                        break;
                    }
                    case AVAssetExportSessionStatusWaiting: {
                         ZXLog(@"AVAssetExportSessionStatusWaiting")
                        break;
                    }
                    case AVAssetExportSessionStatusExporting: {
                         ZXLog(@"AVAssetExportSessionStatusExporting")
                        break;
                    }
                    case AVAssetExportSessionStatusCompleted: {
                        ZXLog(@"AVAssetExportSessionStatusCompleted")
                        break;
                    }
                    case AVAssetExportSessionStatusFailed: {
                        ZXLog(@"Export failed: %@", [[exportSession error] localizedDescription]);
                        break;
                    }
                    case AVAssetExportSessionStatusCancelled: {
                        ZXLog(@"AVAssetExportSessionStatusCancelled")
                        break;
                    }
                }
            }];
        }
    }];

    /*
     (lldb) po compatiblePresets
     <__NSArrayI 0x7fdb9bd54610>(
     AVAssetExportPreset1920x1080,
     AVAssetExportPresetLowQuality,
     AVAssetExportPresetAppleM4A,
     AVAssetExportPreset640x480,
     AVAssetExportPresetHighestQuality,
     AVAssetExportPreset1280x720,
     AVAssetExportPresetMediumQuality,
     AVAssetExportPreset960x540
     )

     */

    /*
     typedef NS_ENUM(NSInteger, AVAssetExportSessionStatus) {
         AVAssetExportSessionStatusUnknown,
         AVAssetExportSessionStatusWaiting,
         AVAssetExportSessionStatusExporting,
         AVAssetExportSessionStatusCompleted,
         AVAssetExportSessionStatusFailed,
         AVAssetExportSessionStatusCancelled
     };
     */
}
@end
