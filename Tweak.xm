#import "Headers.h"

static NSString *kMacroTitle = @"_TITLE_";
static NSString *kMacroSource = @"_SOURCE_";
static NSString *kMacroURL = @"_URL";


#pragma mark -
#pragma mark Format (Twitter, Facebook)

static NSString *gTitle;
static NSString *gSrcTitle;
static NSString *gUrl;
static BOOL moveToTop;
static NSString *format;


%hook ShareController
- (void)share:(RKShareObject *)object inView:(id)arg2
{
	%orig;
	gTitle = [object title];
	gSrcTitle = [object srcTitle];
	gUrl = (NSString *)[object url];
}

- (void)__didClose
{
	%orig;
}

- (void)tapClose:(id)arg1
{
	%orig;
}
%end


@interface WebViewController
@property(readonly) id webView;
@end


%hook RKServiceTwitter
- (void)share:(RKShareObject *)object
{
	NSString *cStr = [format stringByReplacingOccurrencesOfString:kMacroTitle withString:gTitle];
	cStr = [cStr stringByReplacingOccurrencesOfString:kMacroSource withString:gSrcTitle];

	UIWindow *window = [[UIApplication sharedApplication] keyWindow];
	id viewController = window.rootViewController;

	if (moveToTop) {
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleKeyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
	}

	if (kCFCoreFoundationVersionNumber >= kCFCoreFoundationVersionNumber_iOS_6_0) {
		SLComposeViewController *twitterPostVC = [SLComposeViewController composeViewControllerForServiceType:SLServiceTypeTwitter];
		[twitterPostVC setInitialText:cStr];
		[twitterPostVC addURL:[NSURL URLWithString:gUrl]];
		[viewController presentViewController:twitterPostVC animated:YES completion:nil];
	}
	else if (kCFCoreFoundationVersionNumber >= kCFCoreFoundationVersionNumber_iOS_5_0) {
		TWTweetComposeViewController *twitterPostVC = [[TWTweetComposeViewController alloc] init];
		[twitterPostVC setInitialText:cStr];
		[twitterPostVC addURL:[NSURL URLWithString:gUrl]];
		[viewController presentModalViewController:twitterPostVC animated:YES];
	}
}

%new(v@:@)
- (void)handleKeyboardWillShow:(NSNotification *)notification
{
	[[NSNotificationCenter defaultCenter] removeObserver:self];
	UITextView *textView = (UITextView *)[[[UIApplication sharedApplication] keyWindow] findFirstResponder];
	[textView setSelectedRange:NSMakeRange(0, 0)];
}
%end

%hook RKServiceFacebook
- (void)share:(RKShareObject *)object
{
	NSString *cStr = [format stringByReplacingOccurrencesOfString:kMacroTitle withString:gTitle];
	cStr = [cStr stringByReplacingOccurrencesOfString:kMacroSource withString:gSrcTitle];

	UIWindow *window = [UIApplication sharedApplication].keyWindow;
	id viewController = window.rootViewController;

	SLComposeViewController *facebookPostVC = [SLComposeViewController composeViewControllerForServiceType:SLServiceTypeFacebook];    
	[facebookPostVC setInitialText:cStr];
	[facebookPostVC addURL:[NSURL URLWithString:gUrl]];
	[viewController presentViewController:facebookPostVC animated:YES completion:nil];
}
%end


#pragma mark Format (App.net, Buffer, etc.)

%hook RSForm
- (NSString *)text
{
	NSString *cStr = [format stringByReplacingOccurrencesOfString:kMacroTitle withString:gTitle];
	cStr = [cStr stringByReplacingOccurrencesOfString:kMacroSource withString:gSrcTitle];

	if ( !self.quote || [self.quote isEqualToString:NULL] ) {
		cStr = [cStr stringByAppendingString:[NSString stringWithFormat:@" %@", gUrl]];
	}

	return cStr;
}
%end


#pragma mark Format (Mail Link)

static NSString *formatBody;
static NSString *formatSubject;
static BOOL isHTML;


@interface RKServiceMailLink <MFMailComposeViewControllerDelegate>
@end

