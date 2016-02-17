//
//  SVSortTools.m
//  SPUIView
//
//  Created by XYB on 16/1/31.
//  Copyright © 2016年 chinasofti. All rights reserved.
//

#import "SVSortTools.h"

#import <SPService/SVSummaryResultModel.h>

@implementation SVSortTools
/**
 *  根据类型排序
 *
 */
+ (void)sortByType:(NSMutableArray *)array {
  NSMutableArray *reslut = [[NSMutableArray alloc] init];
  for (int i = 0; i < [array count]; i++) {
    if ([((SVSummaryResultModel *)[array objectAtIndex:i])
                .type isEqualToString:@"WIFI"]) {
      [reslut addObject:[array objectAtIndex:i]];
      [array removeObjectAtIndex:i];
      i--;
    }
  }

  [reslut addObjectsFromArray:array];
  [array removeAllObjects];
  [array addObjectsFromArray:reslut];
}
/**
 *  根据时间排序
 *
 */
+ (void)sortByTime:(NSMutableArray *)array {
  for (int i = 0; i < array.count; i++) {
    int a = i;
    for (int j = i; j < array.count; j++) {
      if (((SVSummaryResultModel *)[array objectAtIndex:j]).testTime >
          ((SVSummaryResultModel *)[array objectAtIndex:a]).testTime) {
        a = j;
      }
    }
    [array exchangeObjectAtIndex:i withObjectAtIndex:a];
  }
}
/**
 *  根据得分排序
 *
 */
+ (void)sortByScore:(NSMutableArray *)array {
  for (int i = 0; i < array.count; i++) {
    int a = i;
    for (int j = i; j < array.count; j++) {
      if (((SVSummaryResultModel *)[array objectAtIndex:j]).UvMOS >
          ((SVSummaryResultModel *)[array objectAtIndex:a]).UvMOS) {
        a = j;
      }
    }
    [array exchangeObjectAtIndex:i withObjectAtIndex:a];
  }
}
/**
 *  根据加载时间排序
 *
 */
+ (void)sortByLoadTime:(NSMutableArray *)array {
  for (int i = 0; i < array.count; i++) {
    int a = i;
    for (int j = i; j < array.count; j++) {
      if (((SVSummaryResultModel *)[array objectAtIndex:j]).loadTime >
          ((SVSummaryResultModel *)[array objectAtIndex:a]).loadTime) {
        a = j;
      }
    }
    [array exchangeObjectAtIndex:i withObjectAtIndex:a];
  }
}
/**
 *  根据带宽排序
 *
 */
+ (void)sortByBandWitdh:(NSMutableArray *)array {
  for (int i = 0; i < array.count; i++) {
    int a = i;
    for (int j = i; j < array.count; j++) {
      if (((SVSummaryResultModel *)[array objectAtIndex:j]).bandwidth >
          ((SVSummaryResultModel *)[array objectAtIndex:a]).bandwidth) {
        a = j;
      }
    }
    [array exchangeObjectAtIndex:i withObjectAtIndex:a];
  }
}
/**
 *  逆序
 *
 */
+ (void)reverse:(NSMutableArray *)array {

  for (int i = 0; i < [array count] / 2; i++) {
    [array exchangeObjectAtIndex:i withObjectAtIndex:[array count] - 1 - i];
  }
}

int sort(int array[]) {
  for (int i = 0; i < 11; i++) {
    int a = i;
    for (int j = i; j < 11; j++) {
      if (array[j] < array[a]) {
        a = j;
      }
    }
    int temp = array[i];
    array[i] = array[a];
    array[a] = temp;
  }
  return 0;
}

@end
