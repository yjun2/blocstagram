//
//  ImagesTableViewController.m
//  Blocstagram
//
//  Created by Yong Jun on 5/3/15.
//  Copyright (c) 2015 Yong Jun. All rights reserved.
//

#import "ImagesTableViewController.h"
#import "User.h"
#import "Comment.h"
#import "Media.h"
#import "DataSource.h"
#import "MediaTableViewCell.h"
#import "MediaFullScreenViewController.h"

@interface ImagesTableViewController () <MediaTableViewCellDelegate>

- (NSArray *) items;

@end

@implementation ImagesTableViewController

- (id)initWithStyle:(UITableViewStyle)style {
    self = [super initWithStyle:style];
    
    if (self) {
    }
    
    return self;
}

- (NSArray *) items {
    return [DataSource sharedInstance].mediaItems;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [[DataSource sharedInstance] addObserver:self
                                  forKeyPath:@"mediaItems"
                                     options:0
                                     context:nil];
    
    self.refreshControl = [[UIRefreshControl alloc] init];
    [self.refreshControl addTarget:self action:@selector(refreshControlDidFire:) forControlEvents:UIControlEventValueChanged];
    
    [self.tableView registerClass:[MediaTableViewCell class] forCellReuseIdentifier:@"mediaCell"];

}

- (void) dealloc {
    [[DataSource sharedInstance] removeObserver:self forKeyPath:@"mediaItems"];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self items].count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    MediaTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"mediaCell" forIndexPath:indexPath];
    cell.delegate = self;
    cell.mediaItem = [DataSource sharedInstance].mediaItems[indexPath.row];
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    Media *item = self.items[indexPath.row];
    return [MediaTableViewCell heightForMediaItem:item width:CGRectGetWidth(self.view.frame)];
}

// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}

// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        Media *item = self.items[indexPath.row];
        [[DataSource sharedInstance] deleteMediaItem:item];
        
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
//    NSLog(@"will display row: %d", (int)indexPath.row);
//    Media *mediaItem = [DataSource sharedInstance].mediaItems[indexPath.row];
//    if (mediaItem.downloadState == MediaDownloadStateNeedsImage) {
//        NSLog(@"fetching image from willDisplayCell");
//        [[DataSource sharedInstance] downloadImageForMediaItem:mediaItem];
//    }
}

- (CGFloat)tableView:(UITableView *)tableView estimatedHeightForRowAtIndexPath:(NSIndexPath *)indexPath {
    Media *media = [DataSource sharedInstance].mediaItems[indexPath.row];
    if (media.image) {
        return 350;
    } else {
        return 150;
    }
}

#pragma mark - UIRefreshControl

- (void) refreshControlDidFire:(UIRefreshControl *) sender {
    [[DataSource sharedInstance] requestNewItemsWithCompletionHandler:^(NSError *error) {
        [sender endRefreshing];
    }];
}

- (void) infiniteScrollIfNecessary {
    NSIndexPath *bottomIndexPath = [[self.tableView indexPathsForVisibleRows] lastObject];
    if (bottomIndexPath && bottomIndexPath.row == [DataSource sharedInstance].mediaItems.count - 1) {
        [[DataSource sharedInstance] requestOldItemsWithCompletionHandler:nil];
    }
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
//    scrollView.decelerationRate = UIScrollViewDecelerationRateFast;
    
    CGPoint bottomPoint = CGPointMake(0 ,scrollView.contentOffset.y);
    NSInteger row = [[self.tableView indexPathForRowAtPoint:bottomPoint] row];
    Media *mediaItem = [DataSource sharedInstance].mediaItems[(long)row];
    if (mediaItem.downloadState == MediaDownloadStateNeedsImage) {
        NSLog(@"fetching image scrollDidScroll");
        [[DataSource sharedInstance] downloadImageForMediaItem:mediaItem];
    }
    
    [self infiniteScrollIfNecessary];
}

