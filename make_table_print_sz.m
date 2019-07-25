function [tabl] = make_table_print_sz (sz_proizvodstvo,sz_pol_am,sz_vivoz,all_zakaz)
% Функция для вывода заказов в генераторе СЗ

%all_zakaz=0;
%sz_proizvodstvo=1;
%sz_pol_am=0;
%sz_vivoz=0;

cd2='SELECT zakaz.code_vn, zakaz.zakaz_number, zakaz.srochno FROM zakaz';
cd11='SELECT zakaz.code_vn, zakaz.date_am_2, zakaz.date_am_11, zakaz.date_am_3, zakaz.sz_pol_am, zakaz.date_am_4, zakaz.date_am_5, zakaz.date_am_6, zakaz.date_am_7, zakaz.date_am_8,zakaz.date_am_9, zakaz.date_am_14, zakaz.date_1c FROM zakaz, zakaz_status WHERE zakaz.code_zakaz_status=zakaz_status.code';
cd10='SELECT zakaz.code_vn, zakaz.am_from_zakaz, zakaz_status.name, zakaz.need_am_code, zakaz.date_am_2, zakaz.date_am_11, zakaz.date_am_3, zakaz.sz_pol_am, zakaz.date_am_4, zakaz.date_am_5, zakaz.date_am_6, zakaz.date_am_7, zakaz.date_am_8, zakaz.date_am_9, zakaz.date_am_14, zakaz.comment, zakaz.date_1c FROM zakaz, zakaz_status WHERE zakaz.code_zakaz_status=zakaz_status.code AND zakaz.code_zakaz_status<>8 AND zakaz.code_zakaz_status <>10 AND zakaz.code_zakaz_status <>9';
cd='SELECT zakaz.code_vn, zakaz.zakaz_number, zakaz.zakaz_date, zakaz.date_prihod, logist.name, postavshiki.name, zakaz_status.name, zakaz.sz_zakaz_1, zakaz.sz_pol_am, zakaz.date_otgr_post_2, zakaz.comment, zakaz.am_from_zakaz, zakaz.need_am_code, zakaz.date_am_2, zakaz.date_am_11, zakaz.date_am_3, zakaz.date_am_4, zakaz.date_am_5, zakaz.date_am_6, zakaz.date_am_7, zakaz.date_am_8, zakaz.date_am_17, zakaz.date_am_9, zakaz.date_am_14 FROM zakaz, logist, postavshiki, zakaz_status WHERE zakaz.logist_code=logist.code AND zakaz.postavshik_code=postavshiki.code AND zakaz.code_zakaz_status=zakaz_status.code AND zakaz.code_zakaz_status <>8 AND zakaz.code_zakaz_status <>10 AND zakaz.code_zakaz_status <>9 ORDER BY zakaz.zakaz_date asc, postavshiki.name asc, zakaz.zakaz_number asc';
conn = database('Luding_wares_DB', '', ''); 
set(conn,'ReadOnly',1);
setdbprefs ('DataReturnFormat','cellarray'); 
curs=exec(conn,cd); curs=fetch(curs); tabl=curs.data; 
curs=exec(conn,cd10); curs=fetch(curs); am_status=curs.data;

if sz_proizvodstvo==1,
    curs=exec(conn,cd11); curs=fetch(curs); zakaz_podmena=curs.data;
elseif sz_vivoz==1,
    curs=exec(conn,cd11); curs=fetch(curs); zakaz_podmena=curs.data;
end;

curs=exec(conn,cd2); curs=fetch(curs); 
zakaz=curs.data; 

sr_zakaz=[zakaz(:,1) zakaz(:,3)];
zakaz(:,3)=[];
close(curs);
close(conn); 

clear conn curs cd cd11;


for i=1:length(tabl(:,1)),
if strcmp(tabl{i,7},'Для перезаказа марок')==1,
    tabl{i,12}=tabl{i,1};
    tabl{i,13}=true;
end;

if isnan(tabl{i,12})==1,
    tabl{i,12}=0;
end;


end;


