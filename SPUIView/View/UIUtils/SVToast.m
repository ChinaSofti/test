//
//  SVToast.m
//  SpeedPro
//
//  Created by Rain on 3/4/16.
//  Copyright © 2016 chinasofti. All rights reserved.
//

#import "SVToast.h"


#define DEFAULT_DISPLAY_DURATION 2.0f
#define DEFAULT_LINE_HEIGHT 30

@implementation SVToast

static NSLock *lock;

- (id)init
{
    self = [super init];
    duration = DEFAULT_DISPLAY_DURATION;

    //    if (!lock)
    //    {
    //        lock = [[NSLock alloc] init];
    //    }

    if (self)
    {
        return self;
    }

    return nil;
}

- (id)initWithText:(NSString *)text_
{
    if (self = [self init])
    {
        UIImage *toast_icon = [UIImage imageNamed:@"toast_icon"];
        UIImageView *imageView = [[UIImageView alloc] initWithImage:toast_icon];
        imageView.frame = CGRectMake (5, (DEFAULT_LINE_HEIGHT - 18) / 2, 18, 18);

        UILabel *textLabel = [[UILabel alloc] init];
        NSDictionary *attributes = @{
            NSFontAttributeName: [UIFont systemFontOfSize:14],
        };
        CGSize textSize = [text_ boundingRectWithSize:CGSizeMake (500, 30)
                                              options:NSStringDrawingTruncatesLastVisibleLine
                                           attributes:attributes
                                              context:nil]
                          .size;
        [textLabel setFrame:CGRectMake (imageView.rightX + 10, (DEFAULT_LINE_HEIGHT - textSize.height) / 2,
                                        textSize.width + 10, textSize.height)];
        textLabel.backgroundColor = [UIColor clearColor];
        textLabel.textColor = [UIColor whiteColor];
        [textLabel setTextAlignment:NSTextAlignmentLeft];
        textLabel.font = [UIFont boldSystemFontOfSize:[UIFont smallSystemFontSize]];
        textLabel.text = text_;
        textLabel.numberOfLines = 1;

        contentView = [[UIButton alloc]

        initWithFrame:CGRectMake (0, 0, (imageView.size.width + textLabel.size.width) + 10, DEFAULT_LINE_HEIGHT)];
        NSLog (@"%f  %f ", imageView.size.width, textLabel.size.width);
        contentView.layer.cornerRadius = 15.0f;
        contentView.backgroundColor = [UIColor blackColor];
        [contentView addSubview:imageView];
        [contentView addSubview:textLabel];

        contentView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        [contentView addTarget:self
                        action:@selector (toastTaped:)
              forControlEvents:UIControlEventTouchDown];
        contentView.alpha = 0.0f;
    }
    return self;
}

- (void)dismissToast
{
    [contentView removeFromSuperview];
}

- (void)toastTaped:(UIButton *)sender_
{
    [self hideAnimation];
}
- (void)setDuration:(CGFloat)duration_
{
    duration = duration_;
}

- (void)showAnimation
{
    //    [lock lock];
    [UIView beginAnimations:@"show" context:NULL];
    [UIView setAnimationCurve:UIViewAnimationCurveEaseIn];
    [UIView setAnimationDuration:0.3];
    contentView.alpha = 0.5f;
    [UIView commitAnimations];
}

- (void)hideAnimation
{
    [UIView beginAnimations:@"hide" context:NULL];
    [UIView setAnimationCurve:UIViewAnimationCurveEaseOut];
    [UIView setAnimationDelegate:self];
    [UIView setAnimationDidStopSelector:@selector (dismissToast)];
    [UIView setAnimationDuration:0.3];
    contentView.alpha = 0.0f;
    [UIView commitAnimations];
    //    [lock unlock];
}


- (void)showFromBottomOffset:(CGFloat)bottom_
{
    UIWindow *window = [UIApplication sharedApplication].keyWindow;
    contentView.center =
    CGPointMake (window.center.x, window.frame.size.height - (bottom_ + contentView.frame.size.height / 2));
    [window addSubview:contentView];
    [self showAnimation];
    [self performSelector:@selector (hideAnimation) withObject:nil afterDelay:duration];
}

+ (void)showWithText:(NSString *)text_
        bottomOffset:(CGFloat)bottomOffset_
            duration:(CGFloat)duration_
{
    SVToast *toast = [[SVToast alloc] initWithText:text_];
    [toast setDuration:duration_];
    [toast showFromBottomOffset:bottomOffset_];
}


+ (void)showWithText:(NSString *)text_
{
    [SVToast showWithText:text_ bottomOffset:100 duration:2];
}

@end
