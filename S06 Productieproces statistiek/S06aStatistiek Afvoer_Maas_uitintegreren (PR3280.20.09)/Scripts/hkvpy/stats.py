import numpy as np
import matplotlib.pyplot as plt
import shapely.geometry as shp
from scipy.optimize import curve_fit, bisect
import pandas as pd
import scipy.stats as st
from scipy.interpolate import interp1d as _interp1d
    

def uitintegreren(x, xp, pp, onzp, mup, sigmap, returnp=False):
    """
    Function to integrate uncertainties around an exceedance frequency curve.
    
    Procedure of additive model without limitations following Geerse (2016):
    
    P(V > v) = P(X + Y > v)
             = int dx f(x) P(x + Y > v | X = x)    
             = int dx f(x) P(Y > v - x | X = x)
             = int dx f(x) [1 - F_{Y|X=x}(v-x)]
    
    Where:
        X : Stochast without uncertainty
        Y : Stochast of the uncertainty
        V : Combined stochast

    Parameters
    ----------
    x : list or array
        The x-coordinates at which the expectancy will be calculated
    xp : list or array
        The x-coordinates of the data points
    pp : list or array
        The exceedance probability of the data points
    onzp : list or array
        The x-coordinates on which the uncertainties are defined.
    mup : list or array
        the mean of the uncertainty of the data points. Usually 0, unless
        there is a bias. If only one number is given, it is assumed constant
        over the full range.
    sigmap : list or array
        the standard deviation of the uncertainty of the data points; a normal
        distribution is assumed. If only one number is given, it is assumed constant
        over the full range.
    returnp : bool
        choose whether to return the non integrated values too. This is
        basically the result of interp(x, xp, pp), taking into account the log-
        scale and extrapolating if necessary.
        
    Returns
    -------
    p_exc : array
        Exceedance probabilities
        
    """
    if isinstance(mup, float):
        mup = np.ones_like(onzp) * mup
        
    if isinstance(sigmap, float):
        sigmap = np.ones_like(onzp) * sigmap

    # De mu-waarden op het x-grid
    fMu = _interp1d(onzp, mup, kind = 'linear', fill_value = 'extrapolate')
    xMu = fMu(x)
    
    # De sigma-waarden op het x-grid
    fSig = _interp1d(onzp, sigmap, kind = 'linear', fill_value = 'extrapolate')
    xSig = fSig(x)
    
    # De overschrijdingskansen op het x-grid
    xstap = x[1] - x[0]
    fP = _interp1d(xp, np.log(pp), kind = 'linear', fill_value = 'extrapolate')
    xPov = np.exp(fP(x-0.5*xstap))
    
    if returnp:
        xPov = np.exp(fP(x))
    
    # Bereken het verschil tussen de overschrijdingskansen, de klassekansen
    klassekansen = xPov - np.roll(xPov, -1)
    klassekansen[-1] = 0  #maak laatste klasse 0
    
    
    PovHulp = np.zeros((len(x), len(x)))
    PovHulp = 1 - st.norm.cdf(x - x[:, None], loc = xMu[:, None], scale = xSig[:, None])   #vector van formaat mGrid
    vPov = np.sum(PovHulp * klassekansen[:, None], axis = 0)       

    if not returnp:
        return vPov
    else:
        return vPov, xPov