%hook RKServiceMailLink
- (void)share:(RKShareObject *)arg1
{
	NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
	NSDictionary *recipients = [ud dictionaryForKey:@"ShareRKServiceMail"];
	NSString *address = [recipients objectForKey:@"EmailLink"];

	NSString *body = [formatBody stringByReplacingOccurrencesOfString:kMacroTitle withString:gTitle];
	body = [body stringByReplacingOccurrencesOfString:kMacroSource withString:gSrcTitle];
	body = [body stringByReplacingOccurrencesOfString:kMacroURL withString:gUrl];

	NSString *subject = [formatSubject stringByReplacingOccurrencesOfString:kMacroTitle withString:gTitle];
	subject = [subject stringByReplacingOccurrencesOfString:kMacroTitle withString:gSrcTitle];
	subject = [subject stringByReplacingOccurrencesOfString:kMacroURL withString:gUrl];

	UIWindow *window = [UIApplication sharedApplication].keyWindow;
	id viewController = window.rootViewController;

	MFMailComposeViewController *mailPostVC = [[MFMailComposeViewController alloc] init];
	mailPostVC.mailComposeDelegate = self;
	[mailPostVC setMessageBody:body isHTML:isHTML];
	[mailPostVC setSubject:subject];
	[mailPostVC setToRecipients:[NSArray arrayWithObjects:address, nil]];
	[viewController presentModalViewController:mailPostVC animated:YES];
}
%end



#pragma mark -
#pragma mark Disable "Pull to Refresh"

static BOOL isRefresh;

%hook SubscriptionsViewController
- (BOOL)scrollHeaderViewCanPull:(id)arg1
{
	return isRefresh ? NO : %orig;
}
%end

%hook TableViewController
- (BOOL)scrollHeaderViewCanPull:(id)arg1
{
	return isRefresh ? NO : %orig;
}
%end

%hook ItemsViewController
- (BOOL)scrollHeaderViewCanPull:(id)arg1
{
	return isRefresh ? NO : %orig;
}
%end



#pragma mark -
#pragma mark Change the font, font size

static NSString *fontTitle;
static float fontSizeTitle;
static float fontSizeSubtitle;

%hook UIFont
/* + (id)boldSystemFontOfSize:(float)size */
+ (id)systemFontOfSize:(float)size
{
	return (size == 17.0) ? %orig(fontSizeSubtitle) : %orig;
}
+ (id)fontWithName:(NSString *)name size:(float)size
{
	return ( [name isEqualToString:@"HelveticaNeue-Medium"] && size == 17.0 ) ? %orig(fontTitle, fontSizeTitle) : %orig;
}
%end



#pragma mark -
#pragma mark Ask to send

static BOOL isAskToSend;


%hook ItemsViewController
- (BOOL)collectionView:(id)arg1 commitSlider:(int)slider forCell:(id)arg3
{
	if (!isAskToSend) {
		return %orig;
	}

	NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
	NSString *action;
	if ( slider == 0 ) {
		action = [ud stringForKey:@"AppSlideRightAction"];
	}
	else if ( slider == 1 ) {
		action = [ud stringForKey:@"AppSlideLeftAction"];
	}
	else {
		return %orig;
	}

	if ( [action isEqualToString:@"NoAction"] || [action isEqualToString:@"ToggleStarred"] || [action isEqualToString:@"ToggleRead"] ) {
		return %orig;
	}

	UIImage *image = [[UIImage alloc] init];
	if ( [action isEqualToString:@"Readability"] ) {
		image = [UIImage imageNamed:@"ShareRKServiceReadability"];
	}
	else if ( [action isEqualToString:@"Instapaper"] ) {
		image = [UIImage imageNamed:@"ShareRKServiceInstapaper"];
	}
	else if ( [action isEqualToString:@"Pocket"] ) {
		image = [UIImage imageNamed:@"ShareRKServiceReadItLater"];
	}
	else if ( [action isEqualToString:@"QuoteFMRead"] ) {
		action = @"QUOTE.fm";
		image = [UIImage imageNamed:@"ShareRKServiceQuoteFMRead"];
	}

	[%c(RSAlert) presentSheetWithTitle:[NSString stringWithFormat:@"Are you sure you want to send to %@?", action] buttonTitle:[NSString stringWithFormat:@"Send to %@", action] cancelButtonTitle:@"Cancel" handler:^{
		UIWindow *window = [UIApplication sharedApplication].keyWindow;
		[%c(Bezel) flashWithTitle:action image:image inView:window.rootViewController.view];
		return %orig;
	} inView:[[UIView alloc] initWithFrame:CGRectMake(0, [[UIScreen mainScreen] bounds].size.height, 320, 460)]];

	return NO;
}
%end



