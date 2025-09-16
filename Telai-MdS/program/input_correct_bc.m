%%-------------------------------------------------------------------------
%%
%%  FUNZIONE PER LA LETTURA DEL FILE DI INPUT:
%%  MOLLE, CEDIMENTI E VINCOLI INCLINATI
%%
%%-------------------------------------------------------------------------

function status=input_correct_bc(finp)

%..........................................................................
% dichiarazione delle variabili globali
% numeri interi
global n_gdl n_vincl
% matrici di interi
global igl
% matrici di reali
global incl
global KstfG
% vettori di reali
global F_extG
%..........................................................................

%..........................................................................
% inizializzazione interruttore
% di corretto funzionamento della funzione
status=1;
%..........................................................................

%..........................................................................
% numero e dettaglio dei vincoli elastici a terra
% ricerca riga di comando
string='numero di vincoli elastici a terra';
% avanzamento lettura
while(~feof(finp))
  % avanzamento in file di input
  rec=native2unicode(fgetl(finp));
  % test comando corretto
  if(strncmp(rec,string,34))
    % avanzamento in file di input
    rec=native2unicode(fgetl(finp));
    % lettura dati
    n_velt=str2num(rec);
    % uscita dal ciclo
    break
  end
end
% ricerca riga di comando
string='tabella dei vincoli';
% avanzamento lettura
while(~feof(finp))
  % avanzamento in file di input
  rec=native2unicode(fgetl(finp));
  % test comando corretto
  if(strncmp(rec,string,19))
    % avanzamento in file di input
    rec=native2unicode(fgetl(finp));
    % test esistenza vincoli elastici a terra
    if(n_velt>0)
      % ciclo lettura
      for i1=1:n_velt
        % lettura dati
        nod=fscanf(finp,'%d',[1,1]);
        dir=fscanf(finp,'%*c %d',[1,1]);
        stf=fscanf(finp,'%*c %g',[1,1]);
        % lettura grado di libertà corrispondente
		jgl=igl(nod,dir);
        % test grado di libertà non vincolato
        if(jgl>0)
          % aggiornamento matrice di rigidezza
          KstfG(jgl,jgl)=KstfG(jgl,jgl)+stf;
        end
      end
    end
    % uscita dal ciclo
    break
  end
end
%..........................................................................

%..........................................................................
% numero e dettaglio di vincoli elastici interni
% ricerca riga di comando
string='numero di vincoli elastici interni';
% avanzamento lettura
while(~feof(finp))
  % avanzamento in file di input
  rec=native2unicode(fgetl(finp));
  % test comando corretto
  if(strncmp(rec,string,34))
    % avanzamento in file di input
    rec=native2unicode(fgetl(finp));
    % lettura dati
    n_veli=str2num(rec);
    % uscita dal ciclo
    break
  end
end
% ricerca riga di comando
string='tabella dei vincoli';
% avanzamento lettura
while(~feof(finp))
  % avanzamento in file di input
  rec=native2unicode(fgetl(finp));
  % test comando corretto
  if(strncmp(rec,string,19))
    % avanzamento in file di input
    rec=native2unicode(fgetl(finp));
    % test esistenza vincoli elastici interni
    if(n_veli>0)
      % ciclo lettura
      for i1=1:n_veli
        % lettura dati
        nod1=fscanf(finp,'%d',[1,1]);
        nod2=fscanf(finp,'%*c %d',[1,1]);
        dir=fscanf(finp,'%*c %d',[1,1]);
        stf=fscanf(finp,'%*c %g',[1,1]);
        % lettura gradi di libertà corrispondenti
		jgl1=igl(nod1,dir);
        jgl2=igl(nod2,dir);
        % test gradi di libertà non vincolati
        if((jgl1>0)&&(jgl2>0))
          % aggiornamento matrice di rigidezza
		  KstfG(jgl1,jgl1)=KstfG(jgl1,jgl1)+stf;
          KstfG(jgl2,jgl2)=KstfG(jgl2,jgl2)+stf;
          KstfG(jgl1,jgl2)=KstfG(jgl1,jgl2)-stf;
          KstfG(jgl2,jgl1)=KstfG(jgl2,jgl1)-stf;
        end
      end
    end
    % uscita dal ciclo
    break
  end
end
%..........................................................................

%..........................................................................
% numero e dettaglio di cedimenti vincolari
% ricerca riga di comando
string='numero di cedimenti vincolari';
% avanzamento lettura
while(~feof(finp))
  % avanzamento in file di input
  rec=native2unicode(fgetl(finp));
  % test comando corretto
  if(strncmp(rec,string,29))
    % avanzamento in file di input
    rec=native2unicode(fgetl(finp));
    % lettura dati
    n_cedv=str2num(rec);
    % uscita dal ciclo
    break
  end
