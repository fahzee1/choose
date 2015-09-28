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

@interface ShareViewController ()<UITableViewDataSource,UITableViewDelegate>
@property (weak, nonatomic) IBOutlet UIImageView *shareImageView;

@property (weak, nonatomic) IBOutlet ASProgressPopUpView *progressView;

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) NSTimer *timer;
@end

@implementation ShareViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
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
    self.navigationItem.title = NSLocalizedString(@"Share!", nil);
    
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

#pragma -mark Tableview
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    if (section == 0){
        // categories
        return 3;
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
                cellText = @"SHARE ON FACEBOOK";
                FAKIonIcons *fbIcon = [FAKIonIcons socialFacebookIconWithSize:30];
                [fbIcon addAttribute:NSForegroundColorAttributeName value:[UIColor whiteColor]];
                fbIcon.drawingBackgroundColor = [UIColor blueColor];
                cellImage = [fbIcon imageWithSize:CGSizeMake(30, 30)];
            }
                break;
            case 1:
            {
                cellText = @"SAVE TO LIBRARY";
                FAKIonIcons *saveIcon = [FAKIonIcons archiveIconWithSize:30];
                [saveIcon addAttribute:NSForegroundColorAttributeName value:[UIColor whiteColor]];
                saveIcon.drawingBackgroundColor = [UIColor colorWithHexString:kColorFlatGreen];
                cellImage = [saveIcon imageWithSize:CGSizeMake(30, 30)];
            }
                break;
            case 2:
            {
                cellText = @"DO SOMETHING HERE";
                FAKIonIcons *saveIcon = [FAKIonIcons poundIconWithSize:30];
                [saveIcon addAttribute:NSForegroundColorAttributeName value:[UIColor whiteColor]];
                saveIcon.drawingBackgroundColor = [UIColor colorWithHexString:kColorFlatPurple];
                cellImage = [saveIcon imageWithSize:CGSizeMake(30, 30)];
            }
                break;
                
            default:
                break;
        }
        UIView *tappedBackgroundColor = [UIView new];
        tappedBackgroundColor.backgroundColor = [[UIColor redColor] colorWithAlphaComponent:0.5];
        cell.selectedBackgroundView = tappedBackgroundColor;
        ((ShareScreenCell *)cell).titleLabel.textColor = [UIColor blackColor];
        ((ShareScreenCell *)cell).titleLabel.font = [UIFont fontWithName:@"Futura-CondensedExtraBold" size:17];
        ((ShareScreenCell *)cell).titleLabel.text = cellText;
        ((ShareScreenCell *)cell).leftIconImage.image = cellImage;
    }

    return cell;
    
}


@end
