//
//  EditingViewController.m
//  AVAssetUsage
//
//  Created by zx on 10/21/16.
//  Copyright © 2016 z2xy. All rights reserved.
//

// https://developer.apple.com/library/content/documentation/AudioVideo/Conceptual/AVFoundationPG/Articles/03_Editing.html#//apple_ref/doc/uid/TP40010188-CH8-SW1

@import AVFoundation;

#import "EditingViewController.h"
#import <MobileCoreServices/UTType.h>

@interface EditingViewController ()

@end

@implementation EditingViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];

//    [self Creating_a_Composition];
//
//    [self Options_for_Initializing_a_Composition_Track];
//
//    [self Adding_Audiovisual_Data_to_a_Composition];
//
//    [self Retrieving_Compatible_Composition_Tracks];


//    [self Generating_a_Volume_Ramp];//只有音频轨道

//    [self Generating_a_Volume_Ramp_Verison_2];//音频+视频轨道

    [self Changing_the_Compositions_Backgournd_Color];//改变背景颜色

//    [self Applying_Opacity_Ramps];
//    [self Applying_Opacity_Ramps_Version_2];
//    [self Combining_Multiple_Assets_and_Saving_the_Result_to_the_Camera_Roll];
}

-(AVURLAsset *)Creating_an_Asset_Object
{
    NSString *mediaPath = [[NSBundle mainBundle] pathForResource:@"Sketch" ofType:@"mp4"];

    NSURL *mediaURL = [NSURL fileURLWithPath:mediaPath];

    AVURLAsset *anAsset = [[AVURLAsset alloc] initWithURL:mediaURL options:nil];

    ZXLog(@"anAsset=%@",anAsset);
    return anAsset;
}

-(void)Creating_a_Composition
{
    AVMutableComposition *mutableCompostition = [AVMutableComposition composition];

    AVMutableCompositionTrack *mutableCompositionVideoTrack = [mutableCompostition addMutableTrackWithMediaType:AVMediaTypeVideo preferredTrackID:kCMPersistentTrackID_Invalid];

    AVMutableCompositionTrack *mutableCompositionAudioTrack = [mutableCompostition addMutableTrackWithMediaType:AVMediaTypeAudio preferredTrackID:kCMPersistentTrackID_Invalid];

    ZXLog(@"mutableCompositionVideoTrack = %@\nmutableCompositionAudioTrack = %@ ",mutableCompositionVideoTrack,mutableCompositionAudioTrack);
}

-(void)Options_for_Initializing_a_Composition_Track
{
    //组件类型还有之类的.
    // AVMediaTypeSubtitle
    // AVMediaTypeText

    //kCMPersistentTrackID_Invalid
    //自动生成一个响应的 TrackID.

    //  If you specify kCMPersistentTrackID_Invalid as the preferred track ID,
    // a unique identifier is automatically generated for you and associated with the track.
}

-(void)Adding_Audiovisual_Data_to_a_Composition
{
    AVMutableComposition *mutableComposition = [AVMutableComposition composition];

    AVMutableCompositionTrack *mutableCompositionVideoTrack = [mutableComposition addMutableTrackWithMediaType:AVMediaTypeVideo preferredTrackID:kCMPersistentTrackID_Invalid];

    AVMutableCompositionTrack *mutableCompositionAudioTrack = [mutableComposition addMutableTrackWithMediaType:AVMediaTypeAudio preferredTrackID:kCMPersistentTrackID_Invalid];

    AVAsset *videoAsset = [self Creating_an_Asset_Object];
    AVAsset *anotherVideoAsset = [self Creating_an_Asset_Object];

    AVAssetTrack *videoAssetTrack = [[videoAsset tracksWithMediaType:AVMediaTypeVideo] firstObject];
    AVAssetTrack *anotherVideoAssetTrack = [[anotherVideoAsset tracksWithMediaType:AVMediaTypeVideo] firstObject];

    [mutableCompositionVideoTrack insertTimeRange:CMTimeRangeMake(kCMTimeZero, videoAssetTrack.timeRange.duration)
                                          ofTrack:videoAssetTrack
                                           atTime:kCMTimeZero
                                            error:nil];
    [mutableCompositionVideoTrack insertTimeRange:CMTimeRangeMake(kCMTimeZero, anotherVideoAssetTrack.timeRange.duration)
                                          ofTrack:anotherVideoAssetTrack
                                           atTime:videoAssetTrack.timeRange.duration
                                            error:nil];
}

