//
//  EESQLiteDatabase+Internal.h
//  EonilCocoaComplements-SQLite
//
//  Created by Hoon Hwangbo on 1/22/12.
//  Copyright (c) 2012 Eonil Company. All rights reserved.
//

#import				<Foundation/Foundation.h>
#import				<sqlite3.h>
#import				"EESQLiteError.h"

inline
extern
sqlite3*
EESQLiteDatabaseGetCorePointerToSQLite3(EESQLiteDatabase* self);



//	Returns YES if the identifier name is valid and has no error. NO for otherwise. An error will be set if NO returned.
inline
static
BOOL
EESQLiteCheckValidityOfIdentifierName(NSString* identifierName, NSError** error)
{
	if (![EESQLiteDatabase isValidIdentifierString:identifierName])
	{
		if (error != NULL)
		{
			*error	=	EESQLiteInputArgumentErrorHasInvalidCharactersForIdentifierNames();
		}
		return	NO;
	}
	else
	{
		return	YES;
	}
}
