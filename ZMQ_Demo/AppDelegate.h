//
//  AppDelegate.h
//  ZMQ_Demo
//
//  Created by Dylan Xiao on 2018/11/19.
//  Copyright © 2018年 Dylan Xiao. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "BPZMQController.h"


@interface AppDelegate : NSObject <NSApplicationDelegate>
{
    BPZMQController *zmqPortCtl;
}

- (IBAction)Btn_ZmqServer:(NSButton *)sender;
- (IBAction)Btn_ZmqClient:(NSButton *)sender;


- (IBAction)Btn_REP_Server:(NSButton *)sender;

- (IBAction)Btn_REQ_Client:(NSButton *)sender;

@end