-(void)Retrieving_Compatible_Composition_Tracks
{
    AVMutableComposition *mutableComposition = [AVMutableComposition composition];

    AVAsset *videoAsset = [self Creating_an_Asset_Object];
    AVAssetTrack *videoAssetTrack = [[videoAsset tracksWithMediaType:AVMediaTypeVideo] firstObject];

    AVMutableCompositionTrack *compatibleCompositionTrack = [mutableComposition mutableTrackCompatibleWithTrack:videoAssetTrack];
    if (compatibleCompositionTrack) {
        // Implementation continues.
    }
}

-(void)Generating_a_Volume_Ramp
{

    //资源
    AVAsset *videoAsset = [self Creating_an_Asset_Object];

    //音频轨道
    AVAssetTrack *audioAssetTrack = [[videoAsset tracksWithMediaType:AVMediaTypeAudio] firstObject];

    //组件
    AVMutableComposition *mutableComposition = [AVMutableComposition composition];

    //音频组件轨
    AVMutableCompositionTrack *mutableCompositionAudioTrack = [mutableComposition addMutableTrackWithMediaType:AVMediaTypeAudio preferredTrackID:kCMPersistentTrackID_Invalid];

    //将音频轨 放到 音频组建轨 上.
    [mutableCompositionAudioTrack insertTimeRange:CMTimeRangeMake(kCMTimeZero, audioAssetTrack.timeRange.duration)
                                          ofTrack:audioAssetTrack
                                           atTime:kCMTimeZero
                                            error:nil];

    //音频混合
    AVMutableAudioMix *mutableAudioMix = [AVMutableAudioMix audioMix];

    //音频输入混合参数
    AVMutableAudioMixInputParameters *mixParameters = [AVMutableAudioMixInputParameters audioMixInputParametersWithTrack:mutableCompositionAudioTrack];
    [mixParameters setVolumeRampFromStartVolume:1.0 toEndVolume:0.0 timeRange:CMTimeRangeMake(kCMTimeZero, mutableComposition.duration)];

    mutableAudioMix.inputParameters = @[mixParameters];

    static NSDateFormatter *kDateFormatter;
    if (!kDateFormatter) {
        kDateFormatter = [[NSDateFormatter alloc] init];
        [kDateFormatter setDateFormat:@"yyyy-MM-dd-HH-mm-ss"];
    }

    AVAssetExportSession *exporter = [[AVAssetExportSession alloc] initWithAsset:mutableComposition presetName:AVAssetExportPresetHighestQuality];

    NSURL *saveURL = [[NSFileManager defaultManager] URLForDirectory:NSDocumentDirectory inDomain:NSUserDomainMask appropriateForURL:nil create:YES error:nil];

    saveURL = [saveURL URLByAppendingPathComponent:[kDateFormatter stringFromDate:[NSDate date]]];

    NSString *fileExtensitionString  = CFBridgingRelease(UTTypeCopyPreferredTagWithClass((CFStringRef)AVFileTypeQuickTimeMovie, kUTTagClassFilenameExtension));

    saveURL = [saveURL URLByAppendingPathExtension:fileExtensitionString];

    ZXLog(@"save url:%@",saveURL);

    exporter.outputURL = saveURL;

    exporter.outputFileType = AVFileTypeQuickTimeMovie;
    exporter.shouldOptimizeForNetworkUse = YES;
    exporter.audioMix = mutableAudioMix;
    
    [exporter exportAsynchronouslyWithCompletionHandler:^{
        dispatch_async(dispatch_get_main_queue(), ^{
            AVAssetExportSessionStatus status = exporter.status;
            ZXLog(@"exporter status = %zd",status);
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
                    if (UIVideoAtPathIsCompatibleWithSavedPhotosAlbum(saveURL.path)) {
                        UISaveVideoAtPathToSavedPhotosAlbum(saveURL.path, self, @selector(video:didFinishSavingWithError:contextInfo:), nil);
                    }
                    break;
                }
                case AVAssetExportSessionStatusFailed: {
                    ZXLog(@"Export failed: %@", [[exporter error] localizedDescription]);
                    break;
                }
                case AVAssetExportSessionStatusCancelled: {
                    ZXLog(@"AVAssetExportSessionStatusCancelled")
                    break;
                }
            }
        });
    }];

}

