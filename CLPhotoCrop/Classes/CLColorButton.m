//
//  CLColorButton.m
//  CLPhotoCrop
//
//  Created by 雷玉宇 on 2022/1/27.
//

#import "CLColorButton.h"

@interface CLColorButton()

@property (nonatomic, assign) CGFloat radius;
@property (nonatomic, strong) UIColor *color;

@end

@implementation CLColorButton

- (void)drawRect:(CGRect)rect {
    [super drawRect:rect];
    CGFloat currRadius = _radius ? _radius + (self.isSelected ? 4 : 2) : 0;
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    // 绘制外侧大圆
    CGContextAddArc(context, rect.size.width/2, rect.size.height/2, currRadius, 0, 2 *M_PI, 1);
    [[UIColor whiteColor] set];
    CGContextClip(context);
    CGContextFillRect(context, rect);
    
    // 绘制小圆
    CGContextAddArc(context, rect.size.width/2, rect.size.height/2, _radius, 0, 2 *M_PI, 1);
    [_color set];
    CGContextClip(context);
    CGContextFillRect(context, rect);
}

- (void)drawRadius:(CGFloat)radius andColor:(UIColor *)color {
    self.radius = radius;
    self.color = color;
}

@end
