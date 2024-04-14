from PIL import Image
img = Image.open('astley.jpg')
pixels = img.load()
img_size = 100
img_skip = 2
pY = 0
pZ = 0
fMain = open("draw.cfg", "w")
fCur = open("draw1.cfg", "w")
fCurLen = 0
fI = 1
def newCfg():
    global fI, fMain, fCur, fCurLen
    cfg = "draw" + str(fI)
    fI += 1
    fMain.write("exec {0}\n".format(str(cfg)))
    fCur.close()
    fCur = open(str(cfg) + ".cfg", "w")
    fCurLen = 0
def tryWrite(str: str):
    global fI, fMain, fCur, fCurLen
    length = fCurLen
    # cfg limit at 1MB
    if (length + len(str) > 1000000):
        newCfg()
    fCur.write(str)
    fCurLen += len(str)
def drawLine(x1, y1, z1, x2, y2, z2, r, g, b):
    tryWrite("sar_drawline {0:.3f} {1:.3f} {2:.3f} {3:.3f} {4:.3f} {5:.3f} {6:.0f} {7:.0f} {8:.0f}\n".format(float(x1), float(y1), float(z1), float(x2), float(y2), float(z2), float(r), float(g), float(b)))
newCfg()
w = img_size / img.size[0]
h = img_size / img.size[1]
for x in range(img.size[0]):
    for y in range(img.size[1]):
        if (x % img_skip == 0 & y % img_skip == 0):
            p = pixels[x, y]
            dX = (x / img_skip) * w
            dY = ((img.size[1] - y) / img_skip) * h
            drawLine(0, dX, dY, 0, dX, dY + h, p[0], p[1], p[2])
fCur.close()
fMain.close()
