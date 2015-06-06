//
//  LikeButton.m
//  Blocstagram
//
//  Created by Yong Jun on 6/5/15.
//  Copyright (c) 2015 Yong Jun. All rights reserved.
//

#import "LikeButton.h"
#import "CircleSpinnerView.h"

#define kLikedStateImage @"heart-full";
#define kUnlikedStateImage @"heart-empty";

@interface LikeButton()

@property (nonatomic, strong) CircleSpinnerView *spinnerView;

@end

@implementation LikeButton

- (instancetype) init {
    self = [super init];
    
    if (self) {
        self.spinnerView = [[CircleSpinnerView alloc] initWithFrame:CGRectMake(0, 0, 44, 44)];
        [self addSubview:self.spinnerView];
        
        self.imageView.contentMode = UIViewContentModeScaleAspectFit;
        self.contentEdgeInsets = UIEdgeInsetsMake(10, 10, 10, 10);
        self.contentVerticalAlignment = UIControlContentVerticalAlignmentTop;
        self.likeButtonState = LikeStateNotLiked;
    }
    
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    self.spinnerView.frame = self.imageView.frame;
}

- (void) setLikeButtonState:(LikeState)likeButtonState {
    _likeButtonState = likeButtonState;
    
    NSString *imageName;
    
    switch (_likeButtonState) {
        case LikeStateLiked:
        case LikeStateUnliking:
            imageName = kLikedStateImage;
            break;
        
        case LikeStateNotLiked:
        case LikeStateLiking:
            imageName = kUnlikedStateImage;
    }
    
    switch (_likeButtonState) {
        case LikeStateLiking:
        case LikeStateUnliking:
            self.spinnerView.hidden = NO;
            self.userInteractionEnabled = NO;
            break;
        case LikeStateLiked:
        case LikeStateNotLiked:
            self.spinnerView.hidden = YES;
            self.userInteractionEnabled = YES;
    }
    
    [self setImage:[UIImage imageNamed:imageName] forState:UIControlStateNormal];
}

@end
