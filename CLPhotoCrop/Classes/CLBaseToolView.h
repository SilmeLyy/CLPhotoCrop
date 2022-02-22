//
//  CLBaseToolView.h
//  CLPhotoCrop
//
//  Created by 雷玉宇 on 2022/1/27.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface CLBaseToolView : UIView

@property (nonatomic, strong) UIButton *__nullable lastBtn;

- (void)hiddenTool;
- (void)showTool: (UIView *)superView;

@end

NS_ASSUME_NONNULL_END