def uitintegreren_meerpeil(x, xp, pp, onzp, mup, sigmap, epsp, returnp = False):
    """
    Function to 'average out' uncertainties. Calclulates the expectancy at
    a number of levels
    
    Parameters
    ----------
    x : list or array
        The x-coordinates at which the expectancy will be calculated
    xp : list or array
        The x-coordinates of the data points
    pp : list or array
        The exceedance probability of the data points
    mup : list or array
        the mean of the uncertainty of the data points. Usually 0, unless
        there is a bias
    sigmap : list or array
        the standard deviation of the uncertainty of the data points; a normal
        distribution is assumed
    returnp : bool
        choose whether to return the non integrated values too. This is
        basically the result of interp(x, xp, pp), taking into account the log-
        scale and extrapolating if necessary.
        
    Returns
    -------
    p_exc : array
        Exceedance probabilities
        
    """
    
    # Importeer interpoleer module
    from scipy.interpolate import interp1d as _interp1d
    
    # De mu-waarden op het x-grid
    fMu = _interp1d(onzp, mup, kind = 'linear', fill_value = 'extrapolate')
    xMu = fMu(x)
    
    # De sigma-waarden op het x-grid
    fSig = _interp1d(onzp, sigmap, kind = 'linear', fill_value = 'extrapolate')
    xSig = fSig(x)
    
    # De sigma-waarden op het x-grid
    fEps = _interp1d(onzp, epsp, kind = 'linear', fill_value = 'extrapolate')
    xEps = fEps(x)
    
    # De overschrijdingskansen op het x-grid
    fP = _interp1d(xp, np.log(pp), kind = 'linear', fill_value = 'extrapolate')
    xPov = np.exp(fP(x))
        
    # Bereken het verschil tussen de overschrijdingskansen, de klassekansen
    klassekansen = xPov - np.roll(xPov, -1)
    klassekansen[-1] = 0  #maak laatste klasse 0

    sSigNormaal = np.sqrt( np.log(1 + xSig**2/(-xEps)**2) )
    sMuNormaal = np.log( -xEps ) - 0.5 * sSigNormaal**2
    
    PovHulp = np.zeros((len(x), len(x)))
    arg = x - (x + xEps)[:, None] + 1e-13
    PovHulp = 1 - st.norm.cdf(np.log(arg), loc = sMuNormaal[:, None], scale = sSigNormaal[:, None])   #vector van formaat mGrid
    vPov = np.sum(PovHulp * klassekansen[:, None], axis = 0)       

    if not returnp:
        return vPov
    else:
        return vPov, xPov

# def uitintegreren(x, xp, pp, onzp, mup, sigmap, returnp=False, returnip=True):
#     """
#     Function to 'average out' uncertainties. Calculates the weighted average at
#     a number of levels

#     Procedure of additive model without limitations following Geerse (2016):
    
#     P(V > v) = P(X + Y > v)
#              = int dx f(x) P(x + Y > v | X = x)    
#              = int dx f(x) P(Y > v - x | X = x)
#              = int dx f(x) [1 - F_{Y|X=x}(v-x)]
    
#     Where:
#         X : Stochast without uncertainty
#         Y : Stochast of the uncertainty
#         V : Combined stochast
        
#     Parameters
#     ----------
#     x : list or array
#         The x-coordinates at which the expectancy will be calculated
#     xp : list or array
#         The x-coordinates of the data points
#     pp : list or array
#         The exceedance probability of the data points
#     mup : list or array
#         the mean of the uncertainty of the data points. Usually 0, unless
#         there is a bias
#     sigmap : list or array
#         the standard deviation of the uncertainty of the data points; a normal
#         distribution is assumed
#     returnp : bool
#         choose whether to return the non integrated values too. This is
#         basically the result of interp(x, xp, pp), taking into account the log-
#         scale and extrapolating if necessary.
        
#     Returns
#     -------
#     p_exc : array
#         Exceedance probabilities
        
#     """
    
#     # Same grid is used fot dicretisation of z
#     v = x
    
#     # De mu-waarden op het x-grid
#     fMu = _interp1d(onzp, mup, kind = 'linear', fill_value = 'extrapolate')
#     xMu = fMu(x)
    
#     # De sigma-waarden op het x-grid
#     fSig = _interp1d(onzp, sigmap, kind = 'linear', fill_value = 'extrapolate')
#     xSig = fSig(x)
    
#     # De overschrijdingskansen op het x-grid
#     fP = _interp1d(xp, np.log(pp), kind = 'linear', fill_value = 'extrapolate')
#     xPov = np.exp(fP(x))
    
#     # Bereken het verschil tussen de overschrijdingskansen, de klassekansen:
#     # f(x) * dx = P(X > x) - P(X > x + dx)
#     klassekansen = xPov - np.roll(xPov, -1)
#     klassekansen[-1] = 0  #maak laatste klasse 0
    
    
#     # PovHulp is de vector waarin de kans op elke combinatie van waterstand
#     # en onzekerheid wordt opgeslagen    
#     vPov = np.zeros_like(v)
#     if returnip:
#         ipX = np.zeros_like(v)
#         ipY = np.zeros_like(v)
    
