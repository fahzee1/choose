//
//  CreateVoteController.m
//  Twinning
//
//  Created by CJ Ogbuehi on 9/19/15.
//  Copyright (c) 2015 Gen Y Solutions LLC. All rights reserved.
//

#import "CreateVoteController.h"
#import "ShareViewController.h"
#import "SelfieImageView.h"
#import "UIView+Glow.h"
#import "NSString+utils.h"
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
#import "Card.h"
#import <MBProgressHUD.h>
#import "UIImage+Utils.h"
#import <CRToast.h>


@interface CreateVoteController()<UIImagePickerControllerDelegate,RSKImageCropViewControllerDelegate,UINavigationControllerDelegate,UIActionSheetDelegate>
@property (weak, nonatomic) IBOutlet SelfieImageView *selfieImageView;
@property (weak, nonatomic) IBOutlet SelfieImageView *selfieImageView2;
@property (strong,nonatomic) UIImageView *tappedImageView;

@property (weak, nonatomic) IBOutlet UILabel *accessCodeLabel;
@property (strong, nonatomic) IBOutlet UITapGestureRecognizer *picTapGesture;
@property (strong, nonatomic) IBOutlet UITapGestureRecognizer *picTapGesture2;

@property (weak, nonatomic) IBOutlet ASProgressPopUpView *progressView;
@property (weak, nonatomic) IBOutlet UIButton *continueButton;

@property (weak, nonatomic) IBOutlet UIView *topHalfView;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UISegmentedControl *segmentedControl;
@property (assign) QuestionType questionType;
@property (nonatomic,strong) NSString *creatorName; // only used for staff
@property (assign) BOOL selfieTitle;
@property (assign) BOOL selfie1;
@property (assign) BOOL selfie2;

@property (assign) BOOL tappedSelfie1;

@property (strong,nonatomic) AMPopTip *popTip;
@property (strong,nonatomic) MBProgressHUD *hud;
@property (assign)BOOL shownPopTip1;
@property (assign) BOOL askedStaff;

// constraints
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *selfieWidthConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *selfieHeightConstraint;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *selfieHorizontalSpaceConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *selfieCenterXConstraint;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *selfieContainerHeightConstraint;

@end

@implementation CreateVoteController

- (void)viewDidLoad {
    [super viewDidLoad];
    //self.stage1selfie = YES;
    [self setup];
    
    NSParameterAssert(self.localUser);
    
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.accessCodeLabel.hidden = YES;
    self.accessCodeLabel.alpha = 0;
    
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    // Pop up the progressview
    [self.progressView showPopUpViewAnimated:YES];

    // If I havent shown the initial pop tip then show it
    if (!self.shownPopTip1){
        [self showPopTipWithText:NSLocalizedString(@"Tap above to choose picture", nil) andDelay:0];
        self.shownPopTip1 = YES;
    }
    
    if (self.createCardAs == CreateCardAsStaff && !self.askedStaff){
        [self askStaff];
        self.askedStaff = YES;
    }
    
    
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
    
    DLog(@"memory warning here");
}


