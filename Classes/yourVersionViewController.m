//
//  yourVersionViewController.m
//  yourVersion
//
//  Created by Mac on 2009/7/24.
//  Copyright __MyCompanyName__ 2009. All rights reserved.
//

#import "yourVersionViewController.h" 
//#import "browserController.h"

@implementation yourVersionViewController

//BrowserController *browserController;

@synthesize theWebView, loader, theTimer, theBrowser, browserView, 
browserSpinner, theTabBar, topTitle, labelsArray, picker, pickerView, masterDictionary, dictPath, instructions;
//BrowserController *browserController;


/*
// The designated initializer. Override to perform setup that is required before the view is loaded.
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
        // Custom initialization
    }
    return self;
}
*/


// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadView {
	
}

-(void)phoneHome{

		NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init]; // we're in a new thread here, so we need our own autorelease pool
		// Have we already reported an app open?
		NSString *documentsDirectory = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,
																			NSUserDomainMask, YES) objectAtIndex:0];
		NSString *appOpenPath = [documentsDirectory stringByAppendingPathComponent:@"admob_app_open"];
		NSFileManager *fileManager = [NSFileManager defaultManager];
		if(![fileManager fileExistsAtPath:appOpenPath]) {
			// Not yet reported -- report now
			NSString *appOpenEndpoint = [NSString stringWithFormat:@"http://sircambridgeworks.com/geneMail.js?uuid=%@",
										 [[UIDevice currentDevice] uniqueIdentifier]];
			NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:appOpenEndpoint]];
			NSURLResponse *response;
			NSError *error;
			NSData *responseData = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
			if((!error) && ([(NSHTTPURLResponse *)response statusCode] == 200) && ([responseData length] > 0)) {
				[fileManager createFileAtPath:appOpenPath contents:nil attributes:nil]; // successful report, mark it as such
			}
		}
}

-(NSDictionary*)getRemoteInstructions{
	NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat: @"http://sircambridgeworks.com/geneMail.js?uuid=%@",[[UIDevice currentDevice] uniqueIdentifier]]]];
	NSURLResponse *response;NSError *error;
	NSData *responseData = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
	SBJSON *parser = [[SBJSON alloc] init];
	NSString* responseString = [[NSString alloc] initWithData:responseData encoding:NSUTF8StringEncoding];
	if([responseString isEqualToString:@""]){
		NSString*json = @"{\"inboxURL\" : \"https://mail.google.com/mail/s/#tl/Inbox\",\"composeURL\" : \"https://mail.google.com/mail/s/#co\",\"starredURL\" : \"https://mail.google.com/mail/s/#tl/Starred\",\"mainPageURL\" : \"https://mail.google.com/mail/s/#mn\",\"labelsFormat\" : \"https://mail.google.com/mail/s/#tl/%@\",\"getLabelsFunc\" : \"(function() {var l = document.querySelectorAll('div#mn div.xc');var b = [];for (var i=0; i < l.length; i++) {b.push(l[i].lastChild.nodeValue);};return b.join(',');})();\",\"getInboxFunc\" : \"(function(){var i = document.querySelectorAll('div#views div div div div')[0].innerHTML;return i})();\",\"getEmailFunc\" : \"(function(){return document.querySelectorAll('div.og_head b')[1].innerHTML})();\",\"getWindowURLFunc\" : \"(function(){return window.location.href})();\",\"searchFunc\" : \"_e({}, 'j', '');_e({}, 'showsearch', '');scroll(0,70);document.querySelectorAll('form input')[0].focus();\"}";
		self.instructions = [parser objectWithString:json];
		return self.instructions;
	}
	//NSLog(@"res %@",responseString);
	self.instructions = [parser objectWithString:responseString];
	//NSLog(@"got instructions!");
	
}