#     # int dx f(x) [1 - F_{Y|X=x}(v-x)]
#     for i in range(len(v)):
#         # [1 - F_{Y|X=x}(v-x)]
#         PovHulp = 1 - st.norm.cdf(v[i] - x, xMu, xSig)
#         prod = PovHulp * klassekansen
        
#         vPov[i] = np.sum(prod)
        
#         if returnip:
#             # Zoek de maximale kansbijdrage:
#             argmaxkans = np.argmax(prod)
#             ipX[i] = x[argmaxkans]
#             ipY[i] = (v[i]-x)[argmaxkans]
        
#     # Array-implementatie, sneller maar minder overzichtelijk:
#     #    PovHulp = 1 - st.norm.cdf(v - x[:, np.newaxis], loc = xMu[:, np.newaxis], scale = xSig[:, np.newaxis])
#     #    vPov = np.sum(PovHulp * klassekansen[:, np.newaxis], axis = 0)
    
#     uitvoer = pd.DataFrame(vPov, index=x, columns=['F(V)'])
#     if returnp:
#         uitvoer.loc[:, 'F(X)'] = xPov
#     if returnip:
#         uitvoer.loc[:, 'Xip'] = ipX
#         uitvoer.loc[:, 'Yip'] = ipY

#     return uitvoer

def uitintegrerenY(x, xp, pp, onzp, mup, sigmap, returnp=False, returnip=True):
    """
    Function to 'average out' uncertainties. Calculates the weighted average at
    a number of levels

    Procedure of additive model without limitations following Geerse (2016):
    
    P(V > v) = P(X + Y > v)
             = int dy f(y) P(y + X > v | Y = y)    
             = int dy f(y) P(X > v - y | Y = y)
             = int dy f(y) [1 - F_{X|Y=y}(v-y)]
    
    Where:
        X : Stochast without uncertainty
        Y : Stochast of the uncertainty
        V : Combined stochast
        
    Parameters
    ----------
    x : list or array
        The x-coordinates at which the expectancy will be calculated
    xp : list or array
        The x-coordinates of the data points
    pp : list or array
        The exceedance probability of the data points
    mup : list or array
        the mean of the uncertainty of the data points. Usually 0, unless
        there is a bias
    sigmap : list or array
        the standard deviation of the uncertainty of the data points; a normal
        distribution is assumed
    returnp : bool
        choose whether to return the non integrated values too. This is
        basically the result of interp(x, xp, pp), taking into account the log-
        scale and extrapolating if necessary.
        
    Returns
    -------
    p_exc : array
        Exceedance probabilities
        
    """
    
    # Same grid is used fot dicretisation of z
    v = x
    
    
    # De mu-waarden op het x-grid
    fMu = _interp1d(onzp, mup, kind = 'linear', fill_value = 'extrapolate')
    xMu = fMu(v)
    
    # De sigma-waarden op het x-grid
    fSig = _interp1d(onzp, sigmap, kind = 'linear', fill_value = 'extrapolate')
    xSig = fSig(v)
    
    # De overschrijdingskansen op het x-grid
    fP = _interp1d(xp, np.log(pp), kind = 'linear', fill_value = 'extrapolate')
    xPov = np.exp(fP(x))
    
    # Bereken het verschil tussen de overschrijdingskansen, de klassekansen:
    
    # PovHulp is de vector waarin de kans op elke combinatie van waterstand
    # en onzekerheid wordt opgeslagen    
    vPov = np.zeros_like(v)
    if returnip:
        ipX = np.zeros_like(v)
        ipY = np.zeros_like(v)
    
    # y = np.linspace(-3*xSig[0], 3*xSig[0], 51)
    # dy = y[1]-y[0]
    # klassekansen = st.norm.pdf(y, loc=xMu[0], scale=xSig[0]) * dy
        

    for i in range(len(v)):
        
        # f(y) * dy = f(Y = y) *dy
        y = np.linspace(-3*xSig[i], 3*xSig[i], 51)
        dy = y[1]-y[0]
        klassekansen = st.norm.pdf(y, loc=xMu[i], scale=xSig[i]) * dy
        # print(sum(klassekansen))
