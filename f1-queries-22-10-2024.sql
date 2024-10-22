

WITH LastPitStop AS (
    SELECT 
        l.id,
        l.number,
        -- Find the most recent pitstop lap order before the current lap
        COALESCE(
            MAX(ps.lap_id) OVER (PARTITION BY l.session_entry_id 
			ORDER BY l.number asc ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING),
            0 -- If no pitstop, default to 0 (race start)
        ) AS last_pitstop_lap
    FROM 
        formula_one_lap  l
    LEFT JOIN 
        formula_one_pitstop ps ON l.id = ps.lap_id -- Optional join with pitstop
)
select 
ROUND(EXTRACT(HOUR FROM l.time) * 3600 + 
    EXTRACT(MINUTE FROM l.time) * 60 + 
    EXTRACT(SECOND FROM l.time) 
	- coalesce (EXTRACT(HOUR FROM psminus.duration) * 3600 + 
    EXTRACT(MINUTE FROM psminus.duration) * 60 + 
    EXTRACT(SECOND FROM psminus.duration),0) , 3)
	as laptime, 
l.number as lap_num,
 l.id -  COALESCE(
	CASE WHEN lp.last_pitstop_lap = 0 then l.id-l.number
	ELSE lp.last_pitstop_lap END, lp.last_pitstop_lap) AS lap_no_since_last_pitstop_or_start,
l.position as position_during_lap,
dr.reference as driver_ref,
(s.date - dr.date_of_birth)/30/12 as age,
team.reference as team_ref,
c.reference as circuit_ref,
se.detail as session_status,
se.grid as start_pos,
s.date as race_date
from formula_one_lap  l
LEFT JOIN 
    LastPitStop lp ON l.id = lp.id
left join formula_one_pitstop ps on ps.lap_id = l.id
left join formula_one_pitstop psminus on psminus.lap_id = l.id-1
join formula_one_sessionentry se on l.session_entry_id = se.id
join formula_one_session s on se.session_id = s.id
join formula_one_round r on r.id = s.round_id
join formula_one_season ss on ss.id = r.season_id
join formula_one_circuit c on c.id = r.circuit_id 
join formula_one_roundentry re on se.round_entry_id = re.id
join formula_one_teamdriver td on td.id = re.team_driver_id
join formula_one_team team on team.id = td.team_id
join formula_one_driver dr on dr.id = td.driver_id
and s.type like 'R' and l.time is not null
order by s.date desc, start_pos asc, start_pos  asc, lap_num asc;