if all_zakaz==1, % Выводим все актуальные заказы без тематического усечения
else
    if sz_proizvodstvo==1,
        tabl(~strcmp(tabl(:,8),'null'),:)=[]; % Удалили все где есть дата СЗ на заказ продукции на пр-ве
        if isempty(tabl)~=1,
         %   tabl(strcmp(tabl(:,7),'Для перезаказа марок'),:)=[]; % Удалили заказы для перезаказа марок
        end;
    elseif sz_pol_am==1,
        tabl(~strcmp(tabl(:,9),'null'),:)=[]; % Удалили все где есть дата СЗ на получение АМ
        if isempty(tabl)~=1,
            tabl(cell2mat(tabl(:,13))==0,:)=[]; % Удалили заказы где марки не нужны
        end;
        if isempty(tabl)~=1,
            tabl(cellfun(@isnan,tabl(:,12)),12)={0};
            
            
            
        tabl(:,end+1)={0};
        for i=1:length(tabl(:,1)),
            if (strcmp(tabl{i,7},'Для перезаказа марок')==0) && (tabl{i,1}~=tabl{i,12}),
                tabl{i,end}=1;
            end;
        end;
        
        tabl(cell2mat(tabl(:,end))==1,:)=[];
        end;
        if isempty(tabl)~=1,
            
            tabl(:,end)=[];
        end;
        
    elseif sz_vivoz==1,
        tabl(~strcmp(tabl(:,10),'null'),:)=[]; % Удалили все где есть дата СЗ на вывоз от поставщика
        if isempty(tabl)~=1,
            tabl(strcmp(tabl(:,7),'Для перезаказа марок'),:)=[]; % Удалили заказы для перезаказа марок
        end;
        
        
        
    end;
end;




% Вычисляем статус АМ

% Удаляем null      
for i=1:length(am_status(:,1)),
if isnan(am_status{i,2})==1, am_status{i,2}=0; end;
if strcmp(am_status{i,16},'null')==1, am_status{i,16}=''; end;
if strcmp(am_status{i,17},'null')==1, am_status{i,17}=''; end;
if strcmp(am_status{i,3},'Для перезаказа марок')==1,
    am_status{i,2}=am_status{i,1};
    am_status{i,4}=true;
end;
end;
%am_status(:,end)=[];

% Подменяем даты по маркам от заказа-донора
if sz_proizvodstvo==1,
    temp_zakaz_podmena=cell2mat(zakaz_podmena(:,1));
for i=1:length(am_status(:,1)),
    if am_status{i,2}==0,
        am_status{i,5}='';
        am_status{i,6}='';
        am_status{i,7}='';
        am_status{i,8}='';
        am_status{i,9}='';
        am_status{i,10}='';
        am_status{i,11}='';
        am_status{i,12}='';
        am_status{i,13}='';
        am_status{i,14}='';
        am_status{i,15}='';
        am_status{i,16}='';
        am_status{i,17}='';
    else
        ind=am_status{i,2}==temp_zakaz_podmena;
        if sum(ind)>0,
            am_status(i,5)=zakaz_podmena(ind,2);
            am_status(i,6)=zakaz_podmena(ind,3);
            am_status(i,7)=zakaz_podmena(ind,4);
            am_status(i,8)=zakaz_podmena(ind,5);
            am_status(i,9)=zakaz_podmena(ind,6);
            am_status(i,10)=zakaz_podmena(ind,7);
            am_status(i,11)=zakaz_podmena(ind,8);
            am_status(i,12)=zakaz_podmena(ind,9);
            am_status(i,13)=zakaz_podmena(ind,10);
            am_status(i,14)=zakaz_podmena(ind,11);
            am_status(i,15)=zakaz_podmena(ind,12);
            am_status(i,17)=zakaz_podmena(ind,13);
        else
            am_status{i,5}='';
            am_status{i,6}='';
            am_status{i,7}='';
            am_status{i,8}='';
            am_status{i,9}='';
            am_status{i,10}='';
            am_status{i,11}='';
            am_status{i,12}='';
            am_status{i,13}='';
            am_status{i,14}='';
            am_status{i,15}='';
            am_status{i,16}='';
            am_status{i,17}='';
        end;
    end;
end;
elseif sz_vivoz==1,
   temp_zakaz_podmena=cell2mat(zakaz_podmena(:,1));
