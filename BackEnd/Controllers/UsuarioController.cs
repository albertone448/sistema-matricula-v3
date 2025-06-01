using BackEnd.DTO;
using BackEnd.Servicios.Interfaces;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;

namespace BackEnd.Controllers
{
    [ApiController]
    [Route("api/[controller]")]
    public class UsuarioController : ControllerBase
    {
        private readonly IUsuarioService _usuarioService;
        private readonly IJwtService _jwtService;

        public UsuarioController(IUsuarioService usuarioService, IJwtService jwtService)
        {
            _usuarioService = usuarioService;
            _jwtService = jwtService;
        }

        // GET: api/Usuario/GetTodosLosUsuarios
        [HttpGet("GetTodosLosUsuarios")]
        [Authorize(Roles = "Administrador")] // Solo administradores pueden ver todos los usuarios
        public IActionResult GetTodosLosUsuarios()
        {
            try
            {
                var usuarios = _usuarioService.GetTodosLosUsuarios();
                return Ok(usuarios);
            }
            catch (Exception ex)
            {
                return StatusCode(500, $"Error interno del servidor: {ex.Message}");
            }
        }

        // GET: api/Usuario/GetUsuarioPorId/{id}
        [HttpGet("GetUsuarioPorId/{id}")]
        [Authorize] // Cualquier usuario autenticado puede acceder
        public IActionResult GetUsuarioPorId(int id)
        {
            try
            {
                var usuario = _usuarioService.GetUsuarioPorId(id);
                if (usuario == null)
                    return NotFound($"Usuario con ID {id} no encontrado");
                return Ok(usuario);
            }
            catch (Exception ex)
            {
                return StatusCode(500, $"Error interno del servidor: {ex.Message}");
            }
        }

        // GET: api/Usuario/GetUsuariosByRolYCarrera
        [HttpGet("GetUsuariosByRolYCarrera")]
        [Authorize(Roles = "Administrador,Profesor")] // Administradores y profesores
        public IActionResult GetUsuariosByRolYCarrera([FromQuery] string rol, [FromQuery] string carrera)
        {
            try
            {
                var usuarios = _usuarioService.GetUsuariosByRolYCarrera(rol, carrera);
                return Ok(usuarios);
            }
            catch (Exception ex)
            {
                return StatusCode(500, $"Error interno del servidor: {ex.Message}");
            }
        }

        // POST: api/Usuario/AddUsuario
        [HttpPost("AddUsuario")]
        [AllowAnonymous] // Permitir registro sin autenticación
        public IActionResult AddUsuario([FromBody] CrearUsuarioDTO crearUsuarioDTO)
        {
            try
            {
                if (crearUsuarioDTO == null)
                    return BadRequest("El usuario no puede ser nulo");

                // Validar campos requeridos
                if (string.IsNullOrWhiteSpace(crearUsuarioDTO.Nombre))
                    return BadRequest("El nombre es requerido");
                if (string.IsNullOrWhiteSpace(crearUsuarioDTO.Apellido1))
                    return BadRequest("El primer apellido es requerido");
                if (string.IsNullOrWhiteSpace(crearUsuarioDTO.Apellido2))
                    return BadRequest("El segundo apellido es requerido");
                if (string.IsNullOrWhiteSpace(crearUsuarioDTO.Identificacion))
                    return BadRequest("La identificación es requerida");
                if (string.IsNullOrWhiteSpace(crearUsuarioDTO.Rol))
                    return BadRequest("El rol es requerido");

                // CAMBIO: Solo validar carrera si NO es administrador
                if (crearUsuarioDTO.Rol != "Administrador" && string.IsNullOrWhiteSpace(crearUsuarioDTO.Carrera))
                    return BadRequest("La carrera es requerida para este rol");

                if (string.IsNullOrWhiteSpace(crearUsuarioDTO.Correo))
                    return BadRequest("El correo es requerido");

                var usuarioDTO = new UsuarioDTO
                {
                    Nombre = crearUsuarioDTO.Nombre,
                    Apellido1 = crearUsuarioDTO.Apellido1,
                    Apellido2 = crearUsuarioDTO.Apellido2,
                    Identificacion = crearUsuarioDTO.Identificacion,
                    Rol = crearUsuarioDTO.Rol,
                    Carrera = crearUsuarioDTO.Rol == "Administrador" ? "N/A" : crearUsuarioDTO.Carrera,
                    Correo = crearUsuarioDTO.Correo,
                    Contrasena = crearUsuarioDTO.Contrasena
                };

                var result = _usuarioService.AddUsuario(usuarioDTO);
                if (result)
                    return Ok(new { mensaje = "Usuario agregado exitosamente. Se ha enviado un código de verificación al correo proporcionado." });
                return BadRequest("Error al agregar el usuario");
            }
            catch (Exception ex)
            {
                return StatusCode(500, $"Error interno del servidor: {ex.Message}");
            }
        }