#pragma mark -
#pragma mark LINE action


%subclass RKServiceLine : RKServiceLocalConnector

static BOOL isLine;
static NSString *formatLine;

+ (BOOL)canHandleObject:(id)object
{
	return ![object isLinkOnly];
}

+ (BOOL)canShare
{
	return isLine;
}

- (void)share:(id)item
{
	NSString *cStr = [formatLine stringByReplacingOccurrencesOfString:kMacroTitle withString:gTitle];
	cStr = [cStr stringByReplacingOccurrencesOfString:kMacroSource withString:gSrcTitle];
	cStr = [cStr stringByReplacingOccurrencesOfString:kMacroURL withString:gUrl];

	if ( [[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"line://"]] ) {
		NSString *url = [NSString stringWithFormat:@"line://msg/text/%@", cStr];
		NSURL *webStringURL = [NSURL URLWithString:[url stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];

		[[UIApplication sharedApplication] openURL:webStringURL];
	}
	else {
		[%c(RSAlert) presentWithTitle:@"Error!" message:@"Please install LINE.app!" buttonTitle:@"OK" handler:^{
			[[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"https://itunes.apple.com/jp/app/line/id443904275?mt=8"]];
		}];
	}
}
%end



static NSString *filedText;

static inline void Response(NSString *response)
{
	if ( [response isEqualToString:@"401 Unauthorized"] ) {
		[%c(RSAlert) presentWithTitle:response message:@"Incorrect username or password." buttonTitle:@"OK" handler:nil];
	}
	else if ( [response isEqualToString:@"400 Bad Request"] ) {
		[%c(RSAlert) presentWithTitle:response message:@"Please try again after a while." buttonTitle:@"OK" handler:nil];
	}
	else {
		UIWindow *window = [UIApplication sharedApplication].keyWindow;
		[%c(Bezel) flashWithTitle:@"Hatena B!" image:[UIImage imageWithContentsOfFile:@"/Library/Application Support/Reeder2Enhancer/Bookmark.png"] inView:window.rootViewController.view];
	}
}


@implementation AtomPubDelegate
- (void)connectionDidFinishLoading:(NSURLConnection *)connection data:(NSData *)data
{
	NSString *responseBody = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
	Response(responseBody);
}
@end


typedef enum {
	NotReachable = 0,
	ReachableViaWiFi,
	ReachableViaWWAN
} NetworkStatus;


%hook UITextField
- (id)_text {
	filedText = %orig;
	return filedText;
}
%end



#pragma mark HatenaBookmark action

%subclass RKServiceHatena : RKServiceLocalConnector

static BOOL isHatena;
static int choice;
static NSString *hatenaUsername;
static NSString *hatenaPassword;
static NSString *hatenaComment;

+ (BOOL)canHandleObject:(id)object
{
	return ![object isLinkOnly];
}

+ (BOOL)canShare
{
	return isHatena;
}

- (void)share:(id)item
{
	if ( choice == 0 ) {
    	
		// Internal

    	[self initializeHatenaBookmarkClient];

    	if ( ![HTBHatenaBookmarkManager sharedManager].authorized ) {

	    	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(showOAuthLoginView:) name:kHTBLoginStartNotification object:nil];
			[[HTBHatenaBookmarkManager sharedManager] logout];

		    [[HTBHatenaBookmarkManager sharedManager] authorizeWithSuccess:^{
	    		UIWindow *window = [UIApplication sharedApplication].keyWindow;
				id rvc = window.rootViewController;

				HTBHatenaBookmarkViewController *viewController = [[HTBHatenaBookmarkViewController alloc] init];
			    viewController.URL = [NSURL URLWithString:gUrl];
			    [rvc presentViewController:viewController animated:YES completion:nil];
		    } failure:^(NSError *error) {
		    }];
		}
		else {

    		UIWindow *window = [UIApplication sharedApplication].keyWindow;
			id rvc = window.rootViewController;

			HTBHatenaBookmarkViewController *viewController = [[HTBHatenaBookmarkViewController alloc] init];
		    viewController.URL = [NSURL URLWithString:gUrl];
		    [rvc presentViewController:viewController animated:YES completion:nil];
		}
	}
	else if ( choice == 1 ) {

		// Internal (Obsolete)
		
		if ( [hatenaUsername isEqualToString:@""] || [hatenaPassword isEqualToString:@""] ) {
			return [%c(RSAlert) presentWithTitle:@"Error!" message:@"Please Login HatenaBookmark! You can configure options from Setting.app." buttonTitle:@"OK" handler:nil];
		}
		
		[%c(RSAlert) presentInput:hatenaComment withTitle:@"Send to HatenaBookmark" placeholder:@"Comment [Tag]" description:nil buttonTitle:@"Send" cancelButtonTitle:@"Cancel" handler:^{
			
			Reachability *curReach = [%c(Reachability) reachabilityForInternetConnection];
			NetworkStatus netStatus = (NetworkStatus)[curReach currentReachabilityStatus];

			switch (netStatus) {
				case NotReachable:
					[%c(RSAlert) presentWithTitle:@"Error!" message:@"Reeder cannot send to HatneBookmark because it is not connected to the Internet." buttonTitle:@"OK" handler:nil];
					break;
				case ReachableViaWWAN:
				case ReachableViaWiFi:
					[self postHatenaWtihComment:filedText];
					break;
				default:
					break;
			}
		} inView:[[UIView alloc] initWithFrame:CGRectMake(0, [[UIScreen mainScreen] bounds].size.height-20, 320, 460)]];
	}
	else if ( choice == 2 ) {

		// URL scheme (Open in hatenabookmark.app)
		
		if ( [[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"hatenabookmark://"]] ) {
			NSString *url = [NSString stringWithFormat:@"hatenabookmark:/entry?title=%@&url=%@&backtitle=%@&backurl=%@", gTitle, gUrl, @"Reeder", @"reeder://"];

			[[UIApplication sharedApplication] openURL:[NSURL URLWithString:[url stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]]];
		}
		else {
			[%c(RSAlert) presentWithTitle:@"Error!" message:@"Please install HatenaBookmark.app!" buttonTitle:@"OK" handler:^{
				[[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"https://itunes.apple.com/jp/app/hatenabukkumaku/id354976659?mt=8"]];
			}];
		}
	}
}

