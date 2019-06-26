//
//  AppDelegate.m
//  ZMQ_Demo
//
//  Created by Dylan Xiao on 2018/11/19.
//  Copyright © 2018年 Dylan Xiao. All rights reserved.
//

#import "AppDelegate.h"

@interface AppDelegate ()

@property (weak) IBOutlet NSWindow *window;
@end

@implementation AppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    // Insert code here to initialize your application
    //[self readFile];
}

- (void)applicationWillTerminate:(NSNotification *)aNotification {
    // Insert code here to tear down your application
}



#define CHECK_LENGTH 20       //检查是否为utf8编码时所检查的字符长度

int is_utf8_string(char *utf)
{
    int length = strlen(utf);
    int check_sub = 0;
    int i = 0;
    
    if ( length > CHECK_LENGTH )  //只取前面特定长度的字符来验证即可
    {
        length = CHECK_LENGTH;
    }
    
    for ( ; i < length; i ++ )
    {
        if ( check_sub == 0 )
        {
            if ( (utf[i] >> 7) == 0 )         //0xxx xxxx
            {
                continue;
            }
            else if ( (utf[i] & 0xE0) == 0xC0 ) //110x xxxx
            {
                check_sub = 1;
            }
            else if ( (utf[i] & 0xF0) == 0xE0 ) //1110 xxxx
            {
                check_sub = 2;
            }
            else if ( (utf[i] & 0xF8) == 0xF0 ) //1111 0xxx
            {
                check_sub = 3;
            }
            else if ( (utf[i] & 0xFC) == 0xF8 ) //1111 10xx
            {
                check_sub = 4;
            }
            else if ( (utf[i] & 0xFE) == 0xFC ) //1111 110x
            {
                check_sub = 5;
            }
            else
            {
                return 0;
            }
        }
        else
        {
            if ( (utf[i] & 0xC0) != 0x80 )
            {
                return 0;
            }
            check_sub --;
        }
    }
    return 1;
}

BOOL IsTextUTF8(char* str,uint64_t length)
{
    u_long nBytes=0;//UFT8可用1-6个字节编码,ASCII用一个字节
    u_char chr;
    BOOL bAllAscii=TRUE; //如果全部都是ASCII, 说明不是UTF-8
    for(int i=0; i<length; ++i)
    {
        chr= *(str+i);
        if( (chr&0x80) != 0 ) // 判断是否ASCII编码,如果不是,说明有可能是UTF-8,ASCII用7位编码,但用一个字节存,最高位标记为0,o0xxxxxxx
            bAllAscii= FALSE;
        if(nBytes==0) //如果不是ASCII码,应该是多字节符,计算字节数
        {
            if(chr>=0x80)
            {
                if(chr>=0xFC&&chr<=0xFD)
                    nBytes=6;
                else if(chr>=0xF8)
                    nBytes=5;
                else if(chr>=0xF0)
                    nBytes=4;
                else if(chr>=0xE0)
                    nBytes=3;
                else if(chr>=0xC0)
                    nBytes=2;
                else
                    return FALSE;
                
                nBytes--;
            }
        }
        else //多字节符的非首字节,应为 10xxxxxx
        {
            if( (chr&0xC0) != 0x80 )
                return FALSE;
            
            nBytes--;
        }
    }
    if( nBytes > 0 ) //违返规则
        return FALSE;
    if( bAllAscii ) //如果全部都是ASCII, 说明不是UTF-8
        return FALSE;
    
    return TRUE;
}

-(void)readFile
{
    NSString *path = @"/Users/dylanxiao/Desktop/demo.txt";
    NSString *path2 =@"/Users/dylanxiao/Desktop/demo23.txt";
    NSData *data = [NSData dataWithContentsOfFile:path];
    
    //32 3031382f 31312f32 37203031 3a32363a 32373a30 38323030 20202020 5b4d4355 5f554152 545f5258 203a5d20 c3901bc3 8b68c385 0bc288c2 abc3b116 c38e543f c2

    //NSData *data1 = [NSData dataWithBytes:<#(nullable const void *)#> length:<#(NSUInteger)#>]
    
    Byte DataArr[] ={0xc3,0x90,0x1b,0xc3,0x8b,0x68,0xc3,0x85,0x0b,0xc2,0x88,0xc2,0xab,0xc3,0xb1,0x16,0xc3,0x8e,0x54,0x3f,0xc2};
    
    NSData *dataTest = [NSData dataWithBytes:DataArr length:sizeof(DataArr)];
    NSLog(@"dataTest = %@",dataTest);
    
    
    
    
    [data writeToFile:path2 atomically:NO];
    NSString *string = [NSString stringWithContentsOfFile:path];
    //NSLog(@"data=%@;\n\n\n***\nstring=%@",data,string);
}


