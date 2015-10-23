//
//  ViewController.m
//  FunkyCards
//
//  Created by Dhaval on 18/09/15.
//  Copyright © 2015 Dhaval. All rights reserved.
//

#import "ViewController.h"
#import "Spring/Spring.h"
#import "inspireMe-Swift.h"
#import "SDWebImage/UIImageView+WebCache.h"
#import "SDWebImageManager.h"
#import "SDWebImagePrefetcher.h"
#import "ALAnimatedButtonWithMenu.h"
#import "ToastView.h"


@interface ViewController ()<UIGestureRecognizerDelegate, ALAnimatedButtonWithMenuDelegate>

@property (weak, nonatomic) IBOutlet SpringImageView *myImageView;
@property (weak, nonatomic) IBOutlet SpringButton *likeButton;
- (IBAction)likeButtonClicked:(id)sender;

@property NSMutableArray *img_urls;
@property NSMutableArray *like_img_urls;
@property NSString *current_loaded_image_url;
@property NSUserDefaults *defaults;
@property ALAnimatedButtonWithMenu * menuButton;
@property NSDictionary *current_dict;
@property NSInteger dict_count;
@property CGFloat img_orig_x;
@property CGFloat img_orig_y;
@property NSInteger is_liked;
@property NSInteger is_favorite_mode_on;



@end

@implementation ViewController

- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    [self simpleJsonParsing]; //parse local json
    [self sanitizeScreen]; //set initvalue and reset header color
    [self setGestureRecognizers]; // add left right swype gestures
    [self setMenuButtonOptions]; // add right awesome menu
}



-(void) sanitizeScreen{
    [self setNeedsStatusBarAppearanceUpdate];
    self.img_orig_x=self.myImageView.bounds.origin.x;
    self.img_orig_y=self.myImageView.bounds.origin.y;
}

-(void) setGestureRecognizers{
    UISwipeGestureRecognizer *leftGestureRecognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(leftSwipeHandler:)];
    [leftGestureRecognizer setDirection:(UISwipeGestureRecognizerDirectionLeft)];
    [self.view addGestureRecognizer:leftGestureRecognizer];
    
    UISwipeGestureRecognizer *RightGestureRecognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(rightSwipeHandler:)];
    [RightGestureRecognizer setDirection:(UISwipeGestureRecognizerDirectionRight)];
    [self.view addGestureRecognizer:RightGestureRecognizer];
    
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
    [_menuButton hideMenu]; //code to hide open menu when user changes device orientation and also to set a menu in another mode.
    UIDeviceOrientation orientation = [[UIDevice currentDevice] orientation];
    if (orientation == UIDeviceOrientationLandscapeLeft ||  orientation == UIDeviceOrientationLandscapeRight)
    {
        [_menuButton hideMenu];
        // reset button now.
        [self setMenuButtonOptions];
    }else{
        [_menuButton hideMenu];
    }
}


-(void) setMenuButtonOptions{
    NSInteger same_size=40;
    NSInteger new_size=40;
    _menuButton = [[ALAnimatedButtonWithMenu alloc] initWithImage:[self imageWithImage:[UIImage imageNamed:@"plus_icon"] scaledToSize:CGSizeMake(same_size,same_size)] andPosition:ALAnimatedButtonPositionBottomRight inView:self.view];
    [_menuButton addMenuButton:[self imageWithImage:[UIImage imageNamed:@"info_icon"] scaledToSize:CGSizeMake(new_size,new_size)] withTag:1];
    [_menuButton addMenuButton:[self imageWithImage:[UIImage imageNamed:@"share_icon"] scaledToSize:CGSizeMake(new_size,new_size)] withTag:2];
    [_menuButton addMenuButton:[self imageWithImage:[UIImage imageNamed:@"fav_sel_inside"] scaledToSize:CGSizeMake(new_size,new_size)] withTag:3];
    [_menuButton setAnimatedButtonDelegate:self];
}



