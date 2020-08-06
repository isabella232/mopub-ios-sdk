//
//  MPVASTModelTests.m
//
//  Copyright 2018-2020 Twitter, Inc.
//  Licensed under the MoPub SDK License Agreement
//  http://www.mopub.com/legal/sdk-license-agreement/
//

#import <XCTest/XCTest.h>
#import "MPVASTModel.h"

@interface MPVASTModelTests : XCTestCase

@end

@implementation MPVASTModelTests

#pragma mark - MPNSStringToNSURLMapper

- (void)testStringToURLMapperSuccess {
    MPNSStringToNSURLMapper * mapper = [[MPNSStringToNSURLMapper alloc] init];
    id mappedValue = [mapper mappedObjectFromSourceObject:@"https://google.com"];

    XCTAssertNotNil(mappedValue);
    XCTAssert([mappedValue isKindOfClass:[NSURL class]]);
}

- (void)testStringToURLMapperBadURL {
    MPNSStringToNSURLMapper * mapper = [[MPNSStringToNSURLMapper alloc] init];
    id mappedValue = [mapper mappedObjectFromSourceObject:@"i-am a garbage URL"];

    XCTAssertNil(mappedValue);
}

- (void)testStringToURLMapperEmptyURL {
    MPNSStringToNSURLMapper * mapper = [[MPNSStringToNSURLMapper alloc] init];
    id mappedValue = [mapper mappedObjectFromSourceObject:@""];

    XCTAssertNil(mappedValue);
}

- (void)testStringToURLMapperWrongType {
    MPNSStringToNSURLMapper * mapper = [[MPNSStringToNSURLMapper alloc] init];
    id mappedValue = [mapper mappedObjectFromSourceObject:[NSNull null]];

    XCTAssertNil(mappedValue);
}

// MPX auction macros that haven't been processed, but make it through to the SDK
// should fail to parse since this is a bug.
- (void)testStringToURLMapperMarketplaceAuctionMacro {
    MPNSStringToNSURLMapper * mapper = [[MPNSStringToNSURLMapper alloc] init];
    id mappedValue = [mapper mappedObjectFromSourceObject:@"https://mpx.mopub.com?a=${AUCTION_PRICE}"];

    XCTAssertNil(mappedValue);
}

#pragma mark - MPDurationStringToTimeIntervalMapper

- (void)testDurationStringToTimeIntervalMapperSuccess {
    MPDurationStringToTimeIntervalMapper * mapper = [[MPDurationStringToTimeIntervalMapper alloc] init];
    id mappedValue = [mapper mappedObjectFromSourceObject:@"13.3"];

    XCTAssertNotNil(mappedValue);
    XCTAssert([mappedValue isKindOfClass:[NSNumber class]]);
    XCTAssert([mappedValue doubleValue] == 13.3);
}

- (void)testDurationStringToTimeIntervalMapperHHMMSSSuccess {
    MPDurationStringToTimeIntervalMapper * mapper = [[MPDurationStringToTimeIntervalMapper alloc] init];
    id mappedValue = [mapper mappedObjectFromSourceObject:@"01:07:30"]; // 1 hour 7 min 30 seconds

    XCTAssertNotNil(mappedValue);
    XCTAssert([mappedValue isKindOfClass:[NSNumber class]]);
    XCTAssert([mappedValue doubleValue] == 4050); // 3600s + 420s + 30s = 4050s
}

- (void)testDurationStringToTimeIntervalMapperHHMMSSmmmSuccess {
    MPDurationStringToTimeIntervalMapper * mapper = [[MPDurationStringToTimeIntervalMapper alloc] init];
    id mappedValue = [mapper mappedObjectFromSourceObject:@"01:07:30.073"]; // 1 hour 7 min 30 seconds 73 milliseconds

    XCTAssertNotNil(mappedValue);
    XCTAssert([mappedValue isKindOfClass:[NSNumber class]]);
    XCTAssert([mappedValue doubleValue] == 4050.073); // 3600s + 420s + 30s = 4050.073s
}

- (void)testDurationStringToTimeIntervalMapperEmptyDuration {
    MPDurationStringToTimeIntervalMapper * mapper = [[MPDurationStringToTimeIntervalMapper alloc] init];
    id mappedValue = [mapper mappedObjectFromSourceObject:@""];

    XCTAssertNil(mappedValue);
}

