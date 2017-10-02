# SwiftyRestAPI

SwiftyRestAPI is a in development project which generates swift files, SwiftyRestAPI is divided into two modules, Model Generator and API Generator. 

## Table of contents

* [Team](#team)
* [Setup the project](#setup-the-project)
* [Running Swifty](#running-swifty)

### Team

| Name  | Email | Role |
| ------------- | ------------- | ------------- |
| Daniel Lozano  | daniel@icalialabs.com  | Development |
| Jorge Elizondo  | jelizondo@icalialabs.com | Development |

## Development

### Setup the project

1. Clone this repository into your local machine.

  ```bash
  $ git clone git@github.com:IcaliaLabs/SwiftyRestAPI.git
  ```

2. Build the project.

  ```bash
  $ swift build -c release
  ```

3. Move the executable to the bin.

  ```bash
  $ cd .build/release
  $ cp -f SwiftyRestAPI /usr/local/bin/swifty
  ```

4. Now you have SwiftyRestAPI installed!!!

### Running Swifty

1. Run Swifty by typing in the terminal: `swifty`.
