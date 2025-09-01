#!/bin/bash


# takes two arguments representing a range of years 
YEAR1=$1 
YEAR2=$2

# create a filename based on the range of years
FILENAME="calendar-$YEAR1-$YEAR2".txt

# loop through each year in the range
for (( year=$YEAR1; year<=$YEAR2; year++ ))
do  
    #cal $year >> "$FILENAME"
    # list of holidays that includes US Federal and Christian holidays, dayslights savings time, flag holidays, solstices and equinoxes
    calendar -A 365 -f /usr/share/calendar/calendar.usholiday -t $year 01 01 >> "$FILENAME"
done




