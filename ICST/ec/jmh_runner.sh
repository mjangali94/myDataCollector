#!/bin/bash

# File containing the list of JMH benchmarks (one per line)
BENCHMARKS_FILE="benchmarks.txt"

# Output file to append results
RESULTS_FILE="results.txt"

# Error log file
ERROR_LOG="error_log.txt"

# JMH JAR file location
JMH_JAR="microbenchmarks.jar"

# JMH options
JMH_OPTIONS="-f 1 -i 30 -r 1 -wi 30 -w 2"

# JMH lock file location (default location)
JMH_LOCK_FILE="/tmp/jmh.lock"

# Check if the benchmarks file exists
if [[ ! -f "$BENCHMARKS_FILE" ]]; then
  echo "Error: $BENCHMARKS_FILE not found."
  exit 1
fi

# Check if the JMH JAR file exists
if [[ ! -f "$JMH_JAR" ]]; then
  echo "Error: JMH JAR file not found at $JMH_JAR."
  exit 1
fi

# Clear the results and error log files if they exist, or create them
> "$RESULTS_FILE"
> "$ERROR_LOG"

# Read each benchmark from the file and run it
while IFS= read -r benchmark; do
  # Skip empty lines
  if [[ -z "$benchmark" ]]; then
    continue
  fi

  # Append '$' to the benchmark name if required
  BENCHMARK_WITH_DOLLAR="${benchmark}\$"

  echo "Running benchmark: $BENCHMARK_WITH_DOLLAR"
  
  # Delete the JMH lock file if it exists
  if [[ -f "$JMH_LOCK_FILE" ]]; then
    echo "Deleting JMH lock file: $JMH_LOCK_FILE"
    rm -f "$JMH_LOCK_FILE"
  fi

  # Run the JMH benchmark and append results to the results file
  echo "=== Benchmark: $BENCHMARK_WITH_DOLLAR ===" >> "$RESULTS_FILE"
  java -XX:+UseParallelGC -Xms8G -Xmx8G -jar "$JMH_JAR" $JMH_OPTIONS "$BENCHMARK_WITH_DOLLAR" >> "$RESULTS_FILE" 2>> "$ERROR_LOG"

  # Check if the benchmark ran successfully
  if [[ $? -eq 0 ]]; then
    echo "Benchmark $BENCHMARK_WITH_DOLLAR completed successfully."
  else
    echo "Error: Benchmark $BENCHMARK_WITH_DOLLAR failed. Check $ERROR_LOG for details."
  fi

  echo "----------------------------------------" >> "$RESULTS_FILE"
done < "$BENCHMARKS_FILE"