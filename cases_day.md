Registrated cases per day
================

# The data

The data is taken from the website of the RIVM:
<https://www.rivm.nl/coronavirus-covid-19/grafieken>.

The figure below shows the daily number of registrated covid-19 cases
from 2020/2/27 until 2020/6/25

![](cases_day_files/figure-gfm/unnamed-chunk-2-1.png)<!-- -->

The reproductive power function is calculated conditional on the number
of infected in the previous 14 days. So the reproductive power function
can be seen as the probability that an infected from the 14 previous
days, produces a new on.

The estimated reproductive power function is:

![](cases_day_files/figure-gfm/unnamed-chunk-3-1.png)<!-- -->

The beginning is quite messy since the conditioning is on less than 14
days. There is also a clear weekend effect as it is in the raw data.

The gray lines are 1000 parametric bootstrap lines to show the
uncertainty. There seems to roughly 4 periods: the first 30 days,
between 30 an 50 days, between 50 and 80 days and the last part.
Approximately between day 80 an 110 the reproductive power seem to rise
again.

# A Markov-switching model

Models with 2 until 11 states were fitted to the data. Due to the large
dispersion in the time series of the covid-19 data it was difficult to
find stable solutions. Nevertheless reasonable estimates were obtained.

The model with 8 states fitted the data best according to Akaike’s
Information Criterion (AIC). This large number of states might be
explained by the large dispersion in the data especially the weekend
effects might have an influence.

In the figure below the reproductive power function (blue line) and the
path through the the most likely hidden states from the 8 state model
(red line) are shown. As can be seen the estimated states follow the
reproductive power function quit accurately. That this number of states
is needed might be due to the volatility in the time series. However
this model might also overfit the data.

![](cases_day_files/figure-gfm/unnamed-chunk-4-1.png)<!-- -->

In the figure below the decoded path for the 8-state model is shown
again (blue line). Besides some going-up and going-down in this path one
might roughly recognize 4 periods. So the decoded path for the 4-state
model is also calculated and shown in the figure below (red line). The
gray vertical line indicates the first 14 days.

![](cases_day_files/figure-gfm/unnamed-chunk-5-1.png)<!-- -->

The 4 state levels are: state 1 with a level of 0.15, state 2 with a
level of 0.08, state 3 with a level of 0.05 and state 4 with a level of
0.03.

Using the 4-state model one might come up withe the following periods:

28-2 until 27-3: outbreak state with state level 1;

28-3 until 18-4: switching between state 2 and 3

19-4 until 19-5: switching between state 3 and 4

20-5 until 13-6: switching between state 2 and 3 (except the first of
june which had state 4 )

18-6 until the end: switching between state 3 and 4

The figure below shows the reproductive power function with the
uncertainty (parametric bootstrap lines) and the most likely state
probability path from the 4 state model.

![](cases_day_files/figure-gfm/unnamed-chunk-6-1.png)<!-- -->
