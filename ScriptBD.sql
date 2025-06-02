CREATE DATABASE SistemaCursos;
GO

-- Usar la base de datos recién creada
USE SistemaCursos;
GO

CREATE TABLE Usuarios (
    UsuarioId INT IDENTITY (1,1) PRIMARY KEY,
    Nombre NVARCHAR(100) NOT NULL,
    Apellido1 NVARCHAR(100) NOT NULL,
    Apellido2 NVARCHAR(100) NOT NULL,
    Identificacion NVARCHAR(50) UNIQUE NOT NULL,
    Rol NVARCHAR(50) NOT NULL,
    Carrera NVARCHAR(100) NOT NULL,
    Correo NVARCHAR(100) UNIQUE NOT NULL,
    Contrasena NVARCHAR(100) NOT NULL,
    NumeroVerificacion INT CHECK (NumeroVerificacion BETWEEN 100000 AND 999999),
	Activo BIT NOT NULL DEFAULT 0,
	Created_at DATETIME DEFAULT GETDATE(),
    Updated_at DATETIME
);


CREATE TABLE Cursos (
    CursoId INt IDENTITY (1,1) PRIMARY KEY,
    Codigo NVARCHAR(10) UNIQUE NOT NULL,
    Nombre NVARCHAR(100) NOT NULL,
    Descripcion NVARCHAR(255) NOT NULL,
    Creditos INT NOT NULL,
	Created_at DATETIME DEFAULT GETDATE(),
    Updated_at DATETIME
);


CREATE TABLE Horarios (
    HorarioId INT IDENTITY (1,1) PRIMARY KEY,
    HoraInicio TIME NOT NULL,
    HoraFin TIME NOT NULL,
    Dia NVARCHAR(20) NOT NULL,
	Created_at DATETIME DEFAULT GETDATE(),
    Updated_at DATETIME
);


CREATE TABLE Secciones (
    SeccionId INT IDENTITY (1,1) PRIMARY KEY,
    UsuarioId INT FOREIGN KEY REFERENCES Usuarios(UsuarioId),
    CursoId INT FOREIGN KEY REFERENCES Cursos(CursoId),
    HorarioId INT FOREIGN KEY REFERENCES Horarios(HorarioId),
    Grupo NVARCHAR(20) NOT NULL,
    Periodo NVARCHAR(50) NOT NULL,
	Carrera NVARCHAR(100) DEFAULT 'Todas',
    CuposMax INT DEFAULT 20,
	Created_at DATETIME DEFAULT GETDATE(),
    Updated_at DATETIME
);


CREATE TABLE Inscripciones (
    InscripcionId INT IDENTITY (1,1) PRIMARY KEY,
    UsuarioId INT FOREIGN KEY REFERENCES Usuarios(UsuarioId),
    SeccionId INT FOREIGN KEY REFERENCES Secciones(SeccionId),
	Created_at DATETIME DEFAULT GETDATE(),
    Updated_at DATETIME
);


CREATE TABLE TipoEvaluaciones (
    TipEvaluacionId INT IDENTITY (1,1) PRIMARY KEY,
    Nombre NVARCHAR(100) NOT NULL,
    Descripcion NVARCHAR(255) NOT NULL,
	Created_at DATETIME DEFAULT GETDATE(),
    Updated_at DATETIME
);


CREATE TABLE Evaluaciones (
    EvaluacionId INT IDENTITY (1,1) PRIMARY KEY,
    SeccionId INT FOREIGN KEY REFERENCES Secciones(SeccionId),
    TipEvaluacionId INT FOREIGN KEY REFERENCES TipoEvaluaciones(TipEvaluacionId),
    Porcentaje DECIMAL(5,2) NOT NULL,
	Created_at DATETIME DEFAULT GETDATE(),
    Updated_at DATETIME
);


