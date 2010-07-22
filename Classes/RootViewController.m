//
//  RootViewController.m
//  CoreDataEvents
//
//  Created by James Abley on 22/07/2010.
//  Copyright Mobile IQ Ltd 2010. All rights reserved.
//

#import "RootViewController.h"
#import "Hero.h"
#import "DeleteOperation.h"
#import "InsertOperation.h"
#import "UpdateOperation.h"

@interface RootViewController ()

- (void)configureButtonCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath;

- (void)configureHeroCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath;

- (void)createHeroIfNecessary:(NSString*)name;

- (void)save;

- (void)seedCoreData;

- (void)submitOperation:(Class)op;

@end

@interface RootViewController(ButtonActions)

- (IBAction)deleteWasTapped:(id)sender;

- (IBAction)insertWasTapped:(id)sender;

- (IBAction)resetWasTapped:(id)sender;

- (IBAction)updateWasTapped:(id)sender;

@end



@implementation RootViewController

@synthesize fetchedResultsController=fetchedResultsController_, managedObjectContext=managedObjectContext_;


#pragma mark -
#pragma mark View lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];

    if ([[[self fetchedResultsController] fetchedObjects] count] != 5) {
        [self seedCoreData];
    }

    buttonMappings_ = [[NSArray alloc] initWithObjects:
                       // 0 - Insert
                       [NSDictionary dictionaryWithObjectsAndKeys:
                        @"Insert", @"title",
                        @"insertWasTapped:", @"target",
                        [NSValue valueWithCGRect:CGRectMake(7, 7, 100, 30)], @"frame",
                        nil],

                       // 1 - Update
                       [NSDictionary dictionaryWithObjectsAndKeys:
                        @"Update", @"title",
                        @"updateWasTapped:", @"target",
                        [NSValue valueWithCGRect:CGRectMake(200, 7, 100, 30)], @"frame",
                        nil],


                       // 2 - Delete
                       [NSDictionary dictionaryWithObjectsAndKeys:
                        @"Delete", @"title",
                        @"deleteWasTapped:", @"target",
                        [NSValue valueWithCGRect:CGRectMake(7, 40, 100, 30)], @"frame",
                        nil],


                       // 3 - Reset
                       [NSDictionary dictionaryWithObjectsAndKeys:
                        @"Reset", @"title",
                        @"resetWasTapped:", @"target",
                        [NSValue valueWithCGRect:CGRectMake(200, 40, 100, 30)], @"frame",
                        nil],

                       nil];

    taskQueue_ = [[NSOperationQueue alloc] init];
}

#pragma mark -
#pragma mark RootViewController()

- (void)configureButtonCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath {

    for (NSDictionary *mappings in buttonMappings_) {
        UIButton *button = [UIButton buttonWithType:UIButtonTypeRoundedRect];

        [button addTarget:self
                   action:NSSelectorFromString([mappings objectForKey:@"target"])
         forControlEvents:UIControlEventTouchUpInside];

        [button setTitle:[mappings objectForKey:@"title"] forState:UIControlStateNormal];
        [button setFrame:[(NSValue*)[mappings objectForKey:@"frame"] CGRectValue]];

        [cell addSubview:button];
    }
}

- (void)configureHeroCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath {

    NSManagedObject *managedObject = [self.fetchedResultsController objectAtIndexPath:indexPath];
    cell.textLabel.text = [[managedObject valueForKey:@"name"] description];
}

- (void)createHeroIfNecessary:(NSString*)name {
    NSPredicate *p = [NSPredicate predicateWithFormat:@"name == %@", name];
    NSArray *matchingHeros = [[[self fetchedResultsController] fetchedObjects] filteredArrayUsingPredicate:p];

    if ([matchingHeros count] == 0) {
        Hero *hero = [NSEntityDescription insertNewObjectForEntityForName:@"Hero" inManagedObjectContext:[self managedObjectContext]];
        [hero setName:name];

        [self save];
    }
}

- (void)deleteAllHeroes {
    for (NSManagedObject *hero in [[self fetchedResultsController] fetchedObjects]) {
        [[self managedObjectContext] deleteObject:hero];
    }

    [self save];
}

- (void)save {
    NSError *error = nil;
    if (![[self managedObjectContext] save:&error]) {
        NSLog(@"%@:%@ problem saving %@, %@", self, NSStringFromSelector(_cmd), error, [error userInfo]);
        abort();
    }
}

- (void)seedCoreData {
    NSArray *superHeroes = [NSArray arrayWithObjects:@"Superman", @"Spiderman", @"Batman", @"Mr Incredible", @"Hulk", nil];

    for (NSString *name in superHeroes) {
        [self createHeroIfNecessary:name];
    }
}

- (void)submitOperation:(Class)op {
    NSOperation *task = [[op alloc] initWithManagedObjectContext:[self managedObjectContext]];
    [taskQueue_ addOperation:task];
    [task release];
}

#pragma mark -
#pragma mark ButtonActions
- (IBAction)deleteWasTapped:(id)sender {
    [self submitOperation:[DeleteOperation class]];
}

- (IBAction)insertWasTapped:(id)sender {
    [self submitOperation:[InsertOperation class]];
}

- (IBAction)resetWasTapped:(id)sender {
    [self deleteAllHeroes];
    [self seedCoreData];
}

- (IBAction)updateWasTapped:(id)sender {
    [self submitOperation:[UpdateOperation class]];
}