-(void)setup
{
    self.navigationItem.title = NSLocalizedString(@"Create Your Own", nil);
    
    FAKIonIcons *backIcon = [FAKIonIcons closeRoundIconWithSize:35];
    UIImage *backImage = [backIcon imageWithSize:CGSizeMake(35, 35)];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithImage:backImage style:UIBarButtonItemStylePlain target:self action:@selector(goBack)];
    
    self.selfieImageView.userInteractionEnabled = YES;
    self.selfieImageView2.userInteractionEnabled = YES;
    self.selfieImageView.descriptionLabel.text = NSLocalizedString(@"Image 1", nil);
    self.selfieImageView2.descriptionLabel.text = NSLocalizedString(@"Image 2", nil);
    self.selfieImageView.descriptionLabel.font = [UIFont fontWithName:@"Futura-CondensedExtraBold" size:12];
    self.selfieImageView2.descriptionLabel.font = [UIFont fontWithName:@"Futura-CondensedExtraBold" size:12];

    
    [self.continueButton setBackgroundColor:[UIColor colorWithHexString:kColorRed]];
    [self.continueButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self.continueButton setTitle:NSLocalizedString(@"DONE", nil) forState:UIControlStateNormal];
    self.continueButton.titleLabel.font = [UIFont fontWithName:kFontGlobalBold size:20];
    
    self.titleLabel.text = NSLocalizedString(@"Tap To Add Question", nil);
    self.titleLabel.font = [UIFont fontWithName:kFontGlobal size:17];
    self.titleLabel.textColor = [UIColor whiteColor];
    self.titleLabel.userInteractionEnabled = YES;

    self.accessCodeLabel.textColor = [UIColor whiteColor];
    self.accessCodeLabel.font = [UIFont fontWithName:kFontGlobal size:15];
    self.accessCodeLabel.hidden = YES;
    self.accessCodeLabel.alpha = 0;
    
    // Create background image for selfies based on app icon
    UIImage *appIcon = [UIImage imageNamed:kAppIcon];
    UIImage *blurredIcon = [appIcon blurredImageWithRadius:3
                                                iterations:5
                                                 tintColor:[UIColor blackColor]];
    self.topHalfView.backgroundColor = [UIColor colorWithPatternImage:blurredIcon];
    self.view.backgroundColor = [UIColor colorWithHexString:kColorBlackSexy];
    

    [self.segmentedControl setTitle:NSLocalizedString(@"1 PIC", nil) forSegmentAtIndex:0];
    [self.segmentedControl setTitle:NSLocalizedString(@"2 PICS", nil) forSegmentAtIndex:1];
    [self.segmentedControl setTintColor:[UIColor whiteColor]];
    [self.segmentedControl setSelectedSegmentIndex:1];
    FAKIonIcons *imageIcon = [FAKIonIcons imageIconWithSize:35];
    FAKIonIcons *imagesIcon = [FAKIonIcons imagesIconWithSize:35];
    UIImage *imageImage = [imageIcon imageWithSize:CGSizeMake(35, 35)];
    UIImage *imagesImage = [imagesIcon imageWithSize:CGSizeMake(35, 35)];
    [self.segmentedControl setImage:imageImage forSegmentAtIndex:0];
    [self.segmentedControl setImage:imagesImage forSegmentAtIndex:1];
    
    if (IS_IPHONE_4_OR_LESS){
        self.selfieContainerHeightConstraint.constant = 300;
    }
    else{
        self.selfieContainerHeightConstraint.constant = 350;
    }
    
    //self.progressView.dataSource = self;
    //self.progressView.delegate = self;
    self.progressView.font = [UIFont fontWithName:kFontGlobal size:18];
    self.progressView.popUpViewAnimatedColors = @[[UIColor colorWithHexString:kColorFlatOrange], [UIColor colorWithHexString:kColorFlatGreen], [UIColor colorWithHexString:kColorFlatTurquoise]];
    self.progressView.popUpViewCornerRadius = 10.0;
    self.progressView.progress = 0.0;
    
    // Pop tip code
    AMPopTip *appearance = [AMPopTip appearance];
    appearance.textColor = [UIColor whiteColor];
    appearance.font = [UIFont fontWithName:kFontGlobal size:16];
    appearance.popoverColor = [UIColor colorWithHexString:kColorFlatGreen];
    appearance.animationIn = 1;
    self.popTip = [AMPopTip popTip];
    self.popTip.shouldDismissOnTapOutside = YES;
    self.popTip.shouldDismissOnTap = YES;
    self.popTip.tapHandler = ^{
        DLog(@"Tapped pop up");
    };
    

}