CREATE TABLE Notas (
    NotaId INT IDENTITY (1,1) PRIMARY KEY,
    EvaluacionId INT FOREIGN KEY REFERENCES Evaluaciones(EvaluacionId),
    InscripcionId INT FOREIGN KEY REFERENCES Inscripciones(InscripcionId),
    Total DECIMAL(5,2) NOT NULL,
	Created_at DATETIME DEFAULT GETDATE(),
    Updated_at DATETIME
);

GO
------------------------------------------------------------------------------------------------------------------------------------------
-- SP Usuarios--
	--Login MODIFICAR ***
	--Obtener por rol y por carrera
	--Insertar usuarios (Funci n administradores)
	--Modificar usuarios (Funci n administradores)
	--Verificar usuarios MODIFICAR***
	--Cambiar contrase a MODIFICAR***
	--Obtener todos
	--Obtener por Id
------------------------------------------------------------------------------------------------------------------------------------------

-- SP para login de usuarios con manejo de errores específicos y verificación de estado activo
CREATE OR ALTER PROCEDURE sp_LoginUsuario
    @Correo NVARCHAR(100),
    @Contrasena NVARCHAR(100)
AS
BEGIN
    DECLARE @UsuarioId INT
    DECLARE @Estado INT = 0
    DECLARE @Mensaje NVARCHAR(100) = ''

    -- Verificar si el correo existe
    IF NOT EXISTS (SELECT 1 FROM Usuarios WHERE Correo = @Correo)
    BEGIN
        SET @Estado = -1
        SET @Mensaje = 'El correo electrónico no está registrado'
        SELECT @Estado AS Estado, @Mensaje AS Mensaje
        RETURN
    END

    -- Verificar si la contraseña es correcta
    IF NOT EXISTS (SELECT 1 FROM Usuarios WHERE Correo = @Correo AND Contrasena = @Contrasena)
    BEGIN
        SET @Estado = -2
        SET @Mensaje = 'Contraseña incorrecta'
        SELECT @Estado AS Estado, @Mensaje AS Mensaje
        RETURN
    END

    -- Verificar si el usuario está pendiente de verificación (tiene número de verificación)
    IF EXISTS (SELECT 1 FROM Usuarios WHERE Correo = @Correo AND Contrasena = @Contrasena AND NumeroVerificacion IS NOT NULL)
    BEGIN
        SET @Estado = -3
        SET @Mensaje = 'Usuario pendiente de verificación'
        SELECT @Estado AS Estado, @Mensaje AS Mensaje, 
               UsuarioId, NumeroVerificacion
        FROM Usuarios
        WHERE Correo = @Correo AND Contrasena = @Contrasena
        RETURN
    END

    -- Verificar si el usuario está activo
    IF EXISTS (SELECT 1 FROM Usuarios WHERE Correo = @Correo AND Contrasena = @Contrasena AND Activo = 0)
    BEGIN
        SET @Estado = -4
        SET @Mensaje = 'Usuario inactivo, contacte al administrador'
        SELECT @Estado AS Estado, @Mensaje AS Mensaje
        RETURN
    END

    -- Login exitoso
    SET @Mensaje = 'Login exitoso'
    
    -- Retornar información del usuario y estado
    SELECT 
        1 AS Estado, 
        @Mensaje AS Mensaje,
        UsuarioId, 
        Nombre, 
        Apellido1, 
        Apellido2, 
        Identificacion, 
        Rol, 
        Carrera, 
        Correo
    FROM Usuarios
    WHERE Correo = @Correo AND Contrasena = @Contrasena;
END;
GO

-- SP para obtener usuarios por rol y carrera
CREATE OR ALTER PROCEDURE sp_GetUsuariosByRolYCarrera
    @Rol NVARCHAR(50),
    @Carrera NVARCHAR(100)
AS
BEGIN
    SELECT UsuarioId, Nombre, Apellido1, Apellido2, Identificacion, Rol, Carrera, Correo, NumeroVerificacion, Activo
    FROM Usuarios
    WHERE Rol = @Rol AND Carrera = @Carrera;
