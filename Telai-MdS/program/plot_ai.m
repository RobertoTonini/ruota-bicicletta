
%%-------------------------------------------------------------------------
%%
%%  FUNZIONE PER IL PLOTTAGGIO DELLE AZIONI INTERNE NEL TELAIO
%%  E DEGLI SPOSTAMENTI NODALI (GRAFICI E FILE DI OUTPUT)
%%
%%-------------------------------------------------------------------------

function status=plot_ai(foup)

%..........................................................................
% dichiarazione delle variabili globali
% numeri interi
global n_nod n_elem
% matrici di interi
global inc igl
% matrici di reali
global coor
global ai_nod
global strspars
% vettori di reali
global disp_vec
global F_neE
%..........................................................................

%..........................................................................
% inizializzazione interruttore
% di corretto funzionamento della funzione
status=1;
%..........................................................................

%..........................................................................
% calcoli preliminari: caratteristiche geomeriche
% inizializzazione dei vettori coordinate massime e minime
minxy=zeros(1,2);
maxxy=zeros(1,2);
% valori massimi e minimi delle coordinate dei nodi
minxy=min(coor);
maxxy=max(coor);
% inizializzazione vettore lunghezze
length=zeros(n_elem,1);
% inizializzazione vettore 
% coseno angolo di inclinazione
cosa=zeros(n_elem,1);
% inizializzazione vettore
% seno angolo di inclinazione
sena=zeros(n_elem,1);
% ciclo sugli elementi per la ricerca
% della minima lunghezza
for elem=1:n_elem
  % nodi di estremità
  nod1=inc(elem,1);
  nod2=inc(elem,2);
  % calcolo distanze
  dx=coor(nod2,1)-coor(nod1,1);
  dy=coor(nod2,2)-coor(nod1,2);
  % calcolo lunghezza
  length(elem)=sqrt(dx^2+dy^2);
  % calcolo seno e coseno angolo
  cosa(elem)=dx/length(elem);
  sena(elem)=dy/length(elem);
end
% ricerca lunghezza minima e massima
% per calcolo fattore di scala
minle=min(length);
maxle=max(length);
% calcolo centro telaio
% per plot in finestra
xc=(maxxy(1,1)+minxy(1,1))/2;
yc=(maxxy(1,2)+minxy(1,2))/2;
% calcolo massime dimensioni
% per plot in finestra
xmaxlt=maxxy(1,1)-minxy(1,1)+maxle;
ymaxlt=maxxy(1,2)-minxy(1,2)+maxle;
%..........................................................................

%..........................................................................
% calcolo una norma dei carichi esterni
% per eliminare errori numerici
normfe=norm(F_neE,2);
eps=1.d-10*normfe;
% azioni alle estremità delle aste
% inizializzazione valori trazione
Nval=zeros(2*n_elem,1);
% ciclo lettura
for elem=1:n_elem
  % lettura dati
  Nval(2*(elem-1)+1)=-ai_nod(elem,1);
  Nval(2*(elem-1)+2)=ai_nod(elem,4);
end
% inizializzazione valori taglio
Tval=zeros(2*n_elem,1);
% ciclo lettura
for elem=1:n_elem
  % lettura dati
  Tval(2*(elem-1)+1)=ai_nod(elem,2);
  Tval(2*(elem-1)+2)=-ai_nod(elem,5);
end 
% inizializzazione valori momento
Mval=zeros(2*n_elem,1);
% ciclo lettura
for elem=1:n_elem
  % lettura dati
  Mval(2*(elem-1)+1)=-ai_nod(elem,3);
  Mval(2*(elem-1)+2)=ai_nod(elem,6);
end 
% ricerca valori massimi
Nmax=max(abs(Nval));
Tmax=max(abs(Tval));
Mmax=max(abs(Mval));
% calcolo coefficiente di scala
% il valore massimo delle azioni nel plot deve
% essere paragonabile alle dimensioni della struttura
% caso azione assiale
% test valore massimo non nullo
if(Nmax>eps)
  % calcolo fattore di scala
  Nfs=minle/(2.2*Nmax);
else
  % azioni nulle
  Nfs=0;
end
% caso taglio
% test valore massimo non nullo
if(Tmax>eps)
  % calcolo fattore di scala
  Tfs=minle/(2.2*Tmax);