#        print(klassekansen)
        # [1 - F_{X|Y=y}(v-y)]
        PovHulp = np.exp(fP(v[i] - y))
        # print(v[i] - y)
        # print(sum(np.exp(fP(v[i] - y)) * klassekansen))
        # print()
        # PovHulp[np.isnan(PovHulp)] = 0.0

        prod = PovHulp * klassekansen
        
        vPov[i] = np.sum(prod)
        
        if returnip:
            # Zoek de maximale kansbijdrage:
            argmaxkans = np.argmax(prod)
            ipY[i] = y[argmaxkans]
            ipX[i] = (v[i]-y)[argmaxkans]
        
    uitvoer = pd.DataFrame(vPov, index=x, columns=['F(V)'])
    if returnp:
        uitvoer.loc[:, 'F(X)'] = xPov
    if returnip:
        uitvoer.loc[:, 'Xip'] = ipX
        uitvoer.loc[:, 'Yip'] = ipY

    return uitvoer




def argdown(x, xarr):
    try:
        ind = np.argmax((xarr - x)[(xarr - x) < 0])
    except:
#        print 'Argument outside of range'
#        print x
#        print xarr
        ind = False
    return ind
    
def argup(x, xarr):
    try:
        ind = np.argmin((xarr - x)[(xarr - x) > 0]) + np.where(((xarr - x) > 0) == True)[0][0]
    except:
#        print 'Argument outside of range'
#        print x
#        print xarr
        ind = False
    return ind

def best_fit(data, method = 'nnlf', PLOT = False, distset = 'small'):
    
    import scipy.stats as st

    mles = []
    parameters = []    
    
    if distset == 'small':
        distributions = [st.alpha, st.anglit, st.arcsine, st.beta, st.betaprime,
                     st.bradford, st.burr, st.cauchy, st.chi, st.chi2, st.cosine,
                     st.dgamma, st.dweibull, st.erlang, st.expon, st.exponweib,
                     st.exponpow, st.f, st.fatiguelife, st.fisk, st.foldcauchy,
                     st.foldnorm, st.frechet_r, st.frechet_l, st.genlogistic,
                     st.genpareto, st.genexpon, st.genextreme, st.gausshyper,
                     st.gamma, st.gengamma, st.genhalflogistic, st.gilbrat,
                     st.gompertz, st.gumbel_r, st.gumbel_l, st.halfcauchy,
                     st.halflogistic, st.halfnorm, st.hypsecant, st.invgamma,
                     st.invgauss, st.invweibull, st.johnsonsb, st.johnsonsu,
                     st.ksone, st.kstwobign, st.laplace, st.logistic, st.loggamma,
                     st.loglaplace, st.lognorm, st.lomax, st.maxwell, st.mielke,
                     st.nakagami, st.ncx2, st.nct, st.norm, st.pareto, st.powerlaw,
                     st.powerlognorm, st.powernorm, st.rdist, st.reciprocal,
                     st.rayleigh, st.rice, st.recipinvgauss, st.semicircular,
                     st.t, st.triang, st.truncexpon, st.truncnorm, st.tukeylambda,
                     st.uniform, st.vonmises, st.wald, st.weibull_min,
                     st.weibull_max, st.wrapcauchy]
   
    else:
        distributions = [st.alpha, st.beta, st.chi, st.chi2, st.dweibull, st.erlang, st.expon, st.frechet_r, st.frechet_l, st.genextreme, st.gausshyper,
                     st.gamma, st.gengamma, st.genhalflogistic, st.gilbrat,
                     st.gompertz, st.gumbel_r, st.gumbel_l, st.halfcauchy,
                     st.halflogistic, st.halfnorm, st.hypsecant, st.invgamma,
                     st.invgauss, st.invweibull, st.johnsonsb, st.johnsonsu,
                     st.ksone, st.kstwobign, st.laplace, st.logistic, st.loggamma,
                     st.loglaplace, st.lognorm, st.lomax, st.maxwell, st.mielke,
                     st.nakagami, st.ncx2, st.nct, st.norm, st.pareto, st.powerlaw,
                     st.powerlognorm, st.powernorm, st.rdist, st.reciprocal,
                     st.rayleigh, st.rice, st.recipinvgauss, st.semicircular,
                     st.t, st.triang, st.truncexpon, st.truncnorm, st.tukeylambda,
                     st.uniform, st.vonmises, st.wald, st.weibull_min,
                     st.weibull_max, st.wrapcauchy]
    
    ranks = np.arange(len(data)+1)/float(len(data))
    ranks = (ranks[1:] + ranks[:-1])/2.
    print(ranks)
    
    for distribution in distributions:
        print('Testing {}'.format(distribution.name))
        params = distribution.fit(data)
        parameters.append(params)
        if method == 'nnlf':
            mle = distribution.nnlf(params, data)
            mles.append(mle)
        elif method == 'lstsq':
            try:
                
                popt, pcov =  curve_fit(distribution.cdf, np.sort(data), ranks, p0 = params)
                mles.append(np.sum(np.power(data - distribution.ppf(ranks), 2)))
            except:
                pass
                mles.append(np.inf)
    results = [(distribution.name, mle) for distribution, mle in zip(distributions, mles) if -9999999 < mle < 9999999]
    
    if PLOT:
        fig, axs = plt.subplots(ncols = 3, nrows = 2)
        axs = axs.ravel()
        
        x = np.linspace(min(data), max(data), 100)
        for i, ax in zip(np.argsort(np.abs(mles))[:6], axs):
            ax.set_title(distributions[i].name+' {}'.format(mles[i]))
            ax.plot(x, distributions[i].cdf(x, *list(parameters[i])), 'b-')
            ax.plot(np.sort(data), ranks, 'r-')
        plt.tight_layout()
    
    return results

