# ETE user functions

## How to load the user functions
 
1. Download R studio and R for your computer if you do not have it yet.

1. Download the RPostgreSQL, reshape2, vegan, and fields packages from http://cran.r-project.org/web/packages/available_packages_by_name.html

    1. Click on the name of the package

    1. Find the Package Source file and click on it to download

1. Open Rstudio

1. In the bottom right-hand pane, click on the Packages tab and click on 'Install Packages'

    1. In the Packages field, write the names of the packages you want to install, separated by commas

    1. Leave the other two fields alone

    1. Click 'Install'

1. Go to File>Open File, and navigate to the UserFunctions.R file we provided for you.

1. Click on the "Source" button in the top panel to load the functions.

## How to use the Functions
 
We have created a suite of user functions that allow you to pull data out of the ETE database by provider. You can pull out yours or anyone else's. The usage commands highlighted in blue can be pasted directly into the console, which is the lower left-hand window in Rstudio.

1. Get your occurrence table in long format: **geteteoccur(provider)**

    1. Usage: `occurrences = geteteoccur("Amatangelo")`

    1. This extracts your table and saves it to an object named occurrences

    1. You can then view this table, do calculations with it, export it to csv, etc.

1. Get your occurrence table in long format for one timebin: **geteteoccurDataset(dataset)**

    1. Usage: `occurrences = geteteoccurDataset("Amatan_Wisc_Pla_Mod")`

    1. This extracts the occurrence table for one dataset/timebin

    1. The dataset must be the exact name of the dataset you want from the datasets table.

1. Put your occurrence table in P/A matrix format: **unmelt2specXsite(table)**

    1. Usage: `PAtable = unmelt2specXsite(occurrences)`

    1. This puts your initial table, occurrences, into an object named *PAtable*

    1. Again, you can view, use, or export this table, among other things.

1. Get a list of your sites and their coordinates: **getlatlong(provider)**

    1. Usage: `sites = getlatlong("Amatangelo")`

    1. This extracts your table and saves it to an object named *sites*, which can then be manipulated

1. Get a list of your sites and their ages: **getages(provider)**

    1. Usage: `ages = getages("Amatangelo")`

    1. This extracts your site ages and saves them to an object named *ages*

1. Get your site traits matrix: **getsitetraits(provider)**

    1. Usage: `sitetraits = getsitetraits("Amatangelo")`

    1. This saves your site traits matrix to a data frame object named *sitetraits*. Note that this data frame is formatted as all characters, so numbers must be converted to numeric format before use in analyses. This can be achieved using the as.numeric() function.

        1. Usage: `sitetraits$[ColumnName] = as.numeric(sitetraits$[ColumnName])`

        1. Square brackets excluded when you type the column name

1. Get your species trait matrix: **getspptraits(provider)**

    1. Usage: `spptraits = getspptraits("Amatangelo")`

    1. This saves your site traits in a data frame called *spptraits*. Note about character formatting under 5ii. applies again.

1. Design your own query of the database: **sql2df(query, maxrows=100000)**

    1. Usage: `output = sql2df("Select * from datasets;", maxrows = 50)`

    1. This sends your query to the database and puts your output table in an object named output. Maxrows is an optional input. If you leave it off it defaults to 100,000 rows, truncating your output table if it is longer than this with a warning.

1. Extract your occurrence tables by timezone into csv files in your working directory: **pa2csv(provider)**

    1. Usage: `pa2csv("Amatangelo")`

    1. This sends your occurrence tables to csv files in your working directory

    1. Your output files will be in wide format

1. Extract your occurrence tables by timezone into a list object: **pa2list(provider)**

    1. Usage: `tables = pa2list("Amatangelo")`

    1. This places your occurrence tables in a list object named tables

    1. List objects are indexed using double brackets. To access the first table in the tables list object type: `tables[[1]]`
 
1. How to view or export your output table.

    1. If you wish to view your output table, simply type its name into the console: `spptraits`

    1. Alternately, you can use the view command: `View(spptraits)`, case sensitive. This will make it pop up as a tab in the upper left window and appear as a pretty table.

    1. If you wish to work with your table in another program, you can export it to a csv.

        1. Click on the files tab in the lower right hand window

        1. Navigate to the folder you'd like to save the csv in. If you can't find your folders, click the '…' button in the upper right corner of that window and a new box should pop up allowing you to navigate from your home directory.

        1. Once you've opened your desired destination folder, click on the 'More' button with the little gear on it, and click "Set as working directory"

        1. In the console, type: `write.csv(mytable, file= "mytable.csv")`. Obviously, the 'mytable' should be replaced with whatever the name of the object is that you'd like to write to the csv and the filename can be whatever you want it to be as long as it ends with .csv.