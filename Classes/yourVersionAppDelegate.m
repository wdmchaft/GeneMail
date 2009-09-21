//
//  yourVersionAppDelegate.m
//  yourVersion
//
//  Created by Mac on 2009/7/24.
//  Copyright __MyCompanyName__ 2009. All rights reserved.
//

#import "yourVersionAppDelegate.h"
#import "yourVersionViewController.h"
#import "browserController.h"
#import <SystemConfiguration/SystemConfiguration.h>

@implementation yourVersionAppDelegate

@synthesize window;
@synthesize viewController;


- (void)applicationDidFinishLaunching:(UIApplication *)application {    
    
    // Override point for customization after app launch    
    [window addSubview:viewController.view];
    [window makeKeyAndVisible];
	if([self isDataSourceAvailable]){
		//[self runQuery:nil];
		//if([sCellNetwork isEqualToString: @"YES"]){
			//NSString * message = @"You are on cellular mode! video quality will be reduced to a lower bandwidth, 3gp version.";
			//UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"Cellular mode!" message:message delegate:self cancelButtonTitle:nil otherButtonTitles:@"OK",nil];
			//[alert show];[alert release];
		//}
	}else{
		UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"No Network" message:@"No network was detected, please try the app again later." delegate:self cancelButtonTitle:nil otherButtonTitles:@"OK",nil];
		[alert show];[alert release];
	}
}

- (BOOL)isDataSourceAvailable
{
	//NSLog(@"checking is data source is available");
    static BOOL checkNetwork = YES;
    if (checkNetwork) { // Since checking the reachability of a host can be expensive, cache the result and perform the reachability check once.
        checkNetwork = NO;
        
        Boolean success;    
        const char *host_name = "google.com";
		
        SCNetworkReachabilityRef reachability = SCNetworkReachabilityCreateWithName(NULL, host_name);
        SCNetworkReachabilityFlags flags;
        success = SCNetworkReachabilityGetFlags(reachability, &flags);
        _isDataSourceAvailable = success && (flags & kSCNetworkFlagsReachable) && !(flags & kSCNetworkFlagsConnectionRequired);
		
		if(!_isDataSourceAvailable){
			//try again, just to be sure
			SCNetworkReachabilityRef reachability = SCNetworkReachabilityCreateWithName(NULL, host_name);
			SCNetworkReachabilityFlags flags;
			success = SCNetworkReachabilityGetFlags(reachability, &flags);
			_isDataSourceAvailable = success && (flags & kSCNetworkFlagsReachable) && !(flags & kSCNetworkFlagsConnectionRequired);
		}
		
		if (flags & kSCNetworkReachabilityFlagsIsWWAN){
			//sCellNetwork = @"YES";
			NSLog(@"cell mode!");
		}
		
		else{
			//sCellNetwork = @"NO";
			NSLog(@"wifi mode!");
		}
		
        CFRelease(reachability);
    }
	NSLog(@"checking if data source is available - done");
    return _isDataSourceAvailable;
}



- (void)dealloc {
    [viewController release];
    [window release];
    [super dealloc];
}


@end
