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

-	Mid-Level means exposing SQLite3 features as is. 

-	High-Level means extra abstraction for best convenience.