end
% ricerca riga di comando
string='tabella dei cedimenti';
% avanzamento lettura
while(~feof(finp))
  % avanzamento in file di input
  rec=native2unicode(fgetl(finp));
  % test comando corretto
  if(strncmp(rec,string,21))
    % avanzamento in file di input
    rec=native2unicode(fgetl(finp));
    % test esistenza cedimenti vincolari
    if(n_cedv>0)
      % ciclo lettura
      for i1=1:n_cedv
        % lettura dati
        nod=fscanf(finp,'%d',[1,1]);
        dir=fscanf(finp,'%*c %d',[1,1]);
        ced=fscanf(finp,'%*c %g',[1,1]);
        % lettura grado di libertà corrispondente
		jgl=igl(nod,dir);
        % test grado di libertà non vincolato
        if((jgl>0))
          % ciclo sui gradi di libertà
          for i2=1:n_gdl
            % aggiornamento matrice di rigidezza
            % annullamento termini in riga
            KstfG(jgl,i2)=0;
            % correzione forze esterne
            F_extG(i2)=F_extG(i2)-KstfG(i2,jgl)*ced;
            % annullamento termini in colonna
            KstfG(i2,jgl)=0;
          end
          % sostituzione equazione di equilibrio
          % con equazione di congruenza
		  KstfG(jgl,jgl)=1;
		  F_extG(jgl)=ced;
        end
      end
    end
    % uscita dal ciclo
    break
  end
end
%..........................................................................

%..........................................................................
% numero e dettaglio di vincoli inclinati
% ricerca riga di comando
string='numero di vincoli inclinati';
% avanzamento lettura
while(~feof(finp))
  % avanzamento in file di input
  rec=native2unicode(fgetl(finp));
  % test comando corretto
  if(strncmp(rec,string,27))
    % avanzamento in file di input
    rec=native2unicode(fgetl(finp));
    % lettura dati
    n_vincl=str2num(rec);
    % uscita dal ciclo
    break
  end
end
% ricerca riga di comando
string='tabella di inclinazione';
% avanzamento lettura
while(~feof(finp))
  % avanzamento in file di input
  rec=native2unicode(fgetl(finp));
  % test comando corretto
  if(strncmp(rec,string,23))
    % avanzamento in file di input
    rec=native2unicode(fgetl(finp));
    % test esistenza vincoli inclinati
    if(n_vincl>0)
      % inizializzazione matrice
      incl=zeros(n_vincl,4);
      % ciclo lettura
      for i1=1:n_vincl
        % lettura dati
        incl(i1,1:4)=fscanf(finp,'%d %*c %g %*c %d %*c %g',[1,4]);
      end
    end
    % uscita dal ciclo
    break
  end
end
% test esistenza vincoli inclinati
if(n_vincl>0)
  % ciclo vincoli da modificare
  for i1=1:n_vincl
    % lettura dati
    nod=incl(i1,1);
    beta=incl(i1,2)*(pi/double(180));
    i_type=incl(i1,3);
    stf_ced=incl(i1,4);
    % calcolo seno e coseno
    senb=sin(beta);
    cosb=cos(beta);
    % lettura gradi di libertà corrispodenti
	ii=igl(nod,1);
	jj=igl(nod,2);
    % termini originari
	vkII=KstfG(ii,ii);
	vkJJ=KstfG(jj,jj);
	vkIJ=KstfG(ii,jj);
    % ciclo di modifica termini
    % della matrice di rigidezza
    for cgdl=1:n_gdl
      % test sul grado di libertà
      if(cgdl==ii)
        % modifica termini
        KstfG(ii,ii)=(vkII*cosb^2)+(2*vkIJ*senb*cosb)+(vkJJ*senb^2);
        KstfG(ii,jj)=vkIJ*(cosb^2-senb^2)+(vkJJ-vkII)*cosb*senb;
      elseif(cgdl==jj)
        % modifica termini
        KstfG(jj,ii)=vkIJ*(cosb^2-senb^2)+(vkJJ-vkII)*cosb*senb;
        KstfG(jj,jj)=(vkII*senb^2)-(2*vkIJ*senb*cosb)+(vkJJ*cosb^2);
      else
        % lettura termini originari
		vkRI=KstfG(cgdl,ii);
		vkRJ=KstfG(cgdl,jj);
        % modifica termini
        KstfG(cgdl,ii)=vkRI*cosb+vkRJ*senb;
        KstfG(cgdl,jj)=-vkRI*senb+vkRJ*cosb;
        KstfG(ii,cgdl)=KstfG(cgdl,ii);
        KstfG(jj,cgdl)=KstfG(cgdl,jj);
      end
    end
    % modifica forze esterne
    % termini originari
    fi=F_extG(ii);
	fj=F_extG(jj);
    % modifica termini
	F_extG(ii)=fi*cosb+fj*senb;
	F_extG(jj)=-fi*senb+fj*cosb;
    % test tipologia di vincolo
    switch(i_type)
      % caso cedimento anelastico
      case 0
        % ciclo sui gradi di libertà
        for i2=1:n_gdl
          % aggiornamento matrice di rigidezza
          % annullamento termini in riga
          KstfG(ii,i2)=0;
          % correzione forze esterne
          F_extG(i2)=F_extG(i2)-KstfG(i2,ii)*stf_ced;
          % annullamento termini in colonna
          KstfG(i2,ii)=0;
        end
        % sostituzione equazione di equilibrio
        % con equazione di congruenza
		KstfG(ii,ii)=1;
		F_extG(ii)=stf_ced;
      % caso vincolo elastico in direzione 
      % perpendicolare al piano di scorrimento
      case 1
        % aggiornamento matrice di rigidezza
        KstfG(ii,ii)=KstfG(ii,ii)+stf_ced;
      % caso vincolo elastico in direzione 
      % parallela al piano di scorrimento
      case 2
        % aggiornamento matrice di rigidezza
        KstfG(jj,jj)=KstfG(jj,jj)+stf_ced;
    end
  end 
end
%..........................................................................

return
%%-------------------------------------------------------------------------