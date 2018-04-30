from zplot import *
import sys
from subprocess import call

def get_ymax(coll_list, t):
    ymax = 0

    for c in coll_list:
        ymax = ymax if t.getmax(c) < ymax else t.getmax(c)
    ymax =float(ymax)
    ymax = ymax + ymax * 0.3

    round_ymax = 0
    round_scale = 10 if ymax < 100 else 100

    while round_ymax < ymax:
        round_ymax += round_scale

    return round_ymax

if len(sys.argv) < 2:
    print("./plot.py memtable.hit.dat")
    sys.exit()

data_file=sys.argv[1]

ctype = 'eps' #if len(sys.argv) < 2 else sys.argv[1]

t = table(file=data_file)
ymax = round(get_ymax(['throughput'], t),-1)

xm = []
w='mrep="%s"' % "cuckoo"
for x, y in t.query(select='workload,line', where=w):
    xrange_max=int(y) * 1.1
    y = str(float(y) - 0.5)
    xm.append((x, y))

c = canvas(ctype, title=data_file, dimensions=['3in', '1.85in'])
d = drawable(canvas=c, xrange=[0,xrange_max], yrange=[-1,ymax], dimensions=['2.7in','1.6in']
            )
options = [('skip_list', 'solid', 0.5, 'red'),
            ('cuckoo', 'solid', 0.5, 'green'),]
#            ('prefix_hash', 'solid', 0.5, 'black'),
#            ('hash_linkedlist', 'solid', 0.5, 'orange'),]


#ym = [ymax // 1000000,ymax]
ym = []
ym.append((ymax, ymax))
#ym.append((global_ymax,global_ymax*1000))

axis(drawable=d, style='box',
#   xauto=[1,15,1],
    title=data_file,
    ytitle="Throughput",
	ytitleshift=[20,0],
    xtitle="Threads",
    xmanual=xm,
    #yauto=[0, ymax, ymax/5],
    ymanual=ym,
    domajortics=False,
    #xaxisposition=0,
    linewidth=0.5, xlabelfontsize=8.0, doxlabels=True,
    )
#xlabelformat='\'%s',
#   xlabelshift=[0,-30],linecolor='black', xlabelfontcolor='black')'
p = plotter()
L = legend()

for opt, ftype, fsize, color in options:
    w = 'mrep="%s"' % opt
    st = table(table=t, where=w)

	#if opt == "prefix_hash" :
		#opt="hash_skiplist"
    barargs = {'drawable':d, 'table':st, 'xfield': 'line', 'yfield': 'throughput',
                'fill': True, 'barwidth': 0.8, 'fillsize': fsize,
                'fillstyle': ftype, 'fillcolor': color,
                'legendtext': opt,'legend' : L}

    p.verticalbars(**barargs)

    L.draw (c, coord=[d.left() + 5, d.top() -6], style='right', skipnext=2, skipspace=45, fontsize=8, height=5, hspace=2)

c.render()
#
#
#call(["mv", _title + ".eps", "figure"])
call(["open", data_file + "." + ctype])

