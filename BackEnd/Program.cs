using Entities.Entities;
using Microsoft.EntityFrameworkCore;
using DAL.Interfaces;
using DAL.Interfaces.InterfacesDeEntidades;
using DAL.Implementaciones;
using DAL.Implementaciones.ImplementacionesDeEntidades;
using BackEnd.Servicios.Interfaces;
using BackEnd.Servicios.Implementaciones;
using BackEnd.Helpers.Implementaciones;
using BackEnd.Helpers.Interfaces;
using Microsoft.AspNetCore.Authentication.JwtBearer;
using Microsoft.IdentityModel.Tokens;
using System.Text;

var builder = WebApplication.CreateBuilder(args);

// Add services to the container.
builder.Services.AddControllers();
// Learn more about configuring Swagger/OpenAPI at https://aka.ms/aspnetcore/swashbuckle
builder.Services.AddEndpointsApiExplorer();
builder.Services.AddSwaggerGen();

#region CORS Configuration
// ? AÑADIR ESTA CONFIGURACIÓN DE CORS
builder.Services.AddCors(options =>
{
    options.AddPolicy("AllowReactApp", policy =>
    {
        policy.WithOrigins(
            "http://localhost:3000",    // React con Create React App
            "http://localhost:5173",    // React con Vite
            "http://localhost:5174",    // Vite puerto alternativo
            "http://127.0.0.1:5173",    // Localhost alternativo
            "http://127.0.0.1:3000"     // Localhost alternativo
        )
        .AllowAnyHeader()
        .AllowAnyMethod()
        .AllowCredentials();
    });
});
#endregion


// Configuración de JWT Authentication
var jwtSettings = builder.Configuration.GetSection("JwtSettings");
var secretKey = jwtSettings["SecretKey"];
var issuer = jwtSettings["Issuer"];
var audience = jwtSettings["Audience"];

builder.Services.AddAuthentication(JwtBearerDefaults.AuthenticationScheme)
    .AddJwtBearer(options =>
    {
        options.TokenValidationParameters = new TokenValidationParameters
        {
            ValidateIssuer = true,
            ValidateAudience = true,
            ValidateLifetime = true,
            ValidateIssuerSigningKey = true,
            ValidIssuer = issuer,
            ValidAudience = audience,
            IssuerSigningKey = new SymmetricSecurityKey(Encoding.UTF8.GetBytes(secretKey!)),
            ClockSkew = TimeSpan.Zero
        };
    });

builder.Services.AddAuthorization();

#region ServicesYDBContext
builder.Services.AddDbContext<SistemaCursosContext>(
                                options =>
                                options.UseSqlServer(
                                    builder
                                    .Configuration
                                    .GetConnectionString("DefaultConnection")
                                 ));

// Registro de DAL
builder.Services.AddScoped<ICursoDAL, DALCursoImpl>();
builder.Services.AddScoped<IEvaluacioneDAL, DALEvaluacioneImpl>();
builder.Services.AddScoped<IHorarioDAL, DALHorarioImpl>();
builder.Services.AddScoped<IInscripcioneDAL, DALInscripcioneImpl>();
builder.Services.AddScoped<INotaDAL, DALNotaImpl>();
builder.Services.AddScoped<ISeccioneDAL, DALSeccioneImpl>();
builder.Services.AddScoped<ITipoEvaluacioneDAL, DALTipoEvaluacioneImpl>();
builder.Services.AddScoped<IUsuarioDAL, DALUsuarioImpl>();
builder.Services.AddScoped<IMailHelper, MailHelper>();
builder.Services.AddScoped<IJwtService, JwtService>();
builder.Services.AddScoped<IInscripcionService, InscripcionService>();

// Registro de Unidad de Trabajo
builder.Services.AddScoped<IUnidadDeTrabajo, UnidadDeTrabajo>();

// Registro de Servicios
builder.Services.AddScoped<IUsuarioService, UsuarioService>();
builder.Services.AddScoped<ITipoEvaluacionService, TipoEvaluacionService>();
builder.Services.AddScoped<IEvaluacionService, EvaluacionService>();
builder.Services.AddScoped<IHorarioService, HorarioService>();
builder.Services.AddScoped<ICursoService, CursoService>();
builder.Services.AddScoped<INotaService, NotaService>();

#endregion

var app = builder.Build();

// Configure the HTTP request pipeline.
if (app.Environment.IsDevelopment())
{
    app.UseSwagger();
    app.UseSwaggerUI();
}

#region Middleware Pipeline
// ? IMPORTANTE: UseCors debe ir ANTES de UseAuthorization
app.UseCors("AllowReactApp");

app.UseAuthentication();
app.UseAuthorization();
app.MapControllers();
#endregion

app.Run();