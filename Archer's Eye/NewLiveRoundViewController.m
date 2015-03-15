//
//  NewLiveRoundViewController.m
//  Archer's Eye
//
//  Created by Alex de Vera on 3/15/15.
//  Copyright (c) 2015 Alex de Vera. All rights reserved.
//

#import "NewLiveRoundViewController.h"
#import "RoundDescCell.h"

@interface NewLiveRoundViewController ()

@end

@implementation NewLiveRoundViewController

//------------------------------------------------------------------------------
- (void)viewDidLoad
{
    self.appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;

    [super viewDidLoad];
}



//------------------------------------------------------------------------------
- (void)viewWillAppear:(BOOL)animated
{
    // Reload the data;  This is in case we created a live round and need to add
    // that into our list
    [self.tableView reloadData];
    
    [super viewDidLoad];
}



//------------------------------------------------------------------------------
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}























#pragma mark - Table view data source

//------------------------------------------------------------------------------
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}



//------------------------------------------------------------------------------
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSUInteger count = 0;
    
    if( _appDelegate.liveRound != nil )
        count = 1;
    else
        count = [_appDelegate.roundTemplates count];
    
    return count;
}



//------------------------------------------------------------------------------
- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    RoundDescCell *cell     = [tableView dequeueReusableCellWithIdentifier:@"RoundDescCell"];
    RoundInfo     *template = nil;

    // Show the live round
    if( _appDelegate.liveRound != nil )
    {
        template = _appDelegate.liveRound;
        
        cell.name.text      = @"LIVE";
        cell.name.textColor = [UIColor redColor];
        cell.numArrows.text = [NSString stringWithFormat:@"%d", template.numArrowsPerEnd];
        cell.numEnds.text   = [NSString stringWithFormat:@"%d", template.numEnds];
    }
    // Show the templates
    else
    {
        template = _appDelegate.roundTemplates[indexPath.row];

        cell.name.text      = @"TEMPLATE";
        cell.name.textColor = [UIColor blackColor];
        cell.numArrows.text = [NSString stringWithFormat:@"%d", template.numArrowsPerEnd];
        cell.numEnds.text   = [NSString stringWithFormat:@"%d", template.numEnds];
    }
    return cell;
}



//------------------------------------------------------------------------------
-       (void)tableView:(UITableView *)tableView
didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    RoundInfo *roundTemplate = _appDelegate.roundTemplates[indexPath.row];
    
    [_appDelegate startLiveRoundFromTemplate:roundTemplate];
}



//------------------------------------------------------------------------------
-               (CGFloat)tableView:(UITableView *)tableView
  estimatedHeightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 44;
}



//------------------------------------------------------------------------------
-       (CGFloat)tableView:(UITableView *)tableView
   heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 44;
}

@end
