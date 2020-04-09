//
//  MPDeviceInformation+Testing.h
//
//  Copyright 2018-2020 Twitter, Inc.
//  Licensed under the MoPub SDK License Agreement
//  http://www.mopub.com/legal/sdk-license-agreement/
//

#import <CoreTelephony/CTCarrier.h>
#import <Foundation/Foundation.h>
#import "MPDeviceInformation.h"

NS_ASSUME_NONNULL_BEGIN

@interface MPDeviceInformation (Testing)
+ (void)updateCarrierInfoCache:(CTCarrier *)carrierInfo;
@end

NS_ASSUME_NONNULL_END
