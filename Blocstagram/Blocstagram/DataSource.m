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

@interface DataSource()

// Redefine 'mediaItems' by removing 'readonly'.
// Only the DataSource instance can modify this property
@property (nonatomic, strong) NSArray *mediaItems;

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

- (instancetype) init {
    self = [super init];
    if (self) {
        [self randomData];
    }
    
    return self;
}


- (void) randomData {
    NSMutableArray *randomMediaItems = [NSMutableArray array];
    
    for (int i = 1; i <= 10; i++) {
        NSString *imageName = [NSString stringWithFormat:@"%d.jpg", i];
        UIImage *image = [UIImage imageNamed:imageName];
        
        if (image) {
            Media *media = [[Media alloc] init];
            media.user = [self randomUser];
            media.image = image;
            media.caption = [self randomSentence];
            
            NSUInteger commentCount = arc4random_uniform(10);
            NSMutableArray *randomComments = [NSMutableArray array];
            
            for (int i = 1; i <= commentCount; i++) {
                Comment *randomComment = [self randomComment];
                [randomComments addObject:randomComment];
            }
            
            media.comments = randomComments;
            [randomMediaItems addObject:media];
        }
    }
    
    self.mediaItems = randomMediaItems;
}

- (User *) randomUser {
    User *user = [[User alloc] init];
    user.userName = [self randomStringofLength:arc4random_uniform(10)];
    NSString *firstName = [self randomStringofLength:arc4random_uniform(7)];
    NSString *lastName = [self randomStringofLength:arc4random_uniform(12)];
    user.fullName = [NSString stringWithFormat:@"%@ %@", firstName, lastName];
    
    return user;
}

- (Comment *) randomComment {
    Comment *comment = [[Comment alloc] init];
    comment.from = [self randomUser];
    comment.text = [self randomSentence];
    return comment;
}

- (NSString *) randomSentence {
    NSUInteger wordCount = arc4random_uniform(20);
    NSMutableString *randomSentence = [[NSMutableString alloc] init];
    for (int i = 1; i <= wordCount; i++) {
        NSString *randomWord = [self randomStringofLength:arc4random_uniform(12)];
        [randomSentence appendFormat:@"%@ ", randomWord];
    }
    
    return randomSentence;
}

- (NSString *) randomStringofLength:(NSUInteger) len {
    NSString *alphabet = @"abcdefghijklmnopqrstuvwxyz";
    NSMutableString *s = [NSMutableString string];
    for (NSUInteger i = 0U; i < len; i++) {
        u_int32_t r = arc4random_uniform((u_int32_t)[alphabet length]);
        unichar c = [alphabet characterAtIndex:r];
        [s appendFormat:@"%C", c];
    }
    
    return [NSString stringWithString:s];
}

- (void) deleteRow:(NSUInteger)index {
    NSMutableArray *mutableMediaItems = [self.mediaItems mutableCopy];
    [mutableMediaItems removeObjectAtIndex:index];
    self.mediaItems = mutableMediaItems;
}
@end