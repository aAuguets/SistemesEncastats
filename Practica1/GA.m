fo=697;        % per filtrar
entrada = 770; % el que tentra
fm=8e3;
wo=2*pi*fo/fm;
N=205;
t=[1/fm:1/fm:N/fm];
x=sin(2*pi*entrada*t);


s(1)=x(1);
s(2)=x(2)+2*cos(wo)*s(1);
for n=3:N
	  s(n)=x(n)+2*cos(wo)*s(n-1)-s(n-2);
  end

plot(t,s)
    p = (s(n-1)**2) + (s(n-2)**2) - (2*cos(wo)*s(n-1)*s(n-2)) %si resultat gran ok si no dep.
