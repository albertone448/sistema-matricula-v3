﻿using BackEnd.DTO;
using BackEnd.Servicios.Interfaces;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;

namespace BackEnd.Controllers
{
    [ApiController]
    [Route("api/[controller]")]
    public class NotaController : ControllerBase
    {
        private readonly INotaService _notaService;

        public NotaController(INotaService notaService)
        {
            _notaService = notaService;
        }

        // GET: api/Nota/GetAllNotas
        [HttpGet("GetAllNotas")]
        [Authorize]
        public IActionResult GetAllNotas()
        {
            try
            {
                var notas = _notaService.GetAllNotas();
                return Ok(notas);
            }
            catch (Exception ex)
            {
                return StatusCode(500, $"Error interno del servidor: {ex.Message}");
            }
        }

        // PUT: api/Nota/UpdateNota
        [HttpPut("UpdateNota")]
        [Authorize]
        public IActionResult UpdateNota([FromBody] NotaDTO notaDTO)
        {
            try
            {
                if (notaDTO == null)
                    return BadRequest("La nota no puede ser nula");

                if (notaDTO.NotaId <= 0)
                    return BadRequest("El ID de la nota debe ser válido");

                if (notaDTO.Total < 0 || notaDTO.Total > 100)
                    return BadRequest("La nota debe estar entre 0 y 100");

                var result = _notaService.UpdateNota(notaDTO);
                if (result)
                    return Ok("Nota actualizada correctamente");
                return BadRequest("Error al actualizar la nota");
            }
            catch (Exception ex)
            {
                return StatusCode(500, $"Error interno del servidor: {ex.Message}");
            }
        }

        // DELETE: api/Nota/DeleteNota
        [HttpDelete("DeleteNota")]
        [Authorize]
        public IActionResult DeleteNota([FromBody] NotaDTO notaDTO)
        {
            try
            {
                if (notaDTO == null)
                    return BadRequest("La nota no puede ser nula");

                if (notaDTO.NotaId <= 0)
                    return BadRequest("El ID de la nota debe ser válido");

                var result = _notaService.DeleteNota(notaDTO);
                if (result)
                    return Ok("Nota eliminada correctamente");
                return BadRequest("Error al eliminar la nota");
            }
            catch (Exception ex)
            {
                return StatusCode(500, $"Error interno del servidor: {ex.Message}");
            }
        }

        // GET: api/Nota/GetNotasPorInscripcion/{inscripcionId}
        [HttpGet("GetNotasPorInscripcion/{inscripcionId}")]
        [Authorize]
        public IActionResult GetNotasPorInscripcion(int inscripcionId)
        {
            try
            {
                if (inscripcionId <= 0)
                    return BadRequest("El ID de inscripción debe ser válido");

                var notas = _notaService.GetNotasPorInscripcion(inscripcionId);
                if (notas == null || !notas.Any())
                    return NotFound($"No se encontraron notas para la inscripción {inscripcionId}");
                return Ok(notas);
            }
            catch (Exception ex)
            {
                return StatusCode(500, $"Error interno del servidor: {ex.Message}");
            }
        }

        // GET: api/Nota/GetNotasPorSeccion/{seccionId}
        [HttpGet("GetNotasPorSeccion/{seccionId}")]
        [Authorize]
        public IActionResult GetNotasPorSeccion(int seccionId)
        {
            try
            {
                if (seccionId <= 0)
                    return BadRequest("El ID de sección debe ser válido");

                var notas = _notaService.GetNotasPorSeccion(seccionId);
                if (notas == null || !notas.Any())
                    return NotFound($"No se encontraron notas para la sección {seccionId}");
                return Ok(notas);
            }
            catch (Exception ex)
            {
                return StatusCode(500, $"Error interno del servidor: {ex.Message}");
            }
        }

        // POST: api/Nota/CrearNota
        [HttpPost("CrearNota")]
        [Authorize]
        public IActionResult CrearNota([FromBody] NotaDTO notaDTO)
        {
            try
            {
                if (notaDTO == null)
                    return BadRequest("La nota no puede ser nula");

                if (notaDTO.EvaluacionId <= 0)
                    return BadRequest("El ID de evaluación debe ser válido");

                if (notaDTO.InscripcionId <= 0)
                    return BadRequest("El ID de inscripción debe ser válido");

                if (notaDTO.Total < 0 || notaDTO.Total > 100)
                    return BadRequest("La nota debe estar entre 0 y 100");

                var result = _notaService.AddNota(notaDTO);
                if (result)
                    return Ok("Nota creada correctamente");
                return BadRequest("Error al crear la nota");
            }
            catch (Exception ex)
            {
                return StatusCode(500, $"Error interno del servidor: {ex.Message}");
            }
        }
    }
}