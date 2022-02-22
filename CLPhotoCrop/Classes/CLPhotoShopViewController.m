//
//  CLPhotoShopViewController.m
//  CLPhotoCrop
//
//  Created by 雷玉宇 on 2022/1/26.
//

#import "CLPhotoShopViewController.h"
#import "CLCropViewController.h"
#import "CLBottomToolView.h"
#import "CLMosaicToolView.h"
#import "CLEmojiBoardView.h"
#import "CLDrawImageView.h"
#import "CLColorToolView.h"
#import "CLTextInputView.h"
#import "CLDrawBaseView.h"
#import "CLDrawTextView.h"
#import "CLPSImageView.h"
#import "CLPhotoCrop.h"


static const CGFloat CLDeleteViewWidth = 130.f;
@interface CLPhotoShopViewController ()<UIScrollViewDelegate,
CLColorToolViewDelegate,
CLBottomToolViewDelegate,
CLMosaicToolViewDelegate,
CLDrawBaseViewDelegate,
CLTextInputViewDelegate,
CLEmojiBoardViewDelegate,
CLCropViewControllerDelegate>

/// 返回按钮
@property (nonatomic, strong) UIButton *backBtn;
/// 底部功能按钮
@property (nonatomic, strong) CLBottomToolView *bottomToolView;
/// 缩放scrollview
@property (nonatomic, strong) UIScrollView *scrollView;

@property (nonatomic, strong) CLBaseToolView *currToolView;

@property (nonatomic, strong) CLPSImageView *imageView;
/// 画笔工具view
@property (nonatomic, strong) CLColorToolView *colorToolView;
/// 马赛克工具view
@property (nonatomic, strong) CLMosaicToolView *mosaicToolView;
/// 输入框
@property (nonatomic, strong) CLTextInputView *textInputView;
/// 表情板
@property (nonatomic, strong) CLEmojiBoardView *emojiBoardView;

@property (nonatomic, strong) UIView *deleteView;

@property (nonatomic, assign) CGRect deleteRect;
@property (nonatomic, assign) CGRect imageFrame;
@end

@implementation CLPhotoShopViewController

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.modalPresentationStyle = 0;
    }
    return self;
}

- (void)dealloc {
    
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self initView];
    [self refreshImageView];
}

- (void)initView {
    self.view.backgroundColor = [UIColor blackColor];
    UIButton *backBtn = [[UIButton alloc] init];
    backBtn.frame = CGRectMake(15, CLP_SAFETOPPADDING, 44, 44);
    [backBtn setImage:[UIImage clp_imageNamed:@"cl_back"] forState:UIControlStateNormal];
    [backBtn addTarget:self action:@selector(clickBackBtn) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:backBtn];
    _backBtn = backBtn;
    
    _bottomToolView = [[CLBottomToolView alloc] init];
    _bottomToolView.delegate = self;
    _bottomToolView.frame = CGRectMake(0, CLP_SCREENHEIGHT - CLP_SAFEBOTTOMHEIGHT, CLP_SCREENWIDTH, CLP_SAFEBOTTOMHEIGHT);
    [self.view addSubview:_bottomToolView];
    
    _scrollView = [[UIScrollView alloc] initWithFrame:self.view.bounds];
    _scrollView.showsVerticalScrollIndicator = false;
    _scrollView.showsHorizontalScrollIndicator = false;
    _scrollView.alwaysBounceHorizontal = YES;
    _scrollView.alwaysBounceVertical = YES;
    _scrollView.delegate = self;
    _scrollView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    if (@available(iOS 11.0, *)) {
        [self.scrollView setContentInsetAdjustmentBehavior:UIScrollViewContentInsetAdjustmentNever];
    } else {
        self.automaticallyAdjustsScrollViewInsets = false;
    }
    [self.view insertSubview:_scrollView atIndex:0];
    
    
    _imageView = [[CLPSImageView alloc] init];
    CLP_WEAKSELF
    _imageView.drawEnd = ^{
        [weakSelf performSelector:@selector(showTool) withObject:nil afterDelay:0.5];
    };
    _imageView.drawStart = ^{
        [NSObject cancelPreviousPerformRequestsWithTarget:weakSelf selector:@selector(showTool) object:nil];
        [weakSelf hiddenTool];
    };
    _imageView.drawIng = ^{
        
    };
    [_scrollView addSubview:_imageView];
    self.deleteView.frame = CGRectMake(CLDeleteViewWidth, CLP_SCREENHEIGHT, CLDeleteViewWidth, 64);
    _deleteRect = CGRectMake(CLDeleteViewWidth, CLP_SCREENHEIGHT - 84, CLDeleteViewWidth, 64);
}

