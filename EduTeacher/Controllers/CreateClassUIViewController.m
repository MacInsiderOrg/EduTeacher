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
    NSLog(@"textFieldShouldReturn");
    [textField resignFirstResponder];
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
#pragma mark - Segue

- (void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
}
@end
