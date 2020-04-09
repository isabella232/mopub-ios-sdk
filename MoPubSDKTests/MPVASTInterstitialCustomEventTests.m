//
//  MPVASTInterstitialCustomEventTests.m
//
//  Copyright 2018-2020 Twitter, Inc.
//  Licensed under the MoPub SDK License Agreement
//  http://www.mopub.com/legal/sdk-license-agreement/
//

#import <XCTest/XCTest.h>
#import "MPAdConfiguration.h"
#import "MPMockAdDestinationDisplayAgent.h"
#import "MPMockDiskLRUCache.h"
#import "MPMockVASTTracking.h"
#import "MPMockInterstitialCustomEventDelegate.h"
#import "MPVASTInterstitialCustomEvent+Testing.h"
#import "XCTestCase+MPAddition.h"

static const NSTimeInterval kDefaultTimeout = 10;

@interface MPVASTInterstitialCustomEventTests : XCTestCase
@end

@implementation MPVASTInterstitialCustomEventTests

- (MPVASTInterstitialCustomEvent *)createTestSubject {
    MPVASTInterstitialCustomEvent *event = [MPVASTInterstitialCustomEvent new];
    event.adDestinationDisplayAgent = [MPMockAdDestinationDisplayAgent new];
    event.mediaFileCache = [MPMockDiskLRUCache new];
    event.vastTracking = [MPMockVASTTracking new];
    return event;
}

/// Test no crash happens for invalid inputs.
- (void)testNoCrash {
    MPVASTInterstitialCustomEvent *event = [self createTestSubject];

    // test passes if no crash: should not crash if valid ad config is not present
    [event requestInterstitialWithCustomEventInfo:@{} adMarkup:nil];
    [event requestRewardedVideoWithCustomEventInfo:@{} adMarkup:nil];

    // test passes if no crash: should not crash if root view controller is nil
    [event showInterstitialFromRootViewController:nil];
}

