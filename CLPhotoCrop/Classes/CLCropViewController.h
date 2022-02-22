//
//  CLCropViewController.h
//  CLPhotoCrop
//
//  Created by 雷玉宇 on 2022/2/8.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@class CLCropViewController;
@protocol CLCropViewControllerDelegate <NSObject>

- (void)clCropViewControllerDoneImage: (UIImage *)image fromCropViewController:(CLCropViewController *)cropViewController;
- (void)clCropViewControllerCancelfromCropViewController:(CLCropViewController *)cropViewController;

@end

@interface CLCropViewController : UIViewController

@property (nonatomic, strong) UIImage *image;
@property (nonatomic, assign) NSInteger angle;
@property (nonatomic, assign) CGRect imageCropFrame;
@property (nonatomic, weak) id<CLCropViewControllerDelegate> delegate;


- (void)presentAnimatedFromParentViewController:(UIViewController *)viewController
                                      fromImage:(UIImage *)image
                                       fromView:(nullable UIView *)fromView
                                      fromFrame:(CGRect)fromFrame
                                          angle:(NSInteger)angle
                                   toImageFrame:(CGRect)toFrame
                                          setup:(void (^)(void))setup
                                     completion:(void (^)(void))completion;

- (void)dismissAnimatedFromParentViewController:(UIViewController *)viewController
                               withCroppedImage:(nullable UIImage *)image
                                         toView:(UIView *)toView
                                        toFrame:(CGRect)frame
                                          setup:(void (^)(void))setup
                                     completion:(void (^)(void))completion;
@end

NS_ASSUME_NONNULL_END
