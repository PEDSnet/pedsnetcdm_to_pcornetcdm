-- PRESCRIBING table

insert into dcc_start2001_pcornet.prescribing (prescribingid,
            patid, encounterid, 
            rx_providerid, rx_order_date, rx_order_time,
            rx_start_date, rx_end_date, rx_quantity, rx_refills, rx_days_supply, rx_frequency, rx_basis,
            rxnorm_cui,
            raw_rx_med_name, raw_rx_frequency, raw_rxnorm_cui,site)
select 
	* from dcc_pcornet.prescribing
where
	patid IN (select cast(person_id as text) from dcc_start2001_pcornet.person_visit_start2001) and EXTRACT(YEAR FROM rx_order_date) >= 2001;