#pragma mark - ZMQServer/Client:PUB/SUB
//ZMQ-Server
-(int)zmqServer_PUB
{
    //  Prepare our context and publisher
    ZMQContext *ctx = [[ZMQContext alloc] initWithIOThreads:1U] ;
    ZMQSocket *publisher = [ctx socketWithType:ZMQ_PUB];
    [publisher bindToEndpoint:@"tcp://127.0.0.1:5556"];
    [publisher bindToEndpoint:@"ipc://weather.ipc"];
    
    //  Initialize random number generator
    srandom ((unsigned) time (NULL));
    for (;;) {
        @autoreleasepool {
            //  Get values that will fool the boss
            int zipcode, temperature, relhumidity;
            zipcode     = within (100000);
            temperature = within (215) - 80;
            relhumidity = within (50) + 10;
            
            // Send message to all subscribers
            NSString *update = [NSString stringWithFormat:@"%05d %d %d",
                                zipcode, temperature, relhumidity];
            NSData *data = [update dataUsingEncoding:NSUTF8StringEncoding];
            [publisher sendData:data withFlags:0];
        }
        
        usleep(10000);
    }
    [publisher close];
    return EXIT_SUCCESS;
}

//client
int zmqClient_SUB(int argc ,const char *argv[])
{
    ZMQContext *ctx = [[ZMQContext alloc] initWithIOThreads:1U];
    
    // Socket to talk to server
    ZMQSocket *subscriber = [ctx socketWithType:ZMQ_SUB];
    if (![subscriber connectToEndpoint:@"tcp://127.0.0.1:5556"]) {
        /* ZMQSocket will already have logged the error. */
        return EXIT_FAILURE;
    }
    
    /* Subscribe to zipcode (defaults to NYC, 10001). */
    const char *kNYCZipCode = "10001";
    const char *filter = (argc > 1)? argv[1] : kNYCZipCode;
    NSData *filterData = [NSData dataWithBytes:filter length:strlen(filter)];
    [subscriber setData:filterData forOption:ZMQ_SUBSCRIBE];
    
    /* Write to stdout immediately rather than at each newline.
     * This makes the incremental temperatures appear incrementally.
     */
    (void)setvbuf(stdout, NULL, _IONBF, BUFSIZ);
    
    /* Process updates. */
    NSLog(@"Collecting temperatures for zipcode %s from weather server...", filter);
    const int kMaxUpdate = 100;
    long total_temp = 0;
    for (int update_nbr = 0; update_nbr < kMaxUpdate; ++update_nbr) {

        NSData *msg = [subscriber receiveDataWithFlags:0];
        const char *string = [msg bytes];
        
        int zipcode = 0, temperature = 0, relhumidity = 0;
        (void)sscanf(string, "%d %d %d", &zipcode, &temperature, &relhumidity);
        
        printf("%d ", temperature);
        total_temp += temperature;

    }
    /* End line of temperatures. */
    putchar('\n');
    
    NSLog(@"Average temperature for zipcode '%s' was %ld degF.",
          filter, total_temp / kMaxUpdate);
    
    /* [ZMQContext sockets] makes it easy to close all associated sockets. */
    [[ctx sockets] makeObjectsPerformSelector:@selector(close)];
    return EXIT_SUCCESS;
}



-(int)zmqServer_Pub1
{
    printf("Hello World.\n");
    void* context = zmq_ctx_new(); // create a new environment
    assert(context !=NULL);
    
    int ret =zmq_ctx_set(context, ZMQ_MAX_SOCKETS, 1); // 在该环境下只允许一个Socket存在
    assert(ret==0);
    
    void* publisher = zmq_socket(context, ZMQ_PUB); //create a new publisher
    assert(publisher !=NULL);
    
    ret = zmq_bind(publisher, "tcp://*:8888");  //bind the publisher to TCP
    assert(ret==0);
    
    while (1) {
        char string[] = "Hi,I'm server.";
        int length = sizeof(string);
        int flag =0;
        ret = zmq_send(publisher, "Hi,I'm server.", 16, 0);
    }
    
    
}

#pragma mark - ZMQServer/Client:REP/REQ

