//
//  CreateVoteController.m
//  Twinning
//
//  Created by CJ Ogbuehi on 9/19/15.
//  Copyright (c) 2015 Gen Y Solutions LLC. All rights reserved.
//

#import "CreateVoteController.h"
#import "ShareViewController.h"
#import "UIView+Glow.h"
#import <ASProgressPopUpView.h>
#import <FontAwesomeKit/FAKIonIcons.h>
#import <AMPopTip.h>
#import "constants.h"
#import "UIView+Screenshot.h"
#import "UIColor+HexValue.h"
#import <PSTAlertController.h>
#import "RSKImageCropViewController.h"
#import <SCLAlertView.h>
#import <SCLAlertViewStyleKit.h>
#import <FXBlurView.h>

@interface CreateVoteController()<UIImagePickerControllerDelegate,RSKImageCropViewControllerDelegate,UINavigationControllerDelegate>
@property (weak, nonatomic) IBOutlet UIImageView *selfieImageView;
@property (weak, nonatomic) IBOutlet UIImageView *selfieImageView2;

@property (weak, nonatomic) IBOutlet UIImageView *downloadAppImageView;
@property (strong, nonatomic) IBOutlet UITapGestureRecognizer *picTapGesture;
@property (strong, nonatomic) IBOutlet UITapGestureRecognizer *picTapGesture2;

@property (weak, nonatomic) IBOutlet ASProgressPopUpView *progressView;
@property (weak, nonatomic) IBOutlet UIButton *continueButton;

@property (weak, nonatomic) IBOutlet UIView *bottomHalfView;
@property (weak, nonatomic) IBOutlet UIView *topHalfView;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;

@property (weak, nonatomic) IBOutlet UILabel *label1;
@property (weak, nonatomic) IBOutlet UILabel *label2;

@property (assign) BOOL selfie1;
@property (assign) BOOL selfie2;

@property (assign) BOOL tappedSelfie1;

@property (strong,nonatomic) AMPopTip *popTip;
@property (strong,nonatomic) NSTimer *timer;
@property (assign)BOOL shownPopTip1;


@end

@implementation CreateVoteController

- (void)viewDidLoad {
    [super viewDidLoad];
    //self.stage1selfie = YES;
    [self setup];
    
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.downloadAppImageView.hidden = YES;
    self.downloadAppImageView.alpha = 0;
    
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self.progressView showPopUpViewAnimated:YES];

    
    double delayInSeconds = 1.0;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        //code to be executed on the main queue after delay
        if (!self.shownPopTip1){
            [self showPopTipWithText:NSLocalizedString(@"Tap below to take a selfie", nil) andDelay:1 forStage:self.stage];
            self.shownPopTip1 = YES;
        }
        
    });
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
    
    DLog(@"memory warning here");
}


