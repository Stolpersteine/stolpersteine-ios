//
//  StolpersteineNetworkService.h
//  Stolpersteine
//
//  Created by Hoefele, Claus(choefele) on 08.01.13.
//  Copyright (c) 2013 Option-U Software. All rights reserved.
//

#import <Foundation/Foundation.h>

@class SearchData;

@interface StolpersteineNetworkService : NSObject

- (id)initWithURL:(NSURL *)url clientUser:(NSString *)clientUser clientPassword:(NSString *)clientPassword;

- (void)retrieveStolpersteineWithSearchData:(SearchData *)searchData page:(NSUInteger)page pageSize:(NSUInteger)pageSize completionHandler:(void (^)(NSArray *stolpersteine, NSUInteger totalNumberOfItems, NSError *error))completionHandler;

@end
