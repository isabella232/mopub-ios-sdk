//
//  MPDeviceInformationTests.m
//
//  Copyright 2018-2020 Twitter, Inc.
//  Licensed under the MoPub SDK License Agreement
//  http://www.mopub.com/legal/sdk-license-agreement/
//

#import <XCTest/XCTest.h>
#import "MPDeviceInformation+Testing.h"
#import "MPMockCarrier.h"

@interface MPDeviceInformationTests : XCTestCase

@end

@implementation MPDeviceInformationTests

- (void)testCarrierInformationCachedAtInitialize {
    // Validates that the `+initialize` method does create a cache entry
    // for carrier information. Since this is a unit test, there is no SIM
    // card and thus no carrier info to cache.
    NSUserDefaults *defaults = NSUserDefaults.standardUserDefaults;
    NSDictionary *carrierInfo = [defaults objectForKey:@"com.mopub.carrierinfo"];
    XCTAssertNotNil(carrierInfo);
}

- (void)testCarrierInfoProperties {
    // Clear out any cached information.
    NSUserDefaults *defaults = NSUserDefaults.standardUserDefaults;
    [defaults removeObjectForKey:@"com.mopub.carrierinfo"];     // Carrier information

    // Cache mock data
    MPMockCarrier *mockCarrier = MPMockCarrier.new;
    [MPDeviceInformation updateCarrierInfoCache:mockCarrier];

    // Validate carrier information exists.
    XCTAssertNotNil(MPDeviceInformation.carrierName);
    XCTAssertNotNil(MPDeviceInformation.isoCountryCode);
    XCTAssertNotNil(MPDeviceInformation.mobileCountryCode);
    XCTAssertNotNil(MPDeviceInformation.mobileNetworkCode);
}

@end
