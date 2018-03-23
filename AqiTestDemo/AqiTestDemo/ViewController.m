//
//  ViewController.m
//  AqiTestDemo
//
//  Created by 黄山锋 on 2018/3/23.
//  Copyright © 2018年 黄山锋. All rights reserved.
//

#import "ViewController.h"

#import "TCPClient.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
}


//发送
- (IBAction)send:(UIButton *)sender {
    BOOL success = [[TCPClient shareTCPClient] connection:@"192.168.3.26" port:2097];
    if (success) {
//        NSString *string = @"fe 00 00 01 ff ff 14 31 3c 00 00 00 00 00 00 00 00 00 00 1D";
//        [[TCPClient shareTCPClient] sendStringToServerAndReceived:string];
//        
    }else{
        NSLog(@"connet error !");
    }
    
}








- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
