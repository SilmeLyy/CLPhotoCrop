//
//  CLBaseToolView.m
//  CLPhotoCrop
//
//  Created by 雷玉宇 on 2022/1/27.
//

#import "CLBaseToolView.h"

@implementation CLBaseToolView

- (instancetype)init
{
    self = [super init];
    if (self) {
        
    }
    return self;
}

- (void)hiddenTool {
    [UIView animateWithDuration:.25 animations:^{
        self.alpha = 0;
    } completion:^(BOOL finished) {
        [self removeFromSuperview];
    }];
}

- (void)showTool:(UIView *)superView {
    [superView addSubview:self];
    [UIView animateWithDuration:.25 animations:^{
        self.alpha = 1;
    } completion:^(BOOL finished) {
    }];
}
@end
