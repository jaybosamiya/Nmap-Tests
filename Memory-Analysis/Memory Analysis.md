Zenmap Memory Analysis
======================

Patch is on the [dev list](http://seclists.org/nmap-dev/2014/q2/429)

Code used to test for peak memory usage is
```bash
function peak_memory_usage {
  /usr/bin/time -v "$@" 2>&1 | awk '/Maximum resident set size \(kbytes\): /{print $6 " kbytes"}' | tee /dev/tty | xclip -selection clipboard
}
```

Note: The `softlimit -a` based limits are **extremely** restrictive and barely allow enough functionality. In a more real world scenario, the limit will most definitely be much larger (and scans will cause problem only if they are much larger than the ones used in this analysis). Small scans with restrictive limits have been used only to conduct a fast study. For a more real-world-similar study, a much longer time period would be required.

Note: Opening scans larger than Zenmap can handle is a **very uncommon** scenario since Zenmap needs to create these XMLs first (and how could it make them if it cannot read them, eh?). Hence, the opening of b.xml and c.xml under `softlimit -a` should be taken with a pinch of salt.

Note: All numbers below are in _kbytes_.

Running Scans
-------------

Raw statistics:

| Test        | Direct code from SVN | Patched code (directly run) | Patched code (run using `softlimit -a 800000000`) | Patched code (run using `softlimit -a 1000000000`) |
|:------------|---------------------:|----------------------------:|--------------------------------------------------:|---------------------------------------------------:|
| Opening     | 39,492               | 39,584                      | 41,628                                            | 39,496                                             |
| Running [1] | 47,012               | 47,044                      | 46,996                                            | 47,012                                             |
| Running [2] | 406,296              | 417,932                     | 128,900                                           | 270,988                                            |
| Running [3] | 1,470,888            | 1,474,404                   | 125,696                                           | 273,240                                            |

Normalizing by taking "just opened as 0 _kbytes_:

| Test        | Direct code from SVN | Patched code (directly run) | Patched code (run using `softlimit -a 800000000`) | Patched code (run using `softlimit -a 1000000000`) |
|:------------|---------------------:|----------------------------:|--------------------------------------------------:|---------------------------------------------------:|
| Opening     | 0                    | 0                           | 0                                                 | 0                                                  |
| Running [1] | 7,520                | 7,460                       | 5,368                                             | 7,516                                              |
| Running [2] | 366,804              | 378,348                     | 87,272                                            | 231,492                                            |
| Running [3] | 1,431,396            | 1,434,820                   | 84,068                                            | 233,744                                            |


Scans list:

+ [1] `nmap -r --top-ports 1000 127.0.0.1/24`
+ [2] `nmap --packet-trace -r --top-ports 1000 127.0.0.1/24`
+ [3] `nmap --packet-trace -r --top-ports 4000 127.0.0.1/24`




Opening Scans
-------------

Raw Statistics:

| Test           | Direct code from SVN | Patched code (directly run) | Patched code (run using `softlimit -a 800000000`) | Patched code (run using `softlimit -a 1000000000`) |
|:---------------|---------------------:|----------------------------:|--------------------------------------------------:|---------------------------------------------------:|
| Opening        | 41,564               | 39,228                      | 39,552                                            | 39,588                                             |
| a.xml          | 44,964               | 45,020                      | 44,936                                            | 44,972                                             |
| b.xml          | 230,672              | 230,788                     | 127,148                                           | 230,988                                            |
| c.xml          | 727,700              | 727,968                     | 72,872                                            | 282,656                                            |
| a_stripped.xml | 44,556               | 44,504                      | 44,492                                            | 46,544                                             |
| b_stripped.xml | 44,392               | 44,392                      | 44,396                                            | 44,504                                             |
| c_stripped.xml | 47,584               | 45,420                      | 45,420                                            | 45,524                                             |

Normalizing by taking "just opened" as 0 kbytes:

| Test           | Direct code from SVN | Patched code (directly run) | Patched code (run using `softlimit -a 800000000`) | Patched code (run using `softlimit -a 1000000000`) |
|:---------------|---------------------:|----------------------------:|--------------------------------------------------:|---------------------------------------------------:|
| Opening        | 0                    | 0                           | 0                                                 | 0                                                  |
| a.xml          | 3,400                | 5,792                       | 5,384                                             | 5,384                                              |
| b.xml          | 189,108              | 191,560                     | 87,596                                            | 191,400                                            |
| c.xml          | 686,136              | 688,740                     | 33,320                                            | 243,068                                            |
| a_stripped.xml | 2,992                | 5,276                       | 4,940                                             | 6,956                                              |
| b_stripped.xml | 2,828                | 5,164                       | 4,844                                             | 4,916                                              |
| c_stripped.xml | 6,020                | 6,192                       | 5,868                                             | 5,936                                              |

Description of XML files:

+ a.xml - XML file generated using [1] - 236.1 kB
+ b.xml - XML file generated using [2] - 21.6 MB
+ c.xml - XML file generated using [3] - 85.8 MB
+ a_stripped.xml - XML file generating by removing `<output>` tag from a.xml - 193.2 kB
+ b_stripped.xml - XML file generating by removing `<output>` tag from b.xml - 193.2 kB
+ c_stripped.xml - XML file generating by removing `<output>` tag from c.xml - 246.1 kB
