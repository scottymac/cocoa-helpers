//
//  UIViewControllerHelper.m
//  Enormego Cocoa Helpers
//
//  Created by Shaun Harrison on 3/18/09.
//  Copyright (c) 2009 enormego
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.
//

#if TARGET_OS_IPHONE
#import "UIViewControllerHelper.h"

@interface UIViewController (Private)
- (void)setParentViewController:(UIViewController*)parentViewController;
@end

@implementation UIViewController (Helper)

- (void)presentPopUpViewController:(UIViewController*)viewController {
	[viewController setParentViewController:self];

	if(![[UIApplication sharedApplication] isStatusBarHidden]) {
		CGRect frame = self.view.bounds;
		frame.origin.y = [UIApplication sharedApplication].statusBarFrame.size.height;
		frame.size.height -= frame.origin.y;
		viewController.view.frame = frame;
	} else {
		viewController.view.frame = self.view.bounds;
	}
	
	viewController.view.alpha = 0.0f;

	[self.view addSubview:viewController.view];
	
	[viewController viewWillAppear:YES];
	
	[UIView beginAnimations:@"presentPopUpViewController" context:viewController];
	[UIView setAnimationDelegate:self];
	[UIView setAnimationDidStopSelector:@selector(presentedPopUpViewController:finished:viewController:)];
	viewController.view.alpha = 1.0f;
	[UIView commitAnimations];
	
	[viewController retain];
}

- (void)presentedPopUpViewController:(id)name finished:(id)finished viewController:(UIViewController*)viewController {
	[viewController viewDidAppear:YES];
}

- (void)dismissPopUpViewController {
	[self.parentViewController dismissPopUpViewController:self];
}

- (void)dismissPopUpViewController:(UIViewController*)viewController {
	[viewController viewWillDisappear:YES];
	
	[UIView beginAnimations:@"dismissPopUpViewController" context:viewController];
	[UIView setAnimationDelegate:self];
	[UIView setAnimationDidStopSelector:@selector(dismissedPopUpViewController:finished:viewController:)];
	viewController.view.alpha = 0.0f;
	[UIView commitAnimations];
	
	UINavigationController* navigationController = nil;
	
	if([self isKindOfClass:[UINavigationController class]]) {
		navigationController = (id)self;
	} else if([self isKindOfClass:[UITabBarController class]]) {
		if([[(UITabBarController*)self selectedViewController] isKindOfClass:[UINavigationController class]]) {
			navigationController = (id)[(UITabBarController*)self selectedViewController];
		}
	}
	
	if(navigationController) {
		if([navigationController.topViewController.view isKindOfClass:[UIScrollView class]]) {
			((UIScrollView*)navigationController.topViewController.view).scrollsToTop = YES;
		}
	}
}

- (void)dismissedPopUpViewController:(id)name finished:(id)finished viewController:(UIViewController*)viewController {
	[viewController.view removeFromSuperview];
	[viewController viewDidDisappear:YES];
	[viewController release];
}

@end
#endif