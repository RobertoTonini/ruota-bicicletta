function [input_txt] = input_generator(R, deltaT, fixed, P, nsub, n_spokes)
    %INPUT_GENERATOR Generates the text for the .input file of the
    % structure
    %   Input:
    %       R:          radius of the rim [m]
    %       deltaT:     temperature delta on each rim [K]
    %       fixed:      boolean 1 if support between rim and spoke is
    %                   fixed, 0 if it's a pin
    %       P:          load on the wheel
    %       nsub:       parameter to control the mesh size along the rim; nsub>=1
    %       n_spokes:   number of spokes/2

    % Input readings
    format long
    input_txt = 'Modello ruota a raggi caricata con peso';

    if deltaT ~= 0
        input_txt = strcat(input_txt, ' e pretensionamento');
    end

    input_txt = strcat(input_txt, ' con');

    if nsub == 1
        input_txt = strcat(input_txt, ' coarse'); 
    else
        input_txt = strcat(input_txt, ' refined');
    end

    input_txt = strcat(input_txt, ' mesh e collegamenti modellati come');

    if fixed
        input_txt = strcat(input_txt, ' incastri\n\n');
    else
        input_txt = strcat(input_txt, ' cerniere\n\n');
    end
    % P = P/2;

    % n_spokes = n_spokes / 2;

    % Preliminary calculations
    Rrim = R;                         % radius of the rim, m
    Nspokes = n_spokes * 2;           % (total) number of spokes
    Delta_teta = 2.*pi/Nspokes;       % angular distance between two spokes
    delta = Delta_teta / 2.^nsub;     % angular distance between two nodes of the mesh along the rim
    teta_rim = [0:delta:pi];          % vector storing the angular coordinates of the nodes of the rim
    Nrim = length(teta_rim);          % total number of nodes of the rim
    teta_spokes = [0.5*Delta_teta:Delta_teta:pi-0.5*Delta_teta]; % vector storing the angular coordinates of the head of the spokes along the rim
    Ns = length(teta_spokes); 
    if Ns==Nspokes/2.
        % ok
    else 
        error('\n something went wrong while defining the position of the nodes'); 
    end 
    
    % cycle to identify the nodes on the rim that coincides with the head of the spokes
    idspokes = zeros(Ns, 1); 
    for ii = 1:Ns
        sr = teta_spokes(ii); 
        ids = 0; 
        ex = 0; 
        cnt = 1;
        while ex == 0 && cnt <= Nrim
            toll = 10^-12; 
            if abs(teta_rim(cnt) - sr)<toll 
	            ids = cnt; 
		        ex = 1; 
            else 
	            cnt = cnt +1; 
	        end 
        end 
        if ex == 0
            error('\n something went wrong while identifying the heads of the spokes'); 
        else
            idspokes(ii) = ids; 
        end 
    end 

    %% Description of the mesh
    Nnodes = Nrim+1;           % number of nodes (not including the node K), -
    Nele = (Nrim-1) + Ns;      % number of elements

    if ~fixed
        Nnodes = Nnodes + Ns;
    end

    input_txt = strcat(input_txt, 'numero di nodi\n', int2str(Nnodes), '\ntabella dei nodi\nnodo,x,y\n');

    %% Create the nodal coordinate matrix
    MXYZ = zeros(Nnodes, 4);
    for ii = 1:Nrim
        MXYZ(ii,1) = ii; 
        MXYZ(ii,2) = Rrim * sin(teta_rim(ii)); 
	    MXYZ(ii,3) = -Rrim * cos(teta_rim(ii)); 
	    MXYZ(ii,4) = 0.;
    end 
    % hub
    MXYZ(Nrim+1,1)=Nrim+1;
    MXYZ(Nrim+1, 2:4) = [0,0,0];

    if ~fixed
        for ii = Nrim+2:Nnodes
            MXYZ(ii,1) = ii; 
            MXYZ(ii,2) = Rrim * sin(teta_rim(idspokes(ii-Nrim-1))); 
	        MXYZ(ii,3) = -Rrim * cos(teta_rim(idspokes(ii-Nrim-1))); 
	        MXYZ(ii,4) = 0.;
        end 
    end

    for mxyz = MXYZ'
        input_txt = strcat(input_txt, sprintf("%d, %.25f, %.25f\n", mxyz(1), mxyz(2), mxyz(3)));
    end

    input_txt = strcat(input_txt, '\nnumero di elementi\n', int2str(Nele), '\ntabella di incidenze\nelem,nodo1,nodo2,sez,mat\n');


    %% Create the elements connection matrix
    % MATRIX FORMAT: elem,nodo1,nodo2,sez,mat

    sez_rim = 1;
    mat_rim = 1;
    sez_spokes = 2;
    mat_spokes = 2;

    % Rim
    for ii = 1:(Nrim-1)
        input_txt = strcat(input_txt, sprintf('%d, %d, %d, %d, %d', ii, ii, ii+1, sez_rim, mat_rim), '\n');
    end
    pin_node = ii + 2;
    q = 1;

    for jj = ii+1:Nele
        if fixed
            delta = 0;
            spoke = idspokes(q);
        else
            delta = Nrim+1;
            spoke = q + delta;
        end
        input_txt = strcat(input_txt, sprintf('%d, %d, %d, %d, %d', jj, pin_node, spoke, sez_spokes, mat_spokes), '\n');
        q = q + 1;
    end

    d_spoke = 2;
    a_spoke = pi * d_spoke^2/4;
    inerzia_spoke = pi * d_spoke^4 / 64;
    h_eq_spoke = (inerzia_spoke*12).^0.25;

    


    input_txt = strcat(input_txt, '\n\nnumero di sezioni\n2\nproprietà delle sezioni\nnum,area,inerzia,altezza,taglio\n1,77e-6, 1124e-12, 8.77e-3,0.0\n2,3.1416e-6,0.7853e-12,1.77e-3,0.0\n\n');
    input_txt = strcat(input_txt, 'numero di materiali\n2\nproprietà dei materiali\nnum,young,poisson,alpha,pp\n1,69e9,0.33,24.e-6,0.0\n2,200e9,0.3,12.e-6,0.0\n\n');
    input_txt = strcat(input_txt, 'numero di vincoli a terra\n6\ntabella dei vincoli a terra\nnodo,direzione\n1,1\n1,3\n', int2str(pin_node-1), ', 1\n', int2str(pin_node-1), ', 3\n', int2str(pin_node), ', 1\n', int2str(pin_node), ', 2\n');
    Nass = 0 * fixed + Ns * ~fixed;
    input_txt = strcat(input_txt, '\nnumero di asservimenti\n', int2str(Nass*2), '\ntabella degli asservimenti\nmaster,slave,direzione\n');
    if ~fixed
        q = pin_node + 1;
        for ids = idspokes'
            input_txt = strcat(input_txt, sprintf('%d, %d, 1', ids, q), "\n", sprintf('%d, %d, 2', ids, q), "\n");
            q = q + 1;
        end
    end
    input_txt = strcat(input_txt, sprintf('\n\nnumero di nodi caricati\n1\ntabella dei carichi\nnodo, direzione, forza\n1, 2, %d', P));
    
    Ncar = 0 * (deltaT == 0) + Ns * ~(deltaT == 0);
    input_txt = strcat(input_txt, '\n\nnumero di elementi caricati\n', int2str(Ncar), '\ntabella dei carichi\nelem,Px,Py1,Py2,&Tsup,&Tinf\n');
    if Ncar ~= 0
        for ii = Nrim:Nele
            input_txt = strcat(input_txt, sprintf("%d, 0, 0, 0, %d, %d", ii, deltaT, deltaT), "\n");
        end
    end

    final_str = '\nnumero di vincoli elastici a terra\n0\ntabella dei vincoli\nnodo,direzione,rigidezza\n\nnumero di vincoli elastici interni\n0\ntabella dei vincoli\nnodo1,nodo2,direzione,rigidezza\n\nnumero di cedimenti vincolari\n0\ntabella dei cedimenti\nnodo,direzione,cedimento\n\nnumero di vincoli inclinati\n0\ntabella di inclinazione\nnodo,angolo(gradi),parametro,rig/ced\n\n';
    input_txt = strcat(input_txt, final_str);


end