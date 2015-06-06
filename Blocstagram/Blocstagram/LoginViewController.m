//
//  LoginViewController.m
//  Blocstagram
//
//  Created by Yong Jun on 5/17/15.
//  Copyright (c) 2015 Yong Jun. All rights reserved.
//

#import "LoginViewController.h"
#import "DataSource.h"

@interface LoginViewController () <UIWebViewDelegate>

@property (nonatomic, weak) UIWebView *webView;

@end

@implementation LoginViewController

NSString *const LoginViewControllerDidGetAccessTokenNotification = @"LoginViewControllerDidGetAccessTokenNotification";

- (void)loadView {
    [super viewDidLoad];
    
    UIWebView *webView = [[UIWebView alloc] init];
    webView.delegate = self;
    
    self.webView = webView;
    self.view = webView;

    [self.navigationItem setTitle:@"Instagram Login"];
    

}

- (void)viewDidLoad {
    
    NSString *urlString = [NSString stringWithFormat:@"https://instagram.com/oauth/authorize/?client_id=%@&scope-likes+comments+relationships&redirect_uri=%@&response_type=token", [DataSource instagramClientId], [self redirectURI]];
    
    NSURL *url = [NSURL URLWithString:urlString];
    
    if (url) {
        NSURLRequest *request = [NSURLRequest requestWithURL:url];
        [self.webView loadRequest:request];
    
    }
}

- (void)dealloc {
    [self clearInstagramCookies];
    self.webView.delegate = nil;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidLayoutSubviews {
    self.view.frame = self.view.bounds;
}

- (NSString *)redirectURI {
    return @"http://bloc.io";
}

- (void) clearInstagramCookies {
    for (NSHTTPCookie *cookie in [[NSHTTPCookieStorage sharedHTTPCookieStorage] cookies]) {
        NSRange domainRange = [cookie.domain rangeOfString:@"instagram.com"];
        if (domainRange.location != NSNotFound) {
            [[NSHTTPCookieStorage sharedHTTPCookieStorage] deleteCookie:cookie];
        }
    }
}

//- (void) updateBackButton {
//    if ([self.webView canGoBack]) {
//        if (!self.navigationItem.leftBarButtonItem) {
//            [self.navigationItem setHidesBackButton:YES animated:NO];
//            UIBarButtonItem *backButton = [[UIBarButtonItem alloc] initWithTitle:@"< Login" style:UIBarButtonItemStylePlain target:self action:@selector(backButtonClicked)];
//            self.navigationItem.leftBarButtonItem = backButton;
//        } 
//    } else {
//        [self.navigationItem setLeftBarButtonItem:nil animated:YES];
//    }
//}
//
//- (void) backButtonClicked {
//    if ([self.webView canGoBack]) {
//        [self.webView goBack];
//    }
//}

#pragma mark - UIWebView delegate methods

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
    NSString *urlString = request.URL.absoluteString;
    
    if ([urlString hasPrefix:[self redirectURI]]) {
        // This contains our auth token
        NSRange rangeOfAccessTokenParameter = [urlString rangeOfString:@"access_token="];
        NSUInteger indexOfTokenStarting = rangeOfAccessTokenParameter.location + rangeOfAccessTokenParameter.length;
        NSString *accessToken = [urlString substringFromIndex:indexOfTokenStarting];
        
        // posts notification for other classes that are observing
        [[NSNotificationCenter defaultCenter] postNotificationName:LoginViewControllerDidGetAccessTokenNotification object:accessToken];
        return NO;
    }
    
    return YES;
}

//- (void)webViewDidStartLoad:(UIWebView *)webView {
//    [self updateBackButton];
//}

//- (void)webViewDidFinishLoad:(UIWebView *)webView {
//    [self updateBackButton];
//}

@end
