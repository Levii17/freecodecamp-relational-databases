#!/bin/bash

# connect db
PSQL="psql --username=freecodecamp --dbname=number_guess -t --no-align -c"

# generate a random number between 1 - 1000
SECRET_NUMBER=$(( RANDOM % 1000 + 1 ))

echo "Enter your username:"
read USERNAME

# check whether user exists in database and trim output
USER_ID=$($PSQL "SELECT user_id FROM users WHERE username = '$USERNAME'" | xargs)

# if user doesn't exist
if [[ -z $USER_ID ]]
then
  # insert new user
  INSERT_USER_RESULT=$($PSQL "INSERT INTO users(username, games_played, best_game) VALUES('$USERNAME', 0, NULL)")
  USER_ID=$($PSQL "SELECT user_id FROM users WHERE username = '$USERNAME'" | xargs)
  echo "Welcome, $USERNAME! It looks like this is your first time here."

# if user does exist
else
  # get user stats and trim output
  GAMES_PLAYED=$($PSQL "SELECT games_played FROM users WHERE user_id = $USER_ID" | xargs)
  BEST_GAME=$($PSQL "SELECT best_game FROM users WHERE user_id = $USER_ID" | xargs)
  echo "Welcome back, $USERNAME! You have played $GAMES_PLAYED games, and your best game took $BEST_GAME guesses."
  
fi

echo "Guess the secret number between 1 and 1000:"
read GUESS
NUMBER_OF_GUESSES=1

while [[ $GUESS -ne $SECRET_NUMBER ]]
do
  # check if input is an integer
  if ! [[ $GUESS =~ ^[0-9]+$ ]]
  then
    echo "That is not an integer, guess again:"
  elif [[ $GUESS -gt $SECRET_NUMBER ]]
  then
    echo "It's lower than that, guess again:"
  else
    echo "It's higher than that, guess again:"
  fi
  read GUESS
  (( NUMBER_OF_GUESSES++ ))
done

# update user stats upon winning
CURRENT_GAMES_PLAYED=$($PSQL "SELECT games_played FROM users WHERE user_id = $USER_ID" | xargs)
NEW_GAMES_PLAYED=$(( CURRENT_GAMES_PLAYED + 1 ))

CURRENT_BEST_GAME=$($PSQL "SELECT best_game FROM users WHERE user_id = $USER_ID" | xargs)

if [[ -z $CURRENT_BEST_GAME || $CURRENT_BEST_GAME == "" || $NUMBER_OF_GUESSES -lt $CURRENT_BEST_GAME ]]
then
  NEW_BEST_GAME=$NUMBER_OF_GUESSES
else
  NEW_BEST_GAME=$CURRENT_BEST_GAME
fi

UPDATE_RESULT=$($PSQL "UPDATE users SET games_played = $NEW_GAMES_PLAYED, best_game = $NEW_BEST_GAME WHERE user_id = $USER_ID")

echo "You guessed it in $NUMBER_OF_GUESSES tries. The secret number was $SECRET_NUMBER. Nice job!"