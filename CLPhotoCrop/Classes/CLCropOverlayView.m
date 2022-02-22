//
//  CLCropOverlayView.m
//  CLPhotoCrop
//
//  Created by 雷玉宇 on 2022/2/8.
//

#import "CLCropOverlayView.h"

static const CGFloat CLCropOverLayerCornerWidth = 20.0f;

@interface CLCropOverlayView()

@property (nonatomic, strong) NSArray *leftTopCorners;
@property (nonatomic, strong) NSArray *rightTopCorners;
@property (nonatomic, strong) NSArray *leftBottomCorners;
@property (nonatomic, strong) NSArray *rightBottomCorners;

@property (nonatomic, strong) NSArray *outBorderLines;

@property (nonatomic, strong) NSArray *horizontalGridLines;
@property (nonatomic, strong) NSArray *verticalGridLines;

@property (nonatomic, strong) NSArray *overLayers;

@end

@implementation CLCropOverlayView

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.clipsToBounds = false;
        self.userInteractionEnabled = false;
        [self initView];
    }
    return self;
}

- (void)initView {
    _leftTopCorners = @[[self createNewLineView], [self createNewLineView]];
    _rightTopCorners = @[[self createNewLineView], [self createNewLineView]];
    _leftBottomCorners = @[[self createNewLineView], [self createNewLineView]];
    _rightBottomCorners = @[[self createNewLineView], [self createNewLineView]];
    
    _outBorderLines = @[[self createBorderLineView], [self createBorderLineView], [self createBorderLineView], [self createBorderLineView]];
}

- (void)setGridHidden:(BOOL)hidden animated:(BOOL)animated
{
    _gridHidden = hidden;
    
    if (animated == NO) {
        for (UIView *lineView in self.horizontalGridLines) {
            lineView.alpha = hidden ? 0.0f : 1.0f;
        }
        
        for (UIView *lineView in self.verticalGridLines) {
            lineView.alpha = hidden ? 0.0f : 1.0f;
        }
    
        return;
    }
    
    [UIView animateWithDuration:hidden?0.35f:0.2f animations:^{
        for (UIView *lineView in self.horizontalGridLines)
            lineView.alpha = hidden ? 0.0f : 1.0f;
        
        for (UIView *lineView in self.verticalGridLines)
            lineView.alpha = hidden ? 0.0f : 1.0f;
    }];
}

- (void)setFrame:(CGRect)frame
{
    [super setFrame:frame];
    
    if (_outBorderLines)
        [self layoutLines];
}

- (void)didMoveToSuperview {
    [super didMoveToSuperview];
    if (_outBorderLines)
        [self layoutLines];
}

