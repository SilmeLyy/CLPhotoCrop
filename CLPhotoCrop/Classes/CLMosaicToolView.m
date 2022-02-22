//
//  CLMosaicToolView.m
//  CLPhotoCrop
//
//  Created by 雷玉宇 on 2022/1/28.
//

#import "CLMosaicToolView.h"
#import "CLPhotoCrop.h"

@interface CLMosaicToolView()

@end

@implementation CLMosaicToolView

- (instancetype)init
{
    self = [super init];
    if (self) {
        [self initView];
    }
    return self;
}

- (void)initView {
    UIButton *previousBtn = [[UIButton alloc] init];
    [previousBtn setImage:[UIImage clp_imageNamed:@"cl_provious_icon"] forState:UIControlStateNormal];
    [self addSubview:previousBtn];
    [previousBtn addTarget:self action:@selector(clickPreviousBtn:) forControlEvents:UIControlEventTouchUpInside];
    previousBtn.frame = CGRectMake(CLP_SCREENWIDTH - 60, 0, 40, 40);
    
    
    UIButton *mosaicBtn = [[UIButton alloc] init];
    mosaicBtn.selected = true;
    self.lastBtn = mosaicBtn;
    [mosaicBtn setImage:[UIImage clp_imageNamed:@"cl_toolbar_mos_icon"] forState:UIControlStateNormal];
    [mosaicBtn setImage:[UIImage clp_imageNamed:@"cl_toolbar_mos_selected_icon"] forState:UIControlStateSelected];
    [mosaicBtn addTarget:self action:@selector(clickItemBtn:) forControlEvents:UIControlEventTouchUpInside];
    mosaicBtn.tag = 0;
    UIButton *mosaicBtn1 = [[UIButton alloc] init];
    [mosaicBtn1 setImage:[UIImage clp_imageNamed:@"cl_toolbar_mos1_icon"] forState:UIControlStateNormal];
    [mosaicBtn1 setImage:[UIImage clp_imageNamed:@"cl_toolbar_mos1_selected_icon"] forState:UIControlStateSelected];
    [mosaicBtn1 addTarget:self action:@selector(clickItemBtn:) forControlEvents:UIControlEventTouchUpInside];
    mosaicBtn1.tag = 1;
    mosaicBtn.frame = CGRectMake(0, 0, 35, 35);
    mosaicBtn1.frame = CGRectMake(0, 0, 35, 35);
    mosaicBtn.center = CGPointMake((CLP_SCREENWIDTH - 100) / 4, 20);
    mosaicBtn1.center = CGPointMake((CLP_SCREENWIDTH - 100) / 4 * 3, 20);
    [self addSubview:mosaicBtn];
    [self addSubview:mosaicBtn1];
}

- (void)clickPreviousBtn: (UIButton *)btn {
    if ([_delegate respondsToSelector:@selector(CLMosaicToolViewClickPreviousBtn)]) {
        [_delegate CLMosaicToolViewClickPreviousBtn];
    }
}

- (void)clickItemBtn: (UIButton *)btn {
    self.lastBtn.selected = false;
    btn.selected = true;
    self.lastBtn = btn;
    if ([_delegate respondsToSelector:@selector(CLMosaicToolViewClickItemBtn:)]) {
        [_delegate CLMosaicToolViewClickItemBtn: btn];
    }
}

@end
