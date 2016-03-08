//
//  main.m
//  SPUIView
//
//  Created by WBapple on 16/1/19.
//  Copyright © 2016年 chinasofti. All rights reserved.
//

#import "AppDelegate.h"
#import <SPCommon/SVLog.h>
#import <UIKit/UIKit.h>

int main (int argc, char *argv[])
{
    @autoreleasepool
    {
        int value = -1;
        @try
        {
            SVInfo (@"SpeedPro start...");
            value = UIApplicationMain (argc, argv, nil, NSStringFromClass ([AppDelegate class]));
        }
        @catch (NSException *exception)
        {
            SVError (@"SpeedPro start fail. Exception:%@", exception);
        }

        return value;
    }
}