- (void) animatedMenuButtonSelected:(ALAnimatedButtonWithMenu *)animatedButtonWithMenu buttonTag:(NSInteger)buttonTag {
    
    NSURL *myUrl=[NSURL URLWithString:@"http://www.google.com/"];
    
    NSString * storyboardName = @"Main";
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:storyboardName bundle: nil];
    UIViewController * vc = [storyboard instantiateViewControllerWithIdentifier:@"appInfo"];
    
    
    switch (buttonTag) {
        case 1:
            //NSLog(@"info clicked show information screen "); //show Information scren
            [self presentViewController:vc animated:YES completion:nil];
            // appInfo
            break;
            
        case 2:
            //NSLog(@"share button clicked");
            [self shareText:@"Share me." andImage:self.myImageView.image andUrl:myUrl];
            break;
            
        case 3:
            //NSLog(@"favorite clicked"); // show liked cards
            
            
            if(_is_favorite_mode_on==0){
                // if no favorite mode selected show notification
                if([_like_img_urls count]> 0){
                    _is_favorite_mode_on=1;
                    [self showToasterView:@"showing liked quotes"];
                    [self CardDismiss:@"right"];
                }else{
                    [self showToasterView:@"no liked quotes"];
                }
                
            }else{
                _is_favorite_mode_on=0;
                [self showToasterView:@"showing all quotes"];
                [self CardDismiss:@"left"];
            }
            
            break;
            
        default:
            break;
    }
    
}

-(void) showToasterView:(NSString *)displayText{
    [ToastView showToastInParentView:self.view withText:displayText withDuaration:2.0];
}

- (UIImage *)imageWithImage:(UIImage *)image scaledToSize:(CGSize)newSize {
    //UIGraphicsBeginImageContext(newSize);
    // In next line, pass 0.0 to use the current device's pixel scaling factor (and thus account for Retina resolution).
    // Pass 1.0 to force exact pixel size.
    UIGraphicsBeginImageContextWithOptions(newSize, NO, 0.0);
    [image drawInRect:CGRectMake(0, 0, newSize.width, newSize.height)];
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newImage;
}



- (void)simpleJsonParsing{
    /* call from url, we will do the background updating later.
     
     NSString *urlString   = @"https://www.right-click.in/inspireMe/myData.json"; // The Openweathermap JSON responder
     NSURL *url            = [[NSURL alloc]initWithString:urlString];
     NSURLRequest *request = [NSURLRequest requestWithURL:url];
     NSURLResponse *response;
     NSData *GETReply      = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:nil];
     NSDictionary *res     = [NSJSONSerialization JSONObjectWithData:GETReply options:NSJSONReadingMutableLeaves|| NSJSONReadingMutableContainers error:nil];
     //NSLog(@"%@",res);
     */
    _is_favorite_mode_on=0;
    
    NSString *filePath = [[NSBundle mainBundle] pathForResource:@"myData" ofType:@"json"];
    NSData *JSONData = [NSData dataWithContentsOfFile:filePath options:NSDataReadingMappedIfSafe error:nil];
    _img_urls = [NSJSONSerialization JSONObjectWithData: JSONData options:NSJSONReadingMutableContainers error:nil];
    [self loadNextImage];
    
    _defaults = [NSUserDefaults standardUserDefaults];
    NSString *isImageCached = [_defaults objectForKey:@"is_image_cached"];
    
    _like_img_urls=  [[NSMutableArray alloc]initWithArray:[[NSUserDefaults standardUserDefaults] objectForKey:@"liked_image_array"]];
    
    
    if (isImageCached == nil){
        // cache all image urls on first time install.
        
        
        [_defaults setObject:@"1" forKey:@"is_image_cached"];
        [self cacheAllImageUrl:_img_urls];
        [_defaults setObject:@"1" forKey:@"is_image_cached"];
        [_defaults setObject:@"1" forKey:@"cache_count"];
    }else{
        
        if([[_defaults objectForKey:@"cache_count"] isEqualToString:@"5"]){
            [self cacheAllImageUrl:_img_urls];
            [_defaults setObject:@"1" forKey:@"is_image_cached"];
            [_defaults setObject:@"1" forKey:@"cache_count"];
        }else{
            
            //   NSString *num=[_defaults objectForKey:@"cache_count"];
            
            
        }
        
    }
    
}

