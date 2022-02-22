//
//  CLMosaicDoobleView.m
//  CLPhotoCrop
//
//  Created by 雷玉宇 on 2022/1/28.
//

#import "CLMosaicDoobleView.h"
#import "CLPSImageView.h"

@implementation CLMosaicDoobleView

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.lineWidth = 20;
    }
    return self;
}

- (void)setMosaicImage:(UIImage *)mosaicImage {
    _mosaicImage = mosaicImage;
    if (self.drawMode == CLPDrawModeMosaic) {
        self.doodleColor = [UIColor colorWithPatternImage:mosaicImage];
    }
}

- (void)setGaussanImage:(UIImage *)gaussanImage {
    _gaussanImage = gaussanImage;
    if (self.drawMode == CLPDrawModeGaussan) {
        self.doodleColor = [UIColor colorWithPatternImage:gaussanImage];
    }
}

- (void)setDrawMode:(CLPDrawMode)drawMode {
    if (drawMode == CLPDrawModeMosaic) {
        self.doodleColor = [UIColor colorWithPatternImage:self.mosaicImage];
    } else {
        self.doodleColor = [UIColor colorWithPatternImage:self.gaussanImage];
    }
}

@end