- (void)refreshImageView {
    if (self.imageView.image == nil) {
        self.imageView.image = self.orgImage;
    }
    
    [self resetImageViewFrame];
    [self resetZoomScaleWithAnimated:NO];
    [self viewDidLayoutSubviews];
}

- (void)resetImageViewFrame {
    
}

- (void)resetZoomScaleWithAnimated:(BOOL)animated
{
    
    CGSize size = (_imageView.image) ? _imageView.image.size : _imageView.frame.size;
    CGRect frame = self.imageFrame;
    CGFloat ratio = MIN(_scrollView.frame.size.width / size.width, _scrollView.frame.size.height / size.height);
    CGFloat W = ratio * size.width;
    CGFloat H = ratio * size.height;
    frame.size.width = W;
    frame.size.height = H;
    frame.origin.x = MAX(0, (_scrollView.frame.size.width-W)/2);
    frame.origin.y = MAX(0, (_scrollView.frame.size.height-H)/2);
    
    CGFloat Rw = _scrollView.frame.size.width / W;
    CGFloat Rh = _scrollView.frame.size.height / H;
    
    //CGFloat scale = [[UIScreen mainScreen] scale];
    CGFloat scale = 1;
    Rw = MAX(Rw, size.width / (scale * _scrollView.frame.size.width));
    Rh = MAX(Rh, size.height / (scale * _scrollView.frame.size.height));
    
    _scrollView.minimumZoomScale = 1;
    _scrollView.maximumZoomScale = MAX(MAX(Rw, Rh), 3);
    _scrollView.contentSize = _imageView.frame.size;
    self.imageView.frame = frame;
    
    [_scrollView setZoomScale:_scrollView.minimumZoomScale animated:animated];
    [self scrollViewDidZoom:_scrollView];
    
    CGFloat top = 0;
    CGFloat left = 0;
    CGFloat bottom = (self.view.bounds.size.height - H);
    CGFloat right = (self.view.bounds.size.width - W);
    self.scrollView.contentInset = (UIEdgeInsets){top, left, bottom, right};
}

- (void)clear {
    
}

- (void)hiddenTool {
    if (self.currToolView) {
        [self.currToolView hiddenTool];
    }
    [self.bottomToolView hiddenTool];
    [UIView animateWithDuration:.25 animations:^{
        self.backBtn.alpha = 0;
    } completion:^(BOOL finished) {
        [self.backBtn removeFromSuperview];
    }];
}

- (void)showTool {
    [self.view addSubview:self.backBtn];
    if (self.currToolView) {
        [self.currToolView showTool:self.view];
    }
    [self.bottomToolView showTool:self.view];
    [UIView animateWithDuration:.25 animations:^{
        self.backBtn.alpha = 1;
    } completion:^(BOOL finished) {
    }];
}

- (void)clickBackBtn {
    [self dismissViewControllerAnimated:true completion:nil];
}

#pragma mark- ScrollView delegate
- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView {
    return self.imageView;
}

//缩放中
- (void)scrollViewDidZoom:(UIScrollView *)scrollView {
    
}

#pragma mark- CLColorToolViewDelegate
- (void)CLColorToolViewCLickColor:(UIColor *)color {
    self.imageView.doodleColor = color;
}

- (void)CLColorToolViewCLickProvious {
    [self.imageView previous];
}

- (void)CLColorToolViewChangeLineWidth:(CGFloat)lineWidth {
    self.imageView.lineWidth = lineWidth;
}