- (UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
}

-(void)leftSwipeHandler:(UISwipeGestureRecognizer *)recognizer {
    //NSLog(@"Left Swipe received.");
    [self CardDismiss:@"left"];
}

-(void)rightSwipeHandler:(UISwipeGestureRecognizer *)recognizer {
    //NSLog(@"Right Swipe received.");
    [self CardDismiss:@"right"];
    
}

-(void)topSwipeHandler:(UISwipeGestureRecognizer *)recognizer {
    //NSLog(@"Top Swipe received.");
    [self CardDismiss:@"left"];
    /*
     <div>Icons made by <a href="http://www.flaticon.com/authors/fermam-aziz" title="Fermam Aziz">Fermam Aziz</a> from <a href="http://www.flaticon.com" title="Flaticon">www.flaticon.com</a>             is licensed by <a href="http://creativecommons.org/licenses/by/3.0/" title="Creative Commons BY 3.0">CC BY 3.0</a></div>
     
     */
}


-(void) CardDismiss:(NSString*)direction{
    
    
    NSArray *dismissAnimations =@[@"zoomOut",@"squeezeDown",@"squeezeRight",@"fall",@"swing",@"shake"];
    NSArray *entryAnimations =@[@"zoomIn",@"slideLeft",@"squeezeUp",@"squeezeLeft",@"wobble",@"squeeze",@"pop"];
    
    
    NSUInteger randomIndex2 = arc4random() % [dismissAnimations count];
    NSString *myAnimation=dismissAnimations[randomIndex2];
    
    //NSLog(@"Remove Animation : %@ ",myAnimation);
    self.myImageView.animation = myAnimation;
    self.myImageView.duration=0.8;
    self.myImageView.delay=0;
    self.myImageView.force=1;
    
    CGFloat outer_bounds=1000;
    
    if([direction isEqual:@"left"]){
        self.myImageView.x=self.myImageView.bounds.origin.x-outer_bounds;
        self.myImageView.y=self.myImageView.bounds.origin.y-outer_bounds;
        
    }else{
        self.myImageView.x=self.myImageView.bounds.origin.x+outer_bounds;
        self.myImageView.y=self.myImageView.bounds.origin.y+outer_bounds;
        
    }
    
    [self.myImageView animateToNext:^{
        
        [self loadNextImage];
        NSUInteger rand_index= arc4random() % [entryAnimations count];
        NSString *myAnimation=entryAnimations[rand_index];
        
        //NSLog(@"Loading  Animation %@",myAnimation);
        self.myImageView.animation = myAnimation;
        self.myImageView.x=self.img_orig_x;
        self.myImageView.y=self.img_orig_y;
        self.myImageView.duration=0.8;
        self.myImageView.delay=0;
        self.myImageView.force=1;
        [self.myImageView animate];
    }];
}


-(void) cacheAllImageUrl:(NSArray*)myImageArr{
    
    NSMutableArray * urls = [NSMutableArray arrayWithCapacity:myImageArr.count];
    for (NSDictionary *s in myImageArr) {
        NSString *cache_img_str=[s objectForKey:@"img_url"];
        [urls addObject:[NSURL URLWithString:cache_img_str]];
    }
    [[SDWebImagePrefetcher sharedImagePrefetcher] prefetchURLs:urls];
}



