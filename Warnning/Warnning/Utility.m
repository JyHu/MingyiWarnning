//
//  Utility.m
//  Warnning
//
//  Created by 胡金友 on 15/7/29.
//  Copyright (c) 2015年 胡金友. All rights reserved.
//

#import "Utility.h"
#import <UIKit/UIKit.h>
#import <AudioToolbox/AudioToolbox.h>

@implementation Utility

+ (void)notify:(NSString *)msg
{
    if ([self isWorkingTime])
    {
        UILocalNotification *notify = [[UILocalNotification alloc] init];
        
        notify.alertBody = msg;
        
        notify.soundName = UILocalNotificationDefaultSoundName;
        
        notify.alertTitle = @"提醒";
        
        [[UIApplication sharedApplication] presentLocalNotificationNow:notify];
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
        });
    }
}

+ (BOOL)isWorkingTime
{
    
#warning - 改一下这里可以设置是上班前后推送还是一直推送
    
#if 0
    
    NSDate *curDate = [NSDate date];
    
    NSCalendar *calendar = [NSCalendar currentCalendar];
    
    NSDateComponents *comp = [calendar components:NSCalendarUnitHour fromDate:curDate];
    
    NSInteger hour = [comp hour];
    
    if (hour < 10 || hour > 18)
    {
        return YES;
    }
    
    return NO;
#else
    
    return YES;
    
#endif
    
}

@end
