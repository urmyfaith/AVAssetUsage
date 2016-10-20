//
//  AVAssetViewController.m
//  AVAssetUsage
//
//  Created by zx on 10/20/16.
//  Copyright © 2016 z2xy. All rights reserved.
//

#import "AVAssetViewController.h"
@import AVFoundation;
@interface AVAssetViewController ()
@property(nonatomic, strong) AVAsset *asset;
@property(nonatomic, strong) AVMetadataItem *metadataItem;
@property(nonatomic, strong) AVAssetTrack *track;
@end

@implementation AVAssetViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.view.backgroundColor = [UIColor whiteColor];
    
    // Xcode7.3.1 文档
    // xcdoc://?url=developer.apple.com/library/etc/redirect/xcode/ios/1151/documentation/AVFoundation/Reference/AVAsset_Class/index.html

    [self Creating_an_Asset];

    [self Loading_Data];
}

#pragma mark - AVAsset Tasks

-(void)Creating_an_Asset
{
    NSString *mediaPath = [[NSBundle mainBundle] pathForResource:@"Sketch" ofType:@"mp4"];

    NSURL *mediaURL = [NSURL fileURLWithPath:mediaPath];
    self.asset = [AVAsset assetWithURL:mediaURL];
}

-(void)Loading_Data
{
    NSArray *assetKeysToLoadAndTest = @[@"tracks", @"duration",@"availableMetadataFormats",
                                        @"lyrics",@"trackGroups",@"hasProtectedContent",
                                        @"readable",@"playable", @"composable",@"exportable",
                                        @"metadata",
                                        @"availableMediaCharacteristicsWithMediaSelectionOptions",@"compatibleWithSavedPhotosAlbum",@"creationDate"];
    __weak typeof(self) weakSelf = self;
    [self.asset loadValuesAsynchronouslyForKeys:assetKeysToLoadAndTest completionHandler:^{

        for (NSString *key in assetKeysToLoadAndTest) {
            NSError *error = nil;
            AVKeyValueStatus status = [weakSelf.asset statusOfValueForKey:key error:&error];
            NSLog(@"key=%@, status=%zd",key,status);
        }

        NSLog(@"playable=%zd, composable=%zd",[weakSelf.asset isPlayable], [weakSelf.asset isComposable]);

        [weakSelf AVAsset_Tasks];

        [weakSelf AVMetadataItem_Tasks];

        [weakSelf AVAssetTrack_Task];
    }];
}

-(void)AVAsset_Tasks
{

    [self Accessing_Metadata];

    [self Acccessing_Tracks];

    [self Determining_Usability];

    [self Getting_a_New_Track_ID];

    [self Accessing_Common_Metadata];

    [self Preferred_Asset_Attributes];

    [self Managing_Reference_Restrictions];

    [self Media_Selections];
}

-(void)Accessing_Metadata
{
    NSArray<AVMetadataItem *> *commonMetaData = self.asset.commonMetadata;
    NSLog(@"commonMetaData=%@",commonMetaData);

    self.metadataItem = commonMetaData.firstObject;

    NSArray<NSString *> *availableMetadataFormats = self.asset.availableMetadataFormats;
    NSLog(@"availableMetadataFormats=%@",availableMetadataFormats);

    NSMutableArray *metadata = [NSMutableArray array];
    for (NSString *format in self.asset.availableMetadataFormats) {
        NSArray<AVMetadataItem *> *metaItems = [self.asset metadataForFormat:format];
        [metadata addObjectsFromArray:metaItems];
        NSLog(@"format=%@, metadataFromFarmate=%@",format,metaItems);
    }

    NSString *lyrics = self.asset.lyrics;
    NSLog(@"lyrics=%@",lyrics);


    NSArray <NSLocale *> *availableChapterLocales = self.asset.availableChapterLocales;
    NSLog(@"availableChapterLocales=%@",availableChapterLocales);
}

-(void)Acccessing_Tracks
{
    NSArray <AVAssetTrack *> *tracks = self.asset.tracks;
    NSLog(@"tracks=%@",tracks);

    for (AVAssetTrack *track in self.asset.tracks) {
        AVAssetTrack *tempTrack = [self.asset trackWithTrackID:track.trackID];
        NSLog(@"trackWithTrackID=%@",tempTrack);
    }

    //视频轨
    NSArray<AVAssetTrack *> *tracksArray1 = [self.asset tracksWithMediaCharacteristic:AVMediaCharacteristicVisual];
    NSLog(@"tracksWithMediaCharacteristic=%@",tracksArray1);

    //音频轨
    NSArray<AVAssetTrack *> *tracksArray2 = [self.asset tracksWithMediaCharacteristic:AVMediaCharacteristicAudible];
    NSLog(@"tracksWithMediaCharacteristic=%@",tracksArray2);

    //音频轨
    NSArray<AVAssetTrack *> *tracksArray3 = [self.asset tracksWithMediaType:AVMediaTypeAudio];
    NSLog(@"tracksWithMediaCharacteristic=%@",tracksArray3);

    //视频轨
    NSArray<AVAssetTrack *> *tracksArray4 = [self.asset tracksWithMediaType:AVMediaTypeVideo];
    NSLog(@"tracksWithMediaCharacteristic=%@",tracksArray4);

    NSArray <AVAssetTrackGroup *> *trackGroups = self.asset.trackGroups;
    NSLog(@"trackGroups=%@",trackGroups);

}

