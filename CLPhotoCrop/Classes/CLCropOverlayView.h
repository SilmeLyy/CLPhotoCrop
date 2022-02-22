//
//  CLCropOverlayView.h
//  CLPhotoCrop
//
//  Created by 雷玉宇 on 2022/2/8.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface CLCropOverlayView : UIView

@property (nonatomic, assign) BOOL gridHidden;

@property (nonatomic, assign) BOOL displayHorizontalGridLines;

@property (nonatomic, assign) BOOL displayVerticalGridLines;

- (void)setGridHidden:(BOOL)hidden animated:(BOOL)animated;

@end

NS_ASSUME_NONNULL_END
