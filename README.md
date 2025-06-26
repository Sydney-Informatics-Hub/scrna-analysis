# scrna-analysis
A set of notebooks and scripts for analysing single cell RNA sequencing data.

## Installation

These notebooks are based on the R programming language and use a number of bioinformatics R packages, in particular Seurat for single cell sequencing analysis. We have provided an R script in this repository at `install/install.R` which will install all the required packages.

### Installation on NCI

The notebooks are intended to be run on NCI's Australian Research Environment (ARE) platform, as this provides a way of running a web-based interactive R session on a high-performance computing system using an RStudio server. However, installing the required R packages on this system can be a little tricky, so we have also provided a bash script for installing on this platform - `install/install_nci.sh`. To use this script, you will first need to log into NCI's gadi:

```bash
# Replace "user" with your NCI username
ssh user@gadi.nci.org.au
```

Next, clone this repository to a convenient location. This will also be where you will be running the notebooks, so it is a good idea to choose a location with a large amount of storage space. We recommend using the `scratch` filesystem as a temporary location for running these notebooks.

```bash
# Replace "project" with your NCI project code
# or choose another location
cd /scratch/project/

git clone https://github.com/Sydney-Informatics-Hub/scrna-analysis.git

cd scrna-analysis
```

The `install/install_nci.sh` script contains a header section that is read by NCI's PBS scheduler. We have included a couple of placeholder values in here that you will need to update based on your NCI details:

```bash
#!/bin/bash
#PBS -q copyq
#PBS -P proj01
#PBS -l mem=8GB
#PBS -l jobfs=64GB
#PBS -l storage=scratch/proj01+gdata/proj01
#PBS -l walltime=04:00:00
#PBS -l wd
```

Update the placeholder value `proj01` in the header section to your NCI project code.

Finally, you can submit the script to the cluster with `qsub`. The script will install the R packages in a new library location at `${PREFIX}/R/scrna-analysis/4.4`, where `PREFIX=/g/data/${PROJECT}` and `PROJECT` is your NCI project code. You can change the prefix by providing `-v PREFIX="/new/prefix/path` to qsub:

```bash
# Install to default directory
qsub install/install_nci.sh

# Install to /scratch/project/R/scrna-analysis/4.4
qsub -v PREFIX="/scratch/project" install/install_nci.sh
```

The installation process may take ~2h to complete. Once finished, inspect the output logs to ensure all packages were correctly installed.

## Running on ARE

Here we provide step-by-step instructions for specifically running these notebooks on NCI's ARE platform. This assumes you have already installed all the required R packages and cloned the repository to a convenient location on Gadi by following the instructions above in [Installation on NCI](#installation-on-nci).

First, in a web browser, navigate to [are.nci.org.au](https://are.nci.org.au). Follow the prompts to log in using your NCI credentials.

On the main ARE dashboard, under "All Apps", select "RStudio". Do not select "RStudio (Rocker image)", as this is an older version of the RStudio app and isn't supported by these notebooks.

![ARE dashboard](img/are_dashboard.png)

On the new page that appears, you will be presented with a number of parameters to configure for your RStudio session. There is also a checkbox labelled "Show advanced settings", **which you will need to select**.

Use the table below to fill in the required parameters. If you don't see the input box for the parameter, ensure you have selected "Show advanced settings" first.

| parameter | value | notes |
| --------- | ----- | ----- |
| Walltime (hours) | 4 | It is better to request more than you will need as you won't be charged for time that isn't used. |
| Queue | normalbw |  |
| Compute Size | large | Some of the steps in these notebooks require a lot of resources, so we recommend using the large compute size. If you run into memory issues, increasing to a larger compute size should help. |
| Project | Your NCI project code |  |
| Storage | gdata/project+scratch/project | Replace `project` with your NCI project code |
| Modules | R/4.4.2 gcc/14.2.0 | These notebooks are based on R version 4.4.2. They also require the `gcc` version 14.2.0 module to be loaded. |
| Environment variables | R_LIBS_USER="/g/data/project/R/scrna-analysis/4.4" | This tells R where to find all the required packages for these notebooks. Replace `project` with your NCI project code. If you ran `install/install_nci.sh` with an alternate installation prefix (see [Installation on NCI](#installation-on-nci)), you should instead provide `R_LIBS_USER="PREFIX/R/scrna-analysis/4.4"`, where `PREFIX` is that alternate installation prefix. |

Your settings should look something like this:

![Typical ARE settings for RStudio](img/are_settings.png)

We recommend saving your settings so that you can quickly start a new session in the future. At the bottom of the page, click the checkbox labelled "Save settings". In the box below that, type a name for your saved settings and click "Save settings and close". This will take you to a new page with a list of your saved settings. At the top right of this list is a play button arrow. Click this to launch a new session of RStudio with your saved settings.

![Launching an RStudio session on ARE](img/are_launch.png)

You will be brought to a new page that shows the status of your session. It will start out as "Queued", but within a few minutes it should show the status as "Starting" and then "Running". Once running, a button will appear labelled "Connect to RStudio Server". Click this to open RStudio in a new browser tab.

![A queued RStudio job](img/are_queued.png)

![A running RStudio job](img/are_running.png)

Within RStudio, you can use the file browser at the lower right side to navigate to where you cloned the repository and start working through the notebooks.

![A brand new RStudio session](img/rstudio_home.png)

![Navigating to your repository in RStudio](img/rstudio_chdir.png)

![Your repository in RStudio](img/rstudio_repo.png)

![Opening the QC notebook in RStudio](img/rstudio_notebook.png)

You can access your saved settings anytime by going to the [My Interactive Sessions](https://are.nci.org.au/pun/sys/dashboard/batch_connect/sessions) page in the ARE dashboard. Under "Saved Settings" you should see the name you gave your settings. Clicking this link brings you back to the page where you can launch your session.

![Accessing your interactive sessions](img/are_navbar.png)

![Accessing your saved sessions](img/are_saved.png)

![Launching your saved sessions](img/are_launch.png)