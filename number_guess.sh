#!/bin/bash

PSQL="psql --username=freecodecamp --dbname=number_guess -t --no-align -c"

MAIN_MENU () {
  echo "Enter your username:"
  read USERNAME
  ASK_USERNAME=$($PSQL "SELECT username FROM users WHERE username = '$USERNAME'")

  if [[ -z $ASK_USERNAME ]]
    then
      ADD_USERNAME=$($PSQL "INSERT INTO users(username) VALUES('$USERNAME')")
      echo "Welcome, $USERNAME! It looks like this is your first time here."
      echo "Guess the secret number between 1 and 1000:"
      GUESSING_ALGORITHM
    else
      USER_ID=$($PSQL "SELECT user_id FROM users WHERE username = '$USERNAME'")
      GAMES_PLAYED=$($PSQL "SELECT COUNT(number_guesses) FROM games WHERE user_id = $USER_ID")
      BEST_GAME=$($PSQL "SELECT MIN(number_guesses) FROM games WHERE user_id = $USER_ID")
      echo "Welcome back, $ASK_USERNAME! You have played $GAMES_PLAYED games, and your best game took $BEST_GAME guesses."
      echo "Guess the secret number between 1 and 1000:"
      GUESSING_ALGORITHM
  fi
}

RANDOM_NUMBER=$((RANDOM % 1000 + 1))
NUMBER_GUESSES=0

GUESSING_ALGORITHM () {
  read NUM
  if [[ $NUM =~ ^[0-9]+$ ]]
    then
      ((NUMBER_GUESSES++))
      if [[ $NUM == $RANDOM_NUMBER ]]
        then
          USER_ID=$($PSQL "SELECT user_id FROM users WHERE username = '$USERNAME'")
          START_GAME=$($PSQL "INSERT INTO games(user_id, number_guesses) VALUES($USER_ID, $NUMBER_GUESSES)")
          echo "You guessed it in $NUMBER_GUESSES tries. The secret number was $RANDOM_NUMBER. Nice job!"
        elif [[ $NUM > $RANDOM_NUMBER ]]
          then
            echo "It's lower than that, guess again:"
            GUESSING_ALGORITHM
          else
            echo "It's higher than that, guess again:"
            GUESSING_ALGORITHM
      fi
    else
      echo "That is not an integer, guess again:" 
      GUESSING_ALGORITHM
  fi
}

MAIN_MENU
