//
//  UpdateOperation.m
//  CoreDataEvents
//
//  Created by James Abley on 22/07/2010.
//  Copyright 2010 Mobile IQ Ltd. All rights reserved.
//

#import "UpdateOperation.h"
#import "Hero.h"

@implementation UpdateOperation

#pragma mark -
#pragma mark NSOperation
- (void)main {
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];

    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Hero" inManagedObjectContext:[self threadedContext]];
    [fetchRequest setEntity:entity];

    NSError *error = nil;
    NSArray *heroes = [[self threadedContext] executeFetchRequest:fetchRequest error:&error];

    if (!heroes) {
        NSLog(@"%@:%@ error retrieving heroes %@, %@", self, NSStringFromSelector(_cmd), error, [error userInfo]);
        abort();
    }

    if ([heroes count]) {
        NSInteger index = rand() % [heroes count];

        Hero *toBeUpdated = [heroes objectAtIndex:index];
        [toBeUpdated setName:[NSString stringWithFormat:@"%@ - updated!", [toBeUpdated name]]];
    }

    [NSThread sleepForTimeInterval:0.5];

    [self saveThreadedContext];
}

@end