else
  % azioni nulle
  Tfs=0;
end
% caso momento
% test valore massimo non nullo
if(Mmax>eps)
  % calcolo fattore di scala
  Mfs=minle/(2.2*Mmax);
else
  % azioni nulle
  Mfs=0;
end 
%..........................................................................

%..........................................................................
% lettura dati schermo
set(0,'Units','pixels');
scrnsize=get(0,'ScreenSize');
% calcolo posizionamento figure
% definizione margini
lrwidth=5;
udwidth=70;
% posizione delle figure (4 grafici)
% figura 1 (telaio)
pos1=[0.0*scrnsize(3)+lrwidth,... 
      1/2*scrnsize(4)+lrwidth,...
      1/2*scrnsize(3)-2*lrwidth,...
      1/2*scrnsize(4)-(lrwidth+udwidth)];
% figura 2 (azione assiale)
pos2=[1/2*scrnsize(3)+lrwidth,... 
      1/2*scrnsize(4)+lrwidth,...
      1/2*scrnsize(3)-2*lrwidth,...
      1/2*scrnsize(4)-(lrwidth+udwidth)];
% figura 3 (taglio)
pos3=[0.0*scrnsize(3)+lrwidth,... 
      0.0*scrnsize(4)+lrwidth,...
      1/2*scrnsize(3)-2*lrwidth,...
      1/2*scrnsize(4)-(lrwidth+udwidth)];
% figura 4 (momento)
pos4=[1/2*scrnsize(3)+lrwidth,... 
      0.0*scrnsize(4)+lrwidth,...
      1/2*scrnsize(3)-2*lrwidth,...
      1/2*scrnsize(4)-(lrwidth+udwidth)];
% dimensione finestre per plot
figw=1/2*scrnsize(3)-2*lrwidth;
figh=1/2*scrnsize(4)-(lrwidth+udwidth);
% posizione degli assi per plot
marg=[0.05*figw 0.07*figh 0.9*figw 0.86*figh];
posax=[0.05 0.07 0.9 0.86];
% calcolo dimesioni finestre per plot
% dimensioni con rapporto fisso
ymaxl=(marg(4)/marg(3))*xmaxlt;
xmaxl=(marg(3)/marg(4))*ymaxlt;
% test dimensioni
if(ymaxl>=ymaxlt)
  % ricalcolo ampiezza
  xmaxl=xmaxlt;
elseif(xmaxl>=xmaxlt)
  % ricalcolo ampiezza
  ymaxl=ymaxlt;
end
%..........................................................................

%..........................................................................
% creazione figura telaio
% struttura e tratteggio fibre tese
% per definizione convenzioni di segno
figure('Position',pos1,...
       'Name','Convenzoni di segno');
% disegno assi
axes('Position',posax);
% disegno finestra
axis([(xc-1/2*xmaxl) (xc+1/2*xmaxl) ...
      (yc-1/2*ymaxl) (yc+1/2*ymaxl)]);
% dimensioni della finestra
winxstrt=xc-1/2*xmaxl;
winystrt=yc-1/2*ymaxl;
winwdt=xmaxl;
winhgt=ymaxl;
% disegno telaio
% inizializzazione vettori coordinate
xnod=zeros(2,1);
ynod=zeros(2,1);
% ciclo elementi
for elem=1:n_elem
  % nodi di estremità
  nod1=inc(elem,1);
  nod2=inc(elem,2);
  % coordinate nodi
  xnod(1)=coor(nod1,1);
  xnod(2)=coor(nod2,1);
  ynod(1)=coor(nod1,2);
  ynod(2)=coor(nod2,2);
  % disegno elemento rettilineo
  hold on
  line(xnod,ynod,'Color','k','LineWidth',3);
