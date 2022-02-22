//
//  CLMosaicDoobleView.h
//  CLPhotoCrop
//
//  Created by 雷玉宇 on 2022/1/28.
//

#import <UIKit/UIKit.h>
#import "CLColorDoobleView.h"
#import "CLPhotoCrop.h"

NS_ASSUME_NONNULL_BEGIN

@interface CLMosaicDoobleView : CLBaseDoobleView

/// 高斯模糊图
@property (nonatomic, strong) UIImage *gaussanImage;
/// 高斯模糊图
@property (nonatomic, strong) UIImage *mosaicImage;
/// 当前绘制模式
@property (nonatomic, assign) CLPDrawMode drawMode;

@end

NS_ASSUME_NONNULL_END
