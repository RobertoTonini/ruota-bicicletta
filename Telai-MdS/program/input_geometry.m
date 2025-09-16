%%-------------------------------------------------------------------------
%%
%%  FUNZIONE PER LA LETTURA DEL FILE DI INPUT: GEOMETRIA E VINCOLI
%%
%%-------------------------------------------------------------------------

function status=input_geometry(finp)

%..........................................................................
% dichiarazione delle variabili globali
% numeri interi
global n_nod n_elem n_sez n_mat n_gdl n_vincl
% matrici di interi
global inc isez imat igl
% matrici di reali
global coor csez cmat card incl
%..........................................................................

%..........................................................................
% inizializzazione interruttore
% di corretto funzionamento della funzione
status=1;
%..........................................................................

%..........................................................................
% numero e dettaglio sui nodi del telaio
% ricerca riga di comando
string='numero di nodi';
% avanzamento lettura
while(~feof(finp))
  % avanzamento in file di input
  rec=native2unicode(fgetl(finp));
  % test comando corretto
  if(strncmp(rec,string,14))
    % avanzamento in file di input
    rec=native2unicode(fgetl(finp));
    % lettura dati
    n_nod=str2num(rec);
    % uscita dal ciclo
    break
  end
end 
% noto il numero di nodi
% si dimensionano le matrici 
% di coordinate nodali e gradi di libertà
coor=zeros(n_nod,2);
igl=zeros(n_nod,3);
% ricerca riga di comando
string='tabella dei nodi';
% avanzamento lettura
while(~feof(finp))
  % avanzamento in file di input
  rec=native2unicode(fgetl(finp));
  % test comando corretto
  if(strncmp(rec,string,16))
    % avanzamento in file di input
    rec=native2unicode(fgetl(finp));
    % ciclo lettura
    for i1=1:n_nod
      % lettura dati
      coor(i1,1:2)=fscanf(finp,'%*g %*c %g %*c %g',[1,2]);
    end
    % uscita dal ciclo
    break
  end
end 
%..........................................................................

%..........................................................................
% numero e dettaglio di elementi trave
% ricerca riga di comando
string='numero di elementi';
% avanzamento lettura
while(~feof(finp))
  % avanzamento in file di input
  rec=native2unicode(fgetl(finp));
  % test comando corretto
  if(strncmp(rec,string,18))
    % avanzamento in file di input
    rec=native2unicode(fgetl(finp));
    % lettura dati
    n_elem=str2num(rec);
    % uscita dal ciclo
    break
  end
end 
% noto il numero di elementi
% si dimensionano le matrici 
% di incidenze di sezioni e materiali
% per ogni elemento di trave
inc=zeros(n_elem,2);
isez=zeros(n_elem,1);
imat=zeros(n_elem,1);
% ricerca riga di comando
string='tabella di incidenze';
% avanzamento lettura
while(~feof(finp))
  % avanzamento in file di input
  rec=native2unicode(fgetl(finp));
  % test comando corretto
  if(strncmp(rec,string,20))
    % avanzamento in file di input
    rec=native2unicode(fgetl(finp));
    % ciclo lettura
    for i1=1:n_elem
      % lettura dati
      inc(i1,1:2)=fscanf(finp,'%*d %*c %d %*c %d',[1,2]);
      isez(i1)=fscanf(finp,'%*c %d',[1,1]);
      imat(i1)=fscanf(finp,'%*c %d',[1,1]);
    end
    % uscita dal ciclo
    break
  end
end 
%..........................................................................

%..........................................................................
% numero e dettaglio di sezioni
% ricerca riga di comando
string='numero di sezioni';
% avanzamento lettura
while(~feof(finp))
  % avanzamento in file di input
  rec=native2unicode(fgetl(finp));
  % test comando corretto
  if(strncmp(rec,string,17))
    % avanzamento in file di input
    rec=native2unicode(fgetl(finp));
    % lettura dati
    n_sez=str2num(rec);
    % uscita dal ciclo
    break
  end
