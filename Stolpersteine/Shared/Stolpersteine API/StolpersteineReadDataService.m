//
//  StolpersteineDataService.m
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

#import "StolpersteineReadDataService.h"

#import "YapDatabase.h"
#import "YapDatabaseFullTextSearch.h"
#import "YapDatabaseView.h"

#import "Stolperstein.h"
#import "StolpersteineSearchData.h"

NSString * const StolpersteineReadDataServiceCollection = @"stolpersteine";
static NSString * const StolpersteineReadDataServiceFullTextSearchExtensionName = @"fullTextSearch";
static NSString * const StolpersteineReadDataServiceAllItemsViewExtensionName = @"allItems";
static int FullTextSearchExtensionVersion = 1;
static NSString * const AllItemsViewExtensionVersion = @"1";

@interface StolpersteineReadDataService()

@property (nonatomic, strong) YapDatabaseConnection *connection;

@end

@implementation StolpersteineReadDataService

- (id)init
{
    self = [super init];
    if (self) {
        _connection = [self.class.sharedDatabase newConnection];
        _cacheEnabled = _connection.objectCacheEnabled;
    }
    return self;
}

+ (YapDatabase *)sharedDatabase
{
    static YapDatabase *sharedDatabase = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedDatabase = [[YapDatabase alloc]initWithPath:self.class.databasePath];
        [self.class registerFullTextSearchExtensionWithDatabase:sharedDatabase];
        [self.class registerAllItemsViewExtensionWithDatabase:sharedDatabase];
    });
    
    return sharedDatabase;
}

+ (NSString *)databasePath
{
    // This directory is backed up by iOS, but never visible to the user,
    // see http://developer.apple.com/library/ios/#qa/qa1699/_index.html
    NSString *libraryPath = [NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES) lastObject];
    NSString *path = [libraryPath stringByAppendingPathComponent:@"Private Documents"];
    if (![NSFileManager.defaultManager fileExistsAtPath:path isDirectory:NULL]) {
        [NSFileManager.defaultManager createDirectoryAtPath:path withIntermediateDirectories:YES attributes:nil error:NULL];
    }

    return [path stringByAppendingPathComponent:@"database.sqlite"];
}

+ (void)registerFullTextSearchExtensionWithDatabase:(YapDatabase *)database
{
    NSArray *propertiesToIndex = @[NSStringFromSelector(@selector(personFirstName)),
                                   NSStringFromSelector(@selector(personLastName)),
                                   NSStringFromSelector(@selector(locationStreet)),
                                   NSStringFromSelector(@selector(locationZipCode)),
                                   NSStringFromSelector(@selector(locationCity))];
    YapDatabaseFullTextSearchBlockType blockType = YapDatabaseFullTextSearchBlockTypeWithObject;
    YapDatabaseFullTextSearchWithObjectBlock block = ^(NSMutableDictionary *dict, NSString *collection, NSString *key, id object) {
        NSAssert([collection isEqualToString:StolpersteineReadDataServiceCollection], @"Invalid collection");
        
        if ([object isKindOfClass:Stolperstein.class]) {
            Stolperstein *stolperstein = (Stolperstein *)object;
            
            if (stolperstein.personFirstName) {
                [dict setObject:stolperstein.personFirstName forKey:propertiesToIndex[0]];
            }
            if (stolperstein.personLastName) {
                [dict setObject:stolperstein.personLastName forKey:propertiesToIndex[1]];
            }
            if (stolperstein.locationStreet) {
                [dict setObject:stolperstein.locationStreet forKey:propertiesToIndex[2]];
            }
            if (stolperstein.locationZipCode) {
                [dict setObject:stolperstein.locationZipCode forKey:propertiesToIndex[3]];
            }
            if (stolperstein.locationCity) {
                [dict setObject:stolperstein.locationCity forKey:propertiesToIndex[4]];
            }
        }
    };
    
    YapDatabaseFullTextSearch *fullTextSearch = [[YapDatabaseFullTextSearch alloc] initWithColumnNames:propertiesToIndex block:block blockType:blockType version:FullTextSearchExtensionVersion];
    [database registerExtension:fullTextSearch withName:StolpersteineReadDataServiceFullTextSearchExtensionName];
}

