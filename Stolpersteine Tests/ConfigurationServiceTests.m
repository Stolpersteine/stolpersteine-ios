//
//  ConfigurationServiceTests.m
//  Stolpersteine
//
//  Created by Claus Höfele on 19.01.14.
//  Copyright (c) 2014 Option-U Software. All rights reserved.
//

#import "ConfigurationService.h"

#import <XCTest/XCTest.h>

@interface ConfigurationServiceTests : XCTestCase

@property (nonatomic, strong) ConfigurationService *configurationService;

@end

@implementation ConfigurationServiceTests

- (void)setUp
{
    [super setUp];
    
    NSBundle *bundle = [NSBundle bundleForClass:self.class];
    NSString *configurationsFile = [bundle pathForResource:@"ConfigurationServiceTests" ofType:@"plist"];
    self.configurationService = [[ConfigurationService alloc] initWithConfigurationsFile:configurationsFile];
}

- (void)testExists
{
    NSString *value = [self.configurationService stringConfigurationForKey:ConfigurationServiceKeyAPIPassword];
    XCTAssertEqualObjects(value, @"test");
}

- (void)testEmpty
{
    NSString *value = [self.configurationService stringConfigurationForKey:ConfigurationServiceKeyAPIUser];
    XCTAssertNil(value);
}

- (void)testMissing
{
    NSString *value = [self.configurationService stringConfigurationForKey:ConfigurationServiceKeyGoogleAnalyticsID];
    XCTAssertNil(value);
}

@end
