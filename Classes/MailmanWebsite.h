//
//  MailmanWebsiteController.h
//  Mailman
//
//  Created by Jan Misker on 03-01-10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "MaillistSettings.h"
#import "MailmanMessage.h"

typedef enum {
	MailmanWebsiteActionDefer = 0,
	MailmanWebsiteActionApprove = 1,
	MailmanWebsiteActionReject = 2,
	MailmanWebsiteActionDiscard = 3
} MailmanWebsiteAction;

static NSString *const MailmanWebsiteStateTest = @"MailmanWebsiteStateTest";
static NSString *const MailmanWebsiteStateLoadModerateItems = @"MailmanWebsiteStateLoadModerateItems";
static NSString *const MailmanWebsiteStateSubmit = @"MailmanWebsiteStateSubmit";

@class MailmanWebsite;
@protocol MailmanWebsiteDelegate

- (void)mailmanWebsite:(MailmanWebsite *)mailmanWebsite moderateItems:(NSArray *)items;
- (void)mailmanWebsite:(MailmanWebsite *)mailmanWebsite connectionFailed:(NSString *)msg;

@optional
- (void)mailmanWebsiteTestSucceeded:(MailmanWebsite *)mailmanWebsite;

@end


@interface MailmanWebsite : NSObject {
	MaillistSettings *maillist;
	id<MailmanWebsiteDelegate> delegate;
	NSString *state;
	NSURLConnection *connection;
	NSMutableData *receivedData;
	NSString *errorMsg;
}

@property (nonatomic, retain) MaillistSettings *maillist;
@property (nonatomic, assign) id<MailmanWebsiteDelegate> delegate;

- (id)initWithDelegate:(id<MailmanWebsiteDelegate>)delegate maillist:(MaillistSettings *)maillist;

+ (MailmanWebsite *)testConnection:(id<MailmanWebsiteDelegate>)delegate maillist:(MaillistSettings *)maillist;
+ (MailmanWebsite *)loadModerateItems:(id<MailmanWebsiteDelegate>)delegate maillist:(MaillistSettings *)maillist;
+ (MailmanWebsite *)submit:(id<MailmanWebsiteDelegate>)delegate action:(MailmanWebsiteAction)action items:(NSArray *)items maillist:(MaillistSettings *)maillist;

- (void)testConnection;
- (void)loadModerateItems;
- (void)submit:(MailmanWebsiteAction)action items:(NSArray *)items;
- (void)requestUrl:(NSString *)url post:(NSDictionary *)postData;

@end
