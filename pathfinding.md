# Dealing with a large sprawling codebase

1. Skim git history to understand how the project has evolved (get my bearings)
  - Just skim commit messages rather than the changes
  - How many authors are there?
  - What is the shape of the history (sloppy, clean)
  - Are there many branches or commits directly to master
  - Is there documentation and how good is it

2. Explore file structure
  - Identify most and least important directories (influential to understanding the application)
    - Confirm expectations
    - This takes the edges of the app off until a middle is discovered
    - Gives a sense of how the file structure makes sense

  - Rails specifics [nouns then verbs]
    - First looks are schema.rb and Gemfile (manifests of data structure of dependencies)
    - Generate an entities relation diagram from the schema
      - You can see how 'important' a model is by how many relationships it has
      - You can see what relations from the data are reflected in the models (which are used)
      - This builds a vocabulary to understand the domain language of the application (names of entities, relationships, attributes)

    - Models
      - The heavier ones likely do more
      - See what business logic is in them. What do they do beyond manage their data and storage

    - Routes
      - An overview of what routes are accessible to the application
      - What is the root
      - Are there any subapps and engines
      - Which resources are available, what parts of CRUD are available, are there important memeber or collection actions

    - Tasks
      - To get a full understanding find any parts that are outside the request response cycle
        - crons, async jobs, rake tasks

3. Active Changing
  - Refactoring
    - Leave artifacts when exploring in the form of changes that better the codebase
    - Especially important when code is hard to understand

  - Hit bugs first
    - Understand what the app does and where something is wrong

  - Proving tests are not funcitonal changes

## Phases
  1. Inspection - just reading, getting bearings, no changes yet
    - A catalog of what the application does and where the code lives
  2. Active learning by changing
  3. Use of the application
    - Chris finds it easier to understand the behavior by looking at the code
    - David finds it easier to understand the code by exploring the behavior
      - An Upsheets page should indicate a controller and model of the same name