-(void)Determining_Usability
{
    BOOL hasProtectedContent = self.asset.hasProtectedContent;
    NSLog(@"hasProtectedContent = %@",hasProtectedContent ? @"YES" : @"NO");

    BOOL playable = self.asset.isPlayable;
    NSLog(@"playable = %@",playable ? @"YES" : @"NO");

    BOOL exportable = self.asset.isExportable;
    NSLog(@"exportable = %@",exportable ? @"YES" : @"NO");

    BOOL readable = self.asset.isReadable;
    NSLog(@"readable = %@",readable ? @"YES" : @"NO");

    BOOL composable = self.asset.isComposable;
    NSLog(@"composable = %@",composable ? @"YES" : @"NO");
}

-(void)Getting_a_New_Track_ID
{
    for (NSInteger i = 0 ; i < 2 ; i++) {
        CMPersistentTrackID unusedTrackID = [self.asset unusedTrackID];
        NSLog(@"unusedTrackID=%zd",unusedTrackID);
    }
}
-(void)Accessing_Common_Metadata
{
    NSArray <AVMetadataItem *> *metadata = self.asset.metadata;
    NSLog(@"metadata = %@",metadata);

    CMTime duration = self.asset.duration;
    CMTimeShow(duration);

    BOOL providesPreciseDurationAndTiming = self.asset.providesPreciseDurationAndTiming;
    NSLog(@"providesPreciseDurationAndTiming = %@",providesPreciseDurationAndTiming ? @"YES" : @"NO");
}

-(void)Preferred_Asset_Attributes
{
    float preferredRate = self.asset.preferredRate;
    NSLog(@"preferredRate = %.2f",preferredRate);

    CGAffineTransform preferredTransform = self.asset.preferredTransform;
    NSLog(@"preferredTransform = %@",NSStringFromCGAffineTransform(preferredTransform));

    float preferredVolume = self.asset.preferredVolume;
    NSLog(@"preferredVolume = %.2f",preferredVolume);
}

-(void)Managing_Reference_Restrictions
{
    /*
     typedef NS_OPTIONS(NSUInteger, AVAssetReferenceRestrictions) {
     AVAssetReferenceRestrictionForbidNone = 0UL,
     AVAssetReferenceRestrictionForbidRemoteReferenceToLocal = (1UL << 0),
     AVAssetReferenceRestrictionForbidLocalReferenceToRemote = (1UL << 1),
     AVAssetReferenceRestrictionForbidCrossSiteReference = (1UL << 2),
     AVAssetReferenceRestrictionForbidLocalReferenceToLocal = (1UL << 3),
     AVAssetReferenceRestrictionForbidAll = 0xFFFFUL,
     };
     */
    AVAssetReferenceRestrictions referenceRestrictions = self.asset.referenceRestrictions;
    NSLog(@"referenceRestrictions = %zd",referenceRestrictions);
}

-(void)Media_Selections
{
    NSArray <NSString *> *availableMediaCharacteristicsWithMediaSelectionOptions = self.asset.availableMediaCharacteristicsWithMediaSelectionOptions;
    NSLog(@"availableMediaCharacteristicsWithMediaSelectionOptions = %@",availableMediaCharacteristicsWithMediaSelectionOptions);


    AVMediaSelectionGroup *mediaSelectionGroup1 = [self.asset mediaSelectionGroupForMediaCharacteristic:AVMediaCharacteristicAudible];
    NSLog(@"mediaSelectionGroupForMediaCharacteristic audible = %@", mediaSelectionGroup1);

    AVMediaSelectionGroup *mediaSelectionGroup2 = [self.asset mediaSelectionGroupForMediaCharacteristic: AVMediaCharacteristicVisual];
    NSLog(@"mediaSelectionGroupForMediaCharacteristic Visual = %@", mediaSelectionGroup2);

    AVMediaSelectionGroup *mediaSelectionGroup3 = [self.asset mediaSelectionGroupForMediaCharacteristic:AVMediaCharacteristicLegible];
    NSLog(@"mediaSelectionGroupForMediaCharacteristic Legible = %@", mediaSelectionGroup3);


    BOOL isCompatibleWithSavedPhotosAlbum = self.asset.isCompatibleWithSavedPhotosAlbum;
    NSLog(@"isCompatibleWithSavedPhotosAlbum = %@",isCompatibleWithSavedPhotosAlbum ? @"YES" : @"NO");


    AVMetadataItem *creationDate = self.asset.creationDate;
    NSLog(@"creationDate=%@\ndateValue=%@\nstringVaule=%@",creationDate,creationDate.dateValue,creationDate.stringValue);

}

