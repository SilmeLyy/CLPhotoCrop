//
//  CLTextInputView.m
//  CLPhotoCrop
//
//  Created by 雷玉宇 on 2022/2/7.
//

#import "CLTextInputView.h"
#import "CLColorToolView.h"
#import "CLPhotoCrop.h"

@interface CLTextInputView()<CLColorToolViewDelegate>

@property (nonatomic, assign) CGFloat orgY;
@property (nonatomic, strong) CLColorToolView *colorView;
@property (nonatomic, strong) UIView *bgView;
@property (nonatomic, strong) UITextView *textView;
@property (nonatomic, strong) UIButton *cancelBtn;
@property (nonatomic, strong) UIButton *doneBtn;

@end

@implementation CLTextInputView

- (instancetype)init
{
    self = [super init];
    if (self) {
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(keyboardWillShow:)
                                                     name:UIKeyboardWillShowNotification
                                                   object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(keyboardWillHide:)
                                                     name:UIKeyboardWillHideNotification
                                                   object:nil];
        [self initView];
        self.textView.textColor = [UIColor whiteColor];
    }
    return self;
}

- (void)showWith: (UIView *)superView {
    [superView addSubview:self];
    [_textView becomeFirstResponder];
    self.colorView.frame = CGRectMake(0, CLP_SCREENHEIGHT, CLP_SCREENWIDTH, 40);
    self.cancelBtn.frame = CGRectMake(10, CLP_SCREENHEIGHT, 44, 44);
    self.doneBtn.frame = CGRectMake(CLP_SCREENWIDTH - 54, CLP_SCREENHEIGHT, 44, 35);
    [UIView animateWithDuration:0.25 animations:^{
        self.colorView.frame = CGRectMake(0, CLP_SCREENHEIGHT - 40 - CLP_SAFEBOTTOMPADDING, CLP_SCREENWIDTH, 40);
        self.cancelBtn.frame = CGRectMake(10, CLP_SAFETOPPADDING, 44, 44);
        self.doneBtn.frame = CGRectMake(CLP_SCREENWIDTH - 54, CLP_SAFETOPPADDING + 4.5, 44, 35);
    } completion:^(BOOL finished) {
        
    }];
}

- (void)dismiss {
    self.textView.text = @"";
    [self endEditing:true];
    [UIView animateWithDuration:0.25 animations:^{
        self.colorView.frame = CGRectMake(0, CLP_SCREENHEIGHT, CLP_SCREENWIDTH, 40);
        self.cancelBtn.frame = CGRectMake(10, CLP_SCREENHEIGHT, 44, 44);
        self.doneBtn.frame = CGRectMake(CLP_SCREENWIDTH - 54, CLP_SCREENHEIGHT, 44, 35);
    } completion:^(BOOL finished) {
        [self removeFromSuperview];
    }];
}

- (void)clickDone {
    NSString *str = _textView.text;
    if ([_delegate respondsToSelector:@selector(textInputViewComplete: andColor:)] && str.length > 0) {
        [_delegate textInputViewComplete: str andColor: self.textView.textColor];
    }
    [self dismiss];
}

