#import "UIView+Reeder2Enhancer.h"

@implementation UIView (Reeder2Enhancer)

- (UIView *)findFirstResponder
{
	if (self.isFirstResponder) {
		return self;
	}
	for (UIView *subView in self.subviews) {
		UIView *firstResponder = [subView findFirstResponder];
		if (firstResponder != nil) {
			return firstResponder;
		}
	}
	return nil;
}

@end