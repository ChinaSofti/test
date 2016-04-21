//
//  SVAppVersionChecker.m
//  SpeedPro
//
//  Created by Rain on 4/20/16.
//  Copyright © 2016 Huawei. All rights reserved.
//

#import "SVAppVersionChecker.h"

@implementation SVAppVersionChecker


+(BOOL) hasNewVersion
{
//    NSString *recStr = [[NSString alloc] initWithData:request.responseData encoding:NSUTF8StringEncoding];
//    recStr = [recStr stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    //返回的字符串有前面有很多换行符，需要去除一下
//    NSDictionary *resultDic = [JSONHelper DeserializerDictionary:recStr];
    //jsonhelper是我封装的json解析类，你可以使用自己方式解析
    NSDictionary *resultDic = nil;
    NSArray *infoArray = [resultDic objectForKey:@"results"];
    if (infoArray.count > 0) {
        
        NSDictionary* releaseInfo =[infoArray objectAtIndex:0];
        NSString* appStoreVersion = [releaseInfo objectForKey:@"version"];
        NSDictionary *infoDic = [[NSBundle mainBundle] infoDictionary];
        NSString *currentVersion = [infoDic objectForKey:@"CFBundleShortVersionString"];
        
        NSArray *curVerArr = [currentVersion componentsSeparatedByString:@"."];
        NSArray *appstoreVerArr = [appStoreVersion componentsSeparatedByString:@"."];
        BOOL needUpdate = NO;
        //比较版本号大小
        int maxv = (int)MAX(curVerArr.count, appstoreVerArr.count);
        int cver = 0;
        int aver = 0;
        for (int i = 0; i < maxv; i++) {
            if (appstoreVerArr.count > i) {
                aver = [NSString stringWithFormat:@"%@",appstoreVerArr[i]].intValue;
            }
            else{
                aver = 0;
            }
            if (curVerArr.count > i) {
                cver = [NSString stringWithFormat:@"%@",curVerArr[i]].intValue;
            }
            else{
                cver = 0;
            }
            if (aver > cver) {
                
                
                needUpdate = YES;
                break;
            }
        }
        
        //如果有可用的更新
        if (needUpdate){
            
           NSString *trackViewURL = [[NSString alloc] initWithString:[releaseInfo objectForKey:@"trackViewUrl"]];
            //trackViewURL临时变量存储app下载地址，可以让app跳转到appstore
            UIAlertView* alertview =[[UIAlertView alloc] initWithTitle:@"版本升级" message:[NSString stringWithFormat:@"发现有新版本，是否升级？"] delegate:self cancelButtonTitle:@"暂不升级" otherButtonTitles:@"马上升级", nil];
            [alertview show];
            
        }
        
    }
    return NO;
}



@end
