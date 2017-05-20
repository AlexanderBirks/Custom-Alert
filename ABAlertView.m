//
//  ABAlertView.m
//  ExampleCode
//
//  Created by Alexander Birks on 20/05/2017.
//  Copyright © 2017 Alexander Birks. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>

@protocol ABAlertViewDelegate <NSObject>
@optional

-(void)ABAlertViewButtonPressed:(int)buttonNumber;

@end
@interface ABAlertView : UIView

/*
 
 ABAlertView* myAlert = [[ABAlertView alloc] init];
 [self.view addSubview:myAlert];
 [self.view bringSubviewToFront:myAlert];
 
 myAlert.delegate = self;
 
 [myAlert ABAlertViewMessageWithText:@"Body Text" withTitle:@"Title" withImage:nil withButton1:@"Okay" withButton2:nil alertType:1];
 
 */

@property (nonatomic,strong) id delegate;
// 1st Layer
@property (nonatomic) UIView * blurEffect;
// 2nd layer, message box
@property (nonatomic) UIView * parentContainer;
@property (nonatomic) UILabel * header;
@property (nonatomic) UILabel * message;
@property (nonatomic) UIButton * buttonOne;
@property (nonatomic) UIButton * buttonTwo;
@property (nonatomic) UIImageView * iconImage;
@property (nonatomic) UITextView* txtview;

// init creates a parent view with a blur effect added as a subview.
- (id)init;

- (void) ABAlertViewMessageWithText:(NSString*)message withTitle:(NSString*)title withButton1:(NSString*)button1 withButton2:(NSString*)button2 alertType:(int)type;

@end

// ------

@implementation ABAlertView {
    BOOL confirmedAction;
}

- (id)init {
    self = [super init];
    if (self) {
        
        self.frame = CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height);
        
        // Add blur effect to the view to black out the background.
        // this also stops the user touching elements in the back views
        if (!UIAccessibilityIsReduceTransparencyEnabled()) {
            
            UIBlurEffect *blurEffect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleDark];
            UIVisualEffectView *blurEffectView = [[UIVisualEffectView alloc] initWithEffect:blurEffect];
            blurEffectView.frame = [UIScreen mainScreen].bounds;
            
            _blurEffect = [[UIView alloc] init];
            [_blurEffect sizeToFit];
            [_blurEffect addSubview:blurEffectView];
            [self addSubview:_blurEffect];
            [self bringSubviewToFront:_blurEffect];
            [_blurEffect bringSubviewToFront:blurEffectView];
            [_blurEffect setAlpha:0.6f];
            
            confirmedAction = NO;
        }
    }
    return self;
}

- (void) ABAlertViewMessageWithText:(NSString*)message withTitle:(NSString*)title withButton1:(NSString*)button1 withButton2:(NSString*)button2 alertType:(int)type {
    
    // check length of string message to see how big the frame should be
    NSInteger characterCount = [message length];
    float height = (self.frame.size.height / 2) + characterCount / 2;
    // make sure the message does not go beyond the screen
    if (height > self.frame.size.height) {
        height = self.frame.size.height;
    }
    
    // init _parentContainer for use
    [self initParentContainerViewWithWidth:self.frame.size.width - 50 withHeight:height];
    
    // extras -----------
    
    // add icon
    [self addIconFor:type];
    
    // add message _message
    if (message) {
        [self addMessageWithText:message];
    }
    
    // add title _header
    if (title) {
        [self addHeaderWithText:title];
    }
    
    // re-arrange buttons
    if (button1 && button2) {
        // next to each other
        [self initButtonOneWithOthers:YES withText:button1];
        [self initButtonTwoWithOthers:YES withText:button2];
    } else if (button1) {
        // middle
        [self initButtonOneWithOthers:NO withText:button1];
    } else if (button2) {
        // middle
        [self initButtonTwoWithOthers:NO withText:button2];
    }
    
    // animate view
    [self animateView];
}

// --------------------------------------------------------------------------------------------
// --------------------------------------------------------------------------------------------
// Additions...