end
% noto il numero di sezioni
% si dimensiona la matrice corrispondente
csez=zeros(n_sez,4);
% ricerca riga di comando
string='proprietà delle sezioni';
% avanzamento lettura
while(~feof(finp))
  % avanzamento in file di input
  rec=native2unicode(fgetl(finp));
  % test comando corretto
  if(strncmp(rec,string,23))
    % avanzamento in file di input
    rec=native2unicode(fgetl(finp));
    % ciclo lettura
    for i1=1:n_sez
      % lettura dati
      csez(i1,1:4)=fscanf(finp,'%*g %*c %g %*c %g %*c %g %*c %g',[1,4]);
    end
    % uscita dal ciclo
    break
  end
end
%..........................................................................

%..........................................................................
% numero e dettaglio di materiali
% ricerca riga di comando
string='numero di materiali';
% avanzamento lettura
while(~feof(finp))
  % avanzamento in file di input
  rec=native2unicode(fgetl(finp));
  % test comando corretto
  if(strncmp(rec,string,19))
    % avanzamento in file di input
    rec=native2unicode(fgetl(finp));
    % lettura dati
    n_mat=str2num(rec);
    % uscita dal ciclo
    break
  end
end
% noto il numero di materiali
% si dimensiona la matrice corrispondente
cmat=zeros(n_mat,4);
% ricerca riga di comando
string='proprietà dei materiali';
% avanzamento lettura
while(~feof(finp))
  % avanzamento in file di input
  rec=native2unicode(fgetl(finp));
  % test comando corretto
  if(strncmp(rec,string,23))
    % avanzamento in file di input
    rec=native2unicode(fgetl(finp));
    % ciclo lettura
    for i1=1:n_mat
      % lettura dati
      cmat(i1,1:4)=fscanf(finp,'%*g %*c %g %*c %g %*c %g %*c %g',[1,4]);
    end
    % uscita dal ciclo
    break
  end
end
%..........................................................................

%..........................................................................
% numero e dettaglio dei vincoli a terra
% ricerca riga di comando
string='numero di vincoli a terra';
% avanzamento lettura
while(~feof(finp))
  % avanzamento in file di input
  rec=native2unicode(fgetl(finp));
  % test comando corretto
  if(strncmp(rec,string,25))
    % avanzamento in file di input
    rec=native2unicode(fgetl(finp));
    % lettura dati
    n_vrt=str2num(rec);
    % uscita dal ciclo
    break
  end
end
% ricerca riga di comando
string='tabella dei vincoli a terra';
% avanzamento lettura
while(~feof(finp))
  % avanzamento in file di input
  rec=native2unicode(fgetl(finp));
  % test comando corretto
  if(strncmp(rec,string,27))
    % avanzamento in file di input
    rec=native2unicode(fgetl(finp));
    % ciclo lettura
    for i1=1:n_vrt
      % lettura dati
      nod=fscanf(finp,'%d',[1,1]);
      dir=fscanf(finp,'%*c %d',[1,1]);
      % correzione matrice gradi di libertà
      igl(nod,dir)=-1;
    end
    % uscita dal ciclo
    break
  end
end
%..........................................................................

%..........................................................................
% numero e dettaglio di asservimenti
% ricerca riga di comando
string='numero di asservimenti';
% avanzamento lettura
while(~feof(finp))
  % avanzamento in file di input
  rec=native2unicode(fgetl(finp));
  % test comando corretto
  if(strncmp(rec,string,22))
    % avanzamento in file di input
    rec=native2unicode(fgetl(finp));
    % lettura dati
    n_ass=str2num(rec);
    % uscita dal ciclo
    break
  end
end
% ricerca riga di comando
string='tabella degli asservimenti';
% avanzamento lettura
while(~feof(finp))
  % avanzamento in file di input
  rec=native2unicode(fgetl(finp));
  % test comando corretto
  if(strncmp(rec,string,26))
    % avanzamento in file di input
    rec=native2unicode(fgetl(finp));
    % test esistenza asservimenti
    if(n_ass>0)
      % ciclo lettura
      for i1=1:n_ass
        % lettura dati (nodo master - nodo slave)
        nodM=fscanf(finp,'%d',[1,1]);
        nodS=fscanf(finp,'%*c %d',[1,1]);
        dir=fscanf(finp,'%*c %d',[1,1]);
        % correzione matrice gradi di libertà
        igl(nodS,dir)=nodM;
      end
    end
    % uscita dal ciclo
    break
  end
end
%..........................................................................

return
%%-------------------------------------------------------------------------