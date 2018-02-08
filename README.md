# cloaksec-scripts
Some scripts/helpers I made throughout the PWK/OSCP

Terminator is required for full functionality

There are probably better ways to do all of this.
## pplfinder
Cewl shouldn't be the end of it. Check for common usernames with pplfinder.

## hydro.sh
Feed multiple password lists into hydra in run order.

## start.sh
Builds out folders and starts portscan.sh for each target in Targets.txt
## portscan.sh
Starts a TCP nmap scan, and allows you to run a specific webscan.sh on each suspected web service. Also starts a unicornscan -> nmap scan for UDP
## webscan.sh
Options for days. Cewl (-> pplfinder), Nikto, directory scanning, WFuzz attack, or a combo
## terminalshot.py
When using terminator, quickly save a screenshot of the terminal without having to choose where to save.
TODO: Add option to enable save dialog again, in context menu
## terminalsearch.py
Select some text in terminator, right click, and search `SELECTEDTEXT exploit` in google.
Originally forked from https://github.com/msudgh/terminator-search
TODO: Add custom trailing words context menu and pull re https://github.com/msudgh/terminator-search/pull/2

## ching.sh
Runs some steg tools. A few of which are not installed by default.

## .bash_aliases
Various helpers, mostly related to BOF exercises.