// button 1
- (void) initButtonOneWithOthers:(BOOL)withOthers withText:(NSString*)text {
    
    UIButton* buttonInst = [UIButton buttonWithType:UIButtonTypeCustom];
    _buttonOne = buttonInst;
    
    if (withOthers == YES) {
        _buttonOne.frame = CGRectMake(_parentContainer.frame.size.width / 2, _parentContainer.frame.size.height - 100, _parentContainer.frame.size.width / 2 - 10, 50);
    } else {
        _buttonOne.frame = CGRectMake(_parentContainer.frame.size.width / 2, _parentContainer.frame.size.height - 100, _parentContainer.frame.size.width - 10, 50);
    }
    
    [[_buttonOne layer] setBorderWidth:1.0f];
    [[_buttonOne layer] setCornerRadius:8.0f];
    [[_buttonOne layer] setBorderColor:[UIColor whiteColor].CGColor];
    [_buttonOne setTitle:text forState:UIControlStateNormal];
    [_buttonOne setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [_buttonOne setTitleColor:[UIColor orangeColor] forState:UIControlStateHighlighted];
    [_buttonOne addTarget:self action:@selector(ButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    [_parentContainer addSubview:_buttonOne];
    [_parentContainer bringSubviewToFront:_buttonOne];
    
    if (withOthers == YES) {
        _buttonOne.center = CGPointMake(_parentContainer.frame.size.width / 4, _parentContainer.frame.size.height - 40);
    } else {
        _buttonOne.center = CGPointMake(_parentContainer.frame.size.width / 2, _parentContainer.frame.size.height - 40);
    }
}
// button 2
- (void) initButtonTwoWithOthers:(BOOL)withOthers withText:(NSString*)text {
    
    UIButton* buttonInst = [UIButton buttonWithType:UIButtonTypeCustom];
    _buttonTwo = buttonInst;
    
    if (withOthers == YES) {
        _buttonTwo.frame = CGRectMake(_parentContainer.frame.size.width / 2, _parentContainer.frame.size.height - 100, _parentContainer.frame.size.width / 2 - 10, 50);
    } else {
        _buttonTwo.frame = CGRectMake(_parentContainer.frame.size.width / 2, _parentContainer.frame.size.height - 100, _parentContainer.frame.size.width - 10, 50);
    }
    
    [[_buttonTwo layer] setBorderWidth:1.0f];
    [[_buttonTwo layer] setCornerRadius:8.0f];
    [[_buttonTwo layer] setBorderColor:[UIColor whiteColor].CGColor];
    [_buttonTwo setTitle:text forState:UIControlStateNormal];
    [_buttonTwo setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [_buttonTwo setTitleColor:[UIColor orangeColor] forState:UIControlStateHighlighted];
    [_buttonTwo addTarget:self action:@selector(ButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    [_parentContainer addSubview:_buttonTwo];
    [_parentContainer bringSubviewToFront:_buttonTwo];
    
    if (withOthers == YES) {
        _buttonTwo.center = CGPointMake(_parentContainer.frame.size.width / 4 * 3, _parentContainer.frame.size.height - 40);
    } else {
        _buttonTwo.center = CGPointMake(_parentContainer.frame.size.width / 2, _parentContainer.frame.size.height - 40);
    }
}
// parent container
- (void) initParentContainerViewWithWidth:(float)width withHeight:(float)height {
    
    UIView* viewInst = [[UIView alloc] initWithFrame:CGRectMake(self.frame.size.width / 2, self.frame.size.height / 2, width, height)];
    _parentContainer = viewInst;
    _parentContainer.backgroundColor = [UIColor blackColor];
    [self addSubview:_parentContainer];
    _parentContainer.center = CGPointMake(self.frame.size.width / 2, self.frame.size.height / 2);
    _parentContainer.layer.cornerRadius = 12;
    _parentContainer.layer.masksToBounds = YES;
    _parentContainer.layer.borderColor = [UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:0.7].CGColor;
    _parentContainer.layer.borderWidth = 1.0f;
    [self bringSubviewToFront:_parentContainer];
}
// header
- (void) addHeaderWithText:(NSString*)text {
    
    UIFont *customFont = [UIFont fontWithName:@"Helvetica-Medium" size:35];
    
    UILabel* labelInst = [[UILabel alloc] initWithFrame:CGRectMake(0.0, 0.0, _parentContainer.frame.size.width - 40, 300)];
    _header = labelInst;
    _header.text = text;
    _header.font = customFont;
    _header.numberOfLines = 3;
    _header.adjustsFontSizeToFitWidth = YES;
    _header.minimumScaleFactor = 10.0f/12.0f;
    _header.clipsToBounds = YES;
    _header.backgroundColor = [UIColor clearColor];
    _header.textColor = [UIColor whiteColor];
    _header.textAlignment = NSTextAlignmentCenter;
    [_parentContainer addSubview:_header];
    [_parentContainer bringSubviewToFront:_header];
    _header.center = CGPointMake(_parentContainer.frame.size.width / 2, _iconImage.center.y + 80);
}
// message
- (void) addMessageWithText:(NSString*)text {
    
    UIFont *customFont = [UIFont fontWithName:@"Helvetica-Light" size:19];
    
    _txtview = [[UITextView alloc] initWithFrame:CGRectMake(0, 0, _parentContainer.frame.size.width - 40, _parentContainer.frame.size.height / 3 * 2 - (_header.center.y + _iconImage.center.y))];
    _txtview.scrollEnabled = YES;
    _txtview.editable = NO;
    _txtview.selectable = NO;
    [_parentContainer addSubview:_txtview];
    [_parentContainer bringSubviewToFront:_txtview];
    _txtview.textAlignment = NSTextAlignmentCenter;
    _txtview.text = text;
    _txtview.textColor = [UIColor whiteColor];
    _txtview.font = customFont;
    _txtview.backgroundColor = [UIColor clearColor];
    _txtview.center = CGPointMake(_parentContainer.frame.size.width / 2, _parentContainer.frame.size.height / 2 + (_header.center.y + _iconImage.center.y));
}
// icon
- (void) addIconFor:(int)number {
    
    // call your images "MessageIcon" with a number at the end, ex MessageIcon1
    UIImage *image = [UIImage imageNamed:[NSString stringWithFormat:@"MessageIcon%d", number] inBundle:[NSBundle bundleForClass:self.class] compatibleWithTraitCollection:nil];
    
    _iconImage = [[UIImageView alloc] initWithImage:image];
    
    _iconImage.frame = CGRectMake(0, 0, _parentContainer.frame.size.width / 2, 90);
    _iconImage.contentMode = UIViewContentModeScaleAspectFit;
    
    [_parentContainer addSubview:_iconImage];
    [_parentContainer bringSubviewToFront:_iconImage];
    _iconImage.center = CGPointMake(_parentContainer.frame.size.width / 2, _parentContainer.frame.size.height - _parentContainer.frame.size.height + 70);
}

// --------------------------------------------------------------------------------------------
// --------------------------------------------------------------------------------------------
// Button Pressed

-(void) ButtonPressed:(UIButton*)button {
    
    if (button == _buttonOne) {
        
        if (self.delegate) {
            [self.delegate ABAlertViewButtonPressed:1];
        }
        [self animateViewOut];
    } else if (button == _buttonTwo) {
        
        if (self.delegate) {
            [self.delegate ABAlertViewButtonPressed:2];
        }
        [self animateViewOut];
    }
}

// --------------------------------------------------------------------------------------------
// --------------------------------------------------------------------------------------------
// Animate View IN & OUT

-(void) animateView {
    _parentContainer.layer.opacity = 0.0f;
    
    [UIView animateWithDuration:0.2f delay:0.0 options:UIViewAnimationOptionCurveEaseInOut
                     animations:^{
                         self.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.4f];
                         _parentContainer.layer.opacity = 1.0f;
                     }
                     completion:NULL
     ];
}

-(void) animateViewOut {
    confirmedAction = NO;
    
    [UIView animateWithDuration:0.2f delay:0.0 options:UIViewAnimationOptionCurveEaseInOut
                     animations:^{
                         self.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.4f];
                         _parentContainer.layer.opacity = 0.0f;
                         _blurEffect.layer.opacity = 0.0f;
                     }
                     completion:^(BOOL finished){
                         [_header removeFromSuperview];
                         [_txtview removeFromSuperview];
                         [_iconImage removeFromSuperview];
                         [_parentContainer removeFromSuperview];
                         [self removeFromSuperview];
                     }
     ];
}

@end
