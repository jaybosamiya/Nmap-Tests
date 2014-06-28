Zenmap Memory Analysis
======================

This is a summarizing analysis of the statistics [here](https://github.com/jaybosamiya/Nmap-Tests/blob/master/Memory-Analysis/Statistics.md).

+ For running small scans, the patch does not significantly alter memory usage.
+ **For running larger scans (which should trigger MemoryError otherwise), the patch limits the memory usage and Zenmap continues to run instead of crashing.**

+ For opening scans without output (i.e. without the `<output>` tag - similar to that generated using `-oX` from Nmap), the patch does not significantly alter memory usage.
+ For opening scans with small output, the patch does not significantly alter memory usage
+ For opening scans with large output
  + If there is enough memory available, there is not much difference in memory usage.
  + If there is not enough memory available, Zenmap crashes with a "GLib-ERROR (recursed) **: (NULL) messageAborted" message shown in terminal. However, I think that this is mainly because I am opening files in a very restrictive environment (and also because I am using files that were created in a not-so-restrictive environment).

Concerning the saving of scans in a restrictive environment, trying to save a scan which is already showing the error message causes a crash with "GLib (gthread-posix.c): Unexpected error from C library during 'malloc': Cannot allocate memory.  Aborting."
However, this occurs **only** for scans which already have the error message shown that says "some features might not work as expected". All remaining scans work and save as expected.

To test whether this is caused by the restrictive environment or by the patch, the method used was to put a `raise MemoryError` just after the `try:` in every try-catch block the patch introduced and then try saving the scans. Each time, the scans saved properly showing that the GLib error was caused by the environment and not the patch itself.

Regarding the relation of size of Nmap's output to memory usage:
There seems to be a **(roughly) linear relationship** between memory used and size of the `<output>` in the XML. 
![equation](http://i57.tinypic.com/j5ckdc.png "(MemoryUsage(X.xml)-MemoryUsage(X_stripped.xml))/(SizeOf(X.xml)-SizeOf(X_stripped.xml))") is approximately 8 for X = a,b,c. This is true whenever there is no error message shown on screen (i.e. in a non-restrictive environment).

However, the memory usage while running the scans seems to be a bigger problem that should be handled. The memory usage is approximately 16 times the output generated.
