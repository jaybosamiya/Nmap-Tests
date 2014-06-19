#! /bin/sh

usage(){
  echo "Usage:" 1>&2
  echo "  sudo $0 <host-list> [show each test command? y/n] [nmap directory path]" 1>&2
  echo "Suggested Usage:" 1>&2
  echo "  sudo $0 \"multiple space separated hosts\" n \"path to nmap directory\" >/dev/null" 1>&2
  echo "  This will let you see more information only for tests that fail" 1>&2
  echo " Personally, I'd use" 1>&2
  echo "  (sudo $0 \"multiple space separated hosts\" n \"path to nmap directory\" >/dev/null) 2>&1 | less"
  exit 1
}

# Make sure only root can run the script
if [ "$(id -u)" != "0" ]; then
  echo "This script must be run as root" 1>&2
  usage
fi

# Display usage if needed
if [ -z "$1" -o "$1" = "--help" -o "$1" = "-help" -o "$1" = "-h" -o "$1" = "-?" ]; then
  usage
fi

# Handle whether scans should be shown or not
if [ -n "$2" -a "$2" != "y" -a "$2" != "n" ]; then
  echo "The only options for argument 2 are y,n"
  exit 1
fi
SHOW_SCANS="$2"

# Use a different nmap path if specified. Use preinstalled nmap and ndiff otherwise
if [ -n "$3" -a "$3" != "-" ]; then
  nmap="$3/nmap"
  ndiff="$3/ndiff/ndiff.py"
else
  nmap="nmap"
  ndiff="ndiff"
fi

# Test if Nmap is usable
$nmap $1 -p 1 -oX .test.xml >/dev/null 2>&1
if [ -e .test.xml ]; then
  rm .test.xml
else
  echo "Nmap not found at the location specified. Maybe you pointed to Nmap executable instead of the directory?" 1>&2
  exit 1
fi

# Test if Nmap has capabilities of --exclude-ports
$nmap $1 -p 1 --exclude-ports 1 -oX .test.xml >/dev/null 2>&1
if [ -e .test.xml ]; then
  rm .test.xml
else
  echo "Nmap does not have --exclude-ports support. Please point the nmap directory path to the directory where Nmap with --exclude-ports support is." 1>&2
  exit 1
fi

testUsingNdiff(){
  NDIFFRET=`$ndiff .a.xml .b.xml 2>&1`
  RETVALUE=`echo "$NDIFFRET" | awk 'NR>2'`
  if [ -z "$RETVALUE" ]; then
    echo Passed 1>&2
    if [ -n "$SHOW_SCANS" -a "$SHOW_SCANS" = "y" ]; then
      echo "$NDIFFRET" | awk 'NR<=2' 1>&2
    fi
  else
    echo Failed 1>&2
    echo "$NDIFFRET" 1>&2
    echo
  fi
}

echo 1>&2
echo 1>&2
echo Testing host discovery 1>&2
echo ====================== 1>&2
echo 1>&2
echo 1>&2
echo Unprivileged 1>&2
echo ============ 1>&2
echo 1>&2
echo After excluding ports 80,443 1>&2
echo ---------------------------- 1>&2
TEMPVAR="`$nmap $1 --reason --unprivileged -sn --exclude-ports 80,443 2>&1 | grep "WARNING: a TCP ping"`"
if [ -n "$TEMPVAR" ]; then
  echo Passed 1>&2
  echo "Relevant line: $TEMPVAR"
else
  echo Failed 1>&2
  echo "  Warning was not shown"