#pragma mark -
#pragma mark Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return [[self.fetchedResultsController sections] count] + 1;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    switch (section) {
        case 0: {
            id <NSFetchedResultsSectionInfo> sectionInfo = [[self.fetchedResultsController sections] objectAtIndex:section];
            return [sectionInfo numberOfObjects];
        }
        case 1: {
            return 1; // Insert, Update, Delete and Reset buttons all in the same row.
        }
        default:
            [NSException raise:NSInvalidArgumentException format:@"Out of bounds %d", section];
            return -1;
    }
}


// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {

    static NSString *CellIdentifier = @"Cell";

    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
    }

    switch (indexPath.section) {
        case 0: { // list of heroes
            // Configure the cell.
            [self configureHeroCell:cell atIndexPath:indexPath];
            break;
        }
        case 1: { // buttons
            [self configureButtonCell:cell atIndexPath:indexPath];
            break;
        }
        default:
            break;
    }

    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if ([indexPath section] == 1) {
        return 80.0;
    }

    return 44.0;
}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/


// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {

    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the managed object for the given index path
        NSManagedObjectContext *context = [self.fetchedResultsController managedObjectContext];
        [context deleteObject:[self.fetchedResultsController objectAtIndexPath:indexPath]];

        // Save the context.
        NSError *error = nil;
        if (![context save:&error]) {
            /*
             Replace this implementation with code to handle the error appropriately.

             abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development. If it is not possible to recover from the error, display an alert panel that instructs the user to quit the application by pressing the Home button.
             */
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();
        }
    }
}


- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // The table view should not be re-orderable.
    return NO;
}


#pragma mark -
#pragma mark Table view delegate

- (NSIndexPath *) tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    switch ([indexPath section]) {
        case 1: // Don't allow selection of the buttons either
            return nil;
        default:
            return indexPath;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [[self tableView] deselectRowAtIndexPath:indexPath animated:YES];
}


#pragma mark -
#pragma mark Fetched results controller

- (NSFetchedResultsController *)fetchedResultsController {

    if (fetchedResultsController_ != nil) {
        return fetchedResultsController_;
    }

    /*
     Set up the fetched results controller.
    */
    // Create the fetch request for the entity.
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    // Edit the entity name as appropriate.
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Hero" inManagedObjectContext:self.managedObjectContext];
    [fetchRequest setEntity:entity];

    // Set the batch size to a suitable number.
    [fetchRequest setFetchBatchSize:20];

    // Edit the sort key as appropriate.
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"name" ascending:YES];
    NSArray *sortDescriptors = [[NSArray alloc] initWithObjects:sortDescriptor, nil];

    [fetchRequest setSortDescriptors:sortDescriptors];

    // Edit the section name key path and cache name if appropriate.
    // nil for section name key path means "no sections".
    NSFetchedResultsController *aFetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:self.managedObjectContext sectionNameKeyPath:nil cacheName:@"Root"];
    aFetchedResultsController.delegate = self;
    self.fetchedResultsController = aFetchedResultsController;

    [aFetchedResultsController release];
    [fetchRequest release];
    [sortDescriptor release];
    [sortDescriptors release];

    NSError *error = nil;
    if (![fetchedResultsController_ performFetch:&error]) {
        /*
         Replace this implementation with code to handle the error appropriately.

         abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development. If it is not possible to recover from the error, display an alert panel that instructs the user to quit the application by pressing the Home button.
         */
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }

    return fetchedResultsController_;
}


#pragma mark -
#pragma mark Fetched results controller delegate


- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller {
    [self.tableView beginUpdates];
}


- (void)controller:(NSFetchedResultsController *)controller didChangeSection:(id <NSFetchedResultsSectionInfo>)sectionInfo
           atIndex:(NSUInteger)sectionIndex forChangeType:(NSFetchedResultsChangeType)type {

    switch(type) {
        case NSFetchedResultsChangeInsert:
            [self.tableView insertSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationFade];
            break;

        case NSFetchedResultsChangeDelete:
            [self.tableView deleteSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationFade];
            break;
    }
}


- (void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject
       atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type
      newIndexPath:(NSIndexPath *)newIndexPath {

    UITableView *tableView = self.tableView;

    switch(type) {

        case NSFetchedResultsChangeInsert:
            [tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:newIndexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;

        case NSFetchedResultsChangeDelete:
            [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;

        case NSFetchedResultsChangeUpdate:
            [self configureHeroCell:[tableView cellForRowAtIndexPath:indexPath] atIndexPath:indexPath];
            break;

        case NSFetchedResultsChangeMove:
            [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
            [tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:newIndexPath]withRowAnimation:UITableViewRowAnimationFade];
            break;
    }
}


- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller {
    [self.tableView endUpdates];
}


/*
// Implementing the above methods to update the table view in response to individual changes may have performance implications if a large number of changes are made simultaneously. If this proves to be an issue, you can instead just implement controllerDidChangeContent: which notifies the delegate that all section and object changes have been processed.

 - (void)controllerDidChangeContent:(NSFetchedResultsController *)controller {
    // In the simplest, most efficient, case, reload the table view.
    [self.tableView reloadData];
}
 */


#pragma mark -
#pragma mark Memory management

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];

    // Relinquish ownership any cached data, images, etc that aren't in use.
}


- (void)viewDidUnload {
    // Relinquish ownership of anything that can be recreated in viewDidLoad or on demand.
    // For example: self.myOutlet = nil;
}


- (void)dealloc {
    [taskQueue_ release];
    [buttonMappings_ release];

    [fetchedResultsController_ release];
    [managedObjectContext_ release];
    [super dealloc];
}


@end