-(void)setup
{
    self.stage = VoteStage1;
    self.navigationItem.title = NSLocalizedString(@"Create!", nil);
    
    FAKIonIcons *backIcon = [FAKIonIcons chevronLeftIconWithSize:35];
    UIImage *backImage = [backIcon imageWithSize:CGSizeMake(35, 35)];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithImage:backImage style:UIBarButtonItemStylePlain target:self action:@selector(goBack)];

    self.selfieImageView.userInteractionEnabled = YES;
    self.selfieImageView2.userInteractionEnabled = YES;

    
    [self.continueButton setBackgroundColor:[UIColor colorWithHexString:kColorRed]];
    [self.continueButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self.continueButton setTitle:NSLocalizedString(@"Almost Done!", nil) forState:UIControlStateNormal];
    self.continueButton.titleLabel.font = [UIFont fontWithName:@"Futura-CondensedExtraBold" size:18];
    self.continueButton.layer.cornerRadius = 5;
    self.continueButton.hidden = YES;
    self.continueButton.alpha = 0;
    
    self.titleLabel.text = NSLocalizedString(@"Are we twins or nah?\n Vote now with code cj0092", nil);
    self.titleLabel.font = [UIFont fontWithName:@"Futura-CondensedExtraBold" size:17];
    self.label1.font = [UIFont fontWithName:@"Futura-CondensedExtraBold" size:16];
    self.label2.font = [UIFont fontWithName:@"Futura-CondensedExtraBold" size:16];
    self.titleLabel.textColor = [UIColor whiteColor];
    self.label1.textColor = [UIColor whiteColor];
    self.label2.textColor = [UIColor whiteColor];
    self.label1.userInteractionEnabled = YES;
    self.label2.userInteractionEnabled = YES;
    self.label1.hidden = YES;
    self.label1.alpha = 0;
    self.label2.hidden = YES;
    self.label2.alpha = 0;
    self.titleLabel.hidden = YES;
    self.titleLabel.alpha = 0;
    self.downloadAppImageView.hidden = YES;
    self.downloadAppImageView.alpha = 0;
    
    // Create background image for selfies based on app icon
    UIImage *appIcon = [UIImage imageNamed:kAppIcon];
    UIImage *blurredIcon = [appIcon blurredImageWithRadius:3
                                                iterations:3
                                                 tintColor:nil];
    self.topHalfView.backgroundColor = [UIColor colorWithPatternImage:blurredIcon];
    self.view.backgroundColor = [UIColor colorWithHexString:kColorLightGrey];

    

    
    //self.progressView.dataSource = self;
    //self.progressView.delegate = self;
    self.progressView.font = [UIFont fontWithName:@"Futura-CondensedExtraBold" size:18];
    self.progressView.popUpViewAnimatedColors = @[[UIColor colorWithHexString:kColorFlatOrange], [UIColor colorWithHexString:kColorFlatGreen], [UIColor colorWithHexString:kColorFlatTurquoise]];
    self.progressView.popUpViewCornerRadius = 10.0;
    self.progressView.progress = 0.0;
    
    // Pop tip code
    AMPopTip *appearance = [AMPopTip appearance];
    appearance.textColor = [UIColor whiteColor];
    appearance.font = [UIFont fontWithName:@"Futura-CondensedExtraBold" size:16];
    appearance.popoverColor = [UIColor colorWithHexString:kColorFlatGreen];
    appearance.animationIn = 1;
    self.popTip = [AMPopTip popTip];
    self.popTip.shouldDismissOnTapOutside = YES;
    self.popTip.shouldDismissOnTap = YES;
    self.popTip.tapHandler = ^{
        DLog(@"Tapped pop up");
    };
    
    
    self.timer = [NSTimer scheduledTimerWithTimeInterval:.05
                                                  target:self
                                                selector:@selector(updateTimerWithPreviousTime)
                                                userInfo:nil
                                                 repeats:YES];
}

- (void)showPopTipWithText:(NSString *)text
                  andDelay:(float)delay
                  forStage:(VoteStage)stage
{
    double delayInSeconds = delay;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        //code to be executed on the main queue after delay
        if (stage == VoteStage1){
            // show pop tip on first selfie box
            [self.popTip showText:text direction:AMPopTipDirectionUp maxWidth:200 inView:self.view fromFrame:self.selfieImageView.frame];
        }
        else if (stage == VoteStage2){
            // show pop tip on second selfie box
            [self.popTip showText:text direction:AMPopTipDirectionUp maxWidth:200 inView:self.view fromFrame:self.selfieImageView2.frame];
        }
        
    });
    
}
- (void)updateTimerWithPreviousTime
{
    if (!self.timer){
        [self addMyTimer];
    }

    switch (self.stage) {
        case VoteStage1:
        {
            [self removeMyTimer];
        }
            break;
            
        case VoteStage2:
        {
            if( self.progressView.progress < .25){
                self.progressView.progress = self.progressView.progress + .01f;
            }
            else{
                [self removeMyTimer];
            }
        }
            break;
            
        case VoteStage3:
        {
            if( self.progressView.progress < .49){
                self.progressView.progress = self.progressView.progress + .01f;
            }
            else{
                [self removeMyTimer];
            }

        }
            break;
            
        case VoteStage4:
        {
            if( self.progressView.progress < .74){
                self.progressView.progress = self.progressView.progress + .01f;
            }
            else{
                [self removeMyTimer];
            }
            
        }
            break;
            
        case VoteStage5:
        {
            if( self.progressView.progress < .99){
                self.progressView.progress = self.progressView.progress + .01f;
            }
            else{
                [self removeMyTimer];
                [self performSelector:@selector(goForward2) withObject:nil];
            }
            
        }
            break;
            
        default:
            break;
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

- (void)replaceAndAnimateSelfies
{

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

- (void)goForward
{

    self.downloadAppImageView.hidden = NO;
    self.downloadAppImageView.alpha = 1;
    
    UIImage *shareImage = [self.topHalfView convertViewToImage];
    UIViewController *contoller = [self.storyboard instantiateViewControllerWithIdentifier:kStoryboardShare];
    if ([contoller isKindOfClass:[ShareViewController class]]){
        ((ShareViewController *)contoller).shareImage = shareImage;
    }
    [self.navigationController pushViewController:contoller animated:YES];

}

- (void)goForward2
{
    self.stage = VoteStage5;
    [self goForward];
}

- (IBAction)tappedContinueButton:(UIButton *)sender {
    [self goForward];
}

- (IBAction)tappedSelfieImageView:(UITapGestureRecognizer *)sender {
    self.tappedSelfie1 = YES;
    [self.popTip hide];
    UIImagePickerController *picker = [[UIImagePickerController alloc] init];
    picker.delegate = self;

    PSTAlertController *controller = [PSTAlertController actionSheetWithTitle:NSLocalizedString(@"Choose picture", nil)];
    
    PSTAlertAction *chooseLibrary = [PSTAlertAction actionWithTitle:NSLocalizedString(@"From Library", nil) style:PSTAlertActionStyleDefault handler:^(PSTAlertAction *action) {
        if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary]){
            picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
        }
        [self presentViewController:picker animated:YES completion:nil];

    }];

    PSTAlertAction *openCamera = [PSTAlertAction actionWithTitle:NSLocalizedString(@"From Camera", nil) style:PSTAlertActionStyleDefault handler:^(PSTAlertAction *action) {
        if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]){
            picker.sourceType = UIImagePickerControllerSourceTypeCamera;
        }
        [self presentViewController:picker animated:YES completion:nil];


    }];
    
    PSTAlertAction *cancel = [PSTAlertAction actionWithTitle:NSLocalizedString(@"Cancel", nil) style:PSTAlertActionStyleCancel handler:^(PSTAlertAction *action) {
        [controller dismissAnimated:YES completion:nil];
    }];
    [controller addAction:chooseLibrary];
    [controller addAction:openCamera];
    [controller addAction:cancel];
    [controller showWithSender:self controller:self animated:YES completion:nil];
}

