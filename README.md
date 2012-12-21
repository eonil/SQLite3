Eonil's SQLite3 wrapper library
===============================
Hoon Hwangbo
2012/10/04


`EonilSQLite` is an Objective-C library which wraps C-level SQLite3 database engine library.
This library offers these features.

-	Reducing complexity of using C level functions directly.
-	Offers simple and object-oriented data handling. (handling data using `NSValue`, `NSDictionary` and `NSArray`)




Limitation
----------
This project uses ARC. There is no consideration of non-ARC code.
As far as I know, it should work with non-ARC code, but actually no test has been done for that.







Goal
----

Primary goal of this library is *reducing things to remember* by offering classes following Objective-C conventions.
To archive this goal, these policies are set.

-	Use Objective-C/Cocoa types rather than C types unless exact type matching is required to guarantee integrity by default.
	For example, `NSInteger`/`NSUInteger` for integer types.
-	Offer alternative method with C types.






Limits and Behaviors
--------------------
SQLite3 can store only these types.

-	NULL
-	64-bit signed integer.
-	64-bit IEEE floating-point numbers. (`double` in C type)
-	Binary chunks. (BLOB/Text)

If you try to store value out of range, the result is undefined.
It's your responsibility guaranteeing all values are in the valid range.
Check all you values before passing them into this library.
I describe about this a little more in next chapter.




C Integral Type Size Issue
--------------------------
According to [SQLite3 manual](http://www.sqlite.org/datatype3.html),
all integers are 8-byte signed integer in memory. And variable size
in disk, but the size in storage is not deterministic. So I just
treat all integers are just 8-byte signed integer.

But actually, SQLite3 API functions use just `int` or `long long` type
for numeric passing-in arguments. By the C specification, size of these
types are not guaranteed within 8-byte. So actually SQLite allows
passing-in values to be larger than 8-byte.

Combining two facts, I could make conclusion that exact behavior for
numbers larger then 8-byte signed integer is *not defined*. So I just 
decided to follow that rule. Result for any numbers larger than 8-byte 
signed integer range is not defined in this library too. This library 
won't check anything, and just passes the values as is to SQLite3 engine. 
I don't know what will be happen too. Overflow, underflow, truncation, 
exception or anything. So, make it sure that you will store only values 
in valid range.
	
For example, this library offers accessing method typed as `long long`
. This type *MAY* be 16-byte in some system. In that case, users
should make special care to keep thier values are within valid range.

Trivial systems for Objective-C such as Mac OS X or iOS are all uses
`long long` as 8-byte signed integer. So in that case, you don't need 
to care anything. Anyway you have to keep these facts in mind. Always 
have some policies for limits.

*	Just only for later reference, I attach a link which describes 
	undeterministic behavior for values in invalid range.
	http://jakegoulding.com/blog/2011/02/06/sqlite-64-bit-integers/
	
	
	
	
	

	
	
	
	
	
	
	
	
	
Future Roadmap
--------------

If I can make more time, I will add database duplication feature using online-backup API.

	

