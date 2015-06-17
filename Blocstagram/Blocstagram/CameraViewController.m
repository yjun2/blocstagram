//
//  CameraViewController.m
//  Blocstagram
//
//  Created by Yong Jun on 6/11/15.
//  Copyright (c) 2015 Yong Jun. All rights reserved.
//

#import "CameraViewController.h"
#import "CameraToolbar.h"
#import "UIView+ImageUtilities.h"
#import "CropBox.h"
#import "ImageLibraryViewController.h"
#import <AVFoundation/AVFoundation.h>

@interface CameraViewController () <CameraToolbarDelegate, UIAlertViewDelegate, ImageLibraryViewControllerDelegate>

@property (nonatomic, strong) UIView *imagePreview;

@property (nonatomic, strong) AVCaptureSession *session;
@property (nonatomic, strong) AVCaptureVideoPreviewLayer *captureVideoPreviewLayer;
@property (nonatomic, strong) AVCaptureStillImageOutput *stillImageOutput;

@property (nonatomic, strong) UIToolbar *topView;
@property (nonatomic, strong) UIToolbar *bottomView;

@property (nonatomic, strong) CropBox *cropBox;
@property (nonatomic, strong) CameraToolbar *cameraToolbar;

@end

@implementation CameraViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self createViews];
    [self addViewsToViewHierarchy];
    [self setupImageCapture];
    [self createCancelButton];
}

- (void)viewWillLayoutSubviews {
    [super viewWillLayoutSubviews];
    
    CGFloat width = CGRectGetWidth(self.view.bounds);
    self.topView.frame = CGRectMake(0, self.topLayoutGuide.length, width, 44);
    
    CGFloat yOriginOfBottomView = CGRectGetMaxY(self.topView.frame) + width;
    CGFloat heightOfBottomView = CGRectGetHeight(self.view.frame) - yOriginOfBottomView;
    
    self.bottomView.frame = CGRectMake(0, yOriginOfBottomView, width, heightOfBottomView);
    self.cropBox.frame = CGRectMake(0, CGRectGetMaxX(self.topView.frame), width, width);
    self.imagePreview.frame = self.view.bounds;
    self.captureVideoPreviewLayer.frame = self.imagePreview.bounds;
    
    CGFloat cameraToolbarHeight = 100;
    self.cameraToolbar.frame = CGRectMake(0, CGRectGetHeight(self.view.bounds) - cameraToolbarHeight, width, cameraToolbarHeight);
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Create Views

- (void) createViews {
    self.imagePreview = [UIView new];
    self.topView = [UIToolbar new];
    self.cropBox = [CropBox new];
    self.bottomView = [UIToolbar new];
    
    NSArray *imageArray = @[@"rotate", @"road"];
    self.cameraToolbar = [[CameraToolbar alloc] initWithImageNames:imageArray];
    self.cameraToolbar.delegate = self;
    
    UIColor *whiteBG = [UIColor colorWithWhite:1.0 alpha:.15];
    self.topView.barTintColor = whiteBG;
    self.bottomView.barTintColor = whiteBG;
    self.topView.alpha = 0.5;
    self.bottomView.alpha = 0.5;
}

- (void) addViewsToViewHierarchy {
    NSMutableArray *views = [@[self.imagePreview, self.cropBox, self.topView, self.bottomView] mutableCopy];
    [views addObject:self.cameraToolbar];
    
    for (UIView *view in views) {
        [self.view addSubview:view];
    }
}

- (void) createCancelButton {
    UIImage *cancelImage = [UIImage imageNamed:@"x"];
    UIBarButtonItem *cancelButton = [[UIBarButtonItem alloc] initWithImage:cancelImage style:UIBarButtonItemStyleDone target:self action:@selector(cancelPressed:)];
    self.navigationItem.leftBarButtonItem = cancelButton;
}

#pragma mark - Configuring Image Capture

- (void) setupImageCapture {
    
    self.session = [[AVCaptureSession alloc] init];
    self.session.sessionPreset = AVCaptureSessionPresetHigh;
    
    self.captureVideoPreviewLayer = [[AVCaptureVideoPreviewLayer alloc] initWithSession:self.session];
    self.captureVideoPreviewLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
    
    self.captureVideoPreviewLayer.masksToBounds = YES;
    [self.imagePreview.layer addSublayer:self.captureVideoPreviewLayer];
    
    [AVCaptureDevice requestAccessForMediaType:AVMediaTypeVideo
                             completionHandler:^(BOOL granted) {
                                 dispatch_async(dispatch_get_main_queue(), ^{
                                     if (granted) {
                                         AVCaptureDevice *device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
                                         
                                         NSError *error = nil;
                                         AVCaptureDeviceInput *input = [AVCaptureDeviceInput deviceInputWithDevice:device error:&error];
                                         
                                         if (!input) {
//                                             UIAlertController *alertVC = [UIAlertController alertControllerWithTitle:error.localizedDescription
//                                                                                                              message:error.localizedRecoverySuggestion
//                                                                                                       preferredStyle:UIAlertControllerStyleAlert];
//                                             [alertVC addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
//                                                 [self.delegate cameraViewController:self didCompleteWithImage:nil];
//                                             }]];
//
                                             
//                                             [self presentViewController:alertVC animated:YES completion:nil];
                                             
                                             [self showAlertController:error.localizedDescription message:error.localizedRecoverySuggestion actionTitle:@"OK"];
                                             
                                         } else {
                                             [self.session addInput:input];
                                             self.stillImageOutput = [[AVCaptureStillImageOutput alloc] init];
                                             self.stillImageOutput.outputSettings = @{AVVideoCodecKey:AVVideoCodecJPEG};
                                             
                                             [self.session addOutput:self.stillImageOutput];
                                             [self.session startRunning];
                                         }
                                    
                                     } else {
//                                         UIAlertController *alertVC = [UIAlertController alertControllerWithTitle:@"Camera Permission Denied" message:@"This app deosn't have permission to use the camera; please update your privacy settings" preferredStyle:UIAlertControllerStyleAlert];
//                                         
//                                         [alertVC addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
//                                             [self.delegate cameraViewController:self didCompleteWithImage:nil];
//                                         }]];
                                         
//                                         [self presentViewController:alertVC animated:YES completion:nil];
                                         
                                         [self showAlertController:@"Camera Permission Denied" message:@"This app deosn't have permission to use the camera; please update your privacy settings" actionTitle:@"OK"];
                                     }
                                 });
                             }];
    
}

#pragma mark - CameraToolbarDelegate

- (void)leftButtonPressedOnToolbar:(CameraToolbar *)toolbar {
    AVCaptureDeviceInput *currentCameraInput = self.session.inputs.firstObject;
    
    NSArray *devices = [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo];
    if (devices.count > 1) {
        NSUInteger currentIndex = [devices indexOfObject:currentCameraInput.device];
        NSUInteger newIndex = 0;
        
        if (currentIndex < devices.count - 1) {
            newIndex = currentIndex + 1;
        }
        
        AVCaptureDevice *newCamera = devices[newIndex];
        AVCaptureDeviceInput *newVideoInput = [[AVCaptureDeviceInput alloc] initWithDevice:newCamera error:nil];
        
        if (newVideoInput) {
            UIView *fakeView = [self.imagePreview snapshotViewAfterScreenUpdates:YES];
            fakeView.frame = self.imagePreview.frame;
            [self.view insertSubview:fakeView aboveSubview:self.imagePreview];
            
            [self.session beginConfiguration];
            [self.session removeInput:currentCameraInput];
            [self.session addInput:newVideoInput];
            [self.session commitConfiguration];
            
            [UIView animateWithDuration:0.2 delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
                fakeView.alpha = 0;
            } completion:^(BOOL finished) {
                [fakeView removeFromSuperview];
            }];
        }
    }
}

