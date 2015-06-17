//
//  CropImageViewController.h
//  Blocstagram
//
//  Created by Yong Jun on 6/15/15.
//  Copyright (c) 2015 Yong Jun. All rights reserved.
//

#import "MediaFullScreenViewController.h"

@class CropImageViewController;

@protocol CropImageViewControllerDelegate <NSObject>

- (void) cropControllerFinishedWithImage:(UIImage *)croppedImage;

@end

@interface CropImageViewController : MediaFullScreenViewController

- (instancetype) initWithImage:(UIImage *)image;

@property (nonatomic, weak) NSObject <CropImageViewControllerDelegate> *delegate;

@end
