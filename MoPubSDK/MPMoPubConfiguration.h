//
//  MPMoPubConfiguration.h
//  MoPubSDK
//
//  Copyright © 2017 MoPub. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MPAdvancedBidder.h"

/**
 * SDK configuration options
 */
@interface MPMoPubConfiguration : NSObject
/**
 * List of advanced bidders to initialize.
 */
@property (nonatomic, strong) NSArray<Class<MPAdvancedBidder>> * advancedBidders;

@end
