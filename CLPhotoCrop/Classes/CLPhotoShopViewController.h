//
//  CLPhotoShopViewController.h
//  CLPhotoCrop
//
//  Created by 雷玉宇 on 2022/1/26.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@protocol CLPhotoShopViewControllerDelegate <NSObject>

- (void)CLPhotoShopViewControllerFinishImage: (UIImage *)image;

@end

@interface CLPhotoShopViewController : UIViewController

@property (nonatomic, strong) UIImage *orgImage;
@property (nonatomic, weak) id<CLPhotoShopViewControllerDelegate> delegate;

@end

NS_ASSUME_NONNULL_END
