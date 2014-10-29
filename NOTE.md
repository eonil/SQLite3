NOTE
====




On Design
---------

-	Acepting error handler as an extra input parameter is not a good idea.
	It needs a mutable state update to check the error, and requires tracking
	of separated execution context. Instead, this library returns error enum
	information for features require returning errors. Note that there's no
	result on error situation, so it returns an enum. Implementation is 
	`Error<E,V>` enum.