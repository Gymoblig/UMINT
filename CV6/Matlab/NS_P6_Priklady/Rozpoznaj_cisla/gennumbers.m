% Funkcia na generovanie dat rastra 4x7 pre cisla 0-9
% vracaju sa data vo formate pre trenovanie neuronovej siete
% s rozmermi pre vstup NS (28 x n) pre vystup siete (10 x n) n=pocet cisiel
%
% vstupne parametre : numinput - vektor s cislami 0-9, pre ktore sa
%                               generuju data,default [0 1 2 3 4 5 6 7 8 9]
%                     noise - sum v rozsahu 0-0.5, default 0
%                     change_posit - definovane pozicie pre zmenu hodnot
%                                   vstupu v rozsahu 1-28, ak sa nedefinuje ziadny vstup sa nemeni 
%                     new_value - nove hodnoty na definovane pozicie v rozsahu 0-1, default 1
%
% vystupne parametre : numbers - generovane data pre zadane cisla, vstup NS
%                      target - generovane data pre zadane cisla, vystup NS
%
%   priklady zapisu:
%   vygenerovanie dat pre vsetky cisla bez sumu
%   [xdata,ydata]=gennumbers(0:9)
%
%   vygenerovanie vstupnych dat pre cislo 2 so sumom 0.3
%   xdata=gennumbers(2,0.3)
%
%   vygenerovanie vstupnych dat pre cislo 7 so sumom 0.2
%   xdata=gennumbers(7,0.2)
%
%   vygenerovanie vstupnych dat pre cislo 5  bez sumu , zmena na pozicii
%   2 na 0, na pozicii 8 na 1
%   xdata=gennumbers(5,0,[2 8],[0 1])
%
%   vygenerovanie vstupnych dat pre cislo 2  bez sumu, zmena na poziciach
%   2 na 0, na pozicii 8 na 1
%   xdata=gennumbers(2,0,[27 28],0)
%
%   vygenerovanie vstupnych dat pre cislo 6  so sumom 0.2, zmena na pozicii
%   2 na 0.3, na pozicii 21 na 0.2
%   xdata=gennumbers(6,0.2,[3 21],[0.3 0.2])


function [numbers,target]=gennumbers(numinput,noise,change_posit,new_value)


if nargin==0
    numinput=0:9;
end

if nargin<2
    noise=0;
else
    if noise>0.5
        noise=0.5;
    end
    if noise<0
        noise=0;
    end
end

if nargin<3
    change_number=0;
else
    change_number=length(change_posit);
    if nargin==3
        new_value=ones(1,change_number);
    else
        if length(new_value)<change_number
            new_value=new_value(1)*ones(1,change_number);
        end
    end
end

% Definovanie dat pre cislice 0 az 9
n=length(numinput);
if noise==0
    numbers=zeros(28,n);
else
    numbers=noise*rand(28,n);
end
target=zeros(10,n);

for k=1:n;

	switch numinput(k)
	% cislo 1
	case 1
        index=[3,6,7,9,11,15,19,23,27];
        m=1;
	case 2
        % cislo 2
        index=[2,3,5,8,12,15,18,21,25,26,27,28];
        m=2;
	case 3
        % cislo 3
        index=[2,3,5,8,12,15,20,21,24,26,27];
        m=3;
	case 4
        % cislo 4
        index=[4,7,10,13,17,18,19,20,23,27];
        m=4;
	case 5
        % cislo 5
        index=[1,2,3,4,5,9,13,14,15,20,24,25,26,27];
        m=5;
	case 6    
        % cislo 6
        index=[2,3,5,9,13,14,15,17,20,21,24,26,27];
        m=6;
	case 7
        % cislo 7
        index=[1,2,3,4,8,12,15,18,21,25];
        m=7;
	case 8
        % cislo 8
        index=[2,3,5,8,9,12,14,15,17,20,21,24,26,27];
        m=8;
	case 9
        % cislo 9
        index=[2,3,5,8,9,12,14,15,16,20,24,26,27];
        m=9;
	otherwise
        % cislo 0
        index=[2,3,5,8,9,12,13,16,17,20,21,24,26,27];
        m=10;
	end
	if noise==0
	    numbers(index,k)=1;
	else
	    numbers(index,k)=numbers(index,k)+1-noise;    
	end
	target(m,k)=1;
end    

% zmena hodnoty definovanych bodov
if change_number>0
   for k=1:change_number,
       numbers(change_posit(k),:)=new_value(k);
   end
end