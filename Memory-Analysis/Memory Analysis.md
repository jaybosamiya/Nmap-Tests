Zenmap Memory Analysis
======================

Patch is on the [dev list](http://seclists.org/nmap-dev/2014/q2/429)

Code used to test for peak memory usage is
```
function peak_memory_usage {
  /usr/bin/time -v "$@" 2>&1 | awk '/Maximum resident set size \(kbytes\): /{print $6 " kbytes"}' | tee /dev/tty | xclip -selection clipboard
}
```

Note: The `softlimit -a` based limits are **extremely** restrictive and barely allow enough functionality. In a more real world scenario, the limit will most definitely be much larger (and scans will cause problem only if they are much larger than the ones used in this analysis). Small scans with restrictive limits have been used only to conduct a fast study. For a more real-world-similar study, a much longer time period would be required.


Running Scans
-------------


Raw Statistics:

+ When using direct code from SVN
	+ Upon opening     - 	39492 kbytes
	+ Upon running [1] -	47012 kbytes
	+ Upon running [2] - 	406296 kbytes
	+ Upon running [3] -	1470888 kbytes
+ When using the patched code (running zenmap directly)
	+ Upon opening     - 	39584 kbytes
	+ Upon running [1] -	47044 kbytes
	+ Upon running [2] - 	417932 kbytes
	+ Upon running [3] -	1474404 kbytes
+ When using the patched code (running zenmap using `softlimit -a 800000000`)
	+ Upon opening     - 	41628 kbytes
	+ Upon running [1] -	46996 kbytes
	+ Upon running [2] - 	128900 kbytes
	+ Upon running [3] -	125696 kbytes
+ When using the patched code (running zenmap using `softlimit -a 1000000000`)
	+ Upon opening     - 	39496 kbytes
	+ Upon running [1] -	47012 kbytes
	+ Upon running [2] - 	270988 kbytes
	+ Upon running [3] -	273240 kbytes


Normalizing by taking "just opened" as 0 kbytes:

+ When using direct code from SVN
	+ Upon opening     - 	0 kbytes
	+ Upon running [1] -	7520 kbytes
	+ Upon running [2] - 	366804 kbytes
	+ Upon running [3] -	1431396 kbytes
+ When using the patched code (running zenmap directly)
	+ Upon opening     - 	0 kbytes
	+ Upon running [1] -	7460 kbytes
	+ Upon running [2] - 	378348 kbytes
	+ Upon running [3] -	1434820 kbytes
+ When using the patched code (running zenmap using `softlimit -a 800000000`)
	+ Upon opening     - 	0 kbytes
	+ Upon running [1] -	5368 kbytes
	+ Upon running [2] - 	87272 kbytes
	+ Upon running [3] -	84068 kbytes
+ When using the patched code (running zenmap using `softlimit -a 1000000000`)
	+ Upon opening     - 	0 kbytes
	+ Upon running [1] -	7516 kbytes
	+ Upon running [2] - 	231492 kbytes
	+ Upon running [3] -	233744 kbytes


Scans List
----------

+ [1] `nmap -r --top-ports 1000 127.0.0.1/24`
+ [2] `nmap --packet-trace -r --top-ports 1000 127.0.0.1/24`
+ [3] `nmap --packet-trace -r --top-ports 4000 127.0.0.1/24`



Opening Scans
-------------

Script
```
function give_stats {
  echo -n "    + Upon opening - "; peak_memory_usage $@ && for i in *.xml; do echo -n "    + $i - "; peak_memory_usage $@ -f "$i"; done
}
```

Raw Statistics:

+ When using direct code from SVN
    + Upon opening   - 41564 kbytes
    + a_stripped.xml - 44556 kbytes
    + a.xml          - 44964 kbytes
    + b_stripped.xml - 44392 kbytes
    + b.xml          - 230672 kbytes
    + c_stripped.xml - 47584 kbytes
    + c.xml          - 727700 kbytes
+ When using the patched code (running zenmap directly)
    + Upon opening   - 39228 kbytes
    + a_stripped.xml - 44504 kbytes
    + a.xml          - 45020 kbytes
    + b_stripped.xml - 44392 kbytes
    + b.xml          - 230788 kbytes
    + c_stripped.xml - 45420 kbytes
    + c.xml          - 727968 kbytes
+ When using the patched code (running zenmap using `softlimit -a 800000000`)
    + Upon opening   - 39552 kbytes
    + a_stripped.xml - 44492 kbytes
    + a.xml          - 44936 kbytes
    + b_stripped.xml - 44396 kbytes
    + b.xml          - 127148 kbytes
    + c_stripped.xml - 45420 kbytes
    + c.xml          - 72872 kbytes
+ When using the patched code (running zenmap using `softlimit -a 1000000000`)
    + Upon opening   - 39588 kbytes
    + a_stripped.xml - 46544 kbytes
    + a.xml          - 44972 kbytes
    + b_stripped.xml - 44504 kbytes
    + b.xml          - 230988 kbytes
    + c_stripped.xml - 45524 kbytes
    + c.xml          - 282656 kbytes


Normalizing by taking "just opened" as 0 kbytes:

+ When using direct code from SVN
    + Upon opening   - 0 kbytes
    + a_stripped.xml - 2992 kbytes
    + a.xml          - 3400 kbytes
    + b_stripped.xml - 2828 kbytes
    + b.xml          - 189108 kbytes
    + c_stripped.xml - 6020 kbytes
    + c.xml          - 686136 kbytes
+ When using the patched code (running zenmap directly)
    + Upon opening   - 0 kbytes
    + a_stripped.xml - 5276 kbytes
    + a.xml          - 5792 kbytes
    + b_stripped.xml - 5164 kbytes
    + b.xml          - 191560 kbytes
    + c_stripped.xml - 6192 kbytes
    + c.xml          - 688740 kbytes
+ When using the patched code (running zenmap using `softlimit -a 800000000`)
    + Upon opening   - 0 kbytes
    + a_stripped.xml - 4940 kbytes
    + a.xml          - 5384 kbytes
    + b_stripped.xml - 4844 kbytes
    + b.xml          - 87596 kbytes
    + c_stripped.xml - 5868 kbytes
    + c.xml          - 33320 kbytes
+ When using the patched code (running zenmap using `softlimit -a 1000000000`)
    + Upon opening   - 0 kbytes
    + a_stripped.xml - 6956 kbytes
    + a.xml          - 5384 kbytes
    + b_stripped.xml - 4916 kbytes
    + b.xml          - 191400 kbytes
    + c_stripped.xml - 5936 kbytes
    + c.xml          - 243068 kbytes


Description of XML files
------------------------

+ a.xml - XML file generated using [1] - 236.1 kB
+ a_stripped.xml - XML file generating by removing `<output>` tag from a.xml - 193.2 kB
+ b.xml - XML file generated using [2] - 21.6 MB
+ b_stripped.xml - XML file generating by removing `<output>` tag from b.xml - 193.2 kB
+ c.xml - XML file generated using [3] - 85.8 MB
+ c_stripped.xml - XML file generating by removing `<output>` tag from c.xml - 246.1 kB
