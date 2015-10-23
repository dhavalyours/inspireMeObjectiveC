//
//  InfoViewController.m
//  FunkyCards
//
//  Created by Dhaval on 25/09/15.
//  Copyright © 2015 Dhaval. All rights reserved.
//

#import "InfoViewController.h"

@interface InfoViewController ()

@property (weak, nonatomic) IBOutlet UITextView *myTextView;

@end

@implementation InfoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self setupTextView];
}

-(void) setupTextView{
    
    NSString *htmlString = @"<h1>3rd Party Libraries used in the project</h1> <br /> <ul> <li><a href='https://github.com/spring' target='_blank'>Spring</a></li> <li><a href='https://github.com/rs/SDWebImage' target='_blank'>SDWebImage</a></li><li><a href='https://github.com/asaptf/ALAnimatedButtonWithMenu' target='_blank'>Animated Button</a></li></ul> <br /><br />  Follow me on twitter @<a href='https://twitter.com/dhavalyours'>dhavalyours</a><br /><br /> For feedback email me at    <a href='mailto:dhavalyours@gmail.com'>dhavalyours@gmail.com</a> ";
    
    NSAttributedString *attributedString = [[NSAttributedString alloc] initWithData:[htmlString dataUsingEncoding:NSUnicodeStringEncoding] options:@{ NSDocumentTypeDocumentAttribute: NSHTMLTextDocumentType } documentAttributes:nil error:nil];
    _myTextView.attributedText = attributedString;
    
    [_myTextView.layer setBorderColor:[[[UIColor grayColor] colorWithAlphaComponent:0.5] CGColor]];
    [_myTextView.layer setBorderWidth:2.0];
    
    //The rounded corner part, where you specify your view's corner radius:
    _myTextView.layer.cornerRadius = 5;
    _myTextView.clipsToBounds = YES;
    
    [_myTextView setBackgroundColor:[UIColor whiteColor]];
    [_myTextView setFont:[UIFont boldSystemFontOfSize:16.0]];
    [_myTextView setEditable:NO];
    

    
    //[_myTextView setContentToHTMLString:@""];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
