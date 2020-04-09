//
//  MPVASTInterstitialCustomEvent+Testing.h
//
//  Copyright 2018-2020 Twitter, Inc.
//  Licensed under the MoPub SDK License Agreement
//  http://www.mopub.com/legal/sdk-license-agreement/
//

#import <Foundation/Foundation.h>
#import "MPAdConfiguration.h"
#import "MPAdDestinationDisplayAgent.h"
#import "MPAnalyticsTracker.h"
#import "MPMediaFileCache.h"
#import "MPVASTInterstitialCustomEvent.h"
#import "MPVASTTracking.h"
#import "MPVideoConfig.h"
#import "MPVideoPlayerViewController.h"

NS_ASSUME_NONNULL_BEGIN

@interface MPVASTInterstitialCustomEvent (Testing) <MPVideoPlayerViewControllerDelegate>
@property (nonatomic, strong) id<MPAdDestinationDisplayAgent> adDestinationDisplayAgent;
@property (nonatomic, strong) id<MPAnalyticsTracker> analyticsTracker;
@property (nonatomic, strong) id<MPMediaFileCache> mediaFileCache;
@property (nonatomic, strong) id<MPVASTTracking> vastTracking;
@property (nonatomic, strong) MPVideoConfig *videoConfig;

- (void)fetchAndLoadAdWithConfiguration:(MPAdConfiguration *)configuration fetchAdCompletion:(void(^)(NSError *))complete;
- (void)videoPlayerContainerView:(MPVideoPlayerContainerView *)videoPlayerContainerView
          didShowCompanionAdView:(MPVASTCompanionAdView *)companionAdView;
- (void)videoPlayerContainerView:(MPVideoPlayerContainerView *)videoPlayerContainerView
         didClickCompanionAdView:(MPVASTCompanionAdView *)companionAdView
       overridingClickThroughURL:(NSURL * _Nullable)url;
@end

NS_ASSUME_NONNULL_END
