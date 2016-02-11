//
//  ServiceHub.h
//  EduTeacher
//
//  Created by Andrew Kochulab on 11.02.16.
//  Copyright © 2016 Andrew Kochulab. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Router.h"
#import "SignalR.h"

@protocol ServiceHubDelegate <NSObject>

- (void) connectedToServer;

@end

@interface ServiceHub : NSObject

@property (weak, nonatomic) id <ServiceHubDelegate> delegate;

@property (strong, nonatomic) Router *router;
@property (strong, nonatomic) SRHubConnection *hubConnection;
@property (strong, nonatomic) SRHubProxy *hubProxy;
@property (assign, nonatomic) BOOL isConnected;

+ (ServiceHub *) sharedInstance;

- (void) connectToServerWithCode:(NSString *)code;

@end
