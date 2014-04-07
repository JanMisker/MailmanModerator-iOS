//
//  MailmanMessage.h
//  Mailman
//
//  Created by Jan Misker on 03-01-10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface MailmanMessage : NSObject {
	NSString *idNumber;
	NSString *sender;
	NSString *subject;
	NSString *dateString;
	NSDate *date;
	NSString *reason;
}

@property (retain) NSString *idNumber;
@property (retain) NSString *sender;
@property (retain) NSString *subject;
@property (retain) NSString *dateString;
@property (retain) NSDate *date;
@property (retain) NSString *reason;

@end
