//
//  CLColorDoobleView.m
//  CLPhotoCrop
//
//  Created by 雷玉宇 on 2022/1/28.
//

#import "CLColorDoobleView.h"

@implementation CLBaseDoobleView

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.userInteractionEnabled = false;
        self.backgroundColor = [UIColor clearColor];
        self.paths = @[].mutableCopy;
    }
    return self;
}

- (void)drawRect:(CGRect)rect {
    CGContextRef context = UIGraphicsGetCurrentContext();
    for (CLPath *path in self.paths) {
        [path.color set];
        CGContextSetLineCap(context, path.bzPath.lineCapStyle);
        CGContextSetLineJoin(context, path.bzPath.lineJoinStyle);
        CGContextSetLineWidth(context, path.bzPath.lineWidth);
        CGContextAddPath(context, path.bzPath.CGPath);
        CGContextDrawPath(context, kCGPathStroke);
    }
}

- (void)moveToPoint:(CGPoint)point {
    CLPath *path = [[CLPath alloc] init];
    path.color = self.doodleColor;
    path.bzPath.lineWidth = self.lineWidth;
    [path.bzPath moveToPoint:point];
    [self.paths addObject:path];
    [self setNeedsDisplay];
}

- (void)addLinePoint:(CGPoint)point {
    CLPath *path = [self.paths lastObject];
    [path.bzPath addLineToPoint:point];
    [self setNeedsDisplay];
}


- (void)previous {
    if (self.paths.count) {
        [self.paths removeLastObject];
        [self setNeedsDisplay];
    }
}

@end

@implementation CLColorDoobleView


@end

@implementation CLPath

- (instancetype)init
{
    self = [super init];
    if (self) {
        _bzPath = [UIBezierPath bezierPath];
        _bzPath.lineCapStyle  = kCGLineCapRound;
        _bzPath.lineJoinStyle = kCGLineJoinRound;
    }
    return self;
}

@end
