# freeCodeCamp Relational Databases: Study Notes and Projects

My notes and project work from the freeCodeCamp relational databases material. The notes are rewritten to be **scannable, practical, and easy to review**, and the projects are the PostgreSQL and Bash builds I completed along the way.

## Repo Layout

```text
freecodecamp-relational-databases/
├── README.md
├── notes/        # study notes, numbered in curriculum order
└── projects/     # certification projects (SQL dumps and Bash scripts)
```

## Notes

Each note uses the same structure for every concept:

- **What it is:** a plain-language definition
- **The Everyday Analogy:** a real-world comparison to make it stick
- **Why it matters:** what a working developer gets out of it
- **Quick Example:** a short code block or command
- A closing **Dev Tip** or **Production Pitfall** for each major section, plus a cheat sheet and a Quick Check quiz with collapsible answers

| #   | Note                                                   | What is inside                                                                                                                                                  |
| --- | ------------------------------------------------------ | --------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| 01  | [Code Editors](./notes/01.code-editors.md)             | Editors vs IDEs, installing VS Code, workspaces, Live Server, keyboard shortcuts, useful extensions                                                             |
| 02  | [Bash Fundamentals](./notes/02.bash-fundamentals.md)   | Terminal vs shell vs command line, shortcuts, core Bash commands, options and flags, keyboard layout setup                                                      |
| 03  | [SQL and PostgreSQL](./notes/03.sql-%26-postgresql.md) | Relational vs NoSQL, installing PostgreSQL, SQL basics, data types, CRUD, keys, relationships, joins, psql commands                                             |
| 04  | [Bash Scripting](./notes/04.bash-scripting.md)         | Shebang, variables, `[[ ]]` and `(( ))`, conditionals, loops, arrays, functions, `$RANDOM`, file permissions                                                    |
| 05  | [SQL and Bash](./notes/05.sql-%26-bash.md)             | Normal forms (1NF to BCNF), preventing SQL injection, spotting and fixing the N+1 problem                                                                       |
| 06  | [Git, GitHub, and Nano](./notes/06.git.md)             | Nano, Git setup, repos, SSH and GPG keys, branching, pull requests, code review, GitHub Pages, `.gitignore`, CI/CD with GitHub Actions                          |
| 07  | [Final Review](./notes/07.final-review.md)             | Running SQL from Bash (`psql -c`, `-f`, `-t -A -F`, safe variables, looping over results), one-page review sheets for every topic, and a 16-question mixed quiz |

The numbers follow the order of the curriculum, so reading top to bottom works as a study path.

## Projects

| Project                                                                | What it is                                                                                  | Files                                                                                                                                                                                    |
| ---------------------------------------------------------------------- | ------------------------------------------------------------------------------------------- | ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| [Celestial Bodies Database](./projects/celestial-bodies-database/)     | A PostgreSQL database of galaxies, stars, planets, and moons                                | [`universe.sql`](./projects/celestial-bodies-database/universe.sql)                                                                                                                      |
| [World Cup Database](./projects/world-cup-database/)                   | Bash scripts that load World Cup game data into PostgreSQL and query it                     | [`worldcup.sql`](./projects/world-cup-database/worldcup.sql), [`insert_data.sh`](./projects/world-cup-database/insert_data.sh), [`queries.sh`](./projects/world-cup-database/queries.sh) |
| [Salon Appointment Scheduler](./projects/salon-appointment-scheduler/) | An interactive Bash script that books salon appointments using a PostgreSQL database        | [`salon.sql`](./projects/salon-appointment-scheduler/salon.sql), [`salon.sh`](./projects/salon-appointment-scheduler/salon.sh)                                                           |
| [Number Guessing Game](./projects/number-guessing-game/)               | A Bash number-guessing game that stores player statistics in PostgreSQL                     | [`number_guess.sql`](./projects/number-guessing-game/number_guess.sql), [`number_guess.sh`](./projects/number-guessing-game/number_guess.sh)                                             |
| [Periodic Table Database](./projects/periodic-table-database/)         | A PostgreSQL database of chemical elements with a Bash script to look up element properties | [`periodic_table.sql`](./projects/periodic-table-database/periodic_table.sql), [`element.sh`](./projects/periodic-table-database/element.sh)                                             |

## Progress

- [x] Code editors, IDEs, and VS Code
- [x] Terminal, shell, and Bash commands
- [x] Relational databases, SQL, and PostgreSQL
- [x] Bash scripting
- [x] Normalization, SQL injection, and the N+1 problem
- [x] Git, GitHub, pull requests, and CI/CD
- [x] Celestial Bodies Database
- [x] World Cup Database
- [x] Salon Appointment Scheduler
- [x] Periodic Table Database
- [x] Number Guessing Game

## Running the Projects

Clone the repo and open it in VS Code:

```bash
git clone git@github.com:Levii17/freecodecamp-relational-databases.git
cd freecodecamp-relational-databases
code .
```

**Restore a database from a dump** (works for the `.sql` files):

```bash
# each dump creates its own database and connects to it, so start from the default one
psql --username=freecodecamp --dbname=postgres -f projects/celestial-bodies-database/universe.sql
```

If the database already exists, drop it first with `DROP DATABASE universe;` or the dump will report an error.

**Run a Bash script** (after restoring its database):

```bash
chmod +x projects/salon-appointment-scheduler/salon.sh
./projects/salon-appointment-scheduler/salon.sh
```

The scripts expect a PostgreSQL user named `freecodecamp` and the matching database name set at the top of each script (`salon`, `worldcup`, and so on). Change the `PSQL` variable if your setup differs.

## Tips for Using the Notes

- **Read, then type.** Run every code block yourself in `psql` or your terminal instead of just reading it.
- **Use the Quick Check** at the end of each note, then open the answers.
- **Rebuild from memory.** Practice tasks close out most notes. Try them without looking.

## Notes on Accuracy

These are learning notes, not official documentation. Where the original lesson had a small error or a platform difference (for example, GNU vs macOS `ls` flags), the note calls it out. When in doubt, check the official docs for [PostgreSQL](https://www.postgresql.org/docs/), [Bash](https://www.gnu.org/software/bash/manual/), and [Git](https://git-scm.com/doc).
