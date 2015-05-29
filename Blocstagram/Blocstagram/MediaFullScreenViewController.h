//
//  MediaFullScreenViewController.h
//  Blocstagram
//
//  Created by Yong Jun on 5/26/15.
//  Copyright (c) 2015 Yong Jun. All rights reserved.
//

#import <UIKit/UIKit.h>

@class Media;

@interface MediaFullScreenViewController : UIViewController

@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, strong) UIImageView *imageView;

- (instancetype) initWithMedia:(Media *)media;
- (void) centerScrollView;

@end
