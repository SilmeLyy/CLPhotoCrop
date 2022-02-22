//
//  CLCropsView.m
//  CLPhotoCrop
//
//  Created by 雷玉宇 on 2022/2/8.
//

#import "CLCropsView.h"
#import "CLCropOverlayView.h"
#import "CLCropCoverView.h"

typedef NS_ENUM(NSInteger, CLCropViewOverlayEdge) {
    CLCropViewOverlayEdgeNone,
    CLCropViewOverlayEdgeTopLeft,
    CLCropViewOverlayEdgeTop,
    CLCropViewOverlayEdgeTopRight,
    CLCropViewOverlayEdgeRight,
    CLCropViewOverlayEdgeBottomRight,
    CLCropViewOverlayEdgeBottom,
    CLCropViewOverlayEdgeBottomLeft,
    CLCropViewOverlayEdgeLeft
};

static const CGFloat CLCropViewPadding = 14.0f;
static const CGFloat CLCropViewMinimumBoxSize = 42.0f;
//static const CGFloat CLCropViewCircularPathRadius = 300.0f;

@interface CLCropsView()<UIGestureRecognizerDelegate, UIScrollViewDelegate>

@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, strong) CLCropOverlayView *overlayView;
@property (nonatomic, strong) CLCropCoverView *coverView;
@property (nonatomic, assign) CLCropViewOverlayEdge tappedEdge;
@property (nonatomic, strong) UIPanGestureRecognizer *panges;
@property (nonatomic, strong) UIView *containerView;
@property (nonatomic, strong) UIImageView *imageView;


@property (nonatomic, assign) BOOL rotateAnimationInProgress;


@property (nonatomic, assign) CGRect cropOriginFrame;
@property (nonatomic, assign) CGRect cropOriginImageFrame;
@property (nonatomic, assign) CGPoint panOriginPoint;

@property (nonatomic, assign) CGRect imagrOrgFrame;

/// 初始化的属性，用来判断是否编辑过图片，还原按钮是否可用
@property (nonatomic, assign) CGSize originalCropBoxSize;
@property (nonatomic, assign) CGPoint originalContentOffset;

@end

@implementation CLCropsView


- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self initView];
    }
    return self;
}

- (void)initView {
    self.panges = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panOverlayGes:)];
    self.panges.delegate = self;
    [self addGestureRecognizer:self.panges];

    self.scrollView = [[UIScrollView alloc] initWithFrame:self.bounds];
    self.scrollView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    self.scrollView.alwaysBounceHorizontal = YES;
    self.scrollView.alwaysBounceVertical = YES;
    self.scrollView.showsHorizontalScrollIndicator = NO;
    self.scrollView.showsVerticalScrollIndicator = NO;
    self.scrollView.delegate = self;
    if (@available(iOS 11.0, *)) {
        [self.scrollView setContentInsetAdjustmentBehavior:UIScrollViewContentInsetAdjustmentNever];
    }
    [self.scrollView.panGestureRecognizer requireGestureRecognizerToFail:self.panges];
    [self addSubview:self.scrollView];
    
    self.imageView = [[UIImageView alloc] initWithImage:self.image];
    
    self.containerView = [[UIView alloc] initWithFrame:self.imageView.frame];
    [self.containerView addSubview:self.imageView];
    [self.scrollView addSubview:self.containerView];
    
    self.overlayView = [[CLCropOverlayView alloc] init];
    self.overlayView.displayVerticalGridLines = true;
    self.overlayView.displayHorizontalGridLines = true;
    [self addSubview:self.overlayView];
    
    self.coverView = [[CLCropCoverView alloc] init];
    [self addSubview:self.coverView];
}

- (void)setCanBeReset:(BOOL)canBeReset {
    _canBeReset = canBeReset;
    if ([_delegate respondsToSelector:@selector(cropsViewIsReset:)]) {
        [_delegate cropsViewIsReset: canBeReset];
    }
}

- (void)setImage:(UIImage *)image {
    _image = image;
    self.imageView.image = image;
}

- (void)reset {
    [self.overlayView setGridHidden:true animated:false];
    self.canBeReset = false;
    self.cropOriginImageFrame = self.imagrOrgFrame;
    self.overlayView.hidden = true;
    self.coverView.hidden = true;
    self.angle = 0;
    [self.coverView dismiss];
    [UIView animateWithDuration:0.50f delay:0.0f usingSpringWithDamping:1.0f initialSpringVelocity:1.0f options:UIViewAnimationOptionBeginFromCurrentState animations:^{
        self.imageView.transform = CGAffineTransformIdentity;
        self.scrollView.contentOffset = CGPointMake(0, 0);
        self.scrollView.minimumZoomScale = 1;
        self.scrollView.zoomScale = 1;
        self.scrollView.contentSize = self.imagrOrgFrame.size;
        self.containerView.frame = self.imagrOrgFrame;
        self.imageView.frame = CGRectMake(0, 0, self.imagrOrgFrame.size.width, self.imagrOrgFrame.size.height);
        self.cropBoxFrame = self.imagrOrgFrame;
    } completion:^(BOOL complete) {
        self.overlayView.hidden = false;
        self.coverView.hidden = false;
        [self.coverView show];
        [self checkForCanReset];
        [self.overlayView setGridHidden:false animated:true];
    }];
}