+ (void)registerAllItemsViewExtensionWithDatabase:(YapDatabase *)database
{
    YapDatabaseViewGroupingWithKeyBlock groupingBlock = ^NSString *(NSString *collection, NSString *key) {
        NSAssert([collection isEqualToString:StolpersteineReadDataServiceCollection], @"Invalid collection");

        return @"";
    };
    YapDatabaseViewSortingWithKeyBlock sortingBlock = ^NSComparisonResult(NSString *group, NSString *collection1, NSString *key1, NSString *collection2, NSString *key2) {
        NSAssert([collection1 isEqualToString:StolpersteineReadDataServiceCollection], @"Invalid collection");
        NSAssert([collection2 isEqualToString:StolpersteineReadDataServiceCollection], @"Invalid collection");

        return NSOrderedSame;
    };
    YapDatabaseView *databaseView = [[YapDatabaseView alloc] initWithGroupingBlock:groupingBlock groupingBlockType:YapDatabaseViewBlockTypeWithKey sortingBlock:sortingBlock sortingBlockType:YapDatabaseViewBlockTypeWithKey versionTag:AllItemsViewExtensionVersion];
    [database registerExtension:databaseView withName:StolpersteineReadDataServiceAllItemsViewExtensionName];
}

- (void)setCacheEnabled:(BOOL)cacheEnabled
{
    _cacheEnabled = cacheEnabled;
    self.connection.objectCacheEnabled = cacheEnabled;
}

- (void)readWithBlock:(void (^)(YapDatabaseReadTransaction *transaction))block completionBlock:(dispatch_block_t)completionBlock
{
    if (self.isSynchronous) {
        [self.connection readWithBlock:block];
        if (completionBlock) {
            completionBlock();
        }
    } else {
        [self.connection asyncReadWithBlock:block completionBlock:completionBlock];
    }
}

- (void)retrieveStolpersteinWithID:(NSString *)ID completionHandler:(void (^)(Stolperstein *stolperstein))completionHandler
{
    if (!completionHandler) {
        return;
    }
    
    __block Stolperstein *stolperstein;
    [self readWithBlock:^(YapDatabaseReadTransaction *transaction) {
        stolperstein = [transaction objectForKey:ID inCollection:StolpersteineReadDataServiceCollection];
    } completionBlock:^{
        completionHandler(stolperstein);
    }];
}

- (void)retrieveStolpersteineWithRange:(NSRange)range completionHandler:(void (^)(NSArray *stolpersteine))completionHandler
{
    if (!completionHandler) {
        return;
    }
    
    __block NSMutableArray *stolpersteine;
    [self readWithBlock:^(YapDatabaseReadTransaction *transaction) {
        __block NSUInteger location = 0;
        stolpersteine = [NSMutableArray array];
        [transaction enumerateKeysInCollection:StolpersteineReadDataServiceCollection usingBlock:^(NSString *key, BOOL *stop) {
            BOOL isComplete = location >= (range.location + range.length);
            if (isComplete) {
                *stop = YES;
            } else if (location >= range.location) {
                Stolperstein *stolperstein = [transaction objectForKey:key inCollection:StolpersteineReadDataServiceCollection];
                [stolpersteine addObject:stolperstein];
            }
            location++;
        }];
    } completionBlock:^{
        completionHandler(stolpersteine);
    }];
}

- (void)retrieveStolpersteineWithSearchData:(StolpersteineSearchData *)searchData limit:(NSUInteger)limit completionHandler:(void (^)(NSArray *stolpersteine))completionHandler
{
    if (!completionHandler) {
        return;
    }
    
    NSMutableArray *searchStrings = [NSMutableArray array];
    if (searchData.keywordsString) {
        NSArray *keywords = [searchData.keywordsString componentsSeparatedByString:@" "];
        NSString *keywordsSearchString = [NSString stringWithFormat:@"%@*", [keywords componentsJoinedByString:@"* OR "]];
        [searchStrings addObject:keywordsSearchString];
    }
    
    if (searchData.street) {
        NSString *streetSearchString = [NSString stringWithFormat:@"%@:%@*", NSStringFromSelector(@selector(locationStreet)), searchData.street];
        [searchStrings addObject:streetSearchString];
    }
    
    NSString *searchString = [searchStrings componentsJoinedByString:@" AND "];
    __block NSMutableArray *stolpersteine;
    [self readWithBlock:^(YapDatabaseReadTransaction *transaction) {
        stolpersteine = [NSMutableArray array];
        YapDatabaseFullTextSearchTransaction *fullTextSearchTransaction = [transaction ext:StolpersteineReadDataServiceFullTextSearchExtensionName];
        [fullTextSearchTransaction enumerateKeysMatching:searchString usingBlock:^(NSString *collection, NSString *key, BOOL *stop) {
            NSAssert([collection isEqualToString:StolpersteineReadDataServiceCollection], @"Invalid collection");
            
            Stolperstein *stolperstein = [transaction objectForKey:key inCollection:StolpersteineReadDataServiceCollection];
            [stolpersteine addObject:stolperstein];
            
            if (stolpersteine.count >= limit) {
                *stop = YES;
            }
        }];
    } completionBlock:^{
        completionHandler(stolpersteine);
    }];
}

@end
