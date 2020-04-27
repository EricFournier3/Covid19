with v as (select NOLSPQ as no_lspq, AGE_ANNEE as age, RSS_PATIENT as rss_patient,AUCUN_VOYAGE as aucun_voyage, VOYAGE_PAYS_1 as voyage_pays_1, DATE_PRELEVEMENT as date_prelev, DATE_RECEPTION as date_recu,
CH as ch,RESULTAT_LABORATOIRE as res_lab, SUBSTR(POSTAL_CODE,1,3) as postal_code ,MAX(nCov2019_nCov_ARN) as max_res from (select distinct f.folderno as NOLSPQ, to_char(cr.BIRTH_DATE,'YYYY-MM-DD') as DATE_NAISSANCE,
p.LAST_NAME as NOM, p.FIRST_NAME as PRENOM, 
case 
    when FLOOR(MONTHS_BETWEEN(COALESCE(cr.DATE_COLLECTED,cr.DATE_RECEIVED),cr.BIRTH_DATE )/12) > 1
    THEN TRUNC(MONTHS_BETWEEN(COALESCE(cr.DATE_COLLECTED,cr.DATE_RECEIVED),cr.BIRTH_DATE)/12,0)
    else
        TRUNC(MONTHS_BETWEEN(COALESCE(cr.DATE_COLLECTED,cr.DATE_RECEIVED),cr.BIRTH_DATE )/12,2)
end as AGE_ANNEE,
p.SEX as SEX, cr.OWNER_COUNTY as RSS_PATIENT, cr.OWNER_ZIP as POSTAL_CODE,
case 
    when crm.FIELD45 is null 
    then 'O' 
    else 'N' 
end AS AUCUN_VOYAGE,
crm.FIELD45 as VOYAGE_PAYS_1,
nvl(to_char(cr.DATE_COLLECTED, 'YYYY-MM-DD'),'') AS DATE_PRELEVEMENT,
nvl(to_char(cr.DATE_RECEIVED, 'YYYY-MM-DD'),'') AS DATE_RECEPTION,
rc.COMPNAME AS CH,
replace(replace(replace(crm.FIELD06, chr(13), ' '), chr(10),' '),';',':') AS RESULTAT_LABORATOIRE,
( select    
    case 
        when coro.SINONYM like '%MIRU%' 
        then coro.NUMRES 
        else coro.FINAL 
    end 
    from RESULTS coro
    where coro.ORDNO = ot.ORDNO  AND coro.TESTNO='2019-nCoV'  AND coro.ANALYTE='2019-nCoV ARN'  and coro.REPORTABLE = 'Y' 
    and coro.ORIGREC = ( select max(origrec) from results res2 where res2.ordno=coro.ordno and res2.testno=coro.testno AND res2.TESTNO='2019-nCoV' and res2.ANALYTE='2019-nCoV ARN' )
) as nCoV2019_nCoV_ARN

from 
		CENTRALRECEIVING cr 
		inner join FOLDERS f on f.FOLDERNO = cr.EXTERNAL_ID 
		inner join METADATA crm on crm.ID = cr.METADATA_GUID 
		inner join RASCLIENTS rc on rc.RASCLIENTID = cr.RASCLIENTID 
		left join PATIENTS p on p.PID = cr.PID 
		inner join ORDERS o on o.FOLDERNO = cr.EXTERNAL_ID 
		inner join ORDTASK ot on ot.ORDNO = o.ORDNO
        
where 
		ot.TESTCODE in (2685,2689,2167) and cr.DATE_RECEIVED > to_date('2020-04-20', 'YYYY-MM-DD') 
        and cr.PANEL_LIST like '2019-nCoV%' and rc.RASCLIENTID not in ('LSPQCEC','LSPQCIC','LSPQF','LSPQP','LSPQV')  
        
order by f.FOLDERNO)   GROUP BY NOLSPQ, AGE_ANNEE, RSS_PATIENT,AUCUN_VOYAGE, VOYAGE_PAYS_1, DATE_PRELEVEMENT, DATE_RECEPTION,
CH,RESULTAT_LABORATOIRE, POSTAL_CODE ORDER BY NOLSPQ) select v.no_lspq,v.age,v.rss_patient,v.aucun_voyage, v.voyage_pays_1, v.date_prelev,
v.date_recu, v.ch, v.postal_code,  v.max_res from v where  v.max_res in ('Détecté','détecté');   
