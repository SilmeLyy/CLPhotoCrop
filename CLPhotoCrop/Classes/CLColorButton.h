//
//  CLColorButton.h
//  CLPhotoCrop
//
//  Created by 雷玉宇 on 2022/1/27.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface CLColorButton : UIButton

- (void)drawRadius: (CGFloat)radius andColor: (UIColor *)color;

@end

NS_ASSUME_NONNULL_END