for i=1:length(am_status(:,1)),
    if am_status{i,2}==0,
        am_status{i,5}='';
        am_status{i,6}='';
        am_status{i,7}='';
        am_status{i,8}='';
        am_status{i,9}='';
        am_status{i,10}='';
        am_status{i,11}='';
        am_status{i,12}='';
        am_status{i,13}='';
        am_status{i,14}='';
        am_status{i,15}='';
        am_status{i,16}='';
        am_status{i,17}='';
        
    else
        ind=am_status{i,2}==temp_zakaz_podmena;
        if sum(ind)>0,
            am_status(i,5)=zakaz_podmena(ind,2);
            am_status(i,6)=zakaz_podmena(ind,3);
            am_status(i,7)=zakaz_podmena(ind,4);
            am_status(i,8)=zakaz_podmena(ind,5);
            am_status(i,9)=zakaz_podmena(ind,6);
            am_status(i,10)=zakaz_podmena(ind,7);
            am_status(i,11)=zakaz_podmena(ind,8);
            am_status(i,12)=zakaz_podmena(ind,9);
            am_status(i,13)=zakaz_podmena(ind,10);
            am_status(i,14)=zakaz_podmena(ind,11);
            am_status(i,15)=zakaz_podmena(ind,12);
            am_status(i,17)=zakaz_podmena(ind,13);
        else
            am_status{i,5}='';
            am_status{i,6}='';
            am_status{i,7}='';
            am_status{i,8}='';
            am_status{i,9}='';
            am_status{i,10}='';
            am_status{i,11}='';
            am_status{i,12}='';
            am_status{i,13}='';
            am_status{i,14}='';
            am_status{i,15}='';
            am_status{i,16}='';
            am_status{i,17}='';            
        end;
    end;
end;
end;








% Удаляем null      
for i=1:length(am_status(:,1)),
if strcmp(am_status{i,5},'null')==1, am_status{i,5}=''; end;
if strcmp(am_status{i,6},'null')==1, am_status{i,6}=''; end;
if strcmp(am_status{i,7},'null')==1, am_status{i,7}=''; end;
if strcmp(am_status{i,8},'null')==1, am_status{i,8}=''; end;
if strcmp(am_status{i,9},'null')==1, am_status{i,9}=''; end;
if strcmp(am_status{i,10},'null')==1, am_status{i,10}=''; end;
if strcmp(am_status{i,11},'null')==1, am_status{i,11}=''; end;
if strcmp(am_status{i,12},'null')==1, am_status{i,12}=''; end;
if strcmp(am_status{i,13},'null')==1, am_status{i,13}=''; end;
if strcmp(am_status{i,14},'null')==1, am_status{i,14}=''; end;
if strcmp(am_status{i,15},'null')==1, am_status{i,15}=''; end;
if strcmp(am_status{i,16},'null')==1, am_status{i,16}=''; end;
if strcmp(am_status{i,17},'null')==1, am_status{i,17}=''; end;
end;

am_status=[am_status(:,1), am_status(:,3:end-1), am_status(:,2) am_status(:,end)];





am_status(:,end+1)={'Не определено'};

for i=1:length(am_status(:,1)),
if am_status{i,end-2}==0 && am_status{i,3}==true,
    am_status{i,end}='Не определено';
else
if isempty(am_status{i,4})==1 && isempty(am_status{i,5})==1 && isempty(am_status{i,6})==1 && isempty(am_status{i,17})==0 && isempty(am_status{i,9})==1 && isempty(am_status{i,10})==1 && isempty(am_status{i,11})==1 && isempty(am_status{i,12})==1 && isempty(am_status{i,14})==1 && am_status{i,3}==true && ( strcmp(am_status{i,2},'Планируется отгрузка от поставщика')==1 || strcmp(am_status{i,2},'Размещен (не передан поставщику)')==1 || strcmp(am_status{i,2},'Для перезаказа марок')==1 || strcmp(am_status{i,2},'Планируется производство заказа')==1),
    am_status{i,end}='Заказаны';
elseif isempty(am_status{i,4})==1 && isempty(am_status{i,5})==1 && isempty(am_status{i,6})==1 && isempty(am_status{i,17})==1 && isempty(am_status{i,9})==1 && isempty(am_status{i,10})==1 && isempty(am_status{i,11})==1 && isempty(am_status{i,12})==1 && isempty(am_status{i,14})==1 && am_status{i,3}==true && ( strcmp(am_status{i,2},'Планируется отгрузка от поставщика')==1 || strcmp(am_status{i,2},'Размещен (не передан поставщику)')==1 || strcmp(am_status{i,2},'Для перезаказа марок')==1 || strcmp(am_status{i,2},'Планируется производство заказа')==1),
    am_status{i,end}='Не заказаны';    
elseif isempty(am_status{i,4})==0 && isempty(am_status{i,5})==1 && isempty(am_status{i,6})==1  && isempty(am_status{i,9})==1 && isempty(am_status{i,10})==1 && isempty(am_status{i,11})==1 && isempty(am_status{i,12})==1 && isempty(am_status{i,14})==1 && am_status{i,3}==true,
    am_status{i,end}='Оплачены';