- (void)layoutLines {
    CGSize boundsSize = self.bounds.size;
    UIView *lineView = self.outBorderLines[0];
    lineView.frame = (CGRect){ 0, -1.0f, boundsSize.width+2.0f, 1.0f };
    UIView *line1View = self.outBorderLines[1];
    line1View.frame = (CGRect){ boundsSize.width,0.0f,1.0f,boundsSize.height };
    UIView *line2View = self.outBorderLines[2];
    line2View.frame = (CGRect){ -1.0f,boundsSize.height,boundsSize.width+2.0f,1.0f };
    UIView *line3View = self.outBorderLines[3];
    line3View.frame = (CGRect){ -1.0f, 0, 1.0f, boundsSize.height+1.0f };
    
    NSArray *cornerLines = @[self.leftTopCorners, self.rightTopCorners, self.rightBottomCorners, self.leftBottomCorners];
    for (int i = 0; i < cornerLines.count; i++) {
        NSArray *cornerLine = cornerLines[i];
        CGRect verticalFrame = CGRectZero;
        CGRect horizontalFrame = CGRectZero;
        switch (i) {
            case 0: //top left
                verticalFrame = (CGRect){ -3.0f, -3.0f, 3.0f, CLCropOverLayerCornerWidth+3.0f };
                horizontalFrame = (CGRect){ 0,-3.0f,CLCropOverLayerCornerWidth,3.0f};
                break;
            case 1: //top right
                verticalFrame = (CGRect){ boundsSize.width, -3.0f, 3.0f,CLCropOverLayerCornerWidth+3.0f};
                horizontalFrame = (CGRect){ boundsSize.width-CLCropOverLayerCornerWidth, -3.0f, CLCropOverLayerCornerWidth, 3.0f};
                break;
            case 2: //bottom right
                verticalFrame = (CGRect){ boundsSize.width, boundsSize.height-CLCropOverLayerCornerWidth, 3.0f, CLCropOverLayerCornerWidth+3.0f};
                horizontalFrame = (CGRect){ boundsSize.width-CLCropOverLayerCornerWidth, boundsSize.height, CLCropOverLayerCornerWidth,3.0f};
                break;
            case 3: //bottom left
                verticalFrame = (CGRect){ -3.0f, boundsSize.height-CLCropOverLayerCornerWidth, 3.0f, CLCropOverLayerCornerWidth};
                horizontalFrame = (CGRect){ -3.0f, boundsSize.height, CLCropOverLayerCornerWidth+3.0f, 3.0f};
                break;
        }
        
        [cornerLine[0] setFrame:verticalFrame];
        [cornerLine[1] setFrame:horizontalFrame];
    }
    
    CGFloat thickness = 1.0f / [[UIScreen mainScreen] scale];
    NSInteger numberOfLines = self.horizontalGridLines.count;
    CGFloat padding = (CGRectGetHeight(self.bounds) - (thickness*numberOfLines)) / (numberOfLines + 1);
    for (NSInteger i = 0; i < numberOfLines; i++) {
        UIView *lineView = self.horizontalGridLines[i];
        CGRect frame = CGRectZero;
        frame.size.height = thickness;
        frame.size.width = CGRectGetWidth(self.bounds);
        frame.origin.y = (padding * (i+1)) + (thickness * i);
        lineView.frame = frame;
    }
    
    numberOfLines = self.verticalGridLines.count;
    padding = (CGRectGetWidth(self.bounds) - (thickness*numberOfLines)) / (numberOfLines + 1);
    for (NSInteger i = 0; i < numberOfLines; i++) {
        UIView *lineView = self.verticalGridLines[i];
        CGRect frame = CGRectZero;
        frame.size.width = thickness;
        frame.size.height = CGRectGetHeight(self.bounds);
        frame.origin.x = (padding * (i+1)) + (thickness * i);
        lineView.frame = frame;
    }
}

- (void)setDisplayHorizontalGridLines:(BOOL)displayHorizontalGridLines {
    _displayHorizontalGridLines = displayHorizontalGridLines;
    
    [self.horizontalGridLines enumerateObjectsUsingBlock:^(UIView *__nonnull lineView, NSUInteger idx, BOOL * __nonnull stop) {
        [lineView removeFromSuperview];
    }];
    
    if (_displayHorizontalGridLines) {
        self.horizontalGridLines = @[[self createNewLineView], [self createNewLineView]];
    } else {
        self.horizontalGridLines = @[];
    }
    [self setNeedsDisplay];
}

- (void)setDisplayVerticalGridLines:(BOOL)displayVerticalGridLines {
    _displayVerticalGridLines = displayVerticalGridLines;
    
    [self.verticalGridLines enumerateObjectsUsingBlock:^(UIView *__nonnull lineView, NSUInteger idx, BOOL * __nonnull stop) {
        [lineView removeFromSuperview];
    }];
    
    if (_displayVerticalGridLines) {
        self.verticalGridLines = @[[self createNewLineView], [self createNewLineView]];
    } else {
        self.verticalGridLines = @[];
    }
    [self setNeedsDisplay];
}

- (void)setGridHidden:(BOOL)gridHidden
{
    [self setGridHidden:gridHidden animated:NO];
}

- (nonnull UIView *)createNewLineView {
    UIView *newLine = [[UIView alloc] initWithFrame:CGRectZero];
    newLine.backgroundColor = [UIColor whiteColor];
    [self addSubview:newLine];
    return newLine;
}

- (nonnull UIView *)createBorderLineView {
    UIView *newLine = [[UIView alloc] initWithFrame:CGRectZero];
    newLine.backgroundColor = [UIColor whiteColor];
    newLine.layer.shadowColor  = [UIColor blackColor].CGColor;
    newLine.layer.shadowOffset = CGSizeMake(0, 0);
    newLine.layer.shadowRadius = 1.5f;
    newLine.layer.shadowOpacity= 0.8f;
    [self addSubview:newLine];
    return newLine;
}


@end