fi
echo 1>&2
echo Without excluding 80,443 1>&2
echo ------------------------ 1>&2
$nmap $1 --reason --unprivileged -sn -oX .a.xml 2>&1
$nmap $1 --reason --unprivileged -sn -PE -PS443 -PA80 -PP -oX .b.xml 2>&1
testUsingNdiff
rm .a.xml .b.xml
echo 1>&2
echo 1>&2
echo Privileged 1>&2
echo ========== 1>&2
echo 1>&2
echo After excluding ports 80,443 1>&2
echo ---------------------------- 1>&2
sudo $nmap --privileged $1 --reason -sn -PE -PP -oX .a.xml 2>&1
sudo $nmap --privileged $1 --reason -sn --exclude-ports 80,443 -oX .b.xml 2>&1
testUsingNdiff
sudo rm .a.xml .b.xml
echo 1>&2
echo Without excluding 80,443 1>&2
echo ------------------------ 1>&2
sudo $nmap --privileged $1 --reason -sn -oX .a.xml 2>&1
sudo $nmap --privileged $1 --reason -sn -PE -PS443 -PA80 -PP -oX .b.xml 2>&1
testUsingNdiff
sudo rm .a.xml .b.xml
echo 1>&2
echo 1>&2

echo 1>&2
echo 1>&2
echo Testing port scans 1>&2
echo ================== 1>&2
echo 1>&2
echo 1>&2
echo Unprivileged 1>&2
echo ============ 1>&2
echo 1>&2
echo "Testing empty portlist type 1 (exclude exactly same port)" 1>&2
echo "---------------------------------------------------------" 1>&2
$nmap $1 --unprivileged -p U:1 -oX .a.xml 2>&1
$nmap $1 --unprivileged -p 10 --exclude-ports 10 -oX .b.xml 2>&1
testUsingNdiff
rm .a.xml .b.xml
echo 1>&2
echo "Testing empty portlist type 2 (exclude exactly same ports)" 1>&2
echo "----------------------------------------------------------" 1>&2
$nmap $1 --unprivileged -p U:1 -oX .a.xml 2>&1
$nmap $1 --unprivileged -p 10,20-30 --exclude-ports 20-30,10 -oX .b.xml 2>&1
testUsingNdiff
rm .a.xml .b.xml
echo 1>&2
echo "Testing empty portlist type 3 (exclude more ports than included)" 1>&2
echo "----------------------------------------------------------------" 1>&2
$nmap $1 --unprivileged -p U:1 -oX .a.xml 2>&1
$nmap $1 --unprivileged -p 10 --exclude-ports 1-100 -oX .b.xml 2>&1
testUsingNdiff
rm .a.xml .b.xml
echo 1>&2
echo "Testing partial portlist type 1 (exclude exactly same port)" 1>&2
echo "-----------------------------------------------------------" 1>&2
$nmap $1 --unprivileged -p 80 -oX .a.xml 2>&1
$nmap $1 --unprivileged -p 10,80 --exclude-ports 10 -oX .b.xml 2>&1
testUsingNdiff
rm .a.xml .b.xml
echo 1>&2
echo "Testing partial portlist type 2 (exclude exactly same ports)" 1>&2
echo "------------------------------------------------------------" 1>&2
$nmap $1 --unprivileged -p 80 -oX .a.xml 2>&1
$nmap $1 --unprivileged -p 10,20-30,80 --exclude-ports 20-30,10 -oX .b.xml 2>&1
testUsingNdiff
rm .a.xml .b.xml
echo 1>&2
echo "Testing partial portlist type 3 (exclude more ports than included)" 1>&2
echo "------------------------------------------------------------------" 1>&2
$nmap $1 --unprivileged -p 80 -oX .a.xml 2>&1
$nmap $1 --unprivileged -p 10,80 --exclude-ports 1-50 -oX .b.xml 2>&1
testUsingNdiff
rm .a.xml .b.xml
echo 1>&2
echo "Testing complete portlist type 1 (exclude different range)" 1>&2
echo "----------------------------------------------------------" 1>&2
$nmap $1 --unprivileged -p 10-20,80 -oX .a.xml 2>&1
$nmap $1 --unprivileged -p 10-20,80 --exclude-ports 1000-2000 -oX .b.xml 2>&1
testUsingNdiff
rm .a.xml .b.xml
echo 1>&2
echo "Testing complete portlist type 2 (exclude udp instead of tcp)" 1>&2
echo "-------------------------------------------------------------" 1>&2
$nmap $1 --unprivileged -p 10-20,80 -oX .a.xml 2>&1
$nmap $1 --unprivileged -p 10-20,80 --exclude-ports U:1-1000 -oX .b.xml 2>&1
testUsingNdiff
rm .a.xml .b.xml
echo 1>&2
echo 1>&2
echo Privileged 1>&2
echo ========== 1>&2
echo 1>&2
echo "Testing empty portlist type 1 (exclude exactly same port)" 1>&2
echo "---------------------------------------------------------" 1>&2
sudo $nmap --privileged $1 -p U:1 -oX .a.xml 2>&1
sudo $nmap --privileged $1 -p 10 --exclude-ports 10 -oX .b.xml 2>&1
testUsingNdiff
rm .a.xml .b.xml
echo 1>&2
echo "Testing empty portlist type 2 (exclude exactly same ports)" 1>&2
echo "----------------------------------------------------------" 1>&2
sudo $nmap --privileged $1 -p U:1 -oX .a.xml 2>&1
sudo $nmap --privileged $1 -p 10,20-30 --exclude-ports 20-30,10 -oX .b.xml 2>&1
testUsingNdiff
rm .a.xml .b.xml
echo 1>&2
echo "Testing empty portlist type 3 (exclude more ports than included)" 1>&2
echo "----------------------------------------------------------------" 1>&2
sudo $nmap --privileged $1 -p U:1 -oX .a.xml 2>&1
sudo $nmap --privileged $1 -p 10 --exclude-ports 1-100 -oX .b.xml 2>&1
testUsingNdiff
rm .a.xml .b.xml
echo 1>&2
echo "Testing partial portlist type 1 (exclude exactly same port)" 1>&2
echo "-----------------------------------------------------------" 1>&2
sudo $nmap --privileged $1 -p 80 -oX .a.xml 2>&1
sudo $nmap --privileged $1 -p 10,80 --exclude-ports 10 -oX .b.xml 2>&1
testUsingNdiff
rm .a.xml .b.xml
echo 1>&2
echo "Testing partial portlist type 2 (exclude exactly same ports)" 1>&2
echo "------------------------------------------------------------" 1>&2
sudo $nmap --privileged $1 -p 80 -oX .a.xml 2>&1
sudo $nmap --privileged $1 -p 10,20-30,80 --exclude-ports 20-30,10 -oX .b.xml 2>&1
testUsingNdiff
rm .a.xml .b.xml
echo 1>&2
echo "Testing partial portlist type 3 (exclude more ports than included)" 1>&2
echo "------------------------------------------------------------------" 1>&2
sudo $nmap --privileged $1 -p 80 -oX .a.xml 2>&1
sudo $nmap --privileged $1 -p 10,80 --exclude-ports 1-50 -oX .b.xml 2>&1
testUsingNdiff
rm .a.xml .b.xml
echo 1>&2
echo "Testing complete portlist type 1 (exclude different range)" 1>&2
echo "----------------------------------------------------------" 1>&2
sudo $nmap --privileged $1 -p 10-20,80 -oX .a.xml 2>&1
sudo $nmap --privileged $1 -p 10-20,80 --exclude-ports 1000-2000 -oX .b.xml 2>&1
testUsingNdiff
rm .a.xml .b.xml
echo 1>&2
echo "Testing complete portlist type 2 (exclude udp instead of tcp)" 1>&2
echo "-------------------------------------------------------------" 1>&2
sudo $nmap --privileged $1 -p 10-20,80 -oX .a.xml 2>&1
sudo $nmap --privileged $1 -p 10-20,80 --exclude-ports U:1-1000 -oX .b.xml 2>&1
testUsingNdiff
rm .a.xml .b.xml
echo 1>&2
echo 1>&2

