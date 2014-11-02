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





Layers
------

-	Low-Level means C-interop layer. No logics or abstractions, just handles
	interfacing and type conversions.

-	Mid-Level means exposing SQLite3 features as is. Query builder is provided
	for your convenience. Low level is fully hidden.

-	High-Level means extra abstraction for best convenience. Instead, this is
	very limited in features. Mid/low levels are fully hidden not to break 
	abstraction.

You can choose any level what you want to use, but you can't mix them. Once 
established connection to a database file can be manipulated using only with 
the type of the connection.