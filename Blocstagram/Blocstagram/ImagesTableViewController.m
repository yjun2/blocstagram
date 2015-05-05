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

@interface ImagesTableViewController ()

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
    
    
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"imageCell"];
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
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"imageCell" forIndexPath:indexPath];
    
    static NSInteger imageViewTag = 1234;
    UIImageView *imageView = (UIImageView *)[cell.contentView viewWithTag:imageViewTag];
    
    if (!imageView) {
        imageView = [[UIImageView alloc] init];
        imageView.contentMode = UIViewContentModeScaleToFill;
        imageView.frame = cell.contentView.bounds;
        imageView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
        imageView.tag = imageViewTag;
        [cell.contentView addSubview:imageView];
    }
    
    Media *media = self.items[indexPath.row];
    imageView.image = media.image;
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    Media *media = self.items[indexPath.row];
    UIImage *image = media.image;
    return (CGRectGetWidth(self.view.frame) / image.size.width) * image.size.height;
}

// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}


// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
//        NSMutableArray *data = [[DataSource sharedInstance].mediaItems mutableCopy];
//        [data removeObjectAtIndex:indexPath.row];
        [[DataSource sharedInstance] deleteRow:indexPath.row];
        
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];

    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}


/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
