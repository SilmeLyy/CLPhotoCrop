//
//  CLCropsView.h
//  CLPhotoCrop
//
//  Created by 雷玉宇 on 2022/2/8.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@protocol CLCropsViewDelegate <NSObject>

- (void)cropsViewIsReset: (BOOL)isReset;

@end

@interface CLCropsView : UIView

@property (nonatomic, strong) UIImage *image;
@property (nonatomic, assign) UIEdgeInsets cropRegionInsets;
@property (nonatomic, assign) BOOL aspectRatioLockEnabled;
@property (nonatomic, assign) CGSize aspectRatio;
@property (nonatomic, assign) BOOL canBeReset;
@property (nonatomic, assign) NSInteger angle;
@property (nonatomic, assign) CGRect imageCropFrame;
@property (nonatomic, assign) CGRect cropBoxFrame;
@property (nonatomic, readonly) CGRect imageViewFrame;
@property (nonatomic, assign) BOOL croppingViewsHidden;
@property (nonatomic, assign) BOOL gridOverlayHidden;
@property (nonatomic, weak) id<CLCropsViewDelegate> delegate;

- (void)reset;
- (void)rotateImage;
- (void)rotateImageAnimated: (BOOL)animated;
- (void)rotateImageAnimated: (BOOL)animated andClockwise: (BOOL)clockwise;
- (void)setCroppingViewsHidden:(BOOL)hidden animated:(BOOL)animated;
- (void)setGridOverlayHidden:(BOOL)gridOverlayHidden animated:(BOOL)animated;

@end

NS_ASSUME_NONNULL_END
