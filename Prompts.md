# These were the prompts used to create the app in Claude (Visual Studio Code)
# in 10 steps

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
        Re-ran the scrapping script with less years to test with new formatting fixes to clean hometown rows. Worked! Or at least it has data and makes a histogram. The data looks like it could be real but upon investigation seems off. There is no way to see individual players and if the info is realiable. It is missing a bunch of players and repeats players for multiple years.

6.
    Prompt:
        Is there a reason so many players are missing from the data and/or repeated sometimes (https://www.on3.com/college/arizona-wildcats/basketball/2025/commits/). It only has 2 players in the csv for this yeat (2025) but there are more. Can we also add a way so i can see the players connected to the hometown so i can QA/QC the data.
    Results:
        Found a bug were it ignored some repeat hometowns and commits. Reworked and asked for me to test with some validations built in. It also added a QA/QC table to see selected commit data inside app while changing date range. Actually really awesome.

7. 
    Prompt:
        Let's tweek some UI, can you make it more vizually appealing, it feels to dark. Lets default the team selected to be only Arizona at first to make less complex for the user, and can we actually put the histogram on another page. I realized i wanted a horizontal box plot with similar features to compare previous classes to the most current. If it's not too crazy, add logos and other things to make it better.
    Results:
        Added some features and asked if I wanted to test before adding logos. I told it to go ahead and add it (yes). Asked if I wanted to make logos fully ofiline (yes). Then asked to prefill team_logo_urls.csv with official on3static logo URLs team-by-team (instead of clearbit domains) so they match athletic marks more closely (yes). Then asked to make one more pass and add images to assets folder to make local (yes).

8. 
    Prompt:
        I love the box plot! Go ahad and rework it the best you can and clean everything up. I want the top guages with all the dashboard stats to stand out more and the box plot to be the main point of this app with the othe vizualizations being supplemental. Make the box plot amazing!! Also add help icons and any instructions/readme's or supplemental info you think we should add to create a good user interface for users.
    Results:
        Finished the app and added appropriate files. Also added a story element for " strongest local footprint, widest current reach, and largest current class, plus labeled benchmark guides for local, national, and long-haul thresholds on the box plot". Asked if I wanted to do one final pass and if I want the "hero area" even stronger with color accents, etc. (yes, but also all the helper '?' do nothing. The histogram mode/ban width should only be when the histogram is showing, the font is also a little small). Asked to do one more pass to check spacing (yes).

9. 
    Prompt:
        Okay, last steps, we need to wrap this up. Move the suplemental plots/tables/how to back to the box plot area so the users can click to them otherwise they are too low to see. Update any UI updates you think will make it more vizually appealing. The dark was a little to dark but now its a little to light. Update anything else you need to as if you are going to finish this up. The colors arent also linked on the histogram? or they look simillar. Asked if I wanted to "Make the histogram even more distinct by using solid current bars and outlined prior bars" (yes). And to do a final color polish (yes).
    Results:
        Updated UI plots, color, saturation, app flow. Got "Error in buildTabset(..., ulClass = paste0("nav nav-", type), id = id, : Tabs should all be unnamed arguments, but some are named: class". Gave to Claude to fix and it did.

10.
    Prompt:
        Last chance, I don't see "basketball" mentioned anywhere. Do one last pass and make it the best you can. Also make buttons and selections look obvious to the user. Then right me a final summary of what this application is and can do. (After complete offered to finish off this Prompts.md file for me - yes!)
    Results:
        Final pass completed successfully. Updated app wording to explicitly reference Big 12 men's basketball (header badge, title/subtitle, dashboard title, hero title, team selector placeholder, and reload button label). Improved control clarity by strengthening selector borders/focus states, making tab buttons more obvious with stronger active/inactive contrast, and enhancing action-button styling. Kept the final polished color system consistent across box plot and histogram with clear current-vs-prior distinction. Fixed the tabset class error, validated syntax (`PARSE_OK`), and produced a final application summary describing purpose, features, views, filters, QA/QC support, and local/offline data + logo workflow.


Claude's description:
This is an interactive Shiny dashboard for analyzing Big 12 men’s basketball recruiting geography over time. It loads local recruiting data, calculates hometown-to-campus distances, and lets users compare recruiting reach by team and year window.

Core capabilities:

Compare current recruiting class vs prior classes with a hero horizontal box plot.
Surface key recruiting KPIs:
total recruits
median and average distance
local share (<=300 miles)
national share (>1000 miles)
long-haul share (>2500 miles)
Switch instantly between views in the same main panel:
Box Plot (primary)
Histogram (supplemental distribution view)
QA/QC table (player-level validation)
How-to guide (interpretation help)
Toggle analysis layers:
benchmark distance markers
individual points on box plot
density overlay on histogram
optional exclusion of very long-distance international records
Use locally stored team logos and CSV-backed data for stable, repeatable runs.
Refresh data from CSV with one obvious control.