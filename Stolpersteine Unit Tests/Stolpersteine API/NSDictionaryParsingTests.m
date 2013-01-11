//
//  Stolpersteine_Unit_Tests.m
//  Stolpersteine Unit Tests
//
//  Created by Hoefele, Claus(choefele) on 11.01.13.
//  Copyright (c) 2013 Option-U Software. All rights reserved.
//

#import "NSDictionaryParsingTests.h"

#import "NSDictionary+Parsing.h"
#import "Stolperstein.h"
#import "StolpersteineNetworkService.h"

// http://www.infinite-loop.dk/blog/2011/09/using-nsurlprotocol-for-injecting-test-data/
// http://www.infinite-loop.dk/blog/2011/04/unittesting-asynchronous-network-access/
// https://gist.github.com/2254570

@interface NSDictionaryParsingTests()

@property (nonatomic, assign) BOOL done;

@end

@implementation NSDictionaryParsingTests

- (void)testNewStolperstein
{
    NSString *stolpersteinAsJSON =
        @"{"                                                    \
        @"    \"createdAt\": \"2012-12-23T22:57:07.519Z\","     \
        @"    \"updatedAt\": \"2012-12-23T22:57:07.519Z\","     \
        @"    \"description\": \"Beschreibung\","               \
        @"    \"_id\": \"50d78c43f737060b54000002\","           \
        @"    \"sources\": [],"                                 \
        @"    \"laidAt\": {"                                    \
        @"        \"year\": 2012,"                              \
        @"        \"month\": 11,"                               \
        @"        \"date\": 12"                                 \
        @"    },"                                               \
        @"    \"location\": {"                                  \
        @"        \"street\": \"Straße 1\","                    \
        @"        \"zipCode\": \"10000\","                      \
        @"        \"city\": \"Stadt\","                         \
        @"        \"coordinates\": {"                           \
        @"            \"longitude\": 1,"                        \
        @"            \"latitude\": 1"                          \
        @"        }"                                            \
        @"    },"                                               \
        @"    \"person\": {"                                    \
        @"        \"name\": \"Vorname Nachname\""               \
        @"    }"                                                \
        @"}";

    NSData *stolpersteinAsData = [stolpersteinAsJSON dataUsingEncoding:NSUTF8StringEncoding];
    NSDictionary *stolpersteinAsDictionary = [NSJSONSerialization JSONObjectWithData:stolpersteinAsData options:0 error:NULL];
    Stolperstein *stolperstein = [stolpersteinAsDictionary newStolperstein];
    STAssertEqualObjects(stolperstein.id, @"50d78c43f737060b54000002", @"Wrong id");
}

- (BOOL)waitForCompletion:(NSTimeInterval)timeoutSecs
{
    NSDate *timeoutDate = [NSDate dateWithTimeIntervalSinceNow:timeoutSecs];
    
    do {
        [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:timeoutDate];
        if([timeoutDate timeIntervalSinceNow] < 0.0) {
            break;
        }
    } while (!self.done);
    
    return self.done;
}

- (void)testRetrieveStolpersteine
{
    static NSString * const BASE_URL = @"https://stolpersteine-optionu.rhcloud.com/api/";
    self.done = FALSE;

    StolpersteineNetworkService *networkService = [[StolpersteineNetworkService alloc] initWithURL:[NSURL URLWithString:BASE_URL] clientUser:nil clientPassword:nil];
    [networkService retrieveStolpersteineWithSearchData:nil page:0 pageSize:0 completionHandler:^(NSArray *stolpersteine, NSUInteger totalNumberOfItems, NSError *error) {
        self.done = TRUE;
        
        STAssertTrue(stolpersteine.count > 0, @"Wrong number of stolpersteine");
    }];
    STAssertTrue([self waitForCompletion:5.0], @"Time out");
}

@end
