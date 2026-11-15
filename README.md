# freeCodeCamp Relational Databases: Study Notes

My personal study notes from the freeCodeCamp relational databases material, rewritten to be **scannable, practical, and easy to review**. They cover the tools you need around the database too: the editor, the terminal, Bash, and Git.

Every note uses the same structure for each concept:

- **What it is:** a plain-language definition
- **The Everyday Analogy:** a real-world comparison to make it stick
- **Why it matters:** what a working developer gets out of it
- **Quick Example:** a short code block or command
- A closing **Dev Tip** or **Production Pitfall** for each major section, plus a cheat sheet and a Quick Check quiz with collapsible answers

## The Notes

| # | Note | What is inside |
|---|---|---|
| 1 | [Code Editors and VS Code](./code-editors-and-vscode.md) | Editors vs IDEs, installing VS Code, workspaces, Live Server, keyboard shortcuts, useful extensions |
| 2 | [Bash Fundamentals and the Command Line](./bash-fundamentals-and-the-command-line.md) | Terminal vs shell vs command line, shortcuts, core Bash commands, options and flags, keyboard layout setup |
| 3 | [PostgreSQL and Relational Databases](./postgresql-and-relational-databases.md) | Relational vs NoSQL, installing PostgreSQL, SQL basics, data types, CRUD, keys, relationships, joins, psql commands |
| 4 | [SQL Normalization, Injection, and the N+1 Problem](./sql-normalization-injection-and-n-plus-one.md) | Normal forms (1NF to BCNF), preventing SQL injection, spotting and fixing N+1 queries |
| 5 | [Git, GitHub, and Nano](./git-github-and-nano.md) | Nano, Git setup, repos, SSH and GPG keys, branching, pull requests, code review, GitHub Pages, `.gitignore`, CI/CD with GitHub Actions |

## Suggested Study Order

1. **Set up your workspace:** [Code Editors and VS Code](./code-editors-and-vscode.md)
2. **Learn the terminal:** [Bash Fundamentals](./bash-fundamentals-and-the-command-line.md)
3. **Learn databases and SQL:** [PostgreSQL and Relational Databases](./postgresql-and-relational-databases.md)
4. **Design and protect them:** [Normalization, Injection, and N+1](./sql-normalization-injection-and-n-plus-one.md)
5. **Version and ship your work:** [Git, GitHub, and Nano](./git-github-and-nano.md)

## Topics at a Glance

- [x] Code editors, IDEs, and VS Code
- [x] Terminal, shell, and Bash commands
- [x] Relational databases and PostgreSQL
- [x] SQL: data types, CRUD, keys, relationships, joins
- [x] Database normalization (1NF, 2NF, 3NF, BCNF)
- [x] SQL injection and N+1 query problem
- [x] Git, GitHub, pull requests, and code review
- [x] GitHub Pages, `.gitignore`, and CI/CD

## Using These Notes

Clone the repo and open the folder in VS Code:

```bash
git clone git@github.com:Levii17/freecodecamp-relational-databases.git
cd freecodecamp-relational-databases
code .
```

Tips for getting the most out of them:

- **Read, then type.** Run every code block yourself in `psql` or your terminal instead of just reading it.
- **Use the Quick Check** at the end of each note, then open the answers.
- **Rebuild from memory.** Each note ends with a practice task. Try it without looking.

## Notes on Accuracy

These are learning notes, not official documentation. Where the original lesson had a small error or a platform difference (for example, GNU vs macOS `ls` flags), the note calls it out. When in doubt, check the official docs for [PostgreSQL](https://www.postgresql.org/docs/), [Bash](https://www.gnu.org/software/bash/manual/), and [Git](https://git-scm.com/doc).