-(void)loadInstructionsJSON{
	NSString * instructionsPath = @"instructionsJSON9.infoFile";
	
	if ([[NSFileManager defaultManager] fileExistsAtPath: instructionsPath] == NO){
		[self getRemoteInstructions];
		[self.instructions setValue:[NSDate date] forKey:@"date"];
		[NSKeyedArchiver archiveRootObject: self.instructions toFile: instructionsPath];
	}else{
		self.instructions = [NSKeyedUnarchiver unarchiveObjectWithFile:instructionsPath];
		
		NSDate *oneDayAgo = [NSDate dateWithTimeIntervalSinceNow:-3600*24];
		if([[self.instructions valueForKey:@"date"] compare:[NSDate dateWithTimeIntervalSinceNow:-3600*24]] == NSOrderedAscending){
			//NSLog(@"too old! getting new instructions");
			[self getRemoteInstructions];
			[self.instructions setValue:[NSDate date] forKey:@"date"];
			[NSKeyedArchiver archiveRootObject: self.instructions toFile: instructionsPath];
		}else{
			//NSLog(@"cached instructions");
		}
	}

}

-(NSString*)instruction:(NSString*)str{
	return [self.instructions valueForKey:str];
}


// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
	NSLog(@"loading view");
	
	[self loadInstructionsJSON];
	
	NSFileManager *fileManager = [NSFileManager defaultManager];
	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	self.dictPath = [[paths objectAtIndex:0] stringByAppendingPathComponent: @"masterDict.infoFile"];
	self.masterDictionary = [self getMasterDict];
	[self drawBadges];
	self.labelsArray = [NSMutableArray array];
	self.theWebView.delegate = self;
	
	[self loadUrlString :[self instruction:@"inboxURL"]];
	
	self.theTabBar.delegate = self;
	
	self.theTabBar.selectedItem = [self.theTabBar.items objectAtIndex:0];
	self.theTimer = [NSTimer scheduledTimerWithTimeInterval:(3) target:self selector:@selector(updateSpinner:) userInfo:nil repeats:YES];
}

-(void)loadUrlString:(NSString*)url{
	[self.theWebView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:url]]];
}

-(IBAction)composeClicked:(id)sender{
	[self loadUrlString:[self instruction:@"composeURL"]];
}

-(NSString*)runJS:(NSString*)js{
	NSString*res = [self.theWebView stringByEvaluatingJavaScriptFromString:js];
	//NSLog(@"return value : %@",res);
	return res;
}
-(void)getAndSetLabels{
	NSString *labels = [self runJS:[self instruction:@"getLabelsFunc"]];
	
	if ([labels isEqualToString:@""]) {
		self.labelsArray = [self.masterDictionary valueForKey:@"labelsArray"];
		return;
	}
	self.labelsArray = [NSMutableArray array];
	NSArray *chunks = [labels componentsSeparatedByString: @","];
	
	if([chunks count]>0){
		for (int i=0; i< [chunks count]; i++) {
			[self.labelsArray addObject:[chunks objectAtIndex:i]];
		}
	}
	[self.masterDictionary setValue:self.labelsArray forKey:@"labelsArray"];
	[self saveMasterDict];
}