END;
GO

-- SP para insertar usuarios (funci n de administradores)
CREATE OR ALTER PROCEDURE sp_CreateUsuario
    @Nombre NVARCHAR(100),
    @Apellido1 NVARCHAR(100),
    @Apellido2 NVARCHAR(100),
    @Identificacion NVARCHAR(50),
    @Rol NVARCHAR(50),
    @Carrera NVARCHAR(100),
    @Correo NVARCHAR(100),
    @Contrasena NVARCHAR(100),
    @NumeroVerificacion NVARCHAR(10) = NULL
AS
BEGIN
    INSERT INTO Usuarios (Nombre, Apellido1, Apellido2, Identificacion, Rol, Carrera, Correo, Contrasena, NumeroVerificacion)
    VALUES (@Nombre, @Apellido1, @Apellido2, @Identificacion, @Rol, @Carrera, @Correo, @Contrasena, @NumeroVerificacion);
    
    SELECT SCOPE_IDENTITY() AS UsuarioId;
END;
GO

-- SP para modificar usuarios (funci n de administradores)
CREATE OR ALTER PROCEDURE sp_UpdateUsuario
    @UsuarioId INT,
    @Nombre NVARCHAR(100),
    @Apellido1 NVARCHAR(100),
    @Apellido2 NVARCHAR(100),
    @Identificacion NVARCHAR(50),
    @Rol NVARCHAR(50),
    @Carrera NVARCHAR(100),
    @Correo NVARCHAR(100),
    @NumeroVerificacion NVARCHAR(10) = NULL
AS
BEGIN
    UPDATE Usuarios
    SET Nombre = @Nombre,
        Apellido1 = @Apellido1,
        Apellido2 = @Apellido2,
        Identificacion = @Identificacion,
        Rol = @Rol,
        Carrera = @Carrera,
        Correo = @Correo,
        NumeroVerificacion = @NumeroVerificacion,
		Updated_at = GETDATE()
    WHERE UsuarioId = @UsuarioId;
END;
GO

-- SP para verificar usuarios y activarlos
CREATE OR ALTER PROCEDURE [dbo].[sp_VerificarUsuario]
    @UsuarioId INT,
    @NumeroVerificacion INT
AS
BEGIN
    DECLARE @NumVerificacionActual INT;
    DECLARE @Estado INT = 0;
    DECLARE @Mensaje NVARCHAR(100) = '';
    DECLARE @NuevaContrasena NVARCHAR(12) = '';
    
    -- Verificar si el usuario existe
    IF NOT EXISTS (SELECT 1 FROM Usuarios WHERE UsuarioId = @UsuarioId)
    BEGIN
        SET @Estado = -1
        SET @Mensaje = 'Usuario no encontrado'
        SELECT @Estado AS Estado, @Mensaje AS Mensaje
        RETURN
    END
    
    -- Obtener el número de verificación actual
    SELECT @NumVerificacionActual = NumeroVerificacion
    FROM Usuarios
    WHERE UsuarioId = @UsuarioId;
    
    -- Verificar si el usuario ya está verificado
    IF @NumVerificacionActual IS NULL
    BEGIN
        SET @Estado = -2
        SET @Mensaje = 'El usuario ya ha sido verificado'
        SELECT @Estado AS Estado, @Mensaje AS Mensaje
        RETURN
    END
    
    -- Verificar si el código es correcto
    IF @NumVerificacionActual = @NumeroVerificacion
    BEGIN
        -- Generar contraseña aleatoria de 8 caracteres (letras y números)
        DECLARE @Caracteres NVARCHAR(62) = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789'
        DECLARE @Longitud INT = 8
        DECLARE @i INT = 1
        
        -- Generar contraseña caracter por caracter
        WHILE @i <= @Longitud
        BEGIN
            DECLARE @Posicion INT = ABS(CHECKSUM(NEWID())) % LEN(@Caracteres) + 1
            SET @NuevaContrasena = @NuevaContrasena + SUBSTRING(@Caracteres, @Posicion, 1)
            SET @i = @i + 1
        END
        
        -- Activar el usuario, eliminar el código de verificación y asignar nueva contraseña
        UPDATE Usuarios
        SET NumeroVerificacion = NULL,  -- Se elimina el código una vez verificado
            Activo = 1,  -- Se activa el usuario
            Contrasena = @NuevaContrasena,  -- Asignar nueva contraseña generada
            Updated_at = GETDATE()
        WHERE UsuarioId = @UsuarioId;
        
        SET @Estado = 1
        SET @Mensaje = 'Usuario verificado correctamente. Nueva contraseña generada.'
        
        -- Retornar estado, mensaje y la nueva contraseña
        SELECT @Estado AS Estado, @Mensaje AS Mensaje, @NuevaContrasena AS NuevaContrasena
    END
    ELSE
    BEGIN
        SET @Estado = -3
        SET @Mensaje = 'Código de verificación incorrecto'
        SELECT @Estado AS Estado, @Mensaje AS Mensaje
    END
