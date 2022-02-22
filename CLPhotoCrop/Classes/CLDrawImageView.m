//
//  CLDrawImageView.m
//  CLPhotoCrop
//
//  Created by 雷玉宇 on 2022/2/21.
//

#import "CLDrawImageView.h"
#import "CLPhotoCrop.h"

@implementation CLDrawImageView

- (void)setImage:(UIImage *)image {
    _image = image;
    self.frame = (CGRect){0,0,image.size.width * 0.5 + 30, image.size.height * 0.5 + 30};
}

- (void)drawRect:(CGRect)rect {
    [self.image drawInRect:CGRectMake(15, 15, self.image.size.width * 0.5, self.image.size.height * 0.5)];
}


@end
