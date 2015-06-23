//
//  FilterCollectionViewCell.m
//  Blocstagram
//
//  Created by Yong Jun on 6/22/15.
//  Copyright (c) 2015 Yong Jun. All rights reserved.
//

#import "FilterCollectionViewCell.h"

@interface FilterCollectionViewCell()

@end

@implementation FilterCollectionViewCell

- (void)layoutSubviews {
    self.thumbnail = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, self.thumbnailEdgeSize, self.thumbnailEdgeSize)];
    self.thumbnail.contentMode = UIViewContentModeScaleAspectFill;
    self.thumbnail.clipsToBounds = YES;
    [self.contentView addSubview:self.thumbnail];
    
    self.label = [[UILabel alloc] initWithFrame:CGRectMake(0, self.thumbnailEdgeSize, self.thumbnailEdgeSize, 20)];
    self.label.textAlignment = NSTextAlignmentCenter;
    self.label.font = [UIFont fontWithName:@"HelveticaNeue-Medium" size:10];
    [self.contentView addSubview:self.label];
}

@end