END;
GO
-- SP para cambiar contrase a
CREATE OR ALTER PROCEDURE sp_CambiarContrasena
    @UsuarioId INT,
    @ContrasenaActual NVARCHAR(100),
    @ContrasenaNueva NVARCHAR(100)
AS
BEGIN
    DECLARE @ContrasenaBD NVARCHAR(100);
    DECLARE @Estado INT = 0;
    DECLARE @Mensaje NVARCHAR(100) = '';
    DECLARE @Activo BIT;
    DECLARE @NumeroVerificacion INT;
    
    -- Verificar si el usuario existe
    IF NOT EXISTS (SELECT 1 FROM Usuarios WHERE UsuarioId = @UsuarioId)
    BEGIN
        SET @Estado = -1
        SET @Mensaje = 'Usuario no encontrado'
        SELECT @Estado AS Estado, @Mensaje AS Mensaje
        RETURN
    END
    
    -- Obtener la contraseña actual y el estado del usuario
    SELECT 
        @ContrasenaBD = Contrasena,
        @Activo = Activo,
        @NumeroVerificacion = NumeroVerificacion
    FROM Usuarios
    WHERE UsuarioId = @UsuarioId;
    
    -- Verificar si el usuario está verificado
    IF @NumeroVerificacion IS NOT NULL
    BEGIN
        SET @Estado = -2
        SET @Mensaje = 'Usuario no verificado, debe verificar su cuenta primero'
        SELECT @Estado AS Estado, @Mensaje AS Mensaje
        RETURN
    END
    
    -- Verificar si el usuario está activo
    IF @Activo = 0
    BEGIN
        SET @Estado = -3
        SET @Mensaje = 'Usuario inactivo, contacte al administrador'
        SELECT @Estado AS Estado, @Mensaje AS Mensaje
        RETURN
    END
    
    -- Verificar si la contraseña actual es correcta
    IF @ContrasenaBD <> @ContrasenaActual
    BEGIN
        SET @Estado = -4
        SET @Mensaje = 'Contraseña actual incorrecta'
        SELECT @Estado AS Estado, @Mensaje AS Mensaje
        RETURN
    END
    
    -- Cambiar la contraseña
    UPDATE Usuarios
    SET Contrasena = @ContrasenaNueva,
        Updated_at = GETDATE()
    WHERE UsuarioId = @UsuarioId;
    
    SET @Estado = 1
    SET @Mensaje = 'Contraseña actualizada correctamente'
    SELECT @Estado AS Estado, @Mensaje AS Mensaje
