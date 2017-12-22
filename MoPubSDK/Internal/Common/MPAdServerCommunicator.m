//
//  MPAdServerCommunicator.m
//  MoPub
//
//  Copyright (c) 2012 MoPub, Inc. All rights reserved.
//

#import "MPAdServerCommunicator.h"

#import "MPAdConfiguration.h"
#import "MPLogging.h"
#import "MPCoreInstanceProvider.h"
#import "MPError.h"
#import "MPLogEvent.h"
#import "MPLogEventRecorder.h"

const NSTimeInterval kRequestTimeoutInterval = 10.0;

// Ad response header
static NSString * const kAdResponseTypeHeaderKey = @"X-Ad-Response-Type";
static NSString * const kAdResponseTypeMultipleResponse = @"multi";

// Multiple response JSON fields
static NSString * const kMultiAdResponsesKey = @"ad-responses";
static NSString * const kMultiAdResponsesHeadersKey = @"headers";
static NSString * const kMultiAdResponsesBodyKey = @"body";
static NSString * const kMultiAdResponsesAdMarkupKey = @"adm";

////////////////////////////////////////////////////////////////////////////////////////////////////

@interface MPAdServerCommunicator ()

@property (nonatomic, assign, readwrite) BOOL loading;
@property (nonatomic, copy) NSURL *URL;
@property (nonatomic, strong) NSURLConnection *connection;
@property (nonatomic, strong) NSMutableData *responseData;
@property (nonatomic, strong) NSDictionary *responseHeaders;
@property (nonatomic, strong) MPLogEvent *adRequestLatencyEvent;

- (NSError *)errorForStatusCode:(NSInteger)statusCode;
- (NSURLRequest *)adRequestForURL:(NSURL *)URL;

@end

////////////////////////////////////////////////////////////////////////////////////////////////////

@implementation MPAdServerCommunicator

@synthesize delegate = _delegate;
@synthesize URL = _URL;
@synthesize connection = _connection;
@synthesize responseData = _responseData;
@synthesize responseHeaders = _responseHeaders;
@synthesize loading = _loading;

- (id)initWithDelegate:(id<MPAdServerCommunicatorDelegate>)delegate
{
    self = [super init];
    if (self) {
        self.delegate = delegate;
    }
    return self;
}

- (void)dealloc
{
    [self.connection cancel];

}

#pragma mark - Public

- (void)loadURL:(NSURL *)URL
{
    [self cancel];
    self.URL = URL;

    // Start tracking how long it takes to successfully or unsuccessfully retrieve an ad.
    self.adRequestLatencyEvent = [[MPLogEvent alloc] initWithEventCategory:MPLogEventCategoryRequests eventName:MPLogEventNameAdRequest];
    self.adRequestLatencyEvent.requestURI = URL.absoluteString;

    self.connection = [NSURLConnection connectionWithRequest:[self adRequestForURL:URL]
                                                    delegate:self];
    self.loading = YES;
}

- (void)cancel
{
    self.adRequestLatencyEvent = nil;
    self.loading = NO;
    [self.connection cancel];
    self.connection = nil;
    self.responseData = nil;
    self.responseHeaders = nil;
}