- (IBAction)tappedSelfieImageView2:(id)sender {
    [self tappedSelfieImageView:sender];
    self.tappedSelfie1 = NO;
}


- (IBAction)tappedLabel1:(UITapGestureRecognizer *)sender {
    [self.label1 stopGlowing];
    [self.label2 stopGlowing];
    
    SCLAlertView *alert = [[SCLAlertView alloc] init];
    alert.backgroundType = Shadow;
    //alert.iconTintColor = [UIColor colorWithHexString:kColorYellow];
    alert.customViewColor = [UIColor colorWithHexString:kColorFlatGreen];
    NSString *title = NSLocalizedString(@"Add your names!", nil);
    NSString *subtitle = NSLocalizedString(@"Name your selfie and twin." , nil);
    NSString *closeButton = NSLocalizedString(@"Cancel", nil);
    NSString *doneButton = NSLocalizedString(@"Done", nil);
    NSString *placeholder1 = NSLocalizedString(@"Name your selfie!", nil);
    NSString *placeholder2 = NSLocalizedString(@"Name your twin", nil);
    
    UITextField *commentField = [alert addTextField:placeholder1];
    UITextField *commentField2 = [alert addTextField:placeholder2];
    
    commentField.autocapitalizationType = UITextAutocapitalizationTypeSentences;
    commentField.text = self.label1.text;
    commentField2.autocapitalizationType = UITextAutocapitalizationTypeSentences;
    commentField2.text = self.label2.text;
    [alert addButton:doneButton actionBlock:^{
        self.label1.text = commentField.text;
        self.label2.text = commentField2.text;
        [self showButtons];
        if (self.stage == VoteStage3){
            self.stage = VoteStage4;
            [self updateTimerWithPreviousTime];
        }
    }];
    
    [alert showEdit:self title:title subTitle:subtitle closeButtonTitle:closeButton duration:0.0f];

    
}

- (IBAction)tappedLabel2:(UITapGestureRecognizer *)sender {
    [self tappedLabel1:sender];
}

- (void)showButtons
{
    if ([self.continueButton isHidden]){
        [UIView animateWithDuration:1
                         animations:^{
                             self.continueButton.hidden = NO;
                             self.continueButton.alpha = 1;
                             
                             FAKIonIcons *goIcon = [FAKIonIcons chevronRightIconWithSize:35];
                             UIImage *goImage = [goIcon imageWithSize:CGSizeMake(35, 35)];
                             self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithImage:goImage style:UIBarButtonItemStylePlain target:self action:@selector(goForward)];
                         }];
    }
}

