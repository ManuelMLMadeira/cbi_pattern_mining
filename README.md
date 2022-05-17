# Computer Brain Interface - Pattern Mining

**A Computer-Brain Interface (CBI) approach is an alternative of great interest to the current Brain-Computer Interface (BCI) methods. This is achieved by creating a system that adapts to the user through reliable pattern recognition. EEG recordings of four subjects from an evoked potential stimulus experiment were available and processed via a battery of techniques in line with current research practice, in both time and frequency domains.**

*Project developed in the Processing of Signals in Bioengineering course, at IST (Lisboa)*

See file **report.pdf** for the results of the analysis.

**supplementary_material** contains supporting code and results.

### Folder "participant_processing"

Each file treats data from one subject from whom data was collected.
- **ICA_artifact_removal.m** - ICA technique is applied to filtered data (more detail on filtration below) from that individual and the sources more  highly correlated to the channels Fp1 and Fp2 are removed. The new data is saved;

- **beeps_ica.m** - The raw data is used to extract the timestamps of the instants when the "beep" stimuli are played. Then, all channels are filtered (notch filter, bandpass filter) and this data is saved to be subjected to the ICA technique. The resulting data, pre-processed by ICA, is used in a great variety of processing stages (synchronized averaging, PSD, difference of PSDs from different moments) to each channel and in each moment (before, during, after); using fuction *relpower.m* (also included in folder), the relative powers of the frequency bands of interests are obtained and displayed in tables.

- **sounds_ica.m** - Similar to *beeps_ica.m* but with the timestamps regarding the more complex sounds (boom, ringing, laughing, crying, birds, thunder);

- **STFT_beeps.m** - Spectograms of "beep" stimuli for each channel and in each moment. It can be performed on raw data or on pre-processed (filtered + ICA data). For reasons mentioned in the report, this technique was not used for complex stimuli nor on other subjects.

### Folder "correlation_all_channels"

Files of interest: 
- **CCA_corrcoef_inter.m** - Obtains the correlation values that allow for inter-subject variability analysis. It correlates all the channels of all the subjects for a given stimuli and moment. Makes use of *check_CCA_R.m* and *levels1.m* functions.

- **CCA_corrcoef_beepintra.m** - Obtains the correlation values that allow for intra-subject variability analysis. It correlates all the channels for a given stimuli and individual, in different moments. Makes use of *check_CCA_R_beepi.m* and *levels.m* functions.

- **check_CCA_R.m** - From two matrices (one with the correlation coefficients - R - and other    with the corresponding p_values - P), it outputs a matrix M (nx6) where each row corresponds to an entry where correlation coefficients are bigger than pre-defined threshold (with statistic relevance - p<0.05). The first two columns correspond to the channels where that correlation was found,    the third is the correlation coefficient itself. If that result is significant (p<0.05),    the 4th column takes the boolean True. Otherwise, it is False. The last two elements of each row (5th and 6th columns) are the coordinates of the element analysed in the original P and R matrices. *check_CCA_R_beepi.m* is analogue but for intra-subject variability analysis.

- **levels.m** - converts a matrix of correlation coefficients into a matrix of correlations where there are three different colors according to the value in each entry of the matrix:
	- 0 < C_ij < 0.3    : negligible correlation -> white squares;
	- 0.3 < C_ij < 0.5    : low correlation -> light red;
	- 0.5 < C_ij : significant (medium to very high) correlation -> dark red;

*levels1.m* is analogue but for inter-subject variability analysis.


### Folder "topography_all_channels"

Files of interest: 
- **eegplot.m** - Function whose output is the topographic map of intensities plotted onto image *"brain"*. Its makes use of interpolation methods to designate intensities to the different regions of the brain, based off on single point information (each point equivalent to one channel). The plotted intensities are normalized.

- **(name of subject)_topography.m** - Topography maps of all the stimuli, in all channels and moments are obtained.




