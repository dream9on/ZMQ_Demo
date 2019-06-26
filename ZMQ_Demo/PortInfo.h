//
//  PortInfo.h
//  HWSerser
//
//  Created by Andy.li on 19/05/2017.
//  Copyright © 2017 Andy.li. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ZMQSocket.h"

@interface PortInfo : NSObject
{
    
}

@property (assign) int channelID;
@property (retain)   NSString *name;
@property (assign) int port;
@property (assign) ZMQSocketType protocol;

@end
