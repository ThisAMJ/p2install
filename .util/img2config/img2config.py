from PIL import Image

# Change this for your image
img_path = 'in.png'

# Resize image to 100 width for console
# You should also squash it down vertically so it fits
width = 100
img = Image.open(img_path, 'r')
wpercent = width / float(img.size[0])
hsize = int((float(img.size[1]) * float(wpercent)))
img = img.resize((width, hsize), Image.LANCZOS)
pix_vals = list(img.getdata())
i = 0
with open(img_path + '.cfg', 'w') as f:
    for x in pix_vals:
        a = '%02x%02x%02x' % x
        if ((i + 1) % width == 0):
            a = f'sar_echo {a} "#"\n'
        else:
            a = f'sar_echo_nolf {a} "#"\n'
        i = i + 1
        f.write(a)
