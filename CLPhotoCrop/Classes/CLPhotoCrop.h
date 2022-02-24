//
//  CLPhotoCrop.h
//  CLPhotoCrop
//
//  Created by 雷玉宇 on 2022/1/26.
//

#ifndef CLPhotoCrop_h
#define CLPhotoCrop_h

#import "CLPImage+Category.h"
#import "CLPhotoCropManager.h"
#import "CLPhotoShopViewController.h"

#define CLP_SCALE [UIScreen mainScreen].scale
#define CLP_SCREENWIDTH  [UIScreen mainScreen].bounds.size.width
#define CLP_SCREENHEIGHT  [UIScreen mainScreen].bounds.size.height
#define CLP_SAFEBOTTOMPADDING  (iphoneX() ? 34.f : 0.f)
#define CLP_SAFEBOTTOMHEIGHT  (iphoneX() ? 49.f + 34.f : 49.f)
#define CLP_SAFETOPPADDING  (iphoneX() ? 44.f : 20.f)
#define CLP_SAFETOPHEIGHT  (iphoneX() ? 88.f : 64.f)
#define CLP_COLOR(r,g,b)  [UIColor colorWithRed:(r/255.0) green:(g/255.0)  blue:(b/255.0) alpha:1]
#define CLP_HEXCOLOR(hex) CLP_COLOR(((hex & 0xFF0000) >> 16),((hex & 0xFF00) >> 8),(hex & 0xFF))
#define CLP_WEAKSELF __weak __typeof(&*self) weakSelf = self;


typedef NS_ENUM(NSUInteger, CLPDrawMode) {
    CLPDrawModeColor,
    CLPDrawModeGaussan,
    CLPDrawModeMosaic,
};

static inline BOOL iphoneX() {
    if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPhone) {
        if (@available(iOS 11.0, *)) {
            UIWindow *window = [[[UIApplication sharedApplication] windows] firstObject];
            return window.safeAreaInsets.bottom > 0.f;
        } else {
            return false;
        }
    }
    return false;
}

#endif /* CLPhotoCrop_h */
