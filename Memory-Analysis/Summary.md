Zenmap Memory Analysis Summary
==============================

The complete analysis is [here](https://github.com/jaybosamiya/Nmap-Tests/blob/master/Memory-Analysis/Memory%20Analysis.md).

Note: All numbers below are in _kbytes_.

Running Scans
-------------

Raw statistics:

| Test        | Direct code from SVN | Patched code (directly run) | Patched code (run using `softlimit -a 800000000`) | Patched code (run using `softlimit -a 1000000000`) |
|:------------|---------------------:|----------------------------:|--------------------------------------------------:|---------------------------------------------------:|
| Opening     | 39492                | 39584                       | 41628                                             | 39496                                              |
| Running [1] | 47012                | 47044                       | 46996                                             | 47012                                              |
| Running [2] | 406296               | 417932                      | 128900                                            | 270988                                             |
| Running [3] | 1470888              | 1474404                     | 125696                                            | 273240                                             |

Normalizing by taking "just opened as 0 _kbytes_:

| Test        | Direct code from SVN | Patched code (directly run) | Patched code (run using `softlimit -a 800000000`) | Patched code (run using `softlimit -a 1000000000`) |
|:------------|---------------------:|----------------------------:|--------------------------------------------------:|---------------------------------------------------:|
| Opening     | 0                    | 0                           | 0                                                 | 0                                                  |
| Running [1] | 7520                 | 7460                        | 5368                                              | 7516                                               |
| Running [2] | 366804               | 378348                      | 87272                                             | 231492                                             |
| Running [3] | 1431396              | 1434820                     | 84068                                             | 233744                                             |


Scans list:

+ [1] `nmap -r --top-ports 1000 127.0.0.1/24`
+ [2] `nmap --packet-trace -r --top-ports 1000 127.0.0.1/24`
+ [3] `nmap --packet-trace -r --top-ports 4000 127.0.0.1/24`




Opening Scans
-------------

Raw Statistics:

| Test           | Direct code from SVN | Patched code (directly run) | Patched code (run using `softlimit -a 800000000`) | Patched code (run using `softlimit -a 1000000000`) |
|:---------------|---------------------:|----------------------------:|--------------------------------------------------:|---------------------------------------------------:|
| Opening        | 41564                | 39228                       | 39552                                             | 39588                                              |
| a_stripped.xml | 44556                | 44504                       | 44492                                             | 46544                                              |
| a.xml          | 44964                | 45020                       | 44936                                             | 44972                                              |
| b_stripped.xml | 44392                | 44392                       | 44396                                             | 44504                                              |
| b.xml          | 230672               | 230788                      | 127148                                            | 230988                                             |
| c_stripped.xml | 47584                | 45420                       | 45420                                             | 45524                                              |
| c.xml          | 727700               | 727968                      | 72872                                             | 282656                                             |

Normalizing by taking "just opened" as 0 kbytes:

| Test           | Direct code from SVN | Patched code (directly run) | Patched code (run using `softlimit -a 800000000`) | Patched code (run using `softlimit -a 1000000000`) |
|:---------------|---------------------:|----------------------------:|--------------------------------------------------:|---------------------------------------------------:|
| Opening        | 0                    | 0                           | 0                                                 | 0                                                  |
| a_stripped.xml | 2992                 | 5276                        | 4940                                              | 6956                                               |
| a.xml          | 3400                 | 5792                        | 5384                                              | 5384                                               |
| b_stripped.xml | 2828                 | 5164                        | 4844                                              | 4916                                               |
| b.xml          | 189108               | 191560                      | 87596                                             | 191400                                             |
| c_stripped.xml | 6020                 | 6192                        | 5868                                              | 5936                                               |
| c.xml          | 686136               | 688740                      | 33320                                             | 243068                                             |


Description of XML files:

+ a.xml - XML file generated using [1] - 236.1 kB
+ a_stripped.xml - XML file generating by removing `<output>` tag from a.xml - 193.2 kB
+ b.xml - XML file generated using [2] - 21.6 MB
+ b_stripped.xml - XML file generating by removing `<output>` tag from b.xml - 193.2 kB
+ c.xml - XML file generated using [3] - 85.8 MB
+ c_stripped.xml - XML file generating by removing `<output>` tag from c.xml - 246.1 kB
