//
//  StolpersteineNetworkService.h
//  Stolpersteine
//
//  Created by Hoefele, Claus(choefele) on 08.01.13.
//  Copyright (c) 2013 Option-U Software. All rights reserved.
//

#import <Foundation/Foundation.h>

@class StolpersteinSearchData;
@protocol StolpersteinNetworkServiceDelegate;

@interface StolpersteinNetworkService : NSObject

@property (nonatomic, weak) id<StolpersteinNetworkServiceDelegate> delegate;
@property (nonatomic, assign) BOOL allowsInvalidSSLCertificate;
@property (nonatomic, strong) StolpersteinSearchData *defaultSearchData;

- (id)initWithClientUser:(NSString *)clientUser clientPassword:(NSString *)clientPassword;

- (NSOperation *)retrieveStolpersteineWithSearchData:(StolpersteinSearchData *)searchData range:(NSRange)range completionHandler:(BOOL (^)(NSArray *stolpersteine, NSError *error))completionHandler;

@end
