//
//  CLCropToolView.m
//  CLPhotoCrop
//
//  Created by 雷玉宇 on 2022/2/8.
//

#import "CLCropToolView.h"
#import "CLPhotoCrop.h"

@interface CLCropToolView()

@property (nonatomic, strong) UIButton *doneBtn;
@property (nonatomic, strong) UIButton *closeBtn;
@property (nonatomic, strong) UIButton *resetBtn;
@property (nonatomic, strong) UIButton *rotateBtn;

@end

@implementation CLCropToolView

- (instancetype)init
{
    self = [super init];
    if (self) {
        [self initView];
    }
    return self;
}

- (void)initView {
    self.backgroundColor = [UIColor clearColor];
    _doneBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [_doneBtn setImage:[UIImage clp_imageNamed:@"cl_ok"] forState:UIControlStateNormal];
    [_doneBtn addTarget:self action:@selector(clickDoneBtn) forControlEvents:UIControlEventTouchUpInside];
    _doneBtn.frame = CGRectMake(CLP_SCREENWIDTH - 64, 4.5, 44, 44);
    [self addSubview:_doneBtn];
    
    _closeBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [_closeBtn setImage:[UIImage clp_imageNamed:@"cl_close"] forState:UIControlStateNormal];
    [_closeBtn addTarget:self action:@selector(clickCloseBtn) forControlEvents:UIControlEventTouchUpInside];
    _closeBtn.frame = CGRectMake(20, 4.5, 44, 44);
    [self addSubview:_closeBtn];
    
    _resetBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    _resetBtn.contentMode = UIViewContentModeCenter;
    _resetBtn.enabled = NO;
    [_resetBtn setTitle:@"还原" forState:UIControlStateNormal];
    _resetBtn.titleLabel.font = [UIFont systemFontOfSize:14];
    [_resetBtn setTitleColor:CLP_HEXCOLOR(0x289BF0) forState:UIControlStateNormal];
    [_resetBtn setTitleColor:[UIColor lightTextColor] forState:UIControlStateDisabled];
    [_resetBtn addTarget:self action:@selector(clickResetBtn) forControlEvents:UIControlEventTouchUpInside];
    _resetBtn.frame = CGRectMake(CLP_SCREENWIDTH / 2 - 54, 4.5, 44, 44);
    [self addSubview:_resetBtn];
    
    _rotateBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [_rotateBtn setImage:[UIImage clp_imageNamed:@"cl_rotate"] forState:UIControlStateNormal];
    [_rotateBtn addTarget:self action:@selector(clickRotateBtn) forControlEvents:UIControlEventTouchUpInside];
    _rotateBtn.frame = CGRectMake(CLP_SCREENWIDTH / 2 + 10, 4.5, 44, 44);
    [self addSubview:_rotateBtn];
}

- (void)setResetButtonEnabled:(BOOL)resetButtonEnabled {
    _resetButtonEnabled = resetButtonEnabled;
    _resetBtn.enabled = resetButtonEnabled;
}

- (void)clickDoneBtn {
    if ([_delegate respondsToSelector:@selector(cropToolViewClickDoneBtn)]) {
        [_delegate cropToolViewClickDoneBtn];
    }
}

- (void)clickCloseBtn {
    if ([_delegate respondsToSelector:@selector(cropToolViewClickCloseBtn)]) {
        [_delegate cropToolViewClickCloseBtn];
    }
}

- (void)clickResetBtn {
    if ([_delegate respondsToSelector:@selector(cropToolViewClickResetBtn)]) {
        [_delegate cropToolViewClickResetBtn];
    }
}

- (void)clickRotateBtn {
    if ([_delegate respondsToSelector:@selector(cropToolViewClickRotateBtn)]) {
        [_delegate cropToolViewClickRotateBtn];
    }
}
@end