- (void)initView {
    self.backgroundColor = [UIColor clearColor];
    _bgView = [[UIView alloc] init];
    _bgView.backgroundColor = [UIColor blackColor];
    _bgView.frame = CGRectMake(0, 0, CLP_SCREENWIDTH, CLP_SCREENHEIGHT);
    [self addSubview:_bgView];
    
    _textView = [[UITextView alloc] init];
    _textView.backgroundColor = [UIColor clearColor];
    _textView.textColor = [UIColor whiteColor];
    _textView.font = [UIFont systemFontOfSize:25];
    _textView.returnKeyType = UIReturnKeyDone;
    
    _textView.frame = CGRectMake(20, CLP_SAFETOPHEIGHT, CLP_SCREENWIDTH - 40, CLP_SCREENHEIGHT - 40 - CLP_SAFETOPHEIGHT);
    [self addSubview:_textView];
    
    _colorView = [[CLColorToolView alloc] initWithType:1];
    _colorView.frame = CGRectMake(0, CLP_SCREENHEIGHT, CLP_SCREENWIDTH, 40);
    _colorView.delegate = self;
    [self addSubview:_colorView];
    
    UIButton *cancelBtn = [[UIButton alloc] init];
    [cancelBtn setTitle:@"取消" forState:UIControlStateNormal];
    [cancelBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    cancelBtn.titleLabel.font = [UIFont systemFontOfSize:15];
    [cancelBtn addTarget:self action:@selector(dismiss) forControlEvents:UIControlEventTouchUpInside];
    _cancelBtn = cancelBtn;
    [self addSubview:cancelBtn];
    
    UIButton *doneBtn = [[UIButton alloc] init];
    doneBtn.titleLabel.font = [UIFont systemFontOfSize:15];
    [doneBtn setTitle:@"完成" forState:UIControlStateNormal];
    [doneBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [doneBtn addTarget:self action:@selector(clickDone) forControlEvents:UIControlEventTouchUpInside];
    doneBtn.layer.cornerRadius = 5;
    doneBtn.clipsToBounds = true;
    _doneBtn = doneBtn;
    [doneBtn setBackgroundImage:[UIImage clp_imageColor:CLP_COLOR(82, 170, 56)] forState:UIControlStateNormal];
    [self addSubview:doneBtn];
    cancelBtn.frame = CGRectMake(10, CLP_SCREENHEIGHT, 44, 44);
    doneBtn.frame = CGRectMake(CLP_SCREENWIDTH - 54, CLP_SCREENHEIGHT, 44, 35);
    
    
}

- (void)keyboardWillShow:(NSNotification *)notification {
    NSDictionary *userinfo = notification.userInfo;
    CGRect  keyboardRect              = [[userinfo objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
    CGFloat keyboardAnimationDuration = [[userinfo objectForKey:UIKeyboardAnimationDurationUserInfoKey] doubleValue];
    UIViewAnimationOptions keyboardAnimationCurve = [[userinfo objectForKey:UIKeyboardAnimationCurveUserInfoKey] integerValue];
    
    _orgY = self.frame.origin.y;
    
    self.hidden = YES;
    [UIView animateWithDuration:keyboardAnimationDuration delay:0.f options:keyboardAnimationCurve animations:^{
        self.colorView.frame = CGRectMake(0, CLP_SCREENHEIGHT - 40 - keyboardRect.size.height, CLP_SCREENWIDTH, 40);
        self.textView.frame = CGRectMake(0, CLP_SAFETOPHEIGHT, CLP_SCREENWIDTH, CLP_SCREENHEIGHT - keyboardRect.size.height - 40 - CLP_SAFETOPHEIGHT);
    } completion:^(BOOL finished) {}];
    
    [UIView animateWithDuration:3 animations:^{
        self.hidden = NO;
    }];
}

- (void)keyboardWillHide:(NSNotification *)notification {
    NSDictionary *userinfo = notification.userInfo;
    CGFloat keyboardAnimationDuration = [[userinfo objectForKey:UIKeyboardAnimationDurationUserInfoKey] doubleValue];
    UIViewAnimationOptions keyboardAnimationCurve = [[userinfo objectForKey:UIKeyboardAnimationCurveUserInfoKey] integerValue];
    
    
    [UIView animateWithDuration:keyboardAnimationDuration delay:0.f options:keyboardAnimationCurve animations:^{
        self.colorView.frame = CGRectMake(0, CLP_SCREENHEIGHT - 40 - CLP_SAFEBOTTOMPADDING, CLP_SCREENWIDTH, 40);
        self.textView.frame = CGRectMake(0, CLP_SAFETOPHEIGHT, CLP_SCREENWIDTH, CLP_SCREENHEIGHT - 40 - CLP_SAFETOPHEIGHT);
    } completion:^(BOOL finished) {
        
    }];
}

- (void)CLColorToolViewCLickColor:(UIColor *)color {
    self.textView.textColor = color;
}

@end
