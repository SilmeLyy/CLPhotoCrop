//
//  CLMosaicToolView.h
//  CLPhotoCrop
//
//  Created by 雷玉宇 on 2022/1/28.
//

#import <UIKit/UIKit.h>
#import "CLBaseToolView.h"

NS_ASSUME_NONNULL_BEGIN
@protocol CLMosaicToolViewDelegate <NSObject>

- (void)CLMosaicToolViewClickPreviousBtn;
- (void)CLMosaicToolViewClickItemBtn: (UIButton *)btn;

@end

@interface CLMosaicToolView : CLBaseToolView

@property (nonatomic, weak) id<CLMosaicToolViewDelegate> delegate;

@end

NS_ASSUME_NONNULL_END
