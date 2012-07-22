README






This project is using ARC.




Goal
----

Primary goal of this wrapper library is *reducing complexity* by following Objective-C conventions.
To archive this goal, these policies are set.

-	Use Objective-C/Cocoa types rather than C types unless exact type matching is required to guarantee integrity by default.
	For example, `NSInteger`/`NSUInteger` for integer types.
-	Offer alternative method with C types.




Limits and Behaviors
--------------------
SQLite3 can store only these types.

-	NULL
-	64-bit signed integer.
-	64-bit IEEE floating-point numbers. (`double`)
-	Binary chunks. (BLOB/Text)

If you try to store value out of range, the result is undefined.
It's your responsibility guaranteeing all values are in the valid range.
Check all you values before passing them into SQLite3.






Type for numeric value accessing API
------------------------------------
According to [SQLite3 manual](http://www.sqlite.org/datatype3.html),
all integers are 8-byte signed integer in memory. And variable size
in disk, but the size of storage size is not deterministic. So I just
treat all integers are just 8-byte signed integer.

But actually, SQLite3 API defines general type for integer
acessing functions as `int` or `long long`. This means it allows
possibility the value passing to API can be bigger than 8-byte.
And that means, it will handle it itself.

Combining two facts, I could get conclusion that exact behavior for
integer out of 8-byte number is *not defined*. So I just decided 
to follow that rule. Result for any number out of 8-byte signed 
integer range is not defined also in this library. I don't know what
will be happen. Overflow, underflow, truncation, exception or 
anything. Make it sure that you are storing only valid values.

This library won't check anything and will just pass values as is to
SQLite3.
	
For example, this library offer accessing method typed as `long long`
and this type can be 16-byte in some system. in that case, users 
should make specially care to keep thier values are within valid range.

Regular systems for Objective-C such as Mac OS X or iOS are all uses
uses `long long` as 8-byte signed integer. So in that case, you don't
need to worry. Anyway you have to keep these facts in mind. Always 
define policy for limits.


*	For reference, I attach a link describes undeterministic behavior
	for invalid values.
	http://jakegoulding.com/blog/2011/02/06/sqlite-64-bit-integers/