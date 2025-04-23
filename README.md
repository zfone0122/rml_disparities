# rml_disparities
Repository for - _Recreational Marijuana Laws and Racial Disparities: New Evidence on Arrests and Deaths of Despair_

Authors: Zach Fone, United States Air Force Academy, zachary.fone@afacademy.af.edu; Gokhan Kumpas, California State University - Los Angeles, gkumpas@calstatela.edu; Joseph J. Sabia, San Diego State University, jsabia@sdsu.edu

Abstract: Proponents of recreational marijuana laws (RMLs) argue that ending marijuana prohibition will serve an important social justice objective: reducing racial disparities in arrests. Using data from the Uniform Crime Reports and a generalized difference-in-differences approach, we find that RML adoption is associated with a 498.2-561.2 arrest per 100,000-person (92%-104%) reduction in the marijuana arrest rate among Black adults and a 128.0-144.7 arrest per 100,000-person (78%-88%) reduction in the marijuana arrest rate among White adults.  These findings suggest that RMLs reduce disparities in absolute marijuana arrests between Blacks and Whites.  However, when we explore the effects of RML adoption on racial disparities in (1) non-marijuana drug arrests, and (2) arrests for property and violent crime offenses, we find little evidence that RMLs reduced racial disparities in arrests. In fact, we are unable to rule out the possibility that post-RML reallocation of policing resources to fight non-marijuana drug crime and violent crime may, in some circumstances, widen racial disparities in arrests. Finally, we explore whether RMLs have a racially disparate impact on deaths of despair.  Our findings provide stronger evidence of a causal link between RMLs and reduced opioid-related mortality among Whites than Blacks, consistent with the hypothesis that those hardest hit at the outset of the US opioid epidemic disproportionately gained from state marijuana legalization.

Replication instructions:

1. Software needs:

		a. Stata (SE or MP)

		b. R (to run one R script)

2. Download and unzip the repository from Github

3. Download the data from Zenodo (Note: after unzipping the data files, the folder is roughly 18.5 GB in size):

		a. Unzip and place the "data" folder in the "~\rml_disparities\data\ucr\data\" subdirectory
		b. Now, the directory is as follows:
			rml_disparities\
				master_rml.do
				analysis\
					nvss\
						figures\
						tables\
						Replication NVSS.do
					ucr\
						BOE\
						CS output\
						figures\
						programs\
						tables\
				data\
					nvss\
					ucr\

4. To replicate the project start-to-finish, run the do file "~\rml_disparities\master_rml.do"

		a. The appropriate path MUST be set prior to running any of the files (line 10 of "master_rml.do")
		b. This file calls the do files (in order) to clean the raw data and then produce all estimates included in the paper
   			i. There is one R script that needs to be run separately
				1. "~\rml_disparities\analysis\ucr\programs\CS estimates.R"
		c. NOTE: recompiling/cleaning the source data isn't necessary to produce the output. The "cleaned" analysis files already exist (once data has been downloaded).
