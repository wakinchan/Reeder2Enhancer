#import <UIKit/UIKit.h>
#import <Twitter/TWTweetComposeViewController.h>
#import <Social/Social.h>
#import <MessageUI/MessageUI.h>

#import "HBMSDK/HatenaBookmarkSDK.h"
#import "DCAtomPub/DCWSSE.h"
#import "DCAtomPub/DCHatenaClient.h"
#import "UIView+Reeder2Enhancer.h"

#define PREF_PATH @"/var/mobile/Library/Preferences/com.kindadev.Reeder2Enhancer.plist"

#ifndef kCFCoreFoundationVersionNumber_iOS_5_0
#define kCFCoreFoundationVersionNumber_iOS_5_0 675.00
#endif
#ifndef kCFCoreFoundationVersionNumber_iOS_6_0
#define kCFCoreFoundationVersionNumber_iOS_6_0 793.00
#endif

@interface Reachability
+ (id)reachabilityForInternetConnection;
- (int)currentReachabilityStatus;
@end

@interface AtomPubDelegate : NSObject <DCAtomPubDelegate>
@end

@interface Bezel
// + (id)bezelWithSize:(int)arg1 image:(id)arg2 text:(id)arg3;
// - (void)flashInView:(id)arg1 direction:(int)arg2;
+ (void)flashWithTitle:(id)arg1 image:(id)arg2 inView:(id)arg3;
@end

@interface RSForm
@property(copy) NSString * quote;
@end

@interface RSAlert : NSObject
+ (void)presentInput:(id)arg1 withTitle:(id)arg2 placeholder:(id)arg3 description:(id)arg4 buttonTitle:(id)arg5 cancelButtonTitle:(id)arg6 handler:(id)arg7 inView:(id)arg8;
+ (void)presentSheetWithTitle:(id)arg1 buttonTitle:(id)arg2 cancelButtonTitle:(id)arg3 handler:(id)arg4 cancelHandler:(id)arg5 inView:(id)arg6;
+ (void)presentInput:(id)arg1 withTitle:(id)arg2 placeholder:(id)arg3 description:(id)arg4 buttonTitle:(id)arg5 cancelButtonTitle:(id)arg6 handler:(id)arg7;
+ (void)presentSheetWithTitle:(id)arg1 buttonTitle:(id)arg2 cancelButtonTitle:(id)arg3 handler:(id)arg4 inView:(id)arg5;
+ (void)presentWithTitle:(id)arg1 message:(id)arg2 buttonTitle:(id)arg3 handler:(id)arg4;
+ (void)presentWithImage:(id)arg1 buttonTitle:(id)arg2 handler:(id)arg3;
+ (void)presentSheetWithTitle:(id)arg1 buttonTitle:(id)arg2 handler:(id)arg3;
+ (void)presentSheetWithTitle:(id)arg1 buttonTitle:(id)arg2 cancelButtonTitle:(id)arg3 handler:(id)arg4;
@end

@interface RKShareObject : NSObject
+ (id)shareObjectWithItem:(id)arg1;

- (void)setSummary:(id)arg1;
- (id)summary;
- (void)setContent:(id)arg1;
- (void)setDelegate:(id)arg1;
- (id)delegate;
- (int)type;
- (id)description;
- (BOOL)isEqual:(id)arg1;
- (id)init;
- (void)setUrl:(id)arg1;
- (id)url;
- (id)content;
- (id)item;
- (id)image;
- (id)title;
- (void)setType:(int)arg1;
- (void)setTitle:(id)arg1;
- (void)setImage:(id)arg1;
- (id)initWithItem:(id)arg1;
- (void)setItem:(id)arg1;
- (void)setImageLink:(id)arg1;
- (id)imageLink;
- (void)setImageSrc:(id)arg1;
- (void)setIsLinkOnly:(BOOL)arg1;
- (BOOL)isLinkOnly;
- (id)sentWithReeder;
- (id)titleButtonHeader;
- (id)titleButtonFooter;
- (BOOL)isArticle;
- (id)imageSrc;
- (id)srcTitle;
- (id)srcUrl;
- (BOOL)isGoogleMobilized;
- (BOOL)isInstapaperMobilized;
- (void)setSrcUrl:(id)arg1;
- (void)setSrcTitle:(id)arg1;
- (id)itemData;
- (void)useItem:(id)arg1;
@end

@interface RKServiceConnector : NSObject
@end

@interface RKServiceLocalConnector : RKServiceConnector
@end

@interface RKServiceTwitter : RKServiceLocalConnector
+ (void)initialize;
+ (BOOL)canHandleObject:(id)arg1;
+ (BOOL)unsupported;
+ (BOOL)canShare;

- (void)share:(id)arg1;
- (void)handleKeyboardWillShow:(NSNotification *)notification;
@end

@interface RKServiceLine : RKServiceLocalConnector
+ (BOOL)canHandleObject:(id)arg1;
+ (BOOL)canShare;

- (void)share:(id)arg1;
@end

@interface RKServiceHatena : RKServiceLocalConnector
+ (BOOL)canHandleObject:(id)arg1;
+ (BOOL)canShare;

- (void)share:(id)arg1;
- (void)initializeHatenaBookmarkClient;
- (void)postHatenaWtihComment:(NSString *)comment;
- (void)postHatenaFromUrlScheme;
- (void)handleKeyboardWillShow:(NSNotification *)notification;
@end

@interface RKServiceCustom : RKServiceLocalConnector
+ (BOOL)canHandleObject:(id)arg1;
+ (BOOL)canShare;

- (void)share:(id)arg1;
@end

