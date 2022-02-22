//
//  CLPSImageView.m
//  CLPhotoCrop
//
//  Created by 雷玉宇 on 2022/1/26.
//

#import "CLPSImageView.h"
#import "CLColorDoobleView.h"
#import "CLMosaicDoobleView.h"
#import "CLDrawBaseView.h"

@interface CLPSImageView()

@property (nonatomic, strong) UITapGestureRecognizer *tap;
@property (nonatomic, strong) UIPanGestureRecognizer *pan;

@property (nonatomic, strong) UIImage *relaImage;

@property (nonatomic, strong) CLBaseDoobleView *currDoobleView;
@property (nonatomic, strong) CLColorDoobleView *colorDoobleView;
@property (nonatomic, strong) CLMosaicDoobleView *mosaicDoobleView;

@end

@implementation CLPSImageView

- (instancetype)init
{
    self = [super init];
    if (self) {
        _pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(doodlePan:)];
        _tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapView)];
        _pan.enabled = false;
        _tap.enabled = false;
        self.backgroundColor = [UIColor clearColor];
        self.doodleColor = [UIColor whiteColor];
        self.lineWidth = 3;
        [self addSubview:self.mosaicDoobleView];
        [self addSubview:self.colorDoobleView];
        self.clipsToBounds = true;
    }
    return self;
}

- (void)setImage:(UIImage *)image {
    _image = image;
    _relaImage = image;
    [self setNeedsDisplay];
    [self configGaussanAndMosaicImage];
}

- (void)setDrawMode:(CLPDrawMode)drawMode {
    _drawMode = drawMode;
    if (drawMode == CLPDrawModeColor) {
        self.currDoobleView = self.colorDoobleView;
    } else {
        self.mosaicDoobleView.drawMode = drawMode;
        self.currDoobleView = self.mosaicDoobleView;
    }
}

- (void)setLineWidth:(CGFloat)lineWidth {
    _lineWidth = lineWidth;
    self.colorDoobleView.lineWidth = lineWidth;
}

- (void)setDoodleColor:(UIColor *)doodleColor {
    _doodleColor = doodleColor;
    self.colorDoobleView.doodleColor = doodleColor;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    self.colorDoobleView.frame = self.bounds;
    self.mosaicDoobleView.frame = self.bounds;
}

- (void)configGaussanAndMosaicImage {
    CGSize imageSize = _image.size;
    CGFloat ratio = MIN(CLP_SCREENWIDTH / imageSize.width, CLP_SCREENHEIGHT / imageSize.height);
    CGFloat W = ratio * imageSize.width;
    CGFloat H = ratio * imageSize.height;
    CGSize size = CGSizeMake(W, H);
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        UIImage *filterGaussan = [[self.image clp_resetSize:size andIsScale:false] clp_getImageFilterForGaussianBlur:15] ;
        UIImage *filterMosaic = [[self.image clp_resetSize:size andIsScale:false] clp_getImageFilterForMosaicScale:15] ;
        dispatch_async(dispatch_get_main_queue(), ^{
            self.mosaicDoobleView.gaussanImage = filterGaussan;
            self.mosaicDoobleView.mosaicImage = filterMosaic;
        });
    });
}

- (void)drawRect:(CGRect)rect {
    if (self.relaImage) {
        CGRect rectImage = CGRectMake(0.0, 0.0, rect.size.width, rect.size.height);
        [self.relaImage drawInRect:rectImage];
    }
}

- (void)doodlePan: (UIGestureRecognizer *)pan {
    CGPoint point = [pan locationInView:self];
    if (pan.state == UIGestureRecognizerStateBegan) {
        [self.currDoobleView moveToPoint:point];
        if (self.drawStart) {
            self.drawStart();
        }
    } else if (pan.state == UIGestureRecognizerStateChanged) {
        [self.currDoobleView addLinePoint:point];
        if (self.drawIng) {
            self.drawIng();
        }
    } else {
        if (self.drawEnd) {
            self.drawEnd();
        }
    }
}

- (void)tapView {
    
}

- (void)activeDoodle {
    self.userInteractionEnabled = true;
    _pan.enabled = true;
    _tap.enabled = true;
    [self addGestureRecognizer:_pan];
    [self addGestureRecognizer:_tap];
}

- (void)disableDooble {
    self.userInteractionEnabled = false;
    _pan.enabled = false;
    _tap.enabled = false;
    [self removeGestureRecognizer:_pan];
    [self removeGestureRecognizer:_tap];
}

- (void)previous {
    if (self.currDoobleView) {
        [self.currDoobleView previous];
    }
}

- (UIImage *)buildImage {
    CGFloat width = self.frame.size.width;
    CGFloat height = width * self.image.size.height / self.image.size.width;
    UIGraphicsBeginImageContextWithOptions(CGSizeMake(width, height), false, CLP_SCALE);
    CGContextRef context = UIGraphicsGetCurrentContext();
    for (CLDrawBaseView *drawView in self.subviews) {
        if ([drawView isKindOfClass:[CLDrawBaseView class]]) {
            drawView.active = false;
        }
    }
    [self.layer renderInContext:context];
    UIImage *snap = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return snap;
}

- (void)clear {
    for (CLDrawBaseView *drawView in self.subviews) {
        if ([drawView isKindOfClass:[CLDrawBaseView class]]) {
            [drawView removeFromSuperview];
        }
    }
    [self.colorDoobleView.paths removeAllObjects];
    [self.colorDoobleView setNeedsDisplay];
    [self.mosaicDoobleView.paths removeAllObjects];
    [self.mosaicDoobleView setNeedsDisplay];
}

- (CLMosaicDoobleView *)mosaicDoobleView {
    if (!_mosaicDoobleView) {
        _mosaicDoobleView = [[CLMosaicDoobleView alloc] init];
    }
    return _mosaicDoobleView;
}

- (CLColorDoobleView *)colorDoobleView {
    if (!_colorDoobleView) {
        _colorDoobleView = [[CLColorDoobleView alloc] init];
    }
    return _colorDoobleView;
}

@end

