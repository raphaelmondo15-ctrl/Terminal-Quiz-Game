#!/bin/bash

QUESTIONS_FILE="question.txt"
HIGHSCORES_FILE="highscores.txt"

# Ask your name
read -r -p "Enter your name: " PLAYER

# Check if empty, force a name
while [[ -z "$PLAYER" ]]; do
    read -r -p "Please enter a valid name: " PLAYER
done

echo "Welcome, $PLAYER! Let's start the quiz!"

# Check if the questions file exists
if [[ ! -f "$QUESTIONS_FILE" ]]; then
    echo "Error: $QUESTIONS_FILE not found!"
    exit 1
fi

# Load questions into an array
questions=()
while IFS= read -r line; do
    [[ -z "$line" ]] && continue
    questions+=("$line")
done < "$QUESTIONS_FILE"

# Shuffle the question indices
shuffled=($(gshuf -i 0-$((${#questions[@]} - 1))))

# Initialize score and streak
score=0
streak=0
TOTAL_QUESTIONS=${#questions[@]}

# Function to ask a question
ask_question() {
    local QUESTION="$1"
    local A="$2"
    local B="$3"
    local C="$4"
    local D="$5"
    local ANSWER="$6"

    echo "$QUESTION"
    echo "A) $A"
    echo "B) $B"
    echo "C) $C"
    echo "D) $D"

    read -r -p "Your answer (A/B/C/D): " USER_ANSWER
    USER_ANSWER=$(echo "$USER_ANSWER" | tr '[:lower:]' '[:upper:]')  # Convert to uppercase
    if [[ $USER_ANSWER == "$ANSWER" ]]; then
        echo "Correct!"
        score=$((score + 1))
        streak=$((streak + 1))
    else
        echo "Wrong! The correct answer was $ANSWER."
        streak=0  # Reset streak if the answer is wrong
    fi
}

# Loop through shuffled questions
for idx in "${shuffled[@]}"; do
    line="${questions[$idx]}"
    Q=$(echo "$line" | cut -d '|' -f1)
    A=$(echo "$line" | cut -d '|' -f2)
    B=$(echo "$line" | cut -d '|' -f3)
    C=$(echo "$line" | cut -d '|' -f4)
    D=$(echo "$line" | cut -d '|' -f5)
    ANSWER=$(echo "$line" | cut -d '|' -f6 | tr -d '[:space:]')

    ask_question "$Q" "$A" "$B" "$C" "$D" "$ANSWER"
done

# Final score
echo "You scored $score out of $TOTAL_QUESTIONS."
