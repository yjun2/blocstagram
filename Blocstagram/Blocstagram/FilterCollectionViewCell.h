//
//  FilterCollectionViewCell.h
//  Blocstagram
//
//  Created by Yong Jun on 6/22/15.
//  Copyright (c) 2015 Yong Jun. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FilterCollectionViewCell : UICollectionViewCell

@property (nonatomic, strong) UIImageView *thumbnail;
@property (nonatomic, strong) UILabel *label;
@property (nonatomic, assign) CGFloat thumbnailEdgeSize;

@end
