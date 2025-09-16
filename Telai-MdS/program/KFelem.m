%%-------------------------------------------------------------------------
%%
%%  FUNZIONE PER LA CREAZIONE DEL CONTRIBUTO DELLA SINGOLA
%%  TRAVE ALLA MATRICE DI RIGIDEZZA GLOBALE E AL VETTORE
%%  DEI CARICHI (FORZE NODALI EQUIVALENTI)
%%
%%-------------------------------------------------------------------------

function status=KFelem(elem)

%..........................................................................
% dichiarazione delle variabili globali
% matrici di interi
global inc isez imat
% matrici di reali
global coor csez cmat card
global KstfE
% vettori di reali
global F_neE
%..........................................................................

%..........................................................................
% inizializzazione interruttore
% di corretto funzionamento della funzione
status=1;
%..........................................................................

%..........................................................................
% inizializzazione matrici dell'elemento
% corrente nel riferimento globale
F_neE=zeros(6,1);
KstfE=zeros(6,6);
% inizializzazione matrici dell'elemento
% corrente nel riferimento locale
F_ne=zeros(6,1);
Kstf=zeros(6,6);
% inizializzazione matrice di trasfomazione
Ttrsf=zeros(6,6);
%..........................................................................

%..........................................................................
% lettura nodi
nod1=inc(elem,1);
nod2=inc(elem,2);
% calcolo distanze
dx=coor(nod2,1)-coor(nod1,1);
dy=coor(nod2,2)-coor(nod1,2);
% calcolo lunghezza
le=sqrt(dx^2+dy^2);
% calcolo seno e coseno 
% angolo di inclinazione
ca=dx/le;
sa=dy/le;
% lettura tipologia di 
% sezione e materiale
is=isez(elem);
im=imat(elem);
% lettura proprietà della sezione
Area=csez(is,1);
Im=csez(is,2);
Hsez=csez(is,3);
chi=csez(is,4);
% lettura proprietà del materiale
Ey=cmat(im,1);
Pnu=cmat(im,2);
alfa=cmat(im,3);
ps=cmat(im,4);
%..........................................................................

%..........................................................................
% calcolo coefficienti
gg=Ey/(2*(1+Pnu));
fi=12*chi*(Ey/gg)*(Im/Area)/le^2;
% calcolo termini della matrice di rigidezza
Kstf(1,1)=(Ey*Area)/le;
Kstf(2,2)=12*(Ey*Im)/((1+fi)*le^3);
Kstf(3,3)=(4+fi)*(Ey*Im)/((1+fi)*le);
Kstf(4,4)=Kstf(1,1);
Kstf(5,5)=Kstf(2,2);
Kstf(6,6)=Kstf(3,3);
Kstf(3,2)=6*(Ey*Im)/((1+fi)*le^2);
Kstf(4,1)=-Kstf(1,1);
Kstf(5,2)=-Kstf(2,2);
Kstf(5,3)=-Kstf(3,2);
Kstf(6,2)=Kstf(3,2);
Kstf(6,3)=(2-fi)*(Ey*Im)/((1+fi)*le);
Kstf(6,5)=-Kstf(3,2);
% termini simmetrici
for i1=1:6
  for i2=i1+1:6
    Kstf(i1,i2)=Kstf(i2,i1);
  end 
end
%..........................................................................

%..........................................................................
% calcolo matrice di trasformazione
Ttrsf(1,1)=ca;
Ttrsf(1,2)=-sa;
Ttrsf(2,1)=sa;
Ttrsf(2,2)=ca;
Ttrsf(3,3)=1;
Ttrsf(4,4)=ca;
Ttrsf(4,5)=-sa;
Ttrsf(5,4)=sa;
Ttrsf(5,5)=ca;
Ttrsf(6,6)=1;
%..........................................................................

%..........................................................................
% trasformazione matrice di rigidezza da locale a globale
Kstf=Kstf*(Ttrsf');
KstfE=Ttrsf*Kstf;
%..........................................................................

%..........................................................................
% lettura dati carichi distribuiti
px=card(elem,1);
py1=card(elem,2);
py2=card(elem,3);
dts=card(elem,4);
dti=card(elem,5);
%..........................................................................

%..........................................................................
% calcolo peso specifico della sezione
pg=ps*Area;
% calcolo carichi conseguenti
pp=py1;
qq=py2-py1;
px=px-pg*sa;
pp=pp-pg*ca;
%..........................................................................

%..........................................................................
% calcolo coefficienti per carico distribuito
fh=px*(le/2);
fv=pp*(le/2);
fm=pp*(le^2/12);
% calcolo vettore locale di
% forze nodali equivalenti
% per carico distribuito
F_ne(1)=fh;
F_ne(2)=fv;
F_ne(3)=fm;
F_ne(4)=fh;
F_ne(5)=fv;
F_ne(6)=-fm;
%..........................................................................

%..........................................................................
% calcolo coefficienti per carico triangolare
aa=le/(12*Ey*Im);
bb=chi/(le*Area*gg);
cc=bb/(aa+bb);
% aggiornamento vettore locale di
% forze nodali equivalenti
% per carico triangolare
F_ne(2)=F_ne(2)+(3/20)*qq*le*(1+cc/9);
F_ne(3)=F_ne(3)+(1/30)*qq*(le^2)*(1+cc/4);
F_ne(5)=F_ne(5)+(7/20)*qq*le*(1-cc/21);
F_ne(6)=F_ne(6)-(1/20)*qq*(le^2)*(1-cc/6);
%..........................................................................

%..........................................................................
% calcolo coefficienti per carico termico
dtm=(dts+dti)/2;
dtd=(dts-dti)/2;
% calcolo coefficienti per carico termico
fh=alfa*Ey*Area*dtm;
fm=2*alfa*Ey*(Im/Hsez)*dtd;
% aggiornamento vettore locale di
% forze nodali equivalenti
% per carico termico
F_ne(1)=F_ne(1)-fh;
F_ne(3)=F_ne(3)+fm;
F_ne(4)=F_ne(4)+fh;
F_ne(6)=F_ne(6)-fm;
%..........................................................................

%..........................................................................
% trasformazione vettore dei carichi da locale a globale
F_neE=Ttrsf*F_ne;
%..........................................................................

return
%%-------------------------------------------------------------------------