/// Test the custom event as an `MPVideoPlayerContainerViewDelegate`.
- (void)testMPVideoPlayerContainerViewDelegate {
    NSTimeInterval videoDuration = 30;
    NSError *mockError = [NSError errorWithDomain:@"mock" code:-1 userInfo:nil];
    MPVideoPlayerContainerView *mockPlayerView = [MPVideoPlayerContainerView new];
    MPVASTIndustryIconView *mockIndustryIconView = [MPVASTIndustryIconView new];
    MPVASTCompanionAdView *mockCompanionAdView = [MPVASTCompanionAdView new];

    MPVASTInterstitialCustomEvent *event = [self createTestSubject];
    MPMockVASTTracking *mockVastTracking = (MPMockVASTTracking *)event.vastTracking;
    MPMockInterstitialCustomEventDelegate *mockDelegate = [MPMockInterstitialCustomEventDelegate new];
    event.delegate = mockDelegate; // the delegate needs a strong reference in current scope

    [event videoPlayerContainerViewDidLoadVideo:mockPlayerView];
    XCTAssertEqual(1, [mockDelegate countOfSelectorCalls:@selector(interstitialCustomEvent:didLoadAd:)]);

    [event videoPlayerContainerViewDidFailToLoadVideo:mockPlayerView error:mockError];
    XCTAssertEqual(1, [mockDelegate countOfSelectorCalls:@selector(interstitialCustomEvent:didFailToLoadAdWithError:)]);

    [mockDelegate resetSelectorCounter];
    [mockVastTracking resetHistory];
    [event videoPlayerContainerViewDidStartVideo:mockPlayerView duration:videoDuration];
    XCTAssertEqual(3, [mockVastTracking countOfSelectorCalls:@selector(handleVideoEvent:videoTimeOffset:)]); // Start, CreativeView, and Impression
    XCTAssertEqual(1, [mockVastTracking countOfVideoEventCalls:MPVideoEventCreativeView]);
    XCTAssertEqual(1, [mockVastTracking countOfVideoEventCalls:MPVideoEventImpression]);

    [mockDelegate resetSelectorCounter];
    [mockVastTracking resetHistory];
    [event videoPlayerContainerViewDidCompleteVideo:mockPlayerView duration:videoDuration];
    XCTAssertEqual(1, [mockDelegate countOfSelectorCalls:@selector(rewardedVideoShouldRewardUserForCustomEvent:reward:)]);
    XCTAssertEqual(1, [mockVastTracking countOfSelectorCalls:@selector(handleVideoEvent:videoTimeOffset:)]);
    XCTAssertEqual(1, [mockVastTracking countOfVideoEventCalls:MPVideoEventComplete]);

    [mockVastTracking resetHistory];
    [event videoPlayerContainerView:mockPlayerView videoDidReachProgressTime:videoDuration duration:videoDuration];
    XCTAssertEqual(1, [mockVastTracking countOfSelectorCalls:@selector(handleVideoProgressEvent:videoDuration:)]);
    XCTAssertEqual(1, [mockVastTracking countOfVideoEventCalls:MPVideoEventStart]);
    [event videoPlayerContainerView:mockPlayerView videoDidReachProgressTime:videoDuration * 0.25 duration:videoDuration];
    XCTAssertEqual(2, [mockVastTracking countOfSelectorCalls:@selector(handleVideoProgressEvent:videoDuration:)]);
    XCTAssertEqual(1, [mockVastTracking countOfVideoEventCalls:MPVideoEventFirstQuartile]);
    [event videoPlayerContainerView:mockPlayerView videoDidReachProgressTime:videoDuration * 5 duration:videoDuration];
    XCTAssertEqual(3, [mockVastTracking countOfSelectorCalls:@selector(handleVideoProgressEvent:videoDuration:)]);
    XCTAssertEqual(1, [mockVastTracking countOfVideoEventCalls:MPVideoEventMidpoint]);
    [event videoPlayerContainerView:mockPlayerView videoDidReachProgressTime:videoDuration * 0.75 duration:videoDuration];
    XCTAssertEqual(4, [mockVastTracking countOfSelectorCalls:@selector(handleVideoProgressEvent:videoDuration:)]);
    XCTAssertEqual(1, [mockVastTracking countOfVideoEventCalls:MPVideoEventThirdQuartile]);
    [mockVastTracking resetHistory];

    [mockDelegate resetSelectorCounter];
    [mockVastTracking resetHistory];
    [event videoPlayerContainerView:mockPlayerView
                    didTriggerEvent:MPVideoPlayerEvent_ClickThrough
                      videoProgress:1];
    XCTAssertEqual(1, [mockDelegate countOfSelectorCalls:@selector(interstitialCustomEventDidReceiveTapEvent:)]);
    XCTAssertEqual(0, [mockVastTracking countOfSelectorCalls:@selector(uniquelySendURLs:)]); // 0 since URL is nil
    XCTAssertEqual(1, [mockVastTracking countOfSelectorCalls:@selector(handleVideoEvent:videoTimeOffset:)]);
    XCTAssertEqual(1, [mockVastTracking countOfVideoEventCalls:MPVideoEventClick]);

    [mockVastTracking resetHistory];
    [event videoPlayerContainerView:mockPlayerView
                    didTriggerEvent:MPVideoPlayerEvent_Close
                      videoProgress:2];
    XCTAssertEqual(2, [mockVastTracking countOfSelectorCalls:@selector(handleVideoEvent:videoTimeOffset:)]);
    XCTAssertEqual(1, [mockVastTracking countOfVideoEventCalls:MPVideoEventClose]);
    XCTAssertEqual(1, [mockVastTracking countOfVideoEventCalls:MPVideoEventCloseLinear]);

    [mockVastTracking resetHistory];
    [event videoPlayerContainerView:mockPlayerView
                    didTriggerEvent:MPVideoPlayerEvent_Skip
                      videoProgress:3];
    XCTAssertEqual(3, [mockVastTracking countOfSelectorCalls:@selector(handleVideoEvent:videoTimeOffset:)]);
    XCTAssertEqual(1, [mockVastTracking countOfSelectorCalls:@selector(stopViewabilityTracking)]);
    XCTAssertEqual(1, [mockVastTracking countOfVideoEventCalls:MPVideoEventSkip]);
    XCTAssertEqual(1, [mockVastTracking countOfVideoEventCalls:MPVideoEventClose]);
    XCTAssertEqual(1, [mockVastTracking countOfVideoEventCalls:MPVideoEventCloseLinear]);
    [mockVastTracking resetHistory];

    [event videoPlayerContainerView:mockPlayerView didShowIndustryIconView:mockIndustryIconView];
    XCTAssertEqual(1, [mockVastTracking countOfSelectorCalls:@selector(uniquelySendURLs:)]);

    [mockVastTracking resetHistory];
    [event videoPlayerContainerView:mockPlayerView didClickIndustryIconView:mockIndustryIconView overridingClickThroughURL:nil];
    XCTAssertEqual(1, [mockVastTracking countOfSelectorCalls:@selector(uniquelySendURLs:)]);

    [mockVastTracking resetHistory];
    [event videoPlayerContainerView:mockPlayerView didShowCompanionAdView:mockCompanionAdView];
    XCTAssertEqual(1, [mockVastTracking countOfSelectorCalls:@selector(uniquelySendURLs:)]);

    [mockDelegate resetSelectorCounter];
    [mockVastTracking resetHistory];
    [event videoPlayerContainerView:mockPlayerView didClickCompanionAdView:mockCompanionAdView overridingClickThroughURL:nil];
    XCTAssertEqual(1, [mockDelegate countOfSelectorCalls:@selector(interstitialCustomEventDidReceiveTapEvent:)]);
    XCTAssertEqual(1, [mockVastTracking countOfSelectorCalls:@selector(uniquelySendURLs:)]);

    [event videoPlayerContainerView:mockPlayerView didFailToLoadCompanionAdView:mockCompanionAdView]; // pass if no crash
}