#pragma mark - NSURLConnection delegate (NSURLConnectionDataDelegate in iOS 5.0+)

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
    if ([response respondsToSelector:@selector(statusCode)]) {
        NSInteger statusCode = [(NSHTTPURLResponse *)response statusCode];
        if (statusCode >= 400) {
            // Do not record a logging event if we failed to make a connection.
            self.adRequestLatencyEvent = nil;

            [connection cancel];
            self.loading = NO;
            [self.delegate communicatorDidFailWithError:[self errorForStatusCode:statusCode]];
            return;
        }
    }

    self.responseData = [NSMutableData data];
    self.responseHeaders = [(NSHTTPURLResponse *)response allHeaderFields];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    [self.responseData appendData:data];
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
    // Do not record a logging event if we failed to make a connection.
    self.adRequestLatencyEvent = nil;

    self.loading = NO;
    [self.delegate communicatorDidFailWithError:error];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    [self.adRequestLatencyEvent recordEndTime];
    self.adRequestLatencyEvent.requestStatusCode = 200;
    
    NSArray <MPAdConfiguration *> *configurations;
    // Single ad response
    if (![self.responseHeaders[kAdResponseTypeHeaderKey] isEqualToString:kAdResponseTypeMultipleResponse]) {
        MPAdConfiguration *configuration = [[MPAdConfiguration alloc] initWithHeaders:self.responseHeaders
                                                                                 data:self.responseData];
        configurations = @[configuration];
    }
    // Multiple ad responses
    else {
        // The response data is a JSON payload conforming to the structure:
        // ad-responses: [
        //   {
        //     headers: { x-adtype: html, ... },
        //     body: "<!DOCTYPE html> <html> <head> ... </html>",
        //     adm: "some ad markup"
        //   },
        //   ...
        // ]
        NSError * error = nil;
        NSDictionary * json = [NSJSONSerialization JSONObjectWithData:self.responseData options:kNilOptions error:&error];
        if (error) {
            MPLogError(@"Failed to parse multiple ad response JSON: %@", error.localizedDescription);
            self.loading = NO;
            [self.delegate communicatorDidFailWithError:error];
            return;
        }
        
        NSArray * responses = json[kMultiAdResponsesKey];
        if (responses == nil) {
            MPLogError(@"No ad responses");
            self.loading = NO;
            [self.delegate communicatorDidFailWithError:[MOPUBError errorWithCode:MOPUBErrorUnableToParseJSONAdResponse]];
            return;
        }
        
        MPLogInfo(@"There are %ld ad responses", responses.count);
        
        NSMutableArray<MPAdConfiguration *> * responseConfigurations = [NSMutableArray arrayWithCapacity:responses.count];
        for (NSDictionary * responseJson in responses) {
            NSDictionary * headers = responseJson[kMultiAdResponsesHeadersKey];
            NSData * body = [responseJson[kMultiAdResponsesBodyKey] dataUsingEncoding:NSUTF8StringEncoding];
            
            MPAdConfiguration * configuration = [[MPAdConfiguration alloc] initWithHeaders:headers data:body];
            if (configuration) {
                configuration.advancedBidPayload = responseJson[kMultiAdResponsesAdMarkupKey];
                [responseConfigurations addObject:configuration];
            }
            else {
                MPLogInfo(@"Failed to generate configuration from\nheaders:\n%@\nbody:\n%@", headers, responseJson[kMultiAdResponsesBodyKey]);
            }
        }
        
        configurations = [NSArray arrayWithArray:responseConfigurations];
    }
    
    MPAdConfigurationLogEventProperties *logEventProperties =
    [[MPAdConfigurationLogEventProperties alloc] initWithConfiguration:configurations.firstObject];
    
    // Do not record ads that are warming up.
    if (configurations.firstObject.adUnitWarmingUp) {
        self.adRequestLatencyEvent = nil;
    } else {
        [self.adRequestLatencyEvent setLogEventProperties:logEventProperties];
        MPAddLogEvent(self.adRequestLatencyEvent);
    }
    
    self.loading = NO;
    [self.delegate communicatorDidReceiveAdConfigurations:configurations];
}

#pragma mark - Internal

- (NSError *)errorForStatusCode:(NSInteger)statusCode
{
    NSString *errorMessage = [NSString stringWithFormat:
                              NSLocalizedString(@"MoPub returned status code %d.",
                                                @"Status code error"),
                              statusCode];
    NSDictionary *errorInfo = [NSDictionary dictionaryWithObject:errorMessage
                                                          forKey:NSLocalizedDescriptionKey];
    return [NSError errorWithDomain:@"mopub.com" code:statusCode userInfo:errorInfo];
}

- (NSURLRequest *)adRequestForURL:(NSURL *)URL
{
    NSMutableURLRequest *request = [[MPCoreInstanceProvider sharedProvider] buildConfiguredURLRequestWithURL:URL];
    [request setCachePolicy:NSURLRequestReloadIgnoringCacheData];
    [request setTimeoutInterval:kRequestTimeoutInterval];
    return request;
}

@end
