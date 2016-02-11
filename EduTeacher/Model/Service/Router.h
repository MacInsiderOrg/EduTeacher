//
//  Router.h
//  EduTeacher
//
//  Created by Andrew Kochulab on 11.02.16.
//  Copyright © 2016 Andrew Kochulab. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Router : NSObject

@property (strong, nonatomic) NSString *serverURL;
@property (strong, nonatomic) NSString *serverIP;
@property (strong, nonatomic) NSString *clientIP;

- (void) setupServerWithIPAddress:(NSString *)ipAddress;
- (NSString *) getServerIPAddressByCode:(NSString *)code;

+ (BOOL) isValidIPAddress:(NSString *)ipAddress;

@end
