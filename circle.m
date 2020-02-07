function h = circle(x,y,r,rgbcolor,linestyle)
d = r*2;
px = x-r;
py = y-r;
h = rectangle('Position',[px py d d],'Curvature',[1,1],'LineStyle',linestyle,'EdgeColor',rgbcolor);
daspect([1,1,1])
