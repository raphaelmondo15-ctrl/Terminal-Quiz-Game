#! /bin/bash

QUESTIONS_FILE="question.txt"
export HIGHSCORES_FILE="highscores.txt"

# Ask your name
read -r -p "Enter your name: " Username

# Check if empty, force a name
while [[ -z "$Username" ]]; do
    read -r -p "Please enter a valid name: " Username
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

#Create an array of indices
indices=()
for ((i=0; i<${#questions[@]}; i++)); do
    indices+=("$i")
done

#shuffle
shuffle_array indices

#Now use "${indices[@]}"
shuffled=("${indices[@]}")

#function to get the current date in YYYY-MM-DD format
get_date() {
   date "+%Y-%m-%d"
}

# Initialize score and streak
score=0
streak=0
correct=0
incorrect=0
longest_streak=0
TOTAL_QUESTIONS=${#shuffled[@]}

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
        correct=$((correct + 1))
    if ((streak > longest_streak)); then
          longest_streak=$streak
      fi    
    else
        echo "Wrong! The correct answer was $ANSWER."
        streak=0  # Reset streak if the answer is wrong
        incorrect=$((incorrect + 1))
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

   #Clear the screen for better user experience
   clear
   ask_question "$Q" "$A" "$B" "$C" "$D" "$ANSWER"
done

# Function to show final stats
show_stats() {
   echo ""
   echo "============RESULTS==========="
    echo -e "\nGame Over!"
    echo "Correct: $correct"
    echo "Incorrect: $incorrect"
    echo "Longest streak: $longest_streak"
    echo "Total Questions: $TOTAL_QUESTIONS"
    echo "Final Score: $((correct * 100 / TOTAL_QUESTIONS))%"
}

save_highscore() {
    read -r username
    local score_percent=$((correct * 100 / TOTAL_QUESTIONS))
    local date
    date=$(get_date)
    echo "$username|$score_percent|$correct/$TOTAL_QUESTIONS|$date" >> "$HIGHSCORES_FILE"
}
show_highscores() {
    if [[ ! -f "$HIGHSCORES_FILE" ]]; then
      echo "No high score avialable"
      return
    fi

    echo -e "\nTop 5 High Scores:"
    sort -t '|' -k2,2nr highscores.txt | head -n 5 | while IFS='|' read -r username score correct_total date; do
        echo "$username - $score% ($correct_total) on $date"
    done
} 

#Option to save high score after game
show_stats
save_highscore

echo ""
echo "High score saved!"