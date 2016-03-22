//
//  SVTextField.m
//  SpeedPro
//
//  Created by Rain on 3/21/16.
//  Copyright © 2016 chinasofti. All rights reserved.
//

#import "SVTextField.h"

@implementation SVTextField
{
    int _characterLength;
}


- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        [self setDelegate:self];
    }

    return self;
}

/**
 *  控制UITextField字符个数
 *
 *  @param length 字符个数
 */
- (void)setCharacterLength:(int)length
{
    _characterLength = length;
}


- (BOOL)textField:(UITextField *)textField
shouldChangeCharactersInRange:(NSRange)range
            replacementString:(NSString *)string
{
    NSMutableString *newtxt = [NSMutableString stringWithString:textField.text];
    [newtxt replaceCharactersInRange:range withString:string];
    return ([newtxt length] <= _characterLength);
}

@end