- (void)showPopTipWithText:(NSString *)text
                  andDelay:(float)delay
{
    double delayInSeconds = delay;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        //code to be executed on the main queue after delay
        CGRect frame = [self.view convertRect:self.selfieImageView.frame fromView:self.topHalfView];
        [self.popTip showText:text direction:AMPopTipDirectionDown maxWidth:200 inView:self.view fromFrame:frame duration:10];

    });
    
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

    
    UIImage *shareImage = [self.topHalfView convertViewToImage];
    UIViewController *contoller = [self.storyboard instantiateViewControllerWithIdentifier:kStoryboardShare];
    if ([contoller isKindOfClass:[ShareViewController class]]){
        ((ShareViewController *)contoller).shareImage = shareImage;
    }
    [self.navigationController pushViewController:contoller animated:YES];

}

- (void)saveImageToCameraRoll:(UIImage *)image
{
    UIImageWriteToSavedPhotosAlbum(image,nil,nil,nil);
}

- (void)askStaff
{
    PSTAlertController *alert = [PSTAlertController alertControllerWithTitle:NSLocalizedString(@"Choose Staff", nil)
                                                                     message:NSLocalizedString(@"You're seeing this because you're on the Choose staff. Would you like to create this card with a name (profile) other then your own?", nil)
                                                              preferredStyle:PSTAlertControllerStyleAlert];
    
    PSTAlertAction *yes = [PSTAlertAction actionWithTitle:NSLocalizedString(@"YES", nil) style:PSTAlertActionStyleDefault
                                                      handler:^(PSTAlertAction *action) {
                                                          [alert dismissAnimated:YES completion:nil];
                                                          [self getNameFromStaff];
                                                          
                                                      }];
    
    
    
    PSTAlertAction *no = [PSTAlertAction actionWithTitle:NSLocalizedString(@"NO", nil) style:PSTAlertActionStyleDefault
                                                   handler:^(PSTAlertAction *action) {
                                                       [alert dismissAnimated:YES completion:nil];
                                                   }];
    [alert addAction:yes];
    [alert addAction:no];
    [alert showWithSender:self controller:self animated:YES completion:nil];

}

- (void)getNameFromStaff
{
    PSTAlertController *alert = [PSTAlertController alertControllerWithTitle:NSLocalizedString(@"Create Fake User", nil)
                                                                     message:NSLocalizedString(@"Enter the name of the user you want to be displayed for this card. The server will create a temporary fake user to be displayed. Used by staff only.", nil)
                                                              preferredStyle:PSTAlertControllerStyleAlert];
    
    PSTAlertAction *cancel = [PSTAlertAction actionWithTitle:NSLocalizedString(@"Cancel", nil) style:PSTAlertActionStyleCancel
                                                  handler:^(PSTAlertAction *action) {
                                                      [alert dismissAnimated:YES completion:nil];
                                                      
                                                  }];
    
    
    
    PSTAlertAction *done = [PSTAlertAction actionWithTitle:NSLocalizedString(@"Done", nil) style:PSTAlertActionStyleDefault
                                                 handler:^(PSTAlertAction *action) {
                                                     self.creatorName = alert.textField.text;
                                                     [alert dismissAnimated:YES completion:nil];
                                                     // let user know
                                                     NSDictionary *options = @{
                                                                               kCRToastTextKey :[NSString stringWithFormat:@"Creating card as %@",self.creatorName],
                                                                               kCRToastTextAlignmentKey : @(NSTextAlignmentCenter),
                                                                               kCRToastBackgroundColorKey : [UIColor colorWithHexString:kColorFlatTurquoise],
                                                                               kCRToastAnimationInTypeKey : @(CRToastAnimationTypeGravity),
                                                                               kCRToastAnimationOutTypeKey : @(CRToastAnimationTypeGravity),
                                                                               kCRToastAnimationInDirectionKey : @(CRToastAnimationDirectionTop),
                                                                               kCRToastAnimationOutDirectionKey : @(CRToastAnimationDirectionTop),
                                                                               kCRToastTextColorKey:[UIColor whiteColor],
                                                                               kCRToastFontKey:[UIFont fontWithName:kFontGlobalBold size:15],
                                                                               kCRToastNotificationTypeKey:@(CRToastTypeNavigationBar),
                                                                               kCRToastTimeIntervalKey:@5
                                                                               };
                                                     [CRToastManager showNotificationWithOptions:options
                                                                                 completionBlock:^{
                                                                                 }];


                                                 }];
    [alert addAction:cancel];
    [alert addAction:done];
    [alert addTextFieldWithConfigurationHandler:^(UITextField *textField) {
        textField.placeholder = NSLocalizedString(@"Enter name", nil);
        textField.autocapitalizationType = UITextAutocapitalizationTypeWords;
    }];
    
    [alert showWithSender:self controller:self animated:YES completion:nil];
}