%new(v@:)
- (void)initializeHatenaBookmarkClient
{
    [[HTBHatenaBookmarkManager sharedManager] setConsumerKey:@"K/FHwtxiJGrMIw==" consumerSecret:@"9HT5kYVrHXPFxisbfn5IewT8NaE="];
    
    if ( [HTBHatenaBookmarkManager sharedManager].authorized ) {
        [[HTBHatenaBookmarkManager sharedManager] getMyEntryWithSuccess:^(HTBMyEntry *myEntry) {
        } failure:^(NSError *error) {
        }];

        [[HTBHatenaBookmarkManager sharedManager] getMyTagsWithSuccess:^(HTBMyTagsEntry *myTagsEntry) {
        } failure:^(NSError *error) {
        }];
    }
}

%new(v@:@)
-(void)showOAuthLoginView:(NSNotification *)notification
{
    NSURLRequest *req = (NSURLRequest *)notification.object;
    UINavigationController *navigationController = [[UINavigationController alloc] initWithNavigationBarClass:[HTBNavigationBar class] toolbarClass:nil];
    HTBLoginWebViewController *viewController = [[HTBLoginWebViewController alloc] initWithAuthorizationRequest:req];
    navigationController.viewControllers = @[viewController];

    UIWindow *window = [UIApplication sharedApplication].keyWindow;
	id rvc = window.rootViewController;
    [rvc presentViewController:navigationController animated:YES completion:nil];
}


