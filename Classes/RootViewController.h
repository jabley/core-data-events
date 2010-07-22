//
//  RootViewController.h
//  CoreDataEvents
//
//  Created by James Abley on 22/07/2010.
//  Copyright Mobile IQ Ltd 2010. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>

@interface RootViewController : UITableViewController <NSFetchedResultsControllerDelegate> {

@private
    NSFetchedResultsController *fetchedResultsController_;
    NSManagedObjectContext *managedObjectContext_;

    /**
     Array of dictionaries which contain definitions for each UI button.
     */
    NSArray *buttonMappings_;

    /**
     Task queue to simulate long-running network operations which update Core Data.
     */
    NSOperationQueue *taskQueue_;
}

@property (nonatomic, retain) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, retain) NSFetchedResultsController *fetchedResultsController;

@end
