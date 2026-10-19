# Bash Scripting: Your Field Guide

Bash scripting is automation you can start using today. Each concept below follows the same four-part breakdown, and each section ends with a Production Pitfall.

---

## 1. Bash Scripting Basics

### Bash Script

- **What it is:** A text file of Bash commands that Bash runs top to bottom.
- **Analogy:** A recipe card. You write the steps once, and anyone can follow them the same way every time.
- **Why it matters:**
  - Bash ships with nearly every Unix system, so there is no runtime to install (unlike Node.js or Python).
  - You can call any binary on the machine, such as `rsync` or `doctl`.
  - The syntax is the same as the terminal, so you can paste a few lines in to test them.
- **Example:**

```bash
#!/bin/bash

servers=("prod" "dev")

for server in "${servers[@]}"
do
  echo "Pulling $server"
  rsync --archive --verbose $server:/etc/nginx/conf.d/server.conf configs/$server.conf
done
```

This pulls NGINX configs from each server, which is handy for backing them up into a repo.

### Shebang (`#!`)

- **What it is:** The first line of a script. It tells the system which interpreter runs the file.
- **Analogy:** The language label on a book cover. It tells the system whether to read the file as Bash, Python, and so on.
- **Why it matters:**
  - The script runs with the right interpreter on any machine.
  - Common values are `#!/bin/bash`, `#!/usr/bin/bash`, and `#!/bin/sh`.
  - `which bash` shows you the correct path.
- **Example:**

```bash
#!/bin/bash
which bash   # /usr/bin/bash
```

**Dev Tip:** Always start a script with a shebang, because without it the script's behavior depends on whoever happens to run it.

---

## 2. Variables, Input, and Comments

### Variables

- **What it is:** A named container for a value, created as `NAME=value`.
- **Analogy:** A labeled jar in your kitchen. You grab the jar by its label instead of remembering what is inside.
- **Why it matters:**
  - You avoid hardcoding values in many places.
  - **No spaces around `=`**, or Bash thinks you are running a command.
  - Use double quotes when the value has spaces.
  - Scripts run top to bottom, so a variable only exists below where you create it.
- **Example:**

```bash
NAME=John
MESSAGE="Hello World"
COUNT=5

echo $NAME
echo "The message is: $MESSAGE"
```

### Variable Interpolation

- **What it is:** Using `$variable` inside strings and commands so Bash swaps in the value.
- **Analogy:** A mail-merge letter. "Dear {name}" becomes "Dear John."
- **Why it matters:** It builds dynamic commands such as file paths and server names.
- **Example:**

```bash
TEXT="The next number is, "
NUMBER=42
echo $TEXT B:$NUMBER
echo "Pulling $server"
```

### User Input with `read`

- **What it is:** A command that pauses the script and stores what the user types in a variable.
- **Analogy:** A form field. The script asks, the user answers, and the answer is saved.
- **Why it matters:** It makes scripts interactive (menus, confirmations, questionnaires).
- **Example:**

```bash
read USERNAME
echo "Hello $USERNAME"
```

### Comments

- **What it is:** Notes for humans that Bash ignores.
- **Analogy:** Sticky notes in the margin of a recipe.
- **Why it matters:** They explain the why of your code to your teammates and your future self.
- **Example:**

```bash
# Single-line comment
NAME="John"  # End-of-line comment

: '
Multi-line comment.
Everything between the quotes is ignored.
'
```

**Dev Tip:** Never put spaces around `=` in an assignment, because `NAME = John` fails with "command not found".

---

## 3. Getting Help, Echo, and Script Arguments

### Built-in Help Tools

- **What it is:** Bash's own documentation commands.
- **Analogy:** The help desk, with a few different counters depending on your question.
- **Why it matters:** You can get unstuck without leaving the terminal.
  - `help` lists built-ins, and `help if` explains one. Built-ins like `if` have no man page.
  - `man ls` opens the full manual (arrows to scroll, `q` to quit).
  - `ls --help` gives a quick summary, but not every command supports it.
  - `which python` shows where an executable lives and which version will run.
- **Example:**

```bash
help
help if
man echo
chmod --help
which bash
```

### `echo` Options

- **What it is:** Prints text to the terminal.
- **Analogy:** A print statement for the shell.
- **Why it matters:**
  - `-e` enables backslash escapes like `\n` (new line).
  - An empty line prints only if you quote it (`echo ""`).
  - It is great for formatted output and program titles.
- **Example:**