- (void)setCropBoxFrame:(CGRect)cropBoxFrame {
    if (CGRectEqualToRect(cropBoxFrame, _cropBoxFrame))
        return;
    
    if (cropBoxFrame.size.width < FLT_EPSILON || cropBoxFrame.size.height < FLT_EPSILON)
        return;
    
    CGRect contentFrame = [self contentBounds];
    CGFloat xOrigin = ceilf(contentFrame.origin.x);
    CGFloat xDelta = cropBoxFrame.origin.x - xOrigin;
    cropBoxFrame.origin.x = floorf(MAX(cropBoxFrame.origin.x, xOrigin));
    if (xDelta < -FLT_EPSILON)
        cropBoxFrame.size.width += xDelta;
    
    CGFloat yOrigin = ceilf(contentFrame.origin.y);
    CGFloat yDelta = cropBoxFrame.origin.y - yOrigin;
    cropBoxFrame.origin.y = floorf(MAX(cropBoxFrame.origin.y, yOrigin));
    if (yDelta < -FLT_EPSILON)
        cropBoxFrame.size.height += yDelta;
    
    CGFloat maxWidth = (contentFrame.size.width + contentFrame.origin.x) - cropBoxFrame.origin.x;
    cropBoxFrame.size.width = floorf(MIN(cropBoxFrame.size.width, maxWidth));
    
    CGFloat maxHeight = (contentFrame.size.height + contentFrame.origin.y) - cropBoxFrame.origin.y;
    cropBoxFrame.size.height = floorf(MIN(cropBoxFrame.size.height, maxHeight));
    
    cropBoxFrame.size.width  = MAX(cropBoxFrame.size.width, CLCropViewMinimumBoxSize);
    cropBoxFrame.size.height = MAX(cropBoxFrame.size.height, CLCropViewMinimumBoxSize);
    
    _cropBoxFrame = cropBoxFrame;
    self.coverView.emptRect = cropBoxFrame;
    
    CGFloat top = _cropBoxFrame.origin.y - self.cropOriginImageFrame.origin.y;
    CGFloat left = _cropBoxFrame.origin.x - self.cropOriginImageFrame.origin.x;
    CGFloat bottom = CGRectGetMaxY(self.cropOriginImageFrame) - CGRectGetMaxY(_cropBoxFrame) + (self.bounds.size.height - self.cropOriginImageFrame.size.height);
    CGFloat right = CGRectGetMaxX(self.cropOriginImageFrame)  - CGRectGetMaxX(_cropBoxFrame) + (self.bounds.size.width - self.cropOriginImageFrame.size.width);
    self.scrollView.contentInset = (UIEdgeInsets){top, left, bottom, right};
    
    self.overlayView.frame = cropBoxFrame;
    
    CGSize imageSize = self.containerView.bounds.size;
    CGFloat scale = MAX(cropBoxFrame.size.height/imageSize.height, cropBoxFrame.size.width/imageSize.width);
    self.scrollView.minimumZoomScale = scale;
    
    CGSize size = self.scrollView.contentSize;
    size.width = floorf(size.width);
    size.height = floorf(size.height);
    self.scrollView.contentSize = size;
    
    self.scrollView.zoomScale = self.scrollView.zoomScale;
    
    [self checkForCanReset];
}

- (void)setFrame:(CGRect)frame {
    [super setFrame:frame];
    [self initialImage];
}

- (void)didMoveToSuperview {
    [super didMoveToSuperview];
    if (self.superview == nil) {
        return;
    }
    [self initialImage];
}

- (void)initialImage {
    if (!self.image) {
        return;
    }
    CGSize imageSize = [self imageSize];
    
    CGRect bounds = [self contentBounds];
    
    CGFloat scale = 0;
    
    scale = MIN(CGRectGetWidth(bounds) / imageSize.width, CGRectGetHeight(bounds) / imageSize.height);
    
    CGSize cropBoxSize = CGSizeZero;
    if ([self hasAspectRatio]) {
        
    }
    
    CGSize scaleSize = (CGSize){ imageSize.width * scale, imageSize.height * scale };
    
    CGRect frame = CGRectZero;
    
    frame.size = [self hasAspectRatio] ? cropBoxSize : scaleSize;
    frame.origin.x = bounds.origin.x + (CGRectGetWidth(bounds) - frame.size.width) / 2;
    frame.origin.y = bounds.origin.y + (CGRectGetHeight(bounds) - frame.size.height) / 2;
    
    self.scrollView.minimumZoomScale = 1;
    self.scrollView.maximumZoomScale = 10;
    
    self.scrollView.zoomScale = self.scrollView.minimumZoomScale;
    self.scrollView.contentSize = scaleSize;
    
    self.containerView.frame = frame;
    self.cropOriginImageFrame = frame;
    self.imagrOrgFrame = frame;
    self.coverView.frame = self.bounds;
    self.cropBoxFrame = frame;
    
    self.originalContentOffset = CGPointMake(0, 0);
    self.originalCropBoxSize = frame.size;
    
    self.imageView.frame = CGRectMake(0, 0, frame.size.width, frame.size.height);
    
    [self checkForCanReset];
}

