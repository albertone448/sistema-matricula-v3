using BackEnd.DTO;
using BackEnd.Servicios.Interfaces;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;

namespace BackEnd.Controllers
{
    [ApiController]
    [Route("api/[controller]")]
    [Authorize] // Proteger todo el controlador con JWT
    public class SeccionController : ControllerBase
    {
        private readonly ISeccionService _seccionService;

        public SeccionController(ISeccionService seccionService)
        {
            _seccionService = seccionService;
        }

        // GET: api/Seccion/GetAllSecciones
        [HttpGet("GetAllSecciones")]
        [Authorize(Roles = "Administrador,Profesor")] // Solo administradores y profesores
        public IActionResult GetAllSecciones()
        {
            try
            {
                var secciones = _seccionService.GetAllSecciones();
                return Ok(secciones);
            }
            catch (Exception ex)
            {
                return StatusCode(500, $"Error interno del servidor: {ex.Message}");
            }
        }

        // GET: api/Seccion/GetSeccionById/{id}
        [HttpGet("GetSeccionById/{id}")]
        [Authorize] // Cualquier usuario autenticado
        public IActionResult GetSeccionById(int id)
        {
            try
            {
                var secciones = _seccionService.GetSeccionById(id);
                if (secciones == null)
                    return NotFound($"Sección con ID {id} no encontrada");
                return Ok(secciones);
            }
            catch (Exception ex)
            {
                return StatusCode(500, $"Error interno del servidor: {ex.Message}");
            }
        }

        // POST: api/Seccion/AddSeccion
        [HttpPost("AddSeccion")]
        [Authorize(Roles = "Administrador")] // Solo administradores pueden crear secciones
        public IActionResult AddSeccion([FromBody] SeccioneDTO seccionDTO)
        {
            try
            {
                if (seccionDTO == null)
                    return BadRequest("La sección no puede ser nula");
                var result = _seccionService.AddSeccion(seccionDTO);
                if (result)
                    return Ok("Sección agregada correctamente");
                return BadRequest("Error al agregar la sección");
            }
            catch (Exception ex)
            {
                return StatusCode(500, $"Error interno del servidor: {ex.Message}");
            }
        }

        // PUT: api/Seccion/UpdateSeccion
        [HttpPut("UpdateSeccion")]
        [Authorize(Roles = "Administrador,Profesor")] // Administradores y profesores pueden actualizar
        public IActionResult UpdateSeccion([FromBody] SeccioneDTO seccionDTO)
        {
            try
            {
                if (seccionDTO == null)
                    return BadRequest("La sección no puede ser nula");
                var result = _seccionService.UpdateSeccion(seccionDTO);
                if (result)
                    return Ok("Sección actualizada correctamente");
                return BadRequest("Error al actualizar la sección");
            }
            catch (Exception ex)
            {
                return StatusCode(500, $"Error interno del servidor: {ex.Message}");
            }
        }

        // DELETE: api/Seccion/DeleteSeccion
        [HttpDelete("DeleteSeccion")]
        [Authorize(Roles = "Administrador")] // Solo administradores pueden eliminar
        public IActionResult DeleteSeccion([FromBody] SeccioneDTO seccionDTO)
        {
            try
            {
                if (seccionDTO == null)
                    return BadRequest("La sección no puede ser nula");
                var result = _seccionService.DeleteSeccion(seccionDTO);
                if (result)
                    return Ok("Sección eliminada correctamente");
                return BadRequest("Error al eliminar la sección");
            }
            catch (Exception ex)
            {
                return StatusCode(500, $"Error interno del servidor: {ex.Message}");
            }
        }

        // GET: api/Seccion/GetSeccionesbyCarrera/{carrera}
        [HttpGet("GetSeccionesbyCarrera/{carrera}")]
        [Authorize] // Cualquier usuario autenticado
        public IActionResult GetSeccionesbyCarrera(string carrera)
        {
            try
            {
                var secciones = _seccionService.GetSeccionesbyCarrera(carrera);
                if (secciones == null || !secciones.Any())
                    return NotFound($"No se encontraron secciones para la carrera {carrera}");
                return Ok(secciones);
            }
            catch (Exception ex)
            {
                return StatusCode(500, $"Error interno del servidor: {ex.Message}");
            }
        }

        // GET: api/Seccion/MisSecciones - Endpoint para que un profesor vea sus secciones
        [HttpGet("MisSecciones")]
        [Authorize(Roles = "Profesor")]
        public IActionResult GetMisSecciones()
        {
            try
            {
                // Obtener el ID del usuario desde el token JWT
                var userIdClaim = User.FindFirst(System.Security.Claims.ClaimTypes.NameIdentifier);
                if (userIdClaim == null)
                    return Unauthorized("No se pudo obtener la información del usuario");

                var usuarioId = int.Parse(userIdClaim.Value);

                return Ok(new { Mensaje = $"Secciones del profesor con ID: {usuarioId}" });
            }
            catch (Exception ex)
            {
                return StatusCode(500, $"Error interno del servidor: {ex.Message}");
            }
        }
    }
}