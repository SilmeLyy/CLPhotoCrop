//
//  CLDrawTextView.m
//  CLPhotoCrop
//
//  Created by 雷玉宇 on 2022/2/7.
//

#import "CLDrawTextView.h"
#import "CLPhotoCrop.h"

@interface CLDrawTextView()

@property (nonatomic, assign) CGSize textSize;

@end

@implementation CLDrawTextView

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.font = [UIFont systemFontOfSize:25];
        self.textColor = [UIColor whiteColor];
    }
    return self;
}

- (void)setText:(NSString *)text {
    _text = text;
    _textSize = [text boundingRectWithSize:CGSizeMake(CLP_SCREENWIDTH - 60, CGFLOAT_MAX) options:0 attributes:@{NSFontAttributeName: self.font} context:nil].size;
    self.frame = CGRectMake(0, 0, _textSize.width + 30, _textSize.height + 30);
    [self setNeedsDisplay];
}

- (void)drawRect:(CGRect)rect {
    NSAttributedString *string = [[NSAttributedString alloc] initWithString:self.text
                                                                 attributes:@{NSForegroundColorAttributeName: self.textColor,
                                                                              NSBackgroundColorAttributeName: UIColor.clearColor,
                                                                              NSFontAttributeName: self.font}];
    [string drawInRect:CGRectMake(15, 15, rect.size.width - 30, rect.size.height - 30)];
}

@end
