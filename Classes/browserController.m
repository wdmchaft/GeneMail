//
//  BrowserController.m
//  Qfly
//
//  Created by Jonah Williams on 5/12/09.
//  Copyright 2009 Carbon Five. All rights reserved.
//

#import "BrowserController.h"

@implementation BrowserController

@synthesize webView, forwardButton, backButton;

 
- (IBAction) forward {
	[self.webView goForward];
}

- (IBAction) back {
	[self.webView goBack];
}

- (IBAction) reload {
	[self.webView reload];
}

- (IBAction) close {
	[self.webView stopLoading];
	[self dealloc];
	//[self.parentViewController dismissModalViewControllerAnimated:YES];
}

- (void) loadURL:(NSURL *)theURL {
	NSLog(@"attempting to load!");
	[self.webView loadRequest:[NSURLRequest requestWithURL:theURL]];
}

#pragma mark UIWebViewDelegate methods 

- (void)webViewDidStartLoad:(UIWebView *)webView {
	self.forwardButton.enabled = self.webView.canGoForward;
	self.backButton.enabled = self.webView.canGoBack;
}

- (void)webViewDidFinishLoad:(UIWebView *)webView {
	self.forwardButton.enabled = self.webView.canGoForward;
	self.backButton.enabled = self.webView.canGoBack;
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error {
}

- (void)dealloc {
	[webView release];
	[forwardButton release];
	[backButton release];
    [super dealloc];
}


@end