-(NSURL *)generate_save_url
{
    static NSDateFormatter *kDateFormatter;
    if (!kDateFormatter) {
        kDateFormatter = [[NSDateFormatter alloc] init];
        [kDateFormatter setDateFormat:@"yyyy-MM-dd-HH-mm-ss"];
    }

    NSURL *saveURL = [[NSFileManager defaultManager] URLForDirectory:NSDocumentDirectory inDomain:NSUserDomainMask appropriateForURL:nil create:YES error:nil];

    saveURL = [saveURL URLByAppendingPathComponent:[kDateFormatter stringFromDate:[NSDate date]]];

    NSString *fileExtensitionString  = CFBridgingRelease(UTTypeCopyPreferredTagWithClass((CFStringRef)AVFileTypeQuickTimeMovie, kUTTagClassFilenameExtension));

    saveURL = [saveURL URLByAppendingPathExtension:fileExtensitionString];

    ZXLog(@"save url:%@",saveURL);
    return saveURL;
}

-(void)Generating_a_Volume_Ramp_Verison_2
{


    AVAsset *videoAsset = [self Creating_an_Asset_Object];


    AVAssetTrack *audioAssetTrack = [[videoAsset tracksWithMediaType:AVMediaTypeAudio] firstObject];
    AVAssetTrack *videoAssetTrack = [[videoAsset tracksWithMediaType:AVMediaTypeVideo] firstObject];

    AVMutableComposition *mutableComposition = [AVMutableComposition composition];

    AVMutableCompositionTrack *mutableCompositionAudioTrack = [mutableComposition addMutableTrackWithMediaType:AVMediaTypeAudio preferredTrackID:kCMPersistentTrackID_Invalid];
    AVMutableCompositionTrack *mutableCompositionVideoTrack = [mutableComposition addMutableTrackWithMediaType:AVMediaTypeVideo preferredTrackID:kCMPersistentTrackID_Invalid];


    [mutableCompositionAudioTrack insertTimeRange:CMTimeRangeMake(kCMTimeZero, audioAssetTrack.timeRange.duration)
                                          ofTrack:audioAssetTrack
                                           atTime:kCMTimeZero
                                            error:nil];

    [mutableCompositionVideoTrack insertTimeRange:CMTimeRangeMake(kCMTimeZero, videoAssetTrack.timeRange.duration)
                                          ofTrack:videoAssetTrack
                                           atTime:kCMTimeZero
                                            error:nil];

    //音频混合
    AVMutableAudioMix *mutableAudioMix = [AVMutableAudioMix audioMix];

    //音频输入混合参数
    AVMutableAudioMixInputParameters *mixParameters = [AVMutableAudioMixInputParameters audioMixInputParametersWithTrack:mutableCompositionAudioTrack];
    [mixParameters setVolumeRampFromStartVolume:1.0 toEndVolume:0.0 timeRange:CMTimeRangeMake(kCMTimeZero, mutableComposition.duration)];

    mutableAudioMix.inputParameters = @[mixParameters];

    AVAssetExportSession *exporter = [[AVAssetExportSession alloc] initWithAsset:mutableComposition presetName:AVAssetExportPresetHighestQuality];

    NSURL *saveURL = [self generate_save_url];
    exporter.outputURL = saveURL;

    exporter.outputFileType = AVFileTypeQuickTimeMovie;
    exporter.shouldOptimizeForNetworkUse = YES;
    exporter.audioMix = mutableAudioMix;

    [exporter exportAsynchronouslyWithCompletionHandler:^{
        dispatch_async(dispatch_get_main_queue(), ^{
            AVAssetExportSessionStatus status = exporter.status;
            ZXLog(@"exporter status = %zd",status);
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
                    if (UIVideoAtPathIsCompatibleWithSavedPhotosAlbum(saveURL.path)) {
                        UISaveVideoAtPathToSavedPhotosAlbum(saveURL.path, self, @selector(video:didFinishSavingWithError:contextInfo:), nil);
                    }
                    break;
                }
                case AVAssetExportSessionStatusFailed: {
                    ZXLog(@"Export failed: %@", [[exporter error] localizedDescription]);
                    break;
                }
                case AVAssetExportSessionStatusCancelled: {
                    ZXLog(@"AVAssetExportSessionStatusCancelled")
                    break;
                }
            }
        });
    }];
    
}

