//
//  InsertOperation.m
//  CoreDataEvents
//
//  Created by James Abley on 22/07/2010.
//  Copyright 2010 Mobile IQ Ltd. All rights reserved.
//

#import "InsertOperation.h"
#import "Hero.h"

@implementation InsertOperation

#pragma mark -
#pragma mark NSOperation
- (void)main {
    NSArray *names = [NSArray arrayWithObjects:
                      @"The Tick",
                      @"Team America",
                      @"Captain Scarlet",
                      @"Captain Caveman",
                      @"Aquaman",
                      @"Robin",
                      @"Wolverine",
                      @"Daredevil"
                      @"Blade",
                      nil];

    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];

    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Hero" inManagedObjectContext:[self threadedContext]];
    [fetchRequest setEntity:entity];

    NSError *error = nil;
    NSArray *heroes = [[self threadedContext] executeFetchRequest:fetchRequest error:&error];

    if (!heroes) {
        NSLog(@"%@:%@ error retrieving heroes %@, %@", self, NSStringFromSelector(_cmd), error, [error userInfo]);
        abort();
    }

    Hero *hero = [NSEntityDescription insertNewObjectForEntityForName:@"Hero"
                                               inManagedObjectContext:[self threadedContext]];

    [hero setName:[names objectAtIndex:0u]];

    NSPredicate *namep = [NSPredicate predicateWithFormat:@"name == $NAME"];

    for (NSString *name in names) {
        NSPredicate *p = [namep predicateWithSubstitutionVariables:[NSDictionary dictionaryWithObjectsAndKeys:name, @"NAME", nil]];
        NSArray *matches = [heroes filteredArrayUsingPredicate:p];

        if (![matches count]) {
            [hero setName:name];
            break;
        }
    }

    /* Simulate waiting for slow network download. */
    [NSThread sleepForTimeInterval:0.5];

    [self saveThreadedContext];
}

@end
