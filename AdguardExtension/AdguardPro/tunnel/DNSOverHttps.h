//
//  DNSOverHttps.h
//  ProActionExtension
//
//  Created by douxinchun on 2018/11/24.
//  Copyright © 2018年 Performiks. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface DNSOverHttps : NSObject

+ (DNSOverHttps *)instance;

- (NSString *)requestWithName:(NSString *)name;

@end

NS_ASSUME_NONNULL_END
