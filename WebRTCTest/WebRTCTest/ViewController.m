//
//  ViewController.m
//  WebRTCTest
//
//  Created by lim on 10/24/14.
//  Copyright (c) 2014 Lohika. All rights reserved.
//

#import "ViewController.h"

#import <AVFoundation/AVFoundation.h>
#import "APPRTCConnectionManager.h"
#import "RTCEAGLVideoView.h"

static CGFloat const kLocalViewPadding = 20;

@interface ViewController ()<APPRTCConnectionManagerDelegate, APPRTCLogger, RTCEAGLVideoViewDelegate>
@property(nonatomic, assign) UIInterfaceOrientation statusBarOrientation;
@property(nonatomic, strong) RTCEAGLVideoView* localVideoView;
@property(nonatomic, strong) RTCEAGLVideoView* remoteVideoView;
@end

@implementation ViewController {
    APPRTCConnectionManager* _connectionManager;
    CGSize _localVideoSize;
    CGSize _remoteVideoSize;
}

- (instancetype)initWithNibName:(NSString*)nibName
                         bundle:(NSBundle*)bundle {
    if (self = [super initWithNibName:nibName bundle:bundle]) {
        _connectionManager =
        [[APPRTCConnectionManager alloc] initWithDelegate:self
                                                   logger:self];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.remoteVideoView =
    [[RTCEAGLVideoView alloc] initWithFrame:self.blackView.bounds];
    self.remoteVideoView.delegate = self;
    self.remoteVideoView.transform = CGAffineTransformMakeScale(-1, 1);
    [self.blackView addSubview:self.remoteVideoView];
    
    self.localVideoView =
    [[RTCEAGLVideoView alloc] initWithFrame:self.blackView.bounds];
    self.localVideoView.delegate = self;
    [self.blackView addSubview:self.localVideoView];
    
    self.statusBarOrientation =
    [UIApplication sharedApplication].statusBarOrientation;
    self.roomInput.delegate = self;
    [self.roomInput becomeFirstResponder];
}

- (void)viewDidLayoutSubviews {
    if (self.statusBarOrientation !=
        [UIApplication sharedApplication].statusBarOrientation) {
        self.statusBarOrientation =
        [UIApplication sharedApplication].statusBarOrientation;
        [[NSNotificationCenter defaultCenter]
         postNotificationName:@"StatusBarOrientationDidChange"
         object:nil];
    }
}

- (void)applicationWillResignActive:(UIApplication*)application {
    [self logMessage:@"Application lost focus, connection broken."];
    [self disconnect];
}

#pragma mark - APPRTCConnectionManagerDelegate

- (void)connectionManager:(APPRTCConnectionManager*)manager
didReceiveLocalVideoTrack:(RTCVideoTrack*)localVideoTrack {
    self.localVideoView.hidden = NO;
    self.localVideoView.videoTrack = localVideoTrack;
}

- (void)connectionManager:(APPRTCConnectionManager*)manager
didReceiveRemoteVideoTrack:(RTCVideoTrack*)remoteVideoTrack {
    self.remoteVideoView.videoTrack = remoteVideoTrack;
}

- (void)connectionManagerDidReceiveHangup:(APPRTCConnectionManager*)manager {
    [self showAlertWithMessage:@"Remote hung up."];
    [self disconnect];
}

- (void)connectionManager:(APPRTCConnectionManager*)manager
      didErrorWithMessage:(NSString*)message {
    [self showAlertWithMessage:message];
    [self disconnect];
}

#pragma mark - APPRTCLogger

- (void)logMessage:(NSString*)message {
    dispatch_async(dispatch_get_main_queue(), ^{
        NSString* output =
        [NSString stringWithFormat:@"%@\n%@", self.logView.text, message];
        self.logView.text = output;
        [self.logView
         scrollRangeToVisible:NSMakeRange([self.logView.text length], 0)];
    });
}

#pragma mark - RTCEAGLVideoViewDelegate

- (void)videoView:(RTCEAGLVideoView*)videoView
didChangeVideoSize:(CGSize)size {
    if (videoView == self.localVideoView) {
        _localVideoSize = size;
    } else if (videoView == self.remoteVideoView) {
        _remoteVideoSize = size;
    } else {
        NSParameterAssert(NO);
    }
    [self updateVideoViewLayout];
}

#pragma mark - UITextFieldDelegate

- (void)textFieldDidEndEditing:(UITextField*)textField {
    NSString* room = textField.text;
    if ([room length] == 0) {
        return;
    }
    textField.hidden = YES;
    self.instructionsView.hidden = YES;
    self.logView.hidden = NO;
    NSString* url =
    [NSString stringWithFormat:@"https://apprtc.appspot.com/?r=%@", room];
    [_connectionManager connectToRoomWithURL:[NSURL URLWithString:url]];
    [self setupCaptureSession];
}

- (BOOL)textFieldShouldReturn:(UITextField*)textField {
    // There is no other control that can take focus, so manually resign focus
    // when return (Join) is pressed to trigger |textFieldDidEndEditing|.
    [textField resignFirstResponder];
    return YES;
}

#pragma mark - Private

- (void)disconnect {
    [self resetUI];
    [_connectionManager disconnect];
}

- (void)showAlertWithMessage:(NSString*)message {
    UIAlertView* alertView = [[UIAlertView alloc] initWithTitle:nil
                                                        message:message
                                                       delegate:nil
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
    [alertView show];
}

- (void)resetUI {
    [self.roomInput resignFirstResponder];
    self.roomInput.text = nil;
    self.roomInput.hidden = NO;
    self.instructionsView.hidden = NO;
    self.logView.hidden = YES;
    self.logView.text = nil;
    self.localVideoView.videoTrack = nil;
    self.remoteVideoView.videoTrack = nil;
    self.blackView.hidden = YES;
}

- (void)setupCaptureSession {
    self.blackView.hidden = NO;
    [self updateVideoViewLayout];
}

- (void)updateVideoViewLayout {
    // TODO(tkchin): handle rotation.
    CGSize defaultAspectRatio = CGSizeMake(4, 3);
    CGSize localAspectRatio = CGSizeEqualToSize(_localVideoSize, CGSizeZero) ?
    defaultAspectRatio : _localVideoSize;
    CGSize remoteAspectRatio = CGSizeEqualToSize(_remoteVideoSize, CGSizeZero) ?
    defaultAspectRatio : _remoteVideoSize;
    
    CGRect remoteVideoFrame =
    AVMakeRectWithAspectRatioInsideRect(remoteAspectRatio,
                                        self.blackView.bounds);
    self.remoteVideoView.frame = remoteVideoFrame;
    
    CGRect localVideoFrame =
    AVMakeRectWithAspectRatioInsideRect(localAspectRatio,
                                        self.blackView.bounds);
    localVideoFrame.size.width = localVideoFrame.size.width / 3;
    localVideoFrame.size.height = localVideoFrame.size.height / 3;
    localVideoFrame.origin.x = CGRectGetMaxX(self.blackView.bounds)
    - localVideoFrame.size.width - kLocalViewPadding;
    localVideoFrame.origin.y = CGRectGetMaxY(self.blackView.bounds)
    - localVideoFrame.size.height - kLocalViewPadding;
    self.localVideoView.frame = localVideoFrame;
}

@end
