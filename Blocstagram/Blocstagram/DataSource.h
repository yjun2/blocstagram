//
//  DataSource.h
//  Blocstagram
//
//  Created by Yong Jun on 5/5/15.
//  Copyright (c) 2015 Yong Jun. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DataSource : NSObject

+(instancetype) sharedInstance;

// readonly. prevent other classes from modifying it
@property (nonatomic, strong, readonly) NSArray *mediaItems;

- (void) deleteRow:(NSUInteger) index;

@end
