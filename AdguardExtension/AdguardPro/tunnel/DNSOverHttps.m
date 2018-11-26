//
//  DNSOverHttps.m
//  ProActionExtension
//
//  Created by douxinchun on 2018/11/24.
//  Copyright © 2018年 Performiks. All rights reserved.
//

#import "DNSOverHttps.h"

@interface DNSOverHttps () {
    dispatch_semaphore_t _syncSemaphore;
    dispatch_queue_t _queue;
}
@end

@implementation DNSOverHttps

+ (DNSOverHttps *)instance {
    static id instance;

    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[[self class] alloc] init];
    });
    return instance;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        _syncSemaphore = dispatch_semaphore_create(0);
        _queue = dispatch_queue_create("DNSOverHttpsRequest", DISPATCH_QUEUE_SERIAL);
    }
    return self;
}

- (NSString *)requestWithName:(NSString *)name {
    if (!name) {
        return nil;
    }
    NSString *urlStr = [NSString stringWithFormat:@"https://dns.rubyfish.cn/dns-query?name=%@&type=A", name];
    NSURL *url = [NSURL URLWithString:urlStr];
    __block NSString *ip;
    dispatch_async(_queue, ^{
        NSURLSessionDataTask *task = [[NSURLSession sharedSession] dataTaskWithURL:url completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
            NSDictionary *jsonResult = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
            NSLog(@"-------%@", jsonResult);
            for (NSDictionary *item in jsonResult[@"Answer"]) {
                int type = (int)[item[@"type"] integerValue];
                NSString *n = item[@"name"];
                if ([n hasSuffix:@"."]) {
                    n = [n substringToIndex:n.length - 1];
                }
                if ( type == 1 ) {
                    ip = item[@"data"];
                    break;
                }
            }
            dispatch_semaphore_signal(_syncSemaphore);
        }];
        [task resume];
    });
    dispatch_semaphore_wait(_syncSemaphore, DISPATCH_TIME_FOREVER);
    return ip;
}

@end
