//
//  yourVersionViewController.h
//  yourVersion
//
//  Created by Mac on 2009/7/24.
//  Copyright __MyCompanyName__ 2009. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SBJSON.h"
//#import "browserController.h"

@interface yourVersionViewController : UIViewController <UIWebViewDelegate, UITabBarDelegate> {
	IBOutlet UIWebView *theWebView;
	IBOutlet UIWebView *theBrowser;
	IBOutlet UIView *loader;
	IBOutlet UIView *browserView;
	IBOutlet UIActivityIndicatorView *browserSpinner;
	IBOutlet UITabBar *theTabBar;
	IBOutlet UINavigationItem *topTitle;
	NSTimer *theTimer;
	NSMutableArray *labelsArray;
	NSArray *labels;
	IBOutlet UIPickerView *picker;
	IBOutlet UIView *pickerView;
	NSMutableDictionary *masterDictionary;
	NSString *dictPath;
	NSMutableDictionary *instructions;
	//BrowserController *browserController;
}
@property(nonatomic,assign) IBOutlet UIWebView *theWebView;
@property(nonatomic,assign) IBOutlet UIView *loader;
@property(nonatomic,assign) NSTimer *theTimer;
@property(nonatomic,assign) UIWebView *theBrowser;
@property(nonatomic,assign) UIView *browserView;
@property(nonatomic,assign) UIActivityIndicatorView *browserSpinner;
@property(nonatomic,assign) UITabBar * theTabBar;
@property(nonatomic,assign) UINavigationItem* topTitle;
@property(nonatomic,retain) NSMutableArray *labelsArray;
@property(nonatomic,retain) NSArray *labels;
@property(nonatomic,assign) UIPickerView *picker;
@property(nonatomic,assign) UIView *pickerView;
@property(nonatomic,retain) NSMutableDictionary *masterDictionary;
@property(nonatomic,retain) NSString *dictPath;
@property(nonatomic,retain) NSMutableDictionary *instructions;

//@property(nonatomic,assign) BrowserController *browserController;


-(IBAction)backClicked:(id)sender;
-(IBAction)backClicked2:(id)sender;
-(IBAction)composeClicked:(id)sender;
-(IBAction)cancelClicked:(id)sender;
-(IBAction)pickClicked:(id)sender;

@end

