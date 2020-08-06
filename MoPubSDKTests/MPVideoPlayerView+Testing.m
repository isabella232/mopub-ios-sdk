//
//  MPVideoPlayerView+Testing.m
//
//  Copyright 2018-2020 Twitter, Inc.
//  Licensed under the MoPub SDK License Agreement
//  http://www.mopub.com/legal/sdk-license-agreement/
//

#import <objc/runtime.h>
#import "MPVideoPlayerView+Testing.h"

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wincomplete-implementation"
#pragma clang diagnostic ignored "-Wobjc-protocol-method-implementation"

@implementation MPVideoPlayerView (Testing)

- (void)resetCounts {
    self.playVideoCount = 0;
    self.pauseVideoCount = 0;
}

#pragma mark - Associated Data

@dynamic playVideoCount;
@dynamic pauseVideoCount;

- (void)setPlayVideoCount:(NSUInteger)playVideoCount {
    objc_setAssociatedObject(self, @selector(playVideoCount), @(playVideoCount), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (NSUInteger)playVideoCount {
    return [objc_getAssociatedObject(self, @selector(playVideoCount)) unsignedIntegerValue];
}

- (void)setPauseVideoCount:(NSUInteger)pauseVideoCount {
    objc_setAssociatedObject(self, @selector(pauseVideoCount), @(pauseVideoCount), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (NSUInteger)pauseVideoCount {
    return [objc_getAssociatedObject(self, @selector(pauseVideoCount)) unsignedIntegerValue];
}

#pragma mark - Overrides

@dynamic audioSessionInterruptionObserverToken;
@dynamic boundaryTrackingTimeObserver;
@dynamic endTimeObserverToken;
@dynamic industryIconHideTimeObserver;
@dynamic industryIconShowTimeObserver;
@dynamic progressTrackingTimeObserver;
@dynamic player;

- (void)playVideo {
    self.playVideoCount++;
}

- (void)pauseVideo {
    self.pauseVideoCount++;
}

@end

#pragma clang diagnostic pop