end
% disegno tratteggio
% distanza linea - tratteggio
dist=minle/20;
% inizializzazione vettori coordinate
vecx=zeros(2,1);
vecy=zeros(2,1);
% ciclo elementi
for elem=1:n_elem
  % lunghezza elemento corrente
  le=length(elem);
  % seno e coseno angolo di inclinazione
  ca=cosa(elem);
  sa=sena(elem);
  % nodi di estremità
  nod1=inc(elem,1);
  nod2=inc(elem,2);
  % coordinate nodi
  xnod(1)=coor(nod1,1);
  xnod(2)=coor(nod2,1);
  ynod(1)=coor(nod1,2);
  ynod(2)=coor(nod2,2);
  % inclinazione elemento corrente
  % calcolo equazioni
  x='s*ca+dist*sa+xnod(1)';
  y='s*sa-dist*ca+ynod(1)';
  % range di valori
  % primo estremo
  s=0;
  % calcolo vettori coordinate;
  vecx(1)=eval(x);
  vecy(1)=eval(y);
  % secondo estremo
  s=le;
  % calcolo vettori coordinate;
  vecx(2)=eval(x);
  vecy(2)=eval(y);
  % disegno elemento rettilineo
  hold on
  line(vecx,vecy,'Color','k','LineWidth',1,'LineStyle','--');
end
% disegno label elementi
% distanza centro label
dist=-minle/5;
% inizializzazione vettori coordinate
vecx=zeros(2,1);
vecy=zeros(2,1);
% ciclo elementi
for elem=1:n_elem
  % lunghezza elemento corrente
  le=length(elem);
  % seno e coseno angolo di inclinazione
  ca=cosa(elem);
  sa=sena(elem);
  % nodi di estremità
  nod1=inc(elem,1);
  nod2=inc(elem,2);
  % coordinate nodi
  xnod(1)=coor(nod1,1);
  xnod(2)=coor(nod2,1);
  ynod(1)=coor(nod1,2);
  ynod(2)=coor(nod2,2);
  % inclinazione elemento corrente
  % calcolo equazioni
  x='s*ca+dist*sa+xnod(1)';
  y='s*sa-dist*ca+ynod(1)';
  % range di valori
  % centro elemento
  s=le/2;
  % calcolo vettori coordinate
  vecx(1)=eval(x)-3/5*abs(dist);
  vecy(1)=eval(y)-1/2*abs(dist);
  vecx(2)=eval(x)+3/5*abs(dist);
  vecy(2)=eval(y)+1/2*abs(dist);
  % posizione di inserimento dei numeri elementi
  pos=[((vecx(1)-winxstrt)/winwdt*marg(3)+marg(1))/figw...
       ((vecy(1)-winystrt)/winhgt*marg(4)+marg(2))/figh...
       (vecx(2)-vecx(1))/winwdt...
       (vecy(2)-vecy(1))/winhgt];
  % scrittura su stringa del numero elemento
  rec=sprintf('%2d',elem);
  % scrittura numero elemento in figura
  hold on
  annotation('textbox',pos,'string',rec,...
    'BackgroundColor','y','FaceAlpha',1,...
    'FontWeight','demi',...
    'HorizontalAlignment','center',...
    'VerticalAlignment','middle');
end
% disegno label nodi
% distanza centro label
dist=-minle/5;
% inizializzazione vettori coordinate
vecx=zeros(2,1);
vecy=zeros(2,1);
% ciclo sui nodi
for i1=1:n_nod
  % calcolo vettori coordinate
  vecx(1)=coor(i1,1)-3/5*abs(dist);
  vecy(1)=coor(i1,2)-1/2*abs(dist);
  vecx(2)=coor(i1,1)+3/5*abs(dist);
  vecy(2)=coor(i1,2)+1/2*abs(dist);
  % posizione di inserimento dei numeri nodi
  pos=[((vecx(1)-winxstrt)/winwdt*marg(3)+marg(1))/figw...
       ((vecy(1)-winystrt)/winhgt*marg(4)+marg(2))/figh...
       (vecx(2)-vecx(1))/winwdt...
       (vecy(2)-vecy(1))/winhgt];
  % scrittura su stringa del numero nodo
  rec=sprintf('%2d',i1);
  % scrittura numero nodo in figura
  hold on
  annotation('textbox',pos,'string',rec,...
    'BackgroundColor','m','FaceAlpha',1,...
    'FontWeight','demi',...
    'HorizontalAlignment','center',...
    'VerticalAlignment','middle');
end
%..........................................................................

%..........................................................................
% creazione figura
% azioni assiali
figure('Position',pos2,...
       'Name','Azioni interne: N');
% disegno assi
axes('Position',posax);
% disegno finestra
axis([(xc-1/2*xmaxl) (xc+1/2*xmaxl) ...
      (yc-1/2*ymaxl) (yc+1/2*ymaxl)]);
