/* 
    Copyright (C) 2015 Stephen Oliver <steve@infincia.com>
    
    This code is distributed under the GNU General Public License, version 2.
    
    3rd party libraries may be distributed under an alternate Open Source license.
    
    See the LICENSE file included with this code for details.
    
*/

#import "FNFCPWrapper.h"

#import <dispatch/dispatch.h>

static const long FCPCommandClientHelloTag = 0;
static const long FCPCommandGetNodeTag = 1;

static NSString *FCPResponseTerminationString = @"EndMessage\n";

#pragma mark - Node state

typedef NS_ENUM(NSInteger, FCPConnectionState) {
    FCPConnectionStateDisconnected    =  0,
    FCPConnectionStateConnected       =  1,
    FCPConnectionStateReady           =  2
};

@interface FNFCPWrapper ()
@property GCDAsyncSocket *nodeSocket;
@property dispatch_queue_t nodeQueue;
@property enum FCPConnectionState connectionState;

-(void)sendFCPMessage:(NSString *)message withTag:(long)tag;
-(NSDictionary *)parseFCPResponse:(NSData *)data;

@end

@implementation FNFCPWrapper

- (instancetype)init {
    self = [super init];
    if (self) {
        self.connectionState = FCPConnectionStateDisconnected;
        self.nodeQueue = dispatch_queue_create("com.freenet.tray.fcpqueue", DISPATCH_QUEUE_SERIAL);
        self.nodeSocket = [[GCDAsyncSocket alloc] initWithDelegate:self delegateQueue:self.nodeQueue];
    }
    return self;
}

-(void)nodeStateLoop {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        while (1) {
            switch (self.connectionState) {
                case FCPConnectionStateDisconnected: {
                    NSURL *nodeFCPURL = [self.dataSource nodeFCPURL];
                    NSError *fcpConnectionError;
                    [self.nodeSocket connectToHost:nodeFCPURL.host onPort:nodeFCPURL.port.integerValue withTimeout:5 error:&fcpConnectionError];
                    if (fcpConnectionError) {
                        NSLog(@"FCP connection error: %@", fcpConnectionError.localizedDescription);
                    }
                    break;
                }
                case FCPConnectionStateConnected: {
                    NSString *lf = [[NSString alloc] initWithData:[GCDAsyncSocket LFData] encoding:NSUTF8StringEncoding];
                    NSMutableString *clientHello = [NSMutableString new];
                    [clientHello appendString:@"ClientHello"];
                    [clientHello appendString:lf];
                    [clientHello appendString:@"Name=FreenetTray"];
                    [clientHello appendString:lf];
                    [clientHello appendString:@"ExpectedVersion=2.0"];
                    [clientHello appendString:lf];
                    [clientHello appendString:@"EndMessage"];
                    [clientHello appendString:lf];  
                    [self sendFCPMessage:clientHello withTag:FCPCommandClientHelloTag];
                    break;
                }
                case FCPConnectionStateReady: {
                    NSString *lf = [[NSString alloc] initWithData:[GCDAsyncSocket LFData] encoding:NSUTF8StringEncoding];
                    NSMutableString *getNode = [NSMutableString new];
                    [getNode appendString:@"GetNode"];
                    [getNode appendString:lf];
                    [getNode appendString:@"WithVolatile=true"];
                    [getNode appendString:lf];
                    [getNode appendString:@"EndMessage"];
                    [getNode appendString:lf];  
                    [self sendFCPMessage:getNode withTag:FCPCommandGetNodeTag];  
                    break;
                }
                default: {
                    break;
                }
            }
            [NSThread sleepForTimeInterval:1];
        }
        
    });
}

#pragma mark - Message and response handling

-(void)sendFCPMessage:(NSString *)message withTag:(long)tag {   
    [self.nodeSocket writeData:[message dataUsingEncoding:NSUTF8StringEncoding] withTimeout:5 tag:tag];
    [self.nodeSocket readDataToData:[FCPResponseTerminationString dataUsingEncoding:NSUTF8StringEncoding] withTimeout:5 tag:tag];
}

-(NSDictionary *)parseFCPResponse:(NSData *)data {
    NSString *rawResponse = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    
    NSMutableDictionary *nodeResponse = [NSMutableDictionary dictionary];
    
    for (NSString *keyValuePair in [rawResponse componentsSeparatedByString:@"\n"]) {
        NSArray *pair = [keyValuePair componentsSeparatedByString:@"="];
        if ([pair count] != 2) {
            continue;
        }
        nodeResponse[pair[0]] = pair[1];
    }
    return nodeResponse;
}

#pragma mark - GCDAsyncSocketDelegate methods

-(void)socket:(GCDAsyncSocket *)sock didConnectToHost:(NSString *)host port:(uint16_t)port {
    self.connectionState = FCPConnectionStateConnected;
}

-(void)socketDidDisconnect:(GCDAsyncSocket *)sock withError:(NSError *)err {
    self.connectionState = FCPConnectionStateDisconnected;
}

-(void)socket:(GCDAsyncSocket *)sock didReadData:(NSData *)data withTag:(long)tag {
    switch (tag) {
        case FCPCommandClientHelloTag: {
            NSDictionary *nodeHello = [self parseFCPResponse:data];
            self.connectionState = FCPConnectionStateReady;
            if (self.delegate != nil) {
                [self.delegate didReceiveNodeHello:nodeHello];
            }
            break;
        }
        case FCPCommandGetNodeTag: {
            NSDictionary *nodeStats = [self parseFCPResponse:data];
            if (self.delegate != nil) {
                [self.delegate didReceiveNodeStats:nodeStats];
            }
            break;
        }
        default: {
            break;
        }
    }
}

-(void)socket:(GCDAsyncSocket *)sock didReadPartialDataOfLength:(NSUInteger)partialLength tag:(long)tag {
    //NSLog(@"Socket read data of length: %ld", partialLength);
}

-(void)socket:(GCDAsyncSocket *)sock didWriteDataWithTag:(long)tag  {
    //NSLog(@"Socket wrote data for tag %ld", tag);
}



@end
