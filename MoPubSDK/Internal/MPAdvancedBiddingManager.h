//
//  MPAdvancedBiddingManager.h
//  MoPubSDK
//
//  Copyright © 2017 MoPub. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MPAdvancedBidder.h"

/**
 * Internally manages all aspects related to advanced bidding.
 */
@interface MPAdvancedBiddingManager : NSObject
/**
 * A boolean value indicating whether advanced bidding is enabled. This boolean defaults to `YES`.
 * To disable advanced bidding, set this value to `NO`.
 */
@property (nonatomic, assign) BOOL advancedBiddingEnabled;

/**
 * A JSON-serializable dictionary of bidder tokens to be sent on every ad request when
 * `advancedBiddingEnabled` is set to `YES`.
 */
@property (nonatomic, strong, readonly) NSDictionary * _Nullable bidderTokens;

/**
 * A JSON string representation of `bidderTokens`.
 */
@property (nonatomic, copy, readonly) NSString * _Nullable bidderTokensJson;

/**
 * Singleton instance of the manager.
 */
+ (MPAdvancedBiddingManager * _Nonnull)sharedManager;

/**
 * Generates the bidder tokens from a given set of bidders.
 * @param bidders Array of bidders
 */
- (void)setBidderTokensWithBidders:(NSArray<Class<MPAdvancedBidder>> * _Nonnull)bidders;

@end