%new(v@:@)
- (void)postHatenaWtihComment:(NSString *)comment
{
    [DCWSSE wsseString:hatenaUsername password:hatenaPassword];
    DCHatenaClient *hatenaClient = [[DCHatenaClient alloc] initWithUsername:hatenaUsername password:hatenaPassword];
	hatenaClient.delegate = [[AtomPubDelegate alloc] init];
	gUrl = (__bridge_transfer NSString *)CFURLCreateStringByAddingPercentEscapes(NULL, (CFStringRef)gUrl, NULL,  (CFStringRef)@"&=-#", kCFStringEncodingUTF8);
	[hatenaClient post:gUrl comment:comment];
}



#pragma mark Custom action

%subclass RKServiceCustom : RKServiceLocalConnector

static BOOL isCustom;
static NSString *formatCustom;
static NSString *titleCustom;

+ (BOOL)canHandleObject:(id)object
{
	return ![object isLinkOnly];
}

+ (BOOL)canShare
{
	return isCustom;
}

- (void)share:(id)item
{
	NSString *cStr = [formatCustom stringByReplacingOccurrencesOfString:kMacroTitle withString:gTitle];
	cStr = [cStr stringByReplacingOccurrencesOfString:kMacroSource withString:gSrcTitle];
	cStr = [cStr stringByReplacingOccurrencesOfString:kMacroURL withString:gUrl];

	cStr = [cStr stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];

	NSString *openURL = [NSString stringWithFormat:@"%@://", [[NSURL URLWithString:cStr] scheme]];

	if ( [[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:openURL]] ) {
		NSURL *webStringURL = [NSURL URLWithString:cStr];

		[[UIApplication sharedApplication] openURL:webStringURL];
	}
	else {
		[%c(RSAlert) presentWithTitle:@"Error!" message:@"URL Scheme Error." buttonTitle:@"OK" handler:^{}];
	}
}
%end



%hook RKService
+ (void)createInStore:(id)store oid:(id)oid title:(id)title link:(id)link index:(int)index
{
	if ( [title isEqualToString:@"Message"] ) {
		%orig;

		// index safari: 20, chrome: 21
		
		%orig(store, @"RKServiceLine", @"LINE", link, 22);
		%orig(store, @"RKServiceHatena", @"HatenaBookmark", link, 23);
		%orig(store, @"RKServiceCustom", titleCustom, link, 24);
	}
	else {
		%orig;
	}
}
%end


%hook UIImage
+ (id)imageNamed:(id)image
{
	if ( [image isEqualToString:@"ShareRKServiceHatena.png"] ) {
		return [UIImage imageWithContentsOfFile:@"/Library/Application Support/Reeder2Enhancer/Bookmark.png"];
	}
	if ( [image isEqualToString:@"ShareRKServiceLine.png"] ) {
		return [UIImage imageWithContentsOfFile:@"/Library/Application Support/Reeder2Enhancer/LINE.png"];
	}
	if ( [image isEqualToString:@"ShareRKServiceCustom.png"] ) {
		return %orig(@"ButtonAction.png");
	}
	else {
		return %orig;	
	}
}
%end


#pragma mark -
#pragma mark Sync Notification

static NSString *previousSyncStatusText;

%hook RKUser
- (void)setSyncStatusText:(NSString *)text
{
	if ( !text && [previousSyncStatusText hasPrefix:@"Caching"] ) {
		UILocalNotification *notification = [[UILocalNotification alloc] init];
		[notification setTimeZone:[NSTimeZone localTimeZone]];
		NSDate *date = [NSDate date];
		NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
		[dateFormatter setDateFormat:@"Y/M/d H:m:ss Z"];
		[notification setAlertBody:[NSString stringWithFormat:@"Synced at %@", [dateFormatter stringFromDate:date]]];
		[notification setSoundName:UILocalNotificationDefaultSoundName];
		[notification setAlertAction:@"Open"];
		[[UIApplication sharedApplication] presentLocalNotificationNow:notification];
	}
	previousSyncStatusText = text;
	%orig;
}
%end

%hook AppDelegate
%new(v@:@@)
- (void)application:(UIApplication *)application didReceiveLocalNotification:(UILocalNotification *)notification
{
	[[UIApplication sharedApplication] cancelAllLocalNotifications];
}

- (void)applicationDidBecomeActive:(id)arg1
{
	[[UIApplication sharedApplication] cancelAllLocalNotifications];
	%orig;
}

