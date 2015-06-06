//
//  DataSource.m
//  Blocstagram
//
//  Created by Yong Jun on 5/5/15.
//  Copyright (c) 2015 Yong Jun. All rights reserved.
//

#import "DataSource.h"
#import "Media.h"
#import "Comment.h"
#import "User.h"
#import "LoginViewController.h"
#import <UICKeyChainStore.h>
#import <AFNetworking.h>


@interface DataSource() {
    NSMutableArray *_mediaItems;
}

@property (nonatomic, strong) NSArray *mediaItems;
@property (nonatomic, strong) NSString *accessToken;
@property (nonatomic, assign) BOOL isRefreshing;
@property (nonatomic, assign) BOOL isLoadingOlderItems;
@property (nonatomic, assign) BOOL thereAreNoMOreOlderMessages;

@property (nonatomic, strong) AFHTTPRequestOperationManager *instagramOperationManager;

@end

@implementation DataSource

+ (instancetype) sharedInstance {
    static dispatch_once_t once;
    static id sharedInstance;
    dispatch_once(&once, ^{
        sharedInstance = [[self alloc] init];
    });
    
    return sharedInstance;
}

+ (NSString *)instagramClientId {
    return @"e4d9f58f5dfe4927a06eed8f4f5d8ed9";
}

- (instancetype) init {
    self = [super init];
    if (self) {
        [self createOperationManager];
        
        // tries to retrieve access token from UICKeyChainStore
        self.accessToken = [UICKeyChainStore stringForKey:@"access token"];
        
        if (!self.accessToken) {
            // no access token was returned, so get a new token and save
            [self registerForAccessTokenNotification];
        } else {
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                NSString *fullPath = [self pathForFileName:NSStringFromSelector(@selector(mediaItems))];
                NSArray *storedMediaItems = [NSKeyedUnarchiver unarchiveObjectWithFile:fullPath];
//                NSArray *storedMediaItems = [NSArray new];
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    if (storedMediaItems.count > 0) {
                        NSMutableArray *mutableMediaItems = [storedMediaItems mutableCopy];
                        
                        [self willChangeValueForKey:@"mediaItems"];
                        self.mediaItems = mutableMediaItems;
                        
                        [self requestNewItemsWithCompletionHandler:nil];
                        
                        [self didChangeValueForKey:@"mediaItems"];
                        
                    } else {
                        [self populateDataWithParameters:nil completionHandler:nil];
                    }
                });
            });
        }
        

    }
    
    return self;
}

- (void) createOperationManager {
    NSURL *baseURL = [NSURL URLWithString:@"https://api.instagram.com/v1/"];
    self.instagramOperationManager = [[AFHTTPRequestOperationManager alloc] initWithBaseURL:baseURL];
    
    AFJSONResponseSerializer *jsonSerializer = [AFJSONResponseSerializer serializer];
    AFImageResponseSerializer *imageSerializer = [AFImageResponseSerializer serializer];
    imageSerializer.imageScale = 1.0;
    
    AFCompoundResponseSerializer *serializer = [AFCompoundResponseSerializer compoundSerializerWithResponseSerializers:@[jsonSerializer, imageSerializer]];
    self.instagramOperationManager.responseSerializer = serializer;
}

- (void) deleteMediaItem:(Media *)item {
    NSMutableArray *mutableArrayWithKVO = [self mutableArrayValueForKey:@"mediaItems"];
    [mutableArrayWithKVO removeObject:item];
}

- (void) populateDataWithParameters:(NSDictionary *)parameters completionHandler:(NewItemCompletionBlock)completionHandler {
    
    if (self.accessToken) {
        NSMutableDictionary *mutableParameters = [@{@"access_token": self.accessToken} mutableCopy];
        
        [mutableParameters addEntriesFromDictionary:parameters];
        
        [self.instagramOperationManager GET:@"users/self/feed"
                                 parameters:mutableParameters
                                    success:^(AFHTTPRequestOperation *operation, id responseObject) {
                                        if ([responseObject isKindOfClass:[NSDictionary class]]) {
                                            [self parseDataFromFeedDictionary:responseObject fromRequestWithParameters:parameters];
                                            
                                            if (completionHandler) {
                                                completionHandler(nil);
                                            }
                                        }
                                    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                        if (completionHandler) {
                                            completionHandler(error);
                                        }
                                    }];
    }
}