/// Test the custom event as an `MPRewardedVideoCustomEvent`.
- (void)testMPRewardedVideoCustomEvent {
    MPVASTInterstitialCustomEvent *event = [self createTestSubject];
    MPMockInterstitialCustomEventDelegate *mockDelegate = [MPMockInterstitialCustomEventDelegate new];
    event.delegate = mockDelegate; // the delegate needs a strong reference in current scope

    XCTAssertFalse([event enableAutomaticImpressionAndClickTracking]);
    [event handleAdPlayedForCustomEventNetwork]; // test passes if no crash
    [event handleCustomEventInvalidated]; // test passes if no crash
    [event presentRewardedVideoFromViewController:nil]; // test passes if no crash
    [event requestRewardedVideoWithCustomEventInfo:@{} adMarkup:nil]; // test passes if no crash
}

/// Test the custom event as an `MPInterstitialViewControllerAppearanceDelegate`.
- (void)testMPInterstitialViewControllerAppearanceDelegate {
    MPVASTInterstitialCustomEvent *event = [self createTestSubject];
    MPMockInterstitialCustomEventDelegate *mockDelegate = [MPMockInterstitialCustomEventDelegate new];
    event.delegate = mockDelegate; // the delegate needs a strong reference in current scope

    [event interstitialWillAppear:nil];
    XCTAssertEqual(1, [mockDelegate countOfSelectorCalls:@selector(interstitialCustomEventWillAppear:)]);

    [event interstitialDidAppear:nil];
    XCTAssertEqual(1, [mockDelegate countOfSelectorCalls:@selector(interstitialCustomEventDidAppear:)]);

    [event interstitialWillDisappear:nil];
    XCTAssertEqual(1, [mockDelegate countOfSelectorCalls:@selector(interstitialCustomEventWillDisappear:)]);

    [event interstitialDidDisappear:nil];
    XCTAssertEqual(1, [mockDelegate countOfSelectorCalls:@selector(interstitialCustomEventDidDisappear:)]);
}

#pragma mark - VAST Trackers