- (BOOL)checkRequired
{
    // First check images are there
    // If one image segment is selected only check for one image, else check for two
    NSString *title = NSLocalizedString(@"Error", nil);
    NSString *message = NSLocalizedString(@"Please choose first image by tapping on 'Image 1'.", nil);
    if (self.segmentedControl.selectedSegmentIndex == 0){
        if (!self.selfie1){
            [PSTAlertController presentDismissableAlertWithTitle:title
                                                         message:message
                                                      controller:self];
            return NO;
        }
    }
    else if (self.segmentedControl.selectedSegmentIndex == 1){
        if (!self.selfie1){
            [PSTAlertController presentDismissableAlertWithTitle:title
                                                         message:message
                                                      controller:self];
            return NO;
        }
        
        else if (!self.selfie2){
            message = NSLocalizedString(@"Please choose second image by tapping on 'Image 2'.", nil);
            [PSTAlertController presentDismissableAlertWithTitle:title
                                                         message:message
                                                      controller:self];
            return NO;
        }
    }
    
    
    // Then make sure title is set
    if (!self.selfieTitle){
        message = NSLocalizedString(@"Please add your question/title by tapping on 'Tap To Add Question'.", nil);
        [PSTAlertController presentDismissableAlertWithTitle:title
                                                     message:message
                                                  controller:self];
        return NO;
    }
    
    if (!self.questionType){
        [self askQuestionType];
        return NO;
        
    }
    
    return YES;
    
}

- (void)askQuestionType
{
    PSTAlertController *alert = [PSTAlertController alertControllerWithTitle:NSLocalizedString(@"Choose question type", nil)
                                                                     message:NSLocalizedString(@"Is this a 'YES or NO' question or an 'A or B' question?", nil)
                                                              preferredStyle:PSTAlertControllerStyleAlert];
    
    PSTAlertAction *yesORno = [PSTAlertAction actionWithTitle:NSLocalizedString(@"YES or NO", nil) style:PSTAlertActionStyleDefault
                                                      handler:^(PSTAlertAction *action) {
                                                          DLog(@"Yes or no question");
                                                          self.questionType = QuestionTypeYESorNO;
                                                          [self tappedContinueButton:nil];
                                                          [alert dismissAnimated:YES completion:nil];
                                                      }];
    

    
    PSTAlertAction *aORb = [PSTAlertAction actionWithTitle:NSLocalizedString(@"A or B", nil) style:PSTAlertActionStyleDefault
                                                   handler:^(PSTAlertAction *action) {
                                                        DLog(@"A or B question");
                                                       self.questionType = QuestionTypeAorB;
                                                       [self tappedContinueButton:nil];
                                                       [alert dismissAnimated:YES completion:nil];
                                                   }];
    [alert addAction:yesORno];
    [alert addAction:aORb];
    [alert showWithSender:self controller:self animated:YES completion:nil];
}

