//
//  UIView+ImageUtilities.h
//  Blocstagram
//
//  Created by Yong Jun on 6/11/15.
//  Copyright (c) 2015 Yong Jun. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImage (ImageUtilities)

//- (UIImage *) imageWithFixedOrientation;
//- (UIImage *) imageResizedToMatchAspectRatioOfSize:(CGSize)size;
//- (UIImage *) imageCroppedToRect:(CGRect)cropRect;

- (UIImage *) imageByScalingToSize:(CGSize)size andCroppingWithRect:(CGRect)rect;

@end
