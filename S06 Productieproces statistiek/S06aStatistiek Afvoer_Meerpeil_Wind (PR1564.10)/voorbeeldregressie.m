
ltxt  = [];
ttxt  = [];
xtxt  = [];
ytxt  = [];
Xtick = [];
Ytick = [];

%Ang, Tang, p 290
diepte = [6 8 14 14 18 20 20 24 28 30]';    %onafh
sterkte = [28 58 50 83 71 101 129 150 129 158]'/100;    %afh

x=[ones(length(diepte),1), diepte];
y= sterkte;
[b,bint,r,rint,stats] = regress(y,x)

%uitvoer
%{
y = b(1) + b(2)x = 0.18 + 0.0516x
b =
  1.8389e-002   
  5.1572e-002

bint =
 -3.4885e-001  3.8562e-001
  3.2919e-002  7.0225e-002

r =
 -4.7821e-002
  1.4903e-001
 -2.4040e-001
  8.9603e-002
 -2.3669e-001
 -3.9830e-002
  2.4017e-001
  2.4388e-001
 -1.7241e-001
  1.4450e-002

rint =
 -4.2303e-001  3.2739e-001
 -2.2972e-001  5.2779e-001
 -6.2871e-001  1.4791e-001
 -3.4467e-001  5.2387e-001
 -6.3560e-001  1.6223e-001
 -4.8616e-001  4.0650e-001
 -1.5555e-001  6.3589e-001
 -1.3446e-001  6.2222e-001
 -5.4782e-001  2.0300e-001
 -3.6788e-001  3.9678e-001

stats =
  8.3555e-001  4.0648e+001  2.1465e-004  3.6877e-002
vermoedelijk:
    R^2         F-waarde   p-waarde Fstat  s^2 van Y|x
%}


rcoplot(r,rint)



%{


The example comes from Chatterjee and Hadi [41] in a paper on regression diagnostics. 
The data set (originally from Moore [42]) has five predictor variables and one response. 
load moore
X = [ones(size(moore,1),1) moore(:,1:5)];

Matrix X has a column of ones, and then one column of values for each of the five predictor variables. 
The column of ones is necessary for estimating the y-intercept of the linear model. 
y = moore(:,6);
[b,bint,r,rint,stats] = regress(y,X);

The y-intercept is b(1), which corresponds to the column index of the column of ones. 
stats
stats =
    0.8107   11.9886    0.0001

The elements of the vector stats are the regression R2 statistic, the F statistic 
(for the hypothesis test that all the regression coefficients are zero), 
and the p-value associated with this F statistic. 

R2 is 0.8107 indicating the model accounts for over 80% of the variability in 
the observations. The F statistic of about 12 and its p-value 
of 0.0001 indicate that it is highly unlikely that all of the regression coefficients are zero. 
rcoplot(r,rint)

The plot shows the residuals plotted in case order (by row). The 95% confidence intervals about 
these residuals are plotted as error bars. The first observation is an outlier since its error bar does not cross the zero reference line. 

In problems with just a single predictor, it is simpler to use the polytool function 
(see Polynomial Curve Fitting Demo). This function can form an X matrix with predictor 
values, their squares, their cubes, and so on.
%}