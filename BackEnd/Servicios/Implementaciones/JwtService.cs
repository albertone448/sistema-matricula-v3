using BackEnd.DTO;
using BackEnd.Servicios.Interfaces;
using Microsoft.IdentityModel.Tokens;
using System.IdentityModel.Tokens.Jwt;
using System.Security.Claims;
using System.Text;

namespace BackEnd.Servicios.Implementaciones
{
    public class JwtService : IJwtService
    {
        private readonly IConfiguration _configuration;
        private readonly string _secretKey;
        private readonly string _issuer;
        private readonly string _audience;
        private readonly int _tokenExpirationMinutes;

        public JwtService(IConfiguration configuration)
        {
            _configuration = configuration;
            _secretKey = _configuration["JwtSettings:SecretKey"] ?? throw new ArgumentNullException("JwtSettings:SecretKey no encontrado");
            _issuer = _configuration["JwtSettings:Issuer"] ?? "SistemaCursos";
            _audience = _configuration["JwtSettings:Audience"] ?? "SistemaCursosAPI";
            _tokenExpirationMinutes = int.Parse(_configuration["JwtSettings:TokenExpirationMinutes"] ?? "60");
        }

        public string GenerateJwtToken(UsuarioDTO usuario)
        {
            try
            {
                var key = new SymmetricSecurityKey(Encoding.UTF8.GetBytes(_secretKey));
                var credentials = new SigningCredentials(key, SecurityAlgorithms.HmacSha256);

                var claims = new[]
                {
                    new Claim(ClaimTypes.NameIdentifier, usuario.UsuarioId.ToString()),
                    new Claim(ClaimTypes.Name, usuario.Nombre),
                    new Claim(ClaimTypes.Email, usuario.Correo),
                    new Claim(ClaimTypes.Role, usuario.Rol),
                    new Claim("Apellido1", usuario.Apellido1),
                    new Claim("Apellido2", usuario.Apellido2),
                    new Claim("Identificacion", usuario.Identificacion),
                    new Claim("Carrera", usuario.Carrera),
                    new Claim("Activo", usuario.Activo.ToString()),
                    new Claim(JwtRegisteredClaimNames.Jti, Guid.NewGuid().ToString()),
                    new Claim(JwtRegisteredClaimNames.Iat,
                        new DateTimeOffset(DateTime.UtcNow).ToUnixTimeSeconds().ToString(),
                        ClaimValueTypes.Integer64)
                };

                var token = new JwtSecurityToken(
                    issuer: _issuer,
                    audience: _audience,
                    claims: claims,
                    expires: DateTime.UtcNow.AddMinutes(_tokenExpirationMinutes),
                    signingCredentials: credentials
                );

                return new JwtSecurityTokenHandler().WriteToken(token);
            }
            catch (Exception ex)
            {
                throw new Exception($"Error generando token JWT: {ex.Message}");
            }
        }

        public bool ValidateJwtToken(string token)
        {
            try
            {
                var tokenHandler = new JwtSecurityTokenHandler();
                var key = Encoding.UTF8.GetBytes(_secretKey);

                tokenHandler.ValidateToken(token, new TokenValidationParameters
                {
                    ValidateIssuerSigningKey = true,
                    IssuerSigningKey = new SymmetricSecurityKey(key),
                    ValidateIssuer = true,
                    ValidIssuer = _issuer,
                    ValidateAudience = true,
                    ValidAudience = _audience,
                    ValidateLifetime = true,
                    ClockSkew = TimeSpan.Zero
                }, out SecurityToken validatedToken);

                return true;
            }
            catch
            {
                return false;
            }
        }

        public UsuarioDTO? GetUserFromToken(string token)
        {
            try
            {
                var tokenHandler = new JwtSecurityTokenHandler();
                var jwt = tokenHandler.ReadJwtToken(token);

                return new UsuarioDTO
                {
                    UsuarioId = int.Parse(jwt.Claims.First(x => x.Type == ClaimTypes.NameIdentifier).Value),
                    Nombre = jwt.Claims.First(x => x.Type == ClaimTypes.Name).Value,
                    Apellido1 = jwt.Claims.First(x => x.Type == "Apellido1").Value,
                    Apellido2 = jwt.Claims.First(x => x.Type == "Apellido2").Value,
                    Identificacion = jwt.Claims.First(x => x.Type == "Identificacion").Value,
                    Correo = jwt.Claims.First(x => x.Type == ClaimTypes.Email).Value,
                    Rol = jwt.Claims.First(x => x.Type == ClaimTypes.Role).Value,
                    Carrera = jwt.Claims.First(x => x.Type == "Carrera").Value,
                    Activo = bool.Parse(jwt.Claims.First(x => x.Type == "Activo").Value)
                };
            }
            catch
            {
                return null;
            }
        }
    }
}