/*

 2016-10-20 13:21:50.009 AVAssetUsage[4629:267893] key=tracks, status=2
 2016-10-20 13:21:50.010 AVAssetUsage[4629:267893] key=duration, status=2
 2016-10-20 13:21:50.010 AVAssetUsage[4629:267893] key=availableMetadataFormats, status=2
 2016-10-20 13:21:50.010 AVAssetUsage[4629:267893] key=lyrics, status=2
 2016-10-20 13:21:50.010 AVAssetUsage[4629:267893] key=trackGroups, status=2
 2016-10-20 13:21:50.011 AVAssetUsage[4629:267893] key=hasProtectedContent, status=2
 2016-10-20 13:21:50.011 AVAssetUsage[4629:267893] key=readable, status=2
 2016-10-20 13:21:50.011 AVAssetUsage[4629:267893] key=playable, status=2
 2016-10-20 13:21:50.011 AVAssetUsage[4629:267893] key=composable, status=2
 2016-10-20 13:21:50.012 AVAssetUsage[4629:267893] key=exportable, status=2
 2016-10-20 13:21:50.012 AVAssetUsage[4629:267893] key=metadata, status=2
 2016-10-20 13:21:50.012 AVAssetUsage[4629:267893] key=availableMediaCharacteristicsWithMediaSelectionOptions, status=2
 2016-10-20 13:21:50.012 AVAssetUsage[4629:267893] key=compatibleWithSavedPhotosAlbum, status=2
 2016-10-20 13:21:50.012 AVAssetUsage[4629:267893] key=creationDate, status=2


 2016-10-20 13:21:50.013 AVAssetUsage[4629:267893] playable=1, composable=1
 2016-10-20 13:21:50.014 AVAssetUsage[4629:267893] commonMetaData=(
 "<AVMetadataItem: 0x7feecb415ac0, identifier=uiso/titl, keySpace=uiso, key class = __NSCFNumber, key=titl, commonKey=title, extendedLanguageTag=en, dataType=com.apple.metadata.datatype.UTF-8, time={INVALID}, duration={INVALID}, startDate=(null), extras={\n    dataType = 2;\n    dataTypeNamespace = \"com.apple.quicktime.udta\";\n}, value=My Movie>"
 )
 2016-10-20 13:21:50.014 AVAssetUsage[4629:267893] availableMetadataFormats=(
 "org.mp4ra"
 )
 2016-10-20 13:21:50.015 AVAssetUsage[4629:267893] format=org.mp4ra, metadataFromFarmate=(
 "<AVMetadataItem: 0x7feecb418ba0, identifier=uiso/titl, keySpace=uiso, key class = __NSCFNumber, key=titl, commonKey=title, extendedLanguageTag=en, dataType=com.apple.metadata.datatype.UTF-8, time={INVALID}, duration={INVALID}, startDate=(null), extras={\n    dataType = 2;\n    dataTypeNamespace = \"com.apple.quicktime.udta\";\n}, value=My Movie>"
 )
 2016-10-20 13:21:50.015 AVAssetUsage[4629:267893] lyrics=(null)
 2016-10-20 13:21:50.015 AVAssetUsage[4629:267893] availableChapterLocales=(
 )


 2016-10-20 13:21:50.016 AVAssetUsage[4629:267893] tracks=(
 "<AVAssetTrack: 0x7feecb50f060, trackID = 1, mediaType = soun>",
 "<AVAssetTrack: 0x7feecb51c450, trackID = 2, mediaType = vide>"
 )
 2016-10-20 13:21:50.016 AVAssetUsage[4629:267893] trackWithTrackID=<AVAssetTrack: 0x7feecb50f060, trackID = 1, mediaType = soun>
 2016-10-20 13:21:50.016 AVAssetUsage[4629:267893] trackWithTrackID=<AVAssetTrack: 0x7feecb51c450, trackID = 2, mediaType = vide>
 2016-10-20 13:21:50.017 AVAssetUsage[4629:267893] tracksWithMediaCharacteristic=(
 "<AVAssetTrack: 0x7feecb51c450, trackID = 2, mediaType = vide>"
 )
 2016-10-20 13:21:50.017 AVAssetUsage[4629:267893] tracksWithMediaCharacteristic=(
 "<AVAssetTrack: 0x7feecb50f060, trackID = 1, mediaType = soun>"
 )
 2016-10-20 13:21:50.017 AVAssetUsage[4629:267893] tracksWithMediaCharacteristic=(
 "<AVAssetTrack: 0x7feecb50f060, trackID = 1, mediaType = soun>"
 )
 2016-10-20 13:21:50.017 AVAssetUsage[4629:267893] tracksWithMediaCharacteristic=(
 "<AVAssetTrack: 0x7feecb51c450, trackID = 2, mediaType = vide>"
 )
 2016-10-20 13:21:50.018 AVAssetUsage[4629:267893] trackGroups=(
 )


 2016-10-20 13:21:50.018 AVAssetUsage[4629:267893] hasProtectedContent = NO
 2016-10-20 13:21:50.018 AVAssetUsage[4629:267893] playable = YES
 2016-10-20 13:21:50.018 AVAssetUsage[4629:267893] exportable = YES
 2016-10-20 13:21:50.018 AVAssetUsage[4629:267893] readable = YES
 2016-10-20 13:21:50.019 AVAssetUsage[4629:267893] composable = YES

 2016-10-20 13:21:50.019 AVAssetUsage[4629:267893] unusedTrackID=4
 2016-10-20 13:21:50.019 AVAssetUsage[4629:267893] unusedTrackID=4
 2016-10-20 13:21:50.019 AVAssetUsage[4629:267893] metadata = (
 "<AVMetadataItem: 0x7feecb51e450, identifier=uiso/titl, keySpace=uiso, key class = __NSCFNumber, key=titl, commonKey=title, extendedLanguageTag=en, dataType=com.apple.metadata.datatype.UTF-8, time={INVALID}, duration={INVALID}, startDate=(null), extras={\n    dataType = 2;\n    dataTypeNamespace = \"com.apple.quicktime.udta\";\n}, value=My Movie>"
 )
 {8814806/30000 = 293.827}
 2016-10-20 13:21:50.020 AVAssetUsage[4629:267893] providesPreciseDurationAndTiming = YES
 2016-10-20 13:21:50.020 AVAssetUsage[4629:267893] preferredRate = 1.00
 2016-10-20 13:21:50.020 AVAssetUsage[4629:267893] preferredTransform = [1, 0, 0, 1, 0, 0]
 2016-10-20 13:21:50.020 AVAssetUsage[4629:267893] preferredVolume = 1.00
 2016-10-20 13:21:50.021 AVAssetUsage[4629:267893] referenceRestrictions = 0
 2016-10-20 13:21:50.021 AVAssetUsage[4629:267893] availableMediaCharacteristicsWithMediaSelectionOptions = (
 )
 2016-10-20 13:21:50.021 AVAssetUsage[4629:267893] mediaSelectionGroupForMediaCharacteristic audible = (null)
 2016-10-20 13:21:50.021 AVAssetUsage[4629:267893] mediaSelectionGroupForMediaCharacteristic Visual = (null)
 2016-10-20 13:21:50.022 AVAssetUsage[4629:267893] mediaSelectionGroupForMediaCharacteristic Legible = (null)
 2016-10-20 13:21:50.022 AVAssetUsage[4629:267893] isCompatibleWithSavedPhotosAlbum = YES
 2016-10-20 13:21:50.024 AVAssetUsage[4629:267893] creationDate=<AVMetadataItem: 0x7feecb641f30, identifier=common/creationDate, keySpace=comn, key class = __NSCFConstantString, key=creationDate, commonKey=creationDate, extendedLanguageTag=(null), dataType=(null), time={INVALID}, duration={INVALID}, startDate=(null), extras={
 }, value=2016-10-20 02:59:53 +0000>
 dateValue=2016-10-20 02:59:53 +0000
 stringVaule=(null)
 */



