//
//  SVNetworkTrafficMonitor.m
//  SpeedPro
//
//  Created by Rain on 3/10/16.
//  Copyright © 2016 chinasofti. All rights reserved.
//

#import "SVNetworkTrafficMonitor.h"
#include <arpa/inet.h>
#include <ifaddrs.h>
#include <net/if.h>
#include <net/if_dl.h>

@implementation SVNetworkTrafficMonitor


+ (NSNumber *)getDataCounters
{
    BOOL success;
    struct ifaddrs *addrs;
    const struct ifaddrs *cursor;
    const struct if_data *networkStatisc;

    int WiFiSent = 0;
    int WiFiReceived = 0;
    int WWANSent = 0;
    int WWANReceived = 0;

    NSString *name = [[NSString alloc] init];

    success = getifaddrs (&addrs) == 0;
    if (success)
    {
        cursor = addrs;
        while (cursor != NULL)
        {
            name = [NSString stringWithFormat:@"%s", cursor->ifa_name];
            //            NSLog (@"ifa_name %s == %@\n", cursor->ifa_name, name);
            // names of interfaces: en0 is WiFi ,pdp_ip0 is WWAN
            if (cursor->ifa_addr->sa_family == AF_LINK)
            {
                if ([name hasPrefix:@"en"])
                {
                    networkStatisc = (const struct if_data *)cursor->ifa_data;
                    WiFiSent += networkStatisc->ifi_obytes;
                    WiFiReceived += networkStatisc->ifi_ibytes;
                    //                    NSLog (@"WiFiSent %d ==%d", WiFiSent,
                    //                    networkStatisc->ifi_obytes);
                    //                    NSLog (@"WiFiReceived %d ==%d", WiFiReceived,
                    //                    networkStatisc->ifi_ibytes);
                }
                if ([name hasPrefix:@"pdp_ip"])
                {
                    networkStatisc = (const struct if_data *)cursor->ifa_data;
                    WWANSent += networkStatisc->ifi_obytes;
                    WWANReceived += networkStatisc->ifi_ibytes;
                    //                    NSLog (@"WWANSent %d ==%d", WWANSent,
                    //                    networkStatisc->ifi_obytes);
                    //                    NSLog (@"WWANReceived %d ==%d", WWANReceived,
                    //                    networkStatisc->ifi_ibytes);
                }
            }
            cursor = cursor->ifa_next;
        }
        freeifaddrs (addrs);
    }
    return [NSNumber numberWithInt:(WiFiReceived + WWANReceived)];
}

@end
