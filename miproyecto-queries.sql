-- 1. Mostrar los nombres de los equipos junto con la suma de los minutos en los que sus jugadores han anotado goles y lo ordena en orden descendiente según la cantidad total de minutos de goles anotados.
select e.nombre_equipo, SUM(g.minuto) as suma_minutos
from equipo e inner join fichajes f
on e.nombre_equipo = f.EQUIPO_nombre_equipo inner join jugador j
on f.JUGADOR_dni = j.dni left join gol g
on j.dni = g.jugador_marca
group by e.nombre_equipo
order by suma_minutos desc;

-- 2. Obtener el nombre del estadio y la cantidad total de partidos jugados en ese estadio donde su numero de telefono se encuentra entre 100000000 y 200000000
select nombre_estadio, telefono, count(*) as total_partidos
from estadio e inner join juegan j
on e.nombre_estadio = j.ESTADIO_nombre_estadio inner join partido p 
on j.EQUIPO_nombre_equipo = p.EQUIPO_nombre_local or j.EQUIPO_nombre_equipo = p.EQUIPO_nombre_visitante 
group by nombre_estadio 
having e.telefono BETWEEN 100000000 and 200000000;

-- 3. Obtener los jugadores que su nombre comienza por la letra 'J' y cuya tarifa es mayor que el promedio de la tarifa de todos los jugadores 
select j.nombre, j.apellidos, f.EQUIPO_nombre_equipo 
from jugador j inner join fichajes f 
on j.dni = f.JUGADOR_dni 
where f.tarifa_transferencia > (
	SELECT avg(f2.tarifa_transferencia)
	from fichajes f2 
) and j.nombre like 'J%';

-- 4. Obtener la cantidad de partidos jugados por cada equipo en una temporada específica y el resultado de cada partido
select nombre_equipo, t.nombre_temporada, count(p.id_partido) as Partidos_jugados, group_concat(p.resultado) as Resultados  
from equipo e inner join partido p 
on e.nombre_equipo = p.EQUIPO_nombre_local or e.nombre_equipo = p.EQUIPO_nombre_visitante inner join temporada t 
on p.TEMPORADA_nombre_temporada = t.nombre_temporada 
group by nombre_equipo , nombre_temporada;

-- 5. Obtener al jugador que ha marcado 2 goles en la Temporada 1
select nombre, nombre_temporada, count(g.jugador_marca) as Goles_marcados 
from jugador j inner join gol g 
on j.dni = g.jugador_marca inner join partido p 
on g.PARTIDO_id_partido = p.id_partido inner join temporada t 
on p.TEMPORADA_nombre_temporada = t.nombre_temporada 
group by j.dni, t.nombre_temporada 
having Goles_marcados='2' and nombre_temporada='Temporada 1';

-- Primera vista
create view primera as
	select e.nombre_equipo, SUM(g.minuto) as suma_minutos
	from equipo e inner join fichajes f
	on e.nombre_equipo = f.EQUIPO_nombre_equipo inner join jugador j
	on f.JUGADOR_dni = j.dni left join gol g
	on j.dni = g.jugador_marca
	group by e.nombre_equipo
	order by suma_minutos desc;

-- Segunda vista
create view segunda as 
	select nombre_estadio, telefono, count(*) as total_partidos
	from estadio e inner join juegan j
	on e.nombre_estadio = j.ESTADIO_nombre_estadio inner join partido p 
	on j.EQUIPO_nombre_equipo = p.EQUIPO_nombre_local or j.EQUIPO_nombre_equipo = p.EQUIPO_nombre_visitante 
	group by nombre_estadio 
	having e.telefono BETWEEN 100000000 and 200000000;

-- 1. Esta funcion toma el nombre del equipo como parámetro y devuelve la edad media de los jugadores del equipo
delimiter $$
create function edadMediaEquipo(nombre_equipo varchar(25))
returns decimal(10, 2)
deterministic
begin
    declare edad_total decimal(10, 2);
    declare cantidad_jugadores int;
    
    select sum(timestampdiff(year, fecha_nacimiento, curdate())) into edad_total
    from jugador
    where dni in (select jugador_dni from fichajes where equipo_nombre_equipo = nombre_equipo);
    
    select count(*) into cantidad_jugadores
    from fichajes
    where equipo_nombre_equipo = nombre_equipo;
    
    return edad_total / cantidad_jugadores;
end $$
delimiter ;

select edadMediaEquipo("Real Betis");

