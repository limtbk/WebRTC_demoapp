//
//  ViewController.h
//  WebRTCTest
//
//  Created by lim on 10/24/14.
//  Copyright (c) 2014 Lohika. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ViewController : UIViewController<UITextFieldDelegate>

@property(weak, nonatomic) IBOutlet UITextField* roomInput;
@property(weak, nonatomic) IBOutlet UITextView* instructionsView;
@property(weak, nonatomic) IBOutlet UITextView* logView;
@property(weak, nonatomic) IBOutlet UIView* blackView;

- (void)applicationWillResignActive:(UIApplication*)application;

@end
