-- PRO_CM query

Insert into dcc_3dot1_pcornet.pro_cm(
	patid, encounterid,
	pro_item, pro_loinc,
	pro_date, pro_time,
	pro_response,
	pro_method,
	pro_mode,
	pro_cat,
	raw_pro_code, raw_pro_response
)
with 
	pro_sub as (Select * from observation where observation_concept_id IN ('','','','','','','','',''))
select 
	o.person_id as patid
	null as encounter_id -- Assume that they surverys are not associated with any encounter
	m1.target_concept_id as pro_item,
	c1.concept_code as pro_loinc,
	o.observation_date as pro_date,
	o.observation_time as pro_time,
	'EC' as pro_method, -- RedCAP?
	null as pro_mode, -- Proxy without assistance?
	null as pro_cat, -- No?
	c1.concept_code as raw_pro_code, -- LOINC code
	o.value_as_text as raw_pro_response
from
	dcc_pedsnet.observation o
	join dcc_3dot1_pcornet.demographic d on on o.person_id = d.patid
	join dcc_3dot1_pcornet.cz_omop_pcornet_concept_map m1 on o.observation_concept_id = m1.standard_concept_id and m1.source_concept_class = 'PRO Item'
	join vocabulary.concept c1 on o.observation_concept_id = c1.concept_id 
	
	
	
