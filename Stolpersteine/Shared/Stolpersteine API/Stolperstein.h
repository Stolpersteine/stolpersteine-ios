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

- (id)initWithID:(NSString *)ID
            type:(StolpersteinType)type
 sourceURLString:(NSString *)sourceURLString
      sourceName:(NSString *)sourceName
 personFirstName:(NSString *)personFirstName
  personLastName:(NSString *)personLastName
personBiographyURLString:(NSString *)personBiographyURLString
  locationStreet:(NSString *)locationStreet
 locationZipCode:(NSString *)locationZipCode
    locationCity:(NSString *)locationCity
locationCoordinate:(CLLocationCoordinate2D)locationCoordinate;

@property (nonatomic, readonly, copy) NSString *ID;
@property (nonatomic, readonly) StolpersteinType type;
@property (nonatomic, readonly, copy) NSString *sourceURLString;
@property (nonatomic, readonly, copy) NSString *sourceName;
@property (nonatomic, readonly, copy) NSString *personFirstName;
@property (nonatomic, readonly, copy) NSString *personLastName;
@property (nonatomic, readonly, copy) NSString *personBiographyURLString;
@property (nonatomic, readonly, copy) NSString *locationStreet;
@property (nonatomic, readonly, copy) NSString *locationZipCode;
@property (nonatomic, readonly, copy) NSString *locationCity;
@property (nonatomic, readonly) CLLocationCoordinate2D locationCoordinate;

@property (nonatomic, readonly, copy) NSString *title;
@property (nonatomic, readonly, copy) NSString *subtitle;
@property (nonatomic, readonly, assign) CLLocationCoordinate2D coordinate;

- (BOOL)isEqualToStolperstein:(Stolperstein *)stolperstein;

@end