% disegno telaio
% inizializzazione vettori coordinate
xnod=zeros(2,1);
ynod=zeros(2,1);
% ciclo elementi
for elem=1:n_elem
  % nodi di estremità
  nod1=inc(elem,1);
  nod2=inc(elem,2);
  % coordinate nodi
  xnod(1)=coor(nod1,1);
  xnod(2)=coor(nod2,1);
  ynod(1)=coor(nod1,2);
  ynod(2)=coor(nod2,2);
  % disegno elemento rettilineo
  line(xnod,ynod,'Color','k','LineWidth',3);
end
% disegno azioni interne
% riempimento diagrammi
% ciclo elementi
for elem=1:n_elem
  % lunghezza elemento corrente
  le=length(elem);
  % seno e coseno angolo di inclinazione
  ca=cosa(elem);
  sa=sena(elem);
  % nodi di estremità
  nod1=inc(elem,1);
  nod2=inc(elem,2);
  % coordinate nodi
  xnod(1)=coor(nod1,1);
  xnod(2)=coor(nod2,1);
  ynod(1)=coor(nod1,2);
  ynod(2)=coor(nod2,2);
  % lettura costanti
  c0=strspars(elem,1,1);
  c1=strspars(elem,1,2);
  c2=strspars(elem,1,3);
  c3=strspars(elem,1,4);
  % inclinazione elemento corrente
  % calcolo equazioni
  x='s*ca+Nfs*(c0+c1*s+c2*s.^2+c3*s.^3)*sa+xnod(1)';
  y='s*sa-Nfs*(c0+c1*s+c2*s.^2+c3*s.^3)*ca+ynod(1)';
  % range di valori
  s=0:le/100:le;
  % vettori di punti per creazione patch
  vecx=[xnod(1) eval(x) xnod(2)];
  vecy=[ynod(1) eval(y) ynod(2)];
  % plottaggio
  hold on
  patch(vecx,vecy,'b');
end
% disegno bordi diagrammi
% ciclo elementi
for elem=1:n_elem
  % lunghezza elemento corrente
  le=length(elem);
  % seno e coseno angolo di inclinazione
  ca=cosa(elem);
  sa=sena(elem);
  % nodi di estremità
  nod1=inc(elem,1);
  nod2=inc(elem,2);
  % coordinate nodi
  xnod(1)=coor(nod1,1);
  xnod(2)=coor(nod2,1);
  ynod(1)=coor(nod1,2);
  ynod(2)=coor(nod2,2);
  % lettura costanti
  c0=strspars(elem,1,1);
  c1=strspars(elem,1,2);
  c2=strspars(elem,1,3);
  c3=strspars(elem,1,4);
  % inclinazione elemento corrente
  % calcolo equazioni
  x='s*ca+Nfs*(c0+c1*s+c2*s.^2+c3*s.^3)*sa+xnod(1)';
  y='s*sa-Nfs*(c0+c1*s+c2*s.^2+c3*s.^3)*ca+ynod(1)';
  % range di valori
  s=0:le/100:le;
  % vettori di punti per creazione plot
  vecx=[eval(x)];
  vecy=[eval(y)];
  % plottaggio
  hold on
  plot(vecx,vecy,'k');
end
%..........................................................................

%..........................................................................
% creazione figura
% taglio
figure('Position',pos3,...
       'Name','Azioni interne: T');
% disegno assi
axes('Position',posax);
% disegno finestra
axis([(xc-1/2*xmaxl) (xc+1/2*xmaxl) ...
      (yc-1/2*ymaxl) (yc+1/2*ymaxl)]);
% disegno telaio
% inizializzazione vettori coordinate
xnod=zeros(2,1);
ynod=zeros(2,1);
% ciclo elementi
for elem=1:n_elem
  % nodi di estremità
  nod1=inc(elem,1);
  nod2=inc(elem,2);
  % coordinate nodi
  xnod(1)=coor(nod1,1);
  xnod(2)=coor(nod2,1);
  ynod(1)=coor(nod1,2);
  ynod(2)=coor(nod2,2);
  % disegno elemento rettilineo
  line(xnod,ynod,'Color','k','LineWidth',3);