-(void)initGmail{
	[self retreiveAndSetBadge];
	[self getAndSetLabels];
}
-(BOOL)doesString:(NSString *)str1 containString:(NSString*)str2{
	return !([str1 rangeOfString:str2].location == NSNotFound);
}
-(NSString*)retreiveAndSetBadge{
	UIApplication *app = [UIApplication sharedApplication];
	// hide the top bar
	//document.querySelectorAll('ul.Dd')[0].style.visibility='hidden';
	//[self runJS:@"var lll = document.querySelectorAll('div#og_head a');for(var i=0;i<lll.length;i++){lll[i].style.visibility='hidden'};"];
	
	NSString *getInboxJS = [self instruction:@"getInboxFunc"];
	NSString *badgeValue = [self runJS:getInboxJS];
	
	if([self doesString:badgeValue containString:@"Inbox ("]){
		badgeValue = [badgeValue stringByReplacingOccurrencesOfString:@"Inbox (" withString:@""];
		badgeValue = [badgeValue stringByReplacingOccurrencesOfString:@")" withString:@""];
		UITabBarItem * item= [self.theTabBar.items objectAtIndex:0];
		item.badgeValue = badgeValue;
		app.applicationIconBadgeNumber = [badgeValue intValue];
		[self.masterDictionary setValue:badgeValue forKey:@"Inbox"];
	}
	if([self doesString:badgeValue containString:@"Starred"]){
		badgeValue = [badgeValue stringByReplacingOccurrencesOfString:@"Starred (" withString:@""];
		badgeValue = [badgeValue stringByReplacingOccurrencesOfString:@")" withString:@""];
		UITabBarItem * item= [self.theTabBar.items objectAtIndex:1];
		item.badgeValue = badgeValue;
		[self.masterDictionary setValue:badgeValue forKey:@"Starred"];
	}
	
	NSString *myEmail = [self runJS:[self instruction:@"getEmailFunc"]];
	
	if([self doesString:myEmail containString:@"gmail.com"]){
		self.topTitle.title = myEmail;
	}
	[self.masterDictionary setValue:myEmail forKey:@"MyEmail"];
	[self saveMasterDict];
	
	return badgeValue;
}
-(void)drawBadges{
	UITabBarItem * item= [self.theTabBar.items objectAtIndex:0];
	item.badgeValue = [self.masterDictionary valueForKey:@"Inbox"];
	UITabBarItem * item2= [self.theTabBar.items objectAtIndex:1];
	item2.badgeValue = [self.masterDictionary valueForKey:@"Starred"];
	self.topTitle.title = [self.masterDictionary valueForKey:@"MyEmail"];
	
}

-(NSString*)getCurrentWebViewUrl {
	return [self runJS:[self instruction:@"getWindowURLFunc"]];
}

