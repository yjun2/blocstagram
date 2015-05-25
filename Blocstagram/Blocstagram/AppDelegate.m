//
//  AppDelegate.m
//  Blocstagram
//
//  Created by Yong Jun on 5/3/15.
//  Copyright (c) 2015 Yong Jun. All rights reserved.
//

#import "AppDelegate.h"
#import "ImagesTableViewController.h"
#import "DataSource.h"
#import "LoginViewController.h"

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    
    // Override point for customization after application launch.
    self.window.backgroundColor = [UIColor whiteColor];

    [DataSource sharedInstance];
    UINavigationController *navVC = [[UINavigationController alloc] init];
    
    // if no access token, set to the LoginViewController
    if (![DataSource sharedInstance].accessToken) {
        LoginViewController *loginVC = [[LoginViewController alloc] init];
        [navVC setViewControllers:@[loginVC] animated:YES];
    
        [[NSNotificationCenter defaultCenter] addObserverForName:LoginViewControllerDidGetAccessTokenNotification object:nil queue:nil usingBlock:^(NSNotification *note) {
            ImagesTableViewController *imageVC = [[ImagesTableViewController alloc] init];
            [navVC setViewControllers:@[imageVC] animated:YES];
        }];
    } else { // if there is access token, just go to the ImageTableViewConroller directly
        ImagesTableViewController *imageVC = [[ImagesTableViewController alloc] init];
        [navVC setViewControllers:@[imageVC] animated:YES];
    }
    
    self.window.rootViewController = navVC;
    
    [self.window makeKeyAndVisible];
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
