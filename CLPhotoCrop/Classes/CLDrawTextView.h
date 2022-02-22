//
//  CLDrawTextView.h
//  CLPhotoCrop
//
//  Created by 雷玉宇 on 2022/2/7.
//

#import <UIKit/UIKit.h>
#import "CLDrawBaseView.h"

NS_ASSUME_NONNULL_BEGIN

@interface CLDrawTextView : CLDrawBaseView

@property (nonatomic, copy) NSString *text;
@property (nonatomic, strong) UIColor *textColor;
@property (nonatomic, strong) UIFont *font;

@end

NS_ASSUME_NONNULL_END
