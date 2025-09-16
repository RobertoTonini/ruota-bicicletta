%%-------------------------------------------------------------------------
%%
%%  FUNZIONE PER LA LETTURA DEL FILE DI INPUT: CARICHI ESTERNI
%%
%%-------------------------------------------------------------------------

function status=input_loads(finp)

%..........................................................................
% dichiarazione delle variabili globali
% numeri interi
global n_elem n_gdl
% matrici di interi
global igl
% matrici di reali
global card
% vettori di reali
global load_vec
%..........................................................................

%..........................................................................
% inizializzazione interruttore
% di corretto funzionamento della funzione
status=1;
%..........................................................................

%..........................................................................
% numero e dettaglio di nodi caricati
% inizializzazione vettore carichi ai nodi
load_vec=zeros(n_gdl,1);
% ricerca riga di comando
string='numero di nodi caricati';
% avanzamento lettura
while(~feof(finp))
  % avanzamento in file di input
  rec=native2unicode(fgetl(finp));
  % test comando corretto
  if(strncmp(rec,string,23))
    % avanzamento in file di input
    rec=native2unicode(fgetl(finp));
    % lettura dati
    n_nc=str2num(rec);
    % uscita dal ciclo
    break
  end
end
% ricerca riga di comando
string='tabella dei carichi';
% avanzamento lettura
while(~feof(finp))
  % avanzamento in file di input
  rec=native2unicode(fgetl(finp));
  % test comando corretto
  if(strncmp(rec,string,19))
    % avanzamento in file di input
    rec=native2unicode(fgetl(finp));
    % test esistenza carichi
    if(n_nc>0)
      % ciclo lettura
      for i1=1:n_nc
        % lettura dati
        nod=fscanf(finp,'%d',[1,1]);
        dir=fscanf(finp,'%*c %d',[1,1]);
        force=fscanf(finp,'%*c %g',[1,1]);
        % lettura grado di libertà corrispondente
		jgl=igl(nod,dir);
        % test grado di libertà non vincolato
        if(jgl>0)
          % assegnamento forza in vettore carichi
          load_vec(jgl)=load_vec(jgl)+force;
        end
      end
    end
    % uscita dal ciclo
    break
  end
end
%..........................................................................

%..........................................................................
% numero e dettaglio di elementi caricati
% inizializzazione matrice carichi sugli elementi
card=zeros(n_elem,5);
% ricerca riga di comando
string='numero di elementi caricati';
% avanzamento lettura
while(~feof(finp))
  % avanzamento in file di input
  rec=native2unicode(fgetl(finp));
  % test comando corretto
  if(strncmp(rec,string,27))
    % avanzamento in file di input
    rec=native2unicode(fgetl(finp));
    % lettura dati
    n_ec=str2num(rec);
    % uscita dal ciclo
    break
  end
end
% ricerca riga di comando
string='tabella dei carichi';
% avanzamento lettura
while(~feof(finp))
  % avanzamento in file di input
  rec=native2unicode(fgetl(finp));
  % test comando corretto
  if(strncmp(rec,string,19))
    % avanzamento in file di input
    rec=native2unicode(fgetl(finp));
    % test esistenza elementi caricati
    if(n_ec>0)
      % ciclo lettura
      for i1=1:n_ec
        % lettura dati
        elem=fscanf(finp,'%d',[1,1]);
        % aggiornamento matrice carichi
        card(elem,1:5)=card(elem,1:5)+...
          fscanf(finp,'%*c %g %*c %g %*c %g %*c %g %*c %g',[1,5]);
      end
    end
    % uscita dal ciclo
    break
  end
end
%..........................................................................

return
%%-------------------------------------------------------------------------