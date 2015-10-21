//
//  SearchViewController.m
//  Twinning
//
//  Created by CJ Ogbuehi on 10/19/15.
//  Copyright (c) 2015 Gen Y Solutions LLC. All rights reserved.
//

#import "SearchViewController.h"
#import "SearchCell.h"
#import <FontAwesomeKit/FAKIonIcons.h>

@interface SearchViewController ()<UITableViewDelegate, UITableViewDataSource,UISearchBarDelegate>
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;


@end

@implementation SearchViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.searchBar.delegate = self;
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero]; // use this to not allow extra table cells

    [self setup];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)setup
{
    self.navigationItem.title = NSLocalizedString(@"Search Results", nil);
    FAKIonIcons *backIcon = [FAKIonIcons closeRoundIconWithSize:35];
    UIImage *backImage = [backIcon imageWithSize:CGSizeMake(35, 35)];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithImage:backImage style:UIBarButtonItemStylePlain target:self action:@selector(goBack)];
    
    if (self.searchString){
        self.searchBar.text = self.searchString;
    }
}

- (void)fetchSearchWithText:(NSString *)text
{
    // get data from server
    // hold in my array
    // refresh tableview
}


- (void)goBack
{
    [self.searchBar resignFirstResponder];
    
    if ([self.navigationController.viewControllers count] > 1){
        [self.navigationController popViewControllerAnimated:YES];
    }
    else{
        [self dismissViewControllerAnimated:YES completion:nil];
    }
}

#pragma -mark Searchbar
- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText
{
    [self fetchSearchWithText:searchText];
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    [self fetchSearchWithText:searchBar.text];
}
#pragma -mark Tableview
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

-(NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    return @"";
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 3;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"searchCell"];
    return cell;
    
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    ((SearchCell *)cell).nameLabel.text = @"CJ Ogbuehi";
    ((SearchCell *)cell).userImageView.image = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:@"http://static.comicvine.com/uploads/original/4/43369/1135029-0000034668_20061021010455.jpg"]]];
}


@end
