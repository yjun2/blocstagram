//
//  MediaFullScreenViewController.m
//  Blocstagram
//
//  Created by Yong Jun on 5/26/15.
//  Copyright (c) 2015 Yong Jun. All rights reserved.
//

#import "MediaFullScreenViewController.h"
#import "Media.h"
#import "MediaTableViewCell.h"

@interface MediaFullScreenViewController () <UIScrollViewDelegate>

@property (nonatomic, strong) Media *media;
@property (nonatomic, strong) UITapGestureRecognizer *tap;
@property (nonatomic, strong) UITapGestureRecognizer *doubleTap;

@property (nonatomic, strong) UIButton *shareButton;

@end

@implementation MediaFullScreenViewController

- (instancetype)initWithMedia:(Media *)media {
    self = [super init];
    
    if (self) {
        self.media = media;
    }
    
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // initialize UIScrollView
    self.scrollView = [[UIScrollView alloc] init];
    self.scrollView.delegate = self;
    self.scrollView.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:self.scrollView];
    
    // initialize UIImageView
    self.imageView = [[UIImageView alloc] init];
    self.imageView.image = self.media.image;
    [self.scrollView addSubview:self.imageView];
    self.scrollView.contentSize = self.media.image.size;
    
    self.tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapFired:)];
    self.doubleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(doubleTapFired:)];
    self.doubleTap.numberOfTapsRequired = 2;
    
    [self.tap requireGestureRecognizerToFail:self.doubleTap];
    
    [self.scrollView addGestureRecognizer:self.tap];
    [self.scrollView addGestureRecognizer:self.doubleTap];
    
    // initialize share button
    self.shareButton = [UIButton buttonWithType:UIButtonTypeSystem];
    [self.shareButton setTitle:NSLocalizedString(@"Share", @"share") forState:UIControlStateNormal];
    [self.shareButton addTarget:self action:@selector(buttonPressed:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.shareButton];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self centerScrollView];
}

- (void)viewWillLayoutSubviews {
    [super viewWillLayoutSubviews];
    
    self.scrollView.frame = self.view.bounds;
    
    CGSize scrollViewFrameSize = self.scrollView.frame.size;
    CGSize scrollViewContentSize = self.scrollView.contentSize;
    
    CGFloat scaleWidth = scrollViewFrameSize.width / scrollViewContentSize.width;
    CGFloat scaleHeight = scrollViewFrameSize.height / scrollViewContentSize.height;
    CGFloat minScale = MIN(scaleWidth, scaleHeight);
    
    self.scrollView.minimumZoomScale = minScale;
    self.scrollView.maximumZoomScale = 1;
    
    // share button
    CGFloat buttonHeight = 50;
    CGFloat buttonWidth = 100;
    CGFloat buttonX = CGRectGetWidth(self.scrollView.frame) - CGRectGetWidth(self.shareButton.frame);
    CGFloat buttonY = 25;
    
    self.shareButton.frame = CGRectMake(buttonX, buttonY, buttonWidth, buttonHeight);
    
}

- (void)centerScrollView {
    [self.imageView sizeToFit];
    
    CGSize boundsSize = self.scrollView.bounds.size;
    CGRect contentFrame = self.imageView.frame;
    
    if (contentFrame.size.width < boundsSize.width) {
        contentFrame.origin.x = (boundsSize.width - CGRectGetWidth(contentFrame)) / 2;
    } else {
        contentFrame.origin.x = 0;
    }
    
    if (contentFrame.size.height < boundsSize.height) {
        contentFrame.origin.y = (boundsSize.height - CGRectGetHeight(contentFrame)) / 2;
    } else {
        contentFrame.origin.y = 0;
    }
    
    self.imageView.frame = contentFrame;
}

#pragma mark - UIScrollViewDelegate

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView {
    return self.imageView;
}

- (void)scrollViewDidZoom:(UIScrollView *)scrollView {
    [self centerScrollView];
}

- (void) tapFired:(UITapGestureRecognizer *)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void) doubleTapFired:(UITapGestureRecognizer *)sender {
    if (self.scrollView.zoomScale == self.scrollView.minimumZoomScale) {
        
        //get the location of where finger touched the imageView
        CGPoint locationPoint = [sender locationInView:self.imageView];
        
        CGSize scrollViewSize = self.scrollView.bounds.size;
        
        CGFloat width = scrollViewSize.width / self.scrollView.maximumZoomScale;
        CGFloat height = scrollViewSize.height /self.scrollView.maximumZoomScale;
        CGFloat x = locationPoint.x - (width / 2);
        CGFloat y = locationPoint.y - (height / 2);
        
        [self.scrollView zoomToRect:CGRectMake(x, y, width, height) animated:YES];
    } else {
        [self.scrollView setZoomScale:self.scrollView.minimumZoomScale animated:YES];
    }
    
}

- (void) buttonPressed:(UIButton *)sender {
    NSLog(@"share button pressed");
    NSMutableArray *itemsToShare = [NSMutableArray array];
    
    [itemsToShare addObject:self.media.image];
    [MediaTableViewCell presentActivityViewController:itemsToShare viewController:self];
}

@end
