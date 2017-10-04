# SwiftyRestAPI

SwiftyRestAPI is a in development project which generates swift files, SwiftyRestAPI is divided into two modules, Model Generator and API Generator.

## Table of contents

* [Team](#team)
* [Setup the project](#setup-the-project)
* [Running Swifty](#running-swifty)
* [Examples](#examples)

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

2. You will get an interactive prompt that will guide you the rest of the way.

### Current status

- SwiftyRestAPI is in ALPHA stage. 
- It was built as a proof of concept to see if doing something like this was possible with Swift & Swift Package Manager.

#### Future Work
##### These next steps are crucial in order to get it to Beta level:

- Accept more input types (Postman, Paw, APIBlueprint, etc.)
- Be able to generate more output types (Currently only supports Swift/Requestr generated code)
- Be able to accept more Json Types. Nested dictionaries, arrays, and optionals, for example.

### Examples

API input example:
```
{
  "categories" : [
    {
      "name" : "Users",
      "endpoints" : [
        {
          "urlParameters" : [

          ],
          "resourceName" : "User",
          "isResourceArray" : false,
          "name" : "getUser",
          "method" : "GET",
          "relativePath" : "\/users\/1"
        },
        {
          "urlParameters" : [

          ],
          "resourceName" : "User",
          "isResourceArray" : false,
          "name" : "postUser",
          "method" : "POST",
          "relativePath" : "\/users\/1"
        }
      ]
    },
    {
      "name" : "Places",
      "endpoints" : [
        {
          "urlParameters" : [

          ],
          "resourceName" : "Place",
          "isResourceArray" : true,
          "name" : "getPlaces",
          "method" : "GET",
          "relativePath" : "\/places"
        },
        {
          "urlParameters" : [

          ],
          "resourceName" : "Place",
          "isResourceArray" : false,
          "name" : "postPlace",
          "method" : "POST",
          "relativePath" : "\/places\/1"
        },
        {
          "urlParameters" : [

          ],
          "resourceName" : "Place",
          "isResourceArray" : false,
          "name" : "putPlace",
          "method" : "PUT",
          "relativePath" : "\/places\/1"
        }
      ]
    }
  ],
  "basePath" : "http:\/\/www.icalialabs.com\/"
}
```
Model input example:
```
{
  "firstName" : "Jorge",
  "age" : 22,
  "lastName" : "Elizondo",
  "isAdult" : true,
  "height" : 1.81
}
```
