//
//  Stolperstein.h
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

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>

typedef enum {
    StolpersteinTypeStolperstein,
    StolpersteinTypeStolperschwelle
} StolpersteinType;

@interface Stolperstein : NSObject<MKAnnotation>

@property (nonatomic, strong) NSString *id;
@property (nonatomic, assign) StolpersteinType type;
@property (nonatomic, strong) NSString *text;
@property (nonatomic, strong) NSArray *imageURLStrings;
@property (nonatomic, strong) NSString *personFirstName;
@property (nonatomic, strong) NSString *personLastName;
@property (nonatomic, strong) NSString *personBiographyURLString;
@property (nonatomic, strong) NSString *sourceURLString;
@property (nonatomic, strong) NSString *sourceName;
@property (nonatomic, strong) NSDate *sourceRetrievedAt;
@property (nonatomic, strong) NSString *locationStreet;
@property (nonatomic, strong) NSString *locationZipCode;
@property (nonatomic, strong) NSString *locationCity;
@property (nonatomic, assign) CLLocationCoordinate2D locationCoordinate;

@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy) NSString *subtitle;
@property (nonatomic, readonly, assign) CLLocationCoordinate2D coordinate;

- (BOOL)isEqualToStolperstein:(Stolperstein *)stolperstein;

@end
