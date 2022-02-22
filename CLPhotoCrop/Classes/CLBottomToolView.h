//
//  CLBottomToolView.h
//  CLPhotoCrop
//
//  Created by 雷玉宇 on 2022/1/28.
//

#import <UIKit/UIKit.h>
#import "CLBaseToolView.h"

NS_ASSUME_NONNULL_BEGIN
@protocol CLBottomToolViewDelegate <NSObject>

- (void)CLBottomToolViewCLickItemBtn: (UIButton *)btn;
- (void)CLBottomToolViewCLickDoneBtn;

@end

@interface CLBottomToolView : CLBaseToolView

@property (nonatomic, weak) id<CLBottomToolViewDelegate> delegate;

@end

NS_ASSUME_NONNULL_END
