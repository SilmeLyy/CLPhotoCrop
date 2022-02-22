//
//  CLColorToolView.m
//  CLPhotoCrop
//
//  Created by 雷玉宇 on 2022/1/27.
//

#import "CLColorToolView.h"
#import "CLColorButton.h"
#import "CLPhotoCrop.h"

@interface CLColorToolView()

@property (nonatomic, strong) NSArray *colors;
@property (nonatomic, strong) UISlider *slider;
@property (nonatomic, assign) NSInteger type;

@end

@implementation CLColorToolView

- (NSArray *)colors {
    if (!_colors) {
        _colors = @[CLP_HEXCOLOR(0xffffff),
                    CLP_HEXCOLOR(0xed1941),
                    CLP_HEXCOLOR(0xf47920),
                    CLP_HEXCOLOR(0xffc20e),
                    CLP_HEXCOLOR(0xb2d235),
                    CLP_HEXCOLOR(0x009ad6),
                    CLP_HEXCOLOR(0x2a5caa),
                    CLP_HEXCOLOR(0x472d56)];
    }
    return _colors;
}

- (instancetype)initWithType: (NSInteger)type {
    self = [super init];
    if (self) {
        self.type = type;
        [self initView];
    }
    return self;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        [self initView];
    }
    return self;
}

- (void)initView {
    if (!self.type) {
        self.slider = [[UISlider alloc] init];
        [self.slider addTarget:self action:@selector(panSlider:) forControlEvents:UIControlEventValueChanged];
        [self.slider setValue:0.3 animated:true];
        [self.slider setThumbImage:[UIImage clp_imageNamed:@"cl_round_icon"] forState:UIControlStateNormal];
        self.slider.frame = CGRectMake(10, 0, CLP_SCREENWIDTH - 20, 20);
        [self addSubview:self.slider];
    }
    
    NSInteger count = self.type ? self.colors.count : self.colors.count + 1;
    CGFloat top = self.type ? 10 : 25;
    CGFloat width = (CLP_SCREENWIDTH - 20) / count;
    for (int i = 0; i < count; i ++) {
        CLColorButton *btn = [[CLColorButton alloc] init];
        btn.frame = CGRectMake(10 + width * i, top, width, 30);
        if (i == _colors.count) {
            [btn addTarget:self action:@selector(clickProvious) forControlEvents:UIControlEventTouchUpInside];
            [btn setImage:[UIImage clp_imageNamed:@"cl_provious_icon"] forState:UIControlStateNormal];
            btn.imageView.contentMode = UIViewContentModeScaleAspectFit;
        } else {
            [btn addTarget:self action:@selector(clickBtn:) forControlEvents:UIControlEventTouchUpInside];
            [btn drawRadius:7 andColor:_colors[i]];
        }
        if (i == 0) {
            btn.selected = true;
            self.lastBtn = btn;
        }
        btn.tag = i;
        [self addSubview:btn];
    }
}

- (void)panSlider: (UISlider *)slider {
    if ([_delegate respondsToSelector:@selector(CLColorToolViewChangeLineWidth:)]) {
        [_delegate CLColorToolViewChangeLineWidth:slider.value * 10];
    }
}

- (void)clickProvious {
    if ([_delegate respondsToSelector:@selector(CLColorToolViewCLickProvious)]) {
        [_delegate CLColorToolViewCLickProvious];
    }
}

- (void)clickBtn: (UIButton *)btn {
    if (self.lastBtn) {
        self.lastBtn.selected = false;
    }
    btn.selected = true;
    self.lastBtn = btn;
    if ([_delegate respondsToSelector:@selector(CLColorToolViewCLickColor:)]) {
        [_delegate CLColorToolViewCLickColor:_colors[btn.tag]];
    }
}

@end