#pragma mark- CLColorToolViewDelegate
- (void)CLBottomToolViewCLickDoneBtn {
    if ([_delegate respondsToSelector:@selector(CLPhotoShopViewControllerFinishImage:)]) {
        CGFloat scale = self.scrollView.zoomScale;
        [self.scrollView setZoomScale:1 animated:false];
        [_delegate CLPhotoShopViewControllerFinishImage:[self.imageView buildImage]];
        [self.scrollView setZoomScale:scale animated:false];
    }
    [self clickBackBtn];
}

- (void)CLBottomToolViewCLickItemBtn:(UIButton *)btn {
    /// 画笔
    if (btn.tag == 0) {
        if (btn.selected) {
            if (self.currToolView) {
                [self.currToolView removeFromSuperview];
            }
            self.currToolView = self.colorToolView;
            [self.currToolView showTool:self.view];
            [self.imageView activeDoodle];
            self.imageView.drawMode = CLPDrawModeColor;
            [self joinDoodelMode];
        } else {
            [self.currToolView hiddenTool];
            self.currToolView = nil;
            [self.imageView disableDooble];
            [self exitDoodelMode];
        }
    } else if (btn.tag == 1) { /// 表情
        [self.emojiBoardView show];
    } else if (btn.tag == 2) { /// 文字
        [self.textInputView showWith:self.view];
    } else if (btn.tag == 3) { /// 裁剪
        CLCropViewController *cropController = [[CLCropViewController alloc] init];
        CGFloat scale = self.scrollView.zoomScale;
        [self.scrollView setZoomScale:1 animated:false];
        UIImage *image = [self.imageView buildImage];
        [self.scrollView setZoomScale:scale animated:false];
        cropController.image = image;
        cropController.delegate = self;
        __weak typeof(self)weakSelf = self;
        CGRect viewFrame = [self.view convertRect:self.imageView.frame toView:self.view];
        [cropController presentAnimatedFromParentViewController:self
                                                      fromImage:image
                                                       fromView:nil
                                                      fromFrame:viewFrame
                                                          angle:0
                                                   toImageFrame:CGRectZero
                                                          setup:^{
            [weakSelf refreshImageView];
            [weakSelf.currToolView hiddenTool];
            [weakSelf.bottomToolView hiddenTool];
            weakSelf.imageView.hidden = true;
                                                          }
                                                     completion:^{
            
                                                     }];
    } else if (btn.tag == 4) { /// 马赛克画笔
        if (btn.isSelected) {
            if (self.currToolView) {
                [self.currToolView removeFromSuperview];
            }
            self.currToolView = self.mosaicToolView;
            self.imageView.drawMode = CLPDrawModeGaussan;
            [self.currToolView showTool:self.view];
            [self.imageView activeDoodle];
            [self joinDoodelMode];
        } else {
            [self.currToolView hiddenTool];
            self.currToolView = nil;
            [self.imageView disableDooble];
            [self exitDoodelMode];
        }
    }
}

#pragma mark- CLMosaicToolViewDelegate
- (void)CLMosaicToolViewClickPreviousBtn {
    [self.imageView previous];
}

- (void)CLMosaicToolViewClickItemBtn:(UIButton *)btn {
    if (btn.tag == 0) {
        self.imageView.drawMode = CLPDrawModeGaussan;
    } else {
        self.imageView.drawMode = CLPDrawModeMosaic;
    }
}

- (void)joinDoodelMode {
    self.scrollView.panGestureRecognizer.minimumNumberOfTouches = 2;
}

- (void)exitDoodelMode {
    self.scrollView.panGestureRecognizer.minimumNumberOfTouches = 1;
}

#pragma mark- CLDrawBaseViewDelegate
- (void)drawBaseViewMovePoint:(CGPoint)point andDrawView: (CLDrawBaseView *)drawView {
    if (CGRectContainsPoint(self.deleteRect, point)) {
        drawView.alpha = 0.3;
        self.deleteView.backgroundColor = CLP_HEXCOLOR(0xed1941);
    } else {
        drawView.alpha = 1;
        self.deleteView.backgroundColor = CLP_HEXCOLOR(0x222222);
    }
}

