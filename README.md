# Hand of God

*[~ currently runs only on zsh ~]*  

A set of shell commands I frequently use to make life easier. Separate files are coming for different use cases (such as 42 Piscine and general as well as bash support)

***

## Installation
1. Clone the repository:
```shell
git clone https://github.com/StriderDunedain/hand_of_god.git
```
2. Add this to your .zshrc file
```shell
source <absolute_path_to_cloned_repo/hand_of_god.sh>
```

That's it! You're set! Just re-open the terminal

***

## man pages
- You can also add the `man` pages:
```shell
mv man_pages/* ~/.local/share/man/man1
```
And learn how to use a specific function by typing `hod <function_name>` or just `hod` to list all of them

***

## Troubleshooting
**Q:** "I get a syntactic error when running `source` although I haven't touched the file!"  
**A:** "Don't worry, it's normal. That just means you already have an alias that is the same as the function's name. Either comment the function out or remove the alias in your shell"

***

## Contributions
You can use this code to your heart's content. And if you wish to see a function added - open an issue or even better a PR with your code!
