//
//  CLCropCoverView.h
//  CLPhotoCrop
//
//  Created by 雷玉宇 on 2022/2/10.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface CLCropCoverView : UIView

@property (nonatomic, assign) CGRect emptRect;


- (void)show;
- (void)dismiss;

@end

NS_ASSUME_NONNULL_END
