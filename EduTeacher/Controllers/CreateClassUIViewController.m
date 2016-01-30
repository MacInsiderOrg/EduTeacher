//
//  CreateClassUIViewController.m
//  EduTeacher
//
//  Created by Bohdan Savych on 1/30/16.
//  Copyright © 2016 Andrew Kochulab. All rights reserved.
//

#import "CreateClassUIViewController.h"
@interface CreateClassUIViewController()<UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UITextField *codeTextField;

@end
@implementation CreateClassUIViewController
static NSCharacterSet* nonDigits;
-(void)viewDidLoad
{
    [super viewDidLoad];
    self.codeTextField.delegate=self;
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
    nonDigits=[[NSCharacterSet decimalDigitCharacterSet] invertedSet];
    if([string rangeOfCharacterFromSet:nonDigits].location==NSNotFound)//return true if we didnt find smth that isnt a number
    {
        if([self.codeTextField.text length]<5)//in future need to change to appropriate length 
        {
            self.codeTextField.text=[self.codeTextField.text stringByAppendingString:string];
        }
    }

    return  NO;
}
#pragma mark-actions
- (IBAction)connectAction:(UIButton *)sender
{
    [self.codeTextField resignFirstResponder];//hide keyboard
    if(![self isEmpty])
    {
            // to other view controller
    }
}
#pragma mark - Segue

- (void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
}
#pragma mark-private method
-(BOOL)isEmpty
{
    if (self.codeTextField.text.length == 0) {
        
        UIAlertController * alert = [UIAlertController alertControllerWithTitle: @"Password"
                                                                        message: @"Please enter a password."
                                                                 preferredStyle: UIAlertControllerStyleAlert];
        
        UIAlertAction* okButton = [UIAlertAction actionWithTitle: @"Ok"
                                                           style: UIAlertActionStyleDefault
                                                         handler: ^(UIAlertAction * action) {
                                                             
                                                             [alert dismissViewControllerAnimated:YES completion:nil];
                                                         }];
        
        [alert addAction:okButton];
        
        [self presentViewController:alert animated:YES completion:nil];
        return YES;
    }
    return NO;
}
@end
