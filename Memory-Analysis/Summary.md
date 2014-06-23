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

