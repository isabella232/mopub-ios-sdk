//
//  MPBannerCustomEventAdapterTests.m
//
//  Copyright 2018-2020 Twitter, Inc.
//  Licensed under the MoPub SDK License Agreement
//  http://www.mopub.com/legal/sdk-license-agreement/
//

#import <XCTest/XCTest.h>
#import "MPAdConfiguration.h"
#import "MPAdConfigurationFactory.h"
#import "MPBannerAdapterDelegateHandler.h"
#import "MPBannerCustomEvent.h"
#import "MPBannerCustomEventAdapter+Testing.h"
#import "MPConstants.h"
#import "MPError.h"
#import "MPHTMLBannerCustomEvent.h"
#import "MPMockAnalyticsTracker.h"
#import "MPMockBannerCustomEvent.h"
#import "MPMRAIDBannerCustomEvent.h"

@interface MPBannerCustomEventAdapterTests : XCTestCase

@end

@implementation MPBannerCustomEventAdapterTests

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

// When an AD is in the imp tracking experiment, banner impressions (include all banner formats) are fired from SDK.
- (void)testShouldTrackImpOnDisplayWhenExperimentEnabled {
    NSDictionary *headers = @{ kBannerImpressionVisableMsMetadataKey: @"0", kBannerImpressionMinPixelMetadataKey:@"1"};
    MPAdConfiguration *config = [[MPAdConfiguration alloc] initWithMetadata:headers data:nil isFullscreenAd:NO];

    MPBannerCustomEventAdapter *adapter = [MPBannerCustomEventAdapter new];

    adapter.configuration = config;

    [adapter didDisplayAd];

    XCTAssertFalse(adapter.hasTrackedImpression);
}

// When an AD is not in the imp tracking experiment, banner impressions are fired from JS directly. SDK doesn't fire impression.
- (void)testImpFiredWhenAutoTrackingEnabledForHtmlAndExperimentDisabled {
    MPAdConfiguration *config = [MPAdConfiguration new];

    MPBannerCustomEventAdapter *adapter = [MPBannerCustomEventAdapter new];
    adapter.configuration = config;

    MPBannerCustomEvent *customEvent = [MPHTMLBannerCustomEvent new];
    adapter.bannerCustomEvent = customEvent;
    adapter.hasTrackedImpression = NO;

    [adapter didDisplayAd];

    XCTAssertFalse(adapter.hasTrackedImpression);
}

