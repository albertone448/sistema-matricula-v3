-- ============================================
-- SCRIPT COMPLETO: LIMPIAR BASE DE DATOS Y CARGAR DATOS DE PRUEBA
-- ============================================

-- PASO 1: LIMPIAR TODAS LAS TABLAS (ORDEN IMPORTANTE POR FOREIGN KEYS)
PRINT 'Iniciando limpieza de la base de datos...'

-- Eliminar datos en orden inverso a las dependencias
DELETE FROM Notas;
DELETE FROM Evaluaciones;
DELETE FROM Inscripciones;
DELETE FROM Secciones;
DELETE FROM TipoEvaluaciones;
DELETE FROM Cursos;
DELETE FROM Horarios;
DELETE FROM Usuarios;

-- Reiniciar los contadores de identidad
DBCC CHECKIDENT ('Notas', RESEED, 0);
DBCC CHECKIDENT ('Evaluaciones', RESEED, 0);
DBCC CHECKIDENT ('Inscripciones', RESEED, 0);
DBCC CHECKIDENT ('Secciones', RESEED, 0);
DBCC CHECKIDENT ('TipoEvaluaciones', RESEED, 0);
DBCC CHECKIDENT ('Cursos', RESEED, 0);
DBCC CHECKIDENT ('Horarios', RESEED, 0);
DBCC CHECKIDENT ('Usuarios', RESEED, 0);

PRINT 'Base de datos limpiada correctamente.'

-- ============================================
-- PASO 2: INSERTAR DATOS DE PRUEBA DESDE CERO
-- ============================================

PRINT 'Iniciando carga de datos de prueba...'

-- 1. USUARIOS (Profesores y Estudiantes)
PRINT 'Insertando usuarios...'
INSERT INTO Usuarios (Nombre, Apellido1, Apellido2, Identificacion, Rol, Carrera, Correo, Contrasena, Activo)
VALUES 
-- Profesores
('María', 'González', 'López', '123456789', 'Profesor', 'Ingeniería Informática', 'maria.gonzalez@universidad.edu', 'profesor123', 1),
('Carlos', 'Rodríguez', 'Pérez', '987654321', 'Profesor', 'Ingeniería Informática', 'carlos.rodriguez@universidad.edu', 'profesor123', 1),
('Ana', 'Martínez', 'Jiménez', '456789123', 'Profesor', 'Administración', 'ana.martinez@universidad.edu', 'profesor123', 1),

-- Estudiantes
('Juan', 'Pérez', 'García', '111222333', 'Estudiante', 'Ingeniería Informática', 'juan.perez@estudiante.edu', 'estudiante123', 1),
('Laura', 'Sánchez', 'Morales', '444555666', 'Estudiante', 'Ingeniería Informática', 'laura.sanchez@estudiante.edu', 'estudiante123', 1),
('Diego', 'Vargas', 'Castro', '777888999', 'Estudiante', 'Ingeniería Informática', 'diego.vargas@estudiante.edu', 'estudiante123', 1),
('Sofia', 'Herrera', 'Ramírez', '101112131', 'Estudiante', 'Administración', 'sofia.herrera@estudiante.edu', 'estudiante123', 1),
('Andrés', 'Moreno', 'Quesada', '141516171', 'Estudiante', 'Ingeniería Informática', 'andres.moreno@estudiante.edu', 'estudiante123', 1),
('Carmen', 'López', 'Solano', '181920212', 'Estudiante', 'Ingeniería Informática', 'carmen.lopez@estudiante.edu', 'estudiante123', 1),
('Roberto', 'Castro', 'Vega', '232425262', 'Estudiante', 'Administración', 'roberto.castro@estudiante.edu', 'estudiante123', 1);

