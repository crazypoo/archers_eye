//
//  NewLiveRoundViewController.h
//  Archer's Eye
//
//  Created by Alex de Vera on 3/15/15.
//  Copyright (c) 2015 Alex de Vera. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AppDelegate.h"

@interface NewLiveRoundViewController : UITableViewController
{
    __weak AppDelegate *_appDelegate;
}

@property (weak) AppDelegate *appDelegate;

@end