-(void) loadNextImage{
    
    NSUInteger randomIndex = 0;
    NSString *img_str=@"";
    
    
    
    
    
    if(_is_favorite_mode_on ==0 || [_like_img_urls count] ==0){
        
        randomIndex = arc4random() % [_img_urls count];
        _current_dict  = [_img_urls objectAtIndex:randomIndex];
        img_str=[_current_dict objectForKey:@"img_url"];
        _current_loaded_image_url=img_str;
        //NSLog(@"Loading image %@",img_str);
        
    }else{
        
        if([_like_img_urls count] ==0){
            //NSLog(@"no liked images");
        }
        randomIndex = arc4random() % [_like_img_urls count];
        img_str=  [_like_img_urls objectAtIndex:randomIndex];;
        _current_loaded_image_url=img_str;
        //NSLog(@"Loading image %@",img_str);
    }
    
    
    
    
    self.myImageView.image = nil;
    [self.myImageView sd_setImageWithURL:[NSURL URLWithString:img_str]
                        placeholderImage:[UIImage imageNamed:@"loader.png"]];
    
    
    //set like counter to 0
    if ([_like_img_urls containsObject: img_str]) {
        _is_liked=1;
        [self.likeButton setImage:[UIImage imageNamed:@"fav_sel"] forState:UIControlStateNormal];
    }else{
        _is_liked=0;
        [self.likeButton setImage:[UIImage imageNamed:@"favorite_icon_unsel1"] forState:UIControlStateNormal];
    }
    
    //reset like button
    self.likeButton.animation = @"pop";
    self.likeButton.duration=0.8;
    self.likeButton.delay=0;
    self.likeButton.force=1;
    [self.likeButton animate];
}

- (IBAction)likeButtonClicked:(id)sender {
    
    //NSLog(@"like button clicked");
    
    if(_is_liked == 0){
        
        _is_liked=1;
        [self.likeButton setImage:[UIImage imageNamed:@"fav_sel"] forState:UIControlStateNormal];
        self.likeButton.animation = @"pop";
        self.likeButton.duration=0.8;
        self.likeButton.delay=0;
        self.likeButton.force=1;
        [self.likeButton animate];
        //add to liked array
        [_like_img_urls addObject:_current_loaded_image_url];
    }else{
        _is_liked=0;
        [self.likeButton setImage:[UIImage imageNamed:@"favorite_icon_unsel1"] forState:UIControlStateNormal];
        [_like_img_urls addObject:_current_loaded_image_url];
        self.likeButton.animation = @"pop";
        self.likeButton.duration=0.8;
        self.likeButton.delay=0;
        self.likeButton.force=1;
        [self.likeButton animate];
        //add to liked array
        [_like_img_urls removeObject:_current_loaded_image_url];
    }
    [_defaults setObject:_like_img_urls forKey:@"liked_image_array"];
    
    //NSLog(@"---  %@ ",_like_img_urls);
    
}


- (void)shareText:(NSString *)text andImage:(UIImage *)image andUrl:(NSURL *)url
{
    NSMutableArray *sharingItems = [NSMutableArray new];
    if (text) {
        //    [sharingItems addObject:text];
    }
    if (image) {
        [sharingItems addObject:image];
    }
    if (url) {
        // [sharingItems addObject:url];
    }
    UIActivityViewController *activityController = [[UIActivityViewController alloc] initWithActivityItems:sharingItems applicationActivities:nil];
    
    
    NSArray *excludeActivities = @[UIActivityTypeAirDrop,
                                   UIActivityTypePrint,
                                   UIActivityTypeAssignToContact,
                                   UIActivityTypeSaveToCameraRoll,
                                   UIActivityTypeAddToReadingList,
                                   UIActivityTypePostToFlickr,
                                   UIActivityTypePostToVimeo,
                                   UIActivityTypeCopyToPasteboard];
    
    activityController.excludedActivityTypes = excludeActivities;
    
    [self presentViewController:activityController animated:YES completion:nil];
    
    
}




- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    //NSLog(@"RECIEVED Memory warning");
}
@end
