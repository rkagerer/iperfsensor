# iperfsensor v1.0.4 (2015-Sep-21)
# iPerf sensor for PRTG
# Author: rkagerer
# For the latest version, see https://github.com/rkagerer/iperfsensor/
#
# This script is intended to run with minimal dependancies, where only a limited subset 
# of Linux commands are supported.

# Run iPerf using parameters passed in, but override a few we require:
# "-f m" to format Transfer volume in MBytes and Bandwidth in MBits/sec 
# "-P 1" since parsing logic hasn't yet been implemented for parallel tests
# "-r"   since we're expecting to parse results of a test in both directions 
# "2>&1" redirect stderr to stdout to prevent errors from contaminating the xml output 
# Warning: There is no input sanitization, so be mindful of what you pass in.
output=$(iperf $* -f m -P 1 -r 2>&1) 
error=$?

# Parse iPerf output.  First find lines with the word MBytes, then (treating space as 
# delimiters) return the fourth-from-last and second-from-last fields (which are 
# Transfer and Bandwidth, respectively).  This yields two pairs of values. 
results=$(echo -e "$output" | grep "MBytes" | awk '{ print $(NF-3), $(NF-1) }') 
# Take those values and convert to bytes, which are needed when using PRTG "SpeedNet" units. 
# bc isn't installed by default on Tomato, so use awk for floating point arithmetic. 
# printf is used to avoid scientific notation that may otherwise arise. 
down=$(echo $results | awk '{printf "%.0f", $2 * 125000}') 
up=$(  echo $results | awk '{printf "%.0f", $4 * 125000}') 
#amt=$( echo $results | awk '{printf "%.2f", ($1+$3) * 1048576}') 
amt=$( echo $results | awk '{printf "%.2f", ($1+$3)}') # leave in MB for convenience 
 
# See https://prtg.paessler.com/api.htm?username=demo&password=demodemo&tabid=7 for more info.
# Be sure to return a valid response even when no parameters are passed in or errors occur. 
# PRTG gets finicky and reports unintuitive errors if it doesn't like what it sees in here, 
# even for minor things like unacceptable combinations of tags.  If you do something wrong 
# wrong here, the "Preparing Sensor Settigns" dialog may hang, and you'll get timeout errors 
# on the sensor, until you fix the problem or remove the sensor. 
echo "<prtg>" 
echo "  <result>" 
echo "    <channel>Download</channel>" 
echo "    <value>$down</value>" 
echo "    <float>1</float>" 
echo "    <unit>SpeedNet</unit>" 
echo "    <volumeSize>MegaBit</volumeSize>" 
echo "    <decimalMode>2</decimalMode>" 
echo "    <showChart>1</showChart>" 
echo "    <limitMinWarning>50</limitMinWarning>" 
echo "    <limitWarningMsg>Downloads from office to Bales are below 50 Mbit/s (6.25 MB/sec)</limitWarningMsg>" 
echo "  </result>" 
echo "  <result>" 
echo "    <channel>Upload</channel>" 
echo "    <value>$up</value>" 
echo "    <float>1</float>" 
echo "    <unit>SpeedNet</unit>" 
echo "    <volumeSize>MegaBit</volumeSize>" 
echo "    <decimalMode>2</decimalMode>" 
echo "    <showChart>1</showChart>" 
echo "    <limitMinWarning>50</limitMinWarning>" 
echo "    <limitWarningMsg>Uploads from Bales to Office are below 50 Mbit/s (6.25 MB/sec)</limitWarningMsg>" 
echo "  </result>" 
echo "  <result>" 
echo "    <channel>Transferred</channel>" 
echo "    <value>$amt</value>" 
echo "    <float>1</float>" 
#echo "    <unit>BytesBandwidth</unit>"
echo "    <unit>Custom</unit>" 
echo "    <customUnit>MB</customUnit>" 
#echo "    <volumeSize>MegaByte</volumeSize>"
echo "    <decimalMode>1</decimalMode>" 
echo "    <showChart>1</showChart>" 
echo "  </result>" 
echo "  <text>" 
# if iPerf failed, send its raw output to PRTG to help with debugging
if [ $error -ne 0 ]; then
  # Escape any special XML characters - see http://daemonforums.org/showthread.php?t=4054
  output=$($output | sed -e 's~&~\&amp;~g' -e 's~<~\&lt;~g'  -e  's~>~\&gt;~g')
  echo -e "$output"
fi
echo "  </text>" 
echo "  <error>$error</error>" 
echo "</prtg>"