- (void)showLabels
{
    
    [UIView animateWithDuration:1
                     animations:^{
                         self.label1.hidden = NO;
                         self.label1.alpha = 1;
                         self.label2.hidden = NO;
                         self.label2.alpha = 1;
                         self.titleLabel.hidden = NO;
                         self.titleLabel.alpha = 1;
                         
                     } completion:^(BOOL finished) {
                         [self.label1 startGlowingWithColor:[UIColor whiteColor] intensity:20];
                         [self.label2 startGlowingWithColor:[UIColor whiteColor] intensity:20];
                     }];

    
}

#pragma -mark Image cropper
-(void)imageCropViewControllerDidCancelCrop:(RSKImageCropViewController *)controller
{
    
    [controller dismissViewControllerAnimated:YES completion:nil];
}

- (void)imageCropViewController:(RSKImageCropViewController *)controller willCropImage:(UIImage *)originalImage
{
    
}

- (void)imageCropViewController:(RSKImageCropViewController *)controller didCropImage:(UIImage *)croppedImage usingCropRect:(CGRect)cropRect rotationAngle:(CGFloat)rotationAngle
{
    [controller dismissViewControllerAnimated:YES completion:^{
        if (self.stage == VoteStage1){
            self.stage = VoteStage2;
            self.selfieImageView.image = croppedImage;
            self.selfie1 = YES;
            [self updateTimerWithPreviousTime];
            [self showPopTipWithText:NSLocalizedString(@"Next choose your twin", nil) andDelay:1 forStage:VoteStage2];
        }
        else if (self.stage == VoteStage2){
            self.stage = VoteStage3;
            self.selfieImageView2.image = croppedImage;
            self.selfie2 = YES;
            [self updateTimerWithPreviousTime];
            [self showLabels];
        }
        else{
            if (self.tappedSelfie1){
                self.selfieImageView.image = croppedImage;
            }
            else{
                self.selfieImageView2.image = croppedImage;
            }
        }
        
        
    }];
    
}

-(void)imageCropViewController:(RSKImageCropViewController *)controller didCropImage:(UIImage *)croppedImage usingCropRect:(CGRect)cropRect
{
    [controller dismissViewControllerAnimated:YES completion:^{
        if (self.stage == VoteStage1){
            self.selfieImageView.image = croppedImage;
            self.selfie1 = croppedImage;
            [self showPopTipWithText:NSLocalizedString(@"Next choose your twin", nil) andDelay:1 forStage:VoteStage2];
        }
        else if (self.stage == VoteStage2){
            self.selfieImageView2.image = croppedImage;
            self.selfie2 = croppedImage;
            [self showButtons];
            [self showLabels];
        }

        
    }];
    
}


#pragma -mark UIImagepicker delegate
- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [picker dismissViewControllerAnimated:YES completion:^{
        //NSLog(@"cancled");
    }];
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    [picker dismissViewControllerAnimated:YES
                               completion:^{
                                   
                                   UIImage *originalImage = nil;
                                   originalImage = info[UIImagePickerControllerOriginalImage];
                                   
                                   RSKImageCropViewController *crop = [[RSKImageCropViewController alloc] initWithImage:originalImage];
                                   crop.cropMode = RSKImageCropModeSquare;
                                   crop.delegate = self;
                                   [self presentViewController:crop animated:YES completion:nil];
                               }];
}


#pragma -mark ASProgressPopupVIew datasource
-(NSString *)progressView:(ASProgressPopUpView *)progressView stringForProgress:(float)progress
{
    NSString *string;
    if (self.stage == VoteStage1){
        string = NSLocalizedString(@"First take a selfie!", nil);
    }
    else if (self.stage == VoteStage2){
        string = NSLocalizedString(@"Choose your twin!", nil);
    }
    else if (self.stage == VoteStage3){
        string = NSLocalizedString(@"Complete!", nil);
    }
    
    return string;
}

- (void)progressViewWillDisplayPopUpView:(ASProgressPopUpView *)progressView;
{

}

#pragma -mark Helper
-(void)showMessageWithTitle:(NSString *)title andMessage:(NSString *)message
{
    UIAlertView *alert = [[UIAlertView alloc]
                          initWithTitle:title
                          message:message
                          delegate:nil
                          cancelButtonTitle:NSLocalizedString(@"OK", nil)
                          otherButtonTitles:nil];
    [alert show];
}


@end