- (void)checkForCanReset
{
    BOOL canReset = NO;
    
    if (self.angle != 0) {
        canReset = YES;
    }
    else if (self.scrollView.zoomScale > self.scrollView.minimumZoomScale) {
        canReset = YES;
    }
    else if ((NSInteger)floorf(self.cropBoxFrame.size.width) != (NSInteger)floorf(self.originalCropBoxSize.width) ||
             (NSInteger)floorf(self.cropBoxFrame.size.height) != (NSInteger)floorf(self.originalCropBoxSize.height))
    {
        canReset = YES;
    }
    else if ((NSInteger)floorf(self.scrollView.contentOffset.x) != (NSInteger)floorf(self.originalContentOffset.x) ||
             (NSInteger)floorf(self.scrollView.contentOffset.y) != (NSInteger)floorf(self.originalContentOffset.y))
    {
        canReset = YES;
    }

    self.canBeReset = canReset;
}

- (void)setCroppingViewsHidden:(BOOL)hidden
{
    [self setCroppingViewsHidden:hidden animated:NO];
}

- (void)setCroppingViewsHidden:(BOOL)hidden animated:(BOOL)animated
{
    if (_croppingViewsHidden == hidden)
        return;
        
    _croppingViewsHidden = hidden;
    
    CGFloat alpha = hidden ? 0.0f : 1.0f;
    self.imageView.alpha = alpha;
    self.containerView.alpha = alpha;
    
    if (animated == NO) {
        self.overlayView.alpha = alpha;
        self.coverView.alpha = alpha;
        return;
    }
    [UIView animateWithDuration:0.4f animations:^{
        self.overlayView.alpha = alpha;
        self.coverView.alpha = alpha;
    }];
}

- (void)setGridOverlayHidden:(BOOL)gridOverlayHidden
{
    [self setGridOverlayHidden:_gridOverlayHidden animated:NO];
}

- (void)setGridOverlayHidden:(BOOL)gridOverlayHidden animated:(BOOL)animated
{
    _gridOverlayHidden = gridOverlayHidden;
    self.overlayView.alpha = _overlayView ? 1.0f : 0.0f;
    
    [UIView animateWithDuration:0.4f animations:^{
        self.overlayView.alpha = gridOverlayHidden ? 0.0f : 1.0f;
    }];
}

- (CLCropViewOverlayEdge)cropEdgeForPoint:(CGPoint)point
{
    CGRect frame = self.cropBoxFrame;
    
    //account for padding around the box
    frame = CGRectInset(frame, -32.0f, -32.0f);
    
    //Make sure the corners take priority
    CGRect topLeftRect = (CGRect){frame.origin, {64,64}};
    if (CGRectContainsPoint(topLeftRect, point))
        return CLCropViewOverlayEdgeTopLeft;
    
    CGRect topRightRect = topLeftRect;
    topRightRect.origin.x = CGRectGetMaxX(frame) - 64.0f;
    if (CGRectContainsPoint(topRightRect, point))
        return CLCropViewOverlayEdgeTopRight;
    
    CGRect bottomLeftRect = topLeftRect;
    bottomLeftRect.origin.y = CGRectGetMaxY(frame) - 64.0f;
    if (CGRectContainsPoint(bottomLeftRect, point))
        return CLCropViewOverlayEdgeBottomLeft;
    
    CGRect bottomRightRect = topRightRect;
    bottomRightRect.origin.y = bottomLeftRect.origin.y;
    if (CGRectContainsPoint(bottomRightRect, point))
        return CLCropViewOverlayEdgeBottomRight;
    
    //Check for edges
    CGRect topRect = (CGRect){frame.origin, {CGRectGetWidth(frame), 64.0f}};
    if (CGRectContainsPoint(topRect, point))
        return CLCropViewOverlayEdgeTop;
    
    CGRect bottomRect = topRect;
    bottomRect.origin.y = CGRectGetMaxY(frame) - 64.0f;
    if (CGRectContainsPoint(bottomRect, point))
        return CLCropViewOverlayEdgeBottom;
    
    CGRect leftRect = (CGRect){frame.origin, {64.0f, CGRectGetHeight(frame)}};
    if (CGRectContainsPoint(leftRect, point))
        return CLCropViewOverlayEdgeLeft;
    
    CGRect rightRect = leftRect;
    rightRect.origin.x = CGRectGetMaxX(frame) - 64.0f;
    if (CGRectContainsPoint(rightRect, point))
        return CLCropViewOverlayEdgeRight;
    
    return CLCropViewOverlayEdgeNone;
}

