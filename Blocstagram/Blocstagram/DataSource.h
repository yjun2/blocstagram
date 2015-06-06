//
//  DataSource.h
//  Blocstagram
//
//  Created by Yong Jun on 5/5/15.
//  Copyright (c) 2015 Yong Jun. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Media.h"

@class Media;

typedef void (^NewItemCompletionBlock)(NSError *error);

//CLIENT ID	e4d9f58f5dfe4927a06eed8f4f5d8ed9
//CLIENT SECRET	e5eedf03b02b42569ce35c09d3758d1d

@interface DataSource : NSObject

+ (instancetype) sharedInstance;
+ (NSString *) instagramClientId;

// readonly. prevent other classes from modifying it
@property (nonatomic, strong, readonly) NSArray *mediaItems;
@property (nonatomic, strong, readonly) NSString *accessToken;

- (void) deleteMediaItem:(Media *)item;
- (void) requestNewItemsWithCompletionHandler:(NewItemCompletionBlock)completionHandler;
- (void) requestOldItemsWithCompletionHandler:(NewItemCompletionBlock)completionHandler;

- (void) downloadImageForMediaItem:(Media *)mediaItem;
- (void) toggleLikeOnMediaItem:(Media *)mediaItem withCompletionHandler:(void (^)(void))completionHandler;

@end
