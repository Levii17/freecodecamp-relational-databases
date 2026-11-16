#!/bin/bash

# Fixed: changed --t to -t
PSQL="psql --username=freecodecamp --dbname=periodic_table -t --no-align -c"

# check if an argument was provided to the script
if [[ -z $1 ]]
then
  # if no argument was provided, prompt the user and exit
  echo "Please provide an element as an argument."
else
  # check if argument is number, symbol or name
  if [[ $1 =~ ^[0-9]+$ ]]
  then
    # query db using atomic number
    QUERY="SELECT e.atomic_number, e.name, e.symbol, t.type, p.atomic_mass, 
            p.melting_point_celsius, p.boiling_point_celsius 
            FROM elements e JOIN properties p ON e.atomic_number = p.atomic_number 
            JOIN types t ON p.type_id = t.type_id WHERE e.atomic_number = $1;"
  else
    # query db using either symbol or name
    QUERY="SELECT e.atomic_number, e.name, e.symbol, t.type, p.atomic_mass, 
            p.melting_point_celsius, p.boiling_point_celsius 
            FROM elements e JOIN properties p ON e.atomic_number = p.atomic_number 
            JOIN types t ON p.type_id = t.type_id WHERE e.symbol = '$1' OR e.name = '$1';"
  fi

  # execute the constructed query against the db
  RESULT=$($PSQL "$QUERY")

  # check if the query returned any results
  if [[ -z $RESULT ]]
  then
    # if no matching element was found in the db
    echo "I could not find that element in the database."
  else
    # parse the pipe-delimited result string and format the output message
    echo "$RESULT" | while IFS="|" read ATOMIC_NUMBER NAME SYMBOL TYPE MASS MELTING BOILING
    do
      echo "The element with atomic number $ATOMIC_NUMBER is $NAME ($SYMBOL). It's a $TYPE, with a mass of $MASS amu. $NAME has a melting point of $MELTING celsius and a boiling point of $BOILING celsius."
    done
  fi
fi