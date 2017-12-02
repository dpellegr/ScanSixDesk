import glob
import os
import re
import sys
sys.path.append('/afs/cern.ch/project/sixtrack/SixDesk_utilities/pro/utilities/externals/SixDeskDB/')
import pickle
import sixdeskdb

import numpy as np
import matplotlib as mpl
import matplotlib.pyplot as plt
import matplotlib.cm as cm
from matplotlib import rc
from matplotlib.ticker import MaxNLocator
from matplotlib.ticker import ScalarFormatter

from math import sqrt
from scipy.interpolate import griddata
from datetime import datetime

import contextlib

@contextlib.contextmanager
def nostdout():
  class DummyFile(object):
    def write(self, x): pass
  save_stdout = sys.stdout
  sys.stdout = DummyFile()
  yield
  sys.stdout = save_stdout


def study2da(study, func):
  print 'Processing', study, '...'
  with nostdout():
    try:
      db=sixdeskdb.SixDeskDB.from_dir('./studies/'+study+'/')
    except:
      print 'WARNING: some problems with sixdb occurred while loading the study'   
      return -1.
    try:
      db.mk_da()
    except:
      print 'WARNING: some problems with sixdb occurred while generating the DA table'
      return -1.
    try:
      seed,angle,da=db.get_da_angle().T
    except:
      print 'WARNING: some problems with sixdb occurred while extracting DAs'
      return -1.
  da = np.fabs(da)
  da = da[da>0.1] # remove zeroes
  da = [np.mean(seed) for seed in da] #average over seeds
  print da
  if len(da)==0:
    return 0.0
  return float(func(da)) # eg. np.amin(da)

def file2dic(study, mydic):
# collects the data from the study files into a dictionary
  da = study2da(study, np.amin)
  if da > 0.:
    m = re.match(r"(?:^.*_)(?P<X>-?[0-9]*(\.[0-9]*)?)(?:_)(?P<Y>-?[0-9]*(\.[0-9]*)?)", study)
    x = float(m.group("X"))
    y = float(m.group("Y"))
    key = (x,y)
    #print key
    mydic[key] = da 

def dic2out(mydic):
  out = []
  for key, aperture in mydic.iteritems():
    out.append((key[1],key[0],aperture if (key[1] < 1.11 or key[0] > 101) else 1))
  out.sort()
  return zip(*out) 

##################################################

def valueInFile(filename, valuename):
  with open(filename) as f:
    for line in f:
      trimmed = ''.join(line.split())
      if not trimmed or trimmed[0]=='#':
        continue
      m = re.search(r'export'+valuename+r'=(.*)', trimmed)
      if m:
        return m.group(1)
  raise Exception('"export '+valuename+' = ..." not found in '+filename)

def getWorkspace():
  return valueInFile('sixdeskenv', 'workspace')

def getMaskPrefix():
  return valueInFile('scan_definitions.sh', 'mask_prefix')

def gaussian_filter_nan(U, **kwargs):
  from scipy.ndimage.filters import gaussian_filter
  #from https://stackoverflow.com/a/36307291/2140449
  V=U.copy()
  V[U!=U]=0
  VV=gaussian_filter(V, **kwargs)
  W=0*U.copy()+1
  W[U!=U]=0
  WW=gaussian_filter(W, **kwargs)
  return VV/WW

##################################################
dco = {}
archive="scan_"+getWorkspace()+".pkl"
if os.path.isfile(archive):
  with open(archive, 'rb') as handle:
    dco = pickle.load(handle)
else:
  for filename in glob.glob(getMaskPrefix()+'_*'):
    if ".db" not in filename:
      file2dic(filename, dco)
  with open(archive, 'wb') as handle:
    pickle.dump(dco, handle, protocol=pickle.HIGHEST_PROTOCOL)
out = dic2out(dco)

#now plotting
x = np.unique(np.array(out[0]))
y = np.unique(np.array(out[1]))
y = y[y>79]
dx = x[1]-x[0]
dy = y[1]-y[0]

# for contour
xx1, yy1 = np.meshgrid(x,y) 
# for pcolormesh
xx2, yy2 = np.meshgrid(np.append(x, x[-1]+dx)-dx/2., np.append(y,y[-1]+dy)-dy/2.)

z = griddata((out[0], out[1]), out[2], (xx1, yy1), method='linear') #interpolates missing points
z1 = gaussian_filter_nan(z, sigma=0.8)
z2 = z #gaussian_filter(z, sigma=0.4)

x1, y1 = xx1[0], [row[0] for row in yy1]
x2, y2 = xx2[0], [row[0] for row in yy2]


#rc('font',**{'family':'sans-serif','sans-serif':['Helvetica']})
mpl.rcParams.update({'font.size': 15}) 
plt.rcParams.update({'mathtext.default': 'regular'})

plt.title(r"LHC 2018; $\beta^*$=25 cm; Q=(.313, .317); Q'=15;"+'\n'+r"I$_{MO}$=330 A; 25 ns; $\varepsilon$=2.5 $\mu$m; Min DA.", fontsize=16, y=1.08)
plt.xlabel("Protons per bunch $[10^{11}]$")
plt.ylabel("Half Xing [$\mu rad$]")

plt.gca().yaxis.get_major_formatter().set_useOffset(False)
plt.gca().xaxis.get_major_formatter().set_useOffset(False)

cf = plt.pcolormesh(x2,y2,z2, cmap=cm.RdBu)
#levels = MaxNLocator(nbins=200).tick_values(z.min(), z.max())
#cf = plt.contourf(x1,y1,z, cmap=cm.RdBu, levels=levels)
minDA = 3.0
maxDA = 7.0
plt.clim(minDA, maxDA)
cbar = plt.colorbar(cf, ticks=np.linspace(minDA, maxDA, (maxDA-minDA)*2.+1))
cbar.set_label('DA [$\sigma_{beam}$]', rotation=90)

#add contour lines
levels = [3.0, 4.0, 5.0, 6.0, 7.0, 8.0]
ct = plt.contour(x1, y1, z1, levels, colors='k', linewidths=3)
plt.clabel(ct, colors = 'k', fmt = '%2.1f', fontsize=16)

plt.tight_layout()
plt.savefig(getWorkspace()+'_'+datetime.now().strftime("%Y%m%d")+'.pdf', dpi=300)
plt.show()