- (void)updateCropBoxFrameWithGesturePoint: (CGPoint)point {
    CGRect frame = self.cropBoxFrame;
    CGRect originFrame = self.cropOriginFrame;
    CGRect contentFrame = [self contentBounds];
    
    point.x = MAX(contentFrame.origin.x, point.x);
    point.y = MAX(contentFrame.origin.y, point.y);
    
    CGFloat xDelta = ceilf(point.x - self.panOriginPoint.x);
    CGFloat yDelta = ceilf(point.y - self.panOriginPoint.y);
    
    CGFloat aspectRatio = (originFrame.size.width / originFrame.size.height);
    
    BOOL aspectHorizontal = NO, aspectVertical = NO;
    BOOL clampMinFromTop = NO, clampMinFromLeft = NO;
    
    switch (self.tappedEdge) {
        case CLCropViewOverlayEdgeLeft:
            if (self.aspectRatioLockEnabled) {
                aspectHorizontal = YES;
                xDelta = MAX(xDelta, 0);
                CGPoint scaleOrigin = (CGPoint){CGRectGetMaxX(originFrame), CGRectGetMidY(originFrame)};
                frame.size.height = frame.size.width / aspectRatio;
                frame.origin.y = scaleOrigin.y - (frame.size.height * 0.5f);
            }
            frame.origin.x   = originFrame.origin.x + xDelta;
            frame.size.width = originFrame.size.width - xDelta;
            
            clampMinFromLeft = YES;
            
            break;
        case CLCropViewOverlayEdgeRight:
            if (self.aspectRatioLockEnabled) {
                aspectHorizontal = YES;
                CGPoint scaleOrigin = (CGPoint){CGRectGetMinX(originFrame), CGRectGetMidY(originFrame)};
                frame.size.height = frame.size.width / aspectRatio;
                frame.origin.y = scaleOrigin.y - (frame.size.height * 0.5f);
                frame.size.width = originFrame.size.width + xDelta;
                frame.size.width = MIN(frame.size.width, contentFrame.size.height * aspectRatio);
            }
            else {
                frame.size.width = originFrame.size.width + xDelta;
            }
            
            break;
        case CLCropViewOverlayEdgeBottom:
            if (self.aspectRatioLockEnabled) {
                aspectVertical = YES;
                CGPoint scaleOrigin = (CGPoint){CGRectGetMidX(originFrame), CGRectGetMinY(originFrame)};
                frame.size.width = frame.size.height * aspectRatio;
                frame.origin.x = scaleOrigin.x - (frame.size.width * 0.5f);
                frame.size.height = originFrame.size.height + yDelta;
                frame.size.height = MIN(frame.size.height, contentFrame.size.width / aspectRatio);
            }
            else {
                frame.size.height = originFrame.size.height + yDelta;
            }
            break;
        case CLCropViewOverlayEdgeTop:
            if (self.aspectRatioLockEnabled) {
                aspectVertical = YES;
                yDelta = MAX(0,yDelta);
                CGPoint scaleOrigin = (CGPoint){CGRectGetMidX(originFrame), CGRectGetMaxY(originFrame)};
                frame.size.width = frame.size.height * aspectRatio;
                frame.origin.x = scaleOrigin.x - (frame.size.width * 0.5f);
                frame.origin.y    = originFrame.origin.y + yDelta;
                frame.size.height = originFrame.size.height - yDelta;
            }
            else {
                frame.origin.y    = originFrame.origin.y + yDelta;
                frame.size.height = originFrame.size.height - yDelta;
            }
            
            clampMinFromTop = YES;
            
            break;
        case CLCropViewOverlayEdgeTopLeft:
            if (self.aspectRatioLockEnabled) {
                xDelta = MAX(xDelta, 0);
                yDelta = MAX(yDelta, 0);
                
                CGPoint distance;
                distance.x = 1.0f - (xDelta / CGRectGetWidth(originFrame));
                distance.y = 1.0f - (yDelta / CGRectGetHeight(originFrame));
                
                CGFloat scale = (distance.x + distance.y) * 0.5f;
                
                frame.size.width = ceilf(CGRectGetWidth(originFrame) * scale);
                frame.size.height = ceilf(CGRectGetHeight(originFrame) * scale);
                frame.origin.x = originFrame.origin.x + (CGRectGetWidth(originFrame) - frame.size.width);
                frame.origin.y = originFrame.origin.y + (CGRectGetHeight(originFrame) - frame.size.height);
                
                aspectVertical = YES;
                aspectHorizontal = YES;
            }
            else {
                frame.origin.x   = originFrame.origin.x + xDelta;
                frame.size.width = originFrame.size.width - xDelta;
                frame.origin.y   = originFrame.origin.y + yDelta;
                frame.size.height = originFrame.size.height - yDelta;
            }
            
            clampMinFromTop = YES;
            clampMinFromLeft = YES;
            
            break;
        case CLCropViewOverlayEdgeTopRight:
            if (self.aspectRatioLockEnabled) {
                xDelta = MIN(xDelta, 0);
                yDelta = MAX(yDelta, 0);
                
                CGPoint distance;
                distance.x = 1.0f - ((-xDelta) / CGRectGetWidth(originFrame));
                distance.y = 1.0f - ((yDelta) / CGRectGetHeight(originFrame));
                
                CGFloat scale = (distance.x + distance.y) * 0.5f;
                
                frame.size.width = ceilf(CGRectGetWidth(originFrame) * scale);
                frame.size.height = ceilf(CGRectGetHeight(originFrame) * scale);
                frame.origin.y = originFrame.origin.y + (CGRectGetHeight(originFrame) - frame.size.height);
                
                aspectVertical = YES;
                aspectHorizontal = YES;
            }
            else {
                frame.size.width  = originFrame.size.width + xDelta;
                frame.origin.y    = originFrame.origin.y + yDelta;
                frame.size.height = originFrame.size.height - yDelta;
            }
            
            clampMinFromTop = YES;
            
            break;
        case CLCropViewOverlayEdgeBottomLeft:
            if (self.aspectRatioLockEnabled) {
                CGPoint distance;
                distance.x = 1.0f - (xDelta / CGRectGetWidth(originFrame));
                distance.y = 1.0f - (-yDelta / CGRectGetHeight(originFrame));
                
                CGFloat scale = (distance.x + distance.y) * 0.5f;
                
                frame.size.width = ceilf(CGRectGetWidth(originFrame) * scale);
                frame.size.height = ceilf(CGRectGetHeight(originFrame) * scale);
                frame.origin.x = CGRectGetMaxX(originFrame) - frame.size.width;
                
                aspectVertical = YES;
                aspectHorizontal = YES;
            }
            else {
                frame.size.height = originFrame.size.height + yDelta;
                frame.origin.x    = originFrame.origin.x + xDelta;
                frame.size.width  = originFrame.size.width - xDelta;
            }
            
            clampMinFromLeft = YES;
            
            break;
        case CLCropViewOverlayEdgeBottomRight:
            if (self.aspectRatioLockEnabled) {
                
                CGPoint distance;
                distance.x = 1.0f - ((-1 * xDelta) / CGRectGetWidth(originFrame));
                distance.y = 1.0f - ((-1 * yDelta) / CGRectGetHeight(originFrame));
                
                CGFloat scale = (distance.x + distance.y) * 0.5f;
                
                frame.size.width = ceilf(CGRectGetWidth(originFrame) * scale);
                frame.size.height = ceilf(CGRectGetHeight(originFrame) * scale);
                
                aspectVertical = YES;
                aspectHorizontal = YES;
            }
            else {
                frame.size.height = originFrame.size.height + yDelta;
                frame.size.width = originFrame.size.width + xDelta;
            }
            break;
        case CLCropViewOverlayEdgeNone: break;
    }
    
    CGSize minSize = (CGSize){CLCropViewMinimumBoxSize, CLCropViewMinimumBoxSize};
    CGSize maxSize = (CGSize){CGRectGetWidth(contentFrame), CGRectGetHeight(contentFrame)};
    
    if (self.aspectRatioLockEnabled && aspectHorizontal) {
        maxSize.height = contentFrame.size.width / aspectRatio;
        minSize.width = CLCropViewMinimumBoxSize * aspectRatio;
    }
        
    if (self.aspectRatioLockEnabled && aspectVertical) {
        maxSize.width = contentFrame.size.height * aspectRatio;
        minSize.height = CLCropViewMinimumBoxSize / aspectRatio;
    }
    
    frame.size.width  = MAX(frame.size.width, minSize.width);
    frame.size.height = MAX(frame.size.height, minSize.height);
    
    frame.size.width  = MIN(frame.size.width, maxSize.width);
    frame.size.height = MIN(frame.size.height, maxSize.height);
    
    frame.origin.x = MAX(frame.origin.x, CGRectGetMinX(contentFrame));
    frame.origin.x = MIN(frame.origin.x, CGRectGetMaxX(contentFrame) - minSize.width);
    
    frame.origin.y = MAX(frame.origin.y, CGRectGetMinY(contentFrame));
    frame.origin.y = MIN(frame.origin.y, CGRectGetMaxY(contentFrame) - minSize.height);
    
    if (clampMinFromLeft && frame.size.width <= minSize.width + FLT_EPSILON) {
        frame.origin.x = CGRectGetMaxX(originFrame) - minSize.width;
    }
    
    if (clampMinFromTop && frame.size.height <= minSize.height + FLT_EPSILON) {
        frame.origin.y = CGRectGetMaxY(originFrame) - minSize.height;
    }
    
    self.cropBoxFrame = frame;
    
    [self checkForCanReset];
}

