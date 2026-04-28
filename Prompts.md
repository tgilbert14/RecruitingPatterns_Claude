# These were the prompts used to create the app in Claude (Visual Studio Code)

1.
    Prompt: 
        Make me a shiny R app that makes a pretty histogram of all the big 12 basketball teams and each recruits distance traveled to get to their school (miles from highschool to college destination). I want to see patterns in how far colleges recruit players from. it should also update reactively as I update the input dates (years). Make it so recruits in previous years look different than the most current year so I can see if they are still recruiting similar distances.
    
    Results:
        It made a very pretty app.R file that used made up data with a cool UI where you could deselect the default the 16 big 12 teams. I did not test the apps plot because I wanted to see real data.

2.  
    Prompt:
        You made up data to "match" historical recruiting distances, did you get real data? you can get that data from 247 sports (player hometown/from/high school from)"
    
    Results:
        It failed once and tired on3 to get the data instead and said it succedded, but everytime you opened the app it tired to scrape all the data every time not matter what you selected. It was also returning no data.

3.  
    Prompt:
        The UI looks pretty, but the scraping isnt working. We just need the data and we can save it to something static and include it in our app. You decide what's best. Claude asked for clarifications: I want to to scrape real data one time, then save it somewhere where we can use it (e.g., a .csv with real data)
    
    Results:
        Created a seperate `scrape_recruits.R` file to run to create a file and added instructions on how to operate the application (DATA_WORKFLOW.md). The scrapping did not work.

4. 
    Prompt:
        I get "ERROR: could not find function "GET" "
    
    Results:
        Found the error and cleaned up file to try again. The next set kind of worked to get data info but did not calculate distances at all, each hometown row looked like "<!-- -->Ogden, UT<!-- -->".

5.
    Prompt: 
        The distances did not calculate at all, here is what the original data scrapped looked like before calculating distances (copied and pasted some of the output from a saved variable as it ran as example).

    Results:
        Re-ran the scrapping script with less years to test with new formatting fixes to clean hometown rows.
