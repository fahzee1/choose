//
//  ShareViewController.m
//  Twinning
//
//  Created by CJ Ogbuehi on 9/24/15.
//  Copyright (c) 2015 Gen Y Solutions LLC. All rights reserved.
//

#import "ShareViewController.h"
#import <FontAwesomeKit/FAKIonIcons.h>
#import <ASProgressPopUpView.h>
#import "constants.h"
#import "ShareScreenCell.h"
#import "UIColor+HexValue.h"
#import <CRToast.h>


@interface ShareViewController ()<UITableViewDataSource,UITableViewDelegate>
@property (weak, nonatomic) IBOutlet UIImageView *shareImageView;

@property (weak, nonatomic) IBOutlet ASProgressPopUpView *progressView;

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) NSTimer *timer;
@property (assign) BOOL savedToLibrary;
@property (assign) BOOL sentToServer;
@end

@implementation ShareViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    if (IS_IPHONE_5 || IS_IPHONE_4_OR_LESS){
        self.tableView.scrollEnabled = YES;
    }
    else{
        self.tableView.scrollEnabled = NO;
    }
    self.tableView.backgroundColor = [UIColor colorWithHexString:kColorBlackSexy];
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero]; // use this to not allow extra table cells
    
    [self setup];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    self.shareImageView.image = self.shareImage;
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)setup
{
    self.navigationItem.title = NSLocalizedString(@"Share 🎉💥", nil);
    self.view.backgroundColor = [UIColor colorWithHexString:kColorBlackSexy];
    FAKIonIcons *backIcon = [FAKIonIcons chevronLeftIconWithSize:35];
    UIImage *backImage = [backIcon imageWithSize:CGSizeMake(35, 35)];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithImage:backImage style:UIBarButtonItemStylePlain target:self action:@selector(goBack)];
    
    self.progressView.font = [UIFont fontWithName:@"Futura-CondensedExtraBold" size:18];
    self.progressView.popUpViewAnimatedColors = @[[UIColor colorWithHexString:kColorFlatOrange], [UIColor colorWithHexString:kColorFlatGreen], [UIColor colorWithHexString:kColorFlatTurquoise]];
    self.progressView.popUpViewCornerRadius = 10.0;
    self.progressView.progress = .75;
    [self.progressView showPopUpViewAnimated:YES];



}

- (void)goBack
{
    if ([self.navigationController.viewControllers count] > 1){
        [self.navigationController popViewControllerAnimated:YES];
    }
    else{
        [self dismissViewControllerAnimated:YES completion:nil];
    }
}

- (void)updateTimerWithPreviousTime
{
    if (!self.timer){
        [self addMyTimer];
    }
    
    if( self.progressView.progress < .99){
        self.progressView.progress = self.progressView.progress + .01f;
    }
    else{
        [self removeMyTimer];
        //[self performSelector:@selector(goForward2) withObject:nil];
    }

    
}

- (void)removeMyTimer
{
    [self.timer invalidate];
    self.timer = nil;
}

- (void)addMyTimer
{
    self.timer = [NSTimer scheduledTimerWithTimeInterval:.05
                                                  target:self
                                                selector:@selector(updateTimerWithPreviousTime)
                                                userInfo:nil
                                                 repeats:YES];
}

- (void)saveImageToLibrary
{
    UIImageWriteToSavedPhotosAlbum(self.shareImageView.image, nil, nil, nil);
    self.savedToLibrary = YES;
    
    NSDictionary *options = @{kCRToastTextKey:NSLocalizedString(@"Image saved!", nil),
                              kCRToastTextColorKey:[UIColor whiteColor],
                              kCRToastFontKey:[UIFont fontWithName:@"Futura-CondensedExtraBold" size:18],
                              kCRToastTextAlignmentKey:@(NSTextAlignmentCenter),
                              kCRToastBackgroundColorKey:[UIColor colorWithHexString:kColorFlatTurquoise],
                              kCRToastAnimationInTypeKey:@(CRToastAnimationTypeGravity),
                              kCRToastAnimationOutTypeKey:@(CRToastAnimationTypeGravity),
                              kCRToastAnimationInDirectionKey:@(CRToastAnimationDirectionLeft),
                              kCRToastAnimationOutDirectionKey:@(CRToastAnimationDirectionRight),
                              kCRToastNotificationTypeKey:@(CRToastTypeNavigationBar),
                              kCRToastNotificationPresentationTypeKey:@(CRToastPresentationTypeCover)};
    
    [CRToastManager showNotificationWithOptions:options
                                completionBlock:^{
                                    DLog(@"saved image");
                                }];

}

- (void)showServerToast
{
    NSTimeInterval time = 60 * 60 * 24 * 360;
    NSDictionary *options = @{kCRToastTextKey:NSLocalizedString(@"Sending to server...", nil),
                              kCRToastTextColorKey:[UIColor whiteColor],
                              kCRToastFontKey:[UIFont fontWithName:@"Futura-CondensedExtraBold" size:18],
                              kCRToastTextAlignmentKey:@(NSTextAlignmentCenter),
                              kCRToastBackgroundColorKey:[UIColor colorWithHexString:kColorFlatGreen],
                              kCRToastAnimationInTypeKey:@(CRToastAnimationTypeGravity),
                              kCRToastAnimationOutTypeKey:@(CRToastAnimationTypeGravity),
                              kCRToastAnimationInDirectionKey:@(CRToastAnimationDirectionTop),
                              kCRToastAnimationOutDirectionKey:@(CRToastAnimationDirectionBottom),
                              kCRToastNotificationTypeKey:@(CRToastTypeNavigationBar),
                              kCRToastNotificationPresentationTypeKey:@(CRToastPresentationTypePush),
                              kCRToastTimeIntervalKey:@(time),
                              kCRToastShowActivityIndicatorKey:@(YES)};
    
    [CRToastManager showNotificationWithOptions:options
                                completionBlock:^{
                                    DLog(@"saved image");
                                }];

}

