//
//  KMIndicatorView.m
//  KMIndicatorView
//
//  Created by Kosuke Matsuda on 2013/07/05.
//  Copyright (c) 2013年 matsuda. All rights reserved.
//

#import "KMIndicatorView.h"

@interface KMIndicatorView ()
@property (strong, nonatomic) UIView *overlayView;
@property (strong, nonatomic) UIView *grayerView;
@property (strong, nonatomic) UIActivityIndicatorView *indicator;
@end

@implementation KMIndicatorView

+ (instancetype)sharedView
{
    static id __instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        __instance = [[self alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    });
    return __instance;
}

+ (void)show
{
    [[self sharedView] show];
}

+ (void)dismiss
{
    [[self sharedView] dismiss];
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        self.alpha = 0;
    }
    return self;
}

- (void)show
{
    if (!self.overlayView.superview) {
        NSEnumerator *frontToBackWindows = [[[UIApplication sharedApplication] windows] reverseObjectEnumerator];
        for (UIWindow *window in frontToBackWindows) {
            if (window.windowLevel == UIWindowLevelNormal) {
                [window addSubview:self.overlayView];
                break;
            }
        }
    }

    if (!self.superview) {
        [self.overlayView addSubview:self];
    }

    [self updateLayout];
    [self didChangeOrientation:nil];

    if (self.alpha != 1) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didChangeOrientation:) name:UIApplicationDidChangeStatusBarOrientationNotification object:nil];
        self.alpha = 1;
        [self setNeedsDisplay];
    }
    [self.indicator startAnimating];
}

- (void)dismiss
{
    self.alpha = 0;
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationDidChangeStatusBarOrientationNotification object:nil];

    [_indicator stopAnimating];
    [_indicator removeFromSuperview];
    _indicator = nil;
    [_overlayView removeFromSuperview];
    _overlayView = nil;
}

- (void)updateLayout
{
    CGRect frame = self.bounds;
    self.grayerView.frame = frame;
    self.indicator.center = CGPointMake(CGRectGetMidX(frame), CGRectGetMidY(frame));
}

- (void)didChangeOrientation:(NSNotification *)notification
{
	UIInterfaceOrientation orientation = [UIApplication sharedApplication].statusBarOrientation;
    // NSLog(@"UIInterfaceOrientationLandscapeLeft >>>>>>>>>>>>>> %d", UIInterfaceOrientationLandscapeLeft);
    // NSLog(@"UIDeviceOrientationLandscapeLeft >>>>>>>>>>>>>> %d", UIDeviceOrientationLandscapeLeft);

    CGRect orientationFrame = [UIScreen mainScreen].bounds;

    if (UIInterfaceOrientationIsLandscape(orientation)) {
        float temp = orientationFrame.size.width;
        orientationFrame.size.width = orientationFrame.size.height;
        orientationFrame.size.height = temp;
    }

    CGFloat posY = orientationFrame.size.height/2;
    CGFloat posX = orientationFrame.size.width/2;
    CGPoint newCenter;
    CGFloat rotateAngle;

    switch (orientation) {
        case UIInterfaceOrientationPortraitUpsideDown:
            rotateAngle = M_PI;
            newCenter = CGPointMake(posX, orientationFrame.size.height-posY);
            break;
        case UIInterfaceOrientationLandscapeLeft:
            rotateAngle = -M_PI/2.0f;
            newCenter = CGPointMake(posY, posX);
            break;
        case UIInterfaceOrientationLandscapeRight:
            rotateAngle = M_PI/2.0f;
            newCenter = CGPointMake(orientationFrame.size.height-posY, posX);
            break;
        default: // as UIInterfaceOrientationPortrait
            rotateAngle = 0.0;
            newCenter = CGPointMake(posX, posY);
            break;
    }
    CGAffineTransform transform = CGAffineTransformMakeRotation(rotateAngle);
    self.indicator.transform = transform;
    self.indicator.center = newCenter;
}

#pragma mark - getter views

- (UIView *)overlayView
{
    if (!_overlayView) {
        UIView *view = [[UIView alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
        view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        view.backgroundColor = [UIColor clearColor];
        _overlayView = view;
    }
    return _overlayView;
}

- (UIView *)grayerView
{
    if (!_grayerView) {
        UIView *view = [[UIView alloc] initWithFrame:CGRectZero];
        view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        view.backgroundColor = [UIColor blackColor];
        view.alpha = 0.7;
        [self addSubview:view];
        _grayerView = view;
    }
    return _grayerView;
}

- (UIActivityIndicatorView *)indicator
{
    if (!_indicator) {
        UIActivityIndicatorView *indicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
        indicator.autoresizingMask = (UIViewAutoresizingFlexibleTopMargin |
                                      UIViewAutoresizingFlexibleBottomMargin |
                                      UIViewAutoresizingFlexibleLeftMargin |
                                      UIViewAutoresizingFlexibleRightMargin);
        indicator.center = CGPointMake(self.bounds.size.width / 2, self.bounds.size.height / 2);
        [self addSubview:indicator];
        _indicator = indicator;
    }
    return _indicator;
}

@end
