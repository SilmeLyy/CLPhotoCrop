//
//  CLCropToolView.h
//  CLPhotoCrop
//
//  Created by 雷玉宇 on 2022/2/8.
//

#import <UIKit/UIKit.h>
#import "CLBaseToolView.h"

NS_ASSUME_NONNULL_BEGIN

@protocol CLCropToolViewDelegate <NSObject>

- (void)cropToolViewClickDoneBtn;
- (void)cropToolViewClickCloseBtn;
- (void)cropToolViewClickResetBtn;
- (void)cropToolViewClickRotateBtn;

@end

@interface CLCropToolView : CLBaseToolView

@property (nonatomic, assign) BOOL resetButtonEnabled;
@property (nonatomic, weak) id<CLCropToolViewDelegate> delegate;

@end

NS_ASSUME_NONNULL_END
