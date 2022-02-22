//
//  CLPSImageView.h
//  CLPhotoCrop
//
//  Created by 雷玉宇 on 2022/1/26.
//

#import <UIKit/UIKit.h>
#import "CLPhotoCrop.h"

NS_ASSUME_NONNULL_BEGIN


@interface CLPSImageView : UIView

@property (nonatomic, strong) UIImage *image;
/// 当前选中画笔的颜色
@property (nonatomic, strong) UIColor *doodleColor;
/// 画笔宽度
@property (nonatomic, assign) CGFloat lineWidth;
/// 当前绘制模式
@property (nonatomic, assign) CLPDrawMode drawMode;

@property (nonatomic, copy) void(^drawStart)(void);
@property (nonatomic, copy) void(^drawIng)(void);
@property (nonatomic, copy) void(^drawEnd)(void);

/// 激活画笔功能
- (void)activeDoodle;
/// 禁用画笔功能
- (void)disableDooble;
/// 上一步
- (void)previous;
/// 生成模糊和马赛克图片
- (void)configGaussanAndMosaicImage;

- (UIImage *)buildImage;

- (void)clear;

@end




NS_ASSUME_NONNULL_END
