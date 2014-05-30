//
//  Localization.m
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

#import "Localization.h"

#import "Stolperstein.h"
#import "CCHMapClusterAnnotation.h"

@implementation Localization

+ (NSString *)newNameFromStolperstein:(Stolperstein *)stolperstein
{
    NSMutableString *name = [NSMutableString stringWithCapacity:stolperstein.personFirstName.length + stolperstein.personLastName.length + 1];
    if (stolperstein.personFirstName.length > 0) {
        [name appendString:stolperstein.personFirstName];
    }
    
    if (stolperstein.personLastName.length > 0) {
        if (name.length > 0) {
            [name appendString:@" "];
        }
        [name appendString:stolperstein.personLastName];
    }
    
    if (stolperstein.type == StolpersteinTypeStolperschwelle) {
        if (name.length > 0) {
            [name appendString:@" "];
        }
        [name appendString:@"(Stolperschwelle)"];
    }
    
    return name;
}

+ (NSString *)newShortNameFromStolperstein:(Stolperstein *)stolperstein
{
    NSMutableString *shortName = [NSMutableString stringWithCapacity:stolperstein.personLastName.length + 3];
    BOOL hasFirstLetter = (stolperstein.personFirstName.length > 0);
    if (hasFirstLetter) {
        [shortName appendFormat:@"%@.", [stolperstein.personFirstName substringToIndex:1]];
    }
    
    if (stolperstein.personLastName.length > 0) {
        if (shortName.length > 0) {
            [shortName appendString:@" "];
        }
        
        [shortName appendString:stolperstein.personLastName];
    }
    
    return shortName;
}

+ (NSString *)newStreetNameFromStolperstein:(Stolperstein *)stolperstein
{
    NSRange range = [stolperstein.locationStreet rangeOfCharacterFromSet:NSCharacterSet.decimalDigitCharacterSet];
    NSString *locationStreetName = stolperstein.locationStreet;
    if (range.location != NSNotFound) {
        locationStreetName = [locationStreetName substringToIndex:range.location];
        locationStreetName = [locationStreetName stringByTrimmingCharactersInSet:NSCharacterSet.whitespaceCharacterSet];
    }
    return locationStreetName;
}

+ (NSString *)newShortAddressFromStolperstein:(Stolperstein *)stolperstein
{
    NSMutableString *address = [NSMutableString stringWithString:stolperstein.locationStreet];
    if (stolperstein.locationZipCode || stolperstein.locationCity) {
        [address appendString:@","];
        
        if (stolperstein.locationZipCode) {
            [address appendFormat:@" %@", stolperstein.locationZipCode];
        }
        if (stolperstein.locationCity) {
            [address appendFormat:@" %@", stolperstein.locationCity];
        }
    }
    
    return address;
}

+ (NSString *)newLongAddressFromStolperstein:(Stolperstein *)stolperstein
{
    NSMutableString *address = [NSMutableString stringWithCapacity:20];
    
    if (stolperstein.locationStreet) {
        [address appendString:stolperstein.locationStreet];
    }
    
    if (stolperstein.locationZipCode) {
        [address appendString:@"\n"];
        [address appendFormat:@"%@", stolperstein.locationZipCode];
    }
    
    if (stolperstein.locationCity) {
        if (stolperstein.locationStreet && !stolperstein.locationZipCode) {
            [address appendString:@"\n"];
        }
        
        if (stolperstein.locationZipCode) {
            [address appendString:@" "];
        }
        
        if (stolperstein.locationCity) {
            [address appendString:stolperstein.locationCity];
        }
    }
    return address;
}

+ (NSString *)newPasteboardStringFromStolperstein:(Stolperstein *)stolperstein
{
    NSString *name = [Localization newNameFromStolperstein:stolperstein];
    NSString *address = [Localization newShortAddressFromStolperstein:stolperstein];
    NSMutableString *string = [NSMutableString stringWithFormat:@"%@\n%@", name, address];
    NSString *localizedPersonBiographyURLString = [[self.class newPersonBiographyURLFromStolperstein:stolperstein] absoluteString];
    if (localizedPersonBiographyURLString) {
        [string appendString:@"\n"];
        [string appendString:localizedPersonBiographyURLString];
    }
    
    return string;
}

+ (NSURL *)newPersonBiographyURLFromStolperstein:(Stolperstein *)stolperstein
{
    NSString *personBiographyURLString = stolperstein.personBiographyURL.absoluteString;
    
    // Use English website for Berlin biographies if not using German
    NSArray *preferredLanguages = NSLocale.preferredLanguages;
    if (preferredLanguages.count > 0 && ![preferredLanguages[0] hasPrefix:@"de"]) {
        static NSString *prefixGerman = @"http://www.stolpersteine-berlin.de/de";
        static NSString *prefixEnglish = @"http://www.stolpersteine-berlin.de/en";
        if ([personBiographyURLString hasPrefix:prefixGerman]) {
            NSRange range = NSMakeRange(0, prefixGerman.length);
            personBiographyURLString = [personBiographyURLString stringByReplacingCharactersInRange:range withString:prefixEnglish];
        }
    }
    
    return [NSURL URLWithString:personBiographyURLString];
}

+ (NSString *)newTitleFromMapClusterAnnotation:(CCHMapClusterAnnotation *)mapClusterAnnotation
{
    NSString *title;
    if (mapClusterAnnotation.isCluster) {
        NSUInteger numStolpersteine = MIN(mapClusterAnnotation.annotations.count, 5);
        NSArray *stolpersteine = [mapClusterAnnotation.annotations.allObjects subarrayWithRange:NSMakeRange(0, numStolpersteine)];
        NSMutableArray *names = [NSMutableArray arrayWithCapacity:numStolpersteine];
        for (Stolperstein *stolperstein in stolpersteine) {
            [names addObject:[Localization newNameFromStolperstein:stolperstein]];
        }
        title = [names componentsJoinedByString:@", "];
    } else {
        Stolperstein *stolperstein = [mapClusterAnnotation.annotations anyObject];
        title = [Localization newNameFromStolperstein:stolperstein];
    }
    
    return title;
}

+ (NSString *)newSubtitleFromMapClusterAnnotation:(CCHMapClusterAnnotation *)mapClusterAnnotation
{
    NSString *subtitle;
    if (mapClusterAnnotation.isUniqueLocation) {
        Stolperstein *stolperstein = [mapClusterAnnotation.annotations anyObject];
        subtitle = [Localization newShortAddressFromStolperstein:stolperstein];
    } else {
        subtitle = [Localization newStolpersteineCountFromCount:mapClusterAnnotation.annotations.count];
    }
    
    return subtitle;
}

+ (NSString *)newStolpersteineCountFromCount:(NSUInteger)count
{
    NSString *localizedKey = count > 1 ? @"Misc.stolpersteine" : @"Misc.stolperstein";
    NSString *localizedName = NSLocalizedString(localizedKey, nil);
    return [NSString stringWithFormat:@"%tu %@", count, localizedName];
}

@end