class ecdf:
    def __init__(self, data):
        self.data = np.array(data)
        
    def ppf(self, x):
        return np.percentile(self.data, x*100.)
    
    def cdf(self, x):
        return np.sum(self.data <= x)/float(len(self.data))
        
    def pdf(self, steps):
        xs = np.linspace(min(self.data), max(self.data), steps)
        dx = xs[1] - xs[0]
        xl = np.linspace(min(self.data)-dx*0.5, max(self.data)+dx*0.5, steps+1)
        cp = np.array([self.cdf(x) for x in xl])
        cp = np.diff(cp)/(max(xl)-min(xl))*(len(cp)-1)
        return xs, cp, xl
        
    def rvs(self, n):
        indices = (np.random.rand(n)*len(self.data)).astype(int)
        return self.data[indices]
    
class conv:
    """
    Creates a probability density function of independent variables
    
    Assumed is that the first input distribution is a scipy.stats distribution.
    This first dist is used to determine the limits, so it should be the
    biggest.
    
    The second can be a kernel distribution or a scipy.stats distribution.
    """
    
    def __init__(self, dists, loc):
        self.dists = dists
        self.loc = loc
        
        dist1 = dists[0]
        self.ext = np.max(np.abs([dist1.ppf(0.0000001), dist1.ppf(0.9999999)]))
        self.xr = np.linspace(-self.ext, self.ext, 10001)
        self.convpdf = dist1.pdf(self.xr)
        
        for dist in dists[1:]:            
            try:
                pdf2 = dist.pdf(self.xr)
            except:
                pdf2 = dist.evaluate(self.xr)
                
            self.convpdf = np.convolve(self.convpdf, pdf2, 'same')     
            self.convpdf /= np.sum(self.convpdf)
            
            self.convcdf = np.cumsum(self.convpdf)
            
            self.convpdf /= np.sum(self.convpdf) * np.diff(self.xr[:2])[0]

        self.xr += loc        
        
    def cdf(self, x):
        if x < np.min(self.xr):
            print("The requested value is below the range of the distribution")
        elif x > np.max(self.xr):
            print("The requested value is above the range of the distribution")
        return np.interp(x, self.xr, self.convcdf, left = 0.0, right = 1.0)
    
    def ppf(self, p):
        return np.interp(p, self.convcdf, self.xr, left = np.nan, right = np.nan)
    
    def pdf(self, x):
        return np.interp(x, self.xr, self.convpdf, left = 0.0, right = 0.0)

