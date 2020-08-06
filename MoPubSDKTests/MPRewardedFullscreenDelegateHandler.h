//
//  MPRewardedFullscreenDelegateHandler.h
//  MoPubSDKTests
//
//  Created by Kelly Dun on 7/8/20.
//  Copyright © 2020 MoPub. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MPAdAdapterDelegate.h"
#import "MPReward.h"

NS_ASSUME_NONNULL_BEGIN

@interface MPRewardedFullscreenDelegateHandler : NSObject <MPAdAdapterFullscreenEventDelegate, MPAdAdapterRewardEventDelegate>
@property (nonatomic, readonly) BOOL hasImpressionFired;
@property (nonatomic, nullable, strong, readonly) MPReward *rewardGivenToUser;
@end

NS_ASSUME_NONNULL_END