- (void)drawBaseViewMoveStart {
    [UIView animateWithDuration:0.25 animations:^{
        self.deleteView.frame = self.deleteRect;
    }];
}

- (void)drawBaseViewMoveEndPoint:(CGPoint)point andDrawView: (CLDrawBaseView *)drawView {
    if (CGRectContainsPoint(self.deleteRect, point)) {
        [drawView removeFromSuperview];
    }
    CGSize size = self.imageFrame.size;
    if (drawView.frame.origin.x >= size.width ||
        drawView.frame.origin.y >= size.height ||
        drawView.frame.origin.x <= -drawView.frame.size.width ||
        drawView.frame.origin.y <= -drawView.frame.size.height) {
        drawView.center = CGPointMake(size.width * 0.5, size.height * 0.5);
    }
    self.deleteView.backgroundColor = CLP_HEXCOLOR(0x222222);
    self.deleteView.frame = CGRectMake(CLDeleteViewWidth, CLP_SCREENHEIGHT, CLDeleteViewWidth, 64);
}

- (void)drawBaseViewInvalidate {
    self.imageView.clipsToBounds = true;
    [self performSelector:@selector(drawViewInvalidate) withObject:nil afterDelay:2];
    [self showTool];
}

- (void)drawBaseViewWith:(CLDrawBaseView *)drawView {
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(drawViewInvalidate) object:nil];
    for (CLDrawBaseView *drawView in self.imageView.subviews) {
        if ([drawView isKindOfClass:[CLDrawBaseView class]]) {
            drawView.active = false;
        }
    }
    [self hiddenTool];
    self.imageView.clipsToBounds = false;
    drawView.active = true;
}

- (void)drawViewInvalidate {
    for (CLDrawBaseView *drawView in self.imageView.subviews) {
        if ([drawView isKindOfClass:[CLDrawBaseView class]]) {
            drawView.active = false;
        }
    }
}

#pragma mark- CLCropViewControllerDelegate
- (void)clCropViewControllerDoneImage:(UIImage *)image fromCropViewController:(CLCropViewController *)cropViewController {
    self.imageView.image = image;
    CGRect frame = self.imageFrame;
    __weak typeof(self)weakSelf = self;
    [cropViewController dismissAnimatedFromParentViewController:self
                                               withCroppedImage:image
                                                         toView:self.imageView
                                                        toFrame:frame
                                                          setup:^{
        
                                                          }
                                                     completion:^{
        [weakSelf.imageView clear];
        weakSelf.imageView.image = image;
        [weakSelf refreshImageView];
        [weakSelf viewDidLayoutSubviews];
        if (weakSelf.currToolView != nil) {
            [weakSelf.currToolView showTool:weakSelf.view];
        }
        [weakSelf.bottomToolView showTool:weakSelf.view];
        [UIView animateWithDuration:.3f animations:^{
            weakSelf.imageView.hidden = NO;
        }];
     }];
}

- (void)clCropViewControllerCancelfromCropViewController:(CLCropViewController *)cropViewController {
    CGRect frame = self.imageFrame;
    __weak typeof(self)weakSelf = self;
    [cropViewController dismissAnimatedFromParentViewController:self
                                               withCroppedImage:self.imageView.image
                                                         toView:self.imageView
                                                        toFrame:frame
                                                          setup:^{
                                                              
                                                          }
                                                     completion:^{
        [weakSelf refreshImageView];
        [weakSelf viewDidLayoutSubviews];
        if (weakSelf.currToolView != nil) {
            [weakSelf.currToolView showTool:weakSelf.view];
        }
        [weakSelf.bottomToolView showTool:weakSelf.view];
                                                         [UIView animateWithDuration:.3f animations:^{
                                                             weakSelf.imageView.hidden = NO;
                                                         }];
                                                         
                                                     }];
}

#pragma mark- CLTextInputViewDelegate
- (void)textInputViewComplete:(NSString *)string andColor:(nonnull UIColor *)color {
    CLDrawTextView *textView = [[CLDrawTextView alloc] init];
    textView.text = string;
    textView.textColor = color;
    textView.center = CGPointMake(self.imageView.frame.size.width / 2, self.imageView.frame.size.height / 2);
    textView.delegate = self;
    textView.active = true;
    [self drawBaseViewInvalidate];
    [self.imageView addSubview:textView];
}