-(int)ZmqServer_REP
{
    __block int result = EXIT_SUCCESS;
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        ZMQContext *ctx = [[ZMQContext alloc] initWithIOThreads:1U] ;
        
        /* Get a socket to talk to clients. */
        static NSString *const kEndpoint = @"tcp://127.0.0.1:5555";
        ZMQSocket *responder = [ctx socketWithType:ZMQ_REP];
        // 如果出现Operation not permitted， 请检查AppSandBox是否设置成否
        BOOL didBind = [responder bindToEndpoint:kEndpoint];
        if (!didBind) {
            NSLog(@"*** Failed to bind to endpoint [%@].", kEndpoint);
            result = EXIT_FAILURE;
            //return EXIT_FAILURE;
            return ;
        }
        
        for (;;) {
            @autoreleasepool {
                /* Block waiting for next request from client. */
                NSData *request = [responder receiveDataWithFlags:0];
                NSString *text = [[NSString alloc] initWithData:request encoding:NSUTF8StringEncoding] ;
                NSLog(@"Received request: %@. original data:[%@]", text,request);
                
                /* "Work" for a bit. */
                sleep(1);
                
                /* Send reply back to client. */
                static NSString *const kWorld = @"This is Server.";
                const char *replyCString = [kWorld UTF8String];
                const NSUInteger replyLength = [kWorld
                                                lengthOfBytesUsingEncoding:NSUTF8StringEncoding];
                NSData *reply = [NSData dataWithBytes:replyCString length:replyLength];
                [responder sendData:reply withFlags:0];
            }
        }
        
        /* Close the socket to avoid blocking in -[ZMQContext terminate]. */
        [responder close];
        result = EXIT_SUCCESS;
        return;
        //return EXIT_SUCCESS;
    });
    
    return result;
    
}

-(int)ZmqClient_REQ
{
    ZMQContext *ctx = [[ZMQContext alloc] initWithIOThreads:1U];
    
    /* Get a socket to talk to clients. */
    NSLog(@"Connecting to hello world server...");
    static NSString *const kEndpoint = @"tcp://localhost:5555";
    ZMQSocket *requester = [ctx socketWithType:ZMQ_REQ];
    BOOL didBind = [requester connectToEndpoint:kEndpoint];
    if (!didBind) {
        NSLog(@"*** Failed to bind to endpoint [%@].", kEndpoint);
        return EXIT_FAILURE;
    }
    
    static const int kMaxRequest = 50000000;
    Byte DataArr[] ={0xc3,0x90,0x1b,0xc3,0x8b,0x68,0xc3,0x85,0x0b,0xc2,0x88,0xc2,0xab,0xc3,0xb1,0x16,0xc3,0x8e,0x54,0x3f,0xc2};
    
    Byte DataArr1[37] ={0x01,0x98};
    NSData *dataTest = [NSData dataWithBytes:DataArr1 length:sizeof(DataArr1)];
    NSLog(@"dataTest = %@",dataTest);
    
    //NSData *const request = [@"Hello" dataUsingEncoding:NSUTF8StringEncoding];
    NSData *const request = [NSData dataWithData:dataTest];
    for (int request_nbr = 0; request_nbr < kMaxRequest; ++request_nbr) {
        NSLog(@"Sending request %d.", request_nbr);
        [requester sendData:request withFlags:0];
        NSData *reply = [requester receiveDataWithFlags:0];
        NSString *text = [[NSString alloc] initWithData:reply encoding:NSUTF8StringEncoding];
        NSLog(@"Received reply %d: %@", request_nbr, text);
    }
    
    [requester close];
    return EXIT_SUCCESS;
}

+(NSString *)runCommand:(NSString *)commandToRun;
{
    NSTask *task;
    task = [[NSTask alloc] init];
    [task setLaunchPath: @"/bin/sh"];
    
    NSArray *arguments = [NSArray arrayWithObjects:
                          @"-c" ,
                          [NSString stringWithFormat:@"%@", commandToRun],
                          nil];
    NSLog(@"run command: %@",commandToRun);
    [task setArguments: arguments];
    
    NSPipe *pipe;
    pipe = [NSPipe pipe];
    [task setStandardOutput: pipe];
    
    NSFileHandle *file;
    file = [pipe fileHandleForReading];
    
    [task launch];
    
    NSData *data;
    data = [file readDataToEndOfFile];
    
    NSString *output;
    output = [[NSString alloc] initWithData: data encoding: NSUTF8StringEncoding];
    return output;
    
}