-- 2. HORARIOS (Recrear los horarios básicos)
PRINT 'Insertando horarios...'
INSERT INTO Horarios (HoraInicio, HoraFin, Dia)
VALUES 
-- Lunes
('08:00', '11:20', 'Lunes'),
('13:00', '16:20', 'Lunes'),
('17:00', '20:20', 'Lunes'),
-- Martes
('08:00', '11:20', 'Martes'),
('13:00', '16:20', 'Martes'),
('17:00', '20:20', 'Martes'),
-- Miércoles
('08:00', '11:20', 'Miércoles'),
('13:00', '16:20', 'Miércoles'),
('17:00', '20:20', 'Miércoles'),
-- Jueves
('08:00', '11:20', 'Jueves'),
('13:00', '16:20', 'Jueves'),
('17:00', '20:20', 'Jueves'),
-- Viernes
('08:00', '11:20', 'Viernes'),
('13:00', '16:20', 'Viernes'),
('17:00', '20:20', 'Viernes');

-- 3. CURSOS
PRINT 'Insertando cursos...'
INSERT INTO Cursos (Nombre, Descripcion, Creditos)
VALUES 
('Programación I', 'Introducción a la programación con C#', 4),
('Base de Datos I', 'Fundamentos de bases de datos relacionales', 3),
('Matemáticas Discretas', 'Lógica y matemáticas para informática', 4),
('Administración de Empresas', 'Principios básicos de administración', 3),
('Estructuras de Datos', 'Algoritmos y estructuras de datos', 4),
('Cálculo I', 'Matemáticas aplicadas a la ingeniería', 4),
('Contabilidad General', 'Fundamentos de contabilidad', 3);

-- 4. TIPOS DE EVALUACIONES
PRINT 'Insertando tipos de evaluaciones...'
INSERT INTO TipoEvaluaciones (Nombre, Descripcion)
VALUES 
('Examen Parcial', 'Evaluación teórica y práctica parcial'),
('Examen Final', 'Evaluación final del curso'),
('Tarea', 'Asignaciones y trabajos individuales'),
('Proyecto', 'Proyecto grupal o individual'),
('Quiz', 'Evaluaciones cortas'),
('Participación', 'Participación en clase y actividades'),
('Laboratorio', 'Prácticas de laboratorio'),
('Presentación', 'Exposiciones orales');

-- 5. SECCIONES
PRINT 'Insertando secciones...'
INSERT INTO Secciones (UsuarioId, CursoId, HorarioId, Grupo, Periodo, Carrera, CuposMax)
VALUES 
-- Programación I - Profesor María González (ID: 1)
(1, 1, 1, 'Grupo 01', '2024-I', 'Ingeniería Informática', 25),
(1, 1, 4, 'Grupo 02', '2024-I', 'Ingeniería Informática', 25),

-- Base de Datos I - Profesor Carlos Rodríguez (ID: 2)  
(2, 2, 2, 'Grupo 01', '2024-I', 'Ingeniería Informática', 30),
(2, 2, 8, 'Grupo 02', '2024-I', 'Ingeniería Informática', 30),

-- Matemáticas Discretas - Profesor María González (ID: 1)
(1, 3, 5, 'Grupo 01', '2024-I', 'Ingeniería Informática', 35),

-- Administración de Empresas - Profesor Ana Martínez (ID: 3)
(3, 4, 3, 'Grupo 01', '2024-I', 'Administración', 40),

-- Estructuras de Datos - Profesor Carlos Rodríguez (ID: 2)
(2, 5, 9, 'Grupo 01', '2024-I', 'Ingeniería Informática', 25),

-- Cálculo I - Profesor María González (ID: 1)
(1, 6, 6, 'Grupo 01', '2024-I', 'Ingeniería Informática', 30);

-- 6. INSCRIPCIONES
PRINT 'Insertando inscripciones...'
INSERT INTO Inscripciones (UsuarioId, SeccionId)
VALUES 
-- Juan Pérez (ID: 4) - Ingeniería Informática
(4, 1), -- Programación I - Grupo 01
(4, 3), -- Base de Datos I - Grupo 01
(4, 5), -- Matemáticas Discretas - Grupo 01

