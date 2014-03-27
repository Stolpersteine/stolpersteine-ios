//
//  StolpersteineDataService.m
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

#import "StolpersteineDataService.h"

#import "YapDatabase.h"
#import "Stolperstein.h"

#define COLLECTION_STOLPERSTEINE @"stolpersteine"

@interface StolpersteineDataService()

@property (nonatomic, strong) YapDatabaseConnection *connection;

@end

@implementation StolpersteineDataService

- (id)init
{
    self = [super init];
    if (self) {
        _connection = [self.sharedYapDatabase newConnection];
    }
    return self;
}

- (void)setCacheEnabled:(BOOL)cacheEnabled
{
    _cacheEnabled = cacheEnabled;
    self.connection.objectCacheEnabled = cacheEnabled;
}

- (YapDatabase *)sharedYapDatabase
{
    static YapDatabase *sharedYapDatabase = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedYapDatabase = [[YapDatabase alloc]initWithPath:StolpersteineDataService.filePath];
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

- (void)createStolpersteine:(NSArray *)stolpersteine completionHandler:(void (^)())completionHandler
{
    [self.connection asyncReadWriteWithBlock:^(YapDatabaseReadWriteTransaction *transaction) {
        for (Stolperstein *stolperstein in stolpersteine) {
            [transaction setObject:stolperstein forKey:stolperstein.id inCollection:COLLECTION_STOLPERSTEINE];
        }
    } completionBlock:^{
        if (completionHandler) {
            completionHandler();
        }
    }];
}

- (void)retrieveStolpersteinWithID:(NSString *)ID completionHandler:(void (^)(Stolperstein *stolperstein))completionHandler
{
    if (!completionHandler) {
        return;
    }
    
    __block Stolperstein *stolperstein;
    [self.connection asyncReadWithBlock:^(YapDatabaseReadTransaction *transaction) {
        stolperstein = [transaction objectForKey:ID inCollection:COLLECTION_STOLPERSTEINE];
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
    [self.connection asyncReadWithBlock:^(YapDatabaseReadTransaction *transaction) {
        __block NSUInteger location = 0;
        stolpersteine = [NSMutableArray array];
        [transaction enumerateKeysInCollection:COLLECTION_STOLPERSTEINE usingBlock:^(NSString *key, BOOL *stop) {
            BOOL isComplete = location >= (range.location + range.length);
            if (isComplete) {
                *stop = YES;
            } else if (location >= range.location) {
                Stolperstein *stolperstein = [transaction objectForKey:key inCollection:COLLECTION_STOLPERSTEINE];
                [stolpersteine addObject:stolperstein];
            }
            location++;
        }];
    } completionBlock:^{
        completionHandler(stolpersteine);
    }];
}

- (void)deleteStolpersteine:(NSArray *)stolpersteine completionHandler:(void (^)())completionHandler
{
    [self.connection asyncReadWriteWithBlock:^(YapDatabaseReadWriteTransaction *transaction) {
        NSArray *keys = [stolpersteine valueForKey:@"id"];
        [transaction removeObjectsForKeys:keys inCollection:COLLECTION_STOLPERSTEINE];
    } completionBlock:^{
        if (completionHandler) {
            completionHandler();
        }
    }];
}

@end