```bash
echo -e "Line 1\nLine 2"
echo ""
echo -e "\n~~ Program Title ~~\n"
echo "Line 1\nLine 2"   # no -e, so prints \n literally
```

### Script Arguments

- **What it is:** Values passed after the script name, such as `./script.sh apple banana`.
- **Analogy:** Handing a chef the order slip along with the recipe.
- **Why it matters:**
  - `$1`, `$2`, `$3` are positional arguments.
  - `$*` and `$@` both mean "all arguments". They differ when quoted: `"$@"` keeps each argument separate, which is the safe choice.
- **Example:**

```bash
echo $1
echo $2
echo "$@"
```

**Dev Tip:** Use `"$@"` (quoted) when forwarding arguments, so values with spaces stay intact.

---

## 4. Double Brackets `[[ ]]` (Tests and Conditions)

### Double Bracket Expressions

- **What it is:** A test that evaluates a condition and returns an exit status (0 for true, 1 for false).
- **Analogy:** A bouncer with a checklist. The condition either passes or it does not.
- **Why it matters:**
  - It is the standard way to test strings, numbers, and files in `if` and loops.
  - **Spaces are required** inside the brackets and around operators.
- **Example:**

```bash
[[ $variable == "value" ]]
[[ $number -gt 10 ]]
[[ -f filename.txt ]]
```

### Operator Cheat Sheet

| Type            | Operators                                                                                                     | Example                            |
| --------------- | ------------------------------------------------------------------------------------------------------------- | ---------------------------------- |
| **String**      | `==` `!=` `<` `>` (alphabetical)                                                                              | `[[ "apple" < "banana" ]]`         |
| **Numeric**     | `-eq` `-ne` `-lt` `-le` `-gt` `-ge`                                                                           | `[[ $age -ge 18 ]]`                |
| **Logical**     | `&&` `\|\|` `!`                                                                                               | `[[ $age -ge 18 && $age -le 65 ]]` |
| **Files**       | `-e` exists, `-f` regular file, `-d` directory, `-r` readable, `-w` writable, `-x` executable, `-s` non-empty | `[[ -d /home/user ]]`              |
| **Regex**       | `=~`                                                                                                          | `[[ "filename.txt" =~ \.txt$ ]]`   |
| **Empty check** | `! $var`                                                                                                      | `[[ ! $undefined_var ]]`           |

### Regex Matching with `=~`

- **What it is:** Pattern matching inside a test.
- **Analogy:** A search with wildcards, like "any file ending in .txt".
- **Why it matters:** It is useful for validating input (emails, questions, file extensions).
- **Example:**

```bash
[[ "hello123" =~ [0-9]+ ]]
[[ "email@domain.com" =~ ^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$ ]]
```

Do not quote the pattern, or Bash treats it as a plain string. Matching is case-sensitive.

**Dev Tip:** Use `-eq`/`-lt` for numbers and `==`/`<` for strings, because `[[ 10 < 9 ]]` compares alphabetically and returns true.

---

## 5. Double Parentheses `(( ))` (Math)

### Arithmetic Evaluation

- **What it is:** C-style math and numeric comparisons.
- **Analogy:** A calculator built into the shell.
- **Why it matters:**
  - Variables do not need `$` inside `(( ))`.
  - It returns exit status 0 if the result is non-zero, and 1 if the result is zero.
- **Example:**

```bash
(( result = 10 + 5 ))
(( count++ ))
(( total += value ))
(( age >= 18 && age <= 65 ))
```

### Operators at a Glance

- **Arithmetic:** `+  -  *  /  %  **` (division is integer division)
- **Assignment:** `=  +=  -=  *=  /=  %=`
- **Increment/decrement:** `++x`, `x++`, `--x`, `x--`
- **Comparison:** `==  !=  <  <=  >  >=`
- **Logical:** `&&  ||  !`
- **Bitwise:** `&  |  ^  ~  <<  >>`
- **Ternary:** `condition ? a : b`

```bash
(( max = (a > b) ? a : b ))
(( power = base ** exponent ))
(( shifted = value << 2 ))
```

### Arithmetic Substitution `$(( ))`

- **What it is:** Captures a math result so you can use it elsewhere.
- **Analogy:** `(( ))` does the math on a scratchpad, and `$(( ))` hands you the answer.
- **Example:**

```bash
result=$(( 10 + 5 ))
echo "The answer is $(( a * b ))"
```

