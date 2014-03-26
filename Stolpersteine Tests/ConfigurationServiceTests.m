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
@property (nonatomic, strong) ConfigurationService *configurationServiceEmpty;

@end

@implementation ConfigurationServiceTests

- (void)setUp
{
    [super setUp];
    
    NSBundle *bundle = [NSBundle bundleForClass:self.class];
    NSString *configurationsFile = [bundle pathForResource:@"ConfigurationServiceTests" ofType:@"plist"];
    self.configurationService = [[ConfigurationService alloc] initWithConfigurationsFile:configurationsFile];
    NSString *configurationsFileEmpty = [bundle pathForResource:@"ConfigurationServiceTestsEmpty" ofType:@"plist"];
    self.configurationServiceEmpty = [[ConfigurationService alloc] initWithConfigurationsFile:configurationsFileEmpty];
}

- (void)testStringExists
{
    NSString *value = [self.configurationService stringConfigurationForKey:ConfigurationServiceKeyAPIPassword];
    XCTAssertEqualObjects(value, @"test");
}

- (void)testStringExistsEmpty
{
    NSString *value = [self.configurationService stringConfigurationForKey:ConfigurationServiceKeyAPIUser];
    XCTAssertNil(value);
}

- (void)testStringMissing
{
    NSString *value = [self.configurationServiceEmpty stringConfigurationForKey:ConfigurationServiceKeyAPIPassword];
    XCTAssertNil(value);
}

- (void)testCoordinateRegionExists
{
    MKCoordinateRegion value = [self.configurationService coordinateRegionConfigurationForKey:ConfigurationServiceKeyVisibleRegion];
    XCTAssertEqual(value.center.latitude, 1);
    XCTAssertEqual(value.center.longitude, 2);
    XCTAssertEqual(value.span.latitudeDelta, 3);
    XCTAssertEqual(value.span.longitudeDelta, 4);
}

- (void)testCoordinateRegionMissing
{
    MKCoordinateRegion value = [self.configurationServiceEmpty coordinateRegionConfigurationForKey:ConfigurationServiceKeyVisibleRegion];
    XCTAssertEqual(value.center.latitude, 0);
    XCTAssertEqual(value.center.longitude, 0);
    XCTAssertEqual(value.span.latitudeDelta, 0);
    XCTAssertEqual(value.span.longitudeDelta, 0);
}

@end
