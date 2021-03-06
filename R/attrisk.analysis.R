attrisk.analysis <- function(sites=NULL, subpop=NULL, design, data.ar,
   response.var, stressor.var, response.levels=rep(list(c("Poor","Good")),
   length(response.var)), stressor.levels=rep(list(c("Poor","Good")),
   length(stressor.var)), popcorrect=FALSE, pcfsize=NULL, N.cluster=NULL,
   stage1size=NULL, sizeweight=FALSE, vartype="Local", conf=95) {

################################################################################
# Function: attrisk.analysis
# Purpose: Relative Risk Analysis for Probability Survey Data
# Programmer: Tom Kincaid
# Date: November 2, 2010
# Last Revised: August 19, 2014
# Description:
#   This function organizes input and output for attributable risk analysis of
#   categorical data generated by a probability survey.
# Arguments:
#   sites = a data frame consisting of two variables: the first variable is site
#     IDs, and the second variable is a logical vector indicating which sites to
#     use in the analysis.  The default is NULL.
#   subpop = a data frame describing sets of populations and subpopulations for
#     which estimates will be calculated.  The first variable is site IDs.  Each
#     subsequent variable identifies a Type of population, where the variable
#     name is used to identify Type.  A Type variable identifies each site with
#     one of the subpopulations of that Type.  The default is NULL.
#   design = a data frame consisting of design variables.  Variables should be
#     named as follows:
#       siteID = site IDs
#       wgt = final adjusted weights, which are either the weights for a
#         single-stage sample or the stage two weights for a two-stage sample
#       xcoord = x-coordinates for location, which are either the x-coordinates
#         for a single-stage sample or the stage two x-coordinates for a two-
#         stage sample
#       ycoord = y-coordinates for location, which are either the y-coordinates
#         for a single-stage sample or the stage two y-coordinates for a two-
#         stage sample
#       stratum = the stratum codes
#       cluster = the stage one sampling unit (primary sampling unit or cluster)
#         codes
#       wgt1 = final adjusted stage one weights
#       xcoord1 = the stage one x-coordinates for location
#       ycoord1 = the stage one y-coordinates for location
#       support = support values - the value one (1) for a site from a finite
#         resource or the measure of the sampling unit associated with a site
#         from an extensive resource, which is required for calculation of
#         finite and continuous population correction factors.
#       swgt = size-weights, which is the stage two size-weight for a two-stage
#         sample.
#       swgt1 = stage one size-weights.
#   data.ar = data frame of categorical response and stressor variables, where
#     each variable consists of two categories.  If response or stressor
#     variables include more than two categories, occurrences of those
#     categories must be removed or replaced with missing values.  The first
#     column of this argument is site IDs.  Subsequent columns are response and
#     stressor variables.  Missing data (NA) is allowed.
#   response.var = character vector providing names of columns in argument
#     data.ar that contain a response variable, where names may be repeated.
#     Each name in this argument is matched with the corresponding value in the
#     stressor.var argument.
#   stressor.var = character vector providing names of columns in argument
#     data.ar that contain a stressor variable, where names may be repeated.
#     Each name in this argument is matched with the corresponding value in the
#     response.var argument.  This argument must be the same length as argument
#     response.var.
#   response.levels = list providing the category values (levels) for each
#     element in the response.var argument.  This argument must be the same
#     length as argument response.var.  The default is a list containing the
#     values "Poor" and "Good" for the first and second levels, respectively, of
#     each element in the response.var argument.
#   stressor.levels = list providing the category values (levels) for each
#     element in the stressor.var argument.  This argument must be the same
#     length as argument response.var.  The default is a list containing the
#     values "Poor" and "Good" for the first and second levels, respectively, of
#     each element in the stressor.var argument.
#   popcorrect = a logical value that indicates whether finite or continuous
#     population correction factors should be employed during variance
#     estimation, where TRUE = use the correction factor and FALSE = do not use
#     the correction factor.  The default is FALSE.  To employ the correction
#     factor for a single-stage sample, values must be supplied for argument
#     pcfsize and for the support variable of the design argument.  To employ the
#     correction factor for a two-stage sample, values must be supplied for
#     arguments N.cluster and stage1size, and for the support variable of the
#     design argument.
#   pcfsize = size of the resource, which is required for calculation of finite
#     and continuous population correction factors for a single-stage sample.
#     For a stratified sample this argument must be a vector containing a value
#     for each stratum and must have the names attribute set to identify the
#     stratum codes.  The default is NULL.
#   N.cluster = the number of stage one sampling units in the resource, which is
#     required for calculation of finite and continuous population correction
#     factors for a two-stage sample.  For a stratified sample this argument
#     must be a vector containing a value for each stratum and must have the
#     names attribute set to identify the stratum codes.  The default is NULL.
#   stage1size = size of the stage one sampling units of a two-stage sample,
#     which is required for calculation of finite and continuous population
#     correction factors for a two-stage sample and must have the names
#     attribute set to identify the stage one sampling unit codes.  For a
#     stratified sample, the names attribute must be set to identify both
#     stratum codes and stage one sampling unit codes using a convention where
#     the two codes are separated by the & symbol, e.g., "Stratum 1&Cluster 1".
#     The default is NULL.
#   vartype = the choice of variance estimator, where "Local" = local mean
#     estimator and "SRS" = SRS estimator.  The default is "Local".
#   conf = the confidence level.  The default is 95%.
# Results:
#   A data frame of attributable risk estimates for all combinations of
#   population Types, subpopulations within Types, and response variables.
#   Standard error and confidence interval estimates also are provided.
# Other Functions Required:
#   dframe.check - check site IDs, the sites data frame, the subpop data frame,
#     and the data.ar data frame to assure valid contents and, as necessary,
#     create the sites data frame and the subpop data frame
#   uniqueID - creates unique site IDs by appending a unique number to each
#     occurrence of a site ID
#   input.check - check input values for errors, consistency, and compatibility
#     with psurvey.analysis analytical functions
#   attrisk.est - compute the attributable risk estimate
# Example:
#   mysiteID <- paste("Site", 1:100, sep="")
#   mysites <- data.frame(siteID=mysiteID, Active=rep(TRUE, 100))
#   mysubpop <- data.frame(siteID=mysiteID, All.Sites=rep("All Sites", 100),
#     Resource.Class=rep(c("Agr", "Forest"), c(55,45)))
#   mydesign <- data.frame(siteID=mysiteID, wgt=runif(100, 10, 100),
#     xcoord=runif(100), ycoord=runif(100), stratum=rep(c("Stratum1",
#     "Stratum2"), 50))
#   mydata.ar <- data.frame(siteID=mysiteID, RespVar1=sample(c("Poor", "Good"),
#     100, replace=TRUE), RespVar2=sample(c("Poor", "Good"), 100, replace=TRUE),
#     StressVar=sample(c("Poor", "Good"), 100, replace=TRUE), wgt=runif(100, 10,
#     100))
#   attrisk.analysis(sites=mysites, subpop=mysubpop, design=mydesign,
#     data.ar=mydata.ar, response.var=c("RespVar1", "RespVar2"),
#     stressor.var=rep("StressVar", 2))
################################################################################

# Create a data frame for warning messages

   warn.ind <- FALSE
   warn.df <- NULL
   fname <- "attrisk.analysis"

# Check that the required arguments have been provided

   if(is.null(design))
      stop("\nThe design data frame must be provided.")
   if(!is.data.frame(design))
      stop("\nThe design argument must be a data frame.")
   if(is.null(data.ar))
      stop("\nThe data.ar data frame must be provided.")
   if(is.null(response.var))
      stop("\nThe response argument must be provided.")
   if(is.null(stressor.var))
      stop("\nThe stressor argument must be provided.")

# Check the design data frame for required names

   design.names <- names(design)
   temp <- match(design.names, c("siteID", "wgt", "xcoord", "ycoord",
      "stratum", "cluster", "wgt1", "xcoord1", "ycoord1", "support", "swgt",
      "swgt1"), nomatch=0)
   if(any(temp == 0)) {
      temp.str <- vecprint(design.names[temp == 0])
      stop(paste("\nThe following names used in the design data frame do not match the required names:\n", temp.str))
   }

# Check the sites data frame, the design data frame, the subpop data frame, and
# the data.ar data frame to assure valid contents

   temp <- dframe.check(sites, design, subpop, NULL, NULL, data.ar,
      design.names)
   sites <- temp$sites
   design <- temp$design
   subpop <- temp$subpop
   data.ar <- temp$data.risk

# Assign variables from the design data frame

   siteID <- design$siteID
   wgt <- design$wgt
   xcoord <- design$xcoord
   ycoord <- design$ycoord
   stratum <- design$stratum
   cluster <- design$cluster
   wgt1 <- design$wgt1
   xcoord1 <- design$xcoord1
   ycoord1 <- design$ycoord1
   support <- design$support
   swgt <- design$swgt
   swgt1 <- design$swgt1

# Check site IDs for repeat values and, as necessary, create unique site IDs and
# output a warning message

   temp <- sapply(split(siteID, siteID), length)
   if(any(temp > 1)) {
      warn.ind <- TRUE
      temp.str <- vecprint(names(temp)[temp > 1])
      warn <- paste("The following site ID values occur more than once among the values that were \ninput to the function:\n", temp.str, sep="")
      act <- "Unique site ID values were created.\n"
      warn.df <- rbind(warn.df, data.frame(func=I(fname),
         subpoptype=NA, subpop=NA, indicator=NA, stratum=NA, warning=I(warn),
         action=I(act)))
      siteID <- uniqueID(siteID)
      subpop[,1] <- siteID
      data.ar[,1] <- siteID
   }

# Assign some required values from the subpop data frame

   ntypes <- dim(subpop)[2]
   typenames <- names(subpop)

# Check arguments response, stressor, response.levels, and stressor.levels for
# compatibility and for valie values

   nvar <- length(response.var)
   if(length(stressor.var) != nvar)
      stop("\nArgument stressor must be the same length as argument response.")
   if(length(response.levels) != nvar)
      stop("\nArgument response.levels must be the same length as argument response.")
   if(length(stressor.levels) != nvar)
      stop("\nArgument stressor.levels must be the same length as argument response.")
   if(any(sapply(response.levels, function(x) length(x) != 2)))
      stop("\nEach element of argument response.levels must contain only two values.")
   if(any(sapply(response.levels, function(x) !is.character(x))))
      stop("\nEach element of argument response.levels must contain character values.")
   if(any(sapply(stressor.levels, function(x) length(x) != 2)))
      stop("\nEach element of argument stressor.levels must contain only two values.")
   if(any(sapply(stressor.levels, function(x) !is.character(x))))
      stop("\nEach element of argument stressor.levels must contain character values.")

# Assign a logical value to the indicator variable for a stratified sample

   stratum.ind <- length(unique(stratum)) > 1

# If the sample is stratified, convert stratum to a factor, determine stratum 
# levels, and calculate number of strata

   if(stratum.ind) {
      stratum <- factor(stratum)
      stratum.levels <- levels(stratum)
      nstrata <- length(stratum.levels)
   } else {
      stratum.levels <- NULL
      nstrata <- NULL
   }

# Assign a logical value to the indicator variable for a two stage sample

   cluster.ind <- length(unique(cluster)) > 1

# If the sample has two stages, convert cluster to a factor, determine cluster 
# levels, and calculate number of clusters

   if(cluster.ind) {
      if(stratum.ind) {
         cluster.in <- cluster
         cluster <- tapply(cluster, stratum, factor)
         cluster.levels <- sapply(cluster, levels, simplify=FALSE)
         ncluster <- sapply(cluster.levels, length)
      } else {
         cluster <- factor(cluster)
         cluster.levels <- levels(cluster)
         ncluster <- length(cluster.levels)
      }
   }

# If the population correction factor is to be used, ensure that support values
# are provided

   if(popcorrect && is.null(support))
      stop("\nThe logical value that indicates whether finite or continuous population \ncorrection factors should be employed during variance estimation was set to \nTRUE, but support values were not provided in the design data frame.")

# Assign the value of popcorrect to the indicator variable for use of the
# population correction factor

   pcfactor.ind <- popcorrect

# If the sample uses size-weights, ensure that size weights are provided

   if(sizeweight) {
      if(is.null(swgt))
         stop("\nThe logical value that indicates whether size-weights should be employed in the analysis was set to \nTRUE, but size-weights were not provided in the design data frame.")
      if(cluster.ind && is.null(swgt1))
         stop("\nThe sample has two stages and the logical value that indicates whether size- \nweights should be employed in the analysis was set to TRUE, but stage one \nsize-weights were not provided in the design data frame.")
   }

# Assign the value of sizeweight to the indicator variable for use of size
# weights

   swgt.ind <- sizeweight

# Determine the number of response values

   nresp <- dim(design)[1]

# Check for compatibility of input values

      temp <- input.check(nresp, wgt, NULL, NULL, xcoord, ycoord, stratum.ind,
         stratum, stratum.levels, nstrata, cluster.ind, cluster, cluster.levels,
         ncluster, wgt1, xcoord1, ycoord1, NULL, pcfactor.ind, pcfsize,
         N.cluster, stage1size, support, swgt.ind, swgt, swgt1, vartype, conf,
         subpop=subpop)
      pcfsize <- temp$pcfsize
      N.cluster <- temp$N.cluster
      stage1size <- temp$stage1size

# If the sample was stratified and had two stages, then reset cluster to its 
# input value

   if(stratum.ind && cluster.ind)
      cluster <- cluster.in

# If the sample has two stages, determine whether there are a sufficient number
# of sites in each stage one sampling unit to allow variance calculation

   if(cluster.ind) {
      for(itype in 2:ntypes) {
         temp <- apply(table(cluster, subpop[,itype]) == 1, 2, sum)
         ind <- tapply(cluster, subpop[,itype], function(x)
            length(unique(x)))
         if(any(temp == ind)) {
            temp.str <- vecprint(names(temp)[temp == ind])
            warn.df <<- warn.df
            stop(paste("\nA variance estimate cannot be calculated since all of the stage one sampling \nunits contain a single stage two sampling unit for the following \nsubpopulation(s) of population ", typenames[itype], ":\n", temp.str, "\nEnter the following command to view the warning messages that were generated: \nwarnprnt() \n", sep=""))
         }
         if(any(temp > 0)) {
            temp.str <- vecprint(names(temp)[temp > 0])
            warn <- paste("Since they include one or more stage one sampling units with a single site, \nthe mean of the variance estimates for stage one sampling units with two or \nmore sites will be used as the variance estimate for stage one sampling units \nwith one site for the following subpopulation(s) of population\n", typenames[itype], ":\n", temp.str, sep="")
            act <- "The mean of the variance estimates will be used.\n"
            warn.df <- rbind(warn.df, data.frame(func=I(fname),
               subpoptype=NA, subpop=NA, indicator=NA, stratum=NA,
               warning=I(warn), action=I(act)))
         }
      }
   }

# As necessary, assign missing values to the design variables

   if(is.null(xcoord))
      xcoord <- rep(NA, nresp)
   if(is.null(ycoord))
      ycoord <- rep(NA, nresp)
   if(is.null(stratum))
      stratum <- rep(NA, nresp)
   if(is.null(cluster))
      cluster <- rep(NA, nresp)
   if(is.null(wgt1))
      wgt1 <- rep(NA, nresp)
   if(is.null(xcoord1))
      xcoord1 <- rep(NA, nresp)
   if(is.null(ycoord1))
      ycoord1 <- rep(NA, nresp)
   if(is.null(support))
      support <- rep(NA, nresp)
   if(is.null(swgt))
      swgt <- rep(NA, nresp)
   if(is.null(swgt1))
      swgt1 <- rep(NA, nresp)

# Recreate the design data frame

   design <- data.frame(siteID=siteID, wgt=wgt, xcoord=xcoord, ycoord=ycoord,
      stratum=stratum, cluster=cluster, wgt1=wgt1, xcoord1=xcoord1,
      ycoord1=ycoord1, support=support, swgt=swgt, swgt1=swgt1)

# Loop through all response variables

   varnames <- paste(response.var, "and", stressor.var)
   nrow <- 0 
   for(ivar in 1:nvar) {

# Loop through all types of populations

      for(itype in 2:ntypes) {

# Find unique subpopulations of this type of population

         subpopnames <- levels(factor(subpop[,itype]))	

# Loop through all subpopulations of this type

         for(isubpop in 1:length(subpopnames)) {

# Select sites in a subpopulation

            subpop.ind <- subpop[,itype] == subpopnames[isubpop]
            subpop.ind[is.na(subpop.ind)] <- FALSE

# Determine whether the subpopulation is empty

            if(all(is.na(data.ar[subpop.ind, response.var[ivar]]) |
                   is.na(data.ar[subpop.ind, stressor.var[ivar]]))) {
               warn.ind <- TRUE
               warn <- paste("Subpopulation", subpopnames[isubpop], "of population type", typenames[itype], "for indicators", varnames[ivar], "\ncontains no data.  No analysis was performed.\n")
               act <- "None.\n"
               warn.df <- rbind(warn.df, data.frame(func=I(fname),
                  subpoptype=I(typenames[itype]),
                  subpop=I(subpopnames[isubpop]), indicator=I(varnames[ivar]),
                  stratum=NA,  warning=I(warn), action=I(act)))
               next
            }

# Determine whether the subpopulation contains a single value

            if(sum(!(is.na(data.ar[subpop.ind, response.var[ivar]]) |
                     is.na(data.ar[subpop.ind, stressor.var[ivar]]))) == 1) {
               warn.ind <- TRUE
               warn <- paste("Subpopulation", subpopnames[isubpop], "of population type", typenames[itype], "for indicators", varnames[ivar], "\ncontains a single value.  No analysis was performed.\n")
               act <- "None.\n"
               warn.df <- rbind(warn.df, data.frame(func=I(fname),
                  subpoptype=I(typenames[itype]),
                  subpop=I(subpopnames[isubpop]), indicator=I(varnames[ivar]),
                  stratum=NA,  warning=I(warn), action=I(act)))
               next
            }

# For a stratified sample, remove values from pcfsize, N.cluster, and stage1size
# for strata that do not occur in the subpopulation

            if(stratum.ind) {
               temp.pcfsize <- pcfsize[!is.na(match(names(pcfsize),
                  unique(design[subpop.ind, 5])))]
               temp.N.cluster <- N.cluster[!is.na(match(names(N.cluster),
                  unique(design[subpop.ind, 5])))]
               temp.stage1size <- stage1size[!is.na(match(names(stage1size),
                  unique(design[subpop.ind, 5])))]
            } else {
               temp.pcfsize <- pcfsize
               temp.N.cluster <- N.cluster
               temp.stage1size <- stage1size
           }

# Estimate attributable risk for the response variable

            temp <- attrisk.est(response=data.ar[subpop.ind,response.var[ivar]],
               stressor=data.ar[subpop.ind,stressor.var[ivar]],
               response.levels=response.levels[[ivar]],
               stressor.levels=stressor.levels[[ivar]],
               wgt=design[subpop.ind,2], xcoord=design[subpop.ind,3],
               ycoord=design[subpop.ind,4], stratum=design[subpop.ind,5],
               cluster=design[subpop.ind,6], wgt1=design[subpop.ind,7],
               xcoord1=design[subpop.ind,8], ycoord1=design[subpop.ind,9],
               popcorrect=pcfactor.ind, pcfsize=temp.pcfsize,
               N.cluster=temp.N.cluster, stage1size=temp.stage1size,
               support=design[subpop.ind,10], sizeweight=swgt.ind,
               swgt=design[subpop.ind,11], swgt1=design[subpop.ind,12],
               vartype=vartype, conf=conf, check.ind=FALSE, warn.ind=warn.ind,
               warn.df=warn.df, warn.vec=c(typenames[itype],
               subpopnames[isubpop], varnames[ivar]))
            temp.ar <- data.frame(Response=response.var[ivar],
               Stressor=stressor.var[ivar],
               NResp=temp$Results$CellCounts[3,3],
               Estimate=temp$Results$AttRisk,
               StdError.log=temp$Results$ARlog.se,
               LCB=temp$Results$ConfLimits[1],
               UCB=temp$Results$ConfLimits[2],
               WeightTotal=temp$Results$WeightTotal,
               CellCounts.11=temp$Results$CellCounts[1,1],
               CellCounts.12=temp$Results$CellCounts[1,2],
               CellCounts.21=temp$Results$CellCounts[2,1],
               CellCounts.22=temp$Results$CellCounts[2,2],
               CellProportions.11=temp$Results$CellProportions[1,1],
               CellProportions.12=temp$Results$CellProportions[1,2],
               CellProportions.21=temp$Results$CellProportions[2,1],
               CellProportions.22=temp$Results$CellProportions[2,2])
            names(temp.ar)[6:7] <- c(paste("LCB", conf, "Pct", sep=""),
                                     paste("UCB", conf, "Pct", sep=""))
            warn.ind <- temp$warn.ind
            warn.df <- temp$warn.df

# Assign attributable risk estimate for the response variable to a data frame

            if(nrow == 0) {
               arsum <- data.frame(Type=typenames[itype], 
                  Subpopulation=subpopnames[isubpop], temp.ar, 
                  row.names=1)
               nrow <- 1
            } else {
               arsum <- rbind(arsum, data.frame(Type=typenames[itype], 
                  Subpopulation=subpopnames[isubpop], temp.ar, 
                  row.names=(nrow+1)))
               nrow <- nrow + 1
            }

# End of the loop for subpopulations

         }

# End of the loop for type of population

      }

# End of the loop for response variables

   }


# As necessary, output a message indicating that warning messages were generated
# during execution of the program

   if(warn.ind) {
      warn.df <<- warn.df
      if(nrow(warn.df) == 1)
         cat("During execution of the program, a warning message was generated.  The warning \nmessage is stored in a data frame named 'warn.df'.  Enter the following command \nto view the warning message: warnprnt()\n")
      else
         cat(paste("During execution of the program,", nrow(warn.df), "warning messages were generated.  The warning \nmessages are stored in a data frame named 'warn.df'.  Enter the following \ncommand to view the warning messages: warnprnt() \nTo view a subset of the warning messages (say, messages number 1, 3, and 5), \nenter the following command: warnprnt(m=c(1,3,5))\n"))
   }

# Assign consecutive numbers to the row names of the output data frame

   row.names(arsum) <- 1:nrow(arsum)

# Return the data frame

   arsum
}
