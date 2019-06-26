//
//  BPZMQController.h
//  BPZMQLib
//
//  Created by Andy.li on 19/05/2017.
//  Copyright © 2017 Andy.li. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BPZMQPort.h"
#import "ZMQHelper.h"

@interface BPZMQController : NSObject
{
    NSMutableArray *portArray;
}

+(id)sharedController;

-(BPZMQPort *)initialZMQPort:(PortInfo *)portInfo;

-(BPZMQPort *)getZMQPort:(PortInfo *)portInfo;

-(BOOL)isValid:(PortInfo *)portInfo;

-(BOOL) Send_string:(NSString *)str
              PortID:(PortInfo *)portInfo;

-(BOOL) Send_command:(NSString *)str
          WaitString:(NSString *)waitStr
             Timeout:(float)waitTime
              PortID:(PortInfo *)portInfo;

-(BOOL) Wait_forString:(NSString *) waitStr
               Timeout:(float)waitTime
                PortID:(PortInfo *)portInfo;

-(BOOL)deleteZMQPort:(PortInfo *)portInfo;

-(BPZMQPort *)initialZMQPortFirst:(PortInfo *)portInfo;

@end