- (void)moveCroppedContentToCenterAnimated:(BOOL)animated {
    CGRect contentRect = [self contentBounds];
    CGRect cropFrame = self.cropBoxFrame;
    
    if (cropFrame.size.width < FLT_EPSILON || cropFrame.size.height < FLT_EPSILON) {
        return;
    }
    
    CGFloat scale = MIN(CGRectGetWidth(contentRect)/CGRectGetWidth(cropFrame), CGRectGetHeight(contentRect)/CGRectGetHeight(cropFrame));
    
    CGPoint focusPoint = (CGPoint){CGRectGetMidX(cropFrame), CGRectGetMidY(cropFrame)};
    CGPoint midPoint = (CGPoint){CGRectGetMidX(contentRect), CGRectGetMidY(contentRect)};
    
    cropFrame.size.width = ceilf(cropFrame.size.width * scale);
    cropFrame.size.height = ceilf(cropFrame.size.height * scale);
    cropFrame.origin.x = contentRect.origin.x + ceilf((contentRect.size.width - cropFrame.size.width) * 0.5f);
    cropFrame.origin.y = contentRect.origin.y + ceilf((contentRect.size.height - cropFrame.size.height) * 0.5f);
    
    CGPoint contentTargetPoint = CGPointZero;
    contentTargetPoint.x = ((focusPoint.x + self.scrollView.contentOffset.x) * scale);
    contentTargetPoint.y = ((focusPoint.y + self.scrollView.contentOffset.y) * scale);
    
    __block CGPoint offset = CGPointZero;
    offset.x = -midPoint.x + contentTargetPoint.x;
    offset.y = -midPoint.y + contentTargetPoint.y;
    
    offset.x = MAX(-cropFrame.origin.x, offset.x);
    offset.y = MAX(-cropFrame.origin.y, offset.y);
    
    __weak typeof(self) weakSelf = self;
    void (^translateBlock)(void) = ^{
        typeof(self) strongSelf = weakSelf;
        {
            if (scale < 1.0f - FLT_EPSILON || scale > 1.0f + FLT_EPSILON) {
                strongSelf.scrollView.zoomScale *= scale;
                strongSelf.scrollView.zoomScale = MIN(strongSelf.scrollView.maximumZoomScale, strongSelf.scrollView.zoomScale);
            }
            if (strongSelf.scrollView.zoomScale < strongSelf.scrollView.maximumZoomScale - FLT_EPSILON) {
                offset.x = MIN(-CGRectGetMaxX(cropFrame)+strongSelf.scrollView.contentSize.width, offset.x);
                offset.y = MIN(-CGRectGetMaxY(cropFrame)+strongSelf.scrollView.contentSize.height, offset.y);
                strongSelf.scrollView.contentOffset = offset;
            }
            
            strongSelf.cropBoxFrame = cropFrame;
        }
    };
    
    if (!animated) {
        translateBlock();
        return;
    }
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.01f * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [UIView animateWithDuration:0.5f
                              delay:0.0f
             usingSpringWithDamping:1.0f
              initialSpringVelocity:1.0f
                            options:UIViewAnimationOptionBeginFromCurrentState
                         animations:translateBlock
                         completion:nil];
    });
}

