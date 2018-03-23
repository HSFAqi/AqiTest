//
//  TCPClient.h
//  AqiTestDemo
//
//  Created by 黄山锋 on 2018/3/23.
//  Copyright © 2018年 黄山锋. All rights reserved.
//

#import <Foundation/Foundation.h>
@interface TCPClient : NSObject

@property (nonatomic, assign) int clientSocket;
@property (nonatomic, assign) int result;

+ (TCPClient *)shareTCPClient;
//建立连接
- (BOOL)connection:(NSString *)hostText port:(int)port;
//发送字符串数据
- (void)sendStringToServerAndReceived:(NSString *)message;
//断开连接
- (void)disConnection;

@end