#pragma mark - AVMetadataItem Tasks
-(void)AVMetadataItem_Tasks
{
    [self Asynchronous_Loading];
}

-(void)Asynchronous_Loading
{
    NSArray *metadataItemKeysToLoadAndTest = @[@"key",@"keySpace",@"commonKey",
                                               @"value",@"time",@"duration",@"locale",
                                               @"dateValue",@"extraAttributes",@"dataType",
                                               @"extendedLanguageTag",@"identifier",
                                               @"stringValue",@"numberValue",@"dateValue"];
    __weak typeof(self) weakSelf = self;

    [self.metadataItem loadValuesAsynchronouslyForKeys:metadataItemKeysToLoadAndTest completionHandler:^{
        for (NSString *key in metadataItemKeysToLoadAndTest) {
            NSError *error = nil;
            AVKeyValueStatus status = [weakSelf.metadataItem statusOfValueForKey:key error:&error];
            NSLog(@"key=%@, status=%zd",key,status);
        }

        [weakSelf Keys_and_Key_Spaces];

        [weakSelf Accessing_Values];

        [weakSelf Type_Coercion];

        [weakSelf Filtering_Arrays_of_Metadata_Items];
    }];
}
-(void)Keys_and_Key_Spaces
{
    id<NSObject, NSCopying> key = self.metadataItem.key;
    NSLog(@"key = %@",key);

    NSString *keySpace = self.metadataItem.keySpace;
    NSLog(@"keySpace = %@",keySpace);

    NSString *commonKey = self.metadataItem.commonKey;
    NSLog(@"commonKey = %@",commonKey);
}

-(void)Accessing_Values
{
    id<NSObject, NSCopying> value = self.metadataItem.value;
    NSLog(@"key = %@",value);

    CMTime time  = self.metadataItem.time;
    CMTimeShow(time);

    CMTime duration = self.metadataItem.duration;
    CMTimeShow(duration);

    NSLocale *locale = self.metadataItem.locale;
    NSLog(@"locale=%@",locale);

    NSDate *dataValue = self.metadataItem.dateValue;
    NSLog(@"dataValue = %@",dataValue);

    NSDictionary <NSString *,id> *extraAttributes = self.metadataItem.extraAttributes;
    NSLog(@"extraAttributes = %@",extraAttributes);

    NSString *dataType = self.metadataItem.dataType;
    NSLog(@"dataType = %@",dataType);

    NSString *extendedLanguageTag = self.metadataItem.extendedLanguageTag;
    NSLog(@"extendedLanguageTag = %@",extendedLanguageTag);

    NSString *identifier = self.metadataItem.identifier;
    NSLog(@"identifier = %@",identifier);

    NSString *identifierTemp = [AVMetadataItem  identifierForKey:@"z2xy" keySpace:@"zx"];
    NSLog(@"identifierTemp = %@",identifierTemp);

    id keyTemp = [AVMetadataItem keyForIdentifier:identifierTemp];
    NSLog(@"keyTemp = %@", keyTemp);

    NSString *keySpaceTemp = [AVMetadataItem keySpaceForIdentifier:identifierTemp];
    NSLog(@"keySpaceTemp = %@", keySpaceTemp);
}

-(void)Type_Coercion
{
    NSString *stringValue = self.metadataItem.stringValue;
    NSLog(@"stringValue = %@", stringValue);

    NSNumber *numberValue = self.metadataItem.numberValue;
    NSLog(@"numberValue = %@", numberValue);

    NSDate *dateValue = self.metadataItem.dateValue;
    NSLog(@"dateValue = %@", dateValue);
}

