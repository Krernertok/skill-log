# skill-log

The skill-log script can be used to log the usage of skills. Technically, you can use it for logging any one-word "things" but the intent of this script is to log how often skills have been used.

To get started, you can log the usage of, for example, `bash` like this:

    sl bash

The script will prompt you to confirm that you want to add a new skill. Press the `y` button to confirm. The prompt is meant to prevent logging skills with an incorrect name (e.g. due to typos).

To list logged skills:

    sl -l

Further instructions on usage can be found below in the **Usage** section.


## Installing

1. Clone this repository
2. Make sure the sl file is an executable, for example:

    ```
    chmod u+x sl
    ```

3. Create a symbolic link to the executable inside a directory in your PATH, for example:

    ```
    sudo ln -s "$(pwd)/sl" /usr/local/bin/sl
    ```


## Usage

Log using a skill:

    sl bash

List *all* skills that have been logged so far along with the total number they have been logged:

    sl -l

Print out a report for a specific year or month:

    sl -r 2022-12

Print out a report for a specific skill:

    sl -r 2022-12 bash

Usage information (a.k.a. help):

    sl -h

