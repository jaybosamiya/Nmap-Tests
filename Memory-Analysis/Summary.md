Zenmap Memory Analysis Summary
==============================

This is a summarizing analysis of the statistics [here](https://github.com/jaybosamiya/Nmap-Tests/blob/master/Memory-Analysis/Memory%20Analysis.md).

+ For running small scans, the patch does not significantly alter memory usage.
+ For running larger scans (which should trigger MemoryError otherwise), the patch limits the memory usage and Zenmap continues to run instead of crashing.

+ For opening scans without output (i.e. without the `<output>` tag - similar to that generated using `-oX` from Nmap), the patch does not significantly alter memory usage.
+ For opening scans with small output, the patch does not significantly alter memory usage
+ For opening scans with large output
  + If there is enough memory available, there is not much difference in memory usage.
  + If there is not enough memory available, Zenmap crashes with a "GLib-ERROR (recursed) **: (NULL) messageAborted" message shown in terminal. However, I think that this is mainly because I am opening files in a very restrictive environment (and also because I am using files that were created in a not-so-restrictive environment).

Concerning the saving of scans in a restrictive environment, trying to save a scan which is already showing the error message causes a crash with "GLib (gthread-posix.c): Unexpected error from C library during 'malloc': Cannot allocate memory.  Aborting."
However, this occurs **only** for scans which already have the error message shown that says "some features might not work as expected". All remaining scans work and save as expected.
As for this, I think that a minor change might be necessary in the code that saves scans. I will work on this.

Regarding the relation of size of output to memory usage:
There seems to be a (roughly) linear relationship between memory used and size of the `<output>` in the XML. 
![equation](http://www.sciweavers.org/tex2img.php?eq=%20%5Cfrac%7BMemoryUsed%28X.xml%29-MemoryUsed%28X%5C_stripped.xml%29%7D%7BSizeOf%28X.xml%29-SizeOf%28X%5C_stripped.xml%29%7D%20&bc=White&fc=Black&im=jpg&fs=12&ff=arev&edit=0) is approximately 8 for X = a,b,c. This is true whenever there is no error message shown on screen (i.e. in a non-restrictive environment).
