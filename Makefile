ARCHS = armv7
THEOS_INSTALL_KILL = Reeder
THEOS_DEVICE_IP = 192.168.1.106
TARGET = iphone:clang::5.0

include theos/makefiles/common.mk

TWEAK_NAME = Reeder2Enhancer
Reeder2Enhancer_FILES = Tweak.xm UIView+Reeder2Enhancer.m DCAtomPub/Base64EncDec.m DCAtomPub/CocoaCryptoHashing.m DCAtomPub/DCAtomPubClient.m DCAtomPub/DCHatenaClient.m DCAtomPub/DCWSSE.m DCAtomPub/DCWSSEURLRequest.m HBMSDK/AFHTTPClient.m HBMSDK/AFHTTPRequestOperation.m HBMSDK/AFImageRequestOperation.m HBMSDK/AFJSONRequestOperation.m HBMSDK/AFNetworkActivityIndicatorManager.m HBMSDK/AFPropertyListRequestOperation.m HBMSDK/AFURLConnectionOperation.m HBMSDK/AFXMLRequestOperation.m HBMSDK/HTBAFOAuth1Client.m HBMSDK/HTBBookmarkedDataEntry.m HBMSDK/HTBBookmarkEntry.m HBMSDK/HTBBookmarkEntryView.m HBMSDK/HTBBookmarkRootView.m HBMSDK/HTBBookmarkToolbarView.m HBMSDK/HTBBookmarkViewController.m HBMSDK/HTBCanonicalEntry.m HBMSDK/HTBCanonicalView.m HBMSDK/HTBCommentViewController.m HBMSDK/HTBHatenaBookmarkActivity.m HBMSDK/HTBHatenaBookmarkAPIClient.m HBMSDK/HTBHatenaBookmarkManager.m HBMSDK/HTBHatenaBookmarkViewController.m HBMSDK/HTBLoginWebViewController.m HBMSDK/HTBMyEntry.m HBMSDK/HTBMyTagsEntry.m HBMSDK/HTBNavigationBar.m HBMSDK/HTBPlaceholderTextView.m HBMSDK/HTBTagEntry.m HBMSDK/HTBTagInputView.m HBMSDK/HTBTagTextField.m HBMSDK/HTBTagTokenizer.m HBMSDK/HTBTagToolbarView.m HBMSDK/HTBToggleButton.m HBMSDK/HTBUserManager.m HBMSDK/HTBUtility.m HBMSDK/UIAlertView+HTBNSError.m HBMSDK/UIImageView+AFNetworking.m HBMSDK/SFHFKeychainUtils.m HBMSDK/HTBAuthorizeEntry.m
Reeder2Enhancer_FRAMEWORKS = UIKit MessageUI Security CoreGraphics QuartzCore SystemConfiguration MobileCoreServices
Reeder2Enhancer_LDFLAGS = -weak_framework Twitter -weak_framework Social
Reeder2Enhancer_CFLAGS = -fobjc-arc

include $(THEOS_MAKE_PATH)/tweak.mk

BUNDLE_NAME = Reeder2EnhancerSettings
Reeder2EnhancerSettings_FILES = Preference.m SVProgressHUD/SVProgressHUD.m
Reeder2EnhancerSettings_INSTALL_PATH = /Library/PreferenceBundles
Reeder2EnhancerSettings_FRAMEWORKS = UIKit Accounts CoreGraphics
Reeder2EnhancerSettings_PRIVATE_FRAMEWORKS = Preferences
Reeder2EnhancerSettings_LDFLAGS = -weak_framework Twitter -weak_framework Social

include $(THEOS_MAKE_PATH)/bundle.mk

internal-stage::
	$(ECHO_NOTHING)mkdir -p $(THEOS_STAGING_DIR)/Library/PreferenceLoader/Preferences$(ECHO_END)
	$(ECHO_NOTHING)cp entry.plist $(THEOS_STAGING_DIR)/Library/PreferenceLoader/Preferences/Reeder2Enhancer.plist$(ECHO_END)

real-clean:
	rm -rf _
	rm -rf .obj
	rm -rf obj
	rm -rf .theos
	rm -rf *.deb