-- Laura Sánchez (ID: 5) - Ingeniería Informática
(5, 1), -- Programación I - Grupo 01
(5, 4), -- Base de Datos I - Grupo 02
(5, 5), -- Matemáticas Discretas - Grupo 01
(5, 7), -- Estructuras de Datos - Grupo 01

-- Diego Vargas (ID: 6) - Ingeniería Informática
(6, 2), -- Programación I - Grupo 02
(6, 3), -- Base de Datos I - Grupo 01
(6, 8), -- Cálculo I - Grupo 01

-- Sofia Herrera (ID: 7) - Administración
(7, 6), -- Administración de Empresas - Grupo 01

-- Andrés Moreno (ID: 8) - Ingeniería Informática
(8, 1), -- Programación I - Grupo 01
(8, 4), -- Base de Datos I - Grupo 02
(8, 7), -- Estructuras de Datos - Grupo 01

-- Carmen López (ID: 9) - Ingeniería Informática
(9, 2), -- Programación I - Grupo 02
(9, 3), -- Base de Datos I - Grupo 01

-- Roberto Castro (ID: 10) - Administración
(10, 6); -- Administración de Empresas - Grupo 01

-- 7. EVALUACIONES POR SECCIÓN
PRINT 'Insertando evaluaciones...'
INSERT INTO Evaluaciones (SeccionId, TipEvaluacionId, Porcentaje)
VALUES 
-- Programación I - Grupo 01 (SeccionId: 1)
(1, 1, 25.00), -- Examen Parcial - 25%
(1, 2, 35.00), -- Examen Final - 35%
(1, 3, 20.00), -- Tareas - 20%
(1, 4, 20.00), -- Proyecto - 20%

-- Programación I - Grupo 02 (SeccionId: 2)
(2, 1, 30.00), -- Examen Parcial - 30%
(2, 2, 40.00), -- Examen Final - 40%
(2, 3, 15.00), -- Tareas - 15%
(2, 4, 15.00), -- Proyecto - 15%

-- Base de Datos I - Grupo 01 (SeccionId: 3)
(3, 1, 20.00), -- Examen Parcial - 20%
(3, 2, 30.00), -- Examen Final - 30%
(3, 3, 25.00), -- Tareas - 25%
(3, 4, 25.00), -- Proyecto - 25%

-- Base de Datos I - Grupo 02 (SeccionId: 4)
(4, 1, 25.00), -- Examen Parcial - 25%
(4, 2, 35.00), -- Examen Final - 35%
(4, 5, 15.00), -- Quiz - 15%
(4, 3, 25.00), -- Tareas - 25%

-- Matemáticas Discretas - Grupo 01 (SeccionId: 5)
(5, 1, 30.00), -- Examen Parcial - 30%
(5, 2, 40.00), -- Examen Final - 40%
(5, 5, 20.00), -- Quiz - 20%
(5, 6, 10.00), -- Participación - 10%

-- Administración de Empresas - Grupo 01 (SeccionId: 6)
(6, 1, 25.00), -- Examen Parcial - 25%
(6, 2, 35.00), -- Examen Final - 35%
(6, 3, 20.00), -- Tareas - 20%
(6, 6, 20.00), -- Participación - 20%

-- Estructuras de Datos - Grupo 01 (SeccionId: 7)
(7, 1, 30.00), -- Examen Parcial - 30%
(7, 2, 40.00), -- Examen Final - 40%
(7, 7, 20.00), -- Laboratorio - 20%
(7, 4, 10.00), -- Proyecto - 10%

-- Cálculo I - Grupo 01 (SeccionId: 8)
(8, 1, 35.00), -- Examen Parcial - 35%
(8, 2, 45.00), -- Examen Final - 45%
(8, 3, 20.00); -- Tareas - 20%

