ISSUES
======






2013/05/24, Eonil; Remove most error-patterns, replaced them with exceptions.
-----------------------------------------------------------------------------
Currently library API is using too many error-patterns which are mostly inappropriate.
Replace them to exception-pattern. For example, wrong use of API should be an exception,
because it cannot be recoverable.

Fixed. All meaningless error-patterns are removed. API is not compatible to legacy anymore.




2012/12/21, Eonil; Should I make `EESQLiteStatement` to retain `EESQLiteDatabase` object?
-----------------------------------------------------------------------------------------
Currently, statement object doesn't retain database object, but SQLite3 actually
does it. It forces the DB object to be alive until all the statement objects are dead
by error.

I expect I will update statement object to retain database object.

