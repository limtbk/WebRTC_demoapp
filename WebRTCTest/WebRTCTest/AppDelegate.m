//
//  AppDelegate.m
//  WebRTCTest
//
//  Created by lim on 10/24/14.
//  Copyright (c) 2014 Lohika. All rights reserved.
//

#import "AppDelegate.h"

#import "ViewController.h"
#import "RTCPeerConnectionFactory.h"

@implementation AppDelegate {
    UIWindow* _window;
}

#pragma mark - UIApplicationDelegate methods

- (BOOL)application:(UIApplication*)application
didFinishLaunchingWithOptions:(NSDictionary*)launchOptions {
    [RTCPeerConnectionFactory initializeSSL];
    _window =  [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    ViewController* viewController =
    [[ViewController alloc] init];
    _window.rootViewController = viewController;
    [_window makeKeyAndVisible];
    return YES;
}

- (void)applicationWillResignActive:(UIApplication*)application {
    [[self appRTCViewController] applicationWillResignActive:application];
}

- (void)applicationWillTerminate:(UIApplication*)application {
    [RTCPeerConnectionFactory deinitializeSSL];
}

#pragma mark - Private

- (ViewController*)appRTCViewController {
    return (ViewController*)_window.rootViewController;
}

@end