-(void)Filtering_Arrays_of_Metadata_Items
{

}
/*
 2016-10-20 14:07:17.089 AVAssetUsage[5155:303160] key=key, status=2
 2016-10-20 14:07:17.089 AVAssetUsage[5155:303160] key=keySpace, status=2
 2016-10-20 14:07:17.090 AVAssetUsage[5155:303160] key=commonKey, status=2
 2016-10-20 14:07:17.090 AVAssetUsage[5155:303160] key=value, status=2
 2016-10-20 14:07:17.090 AVAssetUsage[5155:303160] key=time, status=2
 2016-10-20 14:07:17.090 AVAssetUsage[5155:303160] key=duration, status=2
 2016-10-20 14:07:17.090 AVAssetUsage[5155:303160] key=locale, status=2
 2016-10-20 14:07:17.091 AVAssetUsage[5155:303160] key=dateValue, status=2
 2016-10-20 14:07:17.091 AVAssetUsage[5155:303160] key=extraAttributes, status=2
 2016-10-20 14:07:17.091 AVAssetUsage[5155:303160] key=dataType, status=2
 2016-10-20 14:07:17.106 AVAssetUsage[5155:303160] key=extendedLanguageTag, status=2
 2016-10-20 14:07:17.106 AVAssetUsage[5155:303160] key=identifier, status=2
 2016-10-20 14:07:17.106 AVAssetUsage[5155:303160] key=stringValue, status=2
 2016-10-20 14:07:17.106 AVAssetUsage[5155:303160] key=numberValue, status=2
 2016-10-20 14:07:17.106 AVAssetUsage[5155:303160] key=dateValue, status=2
 2016-10-20 14:07:17.107 AVAssetUsage[5155:303160] key = 1953068140
 2016-10-20 14:07:17.107 AVAssetUsage[5155:303160] keySpace = uiso
 2016-10-20 14:07:17.107 AVAssetUsage[5155:303160] commonKey = title
 2016-10-20 14:07:17.107 AVAssetUsage[5155:303160] key = My Movie
 {INVALID}
 {INVALID}
 2016-10-20 14:07:17.108 AVAssetUsage[5155:303160] locale=<__NSCFLocale: 0x7fb482e07a30>
 2016-10-20 14:07:17.109 AVAssetUsage[5155:303160] dataValue = (null)
 2016-10-20 14:07:17.110 AVAssetUsage[5155:303160] extraAttributes = {
 dataType = 2;
 dataTypeNamespace = "com.apple.quicktime.udta";
 }
 2016-10-20 14:07:17.110 AVAssetUsage[5155:303160] dataType = com.apple.metadata.datatype.UTF-8
 2016-10-20 14:07:17.110 AVAssetUsage[5155:303160] extendedLanguageTag = en
 2016-10-20 14:07:17.110 AVAssetUsage[5155:303160] identifier = uiso/titl
 2016-10-20 14:07:17.110 AVAssetUsage[5155:303160] identifierTemp = zx/z2xy
 2016-10-20 14:07:17.110 AVAssetUsage[5155:303160] keyTemp = <7a327879>
 2016-10-20 14:07:17.111 AVAssetUsage[5155:303160] keySpaceTemp = zx
 2016-10-20 14:07:17.135 AVAssetUsage[5155:303160] stringValue = My Movie
 2016-10-20 14:07:17.135 AVAssetUsage[5155:303160] numberValue = (null)
 2016-10-20 14:07:17.137 AVAssetUsage[5155:303160] dateValue = (null)
 */

#pragma mark - AVAssetTrack Task
-(void)AVAssetTrack_Task
{
    NSArray <AVAssetTrack *> *tracks = self.asset.tracks;

    for (AVAssetTrack *track in tracks) {
        self.track = track;
        NSLog(@"--------------");
        [self Basic_Properties];
        [self Temporal_Properties];
        [self Track_Language_Properties];
        [self Visual_Characteristics];
        [self Audible_Characteristics];
        [self Frame_Based_Characteristics];
        [self Track_Segments];
        [self Managing_Metadata];
        [self Associated_Tracks];
    }
}

