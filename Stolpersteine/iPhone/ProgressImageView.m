//
//  ProgressImageView.m
//  Stolpersteine
//
//  Created by Claus on 29.04.13.
//  Copyright (c) 2013 Option-U Software. All rights reserved.
//

#import "ProgressImageView.h"

#import "AFImageRequestOperation.h"

@interface ProgressImageView()

@property (nonatomic, strong) AFImageRequestOperation *imageRequestOperation;

@end

@implementation ProgressImageView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = UIColor.grayColor;
    }
    return self;
}

+ (NSOperationQueue *)sharedImageRequestOperationQueue
{
    static NSOperationQueue *imageRequestOperationQueue = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        imageRequestOperationQueue = [[NSOperationQueue alloc] init];
        imageRequestOperationQueue.maxConcurrentOperationCount = NSOperationQueueDefaultMaxConcurrentOperationCount;
    });
    
    return imageRequestOperationQueue;
}

- (void)setImageWithURL:(NSURL *)url
{
    self.image = nil;

    __weak ProgressImageView *weakSelf = self;
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    self.imageRequestOperation = [[AFImageRequestOperation alloc] initWithRequest:request];
    [self.imageRequestOperation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, UIImage *responseObject) {
        if ([url isEqual:weakSelf.imageRequestOperation.request.URL]) {
            weakSelf.image = responseObject;
        }
    } failure:NULL];
    
    [[self.class sharedImageRequestOperationQueue] addOperation:self.imageRequestOperation];
}

- (void)cancelImageRequestOperation
{
    [self.imageRequestOperation cancel];
    self.imageRequestOperation = nil;
}

@end