**Dev Tip:** Use `[[ ]]` for strings and files, and `(( ))` for math, because mixing them up gives confusing results.

---

## 6. Control Flow and Command Execution

### `if` / `elif` / `else`

- **What it is:** Runs code only when a condition is true.
- **Analogy:** A fork in the road with signs.
- **Why it matters:** Scripts can make decisions. You can mix `[[ ]]` and `(( ))` in the same chain.
- **Example:**

```bash
if (( NUMBER <= 15 ))
then
    echo "B:$NUMBER"
elif [[ $NUMBER -le 30 ]]
then
    echo "I:$NUMBER"
else
    echo "O:$NUMBER"
fi
```

### Exit Status

- **What it is:** A number every command returns when it finishes. Check it with `$?`.
- **Analogy:** A receipt that says "all good" (0) or "something went wrong" (anything else).
- **Why it matters:**
  - `0` means success, and non-zero means failure.
  - Common codes are `1` (general error) and `127` (command not found).
  - `if` statements rely on it.
- **Example:**

```bash
ls; echo $?
bad_command; echo $?
[[ 4 -le 5 ]]; echo $?
```

### Command Separation, Subshells, Substitution, Sleep

- **`;`** runs commands one after another: `ls -l; echo "Done"`
- **`( ... )`** is a subshell, a separate environment that does not change your parent shell's variables.
- **`$( ... )`** is command substitution, which captures a command's output.
- **`sleep`** pauses the script, and decimals work.

```bash
( cd /tmp; echo "Current dir: $(pwd)" )
file_count=$(ls | wc -l)
echo "Found $file_count files"
sleep 0.5
```

- **Analogy:** A subshell is a sandbox. You can experiment inside it, and your real workspace stays untouched.

**Dev Tip:** Check `$?` immediately after the command you care about, because the next command overwrites it.

---

## 7. Loops

### `while`, `until`, and `for`

- **What it is:** Repeat code.
- **Analogy:** Doing laps. `while` means "keep going as long as you have energy", `until` means "keep going until you reach the finish line", and `for` means "do one lap per runner on the list".
- **Why it matters:**
  - They automate repetitive work (servers, files, retries, input validation).
  - `until` is great for "ask again until the input is valid."
- **Example:**

```bash
# while: runs while condition is true
I=5
while [[ $I -ge 0 ]]
do
    echo $I
    (( I-- ))
    sleep 1
done

# until: runs until condition becomes true
until [[ $QUESTION =~ \?$ ]]
do
    echo "Please enter a question ending with ?"
    read QUESTION
done

# for: three flavors
for server in "${servers[@]}"; do echo "Processing $server"; done
for (( i = 1; i <= 5; i++ )); do echo "Number: $i"; done
for i in {1..5}; do echo "Count: $i"; done
```

**Dev Tip:** In a `while` loop, always change something that eventually makes the condition false (like `(( I-- ))`), or you have written an infinite loop.

---

## 8. Arrays

### Arrays

- **What it is:** One variable holding multiple values.
- **Analogy:** An egg carton. One container, numbered slots, starting at 0.
- **Why it matters:**
  - You can loop over lists of servers, files, or options.
  - A missing index returns an empty string.
- **Example:**

```bash
RESPONSES=("Yes" "No" "Maybe" "Ask again later")
echo ${RESPONSES[0]}     # Yes
echo ${RESPONSES[1]}     # No
echo ${RESPONSES[5]}     # (empty, index doesn't exist)
echo ${RESPONSES[@]}     # all elements
```

### Inspecting and Expanding Arrays

- `declare -p ARR` shows the structure: `ARR=([0]="a" [1]="b" [2]="c")`
- `"${array[@]}"` expands to individual elements, which is what you want in `for` loops.

```bash
for server in "${servers[@]}"
do
    echo "$server"
done
```

### Random Array Access

- **Analogy:** Closing your eyes and pointing at a slot in the egg carton.

```bash
RESPONSES=("Yes" "No" "Maybe" "Outlook good" "Don't count on it" "Ask again later")
N=$(( RANDOM % 6 ))
echo ${RESPONSES[$N]}
```

**Dev Tip:** Array indexes start at 0, so a 6-item array has valid indexes 0 to 5.

---

## 9. Functions

### Functions

- **What it is:** A named, reusable block of code.
- **Analogy:** A speed-dial button. Press it and a whole sequence of steps happens.
- **Why it matters:**
  - It removes duplicate code (DRY).
  - Functions take arguments as `$1`, `$2`, and so on, just like scripts.
  - Define a function before you call it.
