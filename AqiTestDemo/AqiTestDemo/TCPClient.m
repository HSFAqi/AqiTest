//
//  TCPClient.m
//  AqiTestDemo
//
//  Created by 黄山锋 on 2018/3/23.
//  Copyright © 2018年 黄山锋. All rights reserved.
//

#import "TCPClient.h"
#import <sys/socket.h>
#import <netinet/in.h>
#import <arpa/inet.h>

#define TCPHOSTADDNUM   **ip地址**

@implementation TCPClient

static TCPClient * tcpClient = nil;

+ (TCPClient *)shareTCPClient {
    
    @synchronized(self) {
        if (!tcpClient) {
            tcpClient = [[TCPClient alloc]init];
        }
    }
    return tcpClient;
}



#pragma mark 工具
//2.1、通过域名建立连接，hostText：域名地址 port：端口号
- (BOOL)connection:(NSString *)hostText port:(int)port {
    
    /**
     socket   参数
     domain:  协议域，AF_INET（IPV4的网络开发）
     type:    Socket 类型，SOCK_STREAM(TCP)/SOCK_DGRAM(UDP，报文)
     protocol:IPPROTO_TCP，协议，如果输入0，可以根据第二个参数，自动选择协议
     return:  if > 0 就表示成功
     */
    
    self.clientSocket = - 1;
    self.clientSocket = socket(AF_INET, SOCK_STREAM, 0);
    
    if (self.clientSocket > 0) {
        NSLog(@"socket 连接成功： %d", self.clientSocket);
    } else {
        NSLog(@"socket 连接失败");
        return NO;
    }
    
    //通过域名获取Ip地址
    NSString * tcpIp = [self obtainTCPIpAddressWithHost:hostText];
    
    //Connect
    struct sockaddr_in serverAddress;
    serverAddress.sin_family = AF_INET;
    serverAddress.sin_addr.s_addr = inet_addr(tcpIp.UTF8String);
    serverAddress.sin_port = htons(port);
    self.result = connect(self.clientSocket, (const struct sockaddr *)&serverAddress, sizeof(serverAddress));
    
    if (self.clientSocket > 0 && self.result >= 0) {
        NSLog(@"connect 连接成功");
        return YES;
    }else {
        NSLog(@"connect 连接失败");
        [[TCPClient shareTCPClient] disConnection];
        return NO;
    }
}


//2.2、 通过域名获取 IP 地址
//- (NSString *)obtainTCPIpAddressWithHost:(NSString *)hostAdd {
//
//    NSString * tcpIpStr;
//    struct hostent * host_entry = gethostbyname([hostAdd UTF8String]);
//    char IPStr[64] = {0};
//    if(host_entry != 0) {
//
//        sprintf(IPStr, "%d.%d.%d.%d",
//                (host_entry->h_addr_list[0][0]&0x00ff),
//                (host_entry->h_addr_list[0][1]&0x00ff),
//                (host_entry->h_addr_list[0][2]&0x00ff),
//                (host_entry->h_addr_list[0][3]&0x00ff));
//
//        char * ip = inet_ntoa(*((struct in_addr *)host_entry->h_addr));
//        tcpIpStr = [NSString stringWithFormat:@"%s", ip];
//        NSLog(@"通过域名得到：%@", tcpIpStr);
//    }else {
//        tcpIpStr = TCPHOSTADDNUM;
//        NSLog(@"通过IP得到：%@", tcpIpStr);
//    }
//    return tcpIpStr;
//}


//2.2、 通过域名获取 IP 地址
- (NSString *)obtainTCPIpAddressWithHost:(NSString *)hostName
{
//    const char *hostN= [hostName UTF8String];
//    struct hostent* phot;
//
//    @try {
//        phot = gethostbyname(hostN);
//        if (phot == nil) {
//            return nil;
//        }
//    }
//    @catch (NSException *exception) {
//        return nil;
//    }
//
//    struct in_addr ip_addr;
//    memcpy(&ip_addr, phot->h_addr_list[0], 4);
//    char ip[20] = {0};
//    inet_ntop(AF_INET, &ip_addr, ip, sizeof(ip));
//
//    NSString* strIPAddress = [NSString stringWithUTF8String:ip];
//    return strIPAddress;
    
    return @"192.168.3.26";
    
}


//2.3、发送 NSString 数据
//发送和接收字符串
- (void)sendStringToServerAndReceived:(NSString *)message {
    
    if (self.clientSocket > 0 && self.result >= 0) {
        
        //不加下面的代码，如果在发送数据的途中服务器断开连接，会闪退。
        sigset_t set;
        sigemptyset(&set);
        sigaddset(&set, SIGPIPE);
        sigprocmask(SIG_BLOCK, &set, NULL);
        ssize_t sendLen = send(self.clientSocket, message.UTF8String, strlen(message.UTF8String), 0);
        NSLog(@"发送的TCP数据长度 == %ld", sendLen);
        if (sendLen > 0) {
            [self performSelectorInBackground:@selector(readStream) withObject:nil];
        }
    }else {
        //发送的时候如果连接失败，重新连接。
    }
}

//2.4、接收数据
//接收数据
- (void)readStream {
    
    /**
     第一个int:创建的socket
     void *:  接收内容的地址
     size_t:  接收内容的长度
     第二个int:接收数据的标记 0，就是阻塞式，一直等待服务器的数据
     return:  接收到的数据长度
     */
    char readBuffer[1024] = {0};
    long OrgBr = 0;
    OrgBr = recv(self.clientSocket, readBuffer, sizeof(readBuffer), 0) < sizeof(readBuffer);
    NSLog(@"\nbr = %ld\nReceived Data：%s\n", OrgBr, readBuffer);
    memset(readBuffer, 0, sizeof(readBuffer));
    NSString * readString = [NSString stringWithUTF8String:readBuffer];
    if (readString && ![readString isKindOfClass:[NSNull class]] && readString.length > 0) {
        //接收到的数据 NSString 可以自己做相关的操作
    }else {
        //重新连接
    }
}
//2.5、 断开 Socket 连接
//断开连接
- (void)disConnection {
    
    if (self.clientSocket > 0) {
        close(self.clientSocket);
        self.clientSocket = -1;
    }
}



@end
