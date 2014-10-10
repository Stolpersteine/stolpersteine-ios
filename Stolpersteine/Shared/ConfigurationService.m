//
//  ConfigurationService.m
//  Stolpersteine
//
//  Copyright (C) 2014 Option-U Software
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.
//

#import "ConfigurationService.h"

@interface ConfigurationService()

@property (nonatomic, copy) NSDictionary *configurations;
@property (nonatomic, copy) NSDictionary *enumToStringMapping;

@end

@implementation ConfigurationService

- (instancetype)initWithConfigurationsFile:(NSString *)file
{
    self = [super init];
    if (self) {
        _configurations = [NSDictionary dictionaryWithContentsOfFile:file];
        _enumToStringMapping = @{
             @(ConfigurationServiceKeyAPIUser) : @"API client user",
             @(ConfigurationServiceKeyAPIPassword) : @"API client password",
             @(ConfigurationServiceKeyGoogleAnalyticsID) : @"Google Analytics ID",
             @(ConfigurationServiceKeyVisibleRegion) : @"Visible region",
             @(ConfigurationServiceKeyFilterCity) : @"Filter city"
        };
    }
    
    return self;
}

+ (NSString *)appVersion
{
    NSString *version = [[NSBundle.mainBundle infoDictionary] objectForKey:@"CFBundleVersion"];
    return version;
}

+ (NSString *)appShortVersion
{
    NSString *shortVersion = [[NSBundle.mainBundle infoDictionary] objectForKey:@"CFBundleShortVersionString"];
    return shortVersion;
}

- (NSString *)stringConfigurationForKey:(ConfigurationServiceKey)key
{
    NSString *keyAsString = [self.enumToStringMapping objectForKey:@(key)];
    NSAssert(keyAsString != nil, @"Unknown key for configuration: %tu", key);
    NSString *string = [self.configurations objectForKey:keyAsString];
    string = string.length > 0 ? string : nil;
    
    return string;
}

- (MKCoordinateRegion)coordinateRegionConfigurationForKey:(ConfigurationServiceKey)key
{
    NSString *keyAsString = [self.enumToStringMapping objectForKey:@(key)];
    NSAssert(keyAsString != nil, @"Unknown key for configuration: %tu", key);
    NSDictionary *coordinateRegionAsDictionary = [self.configurations objectForKey:keyAsString];
    MKCoordinateRegion coordinateRegion = MKCoordinateRegionMake(CLLocationCoordinate2DMake(0, 0), MKCoordinateSpanMake(0, 0));
    coordinateRegion.center.latitude = [[coordinateRegionAsDictionary objectForKey:@"center.latitude"] doubleValue];
    coordinateRegion.center.longitude = [[coordinateRegionAsDictionary objectForKey:@"center.longitude"] doubleValue];
    coordinateRegion.span.latitudeDelta = [[coordinateRegionAsDictionary objectForKey:@"span.latitudeDelta"] doubleValue];
    coordinateRegion.span.longitudeDelta = [[coordinateRegionAsDictionary objectForKey:@"span.longitudeDelta"] doubleValue];

    return coordinateRegion;
}

@end