-(void)Basic_Properties
{
    AVAsset *asset = self.track.asset;
    NSLog(@"asset = %@",asset);

    CMPersistentTrackID trackID = self.track.trackID;
    NSLog(@"trackID = %zd",trackID);

    NSString *mediaType = self.track.mediaType;
    NSLog(@"mediaType = %@",mediaType);

    BOOL hasMediaCharacteristic1 = [self.track hasMediaCharacteristic:AVMediaCharacteristicVisual];
    NSLog(@"has AVMediaCharacteristicVisual = %@", hasMediaCharacteristic1 ? @"YES": @"NO");


    BOOL hasMediaCharacteristic2 = [self.track hasMediaCharacteristic:AVMediaCharacteristicAudible];
    NSLog(@"has AVMediaCharacteristicAudible = %@", hasMediaCharacteristic2 ? @"YES": @"NO");


    BOOL hasMediaCharacteristic3 = [self.track hasMediaCharacteristic:AVMediaCharacteristicLegible];
    NSLog(@"has AVMediaCharacteristicLegible = %@", hasMediaCharacteristic3 ? @"YES": @"NO");

    NSArray *formatDescriptions = self.track.formatDescriptions;
    NSLog(@"formatDescriptions = %@",formatDescriptions);

    BOOL enabled = self.track.isEnabled;
    NSLog(@"enabled = %@", enabled ? @"YES": @"NO");

    BOOL playable = self.track.isPlayable;
    NSLog(@"playable = %@", playable ? @"YES": @"NO");

    BOOL selfContained = self.track.selfContained;
    NSLog(@"selfContained = %@", selfContained ? @"YES": @"NO");

    long long totalSampleDataLength = self.track.totalSampleDataLength;
    NSLog(@"totalSampleDataLength = %lld",totalSampleDataLength);
}
/*
 2016-10-20 14:35:13.597 AVAssetUsage[5450:328829] asset = <AVURLAsset: 0x7ffe72d0d640, URL = file:///Users/zx/Library/Developer/CoreSimulator/Devices/642C28AE-DEEC-4F5B-96CC-04E2B5DC6A90/data/Containers/Bundle/Application/F40DDE0A-0C38-42A5-AF67-CC0C2F33E11F/AVAssetUsage.app/Sketch.mp4>
 2016-10-20 14:35:13.615 AVAssetUsage[5450:328829] trackID = 1
 2016-10-20 14:35:13.615 AVAssetUsage[5450:328829] mediaType = soun
 2016-10-20 14:35:13.615 AVAssetUsage[5450:328829] has AVMediaCharacteristicVisual = NO
 2016-10-20 14:35:13.616 AVAssetUsage[5450:328829] has AVMediaCharacteristicAudible = YES
 2016-10-20 14:35:13.616 AVAssetUsage[5450:328829] has AVMediaCharacteristicLegible = NO
 2016-10-20 14:35:13.617 AVAssetUsage[5450:328829] formatDescriptions = (
 "<CMAudioFormatDescription 0x7ffe72d7d4a0 [0x104f7ca40]> {\n\tmediaType:'soun' \n\tmediaSubType:'aac ' \n\tmediaSpecific: {\n\t\tASBD: {\n\t\t\tmSampleRate: 48000.000000 \n\t\t\tmFormatID: 'aac ' \n\t\t\tmFormatFlags: 0x0 \n\t\t\tmBytesPerPacket: 0 \n\t\t\tmFramesPerPacket: 1024 \n\t\t\tmBytesPerFrame: 0 \n\t\t\tmChannelsPerFrame: 2 \n\t\t\tmBitsPerChannel: 0 \t} \n\t\tcookie: {<CFData 0x7ffe72f2a010 [0x104f7ca40]>{length = 39, capacity = 39, bytes = 0x03808080220000000480808014401500 ... 1190068080800102}} \n\t\tACL: {Stereo (L R)} \n\t} \n\textensions: {<CFBasicHash 0x7ffe72d7ce60 [0x104f7ca40]>{type = immutable dict, count = 1,\nentries =>\n\t2 : <CFString 0x105173930 [0x104f7ca40]>{contents = \"VerbatimISOSampleEntry\"} = <CFData 0x7ffe72d7d530 [0x104f7ca40]>{length = 87, capacity = 87, bytes = 0x000000576d7034610000000000000001 ... 1190068080800102}\n}\n}\n}"
 )
 2016-10-20 14:35:13.641 AVAssetUsage[5450:328829] enabled = YES
 2016-10-20 14:35:13.641 AVAssetUsage[5450:328829] playable = YES
 2016-10-20 14:35:13.642 AVAssetUsage[5450:328829] selfContained = YES
 2016-10-20 14:35:13.643 AVAssetUsage[5450:328829] totalSampleDataLength = 9150530
 2016-10-20 14:35:13.643 AVAssetUsage[5450:328829] --------------
 2016-10-20 14:35:13.643 AVAssetUsage[5450:328829] asset = <AVURLAsset: 0x7ffe72d0d640, URL = file:///Users/zx/Library/Developer/CoreSimulator/Devices/642C28AE-DEEC-4F5B-96CC-04E2B5DC6A90/data/Containers/Bundle/Application/F40DDE0A-0C38-42A5-AF67-CC0C2F33E11F/AVAssetUsage.app/Sketch.mp4>
 2016-10-20 14:35:13.643 AVAssetUsage[5450:328829] trackID = 2
 2016-10-20 14:35:13.644 AVAssetUsage[5450:328829] mediaType = vide
 2016-10-20 14:35:13.644 AVAssetUsage[5450:328829] has AVMediaCharacteristicVisual = YES
 2016-10-20 14:35:13.645 AVAssetUsage[5450:328829] has AVMediaCharacteristicAudible = NO
 2016-10-20 14:35:13.645 AVAssetUsage[5450:328829] has AVMediaCharacteristicLegible = NO
 2016-10-20 14:35:13.646 AVAssetUsage[5450:328829] formatDescriptions = (
 "<CMVideoFormatDescription 0x7ffe72e33640 [0x104f7ca40]> {\n\tmediaType:'vide' \n\tmediaSubType:'avc1' \n\tmediaSpecific: {\n\t\tcodecType: 'avc1'\t\tdimensions: 960 x 540 \n\t} \n\textensions: {<CFBasicHash 0x7ffe72e3c110 [0x104f7ca40]>{type = immutable dict, count = 16,\nentries =>\n\t0 : <CFString 0x10943d138 [0x104f7ca40]>{contents = \"CVImageBufferColorPrimaries\"} = <CFString 0x10943d178 [0x104f7ca40]>{contents = \"SMPTE_C\"}\n\t2 : <CFString 0x105173950 [0x104f7ca40]>{contents = \"FormatName\"} = 'avc1'\n\t3 : <CFString 0x105173b30 [0x104f7ca40]>{contents = \"SpatialQuality\"} = <CFNumber 0xb000000000000002 [0x104f7ca40]>{value = +0, type = kCFNumberSInt32Type}\n\t4 : <CFString 0x10943d1b8 [0x104f7ca40]>{contents = \"CVImageBufferTransferFunction\"} = <CFString 0x10943d078 [0x104f7ca40]>{contents = \"ITU_R_709_2\"}\n\t5 : <CFString 0x105173b50 [0x104f7ca40]>{contents = \"Version\"} = <CFNumber 0xb000000000000001 [0x104f7ca40]>{value = +0, type = kCFNumberSInt16Type}\n\t6 : <CFString 0x10943d218 [0x104f7ca40]>{contents = \"CVImageBufferChromaLocationBottomField\"} = <CFString 0x10943d238 [0x104f7ca40]>{contents = \"Left\"}\n\t8 : <CFString 0x10943cf98 [0x104f7ca40]>{contents = \"CVPixelAspectRatio\"} = <CFBasicHash 0x7ffe72e3bad0 [0x104f7ca40]>{type = immutable dict, count = 2,\nentries =>\n\t1 : <CFString 0x10943cfb8 [0x104f7ca40]>{contents = \"HorizontalSpacing\"} = <CFNumber 0xb000000000000012 [0x104f7ca40]>{value = +1, type = kCFNumberSInt32Type}\n\t2 : <CFString 0x10943cfd8 [0x104f7ca40]>{contents = \"VerticalSpacing\"} = <CFNumber 0xb000000000000012 [0x104f7ca40]>{value = +1, type = kCFNumberSInt32Type}\n}\n\n\t11 : <CFString 0x105173b70 [0x104f7ca40]>{contents = \"RevisionLevel\"} = <CFNumber 0xb000000000000001 [0x104f7ca40]>{value = +0, type = kCFNumberSInt16Type}\n\t12 : <CFString 0x105173b10 [0x104f7ca40]>{contents = \"TemporalQuality\"} = <CFNumber 0xb000000000000002 [0x104f7ca40]>{value = +0, type = kCFNumberSInt32Type}\n\t14 : <CFString 0x10943d058 [0x104f7ca40]>{contents = \"CVImageBufferYCbCrMatrix\"} = <CFString 0x10943d098 [0x104f7ca40]>{contents = \"ITU_R_601_4\"}\n\t16 : <CFString 0x10943d1f8 [0x104f7ca40]>{contents = \"CVImageBufferChromaLocationTopField\"} = <CFString 0x10943d238 [0x104f7ca40]>{contents = \"Left\"}\n\t17 : <CFString 0x105173930 [0x104f7ca40]>{contents = \"VerbatimISOSampleEntry\"} = <CFData 0x7ffe72e3bf50 [0x104f7ca40]>{length = 190, capacity = 190, bytes = 0x000000be617663310000000000000001 ... 0000000100000001}\n\t18 : <CFString 0x1051738f0 [0x104f7ca40]>{contents = \"SampleDescriptionExtensionAtoms\"} = <CFBasicHash 0x7ffe72e3c050 [0x104f7ca40]>{type = immutable dict, count = 1,\nentries =>\n\t2 : avcC = <CFData 0x7ffe72e3c090 [0x104f7ca40]>{length = 51, capacity = 51, bytes = 0x0164001fffe100242764001fac1316c0 ... 1401000428ee1f2c}\n}\n\n\t19 : <CFString 0x105173a90 [0x104f7ca40]>{contents = \"FullRangeVideo\"} = <CFBoolean 0x104f7d528 [0x104f7ca40]>{value = false}\n\t20 : <CFString 0x10943ced8 [0x104f7ca40]>{contents = \"CVFieldCount\"} = <CFNumber 0xb000000000000010 [0x104f7ca40]>{value = +1, type = kCFNumberSInt8Type}\n\t22 : <CFString 0x105173970 [0x104f7ca40]>{contents = \"Depth\"} = <CFNumber 0xb000000000000181 [0x104f7ca40]>{value = +24, type = kCFNumberSInt16Type}\n}\n}\n}"
 )
 2016-10-20 14:35:13.649 AVAssetUsage[5450:328829] enabled = YES
 2016-10-20 14:35:13.649 AVAssetUsage[5450:328829] playable = YES
 2016-10-20 14:35:13.650 AVAssetUsage[5450:328829] selfContained = YES
 2016-10-20 14:35:13.650 AVAssetUsage[5450:328829] totalSampleDataLength = 57242810
 */

