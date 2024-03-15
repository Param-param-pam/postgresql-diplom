--1. Выведите название самолетов, которые имеют менее 50 посадочных мест? 

select model, count(s.seat_no) as "Количество посадочных мест"
from aircrafts a 
join seats s on a.aircraft_code = s.aircraft_code
group by model 
having count(s.seat_no)<50 


--2. Выведите процентное изменение ежемесячной суммы бронирования билетов, округленной до сотых.

select date_trunc('month', b.book_date)::date, sum (total_amount) as "ежемесечная сумма", lead (sum (total_amount),1) over (order by date_trunc('month', b.book_date)::date), 
round (lead (sum (total_amount),1) over ()/sum (total_amount)*100, 2) as "% изменение"
from bookings b 
group by date_trunc('month', b.book_date)::date
order by date_trunc('month', b.book_date)::date


--3. Выведите названия самолетов не имеющих бизнес - класс. Решение должно быть через функцию array_agg.

select *
from
	(select a.model, array_agg (distinct fare_conditions:: text)
	from seats s 
	join aircrafts a on s.aircraft_code = a.aircraft_code 
	group by a.model) t
where 'Business' != all (t.array_agg)		
	

--4. Вывести накопительный итог количества мест в самолетах по каждому аэропорту на каждый день, 
--учитывая только те самолеты, которые летали пустыми и только те дни, 
--где из одного аэропорта таких самолетов вылетало более одного.
--В результате должны быть код аэропорта, дата, количество пустых мест и накопительный итог.

with cte1 as(
select count (t.flight_id), t.scheduled_departure, t.departure_airport, t.boarding_no, t.aircraft_code
from
	(select f.flight_id, f.flight_no, scheduled_departure::date, departure_airport, aircraft_code, bp.boarding_no, bp.seat_no, f.status 
	from flights f 
	left join boarding_passes bp on bp.flight_id =f.flight_id
	where bp.boarding_no is null and (f.status = 'Departed' or f.status = 'Arrived')
	group by f.flight_id, bp.boarding_no, bp.seat_no)t
group by t.scheduled_departure, t.departure_airport, t.boarding_no, t.aircraft_code
having  count (t.flight_id) > 1)
select c1.departure_airport, c1.scheduled_departure, count(s.seat_no) as "количество пустых мест", 
 	sum (count(s.seat_no)) over (partition by c1.departure_airport order by c1.scheduled_departure rows between unbounded preceding and current row) as "накопительный итог"
from aircrafts a
join cte1 c1 on c1.aircraft_code = a.aircraft_code
join seats s on a.aircraft_code = s.aircraft_code
group by c1.departure_airport, c1.scheduled_departure, c1.aircraft_code


--5. Найдите процентное соотношение перелетов по маршрутам от общего количества перелетов. 
--Выведите в результат названия аэропортов и процентное отношение.
--Решение должно быть через оконную функцию. 


select distinct a.airport_name as "аэропорт отправления", a2.airport_name as "аэропорт прибытия", 
round(100.0 * count(flight_id) over (partition by departure_airport, arrival_airport)/count(flight_id) over (), 2) as "% перелетов по маршрутам" 
from flights f 
join airports a on f.departure_airport = a.airport_code 
join airports a2 on f.arrival_airport = a2.airport_code 
group by flight_id, a.airport_name, a2.airport_name


--6. Выведите количество пассажиров по каждому коду сотового оператора, 
--если учесть, что код оператора - это три символа после +7

select substring(contact_data ->> 'phone', 3, 3), count(passenger_id) 
from tickets t 
group by substring(contact_data ->> 'phone', 3, 3)

--7. Классифицируйте финансовые обороты (сумма стоимости билетов) по маршрутам:
--До 50 млн - low
--От 50 млн включительно до 150 млн - middle
--От 150 млн включительно - high
--Выведите в результат количество маршрутов в каждом полученном классе.

select t.case as "класс", count(*) as "количество маршрутов"
from (
	select f.departure_airport, f.arrival_airport, sum (tf.amount),
	case 
		when sum (tf.amount) < 50000000 then 'low'
		when sum (tf.amount) between 50000000 and 150000000 then 'middle'
		when sum (tf.amount) > 150000000 then 'high'
	end
	from flights f 
	join ticket_flights tf on f.flight_id = tf.flight_id 
	group by f.departure_airport, f.arrival_airport
	) t
group by t.case

--8. Вычислите медиану стоимости билетов,
-- медиану размера бронирования и отношение медианы бронирования к медиане стоимости билетов, округленной до сотых.

select t.percentile_cont, lead (t.percentile_cont) over () as "медана бронирований", 
		round ((lead (t.percentile_cont) over ()/t.percentile_cont)::dec,2)
from
	(select percentile_cont(0.5) within group (order by total_amount)
	from bookings b
	union
	select percentile_cont(0.5) within group (order by amount)
	from ticket_flights tf) t
	limit 1
 

--9. Найдите значение минимальной стоимости полета 1 км для пассажиров. 
--То есть нужно найти расстояние между аэропортами и с учетом стоимости билетов получить искомый результат.
--Для поиска расстояния между двумя точка на поверхности Земли нужно использовать дополнительный модуль
--earthdistance (https://postgrespro.ru/docs/postgresql/15/earthdistance).
-- Для работы данного модуля нужно установить еще один модуль cube (https://postgrespro.ru/docs/postgresql/15/cube). 
--Установка дополнительных модулей происходит через оператор create extension название_модуля.
--Функция earth_distance возвращает результат в метрах.
--В облачной базе данных модули уже установлены.


create extension cube

create extension earthdistance


with cte6 as(
select f.flight_id, departure_airport,a.longitude, a.latitude, arrival_airport, a2.longitude, a2.latitude,
	round (earth_distance (ll_to_earth (a.latitude,a.longitude), ll_to_earth (a2.latitude, a2.longitude))::dec * 0.001 , 2)
from flights f 
join airports a on f.departure_airport = a.airport_code 
join airports a2 on f.arrival_airport = a2.airport_code 
group by f.flight_id, a.longitude, a.latitude, a2.longitude, a2.latitude)
select c6.flight_id, c6.departure_airport, c6.arrival_airport, c6.round as "расстояние между аэропортами", tf.amount, round (tf.amount/c6.round, 2) as "цена за км"
from ticket_flights tf
join cte6 c6 on c6.flight_id = tf.flight_id 
group by c6.flight_id, c6.round, tf.amount, c6.departure_airport, c6.arrival_airport
order by 6
limit 1