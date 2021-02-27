# Socioeconomic Impacts of COVID-19 in Low-Income Countries: Replication Code

This README describes the directory structure & Stata packages necessary to replicate all analysis for the article Socioeconomic Impacts of COVID-19 in Low-Income Countries. The work relies on the World Bank LSMS and World Bank COVID phone surveys. For more information and to access these phone surveys, visit the World Bank Microdata Library. The relevant surveys are available under under the High-Frequency Phone Survey collection: http://bit.ly/microdata-hfps. We make no guarantee that variables not used in the analysis are cleaned or accurate.

 ## Index
 
 - [Contributors](#contributors)
 - [Data](#data)
 - [Data cleaning](#data-cleaning)
 - [Developing Environment](#developing-environment)

## Contributors

* Ann Furbush
* Anna Josephson 
* Talip Kilic 
* Jeffrey D. Michler

## Data 

The publicly-available data for each survey round is coupled with a basic information document, interview manual, and questionnaire for that round, which can be accessed through: 
 - Ethiopia: http://bit.ly/ethiopia-phonesurvey 
 - Malawi: http://bit.ly/malawi-phonesurvey 
 - Nigeria: http://bit.ly/nigeria-phonesurvey
 - Uganda: http://bit.ly/uganda-phonesurvey 
 
The approach to the phone survey questionnaire design and sampling is comparable across countries. It is informed by the template questionnaire and the phone survey sampling guidelines that have been publicly made available by the World Bank. These can be accessed through: 
 - Template Questionnaire: http://bit.ly/templateqx 
 - Manual: http://bit.ly/interviewermanual
 - Sampling Guidelines: http://bit.ly/samplingguidelines.

## Data cleaning

### Pre-requisites

The data processing and analysis requires a number of user-written Stata programs:
   * 1. `grc1leg2`
   * 2. `palettes`
   * 3. `catplot`
   * 4. `blindschemes` 
   * 5. `mdesc`
   * 6. `estout`
   * 7. `distinct`

The `projectdo.do` file will help you install these.

## Developing Environment

### Step 1

Clone this  repository https://github.com/jdavidm/socioeconomic_impacts_covid_africa. The general repo structure looks as follows:<br>

```stata
evolving_impacts_covid_africa
├────README.md
├────projectdo.do	/* master project file */
├────LICENSE
├────country		/* one dir for each country */
│    ├──wave		/* one file for each wave */
│    └──master		/* master cleaning file for each country */
└────analysis		/* dir for analysis */
```

### Step 2

Open the projectdo.do file and update the global filepath with your username in Section 0 (a).

   ```
    if `"`c(username)'"' == "USERNAME" {
		global		code	"C:/Users/USERNAME/git/socioeconomic_impacts_covid_africa"
		global		data	"C:/Users/USERNAME/socioeconomic_impacts_covid_africa/data"
		global		output	"C:/Users/USERNAME/socioeconomic_impacts_covid_africa/output"
    }
   ```

### Step 3

Set up the file structure on your local machine as outlined below: 

```stata
C:/Users/USERNAME/socioeconomic_impacts_covid_africa
├────output
├──stata_graphs
└────data
     ├──analysis
     ├──ethiopia
     │    ├──refined
     │    └──raw
     │         ├──wave_01
     │         ├──wave_02
     │         ├──wave_03
     │         ├──wave_04
     │         └──wave_05
     ├──malawi
     │    ├──refined
     │    └──raw
     │         ├──wave_01
     │         ├──wave_02
     │         ├──wave_03
     │         └──wave_04
     ├──nigeria
     │    ├──refined
     │    └──raw
     │         ├──wave_01
     │         ├──wave_02
     │         ├──wave_03
     │         ├──wave_04
     │         └──wave_05
     └──uganda
          ├──refined
          └──raw
               ├──wave_01
               ├──wave_02
               └──wave_03
```

### Step 4

Download microdata Stata files from the following links. You will need to create an account with the World Bank if you do not already have one and will be asked to provide a reason for downloading the data. Once data are downloaded, save the data files to the corresponding folders created in Step 3. 
 - Ethiopia Waves 1-5: http://bit.ly/ethiopia-phonesurvey 
 - Malawi Waves 1-4: http://bit.ly/malawi-phonesurvey 
 - Nigeria Waves 1-5: http://bit.ly/nigeria-phonesurvey
 - Uganda Waves 1-3: http://bit.ly/uganda-phonesurvey 

### Step 5

Run the `projectdo.do` file. Output graphs will be saved to the `output` folder. 