end
% disegno azioni interne
% riempimento diagrammi
% ciclo elementi
for elem=1:n_elem
  % lunghezza elemento corrente
  le=length(elem);
  % seno e coseno angolo di inclinazione
  ca=cosa(elem);
  sa=sena(elem);
  % nodi di estremità
  nod1=inc(elem,1);
  nod2=inc(elem,2);
  % coordinate nodi
  xnod(1)=coor(nod1,1);
  xnod(2)=coor(nod2,1);
  ynod(1)=coor(nod1,2);
  ynod(2)=coor(nod2,2);
  % lettura costanti
  c0=strspars(elem,2,1);
  c1=strspars(elem,2,2);
  c2=strspars(elem,2,3);
  c3=strspars(elem,2,4);
  % inclinazione elemento corrente
  % calcolo equazioni
  x='s*ca+Tfs*(c0+c1*s+c2*s.^2+c3*s.^3)*sa+xnod(1)';
  y='s*sa-Tfs*(c0+c1*s+c2*s.^2+c3*s.^3)*ca+ynod(1)';
  % range di valori
  s=0:le/100:le;
  % vettori di punti per creazione patch
  vecx=[xnod(1) eval(x) xnod(2)];
  vecy=[ynod(1) eval(y) ynod(2)];
  % plottaggio
  hold on
  patch(vecx,vecy,'g');
end
% disegno bordi diagrammi
% ciclo elementi
for elem=1:n_elem
  % lunghezza elemento corrente
  le=length(elem);
  % seno e coseno angolo di inclinazione
  ca=cosa(elem);
  sa=sena(elem);
  % nodi di estremità
  nod1=inc(elem,1);
  nod2=inc(elem,2);
  % coordinate nodi
  xnod(1)=coor(nod1,1);
  xnod(2)=coor(nod2,1);
  ynod(1)=coor(nod1,2);
  ynod(2)=coor(nod2,2);
  % lettura costanti
  c0=strspars(elem,2,1);
  c1=strspars(elem,2,2);
  c2=strspars(elem,2,3);
  c3=strspars(elem,2,4);
  % inclinazione elemento corrente
  % calcolo equazioni
  x='s*ca+Tfs*(c0+c1*s+c2*s.^2+c3*s.^3)*sa+xnod(1)';
  y='s*sa-Tfs*(c0+c1*s+c2*s.^2+c3*s.^3)*ca+ynod(1)';
  % range di valori
  s=0:le/100:le;
  % vettori di punti per creazione plot
  vecx=[eval(x)];
  vecy=[eval(y)];
  % plottaggio
  hold on
  plot(vecx,vecy,'k');
end
%..........................................................................

%..........................................................................
% creazione figura
% momento
figure('Position',pos4,...
       'Name','Azioni interne: M');
% disegno assi
axes('Position',posax);
% disegno finestra
axis([(xc-1/2*xmaxl) (xc+1/2*xmaxl) ...
      (yc-1/2*ymaxl) (yc+1/2*ymaxl)]);
% disegno telaio
% inizializzazione vettori coordinate
xnod=zeros(2,1);
ynod=zeros(2,1);
% ciclo elementi
for elem=1:n_elem
  % nodi di estremità
  nod1=inc(elem,1);
  nod2=inc(elem,2);
  % coordinate nodi
  xnod(1)=coor(nod1,1);
  xnod(2)=coor(nod2,1);
  ynod(1)=coor(nod1,2);
  ynod(2)=coor(nod2,2);
  % disegno elemento rettilineo
  line(xnod,ynod,'Color','k','LineWidth',3);
end
% disegno azioni interne
% riempimento diagrammi
% ciclo elementi
for elem=1:n_elem
  % lunghezza elemento corrente
  le=length(elem);
  % seno e coseno angolo di inclinazione
  ca=cosa(elem);
  sa=sena(elem);
  % nodi di estremità
  nod1=inc(elem,1);
  nod2=inc(elem,2);
  % coordinate nodi
  xnod(1)=coor(nod1,1);
  xnod(2)=coor(nod2,1);
  ynod(1)=coor(nod1,2);
  ynod(2)=coor(nod2,2);
  % lettura costanti
  c0=strspars(elem,3,1);
  c1=strspars(elem,3,2);
  c2=strspars(elem,3,3);
  c3=strspars(elem,3,4);
  % inclinazione elemento corrente
  % calcolo equazioni
  x='s*ca+Mfs*(c0+c1*s+c2*s.^2+c3*s.^3)*sa+xnod(1)';
  y='s*sa-Mfs*(c0+c1*s+c2*s.^2+c3*s.^3)*ca+ynod(1)';
  % range di valori
  s=0:le/100:le;
  % vettori di punti per creazione patch
  vecx=[xnod(1) eval(x) xnod(2)];
  vecy=[ynod(1) eval(y) ynod(2)];
  % plottaggio
  hold on
  patch(vecx,vecy,'r');
