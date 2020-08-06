//
//  MPFullscreenAdViewControllerDelegateMock.m
//
//  Copyright 2018-2020 Twitter, Inc.
//  Licensed under the MoPub SDK License Agreement
//  http://www.mopub.com/legal/sdk-license-agreement/
//

#import "MPFullscreenAdViewControllerDelegateMock.h"

@implementation MPFullscreenAdViewControllerDelegateMock
@end


#pragma mark -

@implementation MPFullscreenAdViewControllerDelegateMock (Appearance)

- (void)fullscreenAdDidAppear:(id<MPFullscreenAdViewController>)fullscreenAdViewController {
    // no op
}

- (void)fullscreenAdWillAppear:(id<MPFullscreenAdViewController>)fullscreenAdViewController {
    // no op
}

- (void)fullscreenAdWillDisappear:(id<MPFullscreenAdViewController>)fullscreenAdViewController {
    // no op
}

- (void)fullscreenAdDidDisappear:(id<MPFullscreenAdViewController>)fullscreenAdViewController {
    // no op
}

- (void)fullscreenAdWillDismiss:(id<MPFullscreenAdViewController>)fullscreenAdViewController {
    // no op
}

- (void)fullscreenAdDidDismiss:(id<MPFullscreenAdViewController>)fullscreenAdViewController {
    // no op
}

@end

#pragma mark -

@implementation MPFullscreenAdViewControllerDelegateMock (WebAd)

- (void)fullscreenWebAdDidFailToLoad:(id<MPFullscreenAdViewController>)fullscreenAdViewController {
    // no op
}

- (void)fullscreenWebAdDidLoad:(id<MPFullscreenAdViewController>)fullscreenAdViewController {
    // no op
}

- (void)fullscreenWebAdDidReceiveTap:(id<MPFullscreenAdViewController>)fullscreenAdViewController {
    // no op
}

- (void)fullscreenWebAdWillLeaveApplication:(id<MPFullscreenAdViewController>)fullscreenAdViewController {
    // no op
}

- (void)fullscreenWebAdDidFulfillRewardRequirement:(id<MPFullscreenAdViewController>)fullscreenAdViewController {
    // no op
}

@end
