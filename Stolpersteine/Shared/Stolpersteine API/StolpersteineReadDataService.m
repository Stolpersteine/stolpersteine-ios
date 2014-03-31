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

#import "Stolperstein.h"
#import "StolpersteineSearchData.h"

NSString * const StolpersteineReadDataServiceCollection = @"stolpersteine";
NSString * const StolpersteineReadDataServiceFullTextSearchExtensionName = @"fullTextSearch";

@interface StolpersteineReadDataService()

@property (nonatomic, strong) YapDatabaseConnection *connection;

@end

@implementation StolpersteineReadDataService

- (id)init
{
    self = [super init];
    if (self) {
        YapDatabase *database = [self.class sharedYapDatabase];
        [self.class registerFullTextSearchExtensionWithDatabase:database];
        _connection = [database newConnection];
        _cacheEnabled = _connection.objectCacheEnabled;
    }
    return self;
}

+ (YapDatabase *)sharedYapDatabase
{
    static YapDatabase *sharedYapDatabase = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedYapDatabase = [[YapDatabase alloc]initWithPath:StolpersteineReadDataService.filePath];
    });
    
    return sharedYapDatabase;
}

+ (NSString *)filePath
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
                                   NSStringFromSelector(@selector(personLastName))];
    YapDatabaseFullTextSearchBlockType blockType = YapDatabaseFullTextSearchBlockTypeWithObject;
    YapDatabaseFullTextSearchWithObjectBlock block = ^(NSMutableDictionary *dict, NSString *collection, NSString *key, id object) {
        if ([object isKindOfClass:Stolperstein.class]) {
            Stolperstein *stolperstein = (Stolperstein *)object;
            
            if (stolperstein.personFirstName) {
                [dict setObject:stolperstein.personFirstName forKey:propertiesToIndex[0]];
            }
            if (stolperstein.personLastName) {
                [dict setObject:stolperstein.personLastName forKey:propertiesToIndex[1]];
            }
        }
    };
    
    YapDatabaseFullTextSearch *fullTextSearch = [[YapDatabaseFullTextSearch alloc] initWithColumnNames:propertiesToIndex block:block blockType:blockType];
    [database registerExtension:fullTextSearch withName:StolpersteineReadDataServiceFullTextSearchExtensionName];
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

- (void)retrieveStolpersteineWithSearchData:(StolpersteineSearchData *)searchData range:(NSRange)range completionHandler:(void (^)(NSArray *stolpersteine))completionHandler
{
    if (!completionHandler) {
        return;
    }
    
    NSMutableString *searchString = [NSMutableString string];
    
    if (searchData.keyword) {
        NSArray *keywords = [searchData.keyword componentsSeparatedByString:@" "];
        [searchString appendString:[keywords componentsJoinedByString:@"* OR "]];
        [searchString appendString:@"*"];
    }
    
    __block NSMutableArray *stolpersteine;
    [self readWithBlock:^(YapDatabaseReadTransaction *transaction) {
        __block NSUInteger location = 0;
        stolpersteine = [NSMutableArray array];
        id fullTextSearch = [transaction ext:StolpersteineReadDataServiceFullTextSearchExtensionName];
        [fullTextSearch enumerateKeysMatching:searchString usingBlock:^(NSString *collection, NSString *key, BOOL *stop) {
            NSAssert([collection isEqualToString:StolpersteineReadDataServiceCollection], @"Invalid collection");
            
            BOOL isComplete = (location >= (range.location + range.length));
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

@end
