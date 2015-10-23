//
//  ALAnimatedButtonWithMenu.h
//  AnimatedButtonExample
//
//  Created by Andrey Sapunov on 06/09/15.
//  Copyright (c) 2015 Andrey Sapunov. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum : NSUInteger {
    ALAnimatedButtonPositionBottomRight,
    ALAnimatedButtonPositionBottomLeft,
    ALAnimatedButtonPositionTopRight,
    ALAnimatedButtonPositionTopLeft
} ALAnimatedButtonPosition;

@class ALAnimatedButtonWithMenu;

@protocol ALAnimatedButtonWithMenuDelegate <NSObject>
@required

- (void) animatedMenuButtonSelected:(ALAnimatedButtonWithMenu *) animatedButtonWithMenu buttonTag:(NSInteger) buttonTag;

@end

@interface ALAnimatedButtonWithMenu : UIButton

@property (strong) id <ALAnimatedButtonWithMenuDelegate> animatedButtonDelegate;

#pragma mark - Position

@property (nonatomic, readonly) ALAnimatedButtonPosition animatedButtonPosition;
@property (nonatomic) CGFloat animatedButtonVerticalMargin;
@property (nonatomic) CGFloat animatedButtonHorizontalMargin;

#pragma mark - Appearance

@property (nonatomic) CGFloat animatedButtonAlphaNormal;
@property (nonatomic) CGFloat animatedButtonAlphaOpened;
@property (nonatomic) CGFloat animatedButtonRadius;
@property (nonatomic) Boolean animatedButtonHideMenuOnButtonClick;

#pragma mark - Constructors

- (id) initWithImage:(UIImage *) buttonImage inView:(UIView *) parentView;
- (id) initWithImage:(UIImage *) buttonImage andPosition:(ALAnimatedButtonPosition) position inView:(UIView *) parentView;

#pragma mark - Buttons

- (void) addMenuButton:(UIImage *) buttonImage withTag:(NSInteger) buttonTag;

- (void) displayMenu;
- (void) hideMenu;

@end