- (IBAction)tappedSegmentedControl:(UISegmentedControl *)sender {
    [self.popTip hide];
    if (sender.selectedSegmentIndex == 0){
        if (IS_IPHONE_4_OR_LESS){
            self.selfieHeightConstraint.constant = 190;
            self.selfieWidthConstraint.constant = 190;
        }
        else{
            self.selfieHeightConstraint.constant = 240;
            self.selfieWidthConstraint.constant = 240;
        }
        self.selfieCenterXConstraint.constant = 0;
        self.selfieImageView2.hidden = YES;
        self.selfieImageView2.alpha = 0;
    }
    
    else if (sender.selectedSegmentIndex == 1){
        self.selfieHeightConstraint.constant = 150;
        self.selfieWidthConstraint.constant = 150;
        self.selfieCenterXConstraint.constant = 80;
        self.selfieImageView2.hidden = NO;
        self.selfieImageView2.alpha = 1;

    }
    
    [UIView animateWithDuration:1
                     animations:^{
                         [self.view layoutIfNeeded];
                         [self.selfieImageView repositionIcon];
                     }];
}

- (IBAction)tappedContinueButton:(UIButton *)sender {
    // submit here
    // Check to make sure title is added and images are set
    // Then submit to server, if success then dismiss screen then send notif
    
    
    if (![self checkRequired]){
        return;
    }
    
    [self.progressView setProgress:1.0 animated:YES];
    
    //self.accessCodeLabel.hidden = NO;
    //self.accessCodeLabel.alpha = 1;
    
    self.hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    self.hud.labelText = NSLocalizedString(@"Submitting Card...", nil);
    
    UIImage *shareImage = [self.topHalfView convertViewToImage];
    
    [self saveImageToCameraRoll:shareImage];
    //shareImage = [UIImage imageWithImage:shareImage convertToSize:CGSizeMake(600, 600)];
    NSString *base64Image = [self base64Image:shareImage compress:NO];
    int question_type = 0;
    if (self.questionType == QuestionTypeAorB){
        question_type = 100;
    }
    else if (self.questionType == QuestionTypeYESorNO){
        question_type = 101;
    }
    
    NSMutableDictionary *params = [@{@"question":self.titleLabel.text,
                             @"question_type":[NSNumber numberWithInt:question_type],
                             @"facebook_id":self.localUser.facebook_id,
                             @"image":base64Image} mutableCopy];
    if (self.creatorName){
        params[@"creator_name"] = self.creatorName;
    }
    
    [User createCardWithParams:params
                         block:^(APIRequestStatus status, id data) {
                             [self.hud hide:YES];
                             if (status == APIRequestStatusSuccess){
                                 dispatch_async(dispatch_get_main_queue(), ^{
                                     [self dismissViewControllerAnimated:YES completion:^{
                                        
                                         Card *card = [Card createCardWithData:data[@"data"][@"card"]];
        
                                         [[NSNotificationCenter defaultCenter]
                                          postNotificationName:kNotificationSubmittedCard
                                          object:self
                                          userInfo:@{@"shareImage":shareImage,
                                                     @"shareText":self.titleLabel.text,
                                                     @"card":card}];
                                         
                                     }];
                                 });
                             }
                             else if (status == APIRequestStatusFail){
                                 // card_id will just be error message
                                [self showMessageWithTitle:NSLocalizedString(@"Error", nil) andMessage:data];
                             }
                             else{
                                 abort();
                             }
                         }];
    
    }

