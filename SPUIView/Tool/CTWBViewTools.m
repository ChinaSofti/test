//
//  CTWBViewTools.m
//  SPUIView
//
//  Created by WBapple on 16/1/25.
//  Copyright © 2016年 chinasofti. All rights reserved.
//

#import "CTWBViewTools.h"

@implementation CTWBViewTools

#pragma mark - 通用白色圆角背景rounded background

+ (UIView *)createBackgroundViewWithFrame:(CGRect)frame cornerRadius:(CGFloat)radius
{
    //大小
    UIView *backgroundview = [[UIView alloc] initWithFrame:frame];
    //白的背景
    backgroundview.backgroundColor = [UIColor whiteColor];
    //圆角弧度
    backgroundview.layer.cornerRadius = radius;
    //子视图超出部分能够现实
    backgroundview.layer.masksToBounds = YES;

    return backgroundview;
}

#pragma mark - 标签Label

+ (UILabel *)createLabelWithFrame:(CGRect)frame
                         withFont:(CGFloat)font
                   withTitleColor:(UIColor *)color
                        withTitle:(NSString *)title
{
    //大小
    UILabel *label = [[UILabel alloc] initWithFrame:frame];
    //字体
    label.font = [UIFont systemFontOfSize:font];
    //字体颜色
    label.textColor = color;
    //内容
    label.text = title;

    return label;
}


#pragma mark - 文本输入框TextFiled
//普通的
+ (UITextField *)createTextFieldWithFrame:(CGRect)frame
                              placeholder:(NSString *)placeholder
                                     Font:(float)font
                                fontColor:(UIColor *)color
{
    //大小
    UITextField *textField = [[UITextField alloc] initWithFrame:frame];
    //灰色提示框
    textField.placeholder = placeholder;
    //文字对齐方式
    textField.textAlignment = NSTextAlignmentRight;
    //清除按钮
    textField.clearButtonMode = NO;
    //编辑状态下一直存在
    textField.rightViewMode = UITextFieldViewModeWhileEditing;
    //字体
    textField.font = [UIFont systemFontOfSize:font];
    //字体颜色
    textField.textColor = color;

    return textField;
}
//有左右视图的
+ (UITextField *)createTextFieldWithFrame:(CGRect)frame
                              placeholder:(NSString *)placeholder
                                 passWord:(BOOL)YESorNO
                                 leftView:(UIView *)leftView
                                rightView:(UIView *)rightView
                                     Font:(float)font
                                fontColor:(UIColor *)color
{
    //大小
    UITextField *textField = [[UITextField alloc] initWithFrame:frame];
    //灰色提示框
    textField.placeholder = placeholder;
    //文字对齐方式
    textField.textAlignment = NSTextAlignmentLeft;
    //把密码变成显示状态时有效
    textField.secureTextEntry = YESorNO;
    //边框类型
    // textField.borderStyle=UITextBorderStyleLine;
    //键盘类型
    //    textField.keyboardType=UIKeyboardTypeEmailAddress;
    //关闭首字母大写
    textField.autocapitalizationType = NO;
    //清除按钮
    textField.clearButtonMode = YES;
    //左图片
    textField.leftView = leftView;
    //左侧视图小图标
    textField.leftViewMode = UITextFieldViewModeAlways;
    //右图片
    textField.rightView = rightView;
    //编辑状态下一直存在
    textField.rightViewMode = UITextFieldViewModeWhileEditing;

    //字体
    textField.font = [UIFont systemFontOfSize:font];
    //字体颜色
    textField.textColor = color;

    return textField;
}
//带有线的
+ (UITextField *)createTextFieldWithFrame:(CGRect)frame
                              placeholder:(NSString *)placeholder
                                 passWord:(BOOL)YESorNO
                                 leftView:(UIView *)leftView
                                rightView:(UIView *)rightView
                                     Font:(float)font
                            withLineColor:(UIColor *)lineColor
                                lineWidth:(CGFloat)linewidth
{
    UITextField *textField = [self createTextFieldWithFrame:frame
                                                placeholder:placeholder
                                                   passWord:YESorNO
                                                   leftView:leftView
                                                  rightView:rightView
                                                       Font:font
                                                  fontColor:[UIColor blackColor]];

    if (lineColor)
    {
        //线条长
        CGFloat width = frame.size.width;
        if (linewidth)
        {
            width = linewidth;
        }

        UIView *lineView =
        [self lineViewWithFrame:CGRectMake (frame.origin.x, frame.size.height - 1, width, 0.5)
                      withColor:lineColor];

        [textField addSubview:lineView];
    }

    return textField;
}

