//
//  StolpersteineNetworkService.h
//  Stolpersteine
//
//  Created by Hoefele, Claus(choefele) on 08.01.13.
//  Copyright (c) 2013 Option-U Software. All rights reserved.
//

#import <Foundation/Foundation.h>

@class StolpersteinSearchData;

@interface StolpersteinNetworkService : NSObject

@property (nonatomic, assign) BOOL allowsInvalidSSLCertificate;

- (id)initWithClientUser:(NSString *)clientUser clientPassword:(NSString *)clientPassword;

- (NSOperation *)retrieveStolpersteineWithSearchData:(StolpersteinSearchData *)searchData range:(NSRange)range completionHandler:(void (^)(NSArray *stolpersteine, NSError *error))completionHandler;

@end