END;
GO
--SP para obtener todos los usuarios
CREATE OR ALTER PROCEDURE sp_GetTodosLosUsuarios
AS
BEGIN
    SELECT UsuarioId, Nombre, Apellido1, Apellido2, Identificacion, Rol, Carrera, Correo, NumeroVerificacion, Activo
    FROM Usuarios;
END;
GO

--SP para obtener usuario por id
CREATE OR ALTER PROCEDURE sp_GetUsuarioPorId
    @UsuarioId INT
AS
BEGIN
    SELECT UsuarioId, Nombre, Apellido1, Apellido2, Identificacion, Rol, Carrera, Correo, NumeroVerificacion, Activo
    FROM Usuarios
    WHERE UsuarioId = @UsuarioId;
END;
GO


------------------------------------------------------------------------------------------------------------------------------------------
--SP  para horarios
	--	-Obtener todos los horarios
	--NOTA: Las opciones de horarios estar n establecidas por default en la base de datos
-------------------------------------------------------------------------------------------------------------------------------------------

-- SP para obtener todos los horarios
CREATE OR ALTER PROCEDURE sp_GetAllHorarios
AS
BEGIN
    SELECT * FROM Horarios
    ORDER BY Dia, HoraInicio;
END;
GO

--Horarios disponibles
INSERT INTO Horarios (HoraInicio, HoraFin, Dia)
VALUES 
--Lunes
('08:00', '11:20', 'Lunes'),
('13:00', '16:20', 'Lunes'),
('17:00', '20:20', 'Lunes'),
--Martes
('08:00', '11:20', 'Martes'),
('13:00', '16:20', 'Martes'),
('17:00', '20:20', 'Martes'),
--Mi rcoles
('08:00', '11:20', 'Mi rcoles'),
('13:00', '16:20', 'Mi rcoles'),
('17:00', '20:20', 'Mi rcoles'),
-- Jueves
('08:00', '11:20', 'Jueves'),
('13:00', '16:20', 'Jueves'),
('17:00', '20:20', 'Jueves'),
-- Viernes
('08:00', '11:20', 'Viernes'),
('13:00', '16:20', 'Viernes'),
('17:00', '20:20', 'Viernes')
GO
-------------------------------------------------------------------------------------------------------------------------------------------------
--SP para cursos
	--Obtener todos los cursos
	--Obtener curso por Id
	--Crear curso
	--Eliminar curso
	--Editar curso
-------------------------------------------------------------------------------------------------------------------------------------------------

-- SP para obtener todos los cursos
CREATE OR ALTER PROCEDURE sp_GetAllCursos
AS
BEGIN
    SELECT * FROM Cursos
    ORDER BY Nombre;
END;
GO

-- SP para crear un nuevo curso
CREATE OR ALTER   PROCEDURE [dbo].[sp_CreateCurso]
    @Nombre NVARCHAR(100),
    @Codigo NVARCHAR(10),
    @Descripcion NVARCHAR(255),
    @Creditos INT
AS
BEGIN
    INSERT INTO Cursos (Nombre, Descripcion, Creditos,Codigo)
    VALUES (@Nombre, @Descripcion, @Creditos, @Codigo);
    
    SELECT SCOPE_IDENTITY() AS CursoId;
END;
GO

-- SP para obtener un curso espec fico por ID
CREATE OR ALTER PROCEDURE sp_GetCursoById
    @CursoId INT
AS
BEGIN
    SELECT * FROM Cursos
    WHERE CursoId = @CursoId;
END;
GO

-- SP para eliminar un curso
CREATE OR ALTER PROCEDURE sp_DeleteCurso
    @CursoId INT
AS
BEGIN
    -- Verificar si existen secciones asociadas al curso
    IF NOT EXISTS (SELECT 1 FROM Secciones WHERE CursoId = @CursoId)
    BEGIN
        -- Si no hay secciones, eliminar el curso
        DELETE FROM Cursos WHERE CursoId = @CursoId;
        SELECT 1 AS Eliminado;
    END
    ELSE
    BEGIN
        -- Si hay secciones, no se puede eliminar el curso
        SELECT 0 AS Eliminado;
    END
