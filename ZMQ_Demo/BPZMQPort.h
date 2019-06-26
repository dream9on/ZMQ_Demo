//
//  BPZMQPort.h
//  HWSerser
//
//  Created by Andy.li on 19/05/2017.
//  Copyright © 2017 Andy.li. All rights reserved.
//

#import "PortInfo.h"
#import "ZMQObjC.h"
#import "queue.h"

@interface BPZMQPort : NSObject
{
    NSThread *zmqThread;
    Queue    strQueue;
}

@property (readonly) PortInfo *ZMQPortInfo;
@property (retain) ZMQContext *context;
@property (retain) ZMQSocket *responder;
@property (assign) BOOL threadRuning;
@property (assign) BOOL respond_status;



-(id) createZMQPort:(PortInfo *)pInfo;
-(BOOL)isValid;
-(NSString *)Receive_string;
-(BOOL)Send_string:(NSString *)str;
-(BOOL)Send_string:(NSString *)str WaitString:(NSString *)waitStr Timeout:(float)waitTime;
-(BOOL)Wait_forString:(NSString *) waitStr Timeout:(float)waitTime;
-(BOOL)ReadZMQPort:(double)tt usingBlock:(void (^)(NSData *data,size_t len,BOOL *stop))callback;
-(void)freeQueue;
-(void)close;

@end
