//
//  MPAdvancedBiddingManager.m
//  MoPubSDK
//
//  Copyright © 2017 MoPub. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MPAdvancedBiddingManager.h"
#import "MPLogging.h"

// JSON constants
static NSString const * kTokenKey = @"token";

@interface MPAdvancedBiddingManager()
@property (nonatomic, strong, readwrite) NSDictionary * bidderTokens;
@end

@implementation MPAdvancedBiddingManager

+ (MPAdvancedBiddingManager *)sharedManager {
    static MPAdvancedBiddingManager * sharedMyManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedMyManager = [[self alloc] init];
    });
    return sharedMyManager;
}

- (instancetype)init {
    if (self = [super init]) {
        _advancedBiddingEnabled = YES;
        _bidderTokens = nil;
    }
    
    return self;
}

- (void)setBidderTokensWithBidders:(NSArray<Class<MPAdvancedBidder>> *)bidders {
    // No bidders; nothing to do.
    if (bidders.count == 0) {
        return;
    }
    
    NSMutableDictionary * bidderTokens = [NSMutableDictionary dictionaryWithCapacity:bidders.count];
    for (Class<MPAdvancedBidder> advancedBidderClass in bidders) {
        id<MPAdvancedBidder> advancedBidder = (id<MPAdvancedBidder>)[[[advancedBidderClass class] alloc] init];
        
        NSString * network = advancedBidder.creativeNetworkName;
        bidderTokens[network] = @{ kTokenKey: advancedBidder.token };
    }
    
    self.bidderTokens = bidderTokens;
}

- (NSString *)bidderTokensJson {
    // No tokens to serialize.
    if (self.bidderTokens == nil) {
        return nil;
    }
    
    NSError * error = nil;
    NSData * jsonData = [NSJSONSerialization dataWithJSONObject:self.bidderTokens options:0 error:&error];
    if (jsonData == nil) {
        MPLogError(@"Failed to generate a JSON string from\n%@\nReason: %@", self.bidderTokens, error.localizedDescription);
        return nil;
    }
    
    return [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
}

@end