+(BOOL)runSequence:(NSString *)chStr;
{
    NSLog(@"runSequence:%@",chStr);
    
//    NSString *path = [[Common GetAppPreference] objectForKey:@"PySequenceRoot"];
//    NSString *homeDir = NSHomeDirectory();
//    path = [path stringByReplacingOccurrencesOfString:@"$HomeDir" withString:homeDir];
//    if (!path) {
//        //path = @"/Users/gdlocal/Desktop/IntelligentAutomation/python-sequencer";
//        path=[[Common GetAppPreference] objectForKey:@"PySequenceRoot"];
//        NSString *homeDir=NSHomeDirectory();
//        path=[path stringByReplacingOccurrencesOfString:@"$HomeDir" withString:homeDir];
//    }
    NSString *path = @"/pySequenceRoot";
    setenv("PYTHONPATH", [path cStringUsingEncoding:NSUTF8StringEncoding], 1);
    NSString *sequencePy = [NSString stringWithFormat:@"%@/x527/sequencer/sequencer.py",path];
    NSString *args = [NSString stringWithFormat:@"-s %@ -c -f 1", chStr];
    NSString *command = [NSString stringWithFormat:@"/usr/bin/python %@ %@", sequencePy, args];
    //[HostController runCommand:command];
    [self runCommand:command];
    return YES;
}


#pragma mark - 用BPZMQlib create server & client
-(void)newZMQServer
{
    PortInfo *port = [PortInfo new];
    port.channelID = 1;
    port.name = @"Engine";
    port.port = 5555;
    port.protocol = ZMQ_REP;
    
    BPZMQPort *bpPort = [[BPZMQPort alloc] createZMQPort:port];
}

-(void)newZMQClient:(int)chid port:(int)port
{
//    int chid= 1;
//    int port = 7600;
    
    PortInfo *info = [[PortInfo alloc] init];
    [info setChannelID:chid];
    [info setName:@"Engine"];
    [info setPort:port];
    [info setProtocol:ZMQ_REP];
    
    zmqPortCtl= [BPZMQController sharedController];
    BPZMQPort *zmqPort = [zmqPortCtl initialZMQPort:info];
    if (zmqPort == nil) {
        NSLog(@"initZMQPort Error!");
        return ;
    }
    __block BOOL result = NO;
    
    do {
        [zmqPort ReadZMQPort:10 usingBlock:^(NSData *data, size_t len, BOOL *stop) {
            if (data && [data length] > 0) {
                NSString *text = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
                NSLog(@"Recv(%d):%@", chid,text);
                
                NSDictionary *dict = [ZMQHelper translateStringToDict:text];
                NSLog(@"dict-result(%d):%@",chid, dict);
                NSString *uid = [dict objectForKey:@"id"];
                
                NSString *replyStr = [NSString stringWithFormat: @"{\"id\":\"%@\",\"jsonrpc\":\"2.0\",\"result\":\"--PASS--\"}", uid];
                
                result = [zmqPort Send_string:replyStr];
                *stop = YES;
            }
        }];
        break;
    } while(1);
    NSLog(@"Out of runEngine with %@", (result?@"PASS":@"ERROR"));
    
}

#pragma mark - ZMQ PUB/SUB



#pragma mark - Button
- (IBAction)Btn_ZmqServer:(NSButton *)sender {
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        [self zmqServer_PUB];
    });
    //[self zmqServer_PUB];
}

- (IBAction)Btn_ZmqClient:(NSButton *)sender {
    const char *agv[] = {"TEST","10101"};
    
    zmqClient_SUB(0, agv);
}

- (IBAction)Btn_REP_Server:(NSButton *)sender {
    [self ZmqServer_REP];
}

- (IBAction)Btn_REQ_Client:(NSButton *)sender {
    char *string = "A¬©¬Å¬±√≤¬á√±√∏√Ö¬2";
    

//        Byte DataArr[] ={0xc3,0x90,0x1b,0xc3,0x8b,0x68,0xc3,0x85,0x0b,0xc2,0x88,0xc2,0xab,0xc3,0xb1,0x16,0xc3,0x8e,0x54,0x3f,0xc2};
//        //char* string  = "aabbCC";
//        BOOL isPassed = IsTextUTF8(DataArr, sizeof(DataArr));
//        BOOL isutf8 = is_utf8_string(string);
//
//        NSLog(@"ispassed =%d,%d",isPassed,isutf8);
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
       [self ZmqClient_REQ];
    });
}









@end
