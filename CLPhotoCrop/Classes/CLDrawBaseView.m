//
//  CLDrawBaseView.m
//  CLPhotoCrop
//
//  Created by 雷玉宇 on 2022/2/7.
//

#import "CLDrawBaseView.h"
#import "CLPhotoCrop.h"


static const CGFloat MIN_TEXT_SCAL = 0.3f;
static const CGFloat MAX_TEXT_SCAL = 4.0f;

@interface CLDrawBaseView()

@property (nonatomic, strong) CAShapeLayer *lineLayer;

@end

@implementation CLDrawBaseView

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        _lineLayer = [[CAShapeLayer alloc] init];
        _lineLayer.lineWidth = 1;
        _lineLayer.strokeColor = [UIColor whiteColor].CGColor;
        _lineLayer.fillColor = [UIColor clearColor].CGColor;
        self.scale = 1;
        self.rotation = 0;
        [self.layer addSublayer:_lineLayer];
        [self initGestures];
    }
    return self;
}

- (void)setFrame:(CGRect)frame {
    [super setFrame:frame];
    UIBezierPath *path = [UIBezierPath bezierPathWithRect:self.bounds];
    self.lineLayer.path = path.CGPath;
}

- (void)initGestures {
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(viewDidTap:)];
    UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(viewDidPan:)];
    UIPinchGestureRecognizer *pinch = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(viewDidPinch:)];
    UIRotationGestureRecognizer *rotation = [[UIRotationGestureRecognizer alloc] initWithTarget:self action:@selector(viewDidRotation:)];
    
    [pinch requireGestureRecognizerToFail:tap];
    [rotation requireGestureRecognizerToFail:tap];
    
    [[CLPhotoCropManager instance].scrollview.panGestureRecognizer requireGestureRecognizerToFail:pan];
    
    tap.delegate = [CLPhotoCropManager instance];
    pan.delegate = [CLPhotoCropManager instance];
    pinch.delegate = [CLPhotoCropManager instance];
    rotation.delegate = [CLPhotoCropManager instance];
    
    [self addGestureRecognizer:tap];
    [self addGestureRecognizer:pan];
    [self addGestureRecognizer:pinch];
    [self addGestureRecognizer:rotation];
}

- (void)setActive:(BOOL)active {
    _active = active;
    if (_active) {
        self.lineLayer.hidden = false;
    } else {
        self.lineLayer.hidden = true;
    }
}

- (void)viewDidTap:(UITapGestureRecognizer*)sender
{
    if (sender.state == UIGestureRecognizerStateBegan) {
        if ([_delegate respondsToSelector:@selector(drawBaseViewWith:)]) {
            [_delegate drawBaseViewWith:self];
        }
    } else if (sender.state == UIGestureRecognizerStateChanged) {
        
    } else {
        if ([_delegate respondsToSelector:@selector(drawBaseViewInvalidate)]) {
            [_delegate drawBaseViewInvalidate];
        }
    }
}

- (void)viewDidPan:(UIPanGestureRecognizer*)recognizer
{
    //平移
    CGPoint vPoint = [recognizer locationInView:self.superview.superview.superview];
    CGPoint translation = [recognizer translationInView:self.superview];
    self.center = CGPointMake(self.center.x + translation.x, self.center.y + translation.y);
    [recognizer setTranslation:CGPointZero inView:self.superview];

    if (recognizer.state == UIGestureRecognizerStateBegan) {
        if ([_delegate respondsToSelector:@selector(drawBaseViewWith:)]) {
            [_delegate drawBaseViewWith:self];
        }
        if ([_delegate respondsToSelector:@selector(drawBaseViewMoveStart)]) {
            [_delegate drawBaseViewMoveStart];
        }
    } else if (recognizer.state == UIGestureRecognizerStateChanged) {
        if ([_delegate respondsToSelector:@selector(drawBaseViewMovePoint: andDrawView:)]) {
            [_delegate drawBaseViewMovePoint:vPoint andDrawView: self];
        }
    } else {
        if ([_delegate respondsToSelector:@selector(drawBaseViewInvalidate)]) {
            [_delegate drawBaseViewInvalidate];
        }
        if ([_delegate respondsToSelector:@selector(drawBaseViewMoveEndPoint:andDrawView:)]) {
            [_delegate drawBaseViewMoveEndPoint:vPoint andDrawView: self];
        }
    }
}

- (void)viewDidPinch:(UIPinchGestureRecognizer *)recognizer {
    //缩放
    if (recognizer.state == UIGestureRecognizerStateBegan) {
        if ([_delegate respondsToSelector:@selector(drawBaseViewWith:)]) {
            [_delegate drawBaseViewWith:self];
        }
    } else if (recognizer.state == UIGestureRecognizerStateChanged) {
        CGFloat currentScale = recognizer.scale;
        if (self.scale > MAX_TEXT_SCAL && currentScale > 1) {
            return;
        }
        if (self.scale < MIN_TEXT_SCAL && currentScale < 1) {
            return;
        }
        self.scale = currentScale;
        self.transform = CGAffineTransformScale(self.transform, currentScale, currentScale);
        recognizer.scale = 1;
        [self layoutSubviews];
    } else {
        if ([_delegate respondsToSelector:@selector(drawBaseViewInvalidate)]) {
            [_delegate drawBaseViewInvalidate];
        }
    }
}

- (void)viewDidRotation:(UIRotationGestureRecognizer *)recognizer {
    //旋转
    if (recognizer.state == UIGestureRecognizerStateBegan) {
        if ([_delegate respondsToSelector:@selector(drawBaseViewWith:)]) {
            [_delegate drawBaseViewWith:self];
        }
    } else if (recognizer.state == UIGestureRecognizerStateChanged) {
        self.transform = CGAffineTransformRotate(self.transform, recognizer.rotation);
        _rotation = _rotation + recognizer.rotation;
        recognizer.rotation = 0;
        [self layoutSubviews];
    } else {
        if ([_delegate respondsToSelector:@selector(drawBaseViewInvalidate)]) {
            [_delegate drawBaseViewInvalidate];
        }
    }
}

- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event
{
    UIView *view = [super hitTest:point withEvent:event];
    if(view == self) {
        return self;
    }
    return view;
}

@end
