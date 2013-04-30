//
//  ProgressImageView.m
//  Stolpersteine
//
//  Created by Claus on 29.04.13.
//  Copyright (c) 2013 Option-U Software. All rights reserved.
//

#import "ProgressImageView.h"

#import "AFImageRequestOperation.h"

#define PROGRESS_VIEW_WIDTH 60

@interface ProgressImageView()

@property (nonatomic, strong) AFImageRequestOperation *imageRequestOperation;
@property (nonatomic, strong) UIProgressView *progressView;

@end

@implementation ProgressImageView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.progressView = [[UIProgressView alloc] initWithProgressViewStyle:UIProgressViewStyleDefault];
        self.progressView.progressTintColor = UIColor.lightGrayColor;
        [self addSubview:self.progressView];
        
        UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(toggleFullScreen:)];
        [self addGestureRecognizer:tapGestureRecognizer];
        self.userInteractionEnabled = YES;
    }
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    CGRect progressViewRect = self.progressView.frame;
    progressViewRect.origin.x = roundf((self.frame.size.width - PROGRESS_VIEW_WIDTH) * 0.5);
    progressViewRect.origin.y = roundf((self.frame.size.height - progressViewRect.size.height) * 0.5);
    progressViewRect.size.width = PROGRESS_VIEW_WIDTH;
    self.progressView.frame = progressViewRect;
}

+ (NSOperationQueue *)sharedImageRequestOperationQueue
{
    static NSOperationQueue *imageRequestOperationQueue = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        imageRequestOperationQueue = [[NSOperationQueue alloc] init];
        imageRequestOperationQueue.maxConcurrentOperationCount = 1;
    });
    
    return imageRequestOperationQueue;
}

- (void)setImageWithURL:(NSURL *)url
{
    self.image = nil;
    self.progressView.hidden = NO;

    __weak ProgressImageView *weakSelf = self;
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    self.imageRequestOperation = [[AFImageRequestOperation alloc] initWithRequest:request];
    
    [self.imageRequestOperation setDownloadProgressBlock:^(NSUInteger bytesRead, long long totalBytesRead, long long totalBytesExpectedToRead) {
        float totalBytes = totalBytesExpectedToRead > 0 ? totalBytesExpectedToRead : FLT_MAX;
        float progress = (float)totalBytesRead / totalBytes;
        weakSelf.progressView.progress = progress;
    }];
    
    [self.imageRequestOperation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, UIImage *responseObject) {
        if ([url isEqual:weakSelf.imageRequestOperation.request.URL]) {
            weakSelf.progressView.hidden = YES;
            weakSelf.image = responseObject;
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        weakSelf.progressView.hidden = YES;
    }];
    
    [[self.class sharedImageRequestOperationQueue] addOperation:self.imageRequestOperation];
}

- (void)cancelImageRequest
{
    [self.imageRequestOperation cancel];
    self.imageRequestOperation = nil;
}

- (void)toggleFullScreen:(UITapGestureRecognizer *)sender
{
    NSLog(@"toggleFullScreen");
}

@end