- (void)rightButtonPressedOnToolbar:(CameraToolbar *)toolbar {
    ImageLibraryViewController *imageLibraryVC = [[ImageLibraryViewController alloc] init];
    imageLibraryVC.delegate = self;
    [self.navigationController pushViewController:imageLibraryVC animated:YES];

}

- (void)cameraButtonPressedOnToolbar:(CameraToolbar *)toolbar {
    AVCaptureConnection *videoConnection;
    
    // Find the right connection object
    for (AVCaptureConnection *connection in self.stillImageOutput.connections) {
        for (AVCaptureInputPort *port in connection.inputPorts) {
            if ([port.mediaType isEqual:AVMediaTypeVideo]) {
                videoConnection = connection;
                break;
            }
        }
        if (videoConnection) { break; }
    }
    
    [self.stillImageOutput captureStillImageAsynchronouslyFromConnection:videoConnection completionHandler: ^(CMSampleBufferRef imageSampleBuffer, NSError *error) {
        if (imageSampleBuffer) {
            NSData *imageData = [AVCaptureStillImageOutput jpegStillImageNSDataRepresentation:imageSampleBuffer];
            UIImage *image = [UIImage imageWithData:imageData scale:[UIScreen mainScreen].scale];
            image = [image imageWithFixedOrientation];
            image = [image imageResizedToMatchAspectRatioOfSize:self.captureVideoPreviewLayer.bounds.size];
            
            CGRect gridRect = self.cropBox.frame;
            CGRect cropRect = gridRect;
            cropRect.origin.x = (CGRectGetMinX(gridRect) + (image.size.width - CGRectGetWidth(gridRect)) / 2);
            
            image = [image imageCroppedToRect:cropRect];
//            image = [image imageByScalingToSize:self.captureVideoPreviewLayer.bounds.size andCroppingWithRect:cropRect];
            
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.delegate cameraViewController:self didCompleteWithImage:image];
            });
        } else {
            dispatch_async(dispatch_get_main_queue(), ^{
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:error.localizedDescription message:error.localizedRecoverySuggestion delegate:nil cancelButtonTitle:NSLocalizedString(@"OK", @"OK button") otherButtonTitles:nil];
                [alert show];
            });
            
        }
    }];
}

- (void) showAlertController:(NSString *)alertTitle
                                    message:(NSString *)message
                                actionTitle:(NSString *)actionTitle {
    UIAlertController *alertVC = [UIAlertController alertControllerWithTitle:alertTitle
                                                                     message:message
                                                              preferredStyle:UIAlertControllerStyleAlert];
    
    [alertVC addAction:[UIAlertAction actionWithTitle:@"OK"
                                                style:UIAlertActionStyleCancel
                                              handler:^(UIAlertAction *action) {
        [self.delegate cameraViewController:self didCompleteWithImage:nil];
    }]];
    
    [self presentViewController:alertVC animated:YES completion:nil];
}

- (void) imageLibraryViewController:(ImageLibraryViewController *)imageLibraryViewController didCompleteWithImage:(UIImage *)image {
    [self.delegate cameraViewController:self didCompleteWithImage:image];
}

#pragma mark - even handling

- (void)cancelPressed:(UIBarButtonItem *)sender {
    [self.delegate cameraViewController:self didCompleteWithImage:nil];
}
@end