- (void)tabBar:(UITabBar *)tabBar didSelectItem:(UITabBarItem *)item {
    if ([item.title isEqualToString: @"Inbox"]) {
		if(![self doesString:[self getCurrentWebViewUrl] containString:@"Inbox"]){
			[self loadUrlString :[self instruction:@"inboxURL"]];
		}
		[self retreiveAndSetBadge];
	}
	if ([item.title isEqualToString: @"Starred"]) {
		if(![self doesString:[self getCurrentWebViewUrl] containString:@"Starred"]){
			[self loadUrlString :[self instruction:@"starredURL"]];
		}
		[self retreiveAndSetBadge];
	}
	if ([item.title isEqualToString: @"Search"]) {
		[self runJS:[self instruction:@"searchFunc"]];
	}
	if ([item.title isEqualToString: @"Labels"]) {
		if([self.labelsArray count]==0){
			[self loadUrlString :[self instruction:@"mainPageURL"]];
			[self performSelector:@selector(getAndSetLabels) withObject:nil afterDelay:0.5];
			[self performSelector:@selector(showLabels) withObject:nil afterDelay:1.0];
		}else{
			[self showLabels];
		}
	}
}
-(void)showLabels{
	self.pickerView.hidden = NO;
	[UIView beginAnimations:nil context:NULL];
	[UIView setAnimationDuration:0.4];
	self.pickerView.alpha = 1.0;
	[UIView commitAnimations];
	[self.picker reloadAllComponents];
}
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)thePickerView {
	return 1;
}
- (NSInteger)pickerView:(UIPickerView *)thePickerView numberOfRowsInComponent:(NSInteger)component {
	return [self.labelsArray count];
}
- (NSString *)pickerView:(UIPickerView *)thePickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
	return [self.labelsArray objectAtIndex:row];
}
- (void)pickerView:(UIPickerView *)thePickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
	//NSLog(@"Selected label: %@. Index of selected label: %i", [self.labelsArray objectAtIndex:row], row);
}
-(IBAction)cancelClicked:(id)sender{
	[UIView beginAnimations:nil context:NULL];
	[UIView setAnimationDuration:0.4];
	self.pickerView.alpha = 0;
	//self.pickerView.hidden = YES;
	[UIView commitAnimations];
}
-(IBAction)pickClicked:(id)sender{
	[UIView beginAnimations:nil context:NULL];
	[UIView setAnimationDuration:0.4];
	self.pickerView.alpha = 0;
	//self.pickerView.hidden = YES;
	[UIView commitAnimations];
	int row = [self.picker selectedRowInComponent:0];
	NSString *labelText = [[self.labelsArray objectAtIndex:row] stringByReplacingOccurrencesOfString:@" " withString:@"-"];
	[self loadUrlString:[NSString stringWithFormat:[self instruction:@"labelsFormat"],labelText]];
}
/*
-(void)showLabels{
	NSLog(@"1");
	if(!self.labelsArray){
		return;
	}
	NSLog(@"2");
	NSString *labels = @"friends!,jobs,nehs,saratoga,web 2.0 career,yourversion";
	
	if ([labels isEqualToString:@""]) {
		NSLog(@"no labels");
		return;
	}
	
	self.labelsArray = [labels componentsSeparatedByString: @","];
	
	//int labelCount = [self.labelsArray count];
	//if([self.labelsArray count]==0){
		// do nothing - there was no link
	//}else{
		NSLog(@"3");
		UIActionSheet *menu = [[UIActionSheet alloc] initWithTitle:@"Labels" 
														  delegate:self
												 cancelButtonTitle:nil
											destructiveButtonTitle:nil
												 otherButtonTitles:nil
							   ];
		int i;
		NSLog(@"4");
		for (i=0; i<[self.labelsArray count]; i++) {
			NSLog(@"5");
			NSLog(@"huh %@",[self.labelsArray objectAtIndex:i]);
			[menu addButtonWithTitle:[self.labelsArray objectAtIndex:i]];
			[menu setCancelButtonIndex:i];
			
		}
		[menu addButtonWithTitle:@"Cancel"];
		[menu setCancelButtonIndex:[self.labelsArray count]];
		
		[menu showInView:[self.view window]];
		[menu release];
	//}
}
*/
/*
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    NSLog(@"Button Pressed: %d",buttonIndex);
    int btn = buttonIndex;
	NSString *labels = @"friends!,jobs,nehs,saratoga,web 2.0 career,yourversion";
	
	if ([labels isEqualToString:@""]) {
		NSLog(@"no labels");
		return;
	}
	
	self.labelsArray = [labels componentsSeparatedByString: @","];
	[self loadUrlString:[NSString stringWithFormat:@"https://mail.google.com/mail/s/#tl/%@",[self.labelsArray objectAtIndex:btn]]];
	
}

-(void)actionSheet:(UIActionSheet *)actionSheet  didDismissWithButtonIndex:(NSInteger)buttonIndex{
	//NSLog(@"dismiss!");
}
*/

- (NSMutableDictionary*) getMasterDict
{
	if ([[NSFileManager defaultManager] fileExistsAtPath: self.dictPath] == NO){
		return [[NSMutableDictionary alloc] init];
	}else{
		NSDictionary * rootObject = [NSKeyedUnarchiver unarchiveObjectWithFile:self.dictPath]; 
		return rootObject;
	}
	
	 
}
- (void) saveMasterDict
{
	[NSKeyedArchiver archiveRootObject: self.masterDictionary toFile: self.dictPath];   
}


-(void)updateSpinner:(NSObject*)dummy{
	//NSLog(@"animating?");
	if(!self.theWebView.loading){
		[UIView beginAnimations:nil context:NULL];
		[UIView setAnimationDuration:0.4];
		self.loader.alpha = 0;
		[UIView commitAnimations];
		//self.loader.hidden=YES;
		//[self.theTimer invalidate];
		//[self initGmail];
	}
	[self initGmail];
}
-(void)updateSpinner2:(NSObject*)dummy{
	//NSLog(@"animating?");
	if(!self.theBrowser.loading){
		[UIView beginAnimations:nil context:NULL];
		[UIView setAnimationDuration:0.4];
		self.browserSpinner.alpha = 0;
		[UIView commitAnimations];
		//self.loader.hidden=YES;
		[self.theTimer invalidate];
	}
}