end
% disegno bordi diagrammi
% ciclo elementi
for elem=1:n_elem
  % lunghezza elemento corrente
  le=length(elem);
  % seno e coseno angolo di inclinazione
  ca=cosa(elem);
  sa=sena(elem);
  % nodi di estremità
  nod1=inc(elem,1);
  nod2=inc(elem,2);
  % coordinate nodi
  xnod(1)=coor(nod1,1);
  xnod(2)=coor(nod2,1);
  ynod(1)=coor(nod1,2);
  ynod(2)=coor(nod2,2);
  % lettura costanti
  c0=strspars(elem,3,1);
  c1=strspars(elem,3,2);
  c2=strspars(elem,3,3);
  c3=strspars(elem,3,4);
  % inclinazione elemento corrente
  % calcolo equazioni
  x='s*ca+Mfs*(c0+c1*s+c2*s.^2+c3*s.^3)*sa+xnod(1)';
  y='s*sa-Mfs*(c0+c1*s+c2*s.^2+c3*s.^3)*ca+ynod(1)';
  % range di valori
  s=0:le/100:le;
  % vettori di punti per creazione plot
  vecx=[eval(x)];
  vecy=[eval(y)];
  % plottaggio
  hold on
  plot(vecx,vecy,'k');
end
%..........................................................................

%..........................................................................
% scrittura risultati in file di output
% inizializzazione caratteri
% spazio singolo e doppio per incolonnamento
spc1=' ';
spc2='  ';
% scrittura introduzione
string=' Soluzione:';
fprintf(foup,'%s\n\n',string);
% scrittura posizione dei nodi
% scrittura introduzione
string='-----------------------------------------------------';
fprintf(foup,'%s\n',string);
string=' Coordinate nodali:';
fprintf(foup,'%s\n',string);
string='-----------------------------------------------------';
fprintf(foup,'%s\n',string);
% legenda
str1=' Nodo';
str2='     X[L]';
str3='           Y[L]';
% dati
fprintf(foup,'%s %s %s\n',...
        str1,str2,str3);
% ciclo scrittura coordinate nodali
% inizializzazione coordinate nodali
pos=zeros(2,1);
% ciclo sui nodi
for i1=1:n_nod
  % inizializzazione segno
  sgn='';
  % ciclo sulle coordinate nodali
  for i2=1:2
    % lettura coordinata
    pos(i2)=coor(i1,i2);
    % test segno
    if(pos(i2)>=0)
      % positivo
      sgn(i2)='+';
    else
      % negativo
      sgn(i2)='-';
    end
  end
  % scrittura coordinate nodali
  fprintf(foup,'%s%2d %s%c%3.5e %s%c%3.5e\n',spc2,i1,...
          spc2,sgn(1),abs(pos(1)),spc2,sgn(2),abs(pos(2)));
end
% fine dati
string='-----------------------------------------------------';
fprintf(foup,'%s\n\n',string);
% scrittura incidenze elementi
% scrittura introduzione
string='-----------------------------------------------------';
fprintf(foup,'%s\n',string);
string=' Incidenze degli elementi:';
fprintf(foup,'%s\n',string);
string='-----------------------------------------------------';
fprintf(foup,'%s\n',string);
% legenda
str1=' Elemento';
str2=' Nodo 1';
str3=' Nodo 2';
% dati
fprintf(foup,'%s %s %s\n',...
        str1,str2,str3);
% ciclo scrittura incidenze elementali
% ciclo sugli elementi
for i1=1:n_elem
  % scrittura incidenze elementali
  fprintf(foup,'%s%s%s%2d %s%s%2d %s%s%s%2d\n',...
          spc2,spc2,spc1,i1,...
          spc2,spc2,inc(i1,1),...
          spc2,spc2,spc1,inc(i1,2));