class combined:
    """
    Works best for a tailed symmetric function
    """
    
    def __init__(self, dist1, dist2, T1, T2, T):
        
        r1 = np.interp(np.log(T), np.log([T1, T2]), [0, 1])
        r2 = 1 - r1
        
        print(r1, r2)
        
        Fs = np.logspace(np.log(0.00000001)/np.log(2),np.log(0.5)/np.log(2),5001, base = 2)
        self.Fx = np.r_[Fs, 1-Fs[::-1][1:]]        
        
        lower = 0.00000001
        upper = 0.99999999
        
        p1 = np.percentile(dist1.dataset, self.Fx*100) if type(dist1) is st.kde.gaussian_kde else dist1.ppf(self.Fx)
        p2 = np.percentile(dist2.dataset, self.Fx*100) if type(dist2) is st.kde.gaussian_kde else dist2.ppf(self.Fx)
        
        self.x = (p1 * r1 + p2 * r2)

    def cdf(self, a):
        return np.interp(a, self.x, self.Fx, left = 0.0, right = 1.0)
        
    def pdf(self, a):
        
        dy = np.diff(self.Fx)
        dy = np.r_[dy[0], (dy[1:] + dy[:-1])/2., dy[-1]]               
        
        dx = np.diff(self.x)
        dx = np.r_[dx[0], (dx[1:] + dx[:-1])/2., dx[-1]]        
        
        Px = dy/dx
        p = np.interp(a, self.x, Px, left = 0.0, right = 0.0)
        
        return p
    
    def ppf(self, p):
        return np.interp(p, self.Fx, self.x, left = np.nan, right = np.nan)
        
class Werklijn:
    
    def __init__(self, Q, dists, T = 0):
        self.Q = np.sort(Q)
        self.Pexcd = 1 - np.linspace(1,len(Q)-1, len(Q))/float(len(Q))
        if np.sum(T) == 0:
            self.T = 1./self.Pexcd
        else:
            self.T = np.sort(T)
        
        # Add the distributions to lists
        self.Qdists = [q for (q, dist) in dists]
        self.dists = [dist for (q, dist) in dists]
        self.Tdists = []
        for q in self.Qdists:
#            idown = argdown(q, self.Q)
#            iup = argup(q, self.Q)
            
            t = np.exp(np.interp(q, self.Q, np.log(self.T)))
#            line = shp.LineString(zip(np.log10(self.T)[idown:iup+1], self.Q[idown:iup+1]))
#            Qline = shp.LineString(zip([0., np.max(self.T)], [q]*2))
            self.Tdists.append(t)#np.power(10, line.intersection(Qline).x))
            
        # Sort them on return period
        self.Qdists = np.array(self.Qdists)[np.argsort(self.Tdists)].tolist()
        self.dists = np.array(self.dists)[np.argsort(self.Tdists)].tolist()
        self.Tdists = np.sort(self.Tdists).tolist()   
        
        print('Values at which the distributions are placed:', self.Qdists)
        print('Retrun period at which the distributions are:', self.Tdists)
        
    def plot_line(self):
        fig, ax = plt.subplots()
        ax.plot(self.T, self.Q, ls = '-')
        ax.set_xscale('log')
        ax.grid(which = 'both', ls = '-', color = 'grey')
        ax.set_xlim(1, 1000)
        ax.set_ylim(0,8000)
        for a in [0.975, 0.025]:
            ax.plot(self.T, self.percentile_line(a),ls = '-', color = 'grey')
            x = self.get_excd_P(4000, a)
            ax.plot(x, 4000, 'ro')
        
        plt.show()
        
    def percentile_line(self, a):
        fp = np.array([dist.ppf(a) - dist.ppf(0.5) for dist, T in zip(self.dists, self.Tdists)])
        P = np.interp(np.log10(self.T), np.log10(self.Tdists), (fp)) + self.Q

        return P
            
