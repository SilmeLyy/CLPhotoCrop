//
//  CLTextInputView.h
//  CLPhotoCrop
//
//  Created by 雷玉宇 on 2022/2/7.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@protocol CLTextInputViewDelegate <NSObject>

- (void)textInputViewComplete: (NSString *)string andColor: (UIColor *)color;

@end

@interface CLTextInputView : UIView

@property (nonatomic, weak) id<CLTextInputViewDelegate> delegate;

- (void)showWith: (UIView *)superView;

@end

NS_ASSUME_NONNULL_END