echo 1>&2
echo 1>&2
echo Testing top-ports 1>&2
echo ================= 1>&2
echo 1>&2
echo 1>&2
echo Unprivileged 1>&2
echo ============ 1>&2
echo 1>&2
echo "Testing exclusion of non top ports" 1>&2
echo "----------------------------------" 1>&2
$nmap $1 --unprivileged --top-ports 2 -oX .a.xml 2>&1
$nmap $1 --unprivileged --top-ports 2 --exclude-ports 1313 -oX .b.xml 2>&1
testUsingNdiff
rm .a.xml .b.xml
echo 1>&2
echo "Testing exclusion of topmost port" 1>&2
echo "---------------------------------" 1>&2
$nmap $1 --unprivileged -p -79,81- --top-ports 2 -oX .a.xml 2>&1
$nmap $1 --unprivileged --top-ports 2 --exclude-ports 80 -oX .b.xml 2>&1
testUsingNdiff
rm .a.xml .b.xml
echo 1>&2
echo "Testing exclusion of a top-port which is not topmost" 1>&2
echo "----------------------------------------------------" 1>&2
$nmap $1 --unprivileged -p -22,24- --top-ports 2 -oX .a.xml 2>&1
$nmap $1 --unprivileged --top-ports 2 --exclude-ports 23 -oX .b.xml 2>&1
testUsingNdiff
rm .a.xml .b.xml
echo 1>&2
echo "Testing counts of top-ports" 1>&2
echo "---------------------------" 1>&2
$nmap $1 --unprivileged -p 23 -oX .a.xml 2>&1
$nmap $1 --unprivileged --top-ports 1 --exclude-ports 80 -oX .b.xml 2>&1
testUsingNdiff
rm .a.xml .b.xml
echo 1>&2
echo 1>&2
echo Privileged 1>&2
echo ========== 1>&2
echo 1>&2
echo "Testing exclusion of non top ports" 1>&2
echo "----------------------------------" 1>&2
sudo $nmap --privileged $1 --top-ports 2 -oX .a.xml 2>&1
sudo $nmap --privileged $1 --top-ports 2 --exclude-ports 1313 -oX .b.xml 2>&1
testUsingNdiff
rm .a.xml .b.xml
echo 1>&2
echo "Testing exclusion of topmost port" 1>&2
echo "---------------------------------" 1>&2
sudo $nmap --privileged $1 -p -79,81- --top-ports 2 -oX .a.xml 2>&1
sudo $nmap --privileged $1 --top-ports 2 --exclude-ports 80 -oX .b.xml 2>&1
testUsingNdiff
rm .a.xml .b.xml
echo 1>&2
echo "Testing exclusion of a top-port which is not topmost" 1>&2
echo "----------------------------------------------------" 1>&2
sudo $nmap --privileged $1 -p -22,24- --top-ports 2 -oX .a.xml 2>&1
sudo $nmap --privileged $1 --top-ports 2 --exclude-ports 23 -oX .b.xml 2>&1
testUsingNdiff
rm .a.xml .b.xml
echo 1>&2
echo "Testing counts of top-ports" 1>&2
echo "---------------------------" 1>&2
sudo $nmap --privileged $1 -p 23 -oX .a.xml 2>&1
sudo $nmap --privileged $1 --top-ports 1 --exclude-ports 80 -oX .b.xml 2>&1
testUsingNdiff
rm .a.xml .b.xml
echo 1>&2
echo 1>&2