- (void)testDurationStringToTimeIntervalMapperNotReallyDuration {
    MPDurationStringToTimeIntervalMapper * mapper = [[MPDurationStringToTimeIntervalMapper alloc] init];
    id mappedValue = [mapper mappedObjectFromSourceObject:@"i-am a bad duration"];

    XCTAssertNil(mappedValue);
}

- (void)testDurationStringToTimeIntervalMapperZeroDuration {
    MPDurationStringToTimeIntervalMapper * mapper = [[MPDurationStringToTimeIntervalMapper alloc] init];
    id mappedValue = [mapper mappedObjectFromSourceObject:@"0"];

    XCTAssertNil(mappedValue);
}

- (void)testDurationStringToTimeIntervalMapperNegativeDuration {
    MPDurationStringToTimeIntervalMapper * mapper = [[MPDurationStringToTimeIntervalMapper alloc] init];
    id mappedValue = [mapper mappedObjectFromSourceObject:@"-1"];

    XCTAssertNil(mappedValue);
}

- (void)testDurationStringToTimeIntervalMapperWrongType {
    MPDurationStringToTimeIntervalMapper * mapper = [[MPDurationStringToTimeIntervalMapper alloc] init];
    id mappedValue = [mapper mappedObjectFromSourceObject:[NSNull null]];

    XCTAssertNil(mappedValue);
}

#pragma mark - MPStringToNumberMapper

- (void)testStringToNumberMapperSuccess {
    MPStringToNumberMapper * mapper = [[MPStringToNumberMapper alloc] initWithNumberStyle:NSNumberFormatterDecimalStyle];
    id mappedValue = [mapper mappedObjectFromSourceObject:@"123"];

    XCTAssertNotNil(mappedValue);
    XCTAssert([mappedValue isKindOfClass:[NSNumber class]]);
    XCTAssert([mappedValue integerValue] == 123);
}

- (void)testStringToNumberMapperEmptyNumber {
    MPStringToNumberMapper * mapper = [[MPStringToNumberMapper alloc] initWithNumberStyle:NSNumberFormatterDecimalStyle];
    id mappedValue = [mapper mappedObjectFromSourceObject:@""];

    XCTAssertNil(mappedValue);
}

- (void)testStringToNumberMapperDefinitelyNotNumber {
    MPStringToNumberMapper * mapper = [[MPStringToNumberMapper alloc] initWithNumberStyle:NSNumberFormatterDecimalStyle];
    id mappedValue = [mapper mappedObjectFromSourceObject:@"lhsdfghlgs"];

    XCTAssertNil(mappedValue);
}

- (void)testStringToNumberMapperWrongType {
    MPStringToNumberMapper * mapper = [[MPStringToNumberMapper alloc] initWithNumberStyle:NSNumberFormatterDecimalStyle];
    id mappedValue = [mapper mappedObjectFromSourceObject:[NSNull null]];

    XCTAssertNil(mappedValue);
}

#pragma mark - MPClassMapper

- (void)testClassMapperSuccess {
    MPClassMapper * mapper = [[MPClassMapper alloc] initWithDestinationClass:[MPVASTModel class]];
    id mappedValue = [mapper mappedObjectFromSourceObject:[NSDictionary dictionary]];

    XCTAssertNotNil(mappedValue);
    XCTAssert([mappedValue isKindOfClass:[MPVASTModel class]]);
}

- (void)testClassMapperDestinationNotMPVASTModel {
    MPClassMapper * mapper = [[MPClassMapper alloc] initWithDestinationClass:[NSObject class]];
    id mappedValue = [mapper mappedObjectFromSourceObject:[NSDictionary dictionary]];

    XCTAssertNil(mappedValue);
}

- (void)testClassMapperWrongType {
    MPClassMapper * mapper = [[MPClassMapper alloc] initWithDestinationClass:[MPVASTModel class]];
    id mappedValue = [mapper mappedObjectFromSourceObject:[NSNull null]];

    XCTAssertNil(mappedValue);
}

#pragma mark - MPNSArrayMapper