#     def get_excd_P(self, Q, a):
#         liney = self.create_line(a)
#         iup = argup(Q, liney)
#         idown = argdown(Q, liney) 
#         line = shp.LineString(zip(self.T[idown:iup+1], liney[idown:iup+1]))
#         Qline = shp.LineString(zip([0., 100000.], [Q]*2))
# #         print line.intersection(Qline)
#         return line.intersection(Qline).x
    
    def getQ(self, T):
        T = np.log10(T)
        return np.interp(T, np.log10(self.T), self.Q)      
        
    
    def PQqa(self, Q, a):
        
        if type(a) is float or type(a) is int:
            a = [a]
        elif type(a) is not list:
            a = a.tolist()
    
        p = np.zeros(len(a))
        for i, ia in enumerate(a):
           
            liney = self.Q + ia
            
            if Q > np.max(liney):
                p[i] = p[i-1]
            elif Q < np.min(liney):
                p[i] = 0
                
            else:
                iup = argup(Q, liney)
                idown = argdown(Q, liney)
#                print self.Q, ia
#                print Q, liney, self.T[idown:iup+1]
                line = shp.LineString(zip(np.log10(self.T)[idown:iup+1], liney[idown:iup+1]))
                Qline = shp.LineString(zip([0., np.max(self.T)], [Q]*2))
                p[i] = 1./np.power(10, line.intersection(Qline).x)
                
        return p

#    def get_excd_P(self, Q, a):
#        liney = self.create_line(a)
#        iup = argup(Q, liney)
#        idown = argdown(Q, liney) 
#        line = shp.LineString(zip(self.T[idown:iup+1], liney[idown:iup+1]))
#        Qline = shp.LineString(zip([0., np.max(self.T)], [Q]*2))
##         print line.intersection(Qline)
#        return line.intersection(Qline).x

    def Pa(self, Q, step = 0.00001):

        idown = argdown(Q, self.Q)
        iup = argup(Q, self.Q)
        line = shp.LineString(zip(np.log10(self.T)[idown:iup+1], self.Q[idown:iup+1]))
        Qline = shp.LineString(zip([0., np.max(self.T)], [Q]*2))
        T = np.power(10, line.intersection(Qline).x)
#        print 'New T is:',T
        
        Td = self.Tdists
        # Create the range of percentiles which we will evaluate
        xr = np.arange(step, 1.0, step)

        if T < np.min(Td):
            x = self.dists[0].ppf(xr) - Q
        elif T > np.max(Td):
            x = self.dists[-1].ppf(xr) - Q
        else:
            idown = argdown(T, Td)
            iup = argup(T, Td)
            
            Tdown = np.log10(Td[idown])
            Tup = np.log10(Td[iup])
            Tr = np.log10(T)
            
            # Calculate the ratios of which each distribution is used
            r1 = (Tup - Tr)/(Tup - Tdown)
            r2 = 1 - r1
            
            x = (self.dists[idown].ppf(xr) * r1 + self.dists[iup].ppf(xr) * r2) - Q
            print('minx:', np.min(x), 'maxx:', np.max(x))
        maxx = np.max([np.abs(np.min(x)), np.max(x)])
        a = np.linspace(-maxx, maxx, 1000)
        p = np.interp(a, x, xr)
        
        return p, a
        
    def cdf(self, T, a):

        Q = np.interp(np.log10(T), np.log10(self.T), self.Q)
        xr = np.linspace(0.00000001, 0.99999999, 10000)
        
        Td = np.array(self.Tdists)

        if T < np.min(Td):
            x = self.dists[0].ppf(xr) - np.interp(np.log10(self.Tdists[0]), np.log10(self.T), self.Q)
        elif T > np.max(Td):
            x = self.dists[-1].ppf(xr) - np.interp(np.log10(self.Tdists[-1]), np.log10(self.T), self.Q)
        else:
            idown = argdown(T, Td)
            iup = argup(T, Td)
            
            Tdown = np.log10(Td[idown])
            Tup = np.log10(Td[iup])
            Tr = np.log10(T)
                
            r1 = (Tup - Tr)/(Tup - Tdown)
            r2 = 1 - r1
        
    
            x = (self.dists[idown].ppf(xr) * r1 + self.dists[iup].ppf(xr) * r2) - Q
            print(x)
            
        p = np.interp(a, x, xr)
        
        return p
        
    def integrate_out(self):
        
        
        for q in np.linspace(3001., 7000., 10):
            a = np.linspace(-1500, np.min([1500, q-1.]), 400)
            pqa = w.PQqa(q, a)
            pqa = (pqa[1:] + pqa[:-1])/2.
            pa = w.Pa(q, a)
            pa = (pa[1:] - pa[:-1])
            
            plt.plot(1./np.sum(pa * pqa), q, 'rx')


