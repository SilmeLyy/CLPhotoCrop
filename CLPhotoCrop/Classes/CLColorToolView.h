//
//  CLColorToolView.h
//  CLPhotoCrop
//
//  Created by 雷玉宇 on 2022/1/27.
//

#import <UIKit/UIKit.h>
#import "CLBaseToolView.h"

NS_ASSUME_NONNULL_BEGIN

@protocol CLColorToolViewDelegate <NSObject>

- (void)CLColorToolViewCLickColor: (UIColor *)color;

@optional
- (void)CLColorToolViewChangeLineWidth: (CGFloat)lineWidth;
- (void)CLColorToolViewCLickProvious;

@end

@interface CLColorToolView : CLBaseToolView

@property (nonatomic, weak) id<CLColorToolViewDelegate> delegate;

/// type 0  1
- (instancetype)initWithType: (NSInteger)type;

@end

NS_ASSUME_NONNULL_END
