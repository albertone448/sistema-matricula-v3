using BackEnd.DTO;

namespace BackEnd.Servicios.Interfaces
{
    public interface IJwtService
    {
        string GenerateJwtToken(UsuarioDTO usuario);
        bool ValidateJwtToken(string token);
        UsuarioDTO? GetUserFromToken(string token);
    }
}