- (IBAction)tappedSelfieImageView:(UITapGestureRecognizer *)sender {
    self.tappedImageView = (UIImageView *)sender.view;
    self.tappedSelfie1 = YES;
    [self.popTip hide];
    
    if (SYSTEM_VERSION_LESS_THAN(@"8.0")){
        // this crashes on iOS7 so use ios& method
        [self showiOS7ActionSheet];
        return;
    }
    
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


- (IBAction)tappedTitleLabel:(UITapGestureRecognizer *)sender {
    SCLAlertView *alert = [[SCLAlertView alloc] init];
    alert.backgroundType = Shadow;
    //alert.iconTintColor = [UIColor colorWithHexString:kColorYellow];
    alert.customViewColor = [UIColor colorWithHexString:kColorRed];
    NSString *title = NSLocalizedString(@"Ask your question!", nil);
    NSString *subtitle = NSLocalizedString(@"E.g. 'Do I look like like my brother/sister?'" , nil);
    NSString *closeButton = NSLocalizedString(@"Cancel", nil);
    NSString *doneButton = NSLocalizedString(@"Done", nil);
    NSString *placeholder1 = NSLocalizedString(@"Ask your question selfie!", nil);
    
    UITextField *commentField = [alert addTextField:placeholder1];
    
    commentField.autocapitalizationType = UITextAutocapitalizationTypeSentences;
    commentField.text = self.titleLabel.text;

    [alert addButton:doneButton actionBlock:^{
        NSString *titleText = commentField.text;
        if (![titleText containsString:@"?"]){
            titleText = [NSString stringWithFormat:@"%@?",titleText];
        }
        self.titleLabel.text = titleText;
        self.selfieTitle = YES;
    }];
    
    [alert showEdit:self title:title subTitle:subtitle closeButtonTitle:closeButton duration:0.0f];

    
}

- (void)showiOS7ActionSheet
{
    UIActionSheet *sheet = [[UIActionSheet alloc]
                            initWithTitle:NSLocalizedString(@"Choose Picture", nil)
                            delegate:self
                            cancelButtonTitle:NSLocalizedString(@"Cancel", nil)
                            destructiveButtonTitle:nil
                            otherButtonTitles:NSLocalizedString(@"From Library", nil),NSLocalizedString(@"From Camera", nil), nil];
    
    [sheet showInView:self.view];
    
}

- (NSString *)base64Image:(UIImage *)image compress:(BOOL)compress
{
    UIImage *returnImage;
    if (compress){
        returnImage = [image compressImage:image];
    }
    else{
        returnImage = image;
    }
    
    NSData *imgData = UIImageJPEGRepresentation(returnImage, 0.8);
    NSData *imgData64 = [imgData base64EncodedDataWithOptions:NSDataBase64Encoding64CharacterLineLength];
    return [NSString stringWithUTF8String:imgData64.bytes];
}

#pragma -mark iOS7 action sheet delegat
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    UIImagePickerController *picker = [[UIImagePickerController alloc] init];
    picker.delegate = self;
    
    if (buttonIndex == 0){
        // Tapped choose from library
        if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary]){
            picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
        }
        [self presentViewController:picker animated:YES completion:nil];

    }
    else if (buttonIndex == 1){
         // Tapped choose from camera
        if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]){
            picker.sourceType = UIImagePickerControllerSourceTypeCamera;
        }
        [self presentViewController:picker animated:YES completion:nil];
    }
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
        if (self.tappedImageView){
            self.tappedImageView.image = croppedImage;
            if ([self.tappedImageView isKindOfClass:[SelfieImageView class]]){
                [((SelfieImageView *)self.tappedImageView) choseImage];
            }
            self.tappedImageView.contentMode = UIViewContentModeScaleAspectFit;
            if (self.tappedImageView == self.selfieImageView){
                self.selfie1 = YES;
            }
            else if (self.tappedImageView == self.selfieImageView2){
                self.selfie2 = YES;
            }
            return;
        }
        
    
        
    }];
    
}

-(void)imageCropViewController:(RSKImageCropViewController *)controller didCropImage:(UIImage *)croppedImage usingCropRect:(CGRect)cropRect
{
    [controller dismissViewControllerAnimated:YES completion:^{
        if (self.tappedImageView){
            self.tappedImageView.image = croppedImage;
            return;
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
                                   crop.applyMaskToCroppedImage = YES;
                                   crop.avoidEmptySpaceAroundImage = YES;
                                   crop.delegate = self;
                                   [self presentViewController:crop animated:YES completion:nil];
                               }];
}


#pragma -mark ASProgressPopupVIew datasource

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