//输入框左view
+ (UIView *)viewWithFrame:(CGRect)frame withImage:(UIImage *)image withTitle:(NSString *)title
{
    UIView *view = [[UIView alloc] initWithFrame:CGRectZero];
    if (title)
    {
        //大小
        view.frame = frame;
        //图片
        UIImageView *imageV = [[UIImageView alloc] initWithImage:image];
        [view addSubview:imageV];

        UILabel *label = [[UILabel alloc]
        initWithFrame:CGRectMake (imageV.rightX + 5, imageV.originY + 5, view.width - imageV.rightX - 5, 20)];
        //内容
        label.text = title;
        label.font = [UIFont systemFontOfSize:17];
        label.textColor = RGBACOLOR (85, 85, 86, 1);
        [view addSubview:label];
    }
    else
    {
        view.frame = CGRectMake (0, 0, image.size.width + FITWIDTH (20), image.size.height);
        UIImageView *imageView = [[UIImageView alloc] initWithImage:image];
        view.backgroundColor = [UIColor orangeColor];
        [view addSubview:imageView];
    }
    return view;
}

#pragma mark - 按钮Button

+ (UIButton *)createBtnWithFrame:(CGRect)frame
                       withImage:(NSString *)btnImage
                       withTitle:(NSString *)title
{
    //类型
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    //大小
    button.frame = frame;
    UIImageView *topImageV =
    [[UIImageView alloc] initWithFrame:CGRectMake (0, 0, button.width, button.width)];
    //图片
    topImageV.image = [UIImage imageNamed:btnImage];

    [button addSubview:topImageV];

    UILabel *titleLabel = [[UILabel alloc]
    initWithFrame:CGRectMake (-FITWIDTH (10), topImageV.bottomY + FITWIDTH (10), button.width + FITWIDTH (20),
                              button.height - topImageV.bottomY - FITWIDTH (3))];

    titleLabel.text = title;
    titleLabel.textAlignment = NSTextAlignmentCenter;
    titleLabel.font = [UIFont systemFontOfSize:12];
    titleLabel.textColor = [UIColor whiteColor];

    [button addSubview:titleLabel];

    return button;
}
+ (UIButton *)createBtnWithFrame:(CGRect)frame
                       withImage:(NSString *)btnImage
                       withTitle:(NSString *)title
                    withImgFrame:(CGRect)imgFrame
                  withLabelFrame:(CGRect)labelFrame
{
    // button的大小,图片,标题
    UIButton *button = [self createBtnWithFrame:frame withImage:btnImage withTitle:title];

    for (UIView *view in button.subviews)
    {
        if ([view isKindOfClass:[UIImageView class]])
        {
            //图片大小
            view.frame = imgFrame;
        }
        if ([view isKindOfClass:[UILabel class]])
        {
            if (labelFrame.size.width)
            {
                // label大小
                view.frame = labelFrame;
            }
            else
            {
                view.frame = CGRectMake (0, imgFrame.size.height, frame.size.width,
                                         frame.size.height - imgFrame.size.height);
            }
        }
    }

    return button;
}