- (void)video:(NSString *)videoPath didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo
{
    ZXLog(@"compeleteSaveVideo: %@",videoPath);
}

-(void)Performing_Custom_Video_Processing
{
    //通过音频混合,只需要一个AVMutableVideoCompositio来完成自定义的视频处理.
    //通过 video composition 可以完成:
    // 1) 渲染大小, 2)sacale 3)帧率调整.
}

-(void)Changing_the_Compositions_Backgournd_Color
{
    AVAsset *videoAsset = [self Creating_an_Asset_Object];

    AVAssetTrack *videoAssetTrack = [[videoAsset tracksWithMediaType:AVMediaTypeVideo] firstObject];

    //keypoint  code here.
    AVMutableVideoCompositionInstruction *backgroundColorCompositionInstruction = [AVMutableVideoCompositionInstruction videoCompositionInstruction];
    backgroundColorCompositionInstruction.timeRange = CMTimeRangeMake(kCMTimeZero,videoAssetTrack.timeRange.duration);
    backgroundColorCompositionInstruction.backgroundColor = [UIColor colorWithRed:0.8 green:0.8 blue:0.8 alpha:0.5].CGColor;
    //keypoint code ene.

    AVMutableVideoComposition *mutableVideoComposition = [AVMutableVideoComposition videoComposition];
    mutableVideoComposition.instructions = @[backgroundColorCompositionInstruction];
    mutableVideoComposition.renderSize = videoAssetTrack.naturalSize;
    mutableVideoComposition.frameDuration = CMTimeMake(1, 60);

    AVAssetExportSession *exporter = [[AVAssetExportSession alloc]initWithAsset:videoAsset presetName:AVAssetExportPresetHighestQuality];

    NSURL *saveURL = [self generate_save_url];

    exporter.outputURL = saveURL;
    exporter.outputFileType = AVFileTypeQuickTimeMovie;
    exporter.shouldOptimizeForNetworkUse = YES;
    exporter.videoComposition = mutableVideoComposition;

    [exporter exportAsynchronouslyWithCompletionHandler:^{
        dispatch_async(dispatch_get_main_queue(), ^{
            AVAssetExportSessionStatus status = exporter.status;
            ZXLog(@"exporter status = %zd",status);
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
                    if (UIVideoAtPathIsCompatibleWithSavedPhotosAlbum(saveURL.path)) {
                        UISaveVideoAtPathToSavedPhotosAlbum(saveURL.path, self, @selector(video:didFinishSavingWithError:contextInfo:), nil);
                    }
                    break;
                }
                case AVAssetExportSessionStatusFailed: {
                    ZXLog(@"Export failed: %@", [[exporter error] localizedDescription]);
                    break;
                }
                case AVAssetExportSessionStatusCancelled: {
                    ZXLog(@"AVAssetExportSessionStatusCancelled")
                    break;
                }
            }
        });
    }];
}