-- 8. NOTAS DE EJEMPLO
PRINT 'Insertando notas...'
INSERT INTO Notas (EvaluacionId, InscripcionId, Total)
VALUES 
-- Notas para Juan Pérez (InscripcionId: 1, 2, 3)
-- Programación I - Grupo 01 (Inscripción 1)
(1, 1, 85.00), -- Examen Parcial
(2, 1, 78.00), -- Examen Final
(3, 1, 92.00), -- Tareas
(4, 1, 88.00), -- Proyecto

-- Base de Datos I - Grupo 01 (Inscripción 2)
(5, 2, 82.00), -- Examen Parcial
(6, 2, 75.00), -- Examen Final
(7, 2, 90.00), -- Tareas
(8, 2, 85.00), -- Proyecto

-- Matemáticas Discretas - Grupo 01 (Inscripción 3)
(9, 3, 70.00), -- Examen Parcial
(10, 3, 68.00), -- Examen Final
(11, 3, 85.00), -- Quiz
(12, 3, 80.00), -- Participación

-- Notas para Laura Sánchez (InscripcionId: 4, 5, 6, 7)
-- Programación I - Grupo 01 (Inscripción 4)
(1, 4, 90.00), -- Examen Parcial
(2, 4, 85.00), -- Examen Final
(3, 4, 95.00), -- Tareas
(4, 4, 92.00), -- Proyecto

-- Base de Datos I - Grupo 02 (Inscripción 5)
(13, 5, 88.00), -- Examen Parcial
(14, 5, 82.00), -- Examen Final
(15, 5, 90.00), -- Quiz
(16, 5, 87.00), -- Tareas

-- Matemáticas Discretas - Grupo 01 (Inscripción 6)
(9, 6, 75.00), -- Examen Parcial
(10, 6, 72.00), -- Examen Final
(11, 6, 80.00), -- Quiz
(12, 6, 85.00), -- Participación

-- Estructuras de Datos - Grupo 01 (Inscripción 7)
(17, 7, 80.00), -- Examen Parcial
(18, 7, 85.00), -- Examen Final
(19, 7, 90.00), -- Laboratorio

-- Notas para Diego Vargas (InscripcionId: 8, 9, 10)
-- Programación I - Grupo 02 (Inscripción 8)
(21, 8, 78.00), -- Examen Parcial
(22, 8, 80.00), -- Examen Final
(23, 8, 85.00), -- Tareas
(24, 8, 82.00), -- Proyecto

-- Base de Datos I - Grupo 01 (Inscripción 9)
(5, 9, 80.00), -- Examen Parcial
(7, 9, 88.00), -- Tareas
(8, 9, 90.00), -- Proyecto

-- Cálculo I - Grupo 01 (Inscripción 10)
(25, 10, 65.00), -- Examen Parcial
(26, 10, 70.00), -- Examen Final
(27, 10, 85.00), -- Tareas

-- Notas para Sofia Herrera (InscripcionId: 11)
-- Administración de Empresas - Grupo 01
(28, 11, 85.00), -- Examen Parcial
(29, 11, 87.00), -- Examen Final
(30, 11, 90.00), -- Tareas
(31, 11, 88.00), -- Participación

-- Notas para Andrés Moreno (InscripcionId: 12, 13, 14)
-- Programación I - Grupo 01 (Inscripción 12)
(1, 12, 72.00), -- Examen Parcial
(3, 12, 80.00), -- Tareas
(4, 12, 75.00), -- Proyecto

-- Base de Datos I - Grupo 02 (Inscripción 13)
(13, 13, 75.00), -- Examen Parcial
(15, 13, 82.00), -- Quiz

-- Estructuras de Datos - Grupo 01 (Inscripción 14)
(17, 14, 70.00), -- Examen Parcial
(19, 14, 85.00), -- Laboratorio

-- Notas para Carmen López (InscripcionId: 15, 16)
-- Programación I - Grupo 02 (Inscripción 15)
(21, 15, 88.00), -- Examen Parcial
(22, 15, 85.00), -- Examen Final
(23, 15, 92.00), -- Tareas

