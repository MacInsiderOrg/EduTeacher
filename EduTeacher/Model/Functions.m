//
//  Functions.m
//  EduTeacher
//
//  Created by Andrew Kochulab on 20.01.16.
//  Copyright © 2016 Andrew Kochulab & Bohdan Savych. All rights reserved.
//

#import "Functions.h"

@implementation Functions

CGPDFDocumentRef CGPDFDocumentCreateUsingUrl(CFURLRef theURL, NSString* password) {
    // CGPDFDocument
    CGPDFDocumentRef thePDFDocRef = NULL;
    
    // Check for non-NULL CFURLRef
    if (theURL != NULL) {
        thePDFDocRef = CGPDFDocumentCreateWithURL(theURL);
        
        // Check for non-NULL CGPDFDocumentRef
        if (thePDFDocRef != NULL) {
            
            // Encrypted
            if (CGPDFDocumentIsEncrypted(thePDFDocRef) == TRUE) {

                // Try a blank password first, per Apple's Quartz PDF example
                if (CGPDFDocumentUnlockWithPassword(thePDFDocRef, "") == FALSE) {

                    // Nope, now let's try the provided password to unlock the PDF
                    if ((password != nil) && (password.length > 0)) {
                        
                        // char array buffer for the string conversion
                        char text[128];
                        
                        [password getCString:text maxLength:126 encoding:NSUTF8StringEncoding];
                        
                        // Log failure
                        if (CGPDFDocumentUnlockWithPassword(thePDFDocRef, text) == FALSE) {
                            NSLog(@"CGPDFDocumentCreateUsingUrl: Unable to unlock [%@] with [%@]", theURL, password);
                        }
                    }
                }
                
                // Cleanup unlock failure
                if (CGPDFDocumentIsUnlocked(thePDFDocRef) == FALSE) {
                    CGPDFDocumentRelease(thePDFDocRef), thePDFDocRef = NULL;
                }
            }
        }
    }

    // Log an error diagnostic
    else {
        NSLog(@"CGPDFDocumentCreateUsingUrl: theURL == NULL");
    }
    
    return thePDFDocRef;
}

@end