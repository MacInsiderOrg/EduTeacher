//
//  CreateClassUIViewController.m
//  EduTeacher
//
//  Created by Bohdan Savych on 1/30/16.
//  Copyright © 2016 Andrew Kochulab. All rights reserved.
//

#import "CreateClassUIViewController.h"
#import "SubjectCollectionViewController.h"
#import "ServiceHub.h"

@interface CreateClassUIViewController()<UITextFieldDelegate, ServiceHubDelegate>

@property (weak, nonatomic) IBOutlet UITextField *codeTextField;
@property (strong, nonatomic) ServiceHub *serviceHub;

@end
@implementation CreateClassUIViewController
static NSCharacterSet* nonDigits;
-(void)viewDidLoad
{
    [super viewDidLoad];
    self.codeTextField.delegate = self;
    self.serviceHub = [ServiceHub sharedInstance];
    self.serviceHub.delegate = self;
    
}
#pragma mark-UITextFieldDelegate
- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    if([self isEmpty])
    {
        return NO;
    }
    else
    {
        //to other view controler
    }
    return YES;
}
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string   // return NO to not change text
//call when we write some charackter in text field
{
    NSCharacterSet *includeSet = [NSCharacterSet decimalDigitCharacterSet];
    if (![string isEqualToString:@""]&&([[string stringByTrimmingCharactersInSet:includeSet] length] > 0||self.codeTextField.text.length>2))
    {
        return NO;
    }
    return YES;
}
#pragma mark-actions
- (IBAction)connectAction:(UIButton *)sender
{
    [self.codeTextField resignFirstResponder];//hide keyboard
    
    if(![self isEmpty])
    {
        int password = [self.codeTextField.text intValue];
        if (password >= 0 && password <= 255) {
            // Connect to the service
            [self.serviceHub connectToServerWithCode: self.codeTextField.text];

            /*if (!hub.isConnected) {
                [self presentAlertWithTitle:@"Error" message:@"Server is not available."];
            }*/
            
        } else {
            [self presentAlertWithTitle:@"Error" message:@"Code value should be between 0 and 255."];
        }
    }
}

- (void) connectedToServer {
    SubjectCollectionViewController *viewController = [self.storyboard instantiateViewControllerWithIdentifier:@"SubjectCollectionViewController"];
    [self.navigationController pushViewController:viewController animated:YES];
}

- (void) presentAlertWithTitle:(NSString *)title message:(NSString *)message {
    UIAlertController * alert = [UIAlertController alertControllerWithTitle:title
                                                                    message:message
                                                             preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction* okButton = [UIAlertAction actionWithTitle:@"Ok"
                                                       style:UIAlertActionStyleDefault
                                                     handler:^(UIAlertAction * action) {
                                                         [alert dismissViewControllerAnimated:YES completion:nil];
                                                     }];
    
    [alert addAction:okButton];
    [self presentViewController:alert animated:YES completion:nil];
}

#pragma mark-private method
-(BOOL)isEmpty
{
    if (self.codeTextField.text.length == 0) {
        [self presentAlertWithTitle:@"Error" message:@"Please enter the code"];
        return YES;
    }
    return NO;
}

@end
