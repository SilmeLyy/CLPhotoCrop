//
//  CLEmojiBoardCell.m
//  CLPhotoCrop
//
//  Created by 雷玉宇 on 2022/2/21.
//

#import "CLEmojiBoardCell.h"
#import "CLPhotoCrop.h"

@implementation CLEmojiBoardCell

- (instancetype)init
{
    self = [super init];
    if (self) {
        [self initView];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self initView];
    }
    return self;
}

- (void)initView {
    CGFloat width = (CLP_SCREENWIDTH - 90) * 0.2;
    _imageView = [[UIImageView alloc] init];
    _imageView.frame = CGRectMake(0, 0, width, width);
    [self.contentView addSubview:_imageView];
}

@end
