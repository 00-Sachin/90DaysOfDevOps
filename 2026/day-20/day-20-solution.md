# Day 20 Challenge: Automated Log Analysis


Overview
As system administrators and DevOps engineers, manually reading through thousands of lines of server logs is inefficient and prone to human error. For this challenge, I wrote log_analyzer.sh, a Bash script that automates the parsing of log files. It validates input, extracts specific error keywords, identifies critical events by line number, and generates a formatted, timestamped summary report.

# 1. The Script: log_analyzer.sh
Here is the final, working code for the log analyzer. Notably, I updated the file validation to use the -f flag (checking for a file) rather than -d (checking for a directory), ensuring the script handles inputs accurately.

Bash

#!/bin/bash

#1. Ensuring that the path argument is provided 

if [ "$#" -ne 1 ]; then

       echo "Error: Missing log file path."
       echo "usage : $0 <path_to_log_file>"
       exit 1
fi

#2. Checking if the path actually exists

log_path="$1"

if [ ! -f "$log_path" ]; then

        echo "$log_path does not exist."
        echo "Please enter a valid path."
        exit 1
fi

#3. Count lines containing "ERROR" or "Failed"

#Using -E for multiple patterns, -i for case-insensitivity, and -c to count

ERROR_COUNT="$(grep -i -E -c "ERROR|Failed" "$log_path")"

#4. Print the total error count to the console

echo "Total errors/failures found: $ERROR_COUNT" 

#5. Searching and printing the lines that contain CRITICAL

CRITICAL_EVENTS=$(grep -ni "CRITICAL" "$log_path" | awk '{print "line: " $0}')

echo "-----Critical Events-----"

echo "$CRITICAL_EVENTS"

#6. Finding the top 5 most occurred Error messages 

#7. The pipeline: Extract -> Strip Timestamp -> Sort -> Count -> Sort Descending -> Top 5

TOP_5_ERRORS="$(grep -i "ERROR" "$log_path"| cut -c 21- | sort | uniq -c | sort -nr | head -n 5)"

echo "--- Top 5 Error Messages ---"

echo "$TOP_5_ERRORS"

echo ""

#8. Gather remaining data for the report

CURRENT_DATE=$(date +"%Y-%m-%d")

REPORT_FILE="log_report_${CURRENT_DATE}.txt"

TOTAL_LINES=$(wc -l < "$log_path")

#9. Generate the report using the variables we already saved

{

    echo "========================================"
    echo "          LOG ANALYSIS REPORT           "
    echo "========================================"
    echo "Date of analysis: $(date +"%Y-%m-%d %H:%M:%S")"
    echo "Log file name: $log_path"
    echo "Total lines processed: $TOTAL_LINES"
    echo "Total error count: $ERROR_COUNT"
    echo ""
    echo "--- Top 5 Error Messages ---"
    # Just print the variable instead of running grep again!
    echo "$TOP_5_ERRORS" 
    echo ""
    echo "--- Critical Events (with line numbers) ---"
    echo "$CRITICAL_EVENTS"
    echo "========================================"
    
}> "$REPORT_FILE"

echo "Report successfully generated: $REPORT_FILE"

# 2. Commands and Tools Used
   
To make this script efficient, I heavily relied on Linux text-processing utilities and command pipelines:

grep: The core search tool. I used -i to ignore case, -E to search for multiple patterns (ERROR|Failed), -c to return a raw count instead of text, and -n to print the exact line number of the match.

awk: Used for text formatting. awk '{print "line: " $0}' allowed me to prepend the word "line:" to the output of my grep search for better readability.

cut: Used in the Top 5 pipeline. By using cut -c 21-, I stripped away the first 20 characters (the timestamps) so that identical error messages could be grouped properly, regardless of when they occurred.

sort & uniq: The grouping engine. I sorted the text alphabetically first, used uniq -c to count adjacent identical lines, and then used sort -nr to sort those counts numerically in reverse (highest to lowest).

head: Used to cap the pipeline output to only the top 5 results.

wc -l: Used to count the total number of lines processed in the target file.

# 3. Sample Console Output
When running the script against a standard system log file (./log_analyzer.sh sample_log.log), the console outputs the following:

Plaintext
Total errors/failures found: 142
-----Critical Events-----
line: 84: 2026-02-11 10:15:23 CRITICAL Disk space below threshold
line: 217: 2026-02-11 14:32:01 CRITICAL Database connection lost
--- Top 5 Error Messages ---
     45 Connection timed out
     32 File not found
     28 Permission denied
     15 Disk I/O error
      9 Out of memory

Report successfully generated: log_report_2026-02-11.txt
(Note: The generated log_report_2026-02-11.txt file contains this exact data formatted cleanly within the summary borders).

# 4. What I Learned
Robust File Validation: Checking for [ ! -f "$log_path" ] instead of just checking if the string is empty ensures the script doesn't crash halfway through if the user provides a typo in the file path.

The Power of Pipelining: Chaining commands together is where Bash truly shines. Creating a pipeline that extracts text, strips timestamps, sorts, counts, sorts again, and limits the output (grep | cut | sort | uniq -c | sort -nr | head) is an incredibly powerful way to process data without writing loops.

Grouped Output Redirection: Instead of writing complex >> append redirects for every single line of the final report, wrapping all the echo statements inside curly braces { ... } > "$REPORT_FILE" cleanly directs the entire block into the text file at once.
