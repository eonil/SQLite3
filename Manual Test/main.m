//
//  main.m
//  Manual Test
//
//  Created by Hoon Hwangbo on 8/11/12.
//  Copyright (c) 2012 Eonil Company. All rights reserved.
//



int main(int argc, char *argv[])
{
	@autoreleasepool
	{
		NSMutableArray*	classNames	=	[NSMutableArray array];
		{
			unsigned int				CC;
			__unsafe_unretained	Class*	classes	=	objc_copyClassList(&CC);
			
			for (NSUInteger I=0; I<CC; I++)
			{
				Class		C			=	classes[I];
				NSString*	className	=	NSStringFromClass(C);
				
				while (C != Nil)
				{
					C	=	class_getSuperclass(C);
					
					if ([NSStringFromClass(C) isEqualToString:@"UnitTestContainer"])
					{
						[classNames addObject:className];
						break;
					}
				}
			}
			free(classes);
		}
		[classNames sortUsingComparator:^NSComparisonResult(id obj1, id obj2)
		 {
			 NSString*	str1	=	obj1;
			 NSString*	str2	=	obj2;
			 
			 return	[str1 compare:str2];
		 }];
		NSLog(@"Extracted test containers...\n%@", classNames);
		
		
		
		
		
		NSUInteger	CC2	=	[classNames count];
		for (NSUInteger I=0l; I<CC2; I++)
		{
			@autoreleasepool
			{
				NSString*	className	=	[classNames objectAtIndex:I];
				Class		class		=	NSClassFromString(className);
				
				NSMutableArray*	methodNames	=	[NSMutableArray array];
				{
					unsigned int	MC;
					Method*			methods	=	class_copyMethodList(class, &MC);
					
					for (NSUInteger J=0; J<MC; J++)
					{
						SEL			methodSel	=	method_getName(methods[J]);
						NSString*	methodName	=	NSStringFromSelector(methodSel);
						
						if ([methodName hasPrefix:@"test"] && ![methodName hasSuffix:@":"])
						{
							[methodNames addObject:methodName];
						}
					}
					free(methods);
				}
				[methodNames sortUsingComparator:^NSComparisonResult(id obj1, id obj2)
				 {
					 NSString*	str1	=	obj1;
					 NSString*	str2	=	obj2;
					 
					 return	[str1 compare:str2];
				 }];
				NSLog(@"Extracted test entries in container *%@*...\n%@", className, methodNames);
				
				
				
				
				
				id	test	=	[[class alloc] init];
				
				{
					NSUInteger	MC2	=	[methodNames count];
					for (NSUInteger J=0; J<MC2; J++)
					{
						NSString*	methodName	=	[methodNames objectAtIndex:J];
						SEL			methodSel	=	NSSelectorFromString(methodName);
						
						NSLog(@"test -[%@ %@]... starting.", className, methodName);
						@autoreleasepool
						{
							objc_msgSend(test, methodSel);
						}
						NSLog(@"test -[%@ %@]...finished.", className, methodName);
					}
				}
			}
		}
		NSLog(@"%@", @"All test finished.");
	}
}
