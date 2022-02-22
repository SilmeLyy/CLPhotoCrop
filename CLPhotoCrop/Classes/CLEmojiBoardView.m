//
//  CLEmojiBoardView.m
//  CLPhotoCrop
//
//  Created by 雷玉宇 on 2022/2/21.
//

#import "CLEmojiBoardView.h"
#import "CLEmojiBoardCell.h"
#import "CLPhotoCrop.h"

@interface CLEmojiBoardView()<UICollectionViewDataSource, UICollectionViewDelegate>

@property (nonatomic, strong) UIView *containerView;
@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, strong) UICollectionView *collectionView;
@property (nonatomic, strong) UIView *bgView;

@end

@implementation CLEmojiBoardView

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
    _bgView = [[UIView alloc] init];
    _bgView.backgroundColor = [UIColor clearColor];
    _bgView.frame = CGRectMake(0, 0, CLP_SCREENWIDTH, CLP_SCREENHEIGHT);
    [self addSubview:_bgView];
    
    _containerView = [[UIView alloc] init];
    _containerView.frame = CGRectMake(0, CLP_SCREENHEIGHT, CLP_SCREENWIDTH, 256);
    [self addSubview:_containerView];
    
    UIView *headView = [[UIView alloc] init];
    headView.backgroundColor = CLP_HEXCOLOR(0x444444);
    headView.frame = CGRectMake(0, 0, CLP_SCREENWIDTH, 50);
    _scrollView = [[UIScrollView alloc] init];
    _scrollView.frame = CGRectMake(10, 5, CLP_SCREENWIDTH - 62, 40);
    _scrollView.contentSize = CGSizeMake(CLP_SCREENWIDTH - 61, 40);
    _scrollView.bounces = true;
    [_containerView addSubview:headView];
    [headView addSubview:_scrollView];
    
    UIButton *btn = [[UIButton alloc] init];
    btn.layer.cornerRadius = 3;
    btn.imageEdgeInsets = UIEdgeInsetsMake(5, 5, 5, 5);
    [btn setImage:[UIImage clp_imageEmojiNamed:@"cl_dd_00"] forState:UIControlStateNormal];
    btn.frame = CGRectMake(0, 0, 40, 40);
    btn.backgroundColor = CLP_HEXCOLOR(0x333333);
    [_scrollView addSubview:btn];
    
    UIButton *backBtn = [[UIButton alloc] init];
    [backBtn setImage:[UIImage clp_imageNamed:@"cl_arrow_down"] forState:UIControlStateNormal];
    backBtn.frame = CGRectMake(CLP_SCREENWIDTH - 42, 5, 32, 40);
    [backBtn addTarget:self action:@selector(dismiss) forControlEvents:UIControlEventTouchUpInside];
    [headView addSubview:backBtn];
    
    CGFloat width = (CLP_SCREENWIDTH - 90) * 0.2;
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
    layout.itemSize = CGSizeMake(width, width);
    layout.minimumLineSpacing = 15;
    layout.minimumInteritemSpacing = 15;
    layout.sectionInset = UIEdgeInsetsMake(15, 15, 15, 15);
    _collectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(0, 50, CLP_SCREENWIDTH, 206) collectionViewLayout:layout];
    _collectionView.backgroundColor = CLP_HEXCOLOR(0x333333);
    _collectionView.showsVerticalScrollIndicator = false;
    _collectionView.showsHorizontalScrollIndicator = false;
    [_collectionView registerClass:[CLEmojiBoardCell class] forCellWithReuseIdentifier:@"CLEmojiBoardView"];
    _collectionView.delegate = self;
    _collectionView.dataSource = self;
    [_containerView addSubview:_collectionView];
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismiss)];
    [_bgView addGestureRecognizer:tap];
}

- (void)show {
    [[UIApplication sharedApplication].keyWindow addSubview:self];
    self.frame = CGRectMake(0, 0, CLP_SCREENWIDTH, CLP_SCREENHEIGHT);
    self.containerView.frame = CGRectMake(0, CLP_SCREENHEIGHT, CLP_SCREENWIDTH, 256);
    [UIView animateWithDuration:.25f animations:^{
        self.containerView.frame = CGRectMake(0, CLP_SCREENHEIGHT - 256, CLP_SCREENWIDTH, 256);
    }];
}

- (void)dismiss {
    [UIView animateWithDuration:.25f animations:^{
        self.containerView.frame = CGRectMake(0, CLP_SCREENHEIGHT, CLP_SCREENWIDTH, 256);
    } completion:^(BOOL finished) {
        [self removeFromSuperview];
    }];
}

#pragma mark- UICollectionViewDataSource
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return 20;
}

- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    CLEmojiBoardCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"CLEmojiBoardView" forIndexPath:indexPath];
    NSString *imageName = [NSString stringWithFormat:@"cl_dd_%ld", indexPath.item + 1];
    if (indexPath.item < 9) {
        imageName = [NSString stringWithFormat:@"cl_dd_0%ld",indexPath.item + 1];
    }
    cell.imageView.image = [UIImage clp_imageEmojiNamed:imageName];
    return cell;
}

#pragma mark- UICollectionViewDelegate
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    if ([_delegate respondsToSelector:@selector(emojiBoardViewClickIndexPath:andImage:)]) {
        NSString *imageName = [NSString stringWithFormat:@"cl_dd_%ld", indexPath.item + 1];
        if (indexPath.item < 9) {
            imageName = [NSString stringWithFormat:@"cl_dd_0%ld",indexPath.item + 1];
        }
        [_delegate emojiBoardViewClickIndexPath:indexPath andImage:[UIImage clp_imageEmojiNamed:imageName]];
    }
}

@end