- (BOOL)application:(id)arg1 didFinishLaunchingWithOptions:(id)arg2
{
	return %orig;
}
%end


static void LoadSettings()
{
	NSDictionary *dict = [NSDictionary dictionaryWithContentsOfFile:PREF_PATH];

	id existRefresh = [dict objectForKey:@"NoRefresh"];
	isRefresh = existRefresh ? [existRefresh boolValue] : NO;
	id existAskToSend = [dict objectForKey:@"AskToSend"];
	isAskToSend = existAskToSend ? [existAskToSend boolValue] : YES;

	id existHatena = [dict objectForKey:@"IsHatena"];
	isHatena = existHatena ? [existHatena boolValue] : YES;
	id existLine = [dict objectForKey:@"IsLine"];
	isLine = existLine ? [existLine boolValue] : YES;
	id existCustom = [dict objectForKey:@"IsCustom"];
	isCustom = existCustom ? [existCustom boolValue] : YES;

	id existFormat = [dict objectForKey:@"Format"];
	format = existFormat ? [existFormat copy] : @"\"gTitle_ | _SOURCE_\"";

	id existFormatLine = [dict objectForKey:@"FormatLine"];
	formatLine = existFormatLine ? [existFormatLine copy] : @"\"gTitle_ | _SOURCE_\" gUrl_";

	id existFormatCustom = [dict objectForKey:@"FormatCustom"];
	formatCustom = existFormatCustom ? [existFormatCustom copy] : @"tweetbot:///post?text=\"gTitle_ | _SOURCE_\" gUrl_";
	id existTitleCustom = [dict objectForKey:@"TitleCustom"];
	titleCustom = existTitleCustom ? [existTitleCustom copy] : @"*CUSTOM ACTION*";

	id existFormatBody = [dict objectForKey:@"FormatBody"];
	formatBody = existFormatBody ? [existFormatBody copy] : @"\"gTitle_ | _SOURCE_\"<br /><br />gUrl_";
	id existFormatSubject = [dict objectForKey:@"FormatSubject"];
	formatSubject = existFormatSubject ? [existFormatSubject copy] : @"[RSS] gTitle_ | _SOURCE_";

	id existChoice = [dict objectForKey:@"Choice"];
	choice = existChoice ? [existChoice intValue] : 0;
	
	id existUsername = [dict objectForKey:@"HatenaUsername"];
	hatenaUsername = existUsername ? [existUsername copy] : @"";
	id existPassword = [dict objectForKey:@"HatenaPassword"];
	hatenaPassword = existPassword ? [existPassword copy] : @"";
	id existComment = [dict objectForKey:@"DefaultComment"];
	hatenaComment = existComment ? [existComment copy] : @"[Reeder]";
	id existIsHTML = [dict objectForKey:@"IsHTML"];
	isHTML = existIsHTML ? [existIsHTML boolValue] : YES;
	id existMoveToTop = [dict objectForKey:@"CaretMoveToTop"];
	moveToTop = existMoveToTop ? [existMoveToTop boolValue] : YES;

	id existFontTitle = [dict objectForKey:@"FontTitle"];
	fontTitle = existFontTitle ? [existFontTitle copy] : @"HelveticaNeue-Medium";
	id existFontSizeTitle = [dict objectForKey:@"FontSizeTitle"];
	fontSizeTitle = existFontSizeTitle ? [existFontSizeTitle intValue] : 17.0;
	id existFontSizeSubtitle = [dict objectForKey:@"FontSizeSubtitle"];
	fontSizeSubtitle = existFontSizeSubtitle ? [existFontSizeSubtitle intValue] : 17.0;
}

static void PostNotification(CFNotificationCenterRef center, void *observer, CFStringRef name, const void *object, CFDictionaryRef userInfo)
{
	LoadSettings();
}

%ctor
{
	@autoreleasepool {
		%init;
		CFNotificationCenterAddObserver(CFNotificationCenterGetDarwinNotifyCenter(), NULL, PostNotification, CFSTR("com.kindadev.Reeder2Enhancer.settingschanged"), NULL, CFNotificationSuspensionBehaviorCoalesce);
		LoadSettings();	
	}
}