- (void)rotateImage {
    [self rotateImageAnimated:false];
}

- (void)rotateImageAnimated:(BOOL)animated {
    [self rotateImageAnimated:animated andClockwise:false];
}

- (void)rotateImageAnimated:(BOOL)animated andClockwise:(BOOL)clockwise {
    if (self.rotateAnimationInProgress)
        return;
    
    CGFloat zoomScale = self.scrollView.zoomScale;
    NSInteger newAngle = self.angle;
    newAngle = !clockwise ? newAngle + 90 : newAngle - 90;
    if (newAngle <= -360 || newAngle >= 360)
        newAngle = 0;
    
    _angle = newAngle;
    
    CGFloat angleInRadians = 0.0f;
    switch (newAngle) {
        case 90:    angleInRadians = M_PI_2;            break;
        case -90:   angleInRadians = -M_PI_2;           break;
        case 180:   angleInRadians = M_PI;              break;
        case -180:  angleInRadians = -M_PI;             break;
        case 270:   angleInRadians = (M_PI + M_PI_2);   break;
        case -270:  angleInRadians = -(M_PI + M_PI_2);  break;
        default:                                        break;
    }
    
    CGAffineTransform rotation = CGAffineTransformRotate(CGAffineTransformIdentity, angleInRadians);
    CGRect contentBounds = [self contentBounds];
    CGRect cropBoxFrame = self.cropBoxFrame;
    
    CGFloat scale = MIN(contentBounds.size.width / cropBoxFrame.size.height, contentBounds.size.height / cropBoxFrame.size.width);
    CGRect newCropFrame = CGRectZero;
    newCropFrame.size = (CGSize){ cropBoxFrame.size.height * scale, cropBoxFrame.size.width * scale };
    newCropFrame.origin.x = floorf((CGRectGetWidth(self.bounds) - newCropFrame.size.width) * 0.5f);
    newCropFrame.origin.y = floorf((CGRectGetHeight(self.bounds) - newCropFrame.size.height) * 0.5f);
    
    if (animated) {
        self.coverView.hidden = true;
        self.overlayView.hidden = true;
        
//        CGPoint cropMidPoint = (CGPoint){cropBoxFrame.size.width * 0.5f, cropBoxFrame.size.height * 0.5};
//        CGPoint anchorPoint = (CGPoint){(cropMidPoint.x + self.scrollView.contentOffset.x) / self.scrollView.contentSize.width, (cropMidPoint.y + self.scrollView.contentOffset.y) / self.scrollView.contentSize.height};
//        CGPoint oldOrigin = self.imageView.frame.origin;
//        self.imageView.layer.anchorPoint = anchorPoint;
//        CGPoint newOrigin = self.imageView.frame.origin;
//        CGPoint transition;
//        transition.x = newOrigin.x - oldOrigin.x;
//        transition.y = newOrigin.y - oldOrigin.y;
//        self.imageView.center = CGPointMake (self.imageView.center.x - transition.x, self.imageView.center.y - transition.y);
    }
    
    CGSize scaleSize = (CGSize){ self.cropOriginImageFrame.size.height * scale, self.cropOriginImageFrame.size.width * scale };
    CGRect frame = CGRectZero;
    frame.size = scaleSize;
    frame.origin.x = contentBounds.origin.x + (CGRectGetWidth(contentBounds) - frame.size.width) / 2;
    frame.origin.y = contentBounds.origin.y + (CGRectGetHeight(contentBounds) - frame.size.height) / 2;
    
    CGPoint offset = CGPointZero;
    CGPoint cropTargetPoint = CGPointZero;
    if (clockwise) {
        cropTargetPoint = (CGPoint){cropBoxFrame.size.width + self.scrollView.contentOffset.x + self.scrollView.contentInset.left, self.scrollView.contentOffset.y};
        cropTargetPoint.x = floorf(self.scrollView.contentSize.width - cropTargetPoint.x);
        cropTargetPoint.x *= scale;
        cropTargetPoint.y *= scale;
        offset.x = floorf(cropTargetPoint.y);
        offset.y = -floorf(newCropFrame.origin.y - frame.origin.y) + cropTargetPoint.x;
    } else {
        cropTargetPoint = (CGPoint){self.scrollView.contentOffset.x, self.scrollView.contentOffset.y + cropBoxFrame.size.height + self.scrollView.contentInset.top};
        cropTargetPoint.y = floorf(self.scrollView.contentSize.height - cropTargetPoint.y);
        cropTargetPoint.x *= scale;
        cropTargetPoint.y *= scale;
        offset.x = -floorf(newCropFrame.origin.x - frame.origin.x) + cropTargetPoint.y;
        offset.y = floorf(cropTargetPoint.x);
    }
    NSLog(@"%@", NSStringFromCGPoint(offset));
    
    if (animated) {
        [UIView animateWithDuration:0.45f delay:0.0f usingSpringWithDamping:1.0f initialSpringVelocity:0.8f options:UIViewAnimationOptionBeginFromCurrentState animations:^{
            self.containerView.transform = CGAffineTransformIdentity;
            self.imageView.transform = rotation;
            self.containerView.frame = frame;
            self.imageView.frame = CGRectMake(0, 0, frame.size.width, frame.size.height);
            self.cropOriginImageFrame = frame;
            self.scrollView.zoomScale = zoomScale;
            self.scrollView.contentOffset = offset;
            self.cropBoxFrame = newCropFrame;
        } completion:^(BOOL complete) {
            self.coverView.hidden = false;
            self.overlayView.hidden = false;
            self.coverView.alpha = 0;
            self.overlayView.alpha = 0;
//            self.imageView.layer.anchorPoint = CGPointMake(0.5, 0.5);
            [UIView animateWithDuration:0.45f animations:^{
                self.coverView.alpha = 1;
                self.overlayView.alpha = 1;
            } completion:^(BOOL complete) {
                self.rotateAnimationInProgress = NO;
            }];
        }];
    } else {
        self.containerView.transform = CGAffineTransformIdentity;
        self.imageView.transform = rotation;
        self.containerView.frame = frame;
        self.imageView.frame = CGRectMake(0, 0, frame.size.width, frame.size.height);
        self.cropOriginImageFrame = frame;
        self.cropBoxFrame = newCropFrame;
        self.scrollView.zoomScale = zoomScale;
    }
}

