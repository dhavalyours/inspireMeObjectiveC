//
//  ToastView.h
//  inspireMe
//
//  Created by Dhaval on 01/10/15.
//  Copyright © 2015 Dhaval. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ToastView : UIView

@property (strong, nonatomic) NSString *text;

+ (void)showToastInParentView: (UIView *)parentView withText:(NSString *)text withDuaration:(float)duration;

@end