elseif isempty(am_status{i,5})==0 && isempty(am_status{i,6})==1 && isempty(am_status{i,9})==1 && isempty(am_status{i,10})==1 && isempty(am_status{i,11})==1 && isempty(am_status{i,12})==1 && isempty(am_status{i,14})==1 && am_status{i,3}==true,
    am_status{i,end}='Заявлены';
elseif isempty(am_status{i,6})==0 && isempty(am_status{i,7})==1 && isempty(am_status{i,8})==1 && isempty(am_status{i,9})==1 && isempty(am_status{i,10})==1 && isempty(am_status{i,11})==1 && isempty(am_status{i,12})==1 && isempty(am_status{i,14})==1 && am_status{i,3}==true,    
    am_status{i,end}='Готовы на ЦАТ';
elseif isempty(am_status{i,6})==0 && (isempty(am_status{i,7})==0 || isempty(am_status{i,8})==0) && isempty(am_status{i,9})==1 && isempty(am_status{i,10})==1 && isempty(am_status{i,11})==1 && isempty(am_status{i,12})==1 && isempty(am_status{i,14})==1 && am_status{i,3}==true,        
    am_status{i,end}='На получении';
elseif isempty(am_status{i,5})==0 && isempty(am_status{i,6})==1 && (isempty(am_status{i,7})==0 || isempty(am_status{i,8})==0) && isempty(am_status{i,9})==1 && isempty(am_status{i,10})==1 && isempty(am_status{i,11})==1 && isempty(am_status{i,12})==1 && isempty(am_status{i,14})==1 && am_status{i,3}==true,        
    am_status{i,end}='Заявлены';    
elseif isempty(am_status{i,9})==0 && isempty(am_status{i,10})==1 && isempty(am_status{i,11})==1 && isempty(am_status{i,12})==1 && isempty(am_status{i,14})==1 && am_status{i,3}==true,        
    am_status{i,end}='Получены';    
elseif isempty(am_status{i,10})==0 && isempty(am_status{i,11})==1 && isempty(am_status{i,12})==1 && isempty(am_status{i,14})==1 && am_status{i,3}==true,        
    am_status{i,end}='На штрихкодировании'; 
elseif isempty(am_status{i,11})==0 && isempty(am_status{i,12})==1 && isempty(am_status{i,14})==1 && am_status{i,3}==true,        
    am_status{i,end}='Отштрихкодированы';     
elseif isempty(am_status{i,12})==0 && isempty(am_status{i,13})==1 && strcmp(am_status{i,2},'На пути в Москву')==0 && strcmp(am_status{i,2},'На СВХ')==0 && strcmp(am_status{i,2},'Оприходован полностью')==0 && isempty(am_status{i,14})==1 && am_status{i,3}==true,        
    am_status{i,end}='Отправлены';   
elseif isempty(am_status{i,12})==0 && isempty(am_status{i,13})==0 && strcmp(am_status{i,2},'На пути в Москву')==0 && strcmp(am_status{i,2},'На СВХ')==0 && strcmp(am_status{i,2},'Оприходован полностью')==0 && isempty(am_status{i,14})==1 && am_status{i,3}==true,        
    am_status{i,end}='На тр. скл. / заводе';       
elseif isempty(am_status{i,12})==0 && ( strcmp(am_status{i,2},'На пути в Москву')==1 || strcmp(am_status{i,2},'На СВХ')==1) && isempty(am_status{i,14})==1 && am_status{i,3}==true,        
    am_status{i,end}='На пути в Москву';     
elseif isempty(am_status{i,12})==0 && strcmp(am_status{i,2},'Оприходован полностью')==1 && isempty(am_status{i,14})==1 && am_status{i,3}==true,        
    am_status{i,end}='Полностью ввезены в РФ';  
    elseif isempty(am_status{i,14})==0 && am_status{i,3}==true,    
    am_status{i,end}='Отказ от АМ';  
elseif am_status{i,3}==false,
    am_status{i,end}='АМ не нужны'; 
end;
end;

end;

am_status(:,2:17)=[];  


% Добавляем статусы АМ в таблицу
if isempty(tabl)~=1,
    
tabl(:,end+1)={''};
[c,ia,ib]=intersect(cell2mat(tabl(:,1)),cell2mat(am_status(:,1)));    
tabl(ia,end)=am_status(ib,2);

% Удаляем Null
for i=1:length(tabl(:,1)),
if strcmp(tabl{i,4},'null')==1, tabl{i,4}=''; end;
if strcmp(tabl{i,8},'null')==1,
   tabl{i,8}=0; 
else
   tabl{i,8}=1;  
