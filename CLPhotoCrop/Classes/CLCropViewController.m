//
//  CLCropViewController.m
//  CLPhotoCrop
//
//  Created by 雷玉宇 on 2022/2/8.
//

#import "CLCropViewControllerTransitioning.h"
#import "CLCropViewController.h"
#import "CLCropToolView.h"
#import "CLCropsView.h"
#import "CLPhotoCrop.h"

@interface CLCropViewController ()<CLCropToolViewDelegate, CLCropsViewDelegate, UIViewControllerTransitioningDelegate>

@property (nonatomic, strong) CLCropToolView *toolView;
@property (nonatomic, strong) CLCropsView *cropView;

@property (nonatomic, strong) CLCropViewControllerTransitioning *transitionController;
@property (nonatomic, copy) void (^prepareForTransitionHandler)(void);

@end

@implementation CLCropViewController

- (instancetype)init
{
    self = [super init];
    if (self) {
        _transitionController = [[CLCropViewControllerTransitioning alloc] init];
        self.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
        self.modalPresentationStyle = UIModalPresentationFullScreen;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self initView];
    self.transitioningDelegate = self;
}

- (void)initView {
    self.automaticallyAdjustsScrollViewInsets = false;
    _cropView = [[CLCropsView alloc] initWithFrame:CGRectMake(0, CLP_SAFETOPPADDING, CLP_SCREENWIDTH, CLP_SCREENHEIGHT - CLP_SAFEBOTTOMHEIGHT - CLP_SAFETOPPADDING)];
    _cropView.delegate = self;
    _cropView.image = self.image;
    [self.view addSubview:_cropView];
    
    _toolView = [[CLCropToolView alloc] init];
    _toolView.delegate = self;
    _toolView.frame = CGRectMake(0, CLP_SCREENHEIGHT - CLP_SAFEBOTTOMHEIGHT, CLP_SCREENWIDTH, CLP_SAFEBOTTOMHEIGHT);
    [self.view addSubview:_toolView];
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    
}

- (UIStatusBarStyle)preferredStatusBarStyle
{
    if (self.navigationController) {
        return UIStatusBarStyleLightContent;
    }
    
    return UIStatusBarStyleDefault;
}

- (void)presentAnimatedFromParentViewController:(UIViewController *)viewController
                                      fromImage:(UIImage *)image
                                       fromView:(UIView *)fromView
                                      fromFrame:(CGRect)fromFrame
                                          angle:(NSInteger)angle
                                   toImageFrame:(CGRect)toFrame
                                          setup:(void (^)(void))setup
                                     completion:(void (^)(void))completion {
    self.transitionController.image     = image ? image : self.image;
    self.transitionController.fromFrame = fromFrame;
    self.transitionController.fromView  = fromView;
    self.prepareForTransitionHandler    = setup;
    
    if (self.angle != 0 || !CGRectIsEmpty(toFrame)) {
        self.angle = angle;
        self.imageCropFrame = toFrame;
    }
    
    __weak typeof (self) weakSelf = self;
    [viewController presentViewController:self animated:YES completion:^ {
        typeof (self) strongSelf = weakSelf;
        if (completion) {
            completion();
        }
        
        [strongSelf.cropView setCroppingViewsHidden:NO animated:YES];
        if (!CGRectIsEmpty(fromFrame)) {
            [strongSelf.cropView setGridOverlayHidden:NO animated:YES];
        }
    }];
}

- (void)dismissAnimatedFromParentViewController:(UIViewController *)viewController
                                         toView:(UIView *)toView
                                        toFrame:(CGRect)frame
                                          setup:(void (^)(void))setup
                                     completion:(void (^)(void))completion
{
    [self dismissAnimatedFromParentViewController:viewController withCroppedImage:nil toView:toView toFrame:frame setup:setup completion:completion];
}