END;
GO

-- SP para editar un curso
CREATE OR ALTER   PROCEDURE [dbo].[sp_UpdateCurso]
    @CursoId INT,
    @Nombre NVARCHAR(100),
    @Codigo NVARCHAR(10),
    @Descripcion NVARCHAR(255) = NULL,
    @Creditos INT
AS
BEGIN
    UPDATE Cursos
    SET Nombre = @Nombre,
        Descripcion = @Descripcion,
        Creditos = @Creditos,
        Codigo = @Codigo,
		Updated_at = GETDATE()
    WHERE CursoId = @CursoId;
END;
GO

---------------------------------------------------------------------------------------------------------------------------------------------------
--Secciones
	--Listar todas las secciones
	--Obtener la secci n por carrera
	--Obtener seccion por Id
	--Crear secciones
	--Eliminar secciones
	--Editar secciones
---------------------------------------------------------------------------------------------------------------------------------------------------

--SP para obtener todas las secciones
CREATE OR ALTER PROCEDURE sp_GetAllSecciones
AS
BEGIN
	SELECT * FROM Secciones
END;
GO

--SP  para obtener secciones por carrera
CREATE OR ALTER PROCEDURE sp_GetSeccionesbyCarrera
@CARRERA nvarchar(100) -- El tipo que sea
AS
BEGIN
	SELECT * FROM Secciones where Carrera = @CARRERA
END;
GO

-- SP para obtener una secci n espec fica por ID
CREATE OR ALTER PROCEDURE sp_GetSeccionById
    @SeccionId INT
AS
BEGIN
    SELECT * FROM Secciones
    WHERE SeccionId = @SeccionId;
END;
GO

--SP para crear una secci n
Create or alter procedure  sp_CreateSeccion
 @UsuarioID int, 
 @CursoID int,  
 @HorarioID int,
 @Grupo nvarchar(20),  -- El tipo que sea
 @Periodo nvarchar(50),  -- El tipo que sea
 @CuposMax int,
 @Carrera nvarchar(100)  -- El tipo que sea
as
begin
	Insert into Secciones (UsuarioId,CursoId,HorarioId,Grupo,Periodo,CuposMax,Carrera)
	values (@UsuarioID,@CursoID,@HorarioID,@Grupo,@Periodo,@CuposMax,@Carrera)
end;
go

--SP para eliminar una seccion
CREATE OR ALTER PROCEDURE sp_DeleteSeccion
    @SeccionID INT
AS 
BEGIN
    -- Verificar si existen inscripciones para la seccion
    IF NOT EXISTS (SELECT 1 FROM Inscripciones WHERE SeccionId = @SeccionID)
    BEGIN
        -- Si no hay inscripciones, eliminar todas las evaluaciones asociadas con la seccion
        DELETE FROM Evaluaciones WHERE SeccionId = @SeccionID;

        -- Ahora, eliminar la secci n
        DELETE FROM Secciones WHERE SeccionId = @SeccionID;
        PRINT 'Seccion y evaluaciones eliminadas exitosamente.';
    END
    ELSE
    BEGIN
        -- Si hay inscripciones, no se puede eliminar la seccion ni las evaluaciones
        PRINT 'No se puede eliminar la seccion. Existen inscripciones relacionadas.';
    END
END;
GO

--SP para actualizar una seccion
CREATE OR ALTER PROCEDURE sp_UpdateSeccion
    @SECCIONID INT,
    @USUARIOID INT,
    @CURSOID INT,
    @HORARIOID INT,
    @GRUPO NVARCHAR(20), -- El tipo que sea
    @PERIODO NVARCHAR(50),  -- El tipo que sea
    @CARRERA NVARCHAR(100),  -- El tipo que sea
    @CUPOSMAX INT