- (void)testVASTTrackersCombined {
    // VAST Tracking events to check
    NSArray<MPVideoEvent> *trackingEventNames = @[
        MPVideoEventComplete,
        MPVideoEventFirstQuartile,
        MPVideoEventMidpoint,
        MPVideoEventStart,
        MPVideoEventThirdQuartile
    ];

    // Populate MPX trackers coming back in the metadata field
    NSDictionary *headers = @{
        kVASTVideoTrackersMetadataKey: @"{\"events\":[\"start\",\"midpoint\",\"thirdQuartile\",\"firstQuartile\",\"complete\"],\"urls\":[\"https://mpx.mopub.com/video_event?event_type=%%VIDEO_EVENT%%\"]}"
    };

    NSData *vastData = [self dataFromXMLFileNamed:@"VAST_3.0_linear_ad_comprehensive"];
    MPAdConfiguration *mockVastConfig = [[MPAdConfiguration alloc] initWithMetadata:headers data:vastData isFullscreenAd:YES];

    // Configure the delegate
    MPMockInterstitialCustomEventDelegate *mockDelegate = [MPMockInterstitialCustomEventDelegate new];
    mockDelegate.mockConfiguration = mockVastConfig;

    MPVASTInterstitialCustomEvent *event = [self createTestSubject];
    event.delegate = mockDelegate; // the delegate needs a strong reference in current scope

    // Load the fake video ad
    XCTestExpectation * expectation = [self expectationWithDescription:@"Wait for load"];
    [event fetchAndLoadAdWithConfiguration:mockVastConfig fetchAdCompletion:^(NSError * error) {
        [expectation fulfill];
    }];

    [self waitForExpectationsWithTimeout:kDefaultTimeout handler:^(NSError * _Nullable error) {
        if (error != nil) {
            XCTFail(@"Timed out");
        }
    }];

    // Verify that the video configuration includes both the VAST XML video trackers and
    // the MPX trackers
    MPVideoConfig *videoConfig = event.videoConfig;
    XCTAssertNotNil(videoConfig);

    for (MPVideoEvent eventName in trackingEventNames) {
        NSArray<MPVASTTrackingEvent *> *trackers = [videoConfig trackingEventsForKey:eventName];
        XCTAssert(trackers.count > 0);

        // Map the URLs into Strings
        NSMutableArray<NSString *> *trackerUrlStrings = [NSMutableArray array];
        [trackers enumerateObjectsUsingBlock:^(MPVASTTrackingEvent * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            [trackerUrlStrings addObject:obj.URL.absoluteString];
        }];

        // Expected MPX URL
        NSString *expectedUrl = [NSString stringWithFormat:@"https://mpx.mopub.com/video_event?event_type=%@", eventName];
        XCTAssert([trackerUrlStrings containsObject:expectedUrl], @"Trackers for %@ event did not contain %@", eventName, expectedUrl);

        // Expected VAST URL
        NSString *expectedEmbeddedUrl = [NSString stringWithFormat:@"https://www.mopub.com/?q=%@", eventName];
        XCTAssert([trackerUrlStrings containsObject:expectedEmbeddedUrl], @"Trackers for %@ event did not contain %@", eventName, expectedEmbeddedUrl);
    }
}

