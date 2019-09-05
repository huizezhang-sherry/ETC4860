# Honours project: Exploration of Judicial Facial Expression in Videos and Transcripts of Legal Proceedings

## Stage 1: Obtaining data

The source data of the project are videos from the high court of Australia (http://www.hcourt.gov.au/cases/recent-av-recordings). Turning the video information into tidy facial data can be summarised through the following workflow: 

![Image](images/workflow.png)

The relevant R code can be found in [2.Magick & OpenFace.Rmd](https://github.com/huizezhang-sherry/ETC4860/blob/master/2.Magick%20%26%20OpenFace.Rmd), [2.ffmpeg.Rmd](https://github.com/huizezhang-sherry/ETC4860/blob/master/2.ffmpeg.Rmd) and [3.0csv_proessing.Rmd](https://github.com/huizezhang-sherry/ETC4860/blob/master/3.0csv_processing.Rmd).

## Stage 2: Exploratory Data Analysis

### Missing value imputation 

The missingness in the dataset could be due to the fact that a judge is reading the materials on the desk so the face is not captured for a particular frame or simply because some faces are not detectable for the given resolution of the video stream. However, since that data is in time series structure, simply drop the missing observation will cause the time interval to be irregular and complicate further analysis. There are two different sets of variables that need imputation: the ones end with `_c`, which is binary and the ones end with `_r`, which is a float number. 

Linear interpolation from `forecast` package is suitable to impute the variables end with `_r` and I sample from binomial distribution to impute the variables end with `_c`. More details in [3.1missing.Rmd](https://github.com/huizezhang-sherry/ETC4860/blob/master/3.1missing.Rmd). 

### Data Quality

For the data I get from OpenFace, there is a data quality issue that for some Action units, the intensity score is high while the presence score is zero. This doesnt make sense because if the intensity of an action unit is detected as high, that action unit should have a status of presence. Therefore, I adjust the presence value for the cases, where the intensity > 1. The threshold is set to one because in Ekman's definition of intensity score, a value greater than one means the action unit is at least slightly detected. 

### Exploratory data analysis

The obtained dataset has more than 700 variables for each of the 31 video-judge pairs. This outlines the difficulty of this project: no existing models will present accurate prediction and inference using 700+ variables - how can we incorporate these information to say about the facial expressions of the Justices during the hearings? 

I conduct some exploratory data analysis on one video: `Nauru_a` and find the 700+ variables can be classified as follows with some insights

 - **Confidence**: How confidence OpenFace is with the detection. Confidence is related to the angle that the Justice’s face present in the images. 
 
 - **Gaze**: Gaze tracking: the vector from the pupil to corneal reflection. The dataset contains information on the gaze for both eyes while there is no distinct difference between the eyes. Also I was trying to make animation to track the change of the gaze for judges but no good luck. 
 
 - **Pose**: the location of the head with respect to camera. Pose-related variables don't provide much useful information apart from gaze-related variables. 
 
 - **Landmarking**: landmarking variables for face and eyes. Landmarking variables allows me to plot the face of the judge in a particular frame. More work could be done to explore the usefulness of landmarking variables. 
 
 - **Action Unit**: Action units are used to describe facial expressions. More information can be find [here](https://github.com/TadasBaltrusaitis/OpenFace/wiki/Action-Units) and [this website](https://imotions.com/blog/facial-action-coding-system/) provides a good animation on each action unit. The action unit has intensity measures ending with `_c` and presence measures ending with `_r`. These variables will be the focus of my project and a reference study of using action units to detect human emotion by Kovalchik can be found [here](http://www.sloansportsconference.com/wp-content/uploads/2018/02/2005.pdf). 
 
 R markdown document [3.2EDA_nauru_a.Rmd](https://github.com/huizezhang-sherry/ETC4860/blob/master/3.2EDA_nauru_a.Rmd) records the analysis above. An extension to the full video EDA can be bound [here](https://github.com/huizezhang-sherry/ETC4860/blob/master/3.3EDA.Rmd). 
 
### Text Analysis 

Text analysis conducted using the transcript strapped from the high court of Australia to study the interruptions by the justices. This is used as a benchmark to compare if facial information could help to understand more about Justices' decisions. See [3.5text&outcome.R](https://github.com/huizezhang-sherry/ETC4860/blob/master/3.5%20text%26outcome.R) for more details. 
 
## Stage 3: Action unit 

### Data Structure

The rest of the project focuses on the action unit related variables. If we write all the information in the matrix notation, every element will have four indices: 

- `i` for `judge_id`; 
- `j` for `video_id`; 
- `t` for `frame_id` and 
- `k` for `au_id`. 

The `Y` variables are multivariate as Presence and Intensity. [put math in ]

Using the tidy principle, the data is in a tsibble format with `index = frame_id` and `key = c("judge_id, video_id)`. Different measurements on the presence and intensity of each action units are the variables. 

Assuming all the facial information can be summarised as a `Y` variable with multiple indices `(i,j,t,k)`. We can summarise the information via a linear combination of variables as 

![Y_{ijtk} = \mu + \alpha_i + \beta_j + \gamma_t + \delta_k + CP_2(\alpha_i, \beta_j, \gamma_t, \delta_k) + CP_3(\alpha_i, \beta_j, \gamma_t, \delta_k)](https://latex.codecogs.com/gif.latex?Y_%7Bijtk%7D%20%3D%20%5Cmu%20&plus;%20%5Calpha_i%20&plus;%20%5Cbeta_j%20&plus;%20%5Cgamma_t%20&plus;%20%5Cdelta_k%20&plus;%20CP_2%28%5Calpha_i%2C%20%5Cbeta_j%2C%20%5Cgamma_t%2C%20%5Cdelta_k%29%20&plus;%20CP_3%28%5Calpha_i%2C%20%5Cbeta_j%2C%20%5Cgamma_t%2C%20%5Cdelta_k%29)

where 
- CP_2 is the all possible interaction of the two variables
- CP_3 is the all possible interaction of the three variables


### What can we learn from the action unit data 

 - **What are the most common action units for each judges?**
![most common action units](images/most_common_au.png)

Rank by judge_id: 

|index |Bell | Edelman| Gageler| Keane| Kiefel |Nettle|
|------|-----|-------|------|------|------|------|
|    1 |AU09 | AU02  | AU02 | AU20 | AU02 |AU02  |
|    2 |AU15 | AU20  | AU05 | AU15 | AU25 |AU15  |
|    3 |AU25 | AU01  | AU15 | AU02 | AU20 |AU20  |
|    4 |AU02 | AU14  | AU14 | AU14 | AU45 |AU01  |
|    5 |AU20 | AU15  | AU20 | AU45 | AU14 |AU14  |

It can be seen that AU02(outer eyebrow raise) and AU20(lip stretcher) are both common for all the judges. AU15 and AU14 are also commonly detected for five out of the six judges. Other commonly displayed action units include: AU01, AU09, AU20, AU25 and AU45. 


 - **How does the intensity of action units looks like?**
 
The plot gives an overview of the action unit intensity of all the judges across all the trails. Each bar-and-whisker represents the intensity of all the action units aggregated on time for a particular judge in a specific case. For example, the first bar-and-whisker in case Nauru_a is created using all the 17 action units of Edelman through out the elapsed time in Nauru_a case. 

In Ekman's 20002 FACS manual, the intensity of Action unit is defined based on five classes: Trace(1), Slight(2), Marked or pronounced(3), Severe or extreme(4) and Maximum(5). From the plot, most of the action units have low intensity (almost zero average and lower than one upper bounds) and this is expected because usually in the court room, judges are expected to behave neutral.

Looking carefully, we can find that Judge Nettle seems to have higher average in all the four cases he appears: Nauru_a&b, Rinehart_a &b and judge Bell doesn't seem to have many intensive expressions as we can see from the relatively small amount of dots in the whisker.  
 
![intensity_boxplot](images/intensity_boxplot_au.png)

The second plot filters out the points have intensity greater than 2  (at least "slight" as per Ekman) in the previous plot and plot it against time and color by the speaker. It tells us that Edelman, Gageler and Nettle are the judges have stronger emotion that can be detected (since they have more points with intensity greater than 2). Different judges also have different time where they display stronger emotions. For example, Justice Nettle are more likely to have stronger emotion throughout the time when the appellant is speaking but only at the beginning and ending period when the respondent is speaking.

![intense_point](images/is_intense.png)

## Stage 4: Action unit within judge 

In this section, I use bootstrap simulation to answer the question 

- ***Does each Justice behave consistently in different trails or not?***

### AU presence 

I first use simulation method to find the "normal" percentage of appearance of each AU for each Justices. The simulated mean percentage is then compared with the mean percentage appearance of each individual video to determine if an action unit appears considerably more or less than the "normal" level for each justices. The simulation and comparison procedure can be summarised as follows 

- Step 1: Compute the simulated mean percentage appearance ![\mu_{(i,k)}](https://latex.codecogs.com/gif.latex?%5Cmu_%7B%28i%2Ck%29%7D) for each pair of ![(i,k)](https://latex.codecogs.com/gif.latex?%28i%2Ck%29) using bootstrapping and binomial distribution. Below is an illustration of how bootstrap simulation is applied for *one particular* Justices-AU pair ![(i,k)](https://latex.codecogs.com/gif.latex?%28i%2Ck%29).

  - The replicates ![(r_1, r_2, \cdots, r_n)](https://latex.codecogs.com/gif.latex?%28r_1%2C%20r_2%2C%20%5Ccdots%2C%20r_n%29) for bootstrap simulation are drawn from ![x_{(i,1,1,k)}, x_{(i,1,2,k)}, \cdots, x_{(i,1,T,k)},\cdots, x_{(i,J,1,k)},x_{(i,J,2,k)},  \cdots,x_{(i,J,T,k)} ](https://latex.codecogs.com/gif.latex?x_%7B%28i%2C1%2C1%2Ck%29%7D%2C%20x_%7B%28i%2C1%2C2%2Ck%29%7D%2C%20%5Ccdots%2C%20x_%7B%28i%2C1%2CT%2Ck%29%7D%2C%5Ccdots%2C%20x_%7B%28i%2CJ%2C1%2Ck%29%7D%2Cx_%7B%28i%2CJ%2C2%2Ck%29%7D%2C%20%5Ccdots%2Cx_%7B%28i%2CJ%2CT%2Ck%29%7D)
  
  - The statistics to compute is the mean percentage: ![\mu_{(i,k)} = \frac{1}{n}\sum_{i = 1}^n r_i](https://latex.codecogs.com/gif.latex?%5Cfrac%7B1%7D%7Bn%7D%5Csum_%7Bi%20%3D%201%7D%5En%20r_i)

  - Simulation result for all Justices-AU pair can be written in the matrix notation as 

![\begin{bmatrix}
\mu_{(1,1)} & \cdots & \mu_{(1,k)} \\
\mu_{(2,1)} & \cdots & \mu_{(2,k)} \\
\vdots  && \vdots \\
\mu_{(6,1)}  & \cdots & \mu_{(6,k)} \\
\end{bmatrix}](https://latex.codecogs.com/gif.latex?%5Cbegin%7Bbmatrix%7D%20%5Cmu_%7B%281%2C1%29%7D%20%26%20%5Ccdots%20%26%20%5Cmu_%7B%281%2Ck%29%7D%20%5C%5C%20%5Cmu_%7B%282%2C1%29%7D%20%26%20%5Ccdots%20%26%20%5Cmu_%7B%282%2Ck%29%7D%20%5C%5C%20%5Cvdots%20%26%26%20%5Cvdots%20%5C%5C%20%5Cmu_%7B%286%2C1%29%7D%20%26%20%5Ccdots%20%26%20%5Cmu_%7B%286%2Ck%29%7D%20%5C%5C%20%5Cend%7Bbmatrix%7D)

- Step 2: Compute the mean percentage appearance of each individual video ![\frac{1}{T} \sum_{t = 1}^T x_{(i,j,t,k)}](https://latex.codecogs.com/gif.latex?%5Cfrac%7B1%7D%7BT%7D%20%5Csum_%7Bt%20%3D%201%7D%5ET%20x_%7B%28i%2Cj%2Ct%2Ck%29%7D) for each combination of ![$(i, j, k)$](https://latex.codecogs.com/gif.latex?%24%28i%2C%20j%2C%20k%29%24)

The simulation result is presented below. We expect the simulated interval will be able to include most of the points and the very few outliers would indicate a judge is behaving abnormal in a particular trail. However, what we see here is most of the points are outside the interval. This means that judges behave very different from video to video and thus a simulated overall mean is not very representative of the each individual mean appearance. 

![au_presence_sim](images/sim_result_vis.png). 


### AU Intensity

Todo: 
 - fill in this part 

## Stage 5: Action unit between Judge 

In this section, I use principle component analysis (PCA) to answer the question 

- ***Does the judges behave the same or different from one to another?***

Apart from understand how each Justice behaves consistently or not across all the videos, we are also interested in comparing *across* all the Justices to study who are more animated than others during the hearings. Time index is averaged for each judge and video pair and mathmetically, the matrix supplied to the PCA algorithm can be represented as follows. ![\begin{align}
\begin{bmatrix}
x_{1,1,\bar{t},1} & x_{1,1,\bar{t},2} & \cdots & x_{1,1,\bar{t},K}\\
x_{1,2,\bar{t},1} & x_{1,2,\bar{t},2} & \cdots & x_{1,2,\bar{t},K}\\
\vdots & \vdots & &\vdots\\
x_{1,J,\bar{t},1} & x_{1,J,\bar{t},2} & \cdots & x_{1,2,\bar{t},K}\\
x_{2,1,\bar{t},1} & x_{2,1,\bar{t},2} & \cdots & x_{2,1,\bar{t},K}\\
\vdots & \vdots & &\vdots\\
x_{I,J,\bar{t},1} & x_{I,J,\bar{t},2} & \cdots & x_{I,J,\bar{t},K}
\end{bmatrix}
\end{align}](https://latex.codecogs.com/gif.latex?%5Cbegin%7Balign%7D%20%5Cbegin%7Bbmatrix%7D%20x_%7B1%2C1%2C%5Cbar%7Bt%7D%2C1%7D%20%26%20x_%7B1%2C1%2C%5Cbar%7Bt%7D%2C2%7D%20%26%20%5Ccdots%20%26%20x_%7B1%2C1%2C%5Cbar%7Bt%7D%2CK%7D%5C%5C%20x_%7B1%2C2%2C%5Cbar%7Bt%7D%2C1%7D%20%26%20x_%7B1%2C2%2C%5Cbar%7Bt%7D%2C2%7D%20%26%20%5Ccdots%20%26%20x_%7B1%2C2%2C%5Cbar%7Bt%7D%2CK%7D%5C%5C%20%5Cvdots%20%26%20%5Cvdots%20%26%20%26%5Cvdots%5C%5C%20x_%7B1%2CJ%2C%5Cbar%7Bt%7D%2C1%7D%20%26%20x_%7B1%2CJ%2C%5Cbar%7Bt%7D%2C2%7D%20%26%20%5Ccdots%20%26%20x_%7B1%2C2%2C%5Cbar%7Bt%7D%2CK%7D%5C%5C%20x_%7B2%2C1%2C%5Cbar%7Bt%7D%2C1%7D%20%26%20x_%7B2%2C1%2C%5Cbar%7Bt%7D%2C2%7D%20%26%20%5Ccdots%20%26%20x_%7B2%2C1%2C%5Cbar%7Bt%7D%2CK%7D%5C%5C%20%5Cvdots%20%26%20%5Cvdots%20%26%20%26%5Cvdots%5C%5C%20x_%7BI%2CJ%2C%5Cbar%7Bt%7D%2C1%7D%20%26%20x_%7BI%2CJ%2C%5Cbar%7Bt%7D%2C2%7D%20%26%20%5Ccdots%20%26%20x_%7BI%2CJ%2C%5Cbar%7Bt%7D%2CK%7D%20%5Cend%7Bbmatrix%7D%20%5Cend%7Balign%7D)

The result of PCA can be summarised through the following visualisation. ![pca](images/pca.png)

Since PCs are linear combination of the original variables, we take the absolute value of the fitted PCs and compute the sum to create an index. In this study, the first two fitted PCs are summed to determine the most animated judge and I find that Justices Bell is the most animated, then followed by the Chief Justices Kiefel and Justices Nettle. Edelman and Keane are the more neutral Justices. 

The PCA exercise shows the most important linear combination of the action unit variables, which motivates us to find the most animated judge and thus help to build the judge profile. However, there are a few issues with the current PCA practice: 

- The time index is averaged, thus can't see how variables evolving over time 
- The cumulated variance plot increase quite smoothly indicating the data itself is not very correlated. 

## Stage 6: Emotion Profile 

In this section, I create emotion profile for each of the judge to summarise their emotion characteristics in the hearing. 


|Judge |Characteristics|
|----|--------------------------------|
|Nettle|More stronger emotion; at the beginning and ending period when the respondent is speaking.|
|Bell|Most animated judge (has most influential action unit in both appearance and intensity).|
|Edelman|More stronger emotion but not influential.|
|Gageler|More stronger emotion, relatively neutral.|
|Keane|relatively neutral.|
|Kiefel|relatively neutral.|


