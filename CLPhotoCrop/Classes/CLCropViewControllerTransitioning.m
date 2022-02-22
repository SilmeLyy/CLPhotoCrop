//
//  CLCropViewControllerTransitioning.m
//  CLPhotoCrop
//
//  Created by 雷玉宇 on 2022/2/16.
//

#import "CLCropViewControllerTransitioning.h"

@implementation CLCropViewControllerTransitioning

- (NSTimeInterval)transitionDuration:(id <UIViewControllerContextTransitioning>)transitionContext
{
    return 0.45f;
}

- (void)animateTransition:(id <UIViewControllerContextTransitioning>)transitionContext
{
    // Get the master view where the animation takes place
    UIView *containerView = [transitionContext containerView];
    
    // Get the origin/destination view controllers
    UIViewController *fromViewController = [transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
    UIViewController *toViewController = [transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
    
    // Work out which one is the crop view controller
    UIViewController *cropViewController = (self.isDismissing == NO) ? toViewController : fromViewController;
    UIViewController *previousController = (self.isDismissing == NO) ? fromViewController : toViewController;
    
    // Just in case, match up the frame sizes
    cropViewController.view.frame = containerView.bounds;
    if (self.isDismissing) {
        previousController.view.frame = containerView.bounds;
    }
    
    // Add the view layers beforehand as this will trigger the initial sets of layouts
    if (self.isDismissing == NO) {
        [containerView addSubview:cropViewController.view];
    }
    else {
        [containerView insertSubview:previousController.view belowSubview:cropViewController.view];
    }
    
    // Perform any last UI updates now so we can potentially factor them into our calculations, but after
    // the container views have been set up
    if (self.prepareForTransitionHandler)
        self.prepareForTransitionHandler();
    
    // If origin/destination views were supplied, use them to supplant the
    // frames
//    if (!self.isDismissing && self.fromView) {
//        self.fromFrame = [self.fromView.superview convertRect:self.fromView.frame toView:containerView];
//    }
//    else if (self.isDismissing && self.toView) {
//        self.toFrame = [self.toView.superview convertRect:self.toView.frame toView:containerView];
//    }
        
    UIImageView *imageView = nil;
    if ((self.isDismissing && !CGRectIsEmpty(self.toFrame)) || (!self.isDismissing && !CGRectIsEmpty(self.fromFrame))) {
        imageView = [[UIImageView alloc] initWithImage:self.image];
        imageView.frame = self.fromFrame;
        [containerView addSubview:imageView];
    }
    
    cropViewController.view.alpha = (self.isDismissing ? 1.0f : 0.0f);
    if (imageView) {
        [UIView animateWithDuration:[self transitionDuration:transitionContext] delay:0.0f usingSpringWithDamping:1.0f initialSpringVelocity:0.7f options:0 animations:^{
            imageView.frame = self.toFrame;
        } completion:^(BOOL complete) {
            [UIView animateWithDuration:0.1f animations:^{
                imageView.alpha = 0.0f;
            }completion:^(BOOL complete) {
                [imageView removeFromSuperview];
            }];
        }];
    }
    
    [UIView animateWithDuration:[self transitionDuration:transitionContext] animations:^{
        cropViewController.view.alpha = (self.isDismissing ? 0.0f : 1.0f);
    } completion:^(BOOL complete) {
        [self reset];
        [transitionContext completeTransition:![transitionContext transitionWasCancelled]];
    }];
}

- (void)reset
{
    self.image = nil;
    self.toView = nil;
    self.fromView = nil;
    self.fromFrame = CGRectZero;
    self.toFrame = CGRectZero;
    self.prepareForTransitionHandler = nil;
}

@end
