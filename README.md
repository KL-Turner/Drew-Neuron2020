# 2019 Slow Oscillations Review

Summary of the Pre-processing of data: All code and functions are located in the 'Pre-processing-scripts' sub-folder. Each stage contains a sub-functions folder with its respective dependencies. If a
specific function is used in multiple stages, it is located only in the first stage that it is used. If it is used in the MainScript that analyzes the data and generates the figures, the sub-function will be
located in that folder.

Data was acquired simultaneously from MScan (Two photon data, neural data, force sensor) and a LabVIEW program (see: https://github.com/KL-Turner/LabVIEW-DAQ) (whisker angle, duplicate of force sensor)

Stage One Processing

    Extract the whisker angle, force sensor data, and notes from the camera's binary file and the LabVIEW TDMS files. Create a '*_LabVIEW.mat' structure corresponding to the date/time of the imaging.
    
    For more information on whisker tracking, see https://github.com/KL-Turner/Whisker-Tracking

| ![](https://github.com/KL-Turner/Slow-Oscillations-Review/blob/master/Images/2P_Whiskers.PNG) |
|:--:|
| *Figure 1: Graphical User Input (GUI) front interface* |

Stage Two Processing

    Extract the notes from a MS Excel sheet containing the 5 minute session's information.

| ![](https://github.com/KL-Turner/Slow-Oscillations-Review/blob/master/Images/excelFileExample.PNG) |
|:--:|
| *Figure 1: Graphical User Input (GUI) front interface* |

    Analyze the diameter changes from the two-photon TIFF stack by drawing the region of interest and axis along the vessel for the radon transform/FWHD.
| ![](    https://github.com/KL-Turner/Slow-Oscillations-Review/blob/master/Images/vesseROIexample.PNG) |
|:--:|
| *Figure 1: Graphical User Input (GUI) front interface* |

    Set the binarization threshold for the whisker acceleration and force sensor (movement).

    Bandpass filter the raw neural data to create specific neural bands (Delta, Theta, Alpha, Beta, Gamma, MUA). These are not used in this specific analysis, but are otherwise included. These bands are filtered 
        using the  z-p-k -> sos-g from a 4th-order butterworth filter. The bandpassed signals are then smoothed using the z-p-k -> sos-g from a 4th-order butterworth 10 Hz lowpass filter. The smoothed signals
        are then squared and resampled down to 30 Hz.

    Smooth the force sensor and whisker angle signals using the z-p-k -> sos-g from a 2nd-order butterworth 20 Hz lowpass filter. Resample both down to 30 Hz.

    Correct any offset between the MScan data and LabVIEW data by analyzing the cross correlation of the duplicated force sensor signals. Align the data in time, and trim the first 10 and last 10 seconds
        down to the expected length based on the respective signal's sampling rate. Typically, the delay between the MScan trigger and the LabVIEW acquisition start was less than 1 second.

    Combine the important MScan and LabVIEW data into a 'MergedData' structure. 

Stage Three Processing

    





    Calculate the spectrogram for each session using the raw neural data. The raw data is detrended, trimmed to expected length, and applied a 60 Hz notch filter. One-second spectrograms with [1 1] tapers and a 0.1
        second step size are calculated, along with five-second spectrograms with [5 9] tapers and 0.2 second step size.