-- 2. Esta funcion toma el id del arbitro y devuelve el número de partidos que ha arbitrado ese árbitro
delimiter $$
create function numeroPartidosArbitrados(arbitro_id int) returns int
deterministic
begin
    declare num_partidos int;
    
    select count(*) into num_partidos
    from arbitro
    where id_arbitro = arbitro_id;
    
    if num_partidos > 0 then
        select count(*)
        into num_partidos
        from partido
        where arbitro_id_arbitro = arbitro_id;
        return num_partidos;
    else
        return null; 
    end if;
end $$
delimiter ;

select numeroPartidosArbitrados(5);

-- 1. Procedimiento para seleccionar el nombre de los equipos, el nombre del entrenador y la cantidad 
-- de jugadores que tiene cada equipo
delimiter $$
create procedure consultarEquipos()
begin
    select 
        equipo.nombre_equipo,
        equipo.entrenador,
        count(jugador.dni) as cantidad_jugadores
    from 
        equipo
    inner join 
        fichajes on equipo.nombre_equipo = fichajes.equipo_nombre_equipo
    inner join 
        jugador on fichajes.jugador_dni = jugador.dni
    group by equipo.nombre_equipo, equipo.entrenador
    order by equipo.nombre_equipo;
end $$
delimiter ;

call consultarequipos();

-- 2. Procedimiento que utiliza un cursor para hacer un informe de los estadios
delimiter $$

create procedure resumenEstadios()
begin
   declare done int default false;
   declare estadio_nombre varchar(20);
   declare estadio_ciudad varchar(20);
   declare estadio_telefono varchar(20);
   declare resumen varchar(5000) default '';
   declare contador int default 1;

   -- Cursor para recorrer los estadios
   declare cursor_estadios cursor for
       select nombre_estadio, ciudad, telefono from estadio;
   
   -- Manejador para el fin del cursor
   declare continue handler for not found set done = true;

   -- Encabezado
   set resumen = concat(resumen, '================= RESUMEN DE ESTADIOS ====================\n');

   open cursor_estadios;
   
   leer_estadios: loop
       fetch cursor_estadios into estadio_nombre, estadio_ciudad, estadio_telefono;
       if done then
           leave leer_estadios;
       end if;
       
       -- Informacion de cada estadio
       set resumen = concat(resumen, '\n', contador, '. nombre: ', estadio_nombre, ', ciudad: ', estadio_ciudad, ', teléfono: ', estadio_telefono);
       set contador = contador + 1;
   end loop leer_estadios;

   -- Mostramos el informe
   select resumen;
   
   close cursor_estadios;
end $$

delimiter ;

call resumenEstadios();

-- 3. Procedimiento en el que se utiliza la funcion 'edadMediaEquipo' en el que se calcula la 
-- edad media del equipo que juega en el estadio que se recibe como parametro
delimiter $$
create procedure calcularEdadMediaEquipoEnEstadio(in nombre_estadio varchar(20))
begin
    declare nombre_equipo_en_estadio varchar(25);
    declare edad_media decimal(10, 2);
    
    select equipo_nombre_equipo into nombre_equipo_en_estadio
    from juegan
    where estadio_nombre_estadio = nombre_estadio;
    
    set edad_media = edadmediaequipo(nombre_equipo_en_estadio);

    select concat('La edad media de los jugadores del equipo que juega en el estadio ', nombre_estadio,' es: ', edad_media, ' años') as resultado;
end $$
delimiter ;

call calcularEdadMediaEquipoEnEstadio('Benito Villamarín');

-- 1. Creamos un trigger en el que al insertar un jugador, si su nombre es nulo mandará un mensaje de error personalizado.
delimiter $$
create trigger before_insert_jugador
before insert on jugador
for each row
begin
	
	if new.nombre is null then
		signal sqlstate '45000' set message_text = 'Es obligatorio introducir el nombre del jugador';
	end if;


end $$
delimiter ;


insert into jugador (dni, nombre, apellidos, fecha_nacimiento, telefono)
values ('43218401F', null, 'Sanchez', '2003-04-27', '123456789');


-- 2. Creamos un trigger en el que antes de eliminar un estadio, esa eliminación se guarda 
-- en una nueva tabla (eliminados)
create table eliminados (
	nombre_estadio varchar(20) primary key,
	ciudad varchar(20),
	telefono varchar(10)
);

delimiter $$
create trigger before_estadio_delete
before delete on estadio
for each row
begin
	insert into eliminados (nombre_estadio, ciudad, telefono) values(old.nombre_estadio, old.ciudad, old.telefono);
end $$
delimiter ;

delete from estadio where nombre_estadio = 'Principe de Asturia';
