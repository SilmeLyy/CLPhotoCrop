//
//  CLEmojiBoardView.h
//  CLPhotoCrop
//
//  Created by 雷玉宇 on 2022/2/21.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@protocol CLEmojiBoardViewDelegate <NSObject>

- (void)emojiBoardViewClickIndexPath: (NSIndexPath *)indexPath andImage: (UIImage *)image;

@end

@interface CLEmojiBoardView : UIView

@property (nonatomic, weak) id<CLEmojiBoardViewDelegate> delegate;

- (void)show;
- (void)dismiss;

@end

NS_ASSUME_NONNULL_END
