//
//  yourVersionAppDelegate.h
//  yourVersion
//
//  Created by Mac on 2009/7/24.
//  Copyright __MyCompanyName__ 2009. All rights reserved.
//

#import <UIKit/UIKit.h>

@class yourVersionViewController;

@interface yourVersionAppDelegate : NSObject <UIApplicationDelegate> {
    UIWindow *window;
    yourVersionViewController *viewController;
	BOOL _isDataSourceAvailable;
}

@property (nonatomic, retain) IBOutlet UIWindow *window;
@property (nonatomic, retain) IBOutlet yourVersionViewController *viewController;

@end