AS 
BEGIN
    UPDATE Secciones
    SET 
        UsuarioId = @USUARIOID,
        CursoId = @CURSOID,
        HorarioId = @HORARIOID,
        Grupo = @GRUPO,
        Periodo = @PERIODO,
        Carrera = @CARRERA,
        CuposMax = @CUPOSMAX,
		Updated_at = GETDATE()
    WHERE SeccionId = @SECCIONID;
END;
GO

---------------------------------------------------------------------------------------------------------------------------------------------------
--Inscripciones
	--Crear inscripci n
	--Eliminar inscripci n
	--Listar inscripci n por usuarios
	--Listar usuarios por seccion
---------------------------------------------------------------------------------------------------------------------------------------------------

--SP para crear inscripcion
CREATE OR ALTER PROCEDURE sp_CrearInscripcion
    @UsuarioId INT,
    @SeccionId INT
AS
BEGIN
    IF EXISTS (
        SELECT 1 FROM Inscripciones
        WHERE UsuarioId = @UsuarioId AND SeccionId = @SeccionId
    )
    BEGIN
        RAISERROR('El usuario ya est  inscrito en esta secci n.', 16, 1);
        RETURN;
    END;

    INSERT INTO Inscripciones (UsuarioId, SeccionId, Created_at)
    VALUES (@UsuarioId, @SeccionId, GETDATE());
END;
GO


--SP para eliminar inscripcion
CREATE OR ALTER PROCEDURE sp_EliminarInscripcion
    @InscripcionId INT
AS
BEGIN
    DELETE FROM Inscripciones
    WHERE InscripcionId = @InscripcionId;
END;
GO

--SP para listar las inscripciones por usuario
CREATE OR ALTER PROCEDURE sp_ListarInscripcionesPorUsuario
    @UsuarioId INT
AS
BEGIN
    SELECT i.InscripcionId, i.UsuarioId, i.SeccionId, i.Created_at, i.Updated_at,
           s.Grupo, s.Periodo, s.Carrera
    FROM Inscripciones i
    INNER JOIN Secciones s ON i.SeccionId = s.SeccionId
    WHERE i.UsuarioId = @UsuarioId;
END;
GO

--SP para listar inscripciones por seccion
CREATE OR ALTER PROCEDURE sp_ListarUsuariosPorSeccion
    @SeccionId INT
AS
BEGIN
    SELECT i.InscripcionId, i.SeccionId, i.UsuarioId, i.Created_at, i.Updated_at, u.Nombre, u.Apellido1, u.Apellido2, u.Correo
    FROM Inscripciones i
    INNER JOIN Usuarios u ON i.UsuarioId = u.UsuarioId
    WHERE i.SeccionId = @SeccionId;
END;
GO

---------------------------------------------------------------------------------------------------------------------------------------------------
--Evaluaci n
	--Insertar evaluaci n
	--Eliminar evaluaci n
	--Actualizar evaluaci n
	--Obtener evaluaciones por secci n
---------------------------------------------------------------------------------------------------------------------------------------------------

--SP para insertar una evaluacion
CREATE OR ALTER PROCEDURE sp_InsertarEvaluacion
    @SeccionId INT,
    @TipEvaluacionId INT,
    @Porcentaje DECIMAL(5,2)
AS
BEGIN
    INSERT INTO Evaluaciones (SeccionId, TipEvaluacionId, Porcentaje, Created_at)
    VALUES (@SeccionId, @TipEvaluacionId, @Porcentaje, GETDATE());
END;
GO

--SP para eliminar una evaluacion
CREATE OR ALTER PROCEDURE sp_EliminarEvaluacion
    @EvaluacionId INT
AS
BEGIN
    DELETE FROM Evaluaciones
    WHERE EvaluacionId = @EvaluacionId;
END;
GO