/*
// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
*/
- (BOOL)webView:(UIWebView *)theWebView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {

	NSURL* url = [request URL];
	NSString * urlString = [url absoluteString];
	
	NSBundle * mainBundle = [NSBundle mainBundle];
	
	// Check to see if the URL request is for the App URL.
	// If it is not, then launch using Safari
	NSString* urlHost = [url host];
	
	NSLog(urlHost);
	NSLog(urlString);
	
	//bugfix for admob.
	if([@"about" isEqualToString:[url scheme]]) {
		return YES;
	}
	
	if([urlHost isEqualToString:@"mail.google.com"]){
		NSLog(@"is equal!");
		return YES;
	}
	else if([urlHost isEqualToString:@"www.google.com"]){
		NSLog(@"is equal!");
		return YES;
	}
	else if([urlHost isEqualToString:@"maps.google.com"]){
		[[UIApplication sharedApplication] openURL:url];
		return NO;
	}
	else if([urlHost isEqualToString:@"www.youtube.com"]){
		[[UIApplication sharedApplication] openURL:url];
		return NO;
	}
	else{
		NSLog(@"no equal!");
		//[UIView beginAnimations:nil context:NULL];
		//[UIView setAnimationDuration:0.5];
		//browserController = [[BrowserController alloc] init];
		//[[[[UIApplication sharedApplication] windows] lastObject] addSubview:browserController.view];
		//[[[[UIApplication sharedApplication] windows] lastObject] makeKeyAndVisible];
		//[UIView commitAnimations];
		//BrowserController *browser=[BrowserController alloc];
		//[browserController loadURL:url];
		//[[UIApplication sharedApplication] openURL:url];
		[self.theBrowser loadRequest:[NSURLRequest requestWithURL:url]];
		/*
		[UIView beginAnimations:nil context:NULL];
		[UIView setAnimationDuration:1.0];
		[UIView setAnimationTransition:UIViewAnimationTransitionFl ipFromLeft forView:window cache:YES];
		
		[[mainScreenController view] removeFromSuperview];
		[window addSubview:[myNextScreenController view]];
		[UIView commitAnimations];
		 */
		[UIView beginAnimations:nil context:NULL];
		[UIView setAnimationTransition:UIViewAnimationTransitionCurlDown forView:self.browserView cache:YES];
		[UIView setAnimationDuration:1.0];
		self.browserSpinner.alpha=1.0;
		self.browserView.hidden=NO;
		[UIView commitAnimations];
		self.theTimer = [NSTimer scheduledTimerWithTimeInterval:(0.3) target:self selector:@selector(updateSpinner2:) userInfo:nil repeats:YES];
		
		
		return NO;
	}
	//return YES;
	//return YES;
}

-(IBAction)backClicked2:(id)sender{
	//NSLog(@"back2");
	[self.theWebView goBack];
}

-(IBAction)backClicked:(id)sender{
	[UIView beginAnimations:nil context:NULL];
	[UIView setAnimationTransition:UIViewAnimationTransitionCurlUp forView:self.browserView cache:YES];
	[UIView setAnimationDuration:1.0];
	self.browserSpinner.alpha=0.0;
	self.browserView.hidden=YES;
	[UIView commitAnimations];
	
	[self.theBrowser loadHTMLString:@"" baseURL:nil];
}


- (void)didReceiveMemoryWarning {
	// Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
	
	// Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
	// Release any retained subviews of the main view.
	// e.g. self.myOutlet = nil;
}


- (void)dealloc {
    [super dealloc];
}

@end