#pragma mark - UIGestureRecognizerDelegate
- (void)panOverlayGes:(UIPanGestureRecognizer *)recognizer
{
    CGPoint point = [recognizer locationInView:self];
    
    if (recognizer.state == UIGestureRecognizerStateBegan) {
        [self.coverView dismiss];
        self.panOriginPoint = point;
        self.cropOriginFrame = self.cropBoxFrame;
        self.tappedEdge = [self cropEdgeForPoint:self.panOriginPoint];
    } else if (recognizer.state == UIGestureRecognizerStateChanged) {
        [self updateCropBoxFrameWithGesturePoint:point];
    } else {
        [self.coverView show];
        [self moveCroppedContentToCenterAnimated: true];
    }
}

- (void)longPressGestureRecognized:(UILongPressGestureRecognizer *)recognizer
{
    
}

- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer
{
    if (gestureRecognizer != self.panges)
        return YES;
    
    CGPoint tapPoint = [gestureRecognizer locationInView:self];
    
    CGRect frame = self.overlayView.frame;
    CGRect innerFrame = CGRectInset(frame, 22.0f, 22.0f);
    CGRect outerFrame = CGRectInset(frame, -22.0f, -22.0f);
    
    if (CGRectContainsPoint(innerFrame, tapPoint) || !CGRectContainsPoint(outerFrame, tapPoint))
        return NO;
    
    return YES;
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch
{
    if (self.panges.state == UIGestureRecognizerStateChanged) {
        return NO;
    }
    return YES;
}

#pragma mark - UIScrollViewDelegate

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView {
    return self.containerView;
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView            {
//    [self matchForegroundToBackground];
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
//    [self startEditing];
//    self.canBeReset = YES;
}

- (void)scrollViewWillBeginZooming:(UIScrollView *)scrollView withView:(UIView *)view
{
//    [self startEditing];
//    self.canBeReset = YES;
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
//    [self startResetTimer];
//    [self checkForCanReset];
}

- (void)scrollViewDidEndZooming:(UIScrollView *)scrollView withView:(UIView *)view atScale:(CGFloat)scale {
//    [self startResetTimer];
//    [self checkForCanReset];
}

- (void)scrollViewDidZoom:(UIScrollView *)scrollView
{
//    if (scrollView.isTracking) {
//        self.cropBoxLastEditedZoomScale = scrollView.zoomScale;
//        self.cropBoxLastEditedMinZoomScale = scrollView.minimumZoomScale;
//    }
//
//    [self matchForegroundToBackground];
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
//    if (!decelerate)
//        [self startResetTimer];
}

- (CGRect)contentBounds
{
    CGRect contentRect = CGRectZero;
    contentRect.origin.x = CLCropViewPadding + self.cropRegionInsets.left;
    contentRect.origin.y = CLCropViewPadding + self.cropRegionInsets.top;
    contentRect.size.width = CGRectGetWidth(self.bounds) - ((CLCropViewPadding * 2) + self.cropRegionInsets.left + self.cropRegionInsets.right);
    contentRect.size.height = CGRectGetHeight(self.bounds) - ((CLCropViewPadding * 2) + self.cropRegionInsets.top + self.cropRegionInsets.bottom);
    return contentRect;
}

- (CGSize)imageSize
{
    if (self.angle == -90 || self.angle == -270 || self.angle == 90 || self.angle == 270)
        return (CGSize){self.image.size.height, self.image.size.width};

    return (CGSize){self.image.size.width, self.image.size.height};
}

- (BOOL)hasAspectRatio
{
    return (self.aspectRatio.width > FLT_EPSILON && self.aspectRatio.height > FLT_EPSILON);
}

- (CGRect)imageCropFrame
{
    CGSize imageSize = self.imageSize;
    CGSize contentSize = self.scrollView.contentSize;
    CGRect cropBoxFrame = self.cropBoxFrame;
    CGPoint contentOffset = self.scrollView.contentOffset;
    UIEdgeInsets edgeInsets = self.scrollView.contentInset;
    
    CGRect frame = CGRectZero;
    frame.origin.x = floorf((contentOffset.x + edgeInsets.left) * (imageSize.width / contentSize.width));
    frame.origin.x = MAX(0, frame.origin.x);
    
    frame.origin.y = floorf((contentOffset.y + edgeInsets.top) * (imageSize.height / contentSize.height));
    frame.origin.y = MAX(0, frame.origin.y);
    
    frame.size.width = ceilf(cropBoxFrame.size.width * (imageSize.width / contentSize.width));
    frame.size.width = MIN(imageSize.width, frame.size.width);
    
    frame.size.height = ceilf(cropBoxFrame.size.height * (imageSize.height / contentSize.height));
    frame.size.height = MIN(imageSize.height, frame.size.height);
    
    return frame;
}

- (CGRect)imageViewFrame
{
    CGRect frame = CGRectZero;
    frame.origin.x = -self.scrollView.contentOffset.x;
    frame.origin.y = -self.scrollView.contentOffset.y;
    frame.size = self.scrollView.contentSize;
    return frame;
}
@end
