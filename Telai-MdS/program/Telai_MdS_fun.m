%%-------------------------------------------------------------------------
%%
%%  PROGRAMMA PER LA RISOLUZIONE DI TELAI
%%  CON APPLICAZIONE DEL METODO DEGLI SPOSTAMENTI
%%    
%%    Dipartimento di Ingegneria Strutturale
%%    Politecnico di Milano
%%                                 5/11/2009
%%
%%-------------------------------------------------------------------------

%..........................................................................
% comandi di inizializzazione
% del codice (variabili e file)
function [n_nod, n_elem, n_sez, n_mat, n_gdl, n_vincl, inc, isez, imat, igl, coor, csez, cmat, card, incl, KstfE, KstfG, ai_nod, strspars, load_vec, disp_vec, F_neE, F_extG] = Telai_MdS_fun(fname, pname, outputpath)

% clear all;
% fclose('all');
% close('all');
close;
format short e;
%..........................................................................

%..........................................................................
% dichiarazione delle variabili globali
% numeri interi
global n_nod n_elem n_sez n_mat n_gdl n_vincl
% matrici di interi
global inc isez imat igl
% matrici di reali
global coor csez cmat card incl
global KstfE KstfG
global ai_nod
global strspars
% vettori di reali
global load_vec disp_vec
global F_neE F_extG
%..........................................................................

%..........................................................................
% inizializzazione delle variabili globali
n_nod=0;
n_elem=0;
n_sez=0;
n_mat=0;
n_gdl=0;
n_vincl=0;
%..........................................................................

%..........................................................................
% richiesta di un file di input
% [fname,pname]=uigetfile('..\input\*.input','Selezionare il file di input');

% pname = 'C:\Users\rtoni\OneDrive\Documenti\Università\Triennale\Anno 3\Semestre 1\Strutture\Codice di calcolo telai\Telai-MdS\input\Ruota bicicletta\';
% fname = 'ruota_carica_P_T_coarse_incastro.input';

string=strcat(pname, fname);
% apertura del file di input
finp=fopen(string,'r');
% lettura dati per costruzione geometria e vincoli
status=input_geometry(finp);
%..........................................................................

%..........................................................................
% costruzione matrice gradi di libertà
% N.B.: funziona solo se i nodi master
%       hanno numerazione inferiore agli slave
% inizializzazione numero gradi di libertà
n_gdl=0;
% ciclo riempimento matrice
for i1=1:n_nod
  % ciclo sui gradi di libertà per nodo
  for i2=1:3
    % test grado di libertà numerabile
    % ossia non vincolato
    if(igl(i1,i2)==0)
      % incremento contatore gradi di libertà
	  n_gdl=n_gdl+1;
      % assegnamento grado di libertà corrente
	  igl(i1,i2)=n_gdl;
    elseif(igl(i1,i2)>0)
      % caso asservimento
      % lettura nodo master
	  nodM=igl(i1,i2);
      % assegnamento gradi di libertà
      % in comune
	  igl(i1,i2)=igl(nodM,i2);
    end
  end
end
%..........................................................................

%..........................................................................
% lettura dati per costruzione vettore carichi
status=input_loads(finp);
%..........................................................................

%..........................................................................
% fase di assemblaggio:
% * matrice di rigidezza globale;
% * vettore carichi globali;
% inizializzazione matrice di rigidezza globale
KstfG=zeros(n_gdl,n_gdl);
% inizializzazione vettore carichi globali
F_extG=zeros(n_gdl,1);
% copia carichi concentrati ai nodi
F_extG(1:n_gdl)=load_vec(1:n_gdl);
% ciclo sugli elementi
for elem=1:n_elem
  % calcola rigidezza e forze nodali equivalenti
  % per l'elemento in esame
  status=KFelem(elem);
  % nodi di estremità
  nod1=inc(elem,1);
  nod2=inc(elem,2);
  % lettura gradi di libertà corrispondenti
  gdlE(1:6)=[igl(nod1,1:3) igl(nod2,1:3)];
  % ciclo sui gradi di libertà (1)
  for i1=1:6
    % test grado di libertà non vincolato
    if(gdlE(i1)>0)
      % assemblggio forze esterne
      F_extG(gdlE(i1))=F_extG(gdlE(i1))+F_neE(i1);
      % ciclo sui gradi di libertà (2)
      for i2=1:6
        % test grado di libertà non vincolato
        if(gdlE(i2)>0)
          % assemblaggio matrice di rigidezza
          KstfG(gdlE(i1),gdlE(i2))=KstfG(gdlE(i1),gdlE(i2))+KstfE(i1,i2);
        end
      % fine ciclo gradi di librtà (2)
      end
    end
  % fine ciclo gradi di librtà (1)
  end
end
%..........................................................................

%..........................................................................
% fase di correzione delle condizioni al contorno 
% aggiunta di vincoli elastici (sia interni che a terra)
% aggiunta di cedimenti e vincoli a terra inclinati
status=input_correct_bc(finp);
%..........................................................................

%..........................................................................
% inizializzazione vettore spostamenti
disp_vec=zeros(n_gdl,1);
% soluzione del sistema
run_gpu = 0;
if run_gpu
    KstfG = gpuArray(KstfG);
    F_extG = gpuArray(F_extG);
end
disp_vec=KstfG\F_extG;
%..........................................................................

%..........................................................................
% fase di correzione degli spostamenti (vincoli inclinati)
status=output_correct_bc;
%..........................................................................

%..........................................................................
% fase di ricostruzione dello stato di sollecitazione
status=stress_eval;
%..........................................................................

%..........................................................................
% fase di plottaggio delle azioni interne
% e scrittura dei risultati su file di output
% apertura del file di output
% string='./Telai-MdS/output/results.output';
string = strcat(outputpath, '/results.output');
foup=fopen(string,'wt');
% plottaggio grafici e scrittura output
status=plot_ai(foup);
%..........................................................................

%..........................................................................
% comandi finali
% fclose('all');
% close('all');
%..........................................................................

% fine programma
%%-------------------------------------------------------------------------