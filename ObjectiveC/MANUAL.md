MANUAL
======
Hoon Hwagbo
2013/01/02
2012/12/21










Goal
----

Primary goal of this library is *reducing things to care* by offering classes following Objective-C conventions.
To archive this goal, these policies are set.

-	Use Objective-C/Cocoa types rather than C types unless exact type matching is required to guarantee integrity by default.
	For example, `NSInteger`/`NSUInteger` for integer types.
-	Offer alternative method with C types.




Limitations and Behaviors
-------------------------
This project uses ARC. There is no consideration of non-ARC code.
As far as I know, compiled binary should work with non-ARC code, but actually no test has been done for that.

SQLite3 can store only these types.

-	NULL
-	64-bit signed integer.
-	64-bit IEEE floating-point numbers. (`double` in C type)
-	Binary chunks. (BLOB/Text)

If you try to store value out of range, the result is undefined.
It's your responsibility guaranteeing all values are in the valid range.
Check all your values before passing them into this library.
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

BY Combining two facts, I could derive conclusion that exact behavior for
numbers larger then 8-byte signed integer is *not defined*. 

This library decided to limit value range strictly into 64-bit
signed integer range. Anyway this check is enabled only in debug mode, then
it is possible to overflow/underflow in release mode. If you want to ensure
the integer numeric limit, then you need to check it yourself.

For example, this library offers accessing method typed as `long long`
. This type *MAY* be 16-byte in some systems. In that case, this library in
debug mode will check 64-bit signed integer range, and will crash if the 
value is out of range. But, in debug mode, this check will be removed, and
you should make special care to keep thier values are within valid range.

Typical systems for Objective-C such as Mac OS X or iOS are all use
`long long` as 8-byte signed integer. So in that case, you don't need
to care anything. Anyway you have to keep these facts in mind. Always 
have some policies for the limits.

*	Just only for later reference, I attach a link which describes 
	undeterministic behavior for values in invalid range.
	http://jakegoulding.com/blog/2011/02/06/sqlite-64-bit-integers/
	
	
	







Build
-----
To build in debug mode, make sure that you set `EESQLITE_DEBUG_MODE=1` flag.












Future Roadmap
--------------

If I can make more time, I will add database duplication feature using 
online-backup API. So it will allow me to copy in-memory database object
on-the-fly.












License
-------
This libray is licensed under MIT license.


