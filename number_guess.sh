#!/bin/bash

PSQL="psql --username=freecodecamp --dbname=number_guess -t --no-align -c"
RANDOM=$$
SECRET_NUMBER=$(($RANDOM%1001))

# get username
echo "Enter your username:"
read USERNAME
# get user_id
USER_ID=$($PSQL "SELECT user_id FROM users WHERE username = '$USERNAME';")
if [[ -z $USER_ID ]]
then
  # if not found
  echo "Welcome, $USERNAME! It looks like this is your first time here."
  # insert new user
  INSERT_USER_RESULT=$($PSQL "INSERT INTO users (username) VALUES ('$USERNAME');")
  USER_ID=$($PSQL "SELECT user_id FROM users WHERE username = '$USERNAME';")
else
  # get number of games played
  GAMES_PLAYED=$($PSQL "SELECT count(*) FROM users INNER JOIN games USING (user_id) WHERE user_id = $USER_ID;")
  # get best game
  BEST_GAME=$($PSQL "SELECT min(tries) FROM users INNER JOIN games USING (user_id) WHERE user_id = $USER_ID;")
  echo "Welcome back, $USERNAME! You have played $GAMES_PLAYED games, and your best game took $BEST_GAME guesses."
fi

echo "Guess the secret number between 1 and 1000:"
read GUESS
NUMBER_OF_GUESSES=0
EXIT=false
while [ "$EXIT" = false ]
do
  NUMBER_OF_GUESSES=$((NUMBER_OF_GUESSES+1))
  if [[ ! $GUESS =~ ^[0-9]+$ ]]; then
    echo "That is not an integer, guess again:"
    read GUESS
  elif [ $GUESS -eq $SECRET_NUMBER ]; then
    EXIT=true
  elif [[ $GUESS -gt $SECRET_NUMBER ]]; then
    echo "It's lower than that, guess again:"
    read GUESS
  else
    echo "It's higher than that, guess again:"
    read GUESS
  fi
done

echo "You guessed it in $NUMBER_OF_GUESSES tries. The secret number was $SECRET_NUMBER. Nice job!"
INSERT_GAME_RESULT=$($PSQL "INSERT INTO games (user_id, tries) VALUES ($USER_ID, $NUMBER_OF_GUESSES);")
