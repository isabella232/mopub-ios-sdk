//
//  MPMockAnalyticsTracker.m
//
//  Copyright 2018-2020 Twitter, Inc.
//  Licensed under the MoPub SDK License Agreement
//  http://www.mopub.com/legal/sdk-license-agreement/
//

#import "MPMockAnalyticsTracker.h"

@interface MPMockAnalyticsTracker ()

@property (nonatomic, strong) MPSelectorCounter *selectotCounter;
@property (nonatomic, strong, readwrite) NSArray<NSURL *> *lastTrackedUrls;

@end

@implementation MPMockAnalyticsTracker

- (instancetype)init {
    if ([super init]) {
        _selectotCounter = [MPSelectorCounter new];
        _lastTrackedUrls = nil;
    }
    return self;
}

- (void)reset {
    self.lastTrackedUrls = nil;
    [self resetSelectorCounter];
}

#pragma mark - MPAnalyticsTracker

- (void)sendTrackingRequestForURLs:(NSArray<NSURL *> *)URLs {
    [self.selectotCounter incrementCountForSelector:@selector(sendTrackingRequestForURLs:)];
    if (self.lastTrackedUrls == nil) {
        self.lastTrackedUrls = URLs;
    } else {
        self.lastTrackedUrls = [self.lastTrackedUrls arrayByAddingObjectsFromArray:URLs];
    }
}

- (void)trackClickForConfiguration:(MPAdConfiguration *)configuration {
    [self.selectotCounter incrementCountForSelector:@selector(trackClickForConfiguration:)];
}

- (void)trackImpressionForConfiguration:(MPAdConfiguration *)configuration {
    [self.selectotCounter incrementCountForSelector:@selector(trackImpressionForConfiguration:)];
}

#pragma mark - MPSelectorCountable

- (NSUInteger)countOfSelectorCalls:(SEL)selector {
    return [self.selectotCounter countOfSelectorCalls:selector];
}

- (void)resetSelectorCounter {
    [self.selectotCounter resetSelectorCounter];
}

@end