def get_annual_maxima(where = 'Lobith', mode = 'T', plotpos = (0.3, 0.4), return_years = False):
    """
    Plot de afvoermaxima bij Lobith
    
    Parameters
    ----------
    ax : matplotlib assenstelsel
        assenstelsel waar de maxima aan toegevoegd worden
    mode : character
        T, f of p, respectievelijk terugkeertijd, frequentie of kans
    
    """
    import site

    spdir = site.getsitepackages()[1]
    
    vals = np.loadtxt(spdir + r'\\hkvpy\data\annualmaxima{}.txt'.format(where), delimiter = ';', usecols = [0, 1])
    years = vals[:,0].astype(int)
    vals = vals[:,1]
    
    
    f = (np.arange(1, len(vals)+1) -plotpos[0])[::-1] / ( len(vals) + plotpos[1])

    years = years[np.argsort(vals)]

    if mode == 'f':
        ret = [f, np.sort(vals)]
    elif mode == 'T':
        T = 1./f
        ret =  [T, np.sort(vals)]
    elif mode == 'p':
        p = 1-np.exp(-f)
        ret = [p, np.sort(vals)]
    else:
        ret = []
        raise ValueError('Invalid mode: "{}". Choose f, T or p'.format(mode))
        
    if return_years:
        ret.append(years)
        return ret
    else:
        return ret

def convert_freq_prob(inp, reverse=False):
    """
    Function to convert frequencies to probabilities, or vice versa.

    Parameters
    ----------
    inp : numpy.ndarray
        Input values, can be exceedance frequencies or exceedance probabilities
    reversed : boolean
        If True, convert probabilities to frequencies. (default: False)
    """

    if not reverse:
        # P = 1 - e(-f)
        out = 1 - np.exp(-inp)
    if reverse:
        # f = -log(1 - P)
        out = -np.log(1 - inp)

    return out


def calc_return_period_pot(maxima, Tper, a=0.3, b=0.4, n=None):
    """
    Calculate return for Peak over Threshold

    Parameters
    ----------
    maxima : list or numpy.array
        Annual maxima
    Tper : float/int
        Length of period
    a : float
        Plotting position
    b : float
        Plotting position
    n : int
        Number of samples. If None, length of series is used
    """

    if not (2*a + b) == 1.0:
        raise ValueError('2a + b != 1.0')

    # Sort the values and determine sort order
    order = np.argsort(maxima)[::-1]
    maxima = np.sort(maxima)[::-1]
    
    # Determine number of values
    if n is None:
        n = len(maxima)

    # Determine order
    k = np.arange(len(maxima)) + 1
    P = (n * (k + a + b - 1)) / ((n + b) * Tper)
    T = 1. / P
    
    return T[np.argsort(order)]

def calc_return_period_am(maxima, a=0.3, b=0.4, n=None):
    """
    Calculate return for annual maxima
    2a + b = 1.0
    b = 1 - 2a

    Parameters
    ----------
    maxima : list or numpy.array
        Annual maxima
    a : float
        Plotting position
    b : float
        Plotting position
    n : int
        Number of samples. If None, length of series is used
    """

    if not (2*a + b) == 1.0:
        raise ValueError('2a + b != 1.0')
    
    # Sort values
    if n is None:
        n = len(maxima)

    # Determine order
    k = np.arange(len(maxima)) + 1
    P = (k - a)[::-1] / (n + b)
    T = 1. / convert_freq_prob(P, reverse=True)
    # T = 1./P

    return T[np.argsort(np.argsort(maxima))]

