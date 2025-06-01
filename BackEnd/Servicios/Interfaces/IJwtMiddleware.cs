using BackEnd.Servicios.Interfaces;

namespace BackEnd.Middleware
{
    public class IJwtMiddleware
    {
        private readonly RequestDelegate _next;
        private readonly ILogger<IJwtMiddleware> _logger;

        public IJwtMiddleware(RequestDelegate next, ILogger<IJwtMiddleware> logger)
        {
            _next = next;
            _logger = logger;
        }

        public async Task InvokeAsync(HttpContext context, IJwtService jwtService)
        {
            try
            {
                var token = context.Request.Headers["Authorization"]
                    .FirstOrDefault()?.Split(" ").Last();

                if (!string.IsNullOrEmpty(token))
                {
                    // Validar el token
                    if (jwtService.ValidateJwtToken(token))
                    {
                        // Obtener información del usuario del token
                        var usuario = jwtService.GetUserFromToken(token);
                        if (usuario != null)
                        {
                            // Agregar información del usuario al contexto si es necesario
                            context.Items["Usuario"] = usuario;
                            _logger.LogInformation($"Token válido para usuario: {usuario.Correo}");
                        }
                    }
                    else
                    {
                        _logger.LogWarning($"Token inválido recibido desde IP: {context.Connection.RemoteIpAddress}");
                    }
                }

                await _next(context);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error en JWT Middleware");
                await _next(context);
            }
        }
    }

    // Extension method para registrar el middleware fácilmente
    public static class JwtMiddlewareExtensions
    {
        public static IApplicationBuilder UseJwtMiddleware(this IApplicationBuilder builder)
        {
            return builder.UseMiddleware<IJwtMiddleware>();
        }
    }
}