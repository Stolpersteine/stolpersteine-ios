//
//  ProgressImageView.m
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
        
        self.contentMode = UIViewContentModeScaleAspectFill;
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
    [self cancelImageRequest];
    
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

@end