#pragma mark 普通button背景图片
//高亮和不同状态
+ (UIButton *)createBtnWithFrame:(CGRect)frame
                 backgroundImage:(NSString *)backgroundImage
               hightlightedImage:(NSString *)hightlighted
                           title:(NSString *)title
                      titleColor:(UIColor *)titleColor
{
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.frame = frame;
    [button setBackgroundImage:[UIImage imageNamed:backgroundImage] forState:UIControlStateNormal];
    [button setBackgroundImage:[UIImage imageNamed:hightlighted]
                      forState:UIControlStateHighlighted];
    [button setTitle:title forState:UIControlStateNormal];
    [button setTintColor:titleColor];
    return button;
}
//高亮,普通,选择三种状态
+ (UIButton *)createBtnWithFrame:(CGRect)frame
                     normalImage:(NSString *)normalImage
                   highlighImage:(NSString *)highlighImage
                     seleceImage:(NSString *)selectImage
                     normalTitle:(NSString *)normalTitle
                     normalColor:(UIColor *)normalColor
{
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];

    button.frame = frame;

    [button setTitle:normalTitle forState:UIControlStateNormal];
    button.titleLabel.font = [UIFont systemFontOfSize:14];
    [button setTitleColor:normalColor forState:UIControlStateNormal];


    [button setImage:[UIImage imageNamed:normalImage] forState:UIControlStateNormal];
    [button setImage:[UIImage imageNamed:highlighImage] forState:UIControlStateHighlighted];
    [button setImage:[UIImage imageNamed:selectImage] forState:UIControlStateSelected];

    return button;
}
//自定义UIBarButtonItem
+ (UIBarButtonItem *)itemWithImage:(NSString *)imageName
                     selectedImage:(NSString *)selectedImageName
                            Target:(id)target
                            action:(SEL)action
{
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];

    [button setImage:[UIImage imageNamed:imageName] forState:UIControlStateNormal];

    [button setImage:[UIImage imageNamed:selectedImageName] forState:UIControlStateSelected];
    [button addTarget:target action:action forControlEvents:UIControlEventTouchUpInside];
    button.size = button.currentImage.size;
    return [[UIBarButtonItem alloc] initWithCustomView:button];
}

// 文字与图片有偏移
+ (UIButton *)createBtnWithFrame:(CGRect)frame
                     normalImage:(NSString *)normalImage
                   highlighImage:(NSString *)highlighImage
                     seleceImage:(NSString *)selectImage
                     normalTitle:(NSString *)normalTitle
                     normalColor:(UIColor *)normalColor
                       titleEdge:(UIEdgeInsets)titleEdge
                       imageEdge:(UIEdgeInsets)imageEdge
{
    UIButton *button = [self createBtnWithFrame:frame
                                    normalImage:normalImage
                                  highlighImage:highlighImage
                                    seleceImage:selectImage
                                    normalTitle:normalTitle
                                    normalColor:normalColor];

    // button.imageEdgeInsets = UIEdgeInsetsMake( 0, 0, -60, 0);
    //设置image在button上的位置（上top，左left，下bottom，右right）这里可以写负值，对上写－5，那么image就象上移动5个像素
    button.titleLabel.textAlignment = NSTextAlignmentCenter; //设置title的字体居中
    button.titleLabel.font = [UIFont systemFontOfSize:15];
    button.titleEdgeInsets = titleEdge;
    button.imageEdgeInsets = imageEdge;
    //设置title在button上的位置（上top，左left，下bottom，右right）

    return button;
}

#pragma mark - 线view
//线view
+ (UIView *)lineViewWithFrame:(CGRect)frame withColor:(UIColor *)color
{
    UIView *lineView = [[UIView alloc] initWithFrame:frame];

    if (color)
    {
        lineView.backgroundColor = color;
    }
    else
    {
        lineView.backgroundColor = RGBACOLOR (103, 104, 104, 0.8);
    }

    return lineView;
}

#pragma mark - 计算文字大小

+ (CGSize)getSizeWith:(NSString *)string size:(CGSize)bigSize font:(CGFloat)font
{
    CGSize size = [string boundingRectWithSize:bigSize
                                       options:NSStringDrawingUsesLineFragmentOrigin
                                    attributes:@{
                                        NSFontAttributeName: [UIFont systemFontOfSize:font]
                                    }
                                       context:nil]
                  .size;

    return size;
}

#pragma mark -  AlertController
+ (UIAlertController *)alertViewWithTitle:(NSString *)title
                                  message:(NSString *)message
                                  okTitle:(NSString *)okTitle
                                  okClick:(void (^) (void))okClick
                              cancelTitle:(NSString *)cancelTitle
                              cancelClick:(void (^) (void))cancelClick
{
    UIAlertController *alertView = [UIAlertController alertControllerWithTitle:title
                                                                       message:message
                                                                preferredStyle:UIAlertControllerStyleAlert];

    [alertView addAction:[UIAlertAction actionWithTitle:okTitle
                                                  style:UIAlertActionStyleDefault
                                                handler:^(UIAlertAction *action) {
                                                  okClick ();
                                                }]];

    [alertView addAction:[UIAlertAction actionWithTitle:cancelTitle
                                                  style:UIAlertActionStyleCancel
                                                handler:^(UIAlertAction *action) {
                                                  cancelClick ();
                                                }]];

    return alertView;
}