-- Base de Datos I - Grupo 01 (Inscripción 16)
(5, 16, 90.00), -- Examen Parcial
(6, 16, 88.00), -- Examen Final
(7, 16, 95.00), -- Tareas

-- Notas para Roberto Castro (InscripcionId: 17)
-- Administración de Empresas - Grupo 01
(28, 17, 78.00), -- Examen Parcial
(30, 17, 82.00), -- Tareas
(31, 17, 85.00); -- Participación

-- ============================================
-- PASO 3: VERIFICACIÓN DE DATOS CARGADOS
-- ============================================

PRINT 'Verificando datos cargados...'

-- Contar registros en cada tabla
SELECT 'Usuarios' as Tabla, COUNT(*) as Total FROM Usuarios
UNION ALL
SELECT 'Horarios', COUNT(*) FROM Horarios
UNION ALL
SELECT 'Cursos', COUNT(*) FROM Cursos
UNION ALL
SELECT 'TipoEvaluaciones', COUNT(*) FROM TipoEvaluaciones
UNION ALL
SELECT 'Secciones', COUNT(*) FROM Secciones
UNION ALL
SELECT 'Inscripciones', COUNT(*) FROM Inscripciones
UNION ALL
SELECT 'Evaluaciones', COUNT(*) FROM Evaluaciones
UNION ALL
SELECT 'Notas', COUNT(*) FROM Notas;

-- ============================================
-- CONSULTAS DE VERIFICACIÓN ÚTILES
-- ============================================

PRINT 'Datos cargados exitosamente!'
PRINT 'Puedes usar las siguientes consultas para verificar:'

/*
-- Ver todos los estudiantes y sus inscripciones
SELECT 
    CONCAT(u.Nombre, ' ', u.Apellido1, ' ', u.Apellido2) AS Estudiante,
    c.Nombre AS Curso,
    s.Grupo,
    s.Periodo
FROM Inscripciones i
INNER JOIN Usuarios u ON i.UsuarioId = u.UsuarioId
INNER JOIN Secciones s ON i.SeccionId = s.SeccionId
INNER JOIN Cursos c ON s.CursoId = c.CursoId
WHERE u.Rol = 'Estudiante'
ORDER BY u.Nombre, c.Nombre;

-- Ver todas las notas con información completa
SELECT 
    CONCAT(u.Nombre, ' ', u.Apellido1) AS Estudiante,
    c.Nombre AS Curso,
    s.Grupo,
    te.Nombre AS TipoEvaluacion,
    n.Total AS Nota,
    e.Porcentaje
FROM Notas n
INNER JOIN Inscripciones i ON n.InscripcionId = i.InscripcionId
INNER JOIN Usuarios u ON i.UsuarioId = u.UsuarioId
INNER JOIN Evaluaciones e ON n.EvaluacionId = e.EvaluacionId
INNER JOIN TipoEvaluaciones te ON e.TipEvaluacionId = te.TipEvaluacionId
INNER JOIN Secciones s ON e.SeccionId = s.SeccionId
INNER JOIN Cursos c ON s.CursoId = c.CursoId
ORDER BY u.Nombre, c.Nombre, te.Nombre;

-- IDs útiles para las pruebas de API:
-- Estudiantes: 4-10
-- Secciones: 1-8
-- Inscripciones: 1-17
-- Evaluaciones: 1-31
-- Notas: 1-50+
*/

PRINT '============================================'
PRINT 'BASE DE DATOS LISTA PARA PRUEBAS'
PRINT '============================================'
PRINT 'Estudiantes disponibles: Juan Pérez (ID:4), Laura Sánchez (ID:5), Diego Vargas (ID:6), etc.'
PRINT 'Secciones con notas disponibles: 1-8'
PRINT 'Inscripciones con notas: 1-17'
PRINT '============================================'