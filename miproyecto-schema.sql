-- mydb.arbitro definition

CREATE TABLE `arbitro` (
  `id_arbitro` int NOT NULL,
  `nombre` varchar(25) DEFAULT NULL,
  `apellidos` varchar(30) DEFAULT NULL,
  `telefono` varchar(10) DEFAULT NULL,
  `nacionalidad` varchar(25) DEFAULT NULL,
  PRIMARY KEY (`id_arbitro`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3;


-- mydb.equipo definition

CREATE TABLE `equipo` (
  `nombre_equipo` varchar(25) NOT NULL,
  `entrenador` varchar(45) DEFAULT NULL,
  `año_fundacion` varchar(10) DEFAULT NULL,
  PRIMARY KEY (`nombre_equipo`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3;


-- mydb.estadio definition

CREATE TABLE `estadio` (
  `nombre_estadio` varchar(20) NOT NULL,
  `ciudad` varchar(20) DEFAULT NULL,
  `telefono` varchar(10) DEFAULT NULL,
  PRIMARY KEY (`nombre_estadio`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3;


-- mydb.jugador definition

CREATE TABLE `jugador` (
  `dni` varchar(10) NOT NULL,
  `nombre` varchar(15) DEFAULT NULL,
  `apellidos` varchar(20) DEFAULT NULL,
  `fecha_nacimiento` date DEFAULT NULL,
  `telefono` varchar(10) DEFAULT NULL,
  PRIMARY KEY (`dni`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3;


-- mydb.temporada definition

CREATE TABLE `temporada` (
  `nombre_temporada` varchar(15) NOT NULL,
  `fecha_inicio` date DEFAULT NULL,
  `fecha_fin` date DEFAULT NULL,
  PRIMARY KEY (`nombre_temporada`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3;


-- mydb.fichajes definition

CREATE TABLE `fichajes` (
  `EQUIPO_nombre_equipo` varchar(25) NOT NULL,
  `JUGADOR_dni` varchar(10) NOT NULL,
  `fecha_inicio` varchar(15) DEFAULT NULL,
  `fecha_fin` varchar(15) NOT NULL,
  `tarifa_transferencia` varchar(20) DEFAULT NULL,
  `contrato` varchar(20) DEFAULT NULL,
  `clausula` varchar(20) DEFAULT NULL,
  PRIMARY KEY (`EQUIPO_nombre_equipo`,`JUGADOR_dni`),
  KEY `fk_EQUIPO_has_JUGADOR_JUGADOR1` (`JUGADOR_dni`),
  CONSTRAINT `fk_EQUIPO_has_JUGADOR_EQUIPO1` FOREIGN KEY (`EQUIPO_nombre_equipo`) REFERENCES `equipo` (`nombre_equipo`),
  CONSTRAINT `fk_EQUIPO_has_JUGADOR_JUGADOR1` FOREIGN KEY (`JUGADOR_dni`) REFERENCES `jugador` (`dni`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3;


-- mydb.juegan definition

CREATE TABLE `juegan` (
  `EQUIPO_nombre_equipo` varchar(25) NOT NULL,
  `ESTADIO_nombre_estadio` varchar(20) NOT NULL,
  PRIMARY KEY (`EQUIPO_nombre_equipo`,`ESTADIO_nombre_estadio`),
  KEY `fk_EQUIPO_has_ESTADIO_ESTADIO1` (`ESTADIO_nombre_estadio`),
  CONSTRAINT `fk_EQUIPO_has_ESTADIO_EQUIPO1` FOREIGN KEY (`EQUIPO_nombre_equipo`) REFERENCES `equipo` (`nombre_equipo`),
  CONSTRAINT `fk_EQUIPO_has_ESTADIO_ESTADIO1` FOREIGN KEY (`ESTADIO_nombre_estadio`) REFERENCES `estadio` (`nombre_estadio`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3;


-- mydb.partido definition

CREATE TABLE `partido` (
  `id_partido` int NOT NULL,
  `num_jornada` varchar(15) DEFAULT NULL,
  `fecha_y_hora` date DEFAULT NULL,
  `resultado` varchar(20) DEFAULT NULL,
  `TEMPORADA_nombre_temporada` varchar(15) NOT NULL,
  `ARBITRO_id_arbitro` int NOT NULL,
  `EQUIPO_nombre_local` varchar(25) NOT NULL,
  `EQUIPO_nombre_visitante` varchar(25) NOT NULL,
  PRIMARY KEY (`id_partido`),
  KEY `fk_PARTIDO_TEMPORADA` (`TEMPORADA_nombre_temporada`),
  KEY `fk_PARTIDO_ARBITRO1` (`ARBITRO_id_arbitro`),
  KEY `fk_PARTIDO_EQUIPO1` (`EQUIPO_nombre_local`),
  KEY `fk_PARTIDO_EQUIPO2` (`EQUIPO_nombre_visitante`),
  CONSTRAINT `fk_PARTIDO_ARBITRO1` FOREIGN KEY (`ARBITRO_id_arbitro`) REFERENCES `arbitro` (`id_arbitro`),
  CONSTRAINT `fk_PARTIDO_EQUIPO1` FOREIGN KEY (`EQUIPO_nombre_local`) REFERENCES `equipo` (`nombre_equipo`),
  CONSTRAINT `fk_PARTIDO_EQUIPO2` FOREIGN KEY (`EQUIPO_nombre_visitante`) REFERENCES `equipo` (`nombre_equipo`),
  CONSTRAINT `fk_PARTIDO_TEMPORADA` FOREIGN KEY (`TEMPORADA_nombre_temporada`) REFERENCES `temporada` (`nombre_temporada`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3;


-- mydb.gol definition

CREATE TABLE `gol` (
  `minuto` varchar(10) NOT NULL,
  `tipo` varchar(15) DEFAULT NULL,
  `jugador_marca` varchar(10) NOT NULL,
  `jugador_asiste` varchar(10) NOT NULL,
  `PARTIDO_id_partido` int NOT NULL,
  KEY `fk_GOL_JUGADOR1` (`jugador_marca`),
  KEY `fk_GOL_JUGADOR2` (`jugador_asiste`),
  KEY `fk_GOL_PARTIDO1` (`PARTIDO_id_partido`),
  CONSTRAINT `fk_GOL_JUGADOR1` FOREIGN KEY (`jugador_marca`) REFERENCES `jugador` (`dni`),
  CONSTRAINT `fk_GOL_JUGADOR2` FOREIGN KEY (`jugador_asiste`) REFERENCES `jugador` (`dni`),
  CONSTRAINT `fk_GOL_PARTIDO1` FOREIGN KEY (`PARTIDO_id_partido`) REFERENCES `partido` (`id_partido`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3;
