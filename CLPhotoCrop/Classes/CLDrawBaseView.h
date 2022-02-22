//
//  CLDrawBaseView.h
//  CLPhotoCrop
//
//  Created by 雷玉宇 on 2022/2/7.
//

#import <UIKit/UIKit.h>


NS_ASSUME_NONNULL_BEGIN

@class CLDrawBaseView;
@protocol CLDrawBaseViewDelegate <NSObject>

- (void)drawBaseViewWith: (CLDrawBaseView *)drawView;
- (void)drawBaseViewInvalidate;
- (void)drawBaseViewMovePoint: (CGPoint)point andDrawView: (CLDrawBaseView *)drawView;
- (void)drawBaseViewMoveStart;
- (void)drawBaseViewMoveEndPoint:(CGPoint)point andDrawView: (CLDrawBaseView *)drawView;

@end

@interface CLDrawBaseView : UIView

@property (nonatomic, weak) id<CLDrawBaseViewDelegate> delegate;

@property (nonatomic, assign) CGRect drawRect;
@property (nonatomic, assign) CGFloat rotation;
@property (nonatomic, assign) CGFloat scale;

@property (nonatomic, assign) BOOL active;

@end

NS_ASSUME_NONNULL_END