--SP para actualizar una evaluacion
CREATE OR ALTER PROCEDURE sp_ActualizarEvaluacion
    @EvaluacionId INT,
    @SeccionId INT,
    @TipEvaluacionId INT,
    @Porcentaje DECIMAL(5,2)
AS
BEGIN
    UPDATE Evaluaciones
    SET 
        SeccionId = @SeccionId,
        TipEvaluacionId = @TipEvaluacionId,
        Porcentaje = @Porcentaje,
        Updated_at = GETDATE()
    WHERE EvaluacionId = @EvaluacionId;
END;
GO

--SP para obtener evaluaciones por seccion
CREATE OR ALTER PROCEDURE sp_ObtenerEvaluacionesPorSeccion
    @SeccionId INT
AS
BEGIN
    SELECT e.EvaluacionId, e.SeccionId, e.TipEvaluacionId, t.Nombre AS TipoEvaluacion, e.Porcentaje,
           e.Created_at, e.Updated_at
    FROM Evaluaciones e
    INNER JOIN TipoEvaluaciones t ON e.TipEvaluacionId = t.TipEvaluacionId
    WHERE e.SeccionId = @SeccionId;
END;
GO

---------------------------------------------------------------------------------------------------------------------------------------------------
--Notas
	--Crear nota
	--Editar nota
	--Eliminar nota
	--Listar notas por seccion
	--Listar notas por inscripci n
---------------------------------------------------------------------------------------------------------------------------------------------------

--SP para crear una nota
CREATE OR ALTER PROCEDURE sp_CrearNota
    @EvaluacionId INT,
    @InscripcionId INT,
    @Total DECIMAL(5,2)
AS
BEGIN
    INSERT INTO Notas (EvaluacionId, InscripcionId, Total, Created_at)
    VALUES (@EvaluacionId, @InscripcionId, @Total, GETDATE());
END;
GO

--SP para editar una nota
CREATE OR ALTER PROCEDURE sp_EditarNota
    @NotaId INT,
    @Total DECIMAL(5,2)
AS
BEGIN
    UPDATE Notas
    SET 
        Total = @Total,
        Updated_at = GETDATE()
    WHERE NotaId = @NotaId;
END;
GO

--SP para eliminar una nota
CREATE OR ALTER PROCEDURE sp_EliminarNota
    @NotaId INT
AS
BEGIN
    DELETE FROM Notas
    WHERE NotaId = @NotaId;
END;
GO

--SP para listar las notas por inscripcion
CREATE OR ALTER PROCEDURE sp_ListarNotasPorInscripcion
    @InscripcionId INT
AS
BEGIN
    SELECT n.NotaId, n.EvaluacionId, n.Total, n.Created_at, n.Updated_at,
           e.Porcentaje
    FROM Notas n
    INNER JOIN Evaluaciones e ON n.EvaluacionId = e.EvaluacionId
    WHERE n.InscripcionId = @InscripcionId;
END;
GO

--SP listar las notas por seccion
CREATE OR ALTER PROCEDURE sp_ListarNotasPorSeccion
    @SeccionId INT
AS
BEGIN
    SELECT n.NotaId, n.Total, n.Created_at, n.Updated_at,
           e.EvaluacionId, e.Porcentaje, e.TipEvaluacionId,
           te.Nombre AS TipoEvaluacion,
           i.InscripcionId, i.UsuarioId,
           u.Nombre, u.Apellido1, u.Apellido2
    FROM Notas n
    INNER JOIN Evaluaciones e ON n.EvaluacionId = e.EvaluacionId
    INNER JOIN TipoEvaluaciones te ON e.TipEvaluacionId = te.TipEvaluacionId
    INNER JOIN Inscripciones i ON n.InscripcionId = i.InscripcionId
    INNER JOIN Usuarios u ON i.UsuarioId = u.UsuarioId
    WHERE e.SeccionId = @SeccionId;
END;
GO