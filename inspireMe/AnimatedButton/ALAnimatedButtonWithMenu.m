//
//  ALAnimatedButtonWithMenu.m
//  AnimatedButtonExample
//
//  Created by Andrey Sapunov on 06/09/15.
//  Copyright (c) 2015 Andrey Sapunov. All rights reserved.
//

#import "ALAnimatedButtonWithMenu.h"

@implementation ALAnimatedButtonWithMenu {
    BOOL isOpened;
    
    NSMutableArray * buttonArray;
    UIView * animatedButtonParentView;
}

#pragma mark - Constructors

- (id) initWithImage:(UIImage *) buttonImage inView:(UIView *) parentView {
    return [self initWithImage:buttonImage andPosition:ALAnimatedButtonPositionBottomRight inView:parentView];
}

- (id) initWithImage:(UIImage *) buttonImage andPosition:(ALAnimatedButtonPosition) position inView:(UIView *) parentView {
    self = [super init];
    
    if (self) {
        [self initialize];
        _animatedButtonPosition = position;
        
        [self setImage:buttonImage forState:UIControlStateNormal];
        animatedButtonParentView = parentView;
        [self updateRect];
        
        [self addTarget:self action:@selector(mainButtonTap:) forControlEvents:UIControlEventTouchUpInside];
        
        [parentView addSubview:self];
    }
    
    return self;
}


#pragma mark - Initialization

- (void) initialize {
    _animatedButtonHorizontalMargin = 20;
    _animatedButtonVerticalMargin = 20;
    
    _animatedButtonAlphaNormal = 1.0f;
    _animatedButtonAlphaOpened = 0.5f;
    
    _animatedButtonRadius = 140.f;
    
    _animatedButtonHideMenuOnButtonClick = YES;
    
    buttonArray = [[NSMutableArray alloc] init];
}

- (void) updateRect {
    UIImage * buttonImage = self.imageView.image;
    
    // Calculate button position;
    
    CGFloat width = buttonImage.size.width;
    CGFloat height = buttonImage.size.height;
    CGFloat x = 0;
    CGFloat y = 0;
    
    if (_animatedButtonPosition == ALAnimatedButtonPositionTopLeft) {
        x = _animatedButtonHorizontalMargin;
        y = _animatedButtonVerticalMargin;
    } else if (_animatedButtonPosition == ALAnimatedButtonPositionTopRight) {
        x = animatedButtonParentView.frame.size.width - width - _animatedButtonHorizontalMargin;
        y = _animatedButtonVerticalMargin;
    } else if (_animatedButtonPosition == ALAnimatedButtonPositionBottomLeft) {
        x = _animatedButtonHorizontalMargin;
        y = animatedButtonParentView.frame.size.height - height - _animatedButtonVerticalMargin;
    } else {
        x = animatedButtonParentView.frame.size.width - width - _animatedButtonHorizontalMargin;
        y = animatedButtonParentView.frame.size.height - height - _animatedButtonVerticalMargin;
    }
    
    CGRect frame = CGRectMake(x, y, width, height);
    
    [self setFrame:frame];
}

- (void) drawRect:(CGRect)rect {
    [super drawRect:rect];
    
    
}

#pragma mark - Buttons

- (void) addMenuButton:(UIImage *) buttonImage withTag:(NSInteger) buttonTag {
    UIButton * button = [UIButton buttonWithType:UIButtonTypeCustom];
    [button setImage:buttonImage forState:UIControlStateNormal];
    [button setTag:buttonTag];
    [button addTarget:self action:@selector(menuButtonTap:) forControlEvents:UIControlEventTouchUpInside];
    [buttonArray addObject:button];
}

- (void) updateFrameForButton:(UIButton *) button withId:(NSInteger) buttonId inTotalButtons:(NSUInteger) totalButtons  {
    // calculate relative X and Y
    
//    CGFloat relX = _animatedButtonRadius * sin(M_PI / (float) 2 + M_PI / (float)(2 * totalButtons) * (buttonId - 1) );
//    CGFloat relY = _animatedButtonRadius * cos(M_PI / (float) 2 + M_PI / (float)(2 * totalButtons) * (buttonId - 1) );
    CGFloat relX = _animatedButtonRadius * sin( M_PI_2 + M_PI / (float)(2 * totalButtons) * (buttonId - 1) );
    CGFloat relY = _animatedButtonRadius * cos( M_PI_2 + M_PI / (float)(2 * totalButtons) * (buttonId - 1) );
    
    if (_animatedButtonPosition == ALAnimatedButtonPositionBottomLeft || _animatedButtonPosition == ALAnimatedButtonPositionTopLeft) {
        relX = -relX;
    }
    
    if (_animatedButtonPosition == ALAnimatedButtonPositionTopLeft || _animatedButtonPosition == ALAnimatedButtonPositionTopRight) {
        relY = -relY;
    }
    
    UIImage * buttonImage = button.imageView.image;
    CGFloat width = buttonImage.size.width;
    CGFloat height = buttonImage.size.height;
    CGFloat x = self.center.x - relX;
    CGFloat y = self.center.y + relY;
    
    CGRect frame = CGRectMake(x - (width / 2.f), y - (height / 2.f), width, height);
    [button setFrame:frame];
    
    //NSLog(@"Coords: %f, %f", relX, relY);
}


#pragma mark - Events

- (IBAction)mainButtonTap:(id)sender {
    if (!isOpened) {
        [self displayMenu];
    } else {
        [self hideMenu];
    }
}

- (IBAction)menuButtonTap:(id)sender {
    UIButton * buttonSender = (UIButton *) sender;
    NSInteger buttonTag = buttonSender.tag;
    
    if (_animatedButtonHideMenuOnButtonClick) {
        [self hideMenu];
    }
 
    if ([self.animatedButtonDelegate respondsToSelector:@selector(animatedMenuButtonSelected:buttonTag:)]) {
        [self.animatedButtonDelegate animatedMenuButtonSelected:self buttonTag:buttonTag];
    }
}

#pragma mark - Menu show/hide

- (void) displayMenu {
    CGFloat alpha = _animatedButtonAlphaOpened;
    NSInteger counter = 1;
    
    for (UIButton * button in buttonArray) {
        [button setCenter:self.center];
        [self.superview addSubview:button];
        
        [UIView animateWithDuration:0.2f delay:0.0 options: UIViewAnimationOptionCurveLinear animations:^{
            [self updateFrameForButton:button withId:counter inTotalButtons:buttonArray.count];
        } completion:NULL];
        
        counter++;
    }
    
    [UIView animateWithDuration:0.2f delay:0.0 options: UIViewAnimationOptionCurveLinear animations:^{
        CGAffineTransform transform = CGAffineTransformMakeRotation(M_PI_2);
        self.transform = transform;
        
        self.alpha = alpha;
    } completion:NULL];
    
    [UIView commitAnimations];
    isOpened = YES;
}

- (void) hideMenu {
    CGFloat alpha = _animatedButtonAlphaNormal;
    
    for (UIButton * button in buttonArray) {
        [self.superview addSubview:button];
        
        [UIView animateWithDuration:0.2f delay:0.0 options: UIViewAnimationOptionCurveLinear animations:^{
            [button setCenter:self.center];
        } completion:^(BOOL ff){
            [button removeFromSuperview];
        }];
    }
    
    [UIView animateWithDuration:0.2f delay:0.0 options: UIViewAnimationOptionCurveLinear animations:^{
        self.transform = CGAffineTransformIdentity;
        self.alpha = alpha;
    } completion:NULL];
    
    [UIView commitAnimations];
    isOpened = NO;
}

@end
