//
//  FullScreenImageViewController.m
//  Choose
//
//  Created by CJ Ogbuehi on 12/10/15.
//  Copyright © 2015 Gen Y Solutions LLC. All rights reserved.
//

#import "FullScreenImageViewController.h"

@interface FullScreenImageViewController ()

@property (weak, nonatomic) IBOutlet UIImageView *imageview;

@end

@implementation FullScreenImageViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self setup];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)setup
{
    
    self.view.backgroundColor = [UIColor blackColor];
    self.imageview.image = self.image;
    self.imageview.userInteractionEnabled = YES;
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tappedScreen:)];
    tap.numberOfTapsRequired = 1;
    tap.numberOfTouchesRequired = 1;
    
    UIView *tapScreen = [[UIView alloc] initWithFrame:self.view.frame];
    tapScreen.userInteractionEnabled = YES;
    tapScreen.backgroundColor = [UIColor clearColor];
    [tapScreen addGestureRecognizer:tap];
    
    [self.view addSubview:tapScreen];
}

                                   
- (void)tappedScreen:(UITapGestureRecognizer *)sender {
    [self dismissViewControllerAnimated:NO completion:nil];
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
