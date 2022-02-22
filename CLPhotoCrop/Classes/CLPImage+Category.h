//
//  CLPImage+Category.h
//  CLPhotoCrop
//
//  Created by 雷玉宇 on 2022/1/28.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UIImage(CLImage)

/// 高斯模糊滤镜
- (UIImage *)clp_getImageFilterForGaussianBlur:(int)blurNumber;
/// 马赛克滤镜
- (UIImage *)clp_getImageFilterForMosaicScale:(int)scale;

- (UIImage *)clp_resetSize: (CGSize)size;

- (UIImage *)clp_resetSize: (CGSize)size andIsScale: (BOOL)isScale;

- (UIImage *)clp_mutableCopyImageWithHD: (BOOL)isHD;

+ (UIImage *)clp_imageNamed: (NSString *)name;

+ (UIImage *)clp_imageColor:(UIColor *)color;

+ (UIImage *)clp_imageEmojiNamed: (NSString *)name;

- (UIImage *)croppedImageWithFrame:(CGRect)frame angle:(NSInteger)angle circularClip:(BOOL)circular;
@end

NS_ASSUME_NONNULL_END
