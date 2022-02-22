//
//  CLColorDoobleView.h
//  CLPhotoCrop
//
//  Created by 雷玉宇 on 2022/1/28.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@class CLPath;
@interface CLBaseDoobleView : UIView

@property (nonatomic, strong) NSMutableArray<CLPath *> *paths;
/// 当前选中画笔的颜色
@property (nonatomic, strong) UIColor *doodleColor;
/// 画笔宽度
@property (nonatomic, assign) CGFloat lineWidth;

- (void)moveToPoint: (CGPoint)point;
- (void)addLinePoint: (CGPoint)point;
- (void)previous;

@end

@interface CLColorDoobleView : CLBaseDoobleView



@end

@interface CLPath : NSObject

@property (nonatomic, strong) UIBezierPath *bzPath;
@property (nonatomic, strong) UIColor *color;

@end

NS_ASSUME_NONNULL_END
