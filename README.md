# Итоговый проект по PostgreSQL

## Данные:
Ссылка на резервную копию в формате *.backup: [avia.backup](https://letsdocode.ru/sql-main/avia.backup). Восстанавливаете, как и предыдущие данные, согласно "Инструкции по установке ПО".
В облачной базе данных работаете с базой даных **total** и схемой **bookings**. Доступ только на чтение, все необходимые модули установлены.

## Описание БД:
Ссылка на описание демонстрационной базы данных: "Авиаперевозки".

### Задания:
1. Выведите название самолетов, которые имеют менее 50 посадочных мест?
2. Выведите процентное изменение ежемесячной суммы бронирования билетов, округленной до сотых.
3. Выведите названия самолетов не имеющих бизнес - класс. Решение должно быть через функцию array_agg.
4. Вывести накопительный итог количества мест в самолетах по каждому аэропорту на каждый день, учитывая только те самолеты, которые летали пустыми и только те дни, где из одного аэропорта таких самолетов вылетало более одного.
 В результате должны быть код аэропорта, дата, количество пустых мест в самолете и накопительный итог.
5. Найдите процентное соотношение перелетов по маршрутам от общего количества перелетов.
 Выведите в результат названия аэропортов и процентное отношение.
 Решение должно быть через оконную функцию.
6. Выведите количество пассажиров по каждому коду сотового оператора, если учесть, что код оператора - это три символа после +7
7. Классифицируйте финансовые обороты (сумма стоимости перелетов) по маршрутам:
 До 50 млн - low
 От 50 млн включительно до 150 млн - middle
 От 150 млн включительно - high
 Выведите в результат количество маршрутов в каждом полученном классе
8. Вычислите медиану стоимости перелетов, медиану размера бронирования и отношение медианы бронирования к медиане стоимости перелетов, округленной до сотых
9. Найдите значение минимальной стоимости полета 1 км для пассажиров. То есть нужно найти расстояние между аэропортами и с учетом стоимости перелетов получить искомый результат
  Для поиска расстояния между двумя точками на поверхности Земли используется модуль **earthdistance**.
  Для работы модуля **earthdistance** необходимо предварительно установить модуль **cube**.
  Установка модулей происходит через команду: **create extension название_модуля**.

## Пояснения:
**Перелет**, **рейс** - разовое перемещение самолета из аэропорта А в аэропорт Б.
**Маршрут** - формируется двумя аэропортами А и Б. При этом А - Б и Б - А - это разные маршруты.
Для решения заданий 8 и 9 необходимо самостоятельно использовать Документацию к PostgreSQL, так как в решении используются функции, которые не проходили в рамках обучения.