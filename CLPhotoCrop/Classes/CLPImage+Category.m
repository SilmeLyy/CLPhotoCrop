//
//  CLPImage+Category.m
//  CLPhotoCrop
//
//  Created by 雷玉宇 on 2022/1/28.
//

#import "CLPImage+Category.h"

@implementation UIImage(CLImage)

- (UIImage *)clp_getImageFilterForGaussianBlur:(int)blurNumber {
    CGFloat blur = blurNumber * self.size.width / [UIScreen mainScreen].bounds.size.width;
    CIContext *context = [CIContext contextWithOptions:nil];
    CIImage *inputImage = [CIImage imageWithCGImage:self.CGImage];
    CIFilter *filter = [CIFilter filterWithName:@"CIGaussianBlur"];
    [filter setDefaults];
    [filter setValue:inputImage forKey:kCIInputImageKey];
    [filter setValue:@(blur) forKey: @"inputRadius"];
    CIImage *outputImage = filter.outputImage;
    CGImageRef cgImage = [context createCGImage:outputImage fromRect:CGRectMake(0, 0, self.size.width, self.size.height)];
    UIImage *image = [UIImage imageWithCGImage:cgImage];
    if (cgImage)
    {
        CGImageRelease(cgImage);
    }
    return image;
}

- (UIImage *)clp_getImageFilterForMosaicScale:(int)scale {
    CIContext *context = [CIContext contextWithOptions:nil];
    CIImage *inputImage = [CIImage imageWithCGImage:self.CGImage];
    CIFilter *filter = [CIFilter filterWithName:@"CIPixellate"];
    [filter setDefaults];
    [filter setValue:inputImage forKey:kCIInputImageKey];
    [filter setValue:@(scale) forKey: @"inputScale"];
    CIImage *outputImage = filter.outputImage;
    CGImageRef cgImage = [context createCGImage:outputImage fromRect:CGRectMake(0, 0, self.size.width, self.size.height)];
    UIImage *image = [UIImage imageWithCGImage:cgImage];
    if (cgImage)
    {
        CGImageRelease(cgImage);
    }
    return image;
}

- (UIImage *)clp_resetSize:(CGSize)size {
    return [self clp_resetSize:size andIsScale:true];
}

- (UIImage *)clp_resetSize:(CGSize)size andIsScale:(BOOL)isScale{
    UIGraphicsBeginImageContextWithOptions(size, false, isScale ? [UIScreen mainScreen].scale : 1.0);
    [self drawInRect:CGRectMake(0, 0, size.width, size.height)];
    UIImage *snap = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return snap;
}

- (UIImage *)clp_mutableCopyImageWithHD: (BOOL)isHD
{
    return [self clp_resetSize:self.size andIsScale:isHD];
}

+ (UIImage *)clp_imageNamed: (NSString *)name {
    UIImage *image = [UIImage imageNamed:[@"CLPhotoCrop.bundle" stringByAppendingPathComponent:name]];
    return image ? image : [UIImage imageNamed:name];
}

+ (UIImage *)clp_imageEmojiNamed:(NSString *)name {
    UIImage *image = [UIImage imageNamed:[@"CLPhotoCrop.bundle" stringByAppendingPathComponent:[NSString stringWithFormat:@"Expression/%@", name]]];
    return image ? image : [UIImage imageNamed:name];
}

+ (UIImage *)clp_imageColor:(UIColor *)color {
    CGSize size = CGSizeMake(1, 1);
    UIGraphicsBeginImageContextWithOptions(size, NO, 0);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(context, color.CGColor);
    CGContextFillRect(context, CGRectMake(0, 0, 1, 1));
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}

- (UIImage *)croppedImageWithFrame:(CGRect)frame angle:(NSInteger)angle circularClip:(BOOL)circular
{
    UIImage *croppedImage = nil;
    UIGraphicsBeginImageContextWithOptions(frame.size, true, self.scale);
    CGContextRef context = UIGraphicsGetCurrentContext();
    if (circular) {
        CGContextAddEllipseInRect(context, (CGRect){CGPointZero, frame.size});
        CGContextClip(context);
    }
    if (angle != 0) {
        UIImageView *imageView = [[UIImageView alloc] initWithImage:self];
        imageView.layer.minificationFilter = kCAFilterNearest;
        imageView.layer.magnificationFilter = kCAFilterNearest;
        imageView.transform = CGAffineTransformRotate(CGAffineTransformIdentity, angle * (M_PI/180.0f));
        CGRect rotatedRect = CGRectApplyAffineTransform(imageView.bounds, imageView.transform);
        UIView *containerView = [[UIView alloc] initWithFrame:(CGRect){CGPointZero, rotatedRect.size}];
        [containerView addSubview:imageView];
        imageView.center = containerView.center;
        CGContextTranslateCTM(context, -frame.origin.x, -frame.origin.y);
        [containerView.layer renderInContext:context];
    }
    else {
        CGContextTranslateCTM(context, -frame.origin.x, -frame.origin.y);
        [self drawAtPoint:CGPointZero];
    }
    croppedImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return [UIImage imageWithCGImage:croppedImage.CGImage scale:[UIScreen mainScreen].scale orientation:UIImageOrientationUp];
}

- (UIImage *)imageRotatedByRadians:(CGFloat)radians {
    
    //定义一个执行旋转的CGAffineTransform结构体
    CGAffineTransform t = CGAffineTransformMakeRotation(radians);
    //对图片的原始区域执行旋转，获取旋转后的区域
    CGRect rotateRect = CGRectApplyAffineTransform(CGRectMake(0, 0, self.size.width, self.size.height), t);
    //获取图片旋转后的大小
    CGSize rotatedSize = rotateRect.size;
    //创建绘制位图的上下文
    UIGraphicsBeginImageContextWithOptions(rotatedSize, NO, [UIScreen mainScreen].scale);
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    //指定坐标变换，将坐标中心平移到图片中心
    CGContextTranslateCTM(ctx, rotatedSize.width/2.0, rotatedSize.height/2.0);
    //执行坐标变换，旋转过radians弧度
    CGContextRotateCTM(ctx, radians);

    //执行坐标变换，执行缩放
    CGContextScaleCTM(ctx, 1.0, -1.0);
    //绘制图片
    CGContextDrawImage(ctx, CGRectMake(-self.size.width/2.0, -self.size.height/2.0, self.size.width, self.size.height), self.CGImage);
    //获取绘制后生成的新图片
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newImage;
    
}
@end