- (void) parseDataFromFeedDictionary:(NSDictionary *) feedDictionary fromRequestWithParameters:(NSDictionary *)parameters {
    NSArray *mediaArray = feedDictionary[@"data"];
    
    NSMutableArray *tmpMediaItems = [NSMutableArray array];
    for (NSDictionary *mediaDictionary in mediaArray) {
        Media *mediaItem = [[Media alloc] initWithDictionary:mediaDictionary];
        if (mediaItem) {
            [tmpMediaItems addObject:mediaItem];
        }
    }
    
    NSMutableArray *mutableArrayWithKVO = [self mutableArrayValueForKey:@"mediaItems"];
    if (parameters[@"min_id"]) {
        NSRange rangeOfIndexes = NSMakeRange(0, tmpMediaItems.count);
        NSIndexSet *indexSetOfNewObjects = [NSIndexSet indexSetWithIndexesInRange:rangeOfIndexes];
        [mutableArrayWithKVO insertObjects:tmpMediaItems atIndexes:indexSetOfNewObjects];
    } else if (parameters[@"max_id"]) {
        if (tmpMediaItems.count == 0) {
            self.thereAreNoMOreOlderMessages = YES;
        }
        
        [mutableArrayWithKVO addObjectsFromArray:tmpMediaItems];
    } else {
        [self willChangeValueForKey:@"mediaItems"];
        self.mediaItems = tmpMediaItems;
        [self didChangeValueForKey:@"mediaItems"];
    }
    
    [self saveImages];
}

#pragma mark - download images

- (void) downloadImageForMediaItem:(Media *)mediaItem {
    if (mediaItem.mediaURL && !mediaItem.image) {
        mediaItem.downloadState = MediaDownloadStateDownloadInProgress;
        
        [self.instagramOperationManager GET:mediaItem.mediaURL.absoluteString
                                 parameters:nil
                                    success:^(AFHTTPRequestOperation *operation, id responseObject) {
                                        if ([responseObject isKindOfClass:[UIImage class]]) {
                                            mediaItem.image = responseObject;
                                            mediaItem.downloadState = MediaDownloadStateHasImage;
                                            NSMutableArray *mutableArrayWithKVO = [self mutableArrayValueForKey:@"mediaItems"];
                                            NSUInteger index = [mutableArrayWithKVO indexOfObject:mediaItem];
                                            [mutableArrayWithKVO replaceObjectAtIndex:index withObject:mediaItem];
                                            [self saveImages];
                                        } else {
                                            mediaItem.downloadState = MediaDownloadStateNonRecoverableError;
                                        }
                                    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                        NSLog(@"Error downloading image: %@", error);
                                        mediaItem.downloadState = MediaDownloadStateNonRecoverableError;
                                        if ([error.domain isEqualToString:NSURLErrorDomain]) {
                                            if (error.code == NSURLErrorTimedOut ||
                                                error.code == NSURLErrorCancelled ||
                                                error.code == NSURLErrorCannotConnectToHost ||
                                                error.code == NSURLErrorNetworkConnectionLost ||
                                                error.code == NSURLErrorNotConnectedToInternet ||
                                                error.code == kCFURLErrorInternationalRoamingOff ||
                                                error.code == kCFURLErrorCallIsActive ||
                                                error.code == kCFURLErrorDataNotAllowed ||
                                                error.code == kCFURLErrorRequestBodyStreamExhausted) {
                                                
                                                // It might work if we try again
                                                mediaItem.downloadState = MediaDownloadStateNeedsImage;
                                            }
                                        }
                                    }];
    }
}

#pragma mark - pull to fetch

- (void)requestNewItemsWithCompletionHandler:(NewItemCompletionBlock)completionHandler {
    self.thereAreNoMOreOlderMessages = NO;
    
    if (self.isRefreshing == NO) {
        self.isRefreshing = YES;
        
        NSString *minId = [[self.mediaItems firstObject] idNumber];
        NSDictionary *parameters = @{@"min_id": minId};
        
        [self populateDataWithParameters:parameters completionHandler:^(NSError *error) {
            self.isRefreshing = NO;
            
            if (completionHandler) {
                completionHandler(error);
            }
        }];
    }
}