- **Example:**

```bash
GET_FORTUNE() {
    if [[ ! $1 ]]
    then
        echo "Ask a yes or no question:"
    else
        echo "Try again. Make sure it ends with a question mark:"
    fi
    read QUESTION
}

GET_FORTUNE          # first call, no argument
GET_FORTUNE again    # retry, with an argument
```

**Dev Tip:** Use `[[ ! $1 ]]` to detect "no argument passed" so your function can behave differently on retries.

---

## 10. Random Numbers and Modulo

### `$RANDOM` and `%`

- **What it is:** `$RANDOM` gives a number from 0 to 32767. The modulo operator `%` returns the remainder of a division.
- **Analogy:** Rolling a giant die, then using clock arithmetic to shrink the result into the range you want.
- **Why it matters:**
  - `RANDOM % n` gives 0 to n-1, and adding 1 shifts it to 1 to n.
  - You must use `$(( ))` for the math.
- **Example:**

```bash
DICE=$(( RANDOM % 6 + 1 ))     # 1 to 6
BINGO=$(( RANDOM % 75 + 1 ))   # 1 to 75
echo $(( 15 % 4 ))             # 3
```

**Dev Tip:** `RANDOM % 6` gives 0 to 5, not 1 to 6, so remember the `+ 1`.

---

## 11. Environment and System Info

### Environment Variables

- **What it is:** Predefined variables the shell provides.
- **Analogy:** The settings page of your shell.
- **Why it matters:**
  - `$HOME` is your home directory, `$LANG` is the system language, and `$PATH` lists the directories searched for commands.
  - `printenv` lists them all.
- **Example:**

```bash
echo $HOME
echo $LANG
printenv
declare -p RANDOM
```

### Command Types

- **What it is:** Not every command is the same kind.
  - **Built-ins** run inside the shell (`echo`, `read`).
  - **External commands** are binaries on disk (`ls`, `sleep`).
  - **Keywords** are language constructs (`then`, `do`, `done`).
- **Why it matters:** It tells you whether to look in `help` (built-ins) or `man` (externals).
- **Example:**

```bash
type echo
type ls
type if
```

**Dev Tip:** If `man` has no page for a command, it is probably a built-in, so try `help <command>`.

---

## 12. Creating and Running Scripts

### Creating a Script File

- **What it is:** `touch` creates an empty file, or updates the timestamp if it exists.

```bash
touch bingo.sh
```

### Three Ways to Run a Script

- **Analogy:** Three ways to start a car: key, push button, remote. Same result, different requirements.
- **Example:**

```bash
sh questionnaire.sh      # run with sh
bash questionnaire.sh    # run with bash
./questionnaire.sh       # run directly (needs execute permission)
```

### File Permissions

- **What it is:** Flags that control who can read, write, and execute a file.
- **Why it matters:** `./script.sh` fails with "Permission denied" until you grant execute permission.
- **Reading `ls -l` output:** `-rw-r--r--`
  - First character: file type (`-` file, `d` directory)
  - Next 9 characters: owner, group, others, each with `r` (read), `w` (write), `x` (execute)
- **Fix it:**

```bash
ls -l questionnaire.sh
chmod +x questionnaire.sh
./questionnaire.sh
```

### Script Organization

1. Shebang
2. Descriptive comment about the script's purpose
3. Variables at the top
4. Functions grouped together
5. Main logic at the bottom

```bash
#!/bin/bash
# Purpose: demo script layout
NAME="value"
ARRAY=("item1" "item2")

my_function() {
    echo "Function code here"
}

my_function
echo "Script complete"
```

### Master Scripts (Sequential Execution)

- **What it is:** A script that runs other scripts in order, and each finishes before the next starts.
- **Analogy:** A factory assembly line.
- **Example:**

```bash
#!/bin/bash
./setup.sh
./interactive.sh
./processing.sh
./cleanup.sh
```

**Production Pitfall:** `chmod +x` gives execute permission to everyone, so on shared or production servers use `chmod 700 script.sh` for scripts that should stay private.

---

## Quick Check

- Do you know why `NAME = John` fails?
- Can you explain `[[ ]]` vs `(( ))` in one sentence?
- What is the range of `$(( RANDOM % 10 + 1 ))`? (Answer: 1 to 10.)

You now have the toolkit to write real automation. Try rebuilding the bingo or fortune-teller script from memory, since that is where the syntax really sticks.
