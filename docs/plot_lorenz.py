"""Render the README animations from the ModelSim list dump.

Usage (from the repo root):  python docs/plot_lorenz.py list.txt
Needs numpy, matplotlib and ffmpeg on PATH. Output is written into docs/.
"""
import os, sys, shutil, subprocess
import numpy as np
import matplotlib

src = os.path.abspath(sys.argv[1] if len(sys.argv) > 1 else "list.txt")
os.chdir(os.path.dirname(os.path.abspath(__file__)))
rows = []
for line in open(src):
    p = line.split()
    if len(p) == 5 and p[1].startswith("+"):
        try: rows.append((int(p[0]), int(p[2]), int(p[3]), int(p[4])))
        except ValueError: pass
np.save("sim.npy", np.array(rows, dtype=np.int64))

matplotlib.use('Agg')
import matplotlib.pyplot as plt
from matplotlib.collections import LineCollection
a=np.load('sim.npy'); s=a[:,1:]/2**20; x,y,z=s.T
BG='#0d1117'
def gif(name,frames_dir,fps):
    subprocess.run(['ffmpeg','-y','-loglevel','error','-framerate',str(fps),'-i',f'{frames_dir}/%04d.png',
      '-vf','split[a][b];[a]palettegen=max_colors=128:stats_mode=diff[p];[b][p]paletteuse=dither=bayer:bayer_scale=4:diff_mode=rectangle',
      name],check=True)
    print(name, os.path.getsize(name)//1024,'KB')
def fresh(d):
    shutil.rmtree(d,ignore_errors=True); os.makedirs(d)

# 1) 3D: trajectory drawn while camera rotates
N=8000; fr=120; d='f3d'; fresh(d)
cmap=plt.get_cmap('plasma')
for i in range(fr):
    n=int(N*min(1,(i+1)/(fr*0.75)))
    fig=plt.figure(figsize=(5,5),dpi=96,facecolor=BG); ax=fig.add_subplot(projection='3d',facecolor=BG)
    seg=np.arange(0,n,1)
    for k in range(0,len(seg)-1,100):
        j=seg[k:k+101]; ax.plot(x[j],y[j],z[j],color=cmap(0.15+0.8*k/ max(1,len(seg))),lw=0.7)
    ax.scatter([x[n-1]],[y[n-1]],[z[n-1]],color='white',s=12)
    ax.set_xlim(-22,22); ax.set_ylim(-30,30); ax.set_zlim(0,52); ax.set_axis_off(); ax.set_box_aspect((44,60,52),zoom=1.35)
    ax.view_init(elev=12,azim=-60+i*3)
    fig.subplots_adjust(0,0,1,1); fig.savefig(f'{d}/{i:04d}.png',facecolor=BG); plt.close(fig)
gif('lorenz_3d.gif',d,20)

# 2) x-z "oscilloscope" view with fading tail
d='fxz'; fresh(d); fr=150; step=60; tail=1500
for i in range(fr):
    n=tail+i*step
    fig,ax=plt.subplots(figsize=(5.6,4.2),dpi=96,facecolor=BG); ax.set_facecolor(BG)
    ax.plot(x[:n],z[:n],color='#1f6feb',lw=0.3,alpha=0.35)
    t=np.arange(n-tail,n); pts=np.stack([x[t],z[t]],1)
    lc=LineCollection(np.stack([pts[:-1],pts[1:]],1),cmap='viridis',linewidths=1.4)
    lc.set_array(np.linspace(0,1,tail-1)); lc.set_alpha(None); ax.add_collection(lc)
    ax.plot(x[n-1],z[n-1],'o',color='white',ms=4)
    ax.set_xlim(-22,22); ax.set_ylim(0,54); ax.axis('off')
    ax.text(0.02,0.95,f'clock {n:6d}',transform=ax.transAxes,color='#8b949e',family='monospace',fontsize=9)
    fig.subplots_adjust(0,0,1,1); fig.savefig(f'{d}/{i:04d}.png',facecolor=BG); plt.close(fig)
gif('lorenz_xz.gif',d,25)

# 3) x,y,z waveforms scrolling (like the ModelSim wave window)
d='fwave'; fresh(d); fr=100; W=4000; step=80
cols=['#ff7b72','#7ee787','#79c0ff']
for i in range(fr):
    a0=i*step; t=np.arange(a0,a0+W)
    fig,axs=plt.subplots(3,1,figsize=(6.4,3.6),dpi=96,facecolor=BG,sharex=True)
    for ax,v,c,l,lim in zip(axs,(x,y,z),cols,('x','y','z'),((-22,22),(-30,30),(0,54))):
        ax.set_facecolor(BG); ax.plot(t,v[t],color=c,lw=1); ax.set_ylim(*lim); ax.set_xlim(t[0],t[-1])
        ax.set_ylabel(l+'_out',color=c,family='monospace',rotation=0,labelpad=26)
        ax.tick_params(colors='#8b949e',labelsize=7); [sp.set_color('#30363d') for sp in ax.spines.values()]
        ax.grid(color='#21262d',lw=0.5)
    axs[-1].set_xlabel('clock cycle',color='#8b949e',fontsize=8)
    fig.subplots_adjust(0.15,0.12,0.98,0.98,hspace=0.12); fig.savefig(f'{d}/{i:04d}.png',facecolor=BG); plt.close(fig)
gif('lorenz_waves.gif',d,20)

# 4) static overview PNG of the full run (3 projections)
fig,axs=plt.subplots(1,3,figsize=(12,4),dpi=110,facecolor=BG)
for ax,(u,v,lu,lv) in zip(axs,((x,y,'x','y'),(x,z,'x','z'),(y,z,'y','z'))):
    ax.set_facecolor(BG); ax.plot(u,v,color='#58a6ff',lw=0.15,alpha=0.6)
    ax.set_xlabel(lu,color='#c9d1d9'); ax.set_ylabel(lv,color='#c9d1d9',rotation=0)
    ax.tick_params(colors='#8b949e',labelsize=8); [sp.set_color('#30363d') for sp in ax.spines.values()]
fig.tight_layout(); fig.savefig('lorenz_projections.png',facecolor=BG); print('png ok')

os.remove("sim.npy")
for d in ("f3d", "fxz", "fwave"): shutil.rmtree(d)