- (void)requestOldItemsWithCompletionHandler:(NewItemCompletionBlock)completionHandler {
    if (self.isLoadingOlderItems == NO && self.thereAreNoMOreOlderMessages == NO) {
        self.isLoadingOlderItems = YES;
        
        NSString *maxId = [[self.mediaItems lastObject] idNumber];
        NSDictionary *parameters = @{@"max_id": maxId};
        
        [self populateDataWithParameters:parameters completionHandler:^(NSError *error) {
            self.isLoadingOlderItems = NO;
            
            if (completionHandler) {
                completionHandler(error);
            }
        }];
        
    }
}

- (void) registerForAccessTokenNotification {
    [[NSNotificationCenter defaultCenter] addObserverForName:LoginViewControllerDidGetAccessTokenNotification object:nil queue:nil usingBlock:^(NSNotification *note) {
        self.accessToken = note.object;
        
        // save the token
        [UICKeyChainStore setString:self.accessToken forKey:@"access token"];
        
        // Got a token, populate the initial data
        [self populateDataWithParameters:nil completionHandler:nil];
    }];
}

#pragma mark - key value observation

- (NSUInteger) countOfMediaItems {
    return self.mediaItems.count;
}

- (id) objectInMediaItemsAtIndex:(NSUInteger)index {
    return [self.mediaItems objectAtIndex:index];
}

- (NSArray *) mediaItemsAtIndexes:(NSIndexSet *)indexes {
    return [self.mediaItems objectsAtIndexes:indexes];
}

- (void) insertObject:(Media *)object inMediaItemsAtIndex:(NSUInteger)index {
    [_mediaItems insertObject:object atIndex:index];
}

- (void) removeObjectFromMediaItemsAtIndex:(NSUInteger)index {
    [_mediaItems removeObjectAtIndex:index];
}

- (void) replaceObjectInMediaItemsAtIndex:(NSUInteger)index withObject:(id)object {
    [_mediaItems replaceObjectAtIndex:index withObject:object];
}

#pragma mark - save images

- (NSString *) pathForFileName:(NSString *)fileName {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
    NSString *documentDirectory = [paths firstObject];
    NSString *dataPath = [documentDirectory stringByAppendingString:fileName];
    return dataPath;
}

- (void) saveImages {
    if (self.mediaItems.count > 0) {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            NSUInteger numberOfImagesToSave = MIN(self.mediaItems.count, 50);
            NSArray *mediaItemsToSave = [self.mediaItems subarrayWithRange:NSMakeRange(0, numberOfImagesToSave)];
            
            NSString *fileNamePath = [self pathForFileName:NSStringFromSelector(@selector(mediaItems))];
            NSData *mediaItemData = [NSKeyedArchiver archivedDataWithRootObject:mediaItemsToSave];
            
            NSError *dataError;
            BOOL wroteSuccessfully = [mediaItemData writeToFile:fileNamePath options:NSDataWritingAtomic | NSDataWritingFileProtectionCompleteUnlessOpen error:&dataError];
            
            if (!wroteSuccessfully) {
                NSLog(@"Couldn't write file: %@", dataError);
            }
        });
        
    }
}

- (void) toggleLikeOnMediaItem:(Media *)mediaItem withCompletionHandler:(void (^)(void))completionHandler {
    NSString *urlString = [NSString stringWithFormat:@"media/%@/likes", mediaItem.idNumber];
    NSDictionary *parameter = @{@"access_token": self.accessToken};
    
    if (mediaItem.likeState == LikeStateNotLiked) {
        mediaItem.likeState = LikeStateLiking;
        
        [self.instagramOperationManager POST:urlString parameters:parameter
                                     success:^(AFHTTPRequestOperation *operation, id responseObject) {
                                         mediaItem.likeState = LikeStateLiked;
                                         if (completionHandler) {
                                             completionHandler();
                                         }
                                     } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                         mediaItem.likeState = LikeStateNotLiked;
                                         if (completionHandler) {
                                             completionHandler();
                                         }
                                     }];
    } else if (mediaItem.likeState == LikeStateLiked) {
        mediaItem.likeState = LikeStateUnliking;
        
        [self.instagramOperationManager DELETE:urlString parameters:parameter
                                        success:^(AFHTTPRequestOperation *operation, id responseObject) {
                                            mediaItem.likeState = LikeStateNotLiked;
                                            if (completionHandler) {
                                                completionHandler();
                                            }
                                        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                            mediaItem.likeState = LikeStateLiked;
                                            if (completionHandler) {
                                                completionHandler();
                                            }
                                        }];
        
    }
}

@end