-(void)Applying_Opacity_Ramps
{
    AVAsset *firstVideoAsset = [self Creating_an_Asset_Object];
    AVAssetTrack *firstVideoAssetTrack = [[firstVideoAsset tracksWithMediaType:AVMediaTypeVideo] firstObject];

    AVMutableVideoCompositionInstruction *firstVideoCompositionInstruction = [AVMutableVideoCompositionInstruction videoCompositionInstruction];
    firstVideoCompositionInstruction.timeRange = CMTimeRangeMake(kCMTimeZero, firstVideoAssetTrack.timeRange.duration);

    AVMutableVideoCompositionLayerInstruction *firstVideoLayerInstruction  = [AVMutableVideoCompositionLayerInstruction videoCompositionLayerInstructionWithAssetTrack:firstVideoAssetTrack];
    [firstVideoLayerInstruction setOpacityRampFromStartOpacity:1.f toEndOpacity:0.f timeRange:CMTimeRangeMake(kCMTimeZero, firstVideoAssetTrack.timeRange.duration)];

    firstVideoCompositionInstruction.layerInstructions = @[firstVideoLayerInstruction];


    AVMutableVideoComposition *mutableVideoComposition = [AVMutableVideoComposition videoComposition];
    mutableVideoComposition.instructions = @[firstVideoCompositionInstruction];
    mutableVideoComposition.renderSize = firstVideoAssetTrack.naturalSize;
    mutableVideoComposition.frameDuration = CMTimeMake(1, 60);

    AVAssetExportSession *exporter = [[AVAssetExportSession alloc]initWithAsset:firstVideoAsset presetName:AVAssetExportPresetHighestQuality];

    NSURL *saveURL = [self generate_save_url];

    exporter.outputURL = saveURL;
    exporter.outputFileType = AVFileTypeQuickTimeMovie;
    exporter.shouldOptimizeForNetworkUse = YES;
    exporter.videoComposition = mutableVideoComposition;

    [exporter exportAsynchronouslyWithCompletionHandler:^{
        dispatch_async(dispatch_get_main_queue(), ^{
            AVAssetExportSessionStatus status = exporter.status;
            ZXLog(@"exporter status = %zd",status);
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
                    if (UIVideoAtPathIsCompatibleWithSavedPhotosAlbum(saveURL.path)) {
                        UISaveVideoAtPathToSavedPhotosAlbum(saveURL.path, self, @selector(video:didFinishSavingWithError:contextInfo:), nil);
                    }
                    break;
                }
                case AVAssetExportSessionStatusFailed: {
                    ZXLog(@"Export failed: %@", [[exporter error] localizedDescription]);
                    break;
                }
                case AVAssetExportSessionStatusCancelled: {
                    ZXLog(@"AVAssetExportSessionStatusCancelled")
                    break;
                }
            }
        });
    }];
}
-(void)Applying_Opacity_Ramps_Version_2
{
    //资源
    AVAsset *firstVideoAsset = [self Creating_an_Asset_Object];
    AVAssetTrack *firstVideoAssetTrack = [[firstVideoAsset tracksWithMediaType:AVMediaTypeVideo] firstObject];
    AVAssetTrack *firstAudioAssetTrack = [[firstVideoAsset tracksWithMediaType:AVMediaTypeAudio] firstObject];

    AVAsset *secondVideoAsset = [self Creating_an_Asset_Object];
    AVAssetTrack *secondVideoAssetTrack = [[secondVideoAsset tracksWithMediaType:AVMediaTypeVideo] firstObject];
    AVAssetTrack *secondAudioAssetTrack = [[secondVideoAsset tracksWithMediaType:AVMediaTypeAudio] firstObject];


    //两个视频资源整合
    AVMutableComposition *mutableComposition = [AVMutableComposition composition];

    AVMutableCompositionTrack *videoCompositionTrack = [mutableComposition addMutableTrackWithMediaType:AVMediaTypeVideo preferredTrackID:kCMPersistentTrackID_Invalid];
    AVMutableCompositionTrack *audioCompositionTrack = [mutableComposition addMutableTrackWithMediaType:AVMediaTypeAudio preferredTrackID:kCMPersistentTrackID_Invalid];



    [videoCompositionTrack insertTimeRange:CMTimeRangeMake(kCMTimeZero, firstVideoAssetTrack.timeRange.duration)
                                   ofTrack:firstVideoAssetTrack
                                    atTime:kCMTimeZero
                                     error:nil];

    [videoCompositionTrack insertTimeRange:CMTimeRangeMake(kCMTimeZero, secondVideoAssetTrack.timeRange.duration)
                                   ofTrack:secondVideoAssetTrack
                                    atTime:firstVideoAssetTrack.timeRange.duration
                                     error:nil];

    [audioCompositionTrack insertTimeRange:CMTimeRangeMake(kCMTimeZero,firstAudioAssetTrack.timeRange.duration)
                                         ofTrack:firstAudioAssetTrack
                                          atTime:kCMTimeZero
                                           error:nil];
    [audioCompositionTrack insertTimeRange:CMTimeRangeMake(kCMTimeZero,secondAudioAssetTrack.timeRange.duration)
                                   ofTrack:secondAudioAssetTrack
                                    atTime:firstAudioAssetTrack.timeRange.duration
                                     error:nil];

    AVMutableVideoCompositionInstruction *firstVideoCompositionInstruction = [AVMutableVideoCompositionInstruction videoCompositionInstruction];
    firstVideoCompositionInstruction.timeRange = CMTimeRangeMake(kCMTimeZero, firstVideoAssetTrack.timeRange.duration);

    AVMutableVideoCompositionLayerInstruction *firstVideoLayerInstruction  = [AVMutableVideoCompositionLayerInstruction videoCompositionLayerInstructionWithAssetTrack:videoCompositionTrack];
    [firstVideoLayerInstruction setOpacityRampFromStartOpacity:1.f toEndOpacity:0.f timeRange:CMTimeRangeMake(kCMTimeZero, firstVideoAssetTrack.timeRange.duration)];
    [firstVideoLayerInstruction setTransform:firstVideoAssetTrack.preferredTransform atTime:kCMTimeZero];
    firstVideoCompositionInstruction.layerInstructions = @[firstVideoLayerInstruction];


    AVMutableVideoCompositionInstruction * secondVideoCompositionInstruction = [AVMutableVideoCompositionInstruction videoCompositionInstruction];
    secondVideoCompositionInstruction.timeRange = CMTimeRangeMake(firstVideoAssetTrack.timeRange.duration, CMTimeAdd(firstVideoAssetTrack.timeRange.duration, secondVideoAssetTrack.timeRange.duration));
    AVMutableVideoCompositionLayerInstruction *secondVideoLayerInstruction = [AVMutableVideoCompositionLayerInstruction videoCompositionLayerInstructionWithAssetTrack:videoCompositionTrack];
    [secondVideoLayerInstruction setTransform:secondVideoAssetTrack.preferredTransform
                                       atTime:firstVideoAssetTrack.timeRange.duration];
    [secondVideoLayerInstruction setOpacityRampFromStartOpacity:0.f
                                                   toEndOpacity:1.f
                                                      timeRange:CMTimeRangeMake(firstVideoAssetTrack.timeRange.duration, secondVideoAssetTrack.timeRange.duration)];
    secondVideoCompositionInstruction.layerInstructions = @[secondVideoLayerInstruction];

    AVMutableVideoComposition *mutableVideoComposition = [AVMutableVideoComposition videoComposition];
    mutableVideoComposition.instructions = @[firstVideoCompositionInstruction,secondVideoCompositionInstruction];
    mutableVideoComposition.renderSize = firstVideoAssetTrack.naturalSize;
    mutableVideoComposition.frameDuration = CMTimeMake(1,60);

    //资源导出

    [AVAssetExportSession determineCompatibilityOfExportPreset:AVAssetExportPresetHighestQuality withAsset:mutableComposition outputFileType:AVFileTypeQuickTimeMovie completionHandler:^(BOOL compatible) {

        ZXLog(@" compatible to export %@",compatible ? @"YES" : @"NO");

        AVAssetExportSession *exporter = [[AVAssetExportSession alloc]initWithAsset:mutableComposition presetName:AVAssetExportPresetHighestQuality];

        NSURL *saveURL = [self generate_save_url];

        exporter.outputURL = saveURL;
        exporter.outputFileType = AVFileTypeQuickTimeMovie;
        exporter.shouldOptimizeForNetworkUse = YES;
        exporter.videoComposition = mutableVideoComposition;

        dispatch_async(dispatch_get_main_queue(), ^{

            [MBProgressHUD showMessage:@"Exporting..."];

            [exporter exportAsynchronouslyWithCompletionHandler:^{
                dispatch_async(dispatch_get_main_queue(), ^{
                    AVAssetExportSessionStatus status = exporter.status;
                    ZXLog(@"exporter status = %zd",status);
                    [MBProgressHUD showToastWithMessage:@"Done Export."];
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
                            if (UIVideoAtPathIsCompatibleWithSavedPhotosAlbum(saveURL.path)) {
                                UISaveVideoAtPathToSavedPhotosAlbum(saveURL.path, self, @selector(video:didFinishSavingWithError:contextInfo:), nil);
                            }
                            break;
                        }
                        case AVAssetExportSessionStatusFailed: {
                            ZXLog(@"Export failed: %@", [[exporter error] localizedDescription]);
                            break;
                        }
                        case AVAssetExportSessionStatusCancelled: {
                            ZXLog(@"AVAssetExportSessionStatusCancelled")
                            break;
                        }
                    }
                });
            }];
        });

    }];
}