end
% fine dati
string='-----------------------------------------------------';
fprintf(foup,'%s\n\n',string);
% scrittura spostamenti nodali
% scrittura introduzione
string='-----------------------------------------------------';
fprintf(foup,'%s\n',string);
string=' Spostamenti nodali:';
fprintf(foup,'%s\n',string);
string='-----------------------------------------------------';
fprintf(foup,'%s\n',string);
% legenda
str1=' Nodo';
str2='     Ux[L]';
str3='          Uy[L]';
str4='          Rz[rad]';
% dati
fprintf(foup,'%s %s %s %s\n',...
        str1,str2,str3,str4);
% ciclo scrittura spostamenti
% inizializzazione spostamenti nodali
disp=zeros(3,1);
% ciclo sui nodi
for i1=1:n_nod
  % inizializzazione segno
  sgn='';
  % ciclo sui gradi di libertà per nodo
  for i2=1:3
    % segno default
    sgn(i2)='+';
    % test vincolo
    if(igl(i1,i2)>0)
      % caso non vincolato
      disp(i2)=disp_vec(igl(i1,i2));
      % test segno
      if(disp(i2)>=0)
        % positivo
        sgn(i2)='+';
      else
        % negativo
        sgn(i2)='-';
      end
    else
      % caso vincolato
      disp(i2)=0;
    end
  end
  % scrittura spostamenti nodali
  fprintf(foup,'%s%2d %s%c%3.5e %s%c%3.5e %s%c%3.5e\n',...
          spc2,i1,...
          spc2,sgn(1),abs(disp(1)),...
          spc2,sgn(2),abs(disp(2)),...
          spc2,sgn(3),abs(disp(3)));
end
% fine dati
string='-----------------------------------------------------';
fprintf(foup,'%s\n\n',string);
% scrittura azioni agli estremi asta per asta
% scrittura introduzione
string='-----------------------------------------------------';
fprintf(foup,'%s\n',string);
string=' Azioni alle estremità delle aste:';
fprintf(foup,'%s\n',string);
string='-----------------------------------------------------';
fprintf(foup,'%s\n',string);
% legenda
str1=' Elem';
str2='     N1[F]';
str3='          T1[F]';
str4='          M1[FL]';
str5='     ';
str6='     N2[F]';
str7='          T2[F]';
str8='          M2[FL]';
% dati
fprintf(foup,'%s %s %s %s\n',...
        str1,str2,str3,str4);
fprintf(foup,'%s %s %s %s\n',...
        str5,str6,str7,str8);
% ciclo scrittura azioni di estremità
% inizializzazione azioni di estremità
azn=zeros(6,1);
% ciclo sugli elementi
for i1=1:n_elem
  % inizializzazione segno
  sgn='';
  % lettura azioni interne
  azn(1)=Nval(2*(i1-1)+1);
  azn(2)=Tval(2*(i1-1)+1);
  azn(3)=Mval(2*(i1-1)+1);
  azn(4)=Nval(2*(i1-1)+2);
  azn(5)=Tval(2*(i1-1)+2);
  azn(6)=Mval(2*(i1-1)+2);
  % ciclo sui gradi di libertà
  % per nodo 1 e 2 per lettura segno
  for i2=1:6
    % test segno
    if(azn(i2)>=0)
      % positivo
      sgn(i2)='+';
    else
      % negativo
      sgn(i2)='-';
    end
  end
  % scrittura azioni interne alle estremità delle aste (nodo 1)
  fprintf(foup,'%s%2d %s%c%3.5e %s%c%3.5e %s%c%3.5e\n',...
          spc2,i1,...
          spc2,sgn(1),abs(azn(1)),...
          spc2,sgn(2),abs(azn(2)),...
          spc2,sgn(3),abs(azn(3)));
  % scrittura azioni interne alle estremità delle aste (nodo 2)
  fprintf(foup,'%s%s %s%c%3.5e %s%c%3.5e %s%c%3.5e\n',...
          spc2,spc2,...
          spc2,sgn(4),abs(azn(4)),...
          spc2,sgn(5),abs(azn(5)),...
          spc2,sgn(6),abs(azn(6)));
end
% fine dati
string='-----------------------------------------------------';
fprintf(foup,'%s\n',string);
%..........................................................................

%..........................................................................
% attesa di istruzioni
% pause
% chiusura figura
% closereq
%..........................................................................

return
%%-------------------------------------------------------------------------