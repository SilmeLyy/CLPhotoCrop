//
//  CLBottomToolView.m
//  CLPhotoCrop
//
//  Created by 雷玉宇 on 2022/1/28.
//

#import "CLBottomToolView.h"
#import "CLPhotoCrop.h"

@implementation CLBottomToolView

- (instancetype)init
{
    self = [super init];
    if (self) {
        [self initView];
    }
    return self;
}

- (void)initView {
    UIButton *doneBtn = [[UIButton alloc] init];
    doneBtn.layer.cornerRadius = 5;
    doneBtn.clipsToBounds = true;
    [doneBtn setTitle:@"完成" forState:UIControlStateNormal];
    [doneBtn setBackgroundImage:[UIImage clp_imageColor:CLP_COLOR(82, 170, 56)] forState:UIControlStateNormal];
    [doneBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    doneBtn.titleLabel.font = [UIFont systemFontOfSize:14];
    [self addSubview:doneBtn];
    [doneBtn addTarget:self action:@selector(clickDoneBtn) forControlEvents:UIControlEventTouchUpInside];
    doneBtn.frame = CGRectMake(CLP_SCREENWIDTH - 74, 7, 64, 35);
    
    
    NSArray<NSString *> *imageNames = @[@"cl_toolbar_annotate_item", @"cl_toolbar_pic_item", @"cl_toolbar_text_item", @"cl_toolbar_clip_item", @"cl_toolbar_mosaic_item"];
    NSArray<NSString *> *selectedImageNames = @[@"cl_toolbar_annotate_selected_item", @"", @"", @"", @"cl_toolbar_mosaic_selected_item"];
    CGFloat width = (CLP_SCREENWIDTH - 174) / imageNames.count;
    for (int i = 0; i < imageNames.count; i ++) {
        UIButton *btn = [[UIButton alloc] init];
        [btn setImage:[UIImage clp_imageNamed:imageNames[i]] forState:UIControlStateNormal];
        if (selectedImageNames[i].length > 0) {
            [btn setImage:[UIImage clp_imageNamed:selectedImageNames[i]] forState:UIControlStateSelected];
        }
        btn.tag = i;
        btn.imageView.contentMode = UIViewContentModeScaleAspectFit;
        btn.frame = CGRectMake((width + 20) * i, 7, width, 35);
        [btn addTarget:self action:@selector(clickItemBtn:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:btn];
    }
}

- (void)clickDoneBtn {
    if ([_delegate respondsToSelector:@selector(CLBottomToolViewCLickDoneBtn)]) {
        [_delegate CLBottomToolViewCLickDoneBtn];
    }
}

- (void)clickItemBtn: (UIButton *)btn {
    if (btn.tag == 0 || btn.tag == 4) {
        if (self.lastBtn == btn) {
            self.lastBtn.selected = false;
            self.lastBtn = nil;
        } else {
            self.lastBtn.selected = false;
            btn.selected = true;
            self.lastBtn = btn;
        }
    }
    if ([_delegate respondsToSelector:@selector(CLBottomToolViewCLickItemBtn:)]) {
        [_delegate CLBottomToolViewCLickItemBtn: btn];
    }
}

@end
