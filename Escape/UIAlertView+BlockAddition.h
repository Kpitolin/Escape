//
//  UIAlertView+BlockAddition.h
//  TOEIC
//
//  Created by Antoine Palazzolo on 15/10/13.
//  Copyright (c) 2013 Kreactive. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void (^KTAlertViewCompletionHandler)(UIAlertView *alertView, NSInteger buttonIndex);


@interface UIAlertView (BlockAddition)

+ (void)presentAlertViewWithTitle:(NSString *)title message:(NSString *)message  cancelButtonTitle:(NSString *)cancelButtonTitle otherButtonTitles:(NSArray *)titles completionHandler:(KTAlertViewCompletionHandler)completionHandler;
@end
