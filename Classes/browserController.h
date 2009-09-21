//
//  BrowserController.h
//  Qfly
//
//  Created by Jonah Williams on 5/12/09.
//  Copyright 2009 Carbon Five. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface BrowserController : UIViewController <UIWebViewDelegate> {
	IBOutlet UIWebView *webView;
	IBOutlet UIButton *forwardButton;
	IBOutlet UIButton *backButton;
}

@property(nonatomic, retain) UIWebView *webView;
@property(nonatomic, retain) UIButton *forwardButton;
@property(nonatomic, retain) UIButton *backButton;

- (IBAction) forward;
- (IBAction) back;
- (IBAction) reload;
- (IBAction) close;
- (void) loadURL:(NSURL *)theURL;

@end
