//
//  ImageGalleryViewController.m
//  Stolpersteine
//
//  Created by Hoefele, Claus(choefele) on 06.06.13.
//  Copyright (c) 2013 Option-U Software. All rights reserved.
//

#import "ImageGalleryViewController.h"

#import "ProgressImageView.h"
#import "ImageGalleryViewCell.h"
#import "AGWindowView.h"

#define ITEM_IDENTIFIER @"item"
#define ANIMATION_DURATION 0.3f

@interface ImageGalleryViewController()

@property (nonatomic, strong) NSArray *progressImageViews;

@property (nonatomic, strong) UIView *backgroundView;
@property (nonatomic, strong) UIView *imageGalleryViewSuperView;
@property (nonatomic, assign) BOOL showsFullScreenGallery;

@end

@implementation ImageGalleryViewController

- (id)init
{
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
    self = [super initWithCollectionViewLayout:layout];
    if (self) {
        layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
        
        [self.collectionView registerClass:ImageGalleryViewCell.class forCellWithReuseIdentifier:ITEM_IDENTIFIER];
        self.collectionView.pagingEnabled = YES;
        self.collectionView.backgroundColor = UIColor.whiteColor;
        self.collectionView.showsHorizontalScrollIndicator = NO;
        
        self.spacing = layout.minimumLineSpacing;
    }

    return self;
}

- (void)viewWillAppear:(BOOL)animated
{
    // Load images before calling super's viewWillAppear: to ensure that all items are ready to be displayed
    if (self.progressImageViews == nil) {
        [self loadImages];
    }

    [super viewWillAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    [self cancelImageRequests];
}

- (void)loadImages
{
    NSMutableArray *progressImageViews = [[NSMutableArray alloc] initWithCapacity:self.imageURLStrings.count];
    for (NSString *urlString in self.imageURLStrings) {
        ProgressImageView *progressImageView = [[ProgressImageView alloc] init];
        [progressImageView setImageWithURL:[NSURL URLWithString:urlString]];
        [progressImageViews addObject:progressImageView];
    }
    self.progressImageViews = progressImageViews;
}

- (void)cancelImageRequests
{
    for (ImageGalleryViewCell *imageGalleryItemView in self.progressImageViews) {
        [imageGalleryItemView.progressImageView cancelImageRequest];
    }
    self.progressImageViews = nil;
}

- (void)addToParentViewController:(UIViewController *)parentViewController inView:(UIView *)view
{
    [parentViewController addChildViewController:self];
    self.view.frame = view.bounds;
    [view addSubview:self.view];
    [self didMoveToParentViewController:parentViewController];
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.progressImageViews.count;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    CGFloat height = self.view.frame.size.height;
    return CGSizeMake(height, height);
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section
{
    return self.spacing;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    ImageGalleryViewCell *imageGalleryViewCell = [self.collectionView dequeueReusableCellWithReuseIdentifier:ITEM_IDENTIFIER forIndexPath:indexPath];
    imageGalleryViewCell.progressImageView = self.progressImageViews[indexPath.row];
    imageGalleryViewCell.frameWidth = self.frameWidth;
    imageGalleryViewCell.frameColor = self.frameColor;
    UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(didTapImageView:)];
    [imageGalleryViewCell addGestureRecognizer:tapGestureRecognizer];

    return imageGalleryViewCell;
}

- (void)didTapImageView:(UITapGestureRecognizer *)sender
{
    if (self.showsFullScreenGallery) {
        [self hideFullScreenGallery];
    } else {
        [self showFullScreenGallery];
    }
    self.showsFullScreenGallery = !self.showsFullScreenGallery;
}

- (void)showFullScreenGallery
{
    [UIApplication.sharedApplication setStatusBarHidden:YES withAnimation:UIStatusBarAnimationFade];
    self.imageGalleryViewSuperView = self.view.superview;
    
    AGWindowView *windowView = [[AGWindowView alloc] initAndAddToKeyWindow];
    windowView.supportedInterfaceOrientations = UIInterfaceOrientationMaskAll;
    self.backgroundView = [[UIView alloc] initWithFrame:windowView.bounds];
    self.backgroundView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    self.backgroundView.backgroundColor = UIColor.blackColor;
    self.backgroundView.alpha = 0;
    [windowView addSubview:self.backgroundView];
    [windowView addSubViewAndKeepSamePosition:self.view];
    
    [UIView animateWithDuration:ANIMATION_DURATION animations:^{
        self.backgroundView.alpha = 1;
        self.view.frame = windowView.bounds;
    } completion:NULL];
}

- (void)hideFullScreenGallery
{
    [UIApplication.sharedApplication setStatusBarHidden:NO withAnimation:UIStatusBarAnimationFade];
    
    // Hack to fix layout after the status bar was hidden
    UIViewController *rootViewController = self.view.window.rootViewController;
    if ([rootViewController isKindOfClass:UINavigationController.class]) {
        UINavigationController *navigationController = (UINavigationController *)rootViewController;
        [navigationController setNavigationBarHidden:YES];
        [navigationController setNavigationBarHidden:NO];
    }
    
    AGWindowView *windowView = [AGWindowView activeWindowViewContainingView:self.view];
    [UIView animateWithDuration:ANIMATION_DURATION animations:^{
        self.backgroundView.alpha = 0;
        CGRect frame = [windowView convertRect:self.imageGalleryViewSuperView.bounds fromView:self.imageGalleryViewSuperView];
        self.view.frame = frame;
    } completion:^(BOOL finished) {
        CGRect frame = [self.imageGalleryViewSuperView convertRect:self.view.frame fromView:self.view.superview];
        self.view.frame = frame;
        [self.imageGalleryViewSuperView addSubview:self.view];
        
        [windowView removeFromSuperview];
        self.backgroundView = nil;
    }];
}

@end