echo 1>&2
echo 1>&2
echo Testing host discovery exclusion with top-ports 1>&2
echo =============================================== 1>&2
echo 1>&2
echo 1>&2
echo Unprivileged 1>&2
echo ============ 1>&2
echo 1>&2
echo "Testing exclusion of all SYN_PING and ACK_PING defaults" 1>&2
echo "-------------------------------------------------------" 1>&2
TEMPVAR="`$nmap $1 --unprivileged --top-ports 10 --exclude-ports 80,443 2>&1 | grep "WARNING: a TCP ping"`"
if [ -n "$TEMPVAR" ]; then
  echo Passed 1>&2
  echo "Relevant line: $TEMPVAR"
else
  echo Failed 1>&2
  echo "  Warning was not shown"
fi
echo 1>&2
echo 1>&2
echo Privileged 1>&2
echo ========== 1>&2
echo 1>&2
echo "Testing exclusion of all SYN_PING and ACK_PING defaults" 1>&2
echo "-------------------------------------------------------" 1>&2
sudo $nmap --privileged $1 --top-ports 2 -p 21-23 -oX .a.xml 2>&1
sudo $nmap --privileged $1 --top-ports 2 --exclude-ports 80,443 -oX .b.xml 2>&1
testUsingNdiff
rm .a.xml .b.xml
echo 1>&2
echo 1>&2