- (void)testVASTCompanionAdTrackersCombined {
    // VAST Tracking events to check
    NSArray<MPVideoEvent> *trackingEventNames = @[
        MPVideoEventCompanionAdClick,
        MPVideoEventCompanionAdView,
        MPVideoEventComplete,
        MPVideoEventFirstQuartile,
        MPVideoEventMidpoint,
        MPVideoEventStart,
        MPVideoEventThirdQuartile
    ];

    // Populate MPX trackers coming back in the metadata field
    NSDictionary *headers = @{
        kVASTVideoTrackersMetadataKey: @"{\"events\":[\"start\",\"midpoint\",\"thirdQuartile\",\"companionAdClick\",\"firstQuartile\",\"companionAdView\",\"complete\"],\"urls\":[\"https://mpx.mopub.com/video_event?event_type=%%VIDEO_EVENT%%\"]}"
    };

    NSData *vastData = [self dataFromXMLFileNamed:@"VAST_3.0_linear_ad_comprehensive"];
    MPAdConfiguration *mockVastConfig = [[MPAdConfiguration alloc] initWithMetadata:headers data:vastData isFullscreenAd:YES];

    // Configure the delegate
    MPMockInterstitialCustomEventDelegate *mockDelegate = [MPMockInterstitialCustomEventDelegate new];
    mockDelegate.mockConfiguration = mockVastConfig;

    MPVASTInterstitialCustomEvent *event = [self createTestSubject];
    event.delegate = mockDelegate; // the delegate needs a strong reference in current scope

    // Load the fake video ad
    XCTestExpectation * expectation = [self expectationWithDescription:@"Wait for load"];
    [event fetchAndLoadAdWithConfiguration:mockVastConfig fetchAdCompletion:^(NSError * error) {
        [expectation fulfill];
    }];

    [self waitForExpectationsWithTimeout:kDefaultTimeout handler:^(NSError * _Nullable error) {
        if (error != nil) {
            XCTFail(@"Timed out");
        }
    }];

    // Verify that the ad configuration includes the MPX trackers
    NSDictionary<MPVideoEvent, NSArray<MPVASTTrackingEvent *> *> *vastVideoTrackers = mockVastConfig.vastVideoTrackers;
    XCTAssertNotNil(vastVideoTrackers);

    for (MPVideoEvent eventName in trackingEventNames) {
        NSArray<MPVASTTrackingEvent *> *trackers = vastVideoTrackers[eventName];
        XCTAssert(trackers.count > 0);

        // Map the URLs into Strings
        NSMutableArray<NSString *> *trackerUrlStrings = [NSMutableArray array];
        [trackers enumerateObjectsUsingBlock:^(MPVASTTrackingEvent * _Nonnull event, NSUInteger idx, BOOL * _Nonnull stop) {
            [trackerUrlStrings addObject:event.URL.absoluteString];
        }];

        // Expected MPX URL
        NSString *expectedUrl = [NSString stringWithFormat:@"https://mpx.mopub.com/video_event?event_type=%@", eventName];
        XCTAssert([trackerUrlStrings containsObject:expectedUrl], @"Trackers for %@ event did not contain %@", eventName, expectedUrl);
    }

    // Mocks
    MPMockVASTTracking *mockVastTracking = (MPMockVASTTracking *)event.vastTracking;
    MPVideoPlayerContainerView *mockPlayerView = [MPVideoPlayerContainerView new];
    MPVASTCompanionAdView *mockCompanionAdView = [MPVASTCompanionAdView new];

    // Trigger Companion Ad View event
    [mockVastTracking resetHistory];
    [event videoPlayerContainerView:mockPlayerView didShowCompanionAdView:mockCompanionAdView];

    XCTAssertEqual(1, [mockVastTracking countOfSelectorCalls:@selector(uniquelySendURLs:)]);
    XCTAssertNotNil(mockVastTracking.historyOfSentURLs);
    XCTAssert(mockVastTracking.historyOfSentURLs.count == 1);

    NSURL *expectedCompanionAdViewUrl = [NSURL URLWithString:@"https://mpx.mopub.com/video_event?event_type=companionAdView"];
    XCTAssert([mockVastTracking.historyOfSentURLs containsObject:expectedCompanionAdViewUrl]);

    // Trigger COmpanion Ad Click event
    [mockVastTracking resetHistory];
    [event videoPlayerContainerView:mockPlayerView didClickCompanionAdView:mockCompanionAdView overridingClickThroughURL:nil];

    XCTAssertEqual(1, [mockVastTracking countOfSelectorCalls:@selector(uniquelySendURLs:)]);
    XCTAssertNotNil(mockVastTracking.historyOfSentURLs);
    XCTAssert(mockVastTracking.historyOfSentURLs.count == 1);

    NSURL *expectedCompanionAdClickUrl = [NSURL URLWithString:@"https://mpx.mopub.com/video_event?event_type=companionAdClick"];
    XCTAssert([mockVastTracking.historyOfSentURLs containsObject:expectedCompanionAdClickUrl]);
}

@end
