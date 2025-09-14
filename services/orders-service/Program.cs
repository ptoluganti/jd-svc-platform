using Microsoft.EntityFrameworkCore;
using OrdersService.Models;
using OrdersService.Services;
using OrdersService.Data;
using Azure.Messaging.ServiceBus;
using Serilog;
using Azure.Extensions.AspNetCore.Configuration.Secrets;
using Azure.Identity;
using Azure.Security.KeyVault.Secrets;

var builder = WebApplication.CreateBuilder(args);

// Configure Serilog
Log.Logger = new LoggerConfiguration()
    .ReadFrom.Configuration(builder.Configuration)
    .Enrich.FromLogContext()
    .WriteTo.Console()
    .CreateLogger();

builder.Host.UseSerilog();

// Add Key Vault configuration
var keyVaultUrl = builder.Configuration["KeyVault:VaultUrl"];
if (!string.IsNullOrEmpty(keyVaultUrl))
{
    builder.Configuration.AddAzureKeyVault(
        new Uri(keyVaultUrl),
        new DefaultAzureCredential());
}

// Add services to the container
builder.Services.AddControllers();
builder.Services.AddEndpointsApiExplorer();
builder.Services.AddSwaggerGen();

// Add Application Insights
builder.Services.AddApplicationInsightsTelemetry(builder.Configuration);

// Add Entity Framework
builder.Services.AddDbContext<OrdersDbContext>(options =>
    options.UseSqlServer(builder.Configuration.GetConnectionString("DefaultConnection")));

// Add Service Bus
builder.Services.AddSingleton(provider =>
{
    var connectionString = builder.Configuration.GetConnectionString("ServiceBus");
    return new ServiceBusClient(connectionString);
});

// Add custom services
builder.Services.AddScoped<IOrderService, OrderService>();
builder.Services.AddScoped<IMessagePublisher, ServiceBusMessagePublisher>();

// Add health checks
builder.Services.AddHealthChecks()
    .AddDbContext<OrdersDbContext>()
    .AddCheck("serviceBus", () => 
    {
        // Simple health check for Service Bus
        return Microsoft.Extensions.Diagnostics.HealthChecks.HealthCheckResult.Healthy();
    });

var app = builder.Build();

// Configure the HTTP request pipeline
if (app.Environment.IsDevelopment())
{
    app.UseSwagger();
    app.UseSwaggerUI();
}

app.UseHttpsRedirection();
app.UseAuthorization();
app.MapControllers();

// Add health check endpoint
app.MapHealthChecks("/health");

// Ensure database is created
using (var scope = app.Services.CreateScope())
{
    var context = scope.ServiceProvider.GetRequiredService<OrdersDbContext>();
    context.Database.EnsureCreated();
}

Log.Information("Orders Service starting up");

app.Run();