end;
if strcmp(tabl{i,9},'null')==1,
   tabl{i,9}=0; 
else
   tabl{i,9}=1;  
end;

if strcmp(tabl{i,10},'null')==1,
   tabl{i,10}=0; 
else
   tabl{i,10}=1;  
end;
if strcmp(tabl{i,11},'null')==1, tabl{i,11}=''; end;
if strcmp(tabl{i,14},'null')==1, tabl{i,14}=''; end;
if strcmp(tabl{i,15},'null')==1, tabl{i,15}=''; end;
if strcmp(tabl{i,16},'null')==1, tabl{i,16}=''; end;
if strcmp(tabl{i,17},'null')==1, tabl{i,17}=''; end;
if strcmp(tabl{i,18},'null')==1, tabl{i,18}=''; end;
if strcmp(tabl{i,19},'null')==1, tabl{i,19}=''; end;
if strcmp(tabl{i,20},'null')==1, tabl{i,20}=''; end;
if strcmp(tabl{i,21},'null')==1, tabl{i,21}=''; end;
if strcmp(tabl{i,22},'null')==1, tabl{i,22}=''; end;
if strcmp(tabl{i,23},'null')==1, tabl{i,23}=''; end;
if strcmp(tabl{i,24},'null')==1, tabl{i,24}=''; end;


    
end;


% Заменяем код заказа-донора на его номер
tabl(:,end+1)={''};

if sz_proizvodstvo==1,
[c,ia,ib]=intersect(cell2mat(tabl(:,12)),cell2mat(zakaz(:,1)));
tabl(ia,end)=zakaz(ib,2);
elseif sz_pol_am==1,
    ind=cell2mat(tabl(:,13))==1;
    
    
    
tabl(ind,end)=tabl(ind,2);
elseif sz_vivoz==1,
[c,ia,ib]=intersect(cell2mat(tabl(:,12)),cell2mat(zakaz(:,1)));
tabl(ia,end)=zakaz(ib,2);
end;



% Перегруппировываем таблицу
tabl(:,end+1)={0};
tabl=[tabl(:,1), tabl(:,27), tabl(:,3), tabl(:,2), tabl(:,4:10), tabl(:,26), tabl(:,14:25), tabl(:,11)];

% Добавляем признак срочного заказа в таблицу
tabl(:,end+1)={0};
[c,ia,ib]=intersect(cell2mat(tabl(:,1)),cell2mat(sr_zakaz(:,1)));
tabl(ia,end)=(sr_zakaz(ib,2));

ind=cell2mat(tabl(:,end))==1;
tabl(ind,end)={'СРОЧНО'};
tabl(~ind,end)={''};
tabl=[tabl(:,1:(end-2)) tabl(:,end) tabl(:,end-1)];

shapka={'Внутренний код','','Дата заказа','Заказ №','Ожидаемая дата поступления заказа в продажу','Специалист по логистике','Поставщик','Статус заказа','З','П','Т','Заказ № от которого используются АМ','Фактическая дата оплаты акцизных марок','Дата заявления акцизных марок','Дата изготовления акцизных марок','Желаемая дата получения акцизных марок','Фактическая дата получения акцизных марок','Дата передачи акцизных марок на штрихкодирование','Дата окончания штрихкодирования акцизных марок','Желаемая дата отправки акцизных марок','Фактическая дата отправки акцизных марок','Дата получения акцизных марок на заводе / тр. складе','Дата отказа от акцизных марок','Статус акцизных марок','Срочный заказ','Комментарий'};
tabl=[shapka; tabl];
else
    tabl={'Внутренний код','','Дата заказа','Заказ №','Ожидаемая дата поступления заказа в продажу','Специалист по логистике','Поставщик','Статус заказа','З','П','Т','Заказ № от которого используются АМ','Фактическая дата оплаты акцизных марок','Дата заявления акцизных марок','Дата изготовления акцизных марок','Желаемая дата получения акцизных марок','Фактическая дата получения акцизных марок','Дата передачи акцизных марок на штрихкодирование','Дата окончания штрихкодирования акцизных марок','Желаемая дата отправки акцизных марок','Фактическая дата отправки акцизных марок','Дата получения акцизных марок на заводе / тр. складе','Дата отказа от акцизных марок','Статус акцизных марок','Срочный заказ','Комментарий'};
end;



clear all_zakaz am_status c cd10 i ia ib shapka sz_pol_am sz_proizvodstvo sz_vivoz cd2 ind zakaz sr_zakaz temp_zakaz_podmena zakaz_podmena;



