slect average pitstops time from all years
select avg(EXTRACT(HOUR FROM p.duration) * 3600 + 
    EXTRACT(MINUTE FROM p.duration) * 60 + 
    EXTRACT(SECOND FROM p.duration)) AS duration_seconds, 
	ss.year from formula_one_pitstop p
join formula_one_sessionentry se on p.session_entry_id = se.id
join formula_one_session s on se.session_id = s.id
join formula_one_round r on r.id = s.round_id
join formula_one_season ss on ss.id = r.season_id
where s.type like 'R'
group by ss.year order by ss.year  ;

-- select all pitstops in order of longest to shortest
select p.duration, ss.year, c.name, se.status, se.detail, concat(dr.forename, ' ',  dr.surname)
from formula_one_pitstop p
join formula_one_sessionentry se on p.session_entry_id = se.id
join formula_one_session s on se.session_id = s.id
join formula_one_round r on r.id = s.round_id
join formula_one_season ss on ss.id = r.season_id
join formula_one_circuit c on c.id = r.circuit_id 
join formula_one_roundentry re on se.round_entry_id = re.id
join formula_one_teamdriver td on td.id = re.team_driver_id
join formula_one_driver dr on dr.id = td.driver_id
where s.type like 'R' and ss.year = 2020  order by duration desc;

select * from ergast_status;

--select avg duration of a pitstop in a race during a particular year
select avg(p.duration) from formula_one_pitstop p
join formula_one_sessionentry se on p.session_entry_id = se.id
join formula_one_session s on se.session_id = s.id
join formula_one_round r on r.id = s.round_id
join formula_one_season ss on ss.id = r.season_id
join formula_one_circuit c on c.id = r.circuit_id 
join formula_one_roundentry re on se.round_entry_id = re.id
join formula_one_teamdriver td on td.id = re.team_driver_id
join formula_one_driver dr on dr.id = td.driver_id
where ss.year=2023 and c.locality like 'Monza';

select * from ergast_sprint_results;
-- all lap time from lewis in bahrain 2020 - pitstop removed 
select l.id, 
EXTRACT(HOUR FROM l.time) * 3600 + 
    EXTRACT(MINUTE FROM l.time) * 60 + 
    EXTRACT(SECOND FROM l.time) 
	- coalesce (EXTRACT(HOUR FROM psminus.duration) * 3600 + 
    EXTRACT(MINUTE FROM psminus.duration) * 60 + 
    EXTRACT(SECOND FROM psminus.duration),0) 
	as laptime, 
	ss.year, c.name, 
concat(dr.forename, ' ',  dr.surname) as dname, 
EXTRACT(HOUR FROM ps.duration) * 3600 + 
    EXTRACT(MINUTE FROM ps.duration) * 60 + 
    EXTRACT(SECOND FROM ps.duration) as pitstop_time
from formula_one_lap  l
left join formula_one_pitstop ps on ps.lap_id = l.id
left join formula_one_pitstop psminus on psminus.lap_id = l.id-1
join formula_one_sessionentry se on l.session_entry_id = se.id
join formula_one_session s on se.session_id = s.id
join formula_one_round r on r.id = s.round_id
join formula_one_season ss on ss.id = r.season_id
join formula_one_circuit c on c.id = r.circuit_id 
join formula_one_roundentry re on se.round_entry_id = re.id
join formula_one_teamdriver td on td.id = re.team_driver_id
join formula_one_driver dr on dr.id = td.driver_id
where c.name like 'Bahrain%' and dr.surname like 'Hamilton' 
and s.type like 'R' and ss.year = 2020;

-- all lap time from lewis in bahrain 2020 - pitstop added 
select l.id, l.time as timefin, ss.year, c.name, 
concat(dr.forename, ' ',  dr.surname) as dname
from formula_one_lap  l
join formula_one_sessionentry se on l.session_entry_id = se.id
join formula_one_session s on se.session_id = s.id
join formula_one_round r on r.id = s.round_id
join formula_one_season ss on ss.id = r.season_id
join formula_one_circuit c on c.id = r.circuit_id 
join formula_one_roundentry re on se.round_entry_id = re.id
join formula_one_teamdriver td on td.id = re.team_driver_id
join formula_one_driver dr on dr.id = td.driver_id
where c.name like 'Bahrain%' and dr.surname like 'Hamilton' 
and s.type like 'R' and ss.year = 2020;
-- group by ss.year, c.name, dname order by timefin desc;

-- find trend in track monza -- average lap time minus all the accumulate from pitstop
select  
avg(EXTRACT(HOUR FROM l.time) * 3600 + 
    EXTRACT(MINUTE FROM l.time) * 60 + 
    EXTRACT(SECOND FROM l.time)
	- coalesce (EXTRACT(HOUR FROM psminus.duration) * 3600 + 
    EXTRACT(MINUTE FROM psminus.duration) * 60 + 
    EXTRACT(SECOND FROM psminus.duration),0) ) 
	as laptime, 
	ss.year
from formula_one_lap  l
left join formula_one_pitstop ps on ps.lap_id = l.id
left join formula_one_pitstop psminus on psminus.lap_id = l.id-1
join formula_one_sessionentry se on l.session_entry_id = se.id
join formula_one_session s on se.session_id = s.id
join formula_one_round r on r.id = s.round_id
join formula_one_season ss on ss.id = r.season_id
join formula_one_circuit c on c.id = r.circuit_id 
join formula_one_roundentry re on se.round_entry_id = re.id
join formula_one_teamdriver td on td.id = re.team_driver_id
join formula_one_driver dr on dr.id = td.driver_id
where s.type like 'R' and c.reference like 'monza'
group by ss.year order by ss.year asc;



-- select * from formula_one_lap;
-- select * from formula_one_circuit cc
-- join formula_one_round r on r.circuit_id = cc.id
-- join formula_one_season ss on r.season_id = ss.id
-- where cc.reference like '%monza%' or cc.name like '%monza%';

-- select * from formula_one_pitstop;
-- SELECT ST_Distance(
--     select location from formula_one_circuit where locality like 'Monza' limit 1,
--     select location from formula_one_circuit where locality like 'Silverstone' limit 1
-- );

-- select location from formula_one_circuit where locality like 'Monza' limit 1;