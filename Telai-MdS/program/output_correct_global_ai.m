%%-------------------------------------------------------------------------
%%
%%  FUNZIONE PER LA MODIFICA DELLE AZIONI INTERNE
%%  NELLE ASTE INCLINATE
%%
%%-------------------------------------------------------------------------

function status=output_correct_global_ai(finp)

%..........................................................................
% dichiarazione delle variabili globali
% numeri interi
global n_vincl
% matrici di interi
global igl
% matrici di reali
global incl
% vettori di reali
global disp_vec
%..........................................................................

%..........................................................................
% inizializzazione interruttore
% di corretto funzionamento della funzione
status=1;
%..........................................................................

%..........................................................................
% correzione degli spostamenti nei vincoli inclinati
% test esistenza vincoli inclinati
if(n_vincl>0)
  % ciclo di correzione
  % sui vincoli inclinati
  for i1=1:n_vincl
    % lettura nodo
    nod=incl(i1,1);
    % lettura angolo di inclinazione
    beta=incl(i1,2)*(pi/double(180));
    % calcolo seno e coseno
    senb=sin(beta);
    cosb=cos(beta);
    % lettura gradi di libertà corrispodenti
	ii=igl(nod,1);
	jj=igl(nod,2);
    % termini originari
    vdi=disp_vec(ii);
	vdj=disp_vec(jj);
    % modifica termini
	disp_vec(ii)=vdi*cosb-vdj*senb;
	disp_vec(jj)=vdi*senb+vdj*cosb;
  end
end
%..........................................................................

return
%%-------------------------------------------------------------------------