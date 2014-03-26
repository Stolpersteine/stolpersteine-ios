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
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentDirectory = [paths objectAtIndex:0];
    return [documentDirectory stringByAppendingPathComponent:@"database.sqlite"];
}

- (void)createStolpersteine:(NSArray *)stolpersteine completionHandler:(void (^)(NSError *error))completionHandler
{
    [self.connection readWriteWithBlock:^(YapDatabaseReadWriteTransaction *transaction) {
        for (Stolperstein *stolperstein in stolpersteine) {
            [transaction setObject:stolperstein forKey:stolperstein.id inCollection:COLLECTION_STOLPERSTEINE];
        }
        
        if (completionHandler) {
            completionHandler(nil);
        }
    }];
}

- (void)retrieveStolpersteinWithID:(NSString *)ID completionHandler:(void (^)(Stolperstein *stolperstein, NSError *error))completionHandler
{
    if (!completionHandler) {
        return;
    }
    
    [self.connection readWithBlock:^(YapDatabaseReadTransaction *transaction) {
        Stolperstein *stolperstein = [transaction objectForKey:ID inCollection:COLLECTION_STOLPERSTEINE];
        completionHandler(stolperstein, nil);
    }];
}

- (void)retrieveStolpersteineWithRange:(NSRange)range completionHandler:(void (^)(NSArray *stolpersteine, NSError *error))completionHandler
{
    
}

- (void)deleteStolpersteine:(NSArray *)stolpersteine completionHandler:(void (^)(NSError *error))completionHandler
{
    [self.connection readWriteWithBlock:^(YapDatabaseReadWriteTransaction *transaction) {
        NSArray *keys = [stolpersteine valueForKey:@"id"];
        [transaction removeObjectsForKeys:keys inCollection:COLLECTION_STOLPERSTEINE];
        
        if (completionHandler) {
            completionHandler(nil);
        }
    }];
}

@end
