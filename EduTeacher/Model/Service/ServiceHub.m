//
//  ServiceHub.m
//  EduTeacher
//
//  Created by Andrew Kochulab on 11.02.16.
//  Copyright © 2016 Andrew Kochulab. All rights reserved.
//

#import "ServiceHub.h"
#import "Router.h"

@interface ServiceHub () <SRConnectionDelegate>

@end

@implementation ServiceHub

#pragma mark - Shared Instance

+ (ServiceHub *) sharedInstance {
    static ServiceHub *hubObj = nil;
    static dispatch_once_t predicate;
    
    dispatch_once(&predicate, ^{
        hubObj = [[self alloc] init];
    });
    
    return hubObj;
}

#pragma mark - Initialization

- (instancetype) init {
    self = [super init];
    
    if (self) {
        // Initialize router
        _router = [[Router alloc] init];
    }
    
    return self;
}

#pragma mark - Instance methods

- (void) dealloc {
    [self.hubConnection stop];
    self.hubProxy = nil;
    self.hubConnection.delegate = nil;
    self.hubConnection = nil;
}

- (void) connectToServerWithCode:(NSString *)code {
    
    NSString *serverIP = [self.router getServerIPAddressByCode:code];
    
    if ([Router isValidIPAddress:serverIP]) {
        [self.router setupServerWithIPAddress:serverIP];
        
        // Connect to the service
        self.hubConnection = [SRHubConnection connectionWithURL:self.router.serverURL];
        self.hubConnection.delegate = self;
        
        // Create a proxy to the smart school service
        self.hubProxy = [self.hubConnection createHubProxy:@"smartSchoolHub"];
        
        // Setup events (testing)
        [self.hubProxy on:@"Exception" perform:self selector:@selector(onException:)];
        
        // Start connection
        [self.hubConnection start];
        
    } else {
        NSLog(@"Server IP is not valid!");
    }
}

- (void) onException:(NSString *)message {
    NSLog(@"Get exception with message: %@", message);
}

#pragma mark - SRConnection delegate methods

- (void) SRConnectionDidOpen:(id<SRConnectionInterface>)connection {
    NSLog(@"SRConnectionDidOpen");
    NSLog(@"Connection started state: %d", self.hubConnection.state);
}

- (void) SRConnection:(id<SRConnectionInterface>)connection didReceiveData:(NSString *)data {
    NSLog(@"SRConnection:didReceiveData");
    NSLog(@"Received some data: %@", data);
}

- (void) SRConnection:(id<SRConnectionInterface>)connection didReceiveError:(NSError *)error {
    NSLog(@"SRConnection:didReceiveError");
    NSLog(@"Received some error: %@", error);
}

- (void) SRConnection:(id<SRConnectionInterface>)connection didChangeState:(connectionState)oldState newState:(connectionState)newState {
    NSLog(@"SRConnection:didChangeState from state: %d to state: %d", oldState, newState);
    if (newState == connected){
        [self.hubProxy invoke:@"TeacherConnectMe" withArgs:[NSArray arrayWithObject:@"Roman"] completionHandler:^(id response) {
            NSLog(@"Response: %@", response);
        }];
        self.isConnected = YES;
    } else {
        self.isConnected = NO;
    }
}

- (void) SRConnectionDidClose:(id<SRConnectionInterface>)connection {
    NSLog(@"SRConnectionDidClose");
    NSLog(@"Connection closed state: %d", self.hubConnection.state);
}

@end
