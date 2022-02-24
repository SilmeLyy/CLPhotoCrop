//
//  ViewController.m
//  CLPhotoCropDemo
//
//  Created by 雷玉宇 on 2022/2/21.
//

#import "TestViewController.h"
#import "ViewController.h"
#import "CLPhotoCrop.h"

@interface ViewController ()<CLPhotoShopViewControllerDelegate>

@property (nonatomic, strong) UIImageView *imageView;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor whiteColor];
    self.imageView = [[UIImageView alloc] init];
    self.imageView.frame = CGRectMake(0, CLP_SAFETOPHEIGHT, CLP_SCREENWIDTH, CLP_SCREENHEIGHT - CLP_SAFETOPHEIGHT);
    self.imageView.image = [UIImage clp_imageNamed:@"bg"];
    self.imageView.contentMode = UIViewContentModeScaleAspectFit;
    [self.view addSubview:self.imageView];
    
    UIButton *btn = [[UIButton alloc] init];
    btn.frame = CGRectMake(CLP_SCREENWIDTH - 54, CLP_SAFETOPPADDING, 44, 44);
    [btn setTitle:@"编辑" forState:UIControlStateNormal];
    [btn setTitleColor:CLP_HEXCOLOR(0x2a5caa) forState:UIControlStateNormal];
    [btn addTarget:self action:@selector(pushPhotoCrop) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:btn];
    
    UILabel *label = [[UILabel alloc] init];
    label.frame = CGRectMake(100, 0, 50, 20);
    label.backgroundColor = [UIColor redColor];
    [self.view addSubview:label];
}

- (void)pushPhotoCrop {
    CLPhotoShopViewController *vc = [[CLPhotoShopViewController alloc] init];
    vc.orgImage = [UIImage clp_imageNamed:@"bg"];
    vc.delegate = self;
    [self presentViewController:vc animated:true completion:nil];
}

- (void)CLPhotoShopViewControllerFinishImage:(UIImage *)image {
    self.imageView.image = image;
}

@end
