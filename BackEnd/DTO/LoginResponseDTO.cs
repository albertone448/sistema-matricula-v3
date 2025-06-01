namespace BackEnd.DTO
{
    public class LoginResponseDTO
    {
        public int Estado { get; set; }
        public string Mensaje { get; set; } = string.Empty;
        public UsuarioDTO? Usuario { get; set; }
        public string? Token { get; set; }
        public DateTime? TokenExpiration { get; set; }
    }
}