- (void)dismissAnimatedFromParentViewController:(UIViewController *)viewController
                               withCroppedImage:(UIImage *)image
                                         toView:(UIView *)toView
                                        toFrame:(CGRect)frame
                                          setup:(void (^)(void))setup
                                     completion:(void (^)(void))completion
{
    // If a cropped image was supplied, use that, and only zoom out from the crop box
    if (image) {
        self.transitionController.image     = image ? image : self.image;
        self.transitionController.fromFrame = [self.cropView convertRect:self.cropView.cropBoxFrame toView:self.view];
    }
    else { // else use the main image, and zoom out from its entirety
        self.transitionController.image     = self.image;
        self.transitionController.fromFrame = [self.cropView convertRect:self.cropView.imageViewFrame toView:self.view];
    }
    
    self.transitionController.toView    = toView;
    self.transitionController.toFrame   = frame;
    self.prepareForTransitionHandler    = setup;
    
    [viewController dismissViewControllerAnimated:YES completion:^ {
        if (completion) {
            completion();
        }
    }];
}

#pragma mark - CLCropToolViewDelegate
- (void)cropToolViewClickDoneBtn {
    if ([_delegate respondsToSelector:@selector(clCropViewControllerDoneImage: fromCropViewController:)]) {
        CGRect cropFrame = self.cropView.imageCropFrame;
        NSInteger angle = self.cropView.angle;
        UIImage *image = nil;
        if (angle == 0 && CGRectEqualToRect(cropFrame, (CGRect){CGPointZero, self.image.size})) {
            image = self.image;
        }
        else {
            image = [self.image croppedImageWithFrame:cropFrame angle:angle circularClip:NO];
        }
        [_delegate clCropViewControllerDoneImage:image fromCropViewController:self];
    } else {
        self.transitioningDelegate = nil;
        [self dismissViewControllerAnimated:true completion:nil];
    }
}

- (void)cropToolViewClickCloseBtn {
    if ([_delegate respondsToSelector:@selector(clCropViewControllerCancelfromCropViewController:)]) {
        [self.cropView reset];
        [_delegate clCropViewControllerCancelfromCropViewController:self];
    } else {
        self.transitioningDelegate = nil;
        [self dismissViewControllerAnimated:true completion:nil];
    }
}

- (void)cropToolViewClickResetBtn {
    [_cropView reset];
}

- (void)cropToolViewClickRotateBtn {
    [_cropView rotateImageAnimated:true];
}

#pragma mark - CLCropsViewDelegate
- (void)cropsViewIsReset:(BOOL)isReset {
    _toolView.resetButtonEnabled = isReset;
}

#pragma mark - UIViewControllerTransitioningDelegate

- (id <UIViewControllerAnimatedTransitioning>)animationControllerForPresentedController:(UIViewController *)presented presentingController:(UIViewController *)presenting sourceController:(UIViewController *)source
{
    if (self.navigationController || self.modalTransitionStyle == UIModalTransitionStyleCoverVertical) {
        return nil;
    }
    
//    self.cropView.simpleRenderMode = YES;
    
    __weak typeof (self) weakSelf = self;
    self.transitionController.prepareForTransitionHandler = ^{
        typeof (self) strongSelf = weakSelf;
        CLCropViewControllerTransitioning *transitioning = strongSelf.transitionController;
        
        transitioning.toFrame = [strongSelf.cropView convertRect:strongSelf.cropView.cropBoxFrame toView:strongSelf.view];
        if (!CGRectIsEmpty(transitioning.fromFrame) || transitioning.fromView) {
            strongSelf.cropView.croppingViewsHidden = YES;
        }

        if (strongSelf.prepareForTransitionHandler)
            strongSelf.prepareForTransitionHandler();
        
        strongSelf.prepareForTransitionHandler = nil;
    };
    
    self.transitionController.isDismissing = NO;
    return self.transitionController;
}

- (id <UIViewControllerAnimatedTransitioning>)animationControllerForDismissedController:(UIViewController *)dismissed
{
    if (self.navigationController || self.modalTransitionStyle == UIModalTransitionStyleCoverVertical) {
        return nil;
    }
    
    __weak typeof (self) weakSelf = self;
    self.transitionController.prepareForTransitionHandler = ^{
        typeof (self) strongSelf = weakSelf;
        CLCropViewControllerTransitioning *transitioning = strongSelf.transitionController;
        
        if (!CGRectIsEmpty(transitioning.toFrame) || transitioning.toView)
            strongSelf.cropView.croppingViewsHidden = YES;
        else
//            strongSelf.cropView.simpleRenderMode = YES;
        
        if (strongSelf.prepareForTransitionHandler)
            strongSelf.prepareForTransitionHandler();
    };
    
    self.transitionController.isDismissing = YES;
    return self.transitionController;
}

@end

