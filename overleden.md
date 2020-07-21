Covid-19 Deaths per day
================

<style type="text/css">
body, td {
   font-size: 20px;
}
code.r{
  font-size: 16px;
}
pre {
  font-size: 12px
}
</style>

# The data

The data is taken from the website of the RIVM:
<https://www.rivm.nl/coronavirus-covid-19/grafieken>.

The figure below shows the daily number of deaths covid-19 cases from
2020/2/27 until 2020/6/25

![](overleden_files/figure-gfm/unnamed-chunk-2-1.png)<!-- -->

The reproductive power function is calculated conditional on the number
of infected in the previous 14 days. So the reproductive power function
can be seen as the probability that an infected from the 14 previous
days, produces a new on.

The estimated reproductive power function is:

![](overleden_files/figure-gfm/unnamed-chunk-3-1.png)<!-- -->

The beginning is quite messy since the conditioning is on less than 14
days. Since after day 60 the number of deaths decreases the number of
deaths in the previous 14 days also decrease leading to an increase of
uncertainty. The gray lines are 1000 parametric bootstrap lines to show
the uncertainty and the increase of towards the end of the series.

# A Markov-switching model

Models with 2 until 9 states were fitted to the data.

The model with 5 states fitted the data best according to Akaike’s
Information Criterion (AIC).

In the figure below the reproductive power function (blue line) and the
path through the the most likely hidden states from the 5 state model
(red line) are shown. As can be seen the estimated states follow the
reproductive power function quit accurately. That this number of states
is needed might be due to the volatility in the time series. However
this model might also overfit the data.

![](overleden_files/figure-gfm/unnamed-chunk-4-1.png)<!-- -->

In the figure below the decoded path for the 5-state model is shown
again (blue line). Besides some going-up and going-down in this path one
might roughly recognize 5 periods. So the decoded path for the 5-state
model is also calculated and shown in the figure below (red line). The
gray vertical line indicates the first 14 days.

The 5 state levels are: state 1 with a level of 0.27, state 2 with a
level of 0.17, state 3 with a level of 0.10, state 4 with a level of
0.06 and state 5 with a level of 0.04.

Using the 5-state model one might come up withe the following periods:

07-3 until 21-3: outbreak state with state level 1;

22-3 until 28-3: state 2.

29-3 until 6-4: state 3

7-4 until 23-4: state 4

23-4 until the end: state 5

The figure below shows the reproductive power function with the
uncertainty (parametric bootstrap lines) and the most likely state
probability path from the 5 state model.

![](overleden_files/figure-gfm/unnamed-chunk-5-1.png)<!-- -->