#pragma mark- CLEmojiBoardViewDelegate
- (void)emojiBoardViewClickIndexPath:(NSIndexPath *)indexPath andImage:(UIImage *)image {
    CLDrawImageView *imageView = [[CLDrawImageView alloc] init];
    imageView.image = image;
    imageView.active = true;
    imageView.delegate = self;
    imageView.center = CGPointMake(self.imageView.frame.size.width / 2, self.imageView.frame.size.height / 2);
    [self drawBaseViewInvalidate];
    [self.imageView addSubview:imageView];
    [self.emojiBoardView dismiss];
}

#pragma mark- 懒加载
- (CLColorToolView *)colorToolView {
    if (!_colorToolView) {
        _colorToolView = [[CLColorToolView alloc] init];
        _colorToolView.frame = CGRectMake(0, CLP_SCREENHEIGHT - CLP_SAFEBOTTOMHEIGHT - 65, CLP_SCREENWIDTH, 65);
        _colorToolView.delegate = self;
        [self.view addSubview:_colorToolView];
    }
    return _colorToolView;
}

- (CLMosaicToolView *)mosaicToolView {
    if (!_mosaicToolView) {
        _mosaicToolView = [[CLMosaicToolView alloc] init];
        _mosaicToolView.delegate = self;
        _mosaicToolView.frame = CGRectMake(0, CLP_SCREENHEIGHT - CLP_SAFEBOTTOMHEIGHT - 40, CLP_SCREENWIDTH, 40);
        [self.view addSubview:_mosaicToolView];
    }
    return _mosaicToolView;
}

- (CLTextInputView *)textInputView {
    if (!_textInputView) {
        _textInputView = [[CLTextInputView alloc] init];
        _textInputView.delegate = self;
        _textInputView.frame = CGRectMake(0, 0, CLP_SCREENWIDTH, CLP_SCREENHEIGHT);
        [self.view addSubview:_textInputView];
    }
    return _textInputView;
}

- (UIView *)deleteView {
    if (!_deleteView) {
        _deleteView = [[UIView alloc] init];
        _deleteView.clipsToBounds = true;
        _deleteView.layer.cornerRadius = 10;
        _deleteView.backgroundColor = CLP_HEXCOLOR(0x222222);
        UIImageView *imageView = [[UIImageView alloc] init];
        imageView.image = [UIImage clp_imageNamed:@"cl_delete"];
        [_deleteView addSubview:imageView];
        imageView.frame = CGRectMake((CLDeleteViewWidth - 24) * 0.5, 10, 24, 24);
        
        UILabel *label = [[UILabel alloc] init];
        label.text = @"拖动到此删除";
        label.font = [UIFont systemFontOfSize:12];
        label.textColor = [UIColor whiteColor];
        label.frame = CGRectMake(0, CGRectGetMaxY(imageView.frame) + 5, CLDeleteViewWidth, 20);
        label.textAlignment = NSTextAlignmentCenter;
        [_deleteView addSubview:label];
        [self.view addSubview:_deleteView];
    }
    return _deleteView;
}

- (CGRect)imageFrame {
    CGSize size = (_imageView.image) ? _imageView.image.size : _imageView.frame.size;
    CGRect frame = CGRectZero;
    CGFloat ratio = MIN(_scrollView.frame.size.width / size.width, _scrollView.frame.size.height / size.height);
    CGFloat W = ratio * size.width;
    CGFloat H = ratio * size.height;
    frame.size.width = W;
    frame.size.height = H;
    frame.origin.x = MAX(0, (_scrollView.frame.size.width-W)/2);
    frame.origin.y = MAX(0, (_scrollView.frame.size.height-H)/2);
    
    return frame;
}

-(CLEmojiBoardView *)emojiBoardView {
    if (!_emojiBoardView) {
        _emojiBoardView = [[CLEmojiBoardView alloc] init];
        _emojiBoardView.delegate = self;
    }
    return _emojiBoardView;
}
@end
