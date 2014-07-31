//
//  UIAlertView+BlockAddition.m
//  TOEIC
//
//  Created by Antoine Palazzolo on 15/10/13.
//  Copyright (c) 2013 Kreactive. All rights reserved.
//

#import "UIAlertView+BlockAddition.h"

@interface KTAlertViewBlockDispatcher : NSObject <UIAlertViewDelegate> {
    NSMapTable *_alertViewToCompletionHandlers;
}
+ (instancetype)defaultBlockDispatcher;
- (void)addAlertView:(UIAlertView *)alertView withCompletionHandler:(KTAlertViewCompletionHandler)completionHandler;
@end

@implementation UIAlertView (BlockAddition)
+ (void)presentAlertViewWithTitle:(NSString *)title message:(NSString *)message  cancelButtonTitle:(NSString *)cancelButtonTitle otherButtonTitles:(NSArray *)titles completionHandler:(KTAlertViewCompletionHandler)completionHandler
{
    UIAlertView *alertView = [[UIAlertView alloc] init];
    alertView.title = title;
    alertView.message = message;
    if (cancelButtonTitle) {
        NSUInteger cancelButtonIndex = [alertView addButtonWithTitle:cancelButtonTitle];
        alertView.cancelButtonIndex = cancelButtonIndex;
    }
    for (NSString *buttonTitle in titles) {
        [alertView addButtonWithTitle:buttonTitle];
    }
    [[KTAlertViewBlockDispatcher defaultBlockDispatcher] addAlertView:alertView withCompletionHandler:completionHandler];
    [alertView show];
}
@end

@implementation KTAlertViewBlockDispatcher


+ (instancetype)defaultBlockDispatcher
{
    static KTAlertViewBlockDispatcher *defaultBlockDispatcher = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        defaultBlockDispatcher = [[KTAlertViewBlockDispatcher alloc] init];
    });
    return defaultBlockDispatcher;
}
- (id)init
{
    self = [super init];
    if (self) {
        _alertViewToCompletionHandlers = [[NSMapTable alloc] initWithKeyOptions:NSPointerFunctionsStrongMemory valueOptions:NSPointerFunctionsStrongMemory capacity:0];
    }
    return self;
}
- (void)addAlertView:(UIAlertView *)alertView withCompletionHandler:(KTAlertViewCompletionHandler)completionHandler
{
    alertView.delegate = self;
    [_alertViewToCompletionHandlers setObject:completionHandler forKey:alertView];
}
- (void)alertView:(UIAlertView *)alertView willDismissWithButtonIndex:(NSInteger)buttonIndex
{
    KTAlertViewCompletionHandler completionHandler = [_alertViewToCompletionHandlers objectForKey:alertView];
    if (completionHandler) {
        completionHandler(alertView,buttonIndex);
    }
    [_alertViewToCompletionHandlers removeObjectForKey:alertView];
}

@end