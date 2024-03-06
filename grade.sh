#!/bin/bash

CPATH='.;lib/hamcrest-core-1.3.jar;lib/junit-4.13.2.jar'
GRADING_AREA="grading-area"

# Clean up previous runs
rm -rf student-submission
rm -rf $GRADING_AREA

# Create directories
mkdir $GRADING_AREA

# Clone the student's submission
git clone $1 student-submission > /dev/null 2>&1
echo 'Finished cloning'

# Check if the required file exists
if [ ! -f student-submission/ListExamples.java ]; then
    echo "Error: ListExamples.java not found in the student's submission."
    exit 1
fi

# Move necessary files to grading-area
cp student-submission/ListExamples.java TestListExamples.java $GRADING_AREA

cp -r lib $GRADING_AREA

# Change to the grading-area directory
cd $GRADING_AREA

# Compile the code
javac -cp $CPATH *.java

# Check if compilation was successful
if [ $? -eq 0 ]
then 
    echo "Compilation successful"
else
    echo "Compilation failed"
fi

# Disable 'set -e' temporarily for running tests
set +e

# Run the tests and report the grade based on JUnit output
java -cp $CPATH org.junit.runner.JUnitCore TestListExamples > test_results.txt

# Enable 'set -e' again
set -e

# Detect failed tests
if grep -q "FAILURES!!!" test_results.txt; then
    echo "Some tests failed. Please review the test results."
    # cat test_results.txt
else
    echo "All tests passed."
    echo "Total Grades: 100"
fi

# Count the total number of tests and the number of passed tests
total_tests=$(grep -oP "(?<=Tests run: )\d+" test_results.txt)
failed_test=$(grep -oP "(?<=Failures: )\d+" test_results.txt)
total_tests=$((total_tests))
failed_test=$((failed_test))
passed=$((total_tests-failed_test))
grades=$((passed/total_tests*100))
echo "Total Grades: $grades"

# Clean up
rm test_results.txt