//- (void)scrollViewWillBeginDecelerating:(UIScrollView *)scrollView {
////    scrollView.decelerationRate = UIScrollViewDecelerationRateFast;
//    CGPoint bottomPoint = CGPointMake(0 ,scrollView.contentOffset.y);
//    
////    NSLog(@"%ld", (long)[[self.tableView indexPathForRowAtPoint:bottomPoint] row]);
//    
//    NSInteger row = [[self.tableView indexPathForRowAtPoint:bottomPoint] row];
//    Media *mediaItem = [DataSource sharedInstance].mediaItems[(long)row];
//    if (mediaItem.downloadState == MediaDownloadStateNeedsImage) {
//        NSLog(@"fetching image willbegindecelerating");
//        [[DataSource sharedInstance] downloadImageForMediaItem:mediaItem];
//    }
//    
//}
//
//- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
//    CGPoint bottomPoint = CGPointMake(0 ,scrollView.contentOffset.y);
//    
////    NSLog(@"%ld", (long)[[self.tableView indexPathForRowAtPoint:bottomPoint] row]);
//    
//    NSInteger row = [[self.tableView indexPathForRowAtPoint:bottomPoint] row];
//    Media *mediaItem = [DataSource sharedInstance].mediaItems[(long)row];
//    if (mediaItem.downloadState == MediaDownloadStateNeedsImage) {
//        NSLog(@"fetching image didenddecelrating");
//        [[DataSource sharedInstance] downloadImageForMediaItem:mediaItem];
//    }
//}

#pragma mark - key-value observing

- (void) observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    if (object == [DataSource sharedInstance] && [keyPath isEqualToString:@"mediaItems"]) {
        NSKeyValueChange kindOfChange = [change[NSKeyValueChangeKindKey] unsignedIntegerValue];
        if (kindOfChange == NSKeyValueChangeSetting) {
            [self.tableView reloadData];
        } else if (kindOfChange == NSKeyValueChangeInsertion ||
                   kindOfChange == NSKeyValueChangeRemoval ||
                   kindOfChange == NSKeyValueChangeReplacement) {
            
            NSIndexSet *indexSetOfChanges = change[NSKeyValueChangeIndexesKey];
            
            NSMutableArray *indexPathsThatChanged = [NSMutableArray array];
            [indexSetOfChanges enumerateIndexesUsingBlock:^(NSUInteger idx, BOOL *stop) {
                NSIndexPath *newIndexPath = [NSIndexPath indexPathForRow:idx inSection:0];
                [indexPathsThatChanged addObject:newIndexPath];
            }];
            
            [self.tableView beginUpdates];
            
            if (kindOfChange == NSKeyValueChangeInsertion) {
                [self.tableView insertRowsAtIndexPaths:indexPathsThatChanged withRowAnimation:UITableViewRowAnimationAutomatic];
            } else if (kindOfChange == NSKeyValueChangeRemoval) {
                [self.tableView deleteRowsAtIndexPaths:indexPathsThatChanged withRowAnimation:UITableViewRowAnimationAutomatic];
            } else if (kindOfChange == NSKeyValueChangeReplacement) {
                [self.tableView reloadRowsAtIndexPaths:indexPathsThatChanged withRowAnimation:UITableViewRowAnimationAutomatic];
            }
            
            [self.tableView endUpdates];
        }
    }
}

#pragma mark - MediaTAbleViewCellDelegate

- (void)cell:(MediaTableViewCell *)cell didTapImageView:(UIImageView *)imageView {
    MediaFullScreenViewController *fullScreenVC = [[MediaFullScreenViewController alloc] initWithMedia:cell.mediaItem];
    [self presentViewController:fullScreenVC animated:YES completion:nil];
}

- (void)cell:(MediaTableViewCell *)cell didLongPressImageView:(UIImageView *)imageView {
    NSMutableArray *itemsToShare = [NSMutableArray array];
    
    if (cell.mediaItem.caption.length > 0) {
        [itemsToShare addObject:cell.mediaItem.caption];
    }
    
    if (cell.mediaItem.image) {
        [itemsToShare addObject:cell.mediaItem.image];
    }

    [MediaTableViewCell presentActivityViewController:itemsToShare viewController:self];
}

- (void)cell:(MediaTableViewCell *)cell didTwoFingerTapImageView:(UIImageView *)imageView {
    [[DataSource sharedInstance] downloadImageForMediaItem:cell.mediaItem];
}

@end
