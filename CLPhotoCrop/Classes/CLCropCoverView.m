//
//  CLCropCoverView.m
//  CLPhotoCrop
//
//  Created by 雷玉宇 on 2022/2/10.
//

#import "CLCropCoverView.h"
#import "CLPhotoCrop.h"

@interface CLCropCoverView()

@property (nonatomic, strong) NSArray *coversLayers;

@end

@implementation CLCropCoverView

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.userInteractionEnabled = false;
        [self initView];
    }
    return self;
}

- (void)setEmptRect:(CGRect)emptRect {
    _emptRect = emptRect;
    CALayer *layer1 = _coversLayers[0];
    layer1.frame = CGRectMake(0, 0, CLP_SCREENWIDTH, emptRect.origin.y - 3);
    CALayer *layer2 = _coversLayers[1];
    layer2.frame = CGRectMake(0, emptRect.origin.y - 3, emptRect.origin.x - 3, emptRect.size.height + 6);
    CALayer *layer3 = _coversLayers[2];
    layer3.frame = CGRectMake(0, CGRectGetMaxY(emptRect) + 3, CLP_SCREENWIDTH, self.bounds.size.height - CGRectGetMaxY(emptRect) - 3);
    CALayer *layer4 = _coversLayers[3];
    layer4.frame = CGRectMake(CGRectGetMaxX(emptRect) + 3, emptRect.origin.y - 3, self.bounds.size.width - CGRectGetMaxX(emptRect) - 3, emptRect.size.height + 6);
    
    
    CALayer *layer5 = _coversLayers[4];
//    layer5.backgroundColor = [[UIColor redColor] CGColor];
    layer5.frame = CGRectMake(emptRect.origin.x + 20, emptRect.origin.y - 4, emptRect.size.width - 40, 3);
    CALayer *layer6 = _coversLayers[5];
//    layer6.backgroundColor = [[UIColor redColor] CGColor];
    layer6.frame = CGRectMake(emptRect.origin.x - 4, emptRect.origin.y + 20, 3, emptRect.size.height - 40);
    CALayer *layer7 = _coversLayers[6];
//    layer7.backgroundColor = [[UIColor redColor] CGColor];
    layer7.frame = CGRectMake(emptRect.origin.x + 20, CGRectGetMaxY(emptRect) + 1, emptRect.size.width - 40, 3);
    CALayer *layer8 = _coversLayers[7];
//    layer8.backgroundColor = [[UIColor redColor] CGColor];
    layer8.frame = CGRectMake(CGRectGetMaxX(emptRect) + 1, emptRect.origin.y + 20, 3, emptRect.size.height - 40);
}

- (void)show {
    for (CALayer *layer in _coversLayers) {
        layer.hidden = false;
    }
}

- (void)dismiss {
    for (CALayer *layer in _coversLayers) {
        layer.hidden = true;
    }
}

- (void)initView {
    _coversLayers = @[[self createLayer],
                      [self createLayer],
                      [self createLayer],
                      [self createLayer],
                      [self createLayer],
                      [self createLayer],
                      [self createLayer],
                      [self createLayer]];
}

- (CALayer *)createLayer {
    CALayer *layer = [[CALayer alloc] init];
    layer.backgroundColor = [[UIColor colorWithWhite:0 alpha:0.6] CGColor];
    [self.layer addSublayer:layer];
    return layer;
}

@end