-(void)Temporal_Properties
{
    CMTimeRange timeRange = self.track.timeRange;
    CMTimeRangeShow(timeRange);

    CMTimeScale naturalTimeScale = self.track.naturalTimeScale;
    NSLog(@"naturalTimeScale = %zd",naturalTimeScale);

    float estimatedDataRate = self.track.estimatedDataRate;
    NSLog(@"estimatedDataRate = %.2f",estimatedDataRate);
}

/*

 2016-10-20 14:38:41.053 AVAssetUsage[5493:331622] totalSampleDataLength = 9150530
 {{0/30000 = 0.000}, {8814806/30000 = 293.827}}
 2016-10-20 14:38:41.066 AVAssetUsage[5493:331622] naturalTimeScale = 48000
 2016-10-20 14:38:41.066 AVAssetUsage[5493:331622] estimatedDataRate = 249088.91

 2016-10-20 14:38:41.084 AVAssetUsage[5493:331622] totalSampleDataLength = 57242810
 {{0/30000 = 0.000}, {8814806/30000 = 293.827}}
 2016-10-20 14:38:41.085 AVAssetUsage[5493:331622] naturalTimeScale = 30000
 2016-10-20 14:38:41.085 AVAssetUsage[5493:331622] estimatedDataRate = 1558545.25
 */