- (void)showSMSorEmailScreen
{
    NSString *inviteText = [NSString stringWithFormat:@"Go vote for me on Twinning"];
    UIActivityViewController *activityVC = [[UIActivityViewController alloc] initWithActivityItems:@[inviteText,self.shareImageView.image] applicationActivities:nil];
    activityVC.excludedActivityTypes = @[UIActivityTypePrint,UIActivityTypeCopyToPasteboard,UIActivityTypeSaveToCameraRoll];
    
    if (IS_IPAD){
        if ([activityVC respondsToSelector:@selector(popoverPresentationController)]){
            activityVC.popoverPresentationController.sourceView = self.view;
            
        }
    }
    
    [self presentViewController:activityVC animated:YES completion:nil];

}

#pragma -mark Tableview
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    if (section == 0){
        // If we still need to upload to server then just show one cell (submit)
        // If uploaded to server, check if we need 2 or 3 cells based on if we saved
        // to library or not
        if (self.sentToServer){
            return self.savedToLibrary? 2:3;
        }
        else{
            return 1;
        }
    }
    else{
        return 0;
    }
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"shareCell"];
    if (indexPath.section == 0){
        NSString *cellText;
        UIImage *cellImage;
        switch (indexPath.row) {
            case 0:
            {
                // Button 1 - will either be submit or share to facebook depending
                // on if we sent image to server or not
                if (!self.sentToServer){
                    cellText = @"SUBMIT";
                    FAKIonIcons *fbIcon = [FAKIonIcons happyIconWithSize:25];
                    [fbIcon addAttribute:NSForegroundColorAttributeName value:[UIColor whiteColor]];
                    fbIcon.drawingBackgroundColor = [UIColor colorWithHexString:kColorFlatGreen];
                    cellImage = [fbIcon imageWithSize:CGSizeMake(30, 30)];
                    }
                else{
                    cellText = @"SHARE ON FACEBOOK";
                    FAKIonIcons *fbIcon = [FAKIonIcons socialFacebookIconWithSize:25];
                    [fbIcon addAttribute:NSForegroundColorAttributeName value:[UIColor whiteColor]];
                    fbIcon.drawingBackgroundColor = [UIColor colorWithHexString:kColorFacebook];
                    cellImage = [fbIcon imageWithSize:CGSizeMake(30, 30)];
                }
            }
                break;
            case 1:
            {
                // Button 2 - will either be save to library or sms/email depending
                // on if we saved image to library or not

                if (!self.savedToLibrary){
                    cellText = @"SAVE TO LIBRARY";
                    FAKIonIcons *saveIcon = [FAKIonIcons iosDownloadIconWithSize:25];
                    [saveIcon addAttribute:NSForegroundColorAttributeName value:[UIColor whiteColor]];
                    saveIcon.drawingBackgroundColor = [UIColor colorWithHexString:kColorFlatGreen];
                    cellImage = [saveIcon imageWithSize:CGSizeMake(30, 30)];
                }
                else{
                    cellText = @"SMS OR EMAIL";
                    FAKIonIcons *saveIcon = [FAKIonIcons iosPaperplaneIconWithSize:25];
                    [saveIcon addAttribute:NSForegroundColorAttributeName value:[UIColor whiteColor]];
                    saveIcon.drawingBackgroundColor = [UIColor colorWithHexString:kColorFlatOrange];
                    cellImage = [saveIcon imageWithSize:CGSizeMake(30, 30)];
                }
            }
                break;
            case 2:
            {
                // Button 3 - as of now third button can only be sms
                cellText = @"SMS OR EMAIL";
                FAKIonIcons *saveIcon = [FAKIonIcons iosPaperplaneIconWithSize:25];
                [saveIcon addAttribute:NSForegroundColorAttributeName value:[UIColor whiteColor]];
                saveIcon.drawingBackgroundColor = [UIColor colorWithHexString:kColorFlatOrange];
                cellImage = [saveIcon imageWithSize:CGSizeMake(30, 30)];
            }
                break;
                
            default:
                break;
        }
        
        ((ShareScreenCell *)cell).titleLabel.font = [UIFont fontWithName:@"Futura-CondensedExtraBold" size:15];
        ((ShareScreenCell *)cell).titleLabel.text = cellText;
        ((ShareScreenCell *)cell).leftIconImage.image = cellImage;
    }

    return cell;
    
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if (indexPath.section == 0){
        switch (indexPath.row) {
            case 0:
            {
                // Button 1 - will either be submit or share to facebook depending
                // on if we sent image to server or not
                if (!self.sentToServer){
                    DLog(@"do something then show options");
                    [self showServerToast];
                    
                    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 5 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
                        [CRToastManager dismissNotification:YES];
                        self.sentToServer = YES;
                        [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationFade];
                    });
                }
                else{
                    DLog(@"tapped on fad")
                }
            }
                break;
            case 1:
            {
                // Button 2 - will either be save to library or sms/email depending
                // on if we saved image to library or not
                if (!self.savedToLibrary){
                    [self saveImageToLibrary];
                    [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationFade];

                }
                else{
                    [self showSMSorEmailScreen];
                }
            }
                break;

            case 2:
            {
                // Button 3 - as of now third button can only be sms
                [self showSMSorEmailScreen];
            }
                break;
            default:
                break;
        }
    }
}
@end
