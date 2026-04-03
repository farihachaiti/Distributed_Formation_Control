xv = linspace(min(x),max(x));
a2 = polyfit(x,y,2);
y2 = polyval(a2,xv);
a3 = polyfit(x,y,3);
y3 = polyval(a3,xv);

figure(1)

hold on
plot(xv, y2, 'r')
plot(xv, y3, 'm')
hold off
grid