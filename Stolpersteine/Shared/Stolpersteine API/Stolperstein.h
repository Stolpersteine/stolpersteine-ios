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

@class StolpersteinComponents;

typedef NS_ENUM(NSInteger, StolpersteinType) {
    StolpersteinTypeStolperstein,
    StolpersteinTypeStolperschwelle
};

@interface Stolperstein : NSObject<MKAnnotation, NSCoding, NSCopying>

@property (nonatomic, readonly, copy) NSString *ID;
@property (nonatomic, readonly) StolpersteinType type;
@property (nonatomic, readonly, copy) NSString *sourceName;
@property (nonatomic, readonly, copy) NSURL *sourceURL;
@property (nonatomic, readonly, copy) NSString *personFirstName;
@property (nonatomic, readonly, copy) NSString *personLastName;
@property (nonatomic, readonly, copy) NSURL *personBiographyURL;
@property (nonatomic, readonly, copy) NSString *locationStreet;
@property (nonatomic, readonly, copy) NSString *locationZipCode;
@property (nonatomic, readonly, copy) NSString *locationCity;
@property (nonatomic, readonly) CLLocationCoordinate2D locationCoordinate;

@property (nonatomic, readonly, copy) NSString *title;
@property (nonatomic, readonly, copy) NSString *subtitle;
@property (nonatomic, readonly) CLLocationCoordinate2D coordinate;

- (instancetype)initWithID:(NSString *)ID
                      type:(StolpersteinType)type
                sourceName:(NSString *)sourceName
                 sourceURL:(NSURL *)sourceURL
           personFirstName:(NSString *)personFirstName
            personLastName:(NSString *)personLastName
        personBiographyURL:(NSURL *)personBiographyURL
            locationStreet:(NSString *)locationStreet
           locationZipCode:(NSString *)locationZipCode
              locationCity:(NSString *)locationCity
        locationCoordinate:(CLLocationCoordinate2D)locationCoordinate;
+ (instancetype)stolpersteinWithBuilderBlock:(void(^)(StolpersteinComponents *builder))builderBlock;

- (instancetype)initWithCoder:(NSCoder *)decoder;
- (void)encodeWithCoder:(NSCoder *)coder;

- (BOOL)isEqualToStolperstein:(Stolperstein *)stolperstein;
- (BOOL)isExactMatchToStolperstein:(Stolperstein *)stolperstein;

@end

@interface StolpersteinComponents : NSObject

@property (nonatomic, copy) NSString *ID;
@property (nonatomic) StolpersteinType type;
@property (nonatomic, copy) NSString *sourceName;
@property (nonatomic, copy) NSURL *sourceURL;
@property (nonatomic, copy) NSString *personFirstName;
@property (nonatomic, copy) NSString *personLastName;
@property (nonatomic, copy) NSURL *personBiographyURL;
@property (nonatomic, copy) NSString *locationStreet;
@property (nonatomic, copy) NSString *locationZipCode;
@property (nonatomic, copy) NSString *locationCity;
@property (nonatomic) CLLocationCoordinate2D locationCoordinate;

- (Stolperstein *)stolperstein;

@end