-(void)Track_Language_Properties
{
    NSString *languageCode = self.track.languageCode;
    NSLog(@"languageCode = %@",languageCode);

    NSString *extendedLanguageTag = self.track.extendedLanguageTag;
    NSLog(@"extendedLanguageTag = %@",extendedLanguageTag);

}

/*

 2016-10-20 14:41:13.216 AVAssetUsage[5534:334104] languageCode = eng
 2016-10-20 14:41:13.216 AVAssetUsage[5534:334104] extendedLanguageTag = (null)

 2016-10-20 14:41:13.224 AVAssetUsage[5534:334104] languageCode = und
 2016-10-20 14:41:13.225 AVAssetUsage[5534:334104] extendedLanguageTag = (null)
 */

-(void)Visual_Characteristics
{
    CGSize naturalSize = self.track.naturalSize;
    NSLog(@"naturalSize = %@",NSStringFromCGSize(naturalSize));

    CGAffineTransform preferredTransform = self.track.preferredTransform;
    NSLog(@"preferredTransform = %@",NSStringFromCGAffineTransform(preferredTransform));
}
/*

 2016-10-20 14:43:26.233 AVAssetUsage[5565:336286] naturalSize = {0, 0}
 2016-10-20 14:43:26.233 AVAssetUsage[5565:336286] preferredTransform = [1, 0, 0, 1, 0, 0]

 2016-10-20 14:43:26.243 AVAssetUsage[5565:336286] naturalSize = {960, 540}
 2016-10-20 14:43:26.243 AVAssetUsage[5565:336286] preferredTransform = [1, 0, 0, 1, 0, 0]
 */

-(void)Audible_Characteristics
{
    float preferredVolume = self.track.preferredVolume;
    NSLog(@"preferredVolume = %.2f",preferredVolume);
}
/*
 2016-10-20 14:47:39.698 AVAssetUsage[5623:340538] preferredVolume = 1.00

 2016-10-20 14:47:39.706 AVAssetUsage[5623:340538] preferredVolume = 0.00
 */

-(void)Frame_Based_Characteristics
{
    float nominalFrameRate = self.track.nominalFrameRate;
    NSLog(@"nominalFrameRate = %.2f",nominalFrameRate);

    CMTime minFrameDuration = self.track.minFrameDuration;
    CMTimeShow(minFrameDuration);

    BOOL requiresFrameReordering = self.track.requiresFrameReordering;
    NSLog(@"requiresFrameReordering = %@", requiresFrameReordering ? @"YES": @"NO");

}

/*
 2016-10-20 14:47:39.698 AVAssetUsage[5623:340538] nominalFrameRate = 46.88
 {INVALID}
 2016-10-20 14:47:39.698 AVAssetUsage[5623:340538] requiresFrameReordering = NO

 2016-10-20 14:47:39.707 AVAssetUsage[5623:340538] nominalFrameRate = 29.97
 {1001/30000 = 0.033}
 2016-10-20 14:47:39.707 AVAssetUsage[5623:340538] requiresFrameReordering = NO
 */

-(void)Track_Segments
{
    NSArray <AVAssetTrackSegment *> *segments = self.track.segments;
    NSLog(@"segments = %@",segments);
}
/*

 2016-10-20 14:50:06.479 AVAssetUsage[5652:343004] segments = (
 "<AVAssetTrackSegment: 0x7f8911730770>"
 )

 2016-10-20 14:50:06.488 AVAssetUsage[5652:343004] segments = (
 "<AVAssetTrackSegment: 0x7f8911620790>"
 )
 */

-(void)Managing_Metadata
{
    NSArray <AVMetadataItem *> *commonMetadata = self.track.commonMetadata;
    NSLog(@"commonMetadata = %@", commonMetadata);

    NSArray <AVMetadataItem *> *metadata = self.track.metadata;
    NSLog(@"metadata = %@", metadata);

    NSArray <NSString *> *availableMetadataFormats = self.track.availableMetadataFormats;
    NSLog(@"availableMetadataFormats = %@",availableMetadataFormats);

}
/*
 2016-10-20 14:53:06.557 AVAssetUsage[5696:345684] commonMetadata = (
 )
 2016-10-20 14:53:06.568 AVAssetUsage[5696:345684] metadata = (
 )
 2016-10-20 14:53:06.569 AVAssetUsage[5696:345684] availableMetadataFormats = (
 )

 2016-10-20 14:53:06.640 AVAssetUsage[5696:345684] commonMetadata = (
 )
 2016-10-20 14:53:06.640 AVAssetUsage[5696:345684] metadata = (
 )
 2016-10-20 14:53:06.640 AVAssetUsage[5696:345684] availableMetadataFormats = (
 )


 */

-(void)Associated_Tracks
{
    NSArray <NSString *> *availableTrackAssociationTypes = [self.track availableMetadataFormats];
    NSLog(@"availableTrackAssociationTypes = %@",availableTrackAssociationTypes);
}

/*
 2016-10-20 14:55:13.233 AVAssetUsage[5728:347623] availableTrackAssociationTypes = (
 )
 2016-10-20 14:55:13.241 AVAssetUsage[5728:347623] availableTrackAssociationTypes = (
 )
 */


@end