/// Test with `enableAutomaticImpressionAndClickTracking` being YES and then NO.
- (void)testClickTracking {
    MPMockAnalyticsTracker *trackerMock = [MPMockAnalyticsTracker new];
    MPMockBannerCustomEvent *customEventMock = [MPMockBannerCustomEvent new];
    MPBannerCustomEventAdapter *adapter = [MPBannerCustomEventAdapter new];
    adapter.configuration = [MPAdConfiguration new];
    adapter.bannerCustomEvent = customEventMock;
    adapter.analyticsTracker = trackerMock;
    customEventMock.delegate = adapter;

    // Test with `enableAutomaticImpressionAndClickTracking = YES`
    customEventMock.enableAutomaticImpressionAndClickTracking = YES;

    // It's caller's responsibility to call `trackClick` only once. If called twice, then it happens twice.
    [adapter trackClick];
    XCTAssertEqual(1, [trackerMock countOfSelectorCalls:@selector(trackClickForConfiguration:)]);
    [adapter trackClick];
    XCTAssertEqual(2, [trackerMock countOfSelectorCalls:@selector(trackClickForConfiguration:)]);
    adapter.hasTrackedClick = NO;

    // `WillBeginAction` implies the user click on a banner to open a web view. `trackClick` dedup is expected.
    [customEventMock.delegate bannerCustomEventWillBeginAction:customEventMock];
    XCTAssertEqual(3, [trackerMock countOfSelectorCalls:@selector(trackClickForConfiguration:)]);
    [customEventMock.delegate bannerCustomEventWillBeginAction:customEventMock];
    XCTAssertEqual(3, [trackerMock countOfSelectorCalls:@selector(trackClickForConfiguration:)]);
    adapter.hasTrackedClick = NO;

    // `WillExpandAd` is not considered as click for historical reasons.
    [customEventMock.delegate bannerCustomEventWillExpandAd:customEventMock];
    XCTAssertEqual(3, [trackerMock countOfSelectorCalls:@selector(trackClickForConfiguration:)]);
    [customEventMock.delegate bannerCustomEventWillExpandAd:customEventMock];
    XCTAssertEqual(3, [trackerMock countOfSelectorCalls:@selector(trackClickForConfiguration:)]);
    adapter.hasTrackedClick = NO;

    // `WillLeaveApplication` implies the user click on a banner to open a web view. `trackClick` dedup is expected.
    [customEventMock.delegate bannerCustomEventWillLeaveApplication:customEventMock];
    XCTAssertEqual(4, [trackerMock countOfSelectorCalls:@selector(trackClickForConfiguration:)]);
    [customEventMock.delegate bannerCustomEventWillLeaveApplication:customEventMock];
    XCTAssertEqual(4, [trackerMock countOfSelectorCalls:@selector(trackClickForConfiguration:)]);
    adapter.hasTrackedClick = NO;

    // Repeat the tests above with `enableAutomaticImpressionAndClickTracking = NO`
    [trackerMock reset];
    customEventMock.enableAutomaticImpressionAndClickTracking = NO;

    // It's caller's responsibility to call `trackClick` only once. If called twice, then it happens twice.
    [adapter trackClick];
    XCTAssertEqual(1, [trackerMock countOfSelectorCalls:@selector(trackClickForConfiguration:)]);
    [adapter trackClick];
    XCTAssertEqual(2, [trackerMock countOfSelectorCalls:@selector(trackClickForConfiguration:)]);
    adapter.hasTrackedClick = NO;

    // `WillBeginAction` has no effect since `trackClick` is expected to be called manually.
    [customEventMock.delegate bannerCustomEventWillBeginAction:customEventMock];
    XCTAssertEqual(2, [trackerMock countOfSelectorCalls:@selector(trackClickForConfiguration:)]);
    adapter.hasTrackedClick = NO;

    // `WillExpandAd`  has no effect since `trackClick` is expected to be called manually.
    [customEventMock.delegate bannerCustomEventWillExpandAd:customEventMock];
    XCTAssertEqual(2, [trackerMock countOfSelectorCalls:@selector(trackClickForConfiguration:)]);
    adapter.hasTrackedClick = NO;

    // `WillLeaveApplication`  has no effect since `trackClick` is expected to be called manually.
    [customEventMock.delegate bannerCustomEventWillLeaveApplication:customEventMock];
    XCTAssertEqual(2, [trackerMock countOfSelectorCalls:@selector(trackClickForConfiguration:)]);
}

#pragma mark - Timeout

- (void)testTimeoutOverrideSuccess {
    XCTestExpectation * expectation = [self expectationWithDescription:@"Wait for timeout"];

    // Generate the ad configurations
    MPAdConfiguration * bannerConfig = [MPAdConfigurationFactory defaultBannerConfigurationWithCustomEventClassName:@"MPMockBannerCustomEvent" additionalMetadata:@{kAdTimeoutMetadataKey: @(1000)}];

    // Configure handler
    __block BOOL didTimeout = NO;
    MPBannerAdapterDelegateHandler * handler = MPBannerAdapterDelegateHandler.new;
    handler.didFailToLoadAd = ^(NSError *error) {
        if (error != nil && error.code == MOPUBErrorAdRequestTimedOut) {
            didTimeout = YES;
        }

        [expectation fulfill];
    };

    // Adapter contains the timeout logic
    MPBannerCustomEventAdapter * adapter = [MPBannerCustomEventAdapter new];
    adapter.configuration = bannerConfig;
    adapter.delegate = handler;
    [adapter startTimeoutTimer];

    [self waitForExpectationsWithTimeout:BANNER_TIMEOUT_INTERVAL handler:^(NSError * _Nullable error) {
        if (error != nil) {
            XCTFail(@"Timed out");
        }
    }];

    // Verify error was timeout
    XCTAssertTrue(didTimeout);
}

@end
