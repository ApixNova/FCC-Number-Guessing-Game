#!/bin/bash

PSQL="psql --username=freecodecamp --dbname=number_guess -t --no-align -c"

#generate num
NUMBER=$(echo $[ $RANDOM % 1000 + 1 ])

ATTEMPTS=1

NUMBER_GUESS() {
  
  echo "Enter your username:"
  read USERNAME

  #get username
  NAME=$($PSQL "SELECT name FROM username WHERE name='$USERNAME'")

  #if new, insert username
  if [[ -z $NAME ]]
  then
    E=$($PSQL "INSERT INTO username(name) VALUES('$USERNAME')")
    echo "Welcome, $USERNAME! It looks like this is your first time here."
  else
    GAMES_PLAYED=$($PSQL "SELECT games_played FROM username WHERE name='$USERNAME'")
    BEST_GAME=$($PSQL "SELECT best_game FROM username WHERE name='$USERNAME'")
    echo "Welcome back, $USERNAME! You have played $GAMES_PLAYED games, and your best game took $BEST_GAME guesses."
  fi

}

GUESS_LOOP() {

  if [[ ! $1 =~ ^[0-9]+$ ]]
  then
    echo "That is not an integer, guess again:"

  else
    if (( $1 < $NUMBER ))
    then
      echo "It's higher than that, guess again:"
    fi
    if (( $1 > $NUMBER ))
    then
      echo "It's lower than that, guess again:"
    fi
  fi
}

#Intro
NUMBER_GUESS
echo "Guess the secret number between 1 and 1000:"

#lower/higher loop
READ_AND_COMPARE() {
  read GUESS
  GUESS_LOOP $GUESS
}
READ_AND_COMPARE

while [[ $GUESS != $NUMBER ]]
do
  READ_AND_COMPARE
  ATTEMPTS=$(($ATTEMPTS+1))
done

#if guessed, finish running and insert data

#if new player
if [[ -z $NAME ]]
then

  #insert attempts and game played (one)
  E=$($PSQL "UPDATE username SET games_played=1 WHERE name='$USERNAME'")
  E=$($PSQL "UPDATE username SET best_game=$ATTEMPTS WHERE name='$USERNAME'")
else

  #update games played and compare attempts
  GAMES_PLAYED=$($PSQL "SELECT games_played FROM username WHERE name='$USERNAME'")
  GAMES_PLAYED=$(($GAMES_PLAYED+1))
  E=$($PSQL "UPDATE username SET games_played=$GAMES_PLAYED WHERE name='$USERNAME'")
  BEST_GAME=$($PSQL "SELECT best_game FROM username WHERE name='$USERNAME'")

  if (( $ATTEMPTS < $BEST_GAME ))
  then
    E=$($PSQL "UPDATE username SET best_game=$ATTEMPTS WHERE name='$USERNAME'")
  fi
fi

echo "You guessed it in $ATTEMPTS tries. The secret number was $NUMBER. Nice job!"