-(void)Combining_Multiple_Assets_and_Saving_the_Result_to_the_Camera_Roll
{
    //1. Creating the Composition
    AVMutableComposition *mutableComposition = [AVMutableComposition composition];
    AVMutableCompositionTrack *videoCompositionTrack = [mutableComposition addMutableTrackWithMediaType:AVMediaTypeVideo preferredTrackID:kCMPersistentTrackID_Invalid];
    AVMutableCompositionTrack *audioCompositionTrack = [mutableComposition addMutableTrackWithMediaType:AVMediaTypeAudio preferredTrackID:kCMPersistentTrackID_Invalid];


    //
    AVAsset *firstVideoAsset = [self Creating_an_Asset_Object];
    AVAssetTrack *firstVideoAssetTrack = [[firstVideoAsset tracksWithMediaType:AVMediaTypeVideo] firstObject];
    AVAssetTrack *firstAudioAssetTrack = [[firstVideoAsset tracksWithMediaType:AVMediaTypeAudio] firstObject];

    AVAsset *secondVideoAsset = [self Creating_an_Asset_Object];
    AVAssetTrack *secondVideoAssetTrack = [[secondVideoAsset tracksWithMediaType:AVMediaTypeVideo] firstObject];
    AVAssetTrack *secondAudioAssetTrack = [[secondVideoAsset tracksWithMediaType:AVMediaTypeAudio] firstObject];

    //2. Adding the Asset
    [videoCompositionTrack insertTimeRange:CMTimeRangeMake(kCMTimeZero, firstVideoAssetTrack.timeRange.duration)
                                   ofTrack:firstVideoAssetTrack
                                    atTime:kCMTimeZero
                                     error:nil];
    [videoCompositionTrack insertTimeRange:CMTimeRangeMake(kCMTimeZero, secondVideoAssetTrack.timeRange.duration)
                                   ofTrack:secondVideoAssetTrack
                                    atTime:firstVideoAssetTrack.timeRange.duration
                                     error:nil];

    [audioCompositionTrack insertTimeRange:CMTimeRangeMake(kCMTimeZero, firstAudioAssetTrack.timeRange.duration)
                                   ofTrack:firstAudioAssetTrack
                                    atTime:kCMTimeZero
                                     error:nil];
    [audioCompositionTrack insertTimeRange:CMTimeRangeMake(kCMTimeZero, secondAudioAssetTrack.timeRange.duration)
                                   ofTrack:secondAudioAssetTrack
                                    atTime:firstAudioAssetTrack.timeRange.duration
                                     error:nil];
    //3. Checking the Video Orientations
    BOOL isFirstVideoPortrait = NO;
    CGAffineTransform firstTransform = firstVideoAssetTrack.preferredTransform;

    if (firstTransform.a == 0 && firstTransform.d == 0 && (firstTransform.b == 1.0 || firstTransform.b == -1.0) && (firstTransform.c == 1.0 || firstTransform.c == -1.0)) {
        isFirstVideoPortrait = YES;
    }
    BOOL isSecondVideoPortrait = NO;
    CGAffineTransform secondTransform = secondVideoAssetTrack.preferredTransform;

    if (secondTransform.a == 0 && secondTransform.d == 0 && (secondTransform.b == 1.0 || secondTransform.b == -1.0) && (secondTransform.c == 1.0 || secondTransform.c == -1.0)) {
        isSecondVideoPortrait = YES;
    }

    if ((isFirstVideoPortrait && !isSecondVideoPortrait) || (!isFirstVideoPortrait && isSecondVideoPortrait)) {
        ZXLog(@"两个视频的朝向不一致!")
        return;
    }

    //4. Applying the Video Composition Layer Instructions
    AVMutableVideoCompositionInstruction *firstVideoCompositionInstruction = [AVMutableVideoCompositionInstruction videoCompositionInstruction];
    firstVideoCompositionInstruction.timeRange = CMTimeRangeMake(kCMTimeZero, firstVideoAssetTrack.timeRange.duration);

    AVMutableVideoCompositionInstruction * secondVideoCompositionInstruction = [AVMutableVideoCompositionInstruction videoCompositionInstruction];
    secondVideoCompositionInstruction.timeRange = CMTimeRangeMake(firstVideoAssetTrack.timeRange.duration, CMTimeAdd(firstVideoAssetTrack.timeRange.duration, secondVideoAssetTrack.timeRange.duration));

    AVMutableVideoCompositionLayerInstruction *firstVideoLayerInstruction = [AVMutableVideoCompositionLayerInstruction videoCompositionLayerInstructionWithAssetTrack:videoCompositionTrack];
    [firstVideoLayerInstruction setOpacityRampFromStartOpacity:1.f
                                                  toEndOpacity:0.f
                                                     timeRange:CMTimeRangeMake(kCMTimeZero, firstVideoAssetTrack.timeRange.duration)];
    [firstVideoLayerInstruction setTransform:firstTransform
                                      atTime:kCMTimeZero];
    firstVideoCompositionInstruction.layerInstructions = @[firstVideoLayerInstruction];

    AVMutableVideoCompositionLayerInstruction *secondVideoLayerInstruction = [AVMutableVideoCompositionLayerInstruction videoCompositionLayerInstructionWithAssetTrack:videoCompositionTrack];

    [secondVideoLayerInstruction setTransform:secondTransform
                                       atTime:firstVideoAssetTrack.timeRange.duration];
    [secondVideoLayerInstruction setOpacityRampFromStartOpacity:0.f
                                                   toEndOpacity:1.f
                                                      timeRange:CMTimeRangeMake(firstVideoAssetTrack.timeRange.duration, secondVideoAssetTrack.timeRange.duration)];
    secondVideoCompositionInstruction.layerInstructions = @[secondVideoLayerInstruction];

    AVMutableVideoComposition *mutableVideoComposition = [AVMutableVideoComposition videoComposition];
    mutableVideoComposition.instructions = @[firstVideoCompositionInstruction, secondVideoCompositionInstruction];

    //5 Setting the Render Size and Frame Duration
    CGSize naturalSizeFirst, naturalSizeSecond;

    if (isFirstVideoPortrait) {
        naturalSizeFirst = CGSizeMake(firstVideoAssetTrack.naturalSize.height, firstVideoAssetTrack.naturalSize.width);
        naturalSizeSecond = CGSizeMake(secondVideoAssetTrack.naturalSize.height, secondVideoAssetTrack.naturalSize.width);
    }
    else {
        naturalSizeFirst = firstVideoAssetTrack.naturalSize;
        naturalSizeSecond = secondVideoAssetTrack.naturalSize;
    }
    float renderWidth, renderHeight;

    if (naturalSizeFirst.width > naturalSizeSecond.width) {
        renderWidth = naturalSizeFirst.width;
    }
    else {
        renderWidth = naturalSizeSecond.width;
    }
    if (naturalSizeFirst.height > naturalSizeSecond.height) {
        renderHeight = naturalSizeFirst.height;
    }
    else {
        renderHeight = naturalSizeSecond.height;
    }
    mutableVideoComposition.renderSize = CGSizeMake(renderWidth, renderHeight);
    mutableVideoComposition.frameDuration = CMTimeMake(1,60);


    //6. Exporting the Composition and Saving it to the Camera Roll

    AVAssetExportSession *exporter = [[AVAssetExportSession alloc] initWithAsset:mutableComposition presetName:AVAssetExportPresetHighestQuality];
    NSURL *saveURL = [self generate_save_url];
    exporter.outputURL = saveURL;
    exporter.outputFileType = AVFileTypeQuickTimeMovie;
    exporter.shouldOptimizeForNetworkUse = YES;
    exporter.videoComposition = mutableVideoComposition;
    [MBProgressHUD showMessage:@"Exporting..."];
    [exporter exportAsynchronouslyWithCompletionHandler:^{
        dispatch_async(dispatch_get_main_queue(), ^{
            AVAssetExportSessionStatus status = exporter.status;
            ZXLog(@"exporter status = %zd",status);
            [MBProgressHUD showToastWithMessage:@"Done Export."];
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
                    if (UIVideoAtPathIsCompatibleWithSavedPhotosAlbum(saveURL.path)) {
                        UISaveVideoAtPathToSavedPhotosAlbum(saveURL.path, self, @selector(video:didFinishSavingWithError:contextInfo:), nil);
                    }
                    break;
                }
                case AVAssetExportSessionStatusFailed: {
                    ZXLog(@"Export failed: %@", [[exporter error] localizedDescription]);
                    break;
                }
                case AVAssetExportSessionStatusCancelled: {
                    ZXLog(@"AVAssetExportSessionStatusCancelled")
                    break;
                }
            }
        });
    }];

}
@end
