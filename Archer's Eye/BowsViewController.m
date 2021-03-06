//
//  BowsViewController.m
//  Archer's Eye
//
//  Created by Alex de Vera on 3/20/15.
//  Copyright (c) 2015 Alex de Vera. All rights reserved.
//

#import "BowsViewController.h"
#import "BowDescCell.h"

@interface BowsViewController ()

@end



@implementation BowsViewController

//------------------------------------------------------------------------------
- (void)viewDidLoad
{
    self.appDelegate    = (AppDelegate *)[UIApplication sharedApplication].delegate;
    self.archersEyeInfo = self.appDelegate.archersEyeInfo;

    [super viewDidLoad];
}



//------------------------------------------------------------------------------
- (void)viewWillAppear:(BOOL)animated
{
    // Reload the data;  This is in case we created a live round and need to add
    // that into our list
    [self.tableView reloadData];
    
    [super viewWillAppear:animated];
}



//------------------------------------------------------------------------------
- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self.archersEyeInfo showHintPopupIfNecessary:eHint_BnA_Bows];
}



//------------------------------------------------------------------------------
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}












#pragma mark - Table view data source

//------------------------------------------------------------------------------
// Number of sections.
//------------------------------------------------------------------------------
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}



//------------------------------------------------------------------------------
// Number of rows in a section.
//------------------------------------------------------------------------------
- (NSInteger)tableView:(UITableView *)tableView
 numberOfRowsInSection:(NSInteger)section
{
    return [self.archersEyeInfo.allBows count];
}



//------------------------------------------------------------------------------
// Build the rows.
//------------------------------------------------------------------------------
- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    BowDescCell *cell = [tableView dequeueReusableCellWithIdentifier:@"BowDescCell"];
    BowInfo     *bow  = self.archersEyeInfo.allBows[indexPath.row];

    cell.bowName.text        = bow.name;
    cell.bowType.text        = [BowInfo typeAsString:bow.type];
    cell.bowDrawWeight.text  = [NSString stringWithFormat:@"%ld lbs", (long)bow.drawWeight];
    
    return cell;
}



//------------------------------------------------------------------------------
// Override to support editing the table view.
//------------------------------------------------------------------------------
-   (void)tableView:(UITableView *)tableView
 commitEditingStyle:(UITableViewCellEditingStyle)editingStyle
  forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if( editingStyle == UITableViewCellEditingStyleDelete )
    {
        // Delete the row from the data source
        [self.archersEyeInfo.allBows removeObjectAtIndex:indexPath.row];
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }
    else if( editingStyle == UITableViewCellEditingStyleInsert )
    {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }
}



//------------------------------------------------------------------------------
// Did select a row.
//------------------------------------------------------------------------------
-       (void)tableView:(UITableView *)tableView
didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self.archersEyeInfo selectBow:indexPath.row];
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