- (void)testArrayMapperOneObjectSuccess {
    MPNSStringToNSURLMapper * stringToURLMapper = [[MPNSStringToNSURLMapper alloc] init];
    MPNSArrayMapper * arrayMapper = [[MPNSArrayMapper alloc] initWithInternalMapper:stringToURLMapper];
    id mappedValue = [arrayMapper mappedObjectFromSourceObject:@"https://google.com"];

    XCTAssertNotNil(mappedValue);
    XCTAssert([mappedValue isKindOfClass:[NSArray class]]);
    XCTAssert([mappedValue count] == 1);
    XCTAssert([((NSURL *)mappedValue[0]) isEqual:[NSURL URLWithString:@"https://google.com"]]);
}

- (void)testArrayMapperMultiObjectSuccess {
    MPNSStringToNSURLMapper * stringToURLMapper = [[MPNSStringToNSURLMapper alloc] init];
    MPNSArrayMapper * arrayMapper = [[MPNSArrayMapper alloc] initWithInternalMapper:stringToURLMapper];
    id mappedValue = [arrayMapper mappedObjectFromSourceObject:@[@"https://google.com", @"https://mopub.com"]];

    XCTAssertNotNil(mappedValue);
    XCTAssert([mappedValue isKindOfClass:[NSArray class]]);
    XCTAssert([mappedValue count] == 2);
    XCTAssert([((NSURL *)mappedValue[0]) isEqual:[NSURL URLWithString:@"https://google.com"]]);
    XCTAssert([((NSURL *)mappedValue[1]) isEqual:[NSURL URLWithString:@"https://mopub.com"]]);
}

- (void)testArrayMapperOneObjectFailure {
    MPNSStringToNSURLMapper * stringToURLMapper = [[MPNSStringToNSURLMapper alloc] init];
    MPNSArrayMapper * arrayMapper = [[MPNSArrayMapper alloc] initWithInternalMapper:stringToURLMapper];
    id mappedValue = [arrayMapper mappedObjectFromSourceObject:[NSNull null]];

    XCTAssertNil(mappedValue);
}

- (void)testArrayMapperMultiObjectHalfFailure {
    MPNSStringToNSURLMapper * stringToURLMapper = [[MPNSStringToNSURLMapper alloc] init];
    MPNSArrayMapper * arrayMapper = [[MPNSArrayMapper alloc] initWithInternalMapper:stringToURLMapper];
    id mappedValue = [arrayMapper mappedObjectFromSourceObject:@[@"https://google.com", [NSNull null]]]; // included two objects, but expect one

    XCTAssertNotNil(mappedValue);
    XCTAssert([mappedValue isKindOfClass:[NSArray class]]);
    XCTAssert([mappedValue count] == 1);
    XCTAssert([((NSURL *)mappedValue[0]) isEqual:[NSURL URLWithString:@"https://google.com"]]);
}

- (void)testArrayMapperMultiObjectFullFailure {
    MPNSStringToNSURLMapper * stringToURLMapper = [[MPNSStringToNSURLMapper alloc] init];
    MPNSArrayMapper * arrayMapper = [[MPNSArrayMapper alloc] initWithInternalMapper:stringToURLMapper];
    id mappedValue = [arrayMapper mappedObjectFromSourceObject:@[[NSNull null], [NSNull null]]];

    XCTAssertNil(mappedValue);
}

- (void)testArrayMapperEmptyArray {
    MPNSStringToNSURLMapper * stringToURLMapper = [[MPNSStringToNSURLMapper alloc] init];
    MPNSArrayMapper * arrayMapper = [[MPNSArrayMapper alloc] initWithInternalMapper:stringToURLMapper];
    id mappedValue = [arrayMapper mappedObjectFromSourceObject:@[]];

    XCTAssertNil(mappedValue);
}

#pragma mark - MPVASTModel

- (void)testModelMap {
    XCTAssertNotNil([MPVASTModel modelMap]);
}

- (void)testModelNoDictionary {
    MPVASTModel *model = [[MPVASTModel alloc] initWithDictionary:nil];
    XCTAssertNil(model);
}

- (void)testModelEmptyDictionary {
    MPVASTModel *model = [[MPVASTModel alloc] initWithDictionary:@{}];
    XCTAssertNotNil(model);
}

@end
