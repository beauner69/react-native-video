#import "AVKit/AVKit.h"
#import "RCTVideoPlayerViewController.h"
#import "RCTVideoPlayerViewControllerDelegate.h"
#import "UIView+FindUIViewController.h"
#import <AVFoundation/AVFoundation.h>
#import <React/RCTComponent.h>

#if __has_include(<react-native-video/RCTVideoCache.h>)
#import <DVAssetLoaderDelegate/DVAssetLoaderDelegate.h>
#import <DVAssetLoaderDelegate/DVURLAsset.h>
#import <react-native-video/RCTVideoCache.h>
#endif

@class RCTEventDispatcher;
#if __has_include(<react-native-video/RCTVideoCache.h>)
@interface RCTVideo : UIView <RCTVideoPlayerViewControllerDelegate,
                              DVAssetLoaderDelegatesDelegate>
#else
@interface RCTVideo : UIView <RCTVideoPlayerViewControllerDelegate>
#endif

@property(nonatomic, copy) RCTBubblingEventBlock onVideoLoadStart;
@property(nonatomic, copy) RCTBubblingEventBlock onVideoLoad;
@property(nonatomic, copy) RCTBubblingEventBlock onVideoBuffer;
@property(nonatomic, copy) RCTBubblingEventBlock onVideoError;
@property(nonatomic, copy) RCTBubblingEventBlock onVideoProgress;
@property(nonatomic, copy) RCTBubblingEventBlock onVideoSeek;
@property(nonatomic, copy) RCTBubblingEventBlock onVideoEnd;
@property(nonatomic, copy) RCTBubblingEventBlock onTimedMetadata;
@property(nonatomic, copy) RCTBubblingEventBlock onVideoAudioBecomingNoisy;
@property(nonatomic, copy)
    RCTBubblingEventBlock onVideoFullscreenPlayerWillPresent;
@property(nonatomic, copy)
    RCTBubblingEventBlock onVideoFullscreenPlayerDidPresent;
@property(nonatomic, copy)
    RCTBubblingEventBlock onVideoFullscreenPlayerWillDismiss;
@property(nonatomic, copy)
    RCTBubblingEventBlock onVideoFullscreenPlayerDidDismiss;
@property(nonatomic, copy) RCTBubblingEventBlock onReadyForDisplay;
@property(nonatomic, copy) RCTBubblingEventBlock onPlaybackStalled;
@property(nonatomic, copy) RCTBubblingEventBlock onPlaybackResume;
@property(nonatomic, copy) RCTBubblingEventBlock onPlaybackRateChange;
@property(nonatomic, copy) RCTBubblingEventBlock onVideoExternalPlaybackChange;
@property(nonatomic, copy) RCTBubblingEventBlock onVideoLoadUpdate;

- (instancetype)initWithEventDispatcher:(RCTEventDispatcher *)eventDispatcher
    NS_DESIGNATED_INITIALIZER;

- (AVPlayerViewController *)createPlayerViewController:(AVPlayer *)player
                                        withPlayerItem:
                                            (AVPlayerItem *)playerItem ;

- (void)sendLoadUpdate:(NSString *)Map format:(NSString*)format;

@end
