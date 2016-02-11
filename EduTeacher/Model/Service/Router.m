//
//  Router.m
//  EduTeacher
//
//  Created by Andrew Kochulab on 11.02.16.
//  Copyright © 2016 Andrew Kochulab. All rights reserved.
//

#import "Router.h"
#import <ifaddrs.h>
#import <arpa/inet.h>

@implementation Router

#pragma mark - Initialization

- (instancetype) init {
    self = [super init];
    
    if (self) {
        // Setup client IP address
        _clientIP = [self getClientIPAddress];
    }
    
    return self;
}

#pragma mark - Instance methods

- (void) setupServerWithIPAddress:(NSString *)ipAddress {
    // Setup server IP address
    self.serverIP = ipAddress;
    
    // Setup server address
    self.serverURL = [self getServerURL];
}

- (NSString *) getServerIPAddressByCode:(NSString *)code {
    NSString *baseIPAddress = nil;
    
    NSRange range = [self.clientIP rangeOfString:@"." options:NSBackwardsSearch];
    baseIPAddress = [self.clientIP substringToIndex:range.location];
    
    return [[baseIPAddress stringByAppendingString:@"."] stringByAppendingString:code];
}

- (NSString *) getClientIPAddress {
    NSString *ipAddress = nil;
    
    struct ifaddrs *interfaces = NULL;
    struct ifaddrs *tempAddresses = NULL;
    
    int success = 0;
    // Retrieve the current interfaces
    // Returns 0 on success
    success = getifaddrs(&interfaces);
    
    if (success == 0) {
        // Loop through linked list of interfaces
        tempAddresses = interfaces;
        
        while (tempAddresses != NULL) {
            if (tempAddresses->ifa_addr->sa_family == AF_INET) {
                // Check if interface is en0 which is the wifi connection on the iPhone
                if ([[NSString stringWithUTF8String:tempAddresses->ifa_name] isEqualToString:@"en0"]) {
                    // Get NSString from C String
                    ipAddress = [NSString stringWithUTF8String:inet_ntoa(((struct sockaddr_in *)tempAddresses->ifa_addr)->sin_addr)];
                }
            }
            
            tempAddresses = tempAddresses->ifa_next;
        }
    }
    
    // Free memory
    freeifaddrs(interfaces);
    
    return ipAddress;
}

- (NSString *) getServerURL {
    return [[@"http://" stringByAppendingString:self.serverIP] stringByAppendingString:@":8080/SignalR/"];
}

#pragma mark - Rotuer methods

+ (BOOL) isValidIPAddress:(NSString *)ipAddress {
    const char *utf8 = [ipAddress UTF8String];
    
    // Check valid IPv4
    struct in_addr ipV4;
    int success = inet_pton(AF_INET, utf8, &(ipV4.s_addr));
    
    if (success != 1) {
        // Check valid IPv6
        struct in6_addr ipV6;
        success = inet_pton(AF_INET6, utf8, &ipV6);
    }
    
    return (success == 1);
}

@end