#pragma mark ActionSheet
+ (UIActionSheet *)actionSheet
{
    UIActionSheet *actionsheet = [[UIActionSheet alloc] init];
    actionsheet.title = @"woshi actionsheet";
    return actionsheet;
}
#pragma mark - 生成图片缩略图
+ (UIImage *)thumbnailWithImageWithoutScale:(UIImage *)image size:(CGSize)asize
{
    UIImage *newimage;

    if (nil == image)
    {
        newimage = nil;
    }
    else
    {
        CGSize oldsize = image.size;
        CGRect rect;

        if (asize.width / asize.height > oldsize.width / oldsize.height)
        {
            rect.size.width = asize.height * oldsize.width / oldsize.height;
            rect.size.height = asize.height;
            rect.origin.x = (asize.width - rect.size.width) / 2;
            rect.origin.y = 0;
        }
        else
        {
            rect.size.width = asize.width;
            rect.size.height = asize.width * oldsize.height / oldsize.width;
            rect.origin.x = 0;
            rect.origin.y = (asize.height - rect.size.height) / 2;
        }

        UIGraphicsBeginImageContext (asize);

        CGContextRef context = UIGraphicsGetCurrentContext ();

        CGContextSetFillColorWithColor (context, [[UIColor clearColor] CGColor]);

        UIRectFill (CGRectMake (0, 0, asize.width, asize.height)); // clear background

        [image drawInRect:rect];

        newimage = UIGraphicsGetImageFromCurrentImageContext ();

        UIGraphicsEndImageContext ();
    }
    return newimage;
}

#pragma mark - 表情输入

+ (BOOL)isContainsEmoji:(NSString *)string
{
    __block BOOL isEomji = NO;
    [string
    enumerateSubstringsInRange:NSMakeRange (0, [string length])
                       options:NSStringEnumerationByComposedCharacterSequences
                    usingBlock:^(NSString *substring, NSRange substringRange, NSRange enclosingRange, BOOL *stop) {
                      const unichar hs = [substring characterAtIndex:0];
                      if (0xd800 <= hs && hs <= 0xdbff)
                      {
                          if (substring.length > 1)
                          {
                              const unichar ls = [substring characterAtIndex:1];
                              const int uc = ((hs - 0xd800) * 0x400) + (ls - 0xdc00) + 0x10000;
                              if (0x1d000 <= uc && uc <= 0x1f77f)
                              {
                                  isEomji = YES;
                              }
                          }
                      }
                      else if (substring.length > 1)
                      {
                          const unichar ls = [substring characterAtIndex:1];
                          if (ls == 0x20e3)
                          {
                              isEomji = YES;
                          }
                      }
                      else
                      {
                          if (0x2100 <= hs && hs <= 0x27ff && hs != 0x263b)
                          {
                              isEomji = YES;
                          }
                          else if (0x2B05 <= hs && hs <= 0x2b07)
                          {
                              isEomji = YES;
                          }
                          else if (0x2934 <= hs && hs <= 0x2935)
                          {
                              isEomji = YES;
                          }
                          else if (0x3297 <= hs && hs <= 0x3299)
                          {
                              isEomji = YES;
                          }
                          else if (hs == 0xa9 || hs == 0xae || hs == 0x303d || hs == 0x3030 || hs == 0x2b55 ||
                                   hs == 0x2b1c || hs == 0x2b1b || hs == 0x2b50 || hs == 0x231a)
                          {
                              isEomji = YES;
                          }
                      }
                    }];
    return isEomji;
}

#pragma mark - 取消searchbar背景色/图片

+ (UIImage *)imageWithColor:(UIColor *)color size:(CGSize)size
{
    CGRect rect = CGRectMake (0, 0, size.width, size.height);
    UIGraphicsBeginImageContext (rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext ();

    CGContextSetFillColorWithColor (context, [color CGColor]);
    CGContextFillRect (context, rect);

    UIImage *image = UIGraphicsGetImageFromCurrentImageContext ();
    UIGraphicsEndImageContext ();

    return image;
}

@end
