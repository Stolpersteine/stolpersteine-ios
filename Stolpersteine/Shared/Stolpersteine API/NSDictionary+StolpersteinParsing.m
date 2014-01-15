//
//  NSDictionary+Parsing.m
//  Stolpersteine
//
//  Copyright (C) 2013 Option-U Software
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

#import "NSDictionary+StolpersteinParsing.h"

#import "Stolperstein.h"

@implementation NSDictionary (Parsing)

- (Stolperstein *)newStolperstein
{
    NSString *typeAsString = [self valueForKeyPath:@"type"];
    StolpersteinType type;
    if ([typeAsString isEqualToString:@"stolperschwelle"]) {
        type = StolpersteinTypeStolperschwelle;
    } else {
        type = StolpersteinTypeStolperstein;
    }

    NSString *latitudeAsString = [self valueForKeyPath:@"location.coordinates.latitude"];
    NSString *longitudeAsString = [self valueForKeyPath:@"location.coordinates.longitude"];
    CLLocationCoordinate2D locationCoordinate = CLLocationCoordinate2DMake(latitudeAsString.doubleValue, longitudeAsString.doubleValue);

    Stolperstein *stolperstein = [[Stolperstein alloc] initWithID:[self valueForKeyPath:@"id"]
                                                             type:type
                                                  sourceURLString:[self valueForKeyPath:@"source.url"]
                                                       sourceName:[self valueForKeyPath:@"source.name"]
                                                  personFirstName:[self valueForKeyPath:@"person.firstName"]
                                                   personLastName:[self valueForKeyPath:@"person.lastName"]
                                         personBiographyURLString:[self valueForKeyPath:@"person.biographyUrl"]
                                                   locationStreet:[self valueForKeyPath:@"location.street"]
                                                  locationZipCode:[self valueForKeyPath:@"location.zipCode"]
                                                     locationCity:[self valueForKeyPath:@"location.city"]
                                               locationCoordinate:locationCoordinate];
   
    return stolperstein;
}

@end
