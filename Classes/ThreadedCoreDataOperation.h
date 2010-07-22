//
//  ThreadedCoreDataOperation.h
//  CoreDataEvents
//
//  Created by James Abley on 22/07/2010.
//  Copyright 2010 Mobile IQ Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 NSOperation for doing Core Data work on a background thread.
 */
@interface ThreadedCoreDataOperation : NSOperation {

    NSManagedObjectContext *mainContext_;

    NSManagedObjectContext *threadedContext_;

}

/**
 This is the NSManagedObjectContext intended to be used by
 instances of this class for reading and writing to Core Data.
 */
@property (nonatomic, readonly, retain) NSManagedObjectContext *threadedContext;

/**
 Returns the NSManagedObjectContext from the main thread that any updates should be merged into.
 */
@property (nonatomic, retain, readonly) NSManagedObjectContext * mainContext;

/**
 Saves the threaded context, merging the changes into the main context.
 */
- (void)saveThreadedContext;

/**
 Returns a non-nil MIQCoreDataOperation which will merge any changes that this NSOperation makes into the specified
 NSManagedObjectContext.
 @param moc - non-nil NSManagedObjectContext into which any changes will be merged
 */
- (id)initWithManagedObjectContext:(NSManagedObjectContext*)mainContext;

@end
