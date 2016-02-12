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
    NSLog(@"Service Hub Deallocated.");
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
        [self setupEvents];
        
        // Start connection
        [self.hubConnection start];
        
        // Setup timer for checking connection
        [NSTimer scheduledTimerWithTimeInterval:2.f
                                         target:self
                                       selector:@selector(checkConnection:)
                                       userInfo:nil
                                        repeats:NO];
    }
}

- (void) checkConnection:(NSTimer *)timer {
    if (!self.isConnected) {
        if ([self.delegate respondsToSelector:@selector(serverNotFound)]) {
            [self.delegate serverNotFound];
        }
    }
}

#pragma mark - Events

- (void) setupEvents {
    [self.hubProxy on:@"Exception" perform:self selector:@selector(onException:)];
}

- (void) onException:(NSString *)message {
    NSLog(@"Get exception with message: %@", message);
}

- (void) setupTeacherMethods {
    [self.hubProxy on:@"DoCommands" perform:self selector:@selector(onDoCommands:)];
    [self.hubProxy on:@"ReciveFilesList" perform:self selector:@selector(onReceiveFilesList:)];
    [self.hubProxy on:@"LoadPage" perform:self selector:@selector(onLoadPage:name:pageNumber:)];
    [self.hubProxy on:@"FilePageCount" perform:self selector:@selector(onFilePageName:withCount:)];
    [self.hubProxy on:@"ReciveStudentList" perform:self selector:@selector(onReceiveStudentList:)];
    [self.hubProxy on:@"ReciveTestsAnswers" perform:self selector:@selector(onReceiveTestAnswers:)];
}

- (void) onDoCommands:(NSString *)command {
    NSLog(@"onDoCommands: %@", command);
}

- (void) onReceiveFilesList:(NSArray *)files {
    NSLog(@"onReceiveFilesList: %@", files);
}

- (void) onLoadPage:(NSString *)data name:(NSString *)name pageNumber:(NSString *)pageNumber {
    NSLog(@"onLoadPage: %@, name = %@, pageNumber = %@", data, name, pageNumber);
}

- (void) onFilePageName:(NSString *)filename withCount:(NSString *)pageNumber {
    NSLog(@"onFilePageName: %@, pageNumber = %@", filename, pageNumber);
}

- (void) onReceiveStudentList:(NSArray *)students {
    NSLog(@"onReceiveStudentList: %@", students);
}

- (void) onReceiveTestAnswers:(NSArray *)answers {
    NSLog(@"onReceiveTestAnswers: %@", answers);
}


#pragma mark - SRConnection delegate methods

- (void) SRConnectionDidOpen:(id<SRConnectionInterface>)connection {
    NSLog(@"SRConnectionDidOpen");
    NSLog(@"Connection started state: %d", self.hubConnection.state);
    if (self.hubConnection.state == connected) {
        if ([self.delegate respondsToSelector:@selector(connectedToServer)]) {
            [self.delegate connectedToServer];
        }
    }
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
        
        [self setupTeacherMethods];
        self.isConnected = YES;
    }
    else {
        self.isConnected = NO;
    }
}

- (void) SRConnectionDidClose:(id<SRConnectionInterface>)connection {
    NSLog(@"SRConnectionDidClose");
    NSLog(@"Connection closed state: %d", self.hubConnection.state);
}

@end