        // PUT: api/Usuario/UpdateUsuario
        [HttpPut("UpdateUsuario")]
        [Authorize] // Usuario autenticado puede actualizar
        public IActionResult UpdateUsuario([FromBody] UsuarioDTO usuarioDTO)
        {
            try
            {
                if (usuarioDTO == null)
                    return BadRequest("El usuario no puede ser nulo");

                // Para actualización, no permitimos cambiar el número de verificación desde el API
                usuarioDTO.NumeroVerificacion = null;

                var result = _usuarioService.UpdateUsuario(usuarioDTO);
                if (result)
                    return Ok("Usuario actualizado exitosamente");
                return BadRequest("Error al actualizar el usuario");
            }
            catch (Exception ex)
            {
                return StatusCode(500, $"Error interno del servidor: {ex.Message}");
            }
        }

        // POST: api/Usuario/Login
        [HttpPost("Login")]
        [AllowAnonymous] // Permitir login sin autenticación previa
        public async Task<IActionResult> Login([FromBody] LoginResponseDTO loginRequest)
        {
            try
            {
                if (string.IsNullOrEmpty(loginRequest.Usuario.Correo) || string.IsNullOrEmpty(loginRequest.Usuario.Contrasena))
                    return BadRequest("El correo y la contraseña son requeridos");

                var (estado, mensaje, usuario) = await _usuarioService.LoginUsuario(loginRequest.Usuario.Correo, loginRequest.Usuario.Contrasena);

                var response = new LoginResponseDTO
                {
                    Estado = estado,
                    Mensaje = mensaje,
                    Usuario = usuario
                };

                // Si el login es exitoso (estado == 1), generar token JWT
                if (estado == 1 && usuario != null)
                {
                    response.Token = _jwtService.GenerateJwtToken(usuario);
                    response.TokenExpiration = DateTime.UtcNow.AddMinutes(60); // Ajustar según configuración
                }

                return Ok(response);
            }
            catch (Exception ex)
            {
                return StatusCode(500, $"Error interno del servidor: {ex.Message}");
            }
        }

        // POST: api/Usuario/VerificarUsuario
        [HttpPost("VerificarUsuario")]
        [AllowAnonymous] // Permitir verificación sin autenticación
        public async Task<IActionResult> VerificarUsuario([FromBody] VerificarUsuarioDTO verificacionRequest)
        {
            try
            {
                var (estado, mensaje) = await _usuarioService.VerificarUsuario(verificacionRequest.UsuarioId, verificacionRequest.NumeroVerificacion);

                return Ok(new { Estado = estado, Mensaje = mensaje });
            }
            catch (Exception ex)
            {
                return StatusCode(500, $"Error interno del servidor: {ex.Message}");
            }
        }

        // POST: api/Usuario/CambiarContrasena
        [HttpPost("CambiarContrasena")]
        [Authorize] // Usuario autenticado puede cambiar contraseña
        public async Task<IActionResult> CambiarContrasena([FromBody] CambiarContrasenaDTO cambioRequest)
        {
            try
            {
                if (string.IsNullOrEmpty(cambioRequest.ContrasenaActual) || string.IsNullOrEmpty(cambioRequest.ContrasenaNueva))
                    return BadRequest("Las contraseñas son requeridas");

                var (estado, mensaje) = await _usuarioService.CambiarContrasena(cambioRequest.UsuarioId, cambioRequest.ContrasenaActual, cambioRequest.ContrasenaNueva);

                return Ok(new { Estado = estado, Mensaje = mensaje });
            }
            catch (Exception ex)
            {
                return StatusCode(500, $"Error interno del servidor: {ex.Message}");
            }
        }

        // GET: api/Usuario/ValidateToken
        [HttpGet("ValidateToken")]
        [Authorize] // Endpoint para validar si el token es válido
        public IActionResult ValidateToken()
        {
            try
            {
                // Si llega hasta aquí, significa que el token es válido
                var userIdClaim = User.FindFirst(System.Security.Claims.ClaimTypes.NameIdentifier);
                if (userIdClaim != null)
                {
                    return Ok(new
                    {
                        Valid = true,
                        UserId = userIdClaim.Value,
                        Mensaje = "Token válido"
                    });
                }
                return Unauthorized(new { Valid = false, Mensaje = "Token inválido" });
            }
            catch (Exception ex)
            {
                return StatusCode(500, $"Error interno del servidor: {ex.Message}");
            }
        }
    }
